/*==============================================================================
	DESCRIPTION: replicating Table 1
==============================================================================*/		

/*------------------------------------------------------------------------------
	Set paths here
------------------------------------------------------------------------------*/
do "/XX.do"

/*------------------------------------------------------------------------------
	Creating table numbers
------------------------------------------------------------------------------*/

* all (men and women)
use "$data_out/Predicted_wages_1963_2022.dta", clear
drop if expcat==5
forval yr=1963/2022 {
	summ rplnwkw [aw=avlswt] if year==`yr'
	if `yr'==1963 gen ln_mn_wg=r(mean) if year==`yr'
	if `yr'!=1963 replace ln_mn_wg=r(mean) if year==`yr'
}
keep year ln_mn_wg*
gduplicates drop
keep if year==1963 | year==1971 | year==1979 | year==1987 | year==1995 | year==2005 | year==2022
gen diff=ln_mn_wg[_n]-ln_mn_wg[_n-1]
local new = _N + 2
set obs `new'
gen num=_n
foreach yr in 1963 2005 2022 {
	gen wage_`yr'=ln_mn_wg if year==`yr'
	sort wage_`yr'
	carryforward wage_`yr', replace
}
sort num
replace diff=wage_2005-wage_1963 if num==8
replace diff=wage_2022-wage_1963 if num==9
keep diff
drop if missing(diff)
xpose, clear
gen id=_n
tostring id, replace
order id
replace id="All" if id=="1"
save "$data_out/Row_all.dta", replace

* by gender
use "$data_out/Predicted_wages_1963_2022.dta", clear
drop if expcat==5
forval x=0/1 {
	forval yr=1963/2022 {
		summ rplnwkw [aw=avlswt] if female==`x' & year==`yr'
		if `yr'==1963 gen ln_mn_wg_`x'=r(mean) if year==`yr'
		if `yr'!=1963 replace ln_mn_wg_`x'=r(mean) if year==`yr'
}
}
keep year ln_mn_wg*
gduplicates drop
keep if year==1963 | year==1971 | year==1979 | year==1987 | year==1995 | year==2005 | year==2022
forval i=0/1 {
	gen diff`i'=ln_mn_wg_`i'[_n]-ln_mn_wg_`i'[_n-1]
}
local new = _N + 2
set obs `new'
gen num=_n
forval i=0/1 {
foreach yr in 1963 2005 2022 {
	gen wage_`yr'_`i'=ln_mn_wg_`i' if year==`yr'
	sort wage_`yr'_`i'
	carryforward wage_`yr'_`i', replace
}
}
sort num
forval i=0/1 {
	replace diff`i'=wage_2005_`i'-wage_1963_`i' if num==8
	replace diff`i'=wage_2022_`i'-wage_1963_`i' if num==9
}
keep diff*
drop if missing(diff0)
rename diff0 men
rename diff1 women
xpose, clear
gen id=_n
tostring id, replace
order id
replace id="Men" if id=="1"
replace id="Women" if id=="2"
save "$data_out/Row_gender.dta", replace

* by education
use "$data_out/Predicted_wages_1963_2022.dta", clear
drop if expcat==5
forval y=1/5 {
	forval yr=1963/2022 {
		summ rplnwkw [aw=avlswt] if school==`y' & year==`yr'
		if `yr'==1963 gen ln_mn_wg_`y'=r(mean) if year==`yr'
		if `yr'!=1963 replace ln_mn_wg_`y'=r(mean) if year==`yr'
   }
   if `y'==1 label var ln_mn_wg_`y' "HSD"
   if `y'==2 label var ln_mn_wg_`y' "HSG"
   if `y'==3 label var ln_mn_wg_`y' "SMC"
   if `y'==4 label var ln_mn_wg_`y' "CLG"
   if `y'==5 label var ln_mn_wg_`y' "GTC"
}
keep year ln_mn_wg*
gduplicates drop
keep if year==1963 | year==1971 | year==1979 | year==1987 | year==1995 | year==2005 | year==2022
forval y=1/5 {
	gen diff`y'=ln_mn_wg_`y'[_n]-ln_mn_wg_`y'[_n-1]
}
local new = _N + 2
set obs `new'
gen num=_n
forval y=1/5 {
foreach yr in 1963 2005 2022 {
	gen wage_`yr'_`y'=ln_mn_wg_`y' if year==`yr'
	sort wage_`yr'_`y'
	carryforward wage_`yr'_`y', replace
}
}
sort num
forval y=1/5 {
	replace diff`y'=wage_2005_`y'-wage_1963_`y' if num==8
	replace diff`y'=wage_2022_`y'-wage_1963_`y' if num==9
}
keep diff*
drop if missing(diff1)
xpose, clear
gen id=_n
tostring id, replace
order id
replace id="0-11" if id=="1"
replace id="12" if id=="2"
replace id="13-15" if id=="3"
replace id="16-17" if id=="4"
replace id="18+" if id=="5"
save "$data_out/Row_education.dta", replace

