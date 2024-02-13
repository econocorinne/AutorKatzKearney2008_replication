/*==============================================================================
	DESCRIPTION: replicating Figure 2
==============================================================================*/		

/*------------------------------------------------------------------------------
	Set paths here
------------------------------------------------------------------------------*/
do "/XX.do"

/*------------------------------------------------------------------------------
/*------------------------------------------------------------------------------
	Panel A
------------------------------------------------------------------------------*/
------------------------------------------------------------------------------*/

/*------------------------------------------------------------------------------
	90/10 percentile
------------------------------------------------------------------------------*/
use "$data_out/ASEC_all_cleaned_NOTOP.dta", clear
keep if fulltime==1 // full-time workers, i.e. worked 35+ hours per week
keep if fullyear==1 // full-year workers, i.e. worked 40+ weeks in prior year
rename agely age
keep if exp<=39 // 0 to 39 years of potential experience
keep if wageworker==1 // longest job was private or gov't wage/salary, no self-employment
drop if bcwkwgkm==1 // drop earnings of below $67/week in 1982 dollars
drop if allocated==1 // drop allocated observations
drop if missing(lnrwinc)
keep if female==0 // just male earnings
gen r90=.
gen r10=.
forval i=1963(1)2022 {
	summ lnrwinc if year==`i' [aw=wgt], detail
	replace r90 = _result(12) if year==`i'
	replace r10=  _result(8) if year==`i'
	gen r9010`i' =r90-r10 if year==`i'
}	
keep year r9010*
gduplicates drop
egen ineq_9010=rowtotal(r9010*)
drop r9010*
save "$data_out/wage_90_10_inequality_series.dta", replace

/*------------------------------------------------------------------------------
	College/HS gap
------------------------------------------------------------------------------*/
use "$data_out/College_HS_wage_premium_exp.dta", clear
keep clphsg_all clghsg_all year
duplicates drop
save "$data_out/college_HS_gap.dta", replace

/*------------------------------------------------------------------------------
	Residual 90/10
------------------------------------------------------------------------------*/
/* The residual 90/10 series depicts the 90-10 difference in wage residuals from 
a regression of the log wage measure on a full set of age dummies, dummies for 
nine discrete schooling categories, and a full set of interactions among the 
schooling dummies and a quartic in age. */
use "$data_out/ASEC_all_cleaned_NOTOP.dta", clear
keep if exp<=39 // 0 to 39 years of potential experience
keep if fulltime==1 // full-time workers, i.e. worked 35+ hours per week
keep if fullyear==1 // full-year workers, i.e. worked 40+ weeks in prior year
drop if allocated==1 // drop allocated observations
keep if wageworker==1 // longest job was private or gov't wage/salary, no self-employment
drop if bcwkwgkm==1 // drop earnings of below $67/week in 1982 dollars
keep if female==0 // just male earnings
drop if missing(lnrwinc)
rename agely age

* keeping needed variables
drop educ edhsd edhsg edsmc edclg edgtc

* age indicators
xi i.age

* creating interactions
foreach ed of varlist ed0_4 ed5_8 ed9 ed10 ed11 ed12 ed13_15 ed16 ed17p {
	gen ageX`ed' = age*`ed'
	gen agesqX`ed' = (age^2)*`ed'
	gen age3X`ed' = (age^3)*`ed'
	gen age4X`ed' = (age^4)*`ed'
}

* regression
gen reswagewk=.
gen rvln=.
gen r90=.
gen r50=.
gen r10=.
forval i=1963(1)2022 {
	local RHS = "ed0_4 ed5_8 ed9 ed10 ed11 ed12 ed13_15 ed16 ed17p _Iage* ageX* agesqX* age3X* age4X*"
	reg lnrwinc `RHS' if year==`i' [aw=wgt]
	predict reswagewk`i' if year==`i', resid
	summ reswagewk`i'

	replace reswagewk = reswagewk`i' if year==`i'

	summ reswagewk if year==`i' [aw=wgt], detail
	replace rvln = _result(4) if year==`i'
	replace r90 = _result(12) if year==`i'
	replace r50 = _result(10) if year==`i' 
	replace r10=  _result(8) if year==`i'

	gen r9010`i' =r90-r10 if year==`i'
	gen r9050`i' =r90-r50 if year==`i'
	gen r5010`i' =r50-r10 if year==`i'
}

keep year r9010*
gduplicates drop
egen resid_9010=rowtotal(r9010*)
drop r9010*
save "$data_out/wage_90_10_resid_inequality_series.dta", replace

