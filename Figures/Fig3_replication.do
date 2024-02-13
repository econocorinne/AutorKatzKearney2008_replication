/*==============================================================================
	DESCRIPTION: replicating Figure 3
==============================================================================*/		

/*------------------------------------------------------------------------------
	Set paths here
------------------------------------------------------------------------------*/
do "/XX.do"

/*------------------------------------------------------------------------------
	Series prep
------------------------------------------------------------------------------*/

* March CPS
clear
forval gender=0/1 {
	use "$data_out/ASEC_all_cleaned_NOTOP.dta", clear
	keep if fulltime==1 // full-time workers, i.e. worked 35+ hours per week
	keep if fullyear==1 // full-year workers, i.e. worked 40+ weeks in prior year
	keep if agely>=16 & agely<=64 // age 16 to 64
	keep if exp<=39 // 0 to 39 years of potential experience
	keep if wageworker==1 // longest job was private or gov't wage/salary, no self-employment
	drop if bcwkwgkm==1 // drop earnings of below $67/week in 1982 dollars
	drop if allocated==1 // drop allocated observations
	keep if female==`gender' 
	gen r90=.
	gen r50=.
	gen r10=.
	forval i=1963(1)2022 {
		summ lnrhinc if year==`i' [aw=wgt_hrs], detail
		replace r90 = r(p90) if year==`i'
		replace r50 = r(p50) if year==`i'
		replace r10=  r(p10) if year==`i'
		gen r9050`i' =r90-r50 if year==`i'
		gen r5010`i' =r50-r10 if year==`i'
	}	
	keep year r9050* r5010*
	gduplicates drop
	egen ineq_cps_9050`gender'=rowtotal(r9050*)
	egen ineq_cps_5010`gender'=rowtotal(r5010*)
	drop r9050* r5010*
	if `gender'==0 {
		save "$data_out/inequality_cps_male.dta", replace
		}
		else if `gender'==1 {
		save "$data_out/inequality_cps_female.dta", replace
		}
}


* May ORG
clear
forval gender=0/1 {
	use "$data_out/MayCPS_MORG_cleaned.dta", clear
	keep if exp<=39 // 0 to 39 years of potential experience
// 	keep if hourlyworker==1 // keeping hourly workers
	drop if hr_w2low==1 // drop hourly earners of below $1.675/hour in 1982 dollars
	drop if hr_w2hi==1 // drop hourly wages exceeding 1/35th the topcoded value of weekly earnings
	drop if alloc==1 // drop allocated
	keep if (inrange(class_new, 0, 2) & year>=1973 & year<=1978) | (inrange(class_new, 0, 4) & year>=1979 & year<=2020) // dropping self-employed
	drop if missing(lnrhinc)
	keep if female==`gender' 
	gen r90=.
	gen r50=.
	gen r10=.
	forval i=1973(1)2020 {
		summ lnrhinc if year==`i' [aw=wgt_hrs], detail
		replace r90 = r(p90) if year==`i'
		replace r50 = r(p50) if year==`i'
		replace r10=  r(p10) if year==`i'
		gen r9050`i' =r90-r50 if year==`i'
		gen r5010`i' =r50-r10 if year==`i'
	}	
	keep year r9050* r5010*
	gduplicates drop
	egen ineq_morg_9050`gender'=rowtotal(r9050*)
	egen ineq_morg_5010`gender'=rowtotal(r5010*)
	drop r9050* r5010*
	if `gender'==0 {
		save "$data_out/inequality_morg_male.dta", replace
		}
		else if `gender'==1 {
		save "$data_out/inequality_morg_female.dta", replace
		}
}

/*------------------------------------------------------------------------------
	Figures
------------------------------------------------------------------------------*/

* merging datasets
use "$data_out/inequality_cps_male.dta", clear
merge 1:1 year using "$data_out/inequality_cps_female.dta", nogen
merge 1:1 year using "$data_out/inequality_morg_male.dta", nogen
merge 1:1 year using "$data_out/inequality_morg_female.dta", nogen
save "$data_out/inequality_percentiles.dta", replace

