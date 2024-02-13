/*==============================================================================
	DESCRIPTION: replicating Figure 1
==============================================================================*/		

/*------------------------------------------------------------------------------
	Set paths here
------------------------------------------------------------------------------*/
do "/XX.do"

/*------------------------------------------------------------------------------
	Creating percentiles for 1963, 2005, 2022
------------------------------------------------------------------------------*/
/* In the notes under Figure 1 in AKK, it specifies that the figure reflects the following: 
1) "Data are for full-time, full-year workers ages 16 to 64 with 0 to 39 years of 
potential experience whose class of work in their longest job was private or government
wage/salary employment. 
2) Full-time, full-year workers are those who usually worked 35-plus hours per
week and worked forty plus weeks in the previous year. 
3) Weekly earnings are calculated as the logarithm of annual earnings divided by weeks worked. 
4) Calculations are weighted by CPS sampling weights and are deflated using the 
personal consumption expenditure (PCE) deflator. 
4) Earnings of below $67/week in 1982 dollars ($112/week in 2000 dollars) are dropped. 
5) Allocated earnings observations are excluded in earnings years 1967 forward 
using either family earnings allocation flags (1967–1974) or individual earnings 
allocation flags (1975 earnings year forward)". */

/* Note: In order to replicated this figure, you have to run the cleaning codes 
WITHOUT replacing the top-coded earnings measures with MAXER and MAXWG. */

* 1963
use "$data_out/ASEC_all_cleaned_NOTOP.dta", clear
keep if year==1963 
keep if fulltime==1 // full-time workers, i.e. worked 35+ hours per week
keep if fullyear==1 // full-year workers, i.e. worked 40+ weeks in prior year
keep if agely>=16 & agely<=64 // age 16 to 64
keep if exp<=39 // 0 to 39 years of potential experience
keep if wageworker==1 // longest job was private or gov't wage/salary, no self-employment
drop if bcwkwgkm==1 // drop earnings of below $67/week in 1982 dollars
drop if allocated==1 // drop allocated observations
gen wagewk=winc_ws*deflator // deflate weekly earnings by PCE deflator (2017=1)
replace wagewk=ln(wagewk) // create log weekly earnings
label var wagewk "Log weekly earnings"
drop if missing(winc_ws)
save "$data_out/ASEC_all_cleaned_1963.dta", replace

* percentiles for women
use "$data_out/ASEC_all_cleaned_1963.dta", clear
keep if female==1
gquantiles pct_fem=wagewk [pweight=wgt], pctile nquantiles(100) genp(percent) by(year) strict
keep pct_fem* percent year
drop if missing(percent)
reshape wide pct_fem, i(percent) j(year)
save "$data_out/Female_1963.dta", replace	

* percentiles for men
use "$data_out/ASEC_all_cleaned_1963.dta", clear
keep if female==0
gquantiles pct_male=wagewk [pweight=wgt], pctile nquantiles(100) genp(percent) by(year) strict
keep pct_male* percent year
drop if missing(percent)
reshape wide pct_male, i(percent) j(year)
save "$data_out/Male_1963.dta", replace	

* 2005
use "$data_out/ASEC_all_cleaned_NOTOP.dta", clear
keep if year==2005
keep if fulltime==1 // full-time workers, i.e. worked 35+ hours per week
keep if fullyear==1 // full-year workers, i.e. worked 40+ weeks in prior year
keep if agely>=16 & agely<=64 // age 16 to 64
keep if exp<=39 // 0 to 39 years of potential experience
keep if wageworker==1 // longest job was private or gov't wage/salary, no self-employment
drop if bcwkwgkm==1 // drop earnings of below $67/week in 1982 dollars
drop if allocated==1 // drop allocated observations
gen wagewk=winc_ws*deflator // deflate weekly earnings by PCE deflator (2017=1)
replace wagewk=ln(wagewk) // create log weekly earnings
label var wagewk "Log weekly earnings"
drop if missing(winc_ws)
save "$data_out/ASEC_all_cleaned_2005.dta", replace

* percentiles for women
use "$data_out/ASEC_all_cleaned_2005.dta", clear
keep if female==1
gquantiles pct_fem=wagewk [pweight=wgt], pctile nquantiles(100) genp(percent) by(year) strict
keep pct_fem* percent year
drop if missing(percent)
reshape wide pct_fem, i(percent) j(year)
save "$data_out/Female_2005.dta", replace	

