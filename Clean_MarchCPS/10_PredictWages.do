/*==============================================================================
	DESCRIPTION: This do file predicts weekly and hourly wages by gender for each year. It does 
	so from a regression of real wages regressed on four education categories, 
	three region dummies, race dummies for black and other, a quartic in experience, 
	and interactions of education (3 broad groupings) with the experience quartic. 

	INPUT: ASEC_all_cleaned_NOTOP.dta
	OUTPUT: Predicted_wages.dta
==============================================================================*/		

/*------------------------------------------------------------------------------
	Set paths here
------------------------------------------------------------------------------*/
do "/XX.do"

/*------------------------------------------------------------------------------
	Additional cleaning before predicting wages
------------------------------------------------------------------------------*/
use "$data_out/ASEC_all_cleaned_NOTOP.dta", clear

* logging wages
gen lnwinc=ln(winc_ws)
gen lnhinc=ln(hinc_ws)

* age 16-64 and experience < 49 years
keep if inrange(agely, 16, 64)
drop if exp>48

* drop self-employed
drop if selfemp==1
assert hinc_ws==. if winc_ws==.
assert winc_ws==. if hinc_ws==.
drop if winc_ws==.

* drop allocators
drop if allocated==1

* don't drop top-coded observations
replace tcwkwg=0
replace tchrwg=0

