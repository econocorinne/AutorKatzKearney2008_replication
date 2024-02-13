/*==============================================================================
	DESCRIPTION: predict MORG wages
	
	DATE: February 2024
==============================================================================*/		

/*------------------------------------------------------------------------------
	Set paths here
------------------------------------------------------------------------------*/
do "/XX.do"

/*------------------------------------------------------------------------------
	Additional cleaning before predicting wages
------------------------------------------------------------------------------*/
/*
Sample for panel B is CPS May/ORG, all hourly workers for earnings years 1973–2005. Processing of
March CPS data A is detailed in table 1 and figure 1 notes. For panel B, samples are drawn from May
CPS for 1973 to 1978 and CPS Merged Outgoing Rotation Group for years 1979 to 2005. Sample is
limited to wage/salary workers ages 16 to 64 with 0 to 39 years of potential experience in current
employment. Calculations are weighted by CPS sample weight times hours worked in the prior week.
Hourly wages are equal to the logarithm of reported hourly earnings for those paid by the hour and the
logarithm of usual weekly earnings divided by hours worked last week for nonhourly workers. Top-coded
earnings observations are multiplied by 1.5. Hourly earners of below $1.675/hour in 1982 dollars
($2.80/hour in 2000 dollars) are dropped, as are hourly wages exceeding 1/35th the top-coded value of
weekly earnings. All earnings are deflated by the chain-weighted (implicit) price deflator for personal
consumption expenditures (PCE). Allocated earnings observations are excluded in all years, except where
allocation flags are unavailable (January 1994 to August 1995). Where possible, we identify and drop
nonflagged allocated observations by using the unedited earnings values provided in the source data.

We calculate composition-adjusted college/high school relative wages
overall and by age or experience using the March and May/ORG samples
described above. These data are sorted into sex-education-experience
groups based on a breakdown of the data into:
2 sexes, 5 education categories (high school dropout, high school graduate, some college,
college plus, and greater than college), and 4 potential experience
categories (0–9, 10–19, 20–29, and 30+ years). 

Log weekly wages of full-time, full-year workers (March CPS) and all hourly workers (May/
ORG) are regressed in each year separately by sex on the dummy
variables for four education categories, a quartic in experience, three
region dummies, black and other race dummies, and interactions of the
experience quartic with three broad education categories (high school
graduate, some college, and college plus). 

The (composition-adjusted)
mean log wage for each of the forty groups in a given year is the predicted
log wage from these regressions evaluated for whites, living in the mean
geographic region, at the relevant experience level (5, 15, 25, or 35 years
depending on the experience group). Mean log wages for broader groups
in each year represent weighted averages of the relevant (compositionadjusted)
cell means using a fixed set of weights, equal to the mean share
of total hours worked by each group over 1963 to 2005 from the March
CPS.
*/

use "$data_out/MayCPS_MORG_cleaned.dta", clear

* keep experience less than 39 years
drop if exp>39

* drop allocators
drop if alloc==1

* drop self-employed
keep if (inrange(class_new, 0, 2) & year>=1973 & year<=1978) | (inrange(class_new, 0, 4) & year>=1979 & year<=2020) 

* saving
save "$data_out/marchtmp.dta", replace


/*------------------------------------------------------------------------------
	Predict hourly wages
------------------------------------------------------------------------------*/

/* Description for Figure 2: 
For panel B, samples are drawn from May CPS for 1973 to 1978 and CPS Merged Outgoing Rotation Group for years 1979 to 2005. Sample is
limited to wage/salary workers ages 16 to 64 with 0 to 39 years of potential experience in current
employment. Calculations are weighted by CPS sample weight times hours worked in the prior week.

Hourly wages are equal to the logarithm of reported hourly earnings for those paid by the hour and the
logarithm of usual weekly earnings divided by hours worked last week for nonhourly workers. Top-coded
earnings observations are multiplied by 1.5. Hourly earners of below $1.675/hour in 1982 dollars
($2.80/hour in 2000 dollars) are dropped, as are hourly wages exceeding 1/35th the top-coded value of
weekly earnings. All earnings are deflated by the chain-weighted (implicit) price deflator for personal
consumption expenditures (PCE). Allocated earnings observations are excluded in all years, except where
allocation flags are unavailable (January 1994 to August 1995). Where possible, we identify and drop
nonflagged allocated observations by using the unedited earnings values provided in the source data.

Description for Figure 8: 
CPS May/ORG samples for all hourly workers are detailed in notes to figure 2. 
Series labeled “observed residual” presents the 90/50 or 50/10 difference in wage 
residuals from an OLS regression (weighted by CPS sampling weight times hours worked
in the prior week) of log hourly earnings on a full set of age dummies, dummies for 
nine discrete schooling categories, and a full set of interactions among the schooling 
dummies and a quartic in age. All models are estimated separately by gender.

*/ 

* Step 1
forval y=1973(1)2020 {
use "$data_out/marchtmp.dta", clear
keep if year==`y'

* male regression
sort female
reg lnrhinc edhsd edsmc edclg edgtc exp1 exp2 exp3 exp4 e1* e2* e3* e4* pt ///
	black other ne mw so [aw=wgt_hrs] if !female & !hr_w2low & !hr_w2hi
	
* predict values
assert female==0 in 1
        
* conduct 25 predictions based upon the the 5 education and 5 experience categories
foreach ed in edhsd edhsg edsmc edclg edgtc {
    * first make all the covariates equal to zero
    foreach var of varlist female black other pt ed* exp* e1* e2* e3* e4* ne mw so {
        replace `var'=0 in 1
    }
    * make the appropriate change in education category
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
        keep e1* e2* e3* e4* exp* ed* deflator black female other pt year ne mw so
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

* female regression
gsort -female
reg lnrhinc edhsd edsmc edclg edgtc exp1 exp2 exp3 exp4 e1* e2* e3* e4* pt ///
	black other ne mw so [aw=wgt_hrs] if female & !hr_w2low & !hr_w2hi

* predict values
assert female==1 in 1

* conduct 25 predictions based upon the the 5 education and 5 experience categories
foreach ed in edhsd edhsg edsmc edclg edgtc {
    * first make all the covariates (except female) equal to zero
    foreach var of varlist black other pt ed* exp* e1* e2* e3* e4* ne mw so {
        replace `var'=0 in 1
    }
    replace female=1
    * make the appropriate change in education category
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
        keep e1* e2* e3* e4* exp* ed* deflator black female other pt year ne mw so
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
list
summ plnhrw

* keeping variabless
keep year female school exp1 plnhrw deflator 
sort female school exp1
label data "Predicted weekly and hourly wages"
label var deflator "PCE deflator: 2017 basis"
sort female school exp1

* saving
save "$data_out/Predicted_wages_MORG.dta", replace