/*------------------------------------------------------------------------------
	Figure Panel A 
------------------------------------------------------------------------------*/
* merging datasets together
use "$data_out/wage_90_10_inequality_series.dta", clear
merge 1:1 year using "$data_out/college_HS_gap.dta", nogen
merge 1:1 year using "$data_out/wage_90_10_resid_inequality_series.dta", nogen

* figure
twoway ///
	(connected ineq_9010 resid_9010 year, yaxis(2) lwidth(medium medium) ///
	msymbol(Oh Dh) msize(vsmall vsmall) mlwidth(medium medium)) /// 
	(connected clphsg_all year, yaxis(1) lwidth(medium) ///
	msymbol(Th) msize(vsmall) mlwidth(medium)) ///
	, ///
	ylabel(0.35(.05)0.7, labsize(small) axis(1) nogrid angle(0) format(%9.2fc)) ///
	ylabel(0.8(.1)1.8, labsize(small) axis(2) nogrid angle(0) format(%9.1fc)) ///
	xlabel(1963(6)2022, labsize(small)) ///
	xline(1973 1979 1992, lstyle(background) lcolor(gs11) lpattern(dash)) ///
	legend(off) graphregion(color(white)) ///
	title("A. March CPS Full-Time Weekly Earnings, 1963-2022", size(medsmall) color(black)) ///
	xtitle("") ///
	ytitle("Log College/HS Wage Gap", size(small) axis(1)) ///
	ytitle("Log Earnings Ratio", size(small) axis(2)) ///
	plotregion(lcolor(black) lwidth(thin)) 
graph export "$figures/Figure2/Figure2_replication_PanelA.eps", replace

* removing datasets no longer needed
save "$data_out/wage_90_10_inequality_series.dta", replace
save "$data_out/college_HS_gap.dta", replace


/*------------------------------------------------------------------------------
/*------------------------------------------------------------------------------
	Panel B
------------------------------------------------------------------------------*/
------------------------------------------------------------------------------*/

/* FROM PAPER: 
For panel B, samples are drawn from May CPS for 1973 to 1978 and CPS Merged 
Outgoing Rotation Group for years 1979 to 2005. Sample is limited to:
- wage/salary workers 
- ages 16 to 64 
- 0 to 39 years of potential experience in current employment
- Calculations are weighted by CPS sample weight times hours worked in the prior week
- Hourly wages are equal to the logarithm of reported hourly earnings for those paid by the hour and the
logarithm of usual weekly earnings divided by hours worked last week for nonhourly workers
- Top-coded earnings observations are multiplied by 1.5
- Hourly earners of below $1.675/hour in 1982 dollars ($2.80/hour in 2000 dollars) are dropped, 
as are hourly wages exceeding 1/35th the top-coded value of weekly earnings 
- All earnings are deflated by the chain-weighted (implicit) price deflator for personal
consumption expenditures (PCE) 
- Allocated earnings observations are excluded in all years, except where
allocation flags are unavailable (January 1994 to August 1995) 
- Where possible, we identify and drop nonflagged allocated observations by using 
the unedited earnings values provided in the source data. */

/*------------------------------------------------------------------------------
	90/10 percentile
------------------------------------------------------------------------------*/
use "$data_out/MayCPS_MORG_cleaned.dta", clear
// tabstat hourlyworker, by(year) stat(min max mean N)
// keep if hourlyworker==1
keep if exp<=39 // 0 to 39 years of potential experience
keep if (inrange(class_new, 0, 2) & year>=1973 & year<=1978) | (inrange(class_new, 0, 4) & year>=1979 & year<=2020) // dropping self-employed
drop if hr_w2low==1 // drop hourly earners of below $1.675/hour in 1982 dollars
drop if hr_w2hi==1 // drop hourly wages exceeding 1/35th the topcoded value of weekly earnings
drop if alloc==1 // drop allocated
keep if female==0 // just male earnings
drop if missing(lnrhinc)
gen r90=.
gen r10=.
forval i=1973(1)2020 {
	summ lnrhinc if year==`i' [aw=wgt_hrs], detail
	replace r90 = _result(12) if year==`i'
	replace r10=  _result(8) if year==`i'
	gen r9010`i' =r90-r10 if year==`i'
}	
keep year r9010*
gduplicates drop
egen ineq_9010=rowtotal(r9010*)
drop r9010*
save "$data_out/wage_90_10_inequality_series_MORG.dta", replace


/*------------------------------------------------------------------------------
	College/HS gap
------------------------------------------------------------------------------*/
use "$data_out/College_HS_wage_premium_exp_MORG.dta", clear
keep clphsg_all clghsg_all year
duplicates drop
save "$data_out/college_HS_gap_MORG.dta", replace