* create 4 experience categories
forval x=5(10)35 {
    gen exp`x'=0
}
replace exp5 = 5 if exp>=0 & exp<=9
replace exp15 = 15 if exp>=10 & exp<=19
replace exp25 = 25 if exp>=20 & exp<=29
replace exp35 = 35 if exp>=30

assert exp5 + exp15 + exp25 + exp35 <= 35
drop exp

* region dummies
gen mw = inlist(statefip,17,18,26,39,55,19,20,27,29,31,38,46)
gen so = inlist(statefip,10,11,12,13,24,37,45,51,54,1,21,28,47,5,22,40,48)
gen we = inlist(statefip,4,8,16,30,32,35,49,56,2,6,15,41,53)

* keeping needed variables
keep ln* edhsd edsmc edclg edgtc exp1 exp2 exp3 exp4 e1* e2* e3* e4* black ///
	other wgt ftfy female tcwkwg tchrwg bcwkwgkm bchrwgkm year ed* deflator weeks_lastyear mw so we pt
drop educ*

* saving
save "$data_out/marchtmp.dta", replace

	
/*------------------------------------------------------------------------------
	Predict weekly wages, using only observations of at least $67/week
------------------------------------------------------------------------------*/

* Step 1: male predicted wages
forval y=1963(1)2022 {
use "$data_out/marchtmp.dta", clear
keep if year==`y'

* Male regression
sort female
reg lnwinc edhsd edsmc edclg edgtc exp1 exp2 exp3 exp4 e1* e2* e3* e4* black ///
	other mw so we [aw=wgt] if ftfy & !female & !tcwkwg & !bcwkwgkm
	
* Predict values
* conduct 25 predictions based upon the the 5 education and 5 experience categories
foreach ed in edhsd edhsg edsmc edclg edgtc {
    * make all covariates equal to zero
    foreach var of varlist female black other ed* exp* e1* e2* e3* e4* {
        replace `var'=0 in 1
    }
    * make appropriate change in education category
    replace `ed'=1 in 1
    * within education category, loop through experience categories and predict
    forval exp=5(10)45  {
        replace exp1=`exp' in 1
        replace exp2=((`exp')^2)/100 in 1
        replace exp3=((`exp')^3)/1000 in 1
        replace exp4=((`exp')^4)/10000 in 1

	  * interact education with experience variables defined above
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
        keep e1* e2* e3* e4* exp* ed* deflator black female other year mw so we
        predict plnwkw in 1
        sum plnwkw
        keep if _n==1
		save "$data_out/marchwk/marchwk-`ed'-exp`exp'-m`y'.dta", replace
		}            
	}     
}


* Step 2: female predicted wages 
forval y=1963(1)2022 {
use "$data_out/marchtmp.dta", clear
keep if year==`y'

* Female regression
gsort -female
reg lnwinc edhsd edsmc edclg edgtc exp1 exp2 exp3 exp4 e1* e2* e3* e4* black ///
	other mw so we [aw=wgt] if ftfy & female & !tcwkwg & !bcwkwgkm

* Predict values
* conduct 25 predictions based upon the the 5 education and 5 experience categories
foreach ed in edhsd edhsg edsmc edclg edgtc {
    * first make all the covariates (except female) equal to zero
    foreach var of varlist black other ed* exp* e1* e2* e3* e4* {
        replace `var'=0 in 1
    }
    replace female=1
    * make appropriate change in education category
    replace `ed'=1 in 1
    * within this education category, loop through experience categories and predict
    forval exp=5(10)45 {
        replace exp1=`exp' in 1
        replace exp2=((`exp')^2)/100 in 1
        replace exp3=((`exp')^3)/1000 in 1
        replace exp4=((`exp')^4)/10000 in 1
	  
      * interact education with experience variables defined above
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
        keep e1* e2* e3* e4* exp* ed* deflator black female other year mw so we
        predict plnwkw in 1
        sum plnwkw
        keep if _n==1
        save "$data_out/marchwk/marchwk-`ed'-exp`exp'-f`y'.dta", replace
		}            
	} 
}    

* Step 3: compile male & female predicted weekly wages
* male
clear
forval y=1963(1)2022 {
	foreach ed in edhsd edhsg edsmc edclg edgtc {
		forval exp=5(10)45 {
			append using "$data_out/marchwk/marchwk-`ed'-exp`exp'-m`y'.dta"
		}	
	} 
}
* female
forval y=1963(1)2022 {
	foreach ed in edhsd edhsg edsmc edclg edgtc {
		forval exp=5(10)45 {
			append using "$data_out/marchwk/marchwk-`ed'-exp`exp'-f`y'.dta"
		}	
	} 
}

gen school = edhsd + 2*edhsg + 3*edsmc + 4*edclg + 5*edgtc
tab school
assert school>0
label define school 1 "Hsd" 2 "Hsg" 3 "Smc" 4 "Clg" 5 "Gtc"
label values school school

sort female school exp1
list plnwkw female school exp1 exp2 exp3 exp4 e1* e2* e3* e4* 
keep year female school exp* plnwkw deflator 
sort year school exp1 female
save "$data_out/pwkwageskm.dta", replace
list
summ plnwkw


/*------------------------------------------------------------------------------
	Predict hourly wages --  Using Only Obs With $67/Week Or More
------------------------------------------------------------------------------*/

* Step 1
forval y=1963(1)2022 {
use "$data_out/marchtmp.dta", clear
keep if year==`y'

* Male regression
sort female
reg lnhinc edhsd edsmc edclg edgtc exp1 exp2 exp3 exp4 e1* e2* e3* e4* pt ///
	black other mw so we [aw=wgt*weeks_lastyear] if !female & !bchrwgkm & !tchrwg

* Predict values
assert female==0 in 1
        
/* Now conduct 25 predictions based upon the the 5 education and 5 experience categories*/
foreach ed in edhsd edhsg edsmc edclg edgtc {
    /* First make all the covariates equal to zero */
    foreach var of varlist female black other ed* exp* e1* e2* e3* e4* pt {
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
        keep e1* e2* e3* e4* exp* ed* deflator black female other year pt mw so we
        predict plnhrw in 1
        sum plnhrw
        keep if _n==1
        save "$data_out/marchhr/marchhr-`ed'-exp`exp'-m`y'.dta", replace
		}            
	} 
}    


* Step 2
forval y=1963(1)2022 {
use "$data_out/marchtmp.dta", clear
keep if year==`y'

* Female regression
gsort -female
reg lnhinc edhsd edsmc edclg edgtc exp1 exp2 exp3 exp4 e1* e2* e3* e4* pt ///
	black other mw so we [aw=wgt*weeks_lastyear] if !female & !bchrwgkm & !tchrwg

* Predict values
assert female==1 in 1

/* Now conduct 25 predictions based upon the the 5 education and 5 experience categories*/
foreach ed in edhsd edhsg edsmc edclg edgtc {
    /* First make all the covariates (except female) equal to zero */
    foreach var of varlist black other ed* exp* e1* e2* e3* e4* pt {
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
        keep e1* e2* e3* e4* exp* ed* deflator black female other year pt mw so we
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
forval y=1963(1)2022 {
	foreach ed in edhsd edhsg edsmc edclg edgtc {
		forval exp=5(10)45 {
			append using "$data_out/marchhr/marchhr-`ed'-exp`exp'-m`y'.dta"
		}	
	} 
}
* female
forval y=1963(1)2022 {
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
summ plnhrw

* keeping variables
keep year female school exp1 plnhrw deflator 
sort female school exp1
merge 1:1 year female school exp1 using "$data_out/pwkwageskm.dta", keepusing(plnwkw)
assert _merge==3
drop _merge

label data "Predicted weekly and hourly wages"
label var deflator "PCE deflator: 2017 basis"
sort female school exp1

* saving
compress
save "$data_out/Predicted_wages.dta", replace

