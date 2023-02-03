/*==============================================================================
						Replicating Figure 1
==============================================================================*/		
cap log close 
clear all 
set more off

** Set paths here
run "SET/PATHS/HERE"

/*------------------------------------------------------------------------------
	Creating percentiles for 1963, 2005, 2019
------------------------------------------------------------------------------*/
/* Note: In order to replicate this figure, you have to run the cleaning codes 
WITHOUT replacing the top-coded earnings measures with MAXER and MAXWG. */

* 1964
use "$data_out/ASEC_all_cleaned_NOTOP.dta", clear
keep if year==1964 // | year==2006
keep if fulltime==1 // full-time workers, i.e. worked 35+ hours per week
keep if fullyear==1 // full-year workers, i.e. worked 40+ weeks in prior year
keep if age>=16 & age<=64 // age 16 to 64
keep if exp<=39 // 0 to 39 years of potential experience
keep if wageworker==1 // longest job was private or gov't wage/salary, no self-employment
drop if bcwkwgkm==1 // drop earnings of below $67/week in 1982 dollars
drop if allocated==1 // drop allocated observations
gen wagewk=winc_ws*deflator // deflate weekly earnings by PCE deflator
replace wagewk=ln(wagewk) // create log weekly earnings
label var wagewk "Log weekly earnings"
drop if missing(winc_ws)
save "$data_out/ASEC_all_cleaned_1964.dta", replace

* percentiles for women
use "$data_out/ASEC_all_cleaned_1964.dta", clear
keep if female==1
gquantiles pct_fem=wagewk [pweight=wgt], pctile nquantiles(100) genp(percent) by(year) strict
keep pct_fem* percent year
drop if missing(percent)
reshape wide pct_fem, i(percent) j(year)
save "$data_out/Female_1964.dta", replace	

* percentiles for men
use "$data_out/ASEC_all_cleaned_1964.dta", clear
keep if female==0
gquantiles pct_male=wagewk [pweight=wgt], pctile nquantiles(100) genp(percent) by(year) strict
keep pct_male* percent year
drop if missing(percent)
reshape wide pct_male, i(percent) j(year)
save "$data_out/Male_1964.dta", replace	

* 2006
use "$data_out/ASEC_all_cleaned_NOTOP.dta", clear
keep if year==2006
keep if fulltime==1 // full-time workers, i.e. worked 35+ hours per week
keep if fullyear==1 // full-year workers, i.e. worked 40+ weeks in prior year
keep if age>=16 & age<=64 // age 16 to 64
keep if exp<=39 // 0 to 39 years of potential experience
keep if wageworker==1 // longest job was private or gov't wage/salary, no self-employment
drop if bcwkwgkm==1 // drop earnings of below $67/week in 1982 dollars
drop if allocated==1 // drop allocated observations
gen wagewk=winc_ws*deflator // deflate weekly earnings by PCE deflator
replace wagewk=ln(wagewk) // create log weekly earnings
label var wagewk "Log weekly earnings"
drop if missing(winc_ws)
save "$data_out/ASEC_all_cleaned_2006.dta", replace

* percentiles for women
use "$data_out/ASEC_all_cleaned_2006.dta", clear
keep if female==1
gquantiles pct_fem=wagewk [pweight=wgt], pctile nquantiles(100) genp(percent) by(year) strict
keep pct_fem* percent year
drop if missing(percent)
reshape wide pct_fem, i(percent) j(year)
save "$data_out/Female_2006.dta", replace	

* percentiles for men
use "$data_out/ASEC_all_cleaned_2006.dta", clear
keep if female==0
gquantiles pct_male=wagewk [pweight=wgt], pctile nquantiles(100) genp(percent) by(year) strict
keep pct_male* percent year
drop if missing(percent)
reshape wide pct_male, i(percent) j(year)
save "$data_out/Male_2006.dta", replace	

* 2020
use "$data_out/ASEC_all_cleaned_NOTOP.dta", clear
keep if year==2020
keep if fulltime==1 // full-time workers, i.e. worked 35+ hours per week
keep if fullyear==1 // full-year workers, i.e. worked 40+ weeks in prior year
keep if age>=16 & age<=64 // age 16 to 64
keep if exp<=39 // 0 to 39 years of potential experience
keep if wageworker==1 // longest job was private or gov't wage/salary, no self-employment
drop if bcwkwgkm==1 // drop earnings of below $67/week in 1982 dollars
drop if allocated==1 // drop allocated observations
gen wagewk=winc_ws*deflator // deflate weekly earnings by PCE deflator
replace wagewk=ln(wagewk) // create log weekly earnings
label var wagewk "Log weekly earnings"
drop if missing(winc_ws)
save "$data_out/ASEC_all_cleaned_2020.dta", replace