/*------------------------------------------------------------------------------
	Residual 90/10
------------------------------------------------------------------------------*/
use "$data_out/MayCPS_MORG_cleaned.dta", clear
keep if hourlyworker==1
keep if exp<=39 // 0 to 39 years of potential experience
keep if (inrange(class_new, 0, 2) & year>=1973 & year<=1978) | (inrange(class_new, 0, 4) & year>=1979 & year<=2020) // dropping self-employed
drop if hr_w2low==1 // drop hourly earners of below $1.675/hour in 1982 dollars
drop if hr_w2hi==1 // drop hourly wages exceeding 1/35th the topcoded value of weekly earnings
drop if alloc==1 // drop allocated
keep if female==0 // just male earnings
drop if missing(lnrhinc)

* keeping needed variables
drop educ edhsd edhsg edsmc edclg edgtc

* age indicators
xi i.age

* creating interactions
foreach ed of varlist ed0_4 ed5_8 ed9 ed10 ed11 ed12 ed13_15 ed16 ed17p {
	gen ageX`ed' = age*`ed'
	gen agesqX`ed' = (age^2)*`ed'
	gen age3X`ed' = (age^3)*`ed'
	gen age4X`ed' = (age^4)*`ed'
}

* keeping needed variables
keep lnrhinc wgt_hrs female year ed* age* _I*

* regression
gen reswagehr=.
gen rvln=.
gen r90=.
gen r50=.
gen r10=.

forval i=1973(1)2020 {
	local RHS = "ed0_4 ed5_8 ed9 ed10 ed11 ed12 ed13_15 ed16 ed17p _Iage* ageX* agesqX* age3X* age4X*"
	quietly reg lnrhinc `RHS' if year==`i' [aw=wgt_hrs]
	predict reswagehr`i' if year==`i', resid
	summ reswagehr`i'

	replace reswagehr = reswagehr`i' if year==`i'

	summ reswagehr if year==`i' [aw=wgt_hrs], detail
	replace rvln = _result(4) if year==`i'
	replace r90 = _result(12) if year==`i'
	replace r50 = _result(10) if year==`i' 
	replace r10=  _result(8) if year==`i'

	gen r9010`i' =r90-r10 if year==`i'
	gen r9050`i' =r90-r50 if year==`i'
	gen r5010`i' =r50-r10 if year==`i'
}

keep year r9010*
gduplicates drop
egen resid_9010=rowtotal(r9010*)
drop r9010*
save "$data_out/wage_90_10_resid_inequality_series_MORG.dta", replace

/*------------------------------------------------------------------------------
	Figure Panel B
------------------------------------------------------------------------------*/
* merging datasets together
use "$data_out/wage_90_10_inequality_series_MORG.dta", clear
merge 1:1 year using "$data_out/college_HS_gap_MORG.dta", nogen
merge 1:1 year using "$data_out/wage_90_10_resid_inequality_series_MORG.dta", nogen

* figure
twoway ///
	(connected ineq_9010 resid_9010 year, yaxis(2) lwidth(medium medium) ///
	msymbol(Oh Dh) msize(vsmall vsmall) mlwidth(medium medium)) /// 
	(connected clphsg_all year, yaxis(1) lwidth(medium) ///
	msymbol(Th) msize(vsmall) mlwidth(medium)) ///
	, ///
	ylabel(0.35(.05)0.7, labsize(small) axis(1) nogrid angle(0) format(%9.2fc)) ///
	ylabel(0.8(.1)1.8, labsize(small) axis(2) nogrid angle(0) format(%9.1fc)) ///
	xlabel(1973(4)2020, labsize(small)) ///
	xline(1979 1992, lstyle(background) lcolor(gs11) lpattern(dash)) ///
	legend(label(1 "Overall 90/10") label(2 "Residual 90/10") label(3 "College/HS Gap") size(small) pos(6) col(3)) ///
	graphregion(color(white)) ///
	title("B. MORG CPS Hourly Earnings, 1973-2020", size(medsmall) color(black)) ///
	xtitle("") ///
	ytitle("Log College/HS Wage Gap", size(small) axis(1)) ///
	ytitle("Log Earnings Ratio", size(small) axis(2)) ///
	plotregion(lcolor(black) lwidth(thin)) 	
graph export "$figures/Figure2/Figure2_replication_PanelB.eps", replace

* removing datasets no longer needed
save "$data_out/wage_90_10_inequality_series_MORG.dta", replace
save "$data_out/college_HS_gap_MORG.dta", replace