// additional education group: 16+ (i.e. college-plus) 
use "$data_out/Predicted_wages_1963_2022.dta", clear
drop if expcat==5
keep if school==4 | school==5
forval yr=1963/2022 {
	summ rplnwkw [aw=avlswt] if year==`yr'
	if `yr'==1963 gen ln_mn_wg_6=r(mean) if year==`yr'
	if `yr'!=1963 replace ln_mn_wg_6=r(mean) if year==`yr'
}
keep year ln_mn_wg*
gduplicates drop
keep if year==1963 | year==1971 | year==1979 | year==1987 | year==1995 | year==2005 | year==2022
gen diff=ln_mn_wg_6[_n]-ln_mn_wg_6[_n-1]
local new = _N + 2
set obs `new'
gen num=_n
foreach yr in 1963 2005 2022 {
	gen wage_`yr'=ln_mn_wg_6 if year==`yr'
	sort wage_`yr'
	carryforward wage_`yr', replace
}
sort num
replace diff=wage_2005-wage_1963 if num==8
replace diff=wage_2022-wage_1963 if num==9
keep diff*
drop if missing(diff)
xpose, clear
gen id=_n
tostring id, replace
order id
replace id="16+" if id=="1"
save "$data_out/Row_education_16plus.dta", replace

* by experience (males)
use "$data_out/Predicted_wages_1963_2022.dta", clear
keep if female==0
keep if expcat==1 // 1st experience group
forval yr=1963/2022 {
	summ rplnwkw [aw=avlswt] if year==`yr'
	if `yr'==1963 gen ln_mn_wg=r(mean) if year==`yr'
	if `yr'!=1963 replace ln_mn_wg=r(mean) if year==`yr'
}
keep year ln_mn_wg*
gduplicates drop
keep if year==1963 | year==1971 | year==1979 | year==1987 | year==1995 | year==2005 | year==2022
gen diff=ln_mn_wg[_n]-ln_mn_wg[_n-1]
local new = _N + 2
set obs `new'
gen num=_n
foreach yr in 1963 2005 2022 {
	gen wage_`yr'=ln_mn_wg if year==`yr'
	sort wage_`yr'
	carryforward wage_`yr', replace
}
sort num
replace diff=wage_2005-wage_1963 if num==8
replace diff=wage_2022-wage_1963 if num==9
keep diff*
drop if missing(diff)
xpose, clear
gen id=_n
tostring id, replace
order id
replace id="5 years" if id=="1"
save "$data_out/Row_experience5.dta", replace

// additional experience group: 25-35 years
use "$data_out/Predicted_wages_1963_2022.dta", clear
keep if female==0
keep if expcat==3 | expcat==4 // 1st experience group
forval yr=1963/2022 {
	summ rplnwkw [aw=avlswt] if year==`yr'
	if `yr'==1963 gen ln_mn_wg_6=r(mean) if year==`yr'
	if `yr'!=1963 replace ln_mn_wg_6=r(mean) if year==`yr'
}
keep year ln_mn_wg*
gduplicates drop
keep if year==1963 | year==1971 | year==1979 | year==1987 | year==1995 | year==2005 | year==2022
gen diff=ln_mn_wg_6[_n]-ln_mn_wg_6[_n-1]
local new = _N + 2
set obs `new'
gen num=_n
foreach yr in 1963 2005 2022 {
	gen wage_`yr'=ln_mn_wg_6 if year==`yr'
	sort wage_`yr'
	carryforward wage_`yr', replace
}
sort num
replace diff=wage_2005-wage_1963 if num==8
replace diff=wage_2022-wage_1963 if num==9
keep diff*
drop if missing(diff)
xpose, clear
gen id=_n
tostring id, replace
order id
replace id="25-35 years" if id=="1"
save "$data_out/Row_experience25_35.dta", replace


* by education and experience (males)
// HSG, 5 years experience
use "$data_out/Predicted_wages_1963_2022.dta", clear
keep if female==0
keep if school==1 // HSG
keep if expcat==1 // 1st experience group
forval yr=1963/2022 {
	summ rplnwkw [aw=avlswt] if year==`yr'
	if `yr'==1963 gen ln_mn_wg=r(mean) if year==`yr'
	if `yr'!=1963 replace ln_mn_wg=r(mean) if year==`yr'
}
keep year ln_mn_wg*
gduplicates drop
keep if year==1963 | year==1971 | year==1979 | year==1987 | year==1995 | year==2005 | year==2022
gen diff=ln_mn_wg[_n]-ln_mn_wg[_n-1]
local new = _N + 2
set obs `new'
gen num=_n
foreach yr in 1963 2005 2022 {
	gen wage_`yr'=ln_mn_wg if year==`yr'
	sort wage_`yr'
	carryforward wage_`yr', replace
}
sort num
replace diff=wage_2005-wage_1963 if num==8
replace diff=wage_2022-wage_1963 if num==9
keep diff*
drop if missing(diff)
xpose, clear
gen id=_n
tostring id, replace
order id
replace id="HSG, 5 years" if id=="1"
save "$data_out/Row_educ12_experience5.dta", replace