* Panel A: Overall Male 90/50 wage inequality
use "$data_out/inequality_percentiles.dta", clear
twoway ///
	connected ineq_cps_90500 ineq_morg_90500 year ///
	, lwidth(medium medium) xlabel(1963(6)2022, labsize(small)) ///
	ylabel(0.45(.05)1.0, nogrid labsize(small)) ///
	msymbol(Oh Dh) msize(vsmall vsmall) mlwidth(medium medium) ///
	lpattern(solid dash) ///
	ytitle("Log 90/50 wage ratio", size(small)) ///
	xtitle("", size(small)) ///
	title("Overall Male 90/50 Wage Inequality", size(medsmall) color(black)) ///
	legend(label(1 "CPS March Weekly") label(2 "CPS May/ORG Hourly") region(col(white)) size(small)) ///
	graphregion(color(white)) ///
	plotregion(lcolor(black) lwidth(thin)) 
graph export "$figures/Figure3/Figure3_panelA_replication.eps", replace

* Panel B: Overall Female 90/50 wage inequality
use "$data_out/inequality_percentiles.dta", clear
twoway ///
	connected ineq_cps_90501 ineq_morg_90501 year ///
	, lwidth(medium medium) xlabel(1963(6)2022, labsize(small)) ///
	ylabel(0.45(.05)1.0, nogrid labsize(small)) ///
	msymbol(Oh Dh) msize(vsmall vsmall) mlwidth(medium medium) ///
	lpattern(solid dash) ///
	ytitle("Log 90/50 wage ratio", size(small)) ///
	xtitle("", size(small)) ///
	title("Overall Female 90/50 Wage Inequality", size(medsmall) color(black)) ///
	legend(label(1 "CPS March Weekly") label(2 "CPS May/ORG Hourly") region(col(white)) size(small)) ///
	graphregion(color(white)) ///
	plotregion(lcolor(black) lwidth(thin)) 
graph export "$figures/Figure3/Figure3_panelB_replication.eps", replace

* Panel C: Overall Male 50/10 wage inequality
use "$data_out/inequality_percentiles.dta", clear
twoway ///
	connected ineq_cps_50100 ineq_morg_50100 year ///
	, lwidth(medium medium) xlabel(1963(6)2022, labsize(small)) ///
	ylabel(0.4(.05).9, nogrid labsize(small)) ///
	msymbol(Oh Dh) msize(vsmall vsmall) mlwidth(medium medium) ///
	lpattern(solid dash) ///
	ytitle("Log 50/10 wage ratio", size(small)) ///
	xtitle("", size(small)) ///
	title("Overall Male 50/10 Wage Inequality", size(medsmall) color(black)) ///
	legend(label(1 "CPS March Weekly") label(2 "CPS May/ORG Hourly") region(col(white)) size(small)) ///
	graphregion(color(white)) ///
	plotregion(lcolor(black) lwidth(thin)) 
graph export "$figures/Figure3/Figure3_panelC_replication.eps", replace

* Panel D: Overall Female 50/10 wage inequality
use "$data_out/inequality_percentiles.dta", clear
twoway ///
	connected ineq_cps_50101 ineq_morg_50101 year ///
	, lwidth(medium mnedium) xlabel(1963(6)2022, labsize(small)) ///
	ylabel(0.4(.05).9, nogrid labsize(small)) ///
	msymbol(Oh Dh) msize(vsmall vsmall) mlwidth(medium medium) ///
	lpattern(solid dash) ///
	ytitle("Log 50/10 wage ratio", size(small)) ///
	xtitle("", size(small)) ///
	title("Overall Female 50/10 Wage Inequality", size(medsmall) color(black)) ///
	legend(label(1 "CPS March Weekly") label(2 "CPS May/ORG Hourly") region(col(white)) size(small)) ///
	graphregion(color(white)) ///
	plotregion(lcolor(black) lwidth(thin)) 
graph export "$figures/Figure3/Figure3_panelD_replication.eps", replace


* removing datasets no longer needed
rm "$data_out/inequality_cps_male.dta"
rm "$data_out/inequality_cps_female.dta"
rm "$data_out/inequality_morg_male.dta"
rm "$data_out/inequality_morg_female.dta"
rm "$data_out/inequality_percentiles.dta"
