/*==============================================================================
						Predict Wages -- MORG
==============================================================================*/		
cap log close 
clear all 
set more off

** SET PATHS HERE
run "/Users/corinnes/Dropbox/0 Research/5_AKK_replication/Scripts/Clean_MarchCPS/0_Paths"

/* Note: The subsequent do files build on code publicly available that is used
in AKK (2008) and Autor, Goldin and Katz (2020). */

/*------------------------------------------------------------------------------
	Additional cleaning before predicting wages
------------------------------------------------------------------------------*/
use "$data_out/MayCPS_MORG_cleaned.dta", clear

* keep experience less than 49 years
drop if exp>48

* drop allocators
drop if allocated==1

* create experience categories 
forval x=5(10)45 {
    gen exp`x'=0
}
replace exp5=5 if exp>=0 & exp<=9
replace exp15=15 if exp>=10 & exp<=19
replace exp25=25 if exp>=20 & exp<=29
replace exp35=35 if exp>=30 & exp<=39
replace exp45=45 if exp>=40 & exp<=48
assert exp5 + exp15 + exp25 + exp35 + exp45 <= 45

* saving
save "$data_out/marchtmp.dta", replace

/*------------------------------------------------------------------------------
	Predict hourly wages
------------------------------------------------------------------------------*/

* Step 1
forval y=1973(1)2020 {
use "$data_out/marchtmp.dta", clear
keep if year==`y'

* Male regression
sort female
reg lnrhinc edhsd edsmc edclg edgtc exp1 exp2 exp3 exp4 e1* e2* e3* e4* pt ///
	black other [aw=wgt_hrs] if !female & !hr_w2low & !hr_w2hi

* Predict values
assert female==0 in 1
        
/* Now conduct 25 predictions based upon the the 5 education and 5 experience categories*/
foreach ed in edhsd edhsg edsmc edclg edgtc {
    /* First make all the covariates equal to zero */
    foreach var of varlist female black other pt ed* exp* e1* e2* e3* e4* {
        replace `var'=0 in 1
    }
    /* Make the appropriate change in education category*/
    replace `ed'=1 in 1
    /* Within this education category, loop through experience categories and predict*/
    forval exp=5(10)45 {
        replace exp1=`exp' in 1
        replace exp2=((`exp')^2)/100 in 1
        replace exp3=((`exp')^3)/1000 in 1
        replace exp4=((`exp')^4)/10000 in 1
	  
      /* Interact education with experience variables defined above */
  	  if "`ed'"!="edhsg" & "`ed'"!="edgtc" {    
                replace e1`ed'=exp1 in 1
                replace e2`ed'=exp2 in 1
                replace e3`ed'=exp3 in 1
                replace e4`ed'=exp4 in 1
            }
      if "`ed'"=="edgtc" { 
            replace e1edclg=exp1 in 1
            replace e2edclg=exp2 in 1
            replace e3edclg=exp3 in 1
            replace e4edclg=exp4 in 1
            }      
        keep e1* e2* e3* e4* exp* ed* deflator black female other pt year 
        predict plnhrw in 1
        sum plnhrw
        keep if _n==1
        save "$data_out/marchhr/marchhr-`ed'-exp`exp'-m`y'.dta", replace
		}            
	} 
}    


* Step 2
forval y=1973(1)2020 {
use "$data_out/marchtmp.dta", clear
keep if year==`y'

* Female regression
gsort -female
reg lnrhinc edhsd edsmc edclg edgtc exp1 exp2 exp3 exp4 e1* e2* e3* e4* pt ///
	black other [aw=wgt_hrs] if female & !hr_w2low & !hr_w2hi

* Predict values
assert female==1 in 1

/* Now conduct 25 predictions based upon the the 5 education and 5 experience categories*/
foreach ed in edhsd edhsg edsmc edclg edgtc {
    /* First make all the covariates (except female) equal to zero */
    foreach var of varlist black other pt ed* exp* e1* e2* e3* e4* {
        replace `var'=0 in 1
    }
    replace female=1
    /* Make the appropriate change in education category*/
    replace `ed'=1 in 1
    /* Within this education category, loop through experience categories and predict*/
    forval exp=5(10)45 {
        replace exp1=`exp' in 1
        replace exp2=((`exp')^2)/100 in 1
        replace exp3=((`exp')^3)/1000 in 1
        replace exp4=((`exp')^4)/10000 in 1
	  
      /* Interact education with experience variables defined above */
  	  if "`ed'"!="edhsg" & "`ed'"!="edgtc" {    
                replace e1`ed'=exp1 in 1
                replace e2`ed'=exp2 in 1
                replace e3`ed'=exp3 in 1
                replace e4`ed'=exp4 in 1
            }
      if "`ed'"=="edgtc" { 
            replace e1edclg=exp1 in 1
            replace e2edclg=exp2 in 1
            replace e3edclg=exp3 in 1
            replace e4edclg=exp4 in 1
            }      
        keep e1* e2* e3* e4* exp* ed* deflator black female other pt year 
        predict plnhrw in 1
        sum plnhrw
        keep if _n==1
        save "$data_out/marchhr/marchhr-`ed'-exp`exp'-f`y'.dta", replace
		}            
	}    
} 

* compile predicted hourly wages
* male
clear
forval y=1973(1)2020 {
	foreach ed in edhsd edhsg edsmc edclg edgtc {
		forval exp=5(10)45 {
			append using "$data_out/marchhr/marchhr-`ed'-exp`exp'-m`y'.dta"
		}	
	} 
}
* female
forval y=1973(1)2020 {
	foreach ed in edhsd edhsg edsmc edclg edgtc {
		forval exp=5(10)45 {
			append using "$data_out/marchhr/marchhr-`ed'-exp`exp'-f`y'.dta"
		}	
	} 
}

gen school = edhsd + 2*edhsg + 3*edsmc + 4*edclg + 5*edgtc
tab school
assert school>0
label define school 1 "Hsd" 2 "Hsg" 3 "Smc" 4 "Clg" 5 "Gtc"
label values school school

sort female school exp1
list plnhrw female school exp1 exp2 exp3 exp4 e1* e2* e3* e4*
// assert _N==50
list
summ plnhrw

* keeping variabless
keep year female school exp1 plnhrw deflator 
sort female school exp1
label data "Predicted weekly and hourly wages"
// gen year=year-1
// label var year "Earnings year"
label var deflator "PCE deflator: 2012 basis"
sort female school exp1

* saving
save "$data_out/Predicted_wages_MORG.dta", replace

* deleting data files
!rm "$data_out/marchtmp.dta"