// HSG, 25-35 years
use "$data_out/Predicted_wages_1963_2022.dta", clear
keep if female==0
keep if school==1 // HSG
keep if expcat==3 | expcat==4 // 25-35 years experience
forval yr=1963/2022 {
	summ rplnwkw [aw=avlswt] if year==`yr'
	if `yr'==1963 gen ln_mn_wg=r(mean) if year==`yr'
	if `yr'!=1963 replace ln_mn_wg=r(mean) if year==`yr'
}
keep year ln_mn_wg*
gduplicates drop
keep if year==1963 | year==1971 | year==1979 | year==1987 | year==1995 | year==2005 | year==2022
gen diff=ln_mn_wg[_n]-ln_mn_wg[_n-1]
local new = _N + 2
set obs `new'
gen num=_n
foreach yr in 1963 2005 2022 {
	gen wage_`yr'=ln_mn_wg if year==`yr'
	sort wage_`yr'
	carryforward wage_`yr', replace
}
sort num
replace diff=wage_2005-wage_1963 if num==8
replace diff=wage_2022-wage_1963 if num==9
keep diff*
drop if missing(diff)
xpose, clear
gen id=_n
tostring id, replace
order id
replace id="HSG, 25-35 years" if id=="1"
save "$data_out/Row_educ12_experience25_35.dta", replace


// 16+ education, 5 years experience
use "$data_out/Predicted_wages_1963_2022.dta", clear
keep if school==4 | school==5
keep if expcat==1 // 1st experience group
forval yr=1963/2022 {
	summ rplnwkw [aw=avlswt] if year==`yr'
	if `yr'==1963 gen ln_mn_wg_6=r(mean) if year==`yr'
	if `yr'!=1963 replace ln_mn_wg_6=r(mean) if year==`yr'
}
keep year ln_mn_wg*
gduplicates drop
keep if year==1963 | year==1971 | year==1979 | year==1987 | year==1995 | year==2005 | year==2022
gen diff=ln_mn_wg_6[_n]-ln_mn_wg_6[_n-1]
local new = _N + 2
set obs `new'
gen num=_n
foreach yr in 1963 2005 2022 {
	gen wage_`yr'=ln_mn_wg_6 if year==`yr'
	sort wage_`yr'
	carryforward wage_`yr', replace
}
sort num
replace diff=wage_2005-wage_1963 if num==8
replace diff=wage_2022-wage_1963 if num==9
keep diff*
drop if missing(diff)
xpose, clear
gen id=_n
tostring id, replace
order id
replace id="16+, 5 years exp" if id=="1"
save "$data_out/Row_education_16plus_experience5.dta", replace


// 16+ education, 25-35 years experience
use "$data_out/Predicted_wages_1963_2022.dta", clear
keep if school==4 | school==5
keep if expcat==3 | expcat==4 // 1st experience group
forval yr=1963/2022 {
	summ rplnwkw [aw=avlswt] if year==`yr'
	if `yr'==1963 gen ln_mn_wg_6=r(mean) if year==`yr'
	if `yr'!=1963 replace ln_mn_wg_6=r(mean) if year==`yr'
}
keep year ln_mn_wg*
gduplicates drop
keep if year==1963 | year==1971 | year==1979 | year==1987 | year==1995 | year==2005 | year==2022
gen diff=ln_mn_wg_6[_n]-ln_mn_wg_6[_n-1]
local new = _N + 2
set obs `new'
gen num=_n
foreach yr in 1963 2005 2022 {
	gen wage_`yr'=ln_mn_wg_6 if year==`yr'
	sort wage_`yr'
	carryforward wage_`yr', replace
}
sort num
replace diff=wage_2005-wage_1963 if num==8
replace diff=wage_2022-wage_1963 if num==9
keep diff*
drop if missing(diff)
xpose, clear
gen id=_n
tostring id, replace
order id
replace id="16+, 25-35 years exp" if id=="1"
save "$data_out/Row_education_16plus_experience25_35.dta", replace


/*------------------------------------------------------------------------------
	Appending all rows together for table
------------------------------------------------------------------------------*/

use "$data_out/Row_all.dta", clear
append using "$data_out/Row_gender.dta"
append using "$data_out/Row_education.dta"
append using "$data_out/Row_education_16plus.dta"
append using "$data_out/Row_experience5.dta"
append using "$data_out/Row_experience25_35.dta"
append using "$data_out/Row_educ12_experience5.dta"
append using "$data_out/Row_educ12_experience25_35.dta"
append using "$data_out/Row_education_16plus_experience5.dta"
append using "$data_out/Row_education_16plus_experience25_35.dta"

* renaming
rename v1 y1963_1971
rename v2 y1971_1979
rename v3 y1979_1987
rename v4 y1987_1995
rename v5 y1995_2005
rename v6 y2005_2022
rename v7 y1963_2005
rename v8 y1963_2022

* multiplying by 100
foreach var of varlist y* {
	replace `var'=`var'*100
}

* formatting 
format y* %9.1f

* then copy data to latex table-making software