* percentiles for women
use "$data_out/ASEC_all_cleaned_2020.dta", clear
keep if female==1
gquantiles pct_fem=wagewk [pweight=wgt], pctile nquantiles(100) genp(percent) by(year) strict
keep pct_fem* percent year
drop if missing(percent)
reshape wide pct_fem, i(percent) j(year)
save "$data_out/Female_2020.dta", replace	

* percentiles for men
use "$data_out/ASEC_all_cleaned_2020.dta", clear
keep if female==0
gquantiles pct_male=wagewk [pweight=wgt], pctile nquantiles(100) genp(percent) by(year) strict
keep pct_male* percent year
drop if missing(percent)
reshape wide pct_male, i(percent) j(year)
save "$data_out/Male_2020.dta", replace	


/*------------------------------------------------------------------------------
	Figure 1 replication: 1963-2005
------------------------------------------------------------------------------*/
* merging together
use "$data_out/Female_1964.dta", clear
merge 1:1 percent using "$data_out/Male_1964.dta", nogen keep(matched)
merge 1:1 percent using "$data_out/Female_2006.dta", nogen keep(matched)
merge 1:1 percent using "$data_out/Male_2006.dta", nogen keep(matched)

* finding difference
gen dm=pct_male2006-pct_male1964
gen df=pct_fem2006-pct_fem1964
label var dm "Males"
label var df "Females"
label var percent "Weekly Wage Percentile"

* dropping extreme percentiles
keep if percent>=3 & percent<=97

* figure
twoway ///
	connected dm df percent ///
	, lwidth(medium medium) xlabel(0(10)100, labsize(small)) ///
	ylabel(0(.1)1, nogrid labsize(small)) ///
	msymbol(Oh Dh) msize(vsmall vsmall) mlwidth(medium medium) ///
	l1title("") l2title("Log Earnings Change") ///
	xtitle("Weekly Wage Percentile", size(small)) ///
	title("A. 1963-2005", color(black) size(medsmall)) ///
	legend(nobox label(1 "Males") label(2 "Females") region(fcolor(white)) pos(6) size(small)) ///
	graphregion(color(white)) ///
	plotregion(lcolor(black)) ///
	saving("$figures/Figure1/Figure1_replicationA.gph",replace)
graph export "$figures/Figure1/Figure1_replicationA.pdf", replace

/*------------------------------------------------------------------------------
	Figure 1 extension: 1963-2019
------------------------------------------------------------------------------*/
* merging together
use "$data_out/Female_1964.dta", clear
merge 1:1 percent using "$data_out/Male_1964.dta", nogen keep(matched)
merge 1:1 percent using "$data_out/Female_2020.dta", nogen keep(matched)
merge 1:1 percent using "$data_out/Male_2020.dta", nogen keep(matched)

* finding difference
gen dm=pct_male2020-pct_male1964
gen df=pct_fem2020-pct_fem1964
label var dm "Males"
label var df "Females"
label var percent "Weekly Wage Percentile"

* dropping extreme percentiles
keep if percent>=3 & percent<=97

* figure
twoway ///
	connected dm df percent ///
	, lwidth(medium medium) xlabel(0(10)100, labsize(small)) ///
	ylabel(0(.1)1.3, nogrid labsize(small)) ///
	msymbol(Oh Dh) msize(vsmall vsmall) mlwidth(medium medium) ///
	l1title("") l2title("Log Earnings Change") ///
	xtitle("Weekly Wage Percentile", size(small)) ///
	title("B. 1963-2019", color(black) size(medsmall)) ///
	legend(nobox label(1 "Males") label(2 "Females") region(fcolor(white)) pos(6) size(small)) ///
	graphregion(color(white)) ///
	plotregion(lcolor(black)) ///
	saving("$figures/Figure1/Figure1_replicationB.gph",replace)
graph export "$figures/Figure1/Figure1_replicationB.pdf", replace