* percentiles for men
use "$data_out/ASEC_all_cleaned_2005.dta", clear
keep if female==0
gquantiles pct_male=wagewk [pweight=wgt], pctile nquantiles(100) genp(percent) by(year) strict
keep pct_male* percent year
drop if missing(percent)
reshape wide pct_male, i(percent) j(year)
save "$data_out/Male_2005.dta", replace	

* 2022
use "$data_out/ASEC_all_cleaned_NOTOP.dta", clear
keep if year==2022
keep if fulltime==1 // full-time workers, i.e. worked 35+ hours per week
keep if fullyear==1 // full-year workers, i.e. worked 40+ weeks in prior year
keep if agely>=16 & agely<=64 // age 16 to 64
keep if exp<=39 // 0 to 39 years of potential experience
keep if wageworker==1 // longest job was private or gov't wage/salary, no self-employment
drop if bcwkwgkm==1 // drop earnings of below $67/week in 1982 dollars
drop if allocated==1 // drop allocated observations
gen wagewk=winc_ws*deflator // deflate weekly earnings by PCE deflator (2017=1)
replace wagewk=ln(wagewk) // create log weekly earnings
label var wagewk "Log weekly earnings"
drop if missing(winc_ws)
save "$data_out/ASEC_all_cleaned_2022.dta", replace

* percentiles for women
use "$data_out/ASEC_all_cleaned_2022.dta", clear
keep if female==1
gquantiles pct_fem=wagewk [pweight=wgt], pctile nquantiles(100) genp(percent) by(year) strict
keep pct_fem* percent year
drop if missing(percent)
reshape wide pct_fem, i(percent) j(year)
save "$data_out/Female_2022.dta", replace	

* percentiles for men
use "$data_out/ASEC_all_cleaned_2022.dta", clear
keep if female==0
gquantiles pct_male=wagewk [pweight=wgt], pctile nquantiles(100) genp(percent) by(year) strict
keep pct_male* percent year
drop if missing(percent)
reshape wide pct_male, i(percent) j(year)
save "$data_out/Male_2022.dta", replace	


/*------------------------------------------------------------------------------
	Figure 1 replication: 1963-2005
------------------------------------------------------------------------------*/
* merging together
use "$data_out/Female_1963.dta", clear
merge 1:1 percent using "$data_out/Male_1963.dta", nogen keep(matched)
merge 1:1 percent using "$data_out/Female_2005.dta", nogen keep(matched)
merge 1:1 percent using "$data_out/Male_2005.dta", nogen keep(matched)

* finding difference
gen dm=pct_male2005-pct_male1963
gen df=pct_fem2005-pct_fem1963
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
	title("1963-2005", color(black) size(medsmall)) ///
	legend(nobox label(1 "Males") label(2 "Females") region(fcolor(white)) pos(6) size(small)) ///
	graphregion(color(white)) ///
	plotregion(lcolor(black)) 
graph export "$figures/Figure1/Figure1_replicationA.eps", replace

/*------------------------------------------------------------------------------
	Figure 1 replication: 1963-2022
------------------------------------------------------------------------------*/
* merging together
use "$data_out/Female_1963.dta", clear
merge 1:1 percent using "$data_out/Male_1963.dta", nogen keep(matched)
merge 1:1 percent using "$data_out/Female_2022.dta", nogen keep(matched)
merge 1:1 percent using "$data_out/Male_2022.dta", nogen keep(matched)

* finding difference
gen dm=pct_male2022-pct_male1963
gen df=pct_fem2022-pct_fem1963
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
	title("1963-2022", color(black) size(medsmall)) ///
	legend(nobox label(1 "Males") label(2 "Females") region(fcolor(white)) pos(6) size(small)) ///
	graphregion(color(white)) ///
	plotregion(lcolor(black)) 
graph export "$figures/Figure1/Figure1_replicationB.eps", replace


* removing datasets no longer needed
rm "$data_out/ASEC_all_cleaned_1963.dta"
rm "$data_out/ASEC_all_cleaned_2005.dta"
rm "$data_out/ASEC_all_cleaned_2022.dta"
rm "$data_out/Female_1963.dta"
rm "$data_out/Male_1963.dta"
rm "$data_out/Female_2005.dta"
rm "$data_out/Male_2005.dta"
rm "$data_out/Female_2022.dta"
rm "$data_out/Male_2022.dta"
