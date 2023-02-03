/*==============================================================================
						Replicating Figure 7
==============================================================================*/		
cap log close 
clear all 
set more off

** SET PATHS HERE
run "/Users/corinnes/Dropbox/0 Research/5_AKK_replication/Scripts/Clean_MarchCPS/0_Paths"

/*------------------------------------------------------------------------------
	Preparing data
------------------------------------------------------------------------------*/

* May ORG
clear
use "$data_out/MayCPS_MORG_cleaned.dta", clear
keep if exp<=39 // 0 to 39 years of potential experience
// keep if paidhre==1 // keeping hourly workers
drop if hr_w2low==1 // drop hourly earners of below $1.675/hour in 1982 dollars
drop if hr_w2hi==1 // drop hourly wages exceeding 1/35th the topcoded value of weekly earnings
drop if alloc==1 // drop allocated
drop if class_new==6 // no self-employed
drop if missing(lnrhinc)
gen r90=.
gen r50=.
gen r10=.
forval i=1973(1)2020 {
	summ lnrhinc if year==`i' [aw=wgt_hrs], detail
	replace r90=r(p90) if year==`i'
	replace r50=r(p50) if year==`i'
	replace r10=r(p10) if year==`i'
	gen r9010`i'=r90-r10 if year==`i'
	gen r9050`i'=r90-r50 if year==`i'
	gen r5010`i'=r50-r10 if year==`i'
}	
keep year r9010* r9050* r5010*
gduplicates drop
egen ineq_morg_9010=rowtotal(r9010*)
egen ineq_morg_9050=rowtotal(r9050*)
egen ineq_morg_5010=rowtotal(r5010*)
drop r9010* r9050* r5010*
save "$data_out/inequality_morg.dta", replace

* merging in real minimum wage
use "$data_out/inequality_morg.dta", clear
drop if year<1973 | year>2019
merge 1:1 year using "$data_out/minimumwage.dta", nogen keepusing(minimumwage) keep(matched)
merge 1:1 year using "$data_out/deflator_pce.dta", nogen keepusing(deflator_2000) keep(matched)

* creating log real minimum wage
gen real_minwage=minimumwage*deflator_2000
gen log_rminwage=ln(real_minwage)

* normalizing
gen minus=log_rminwage if year==1973
carryforward minus, replace
gen normalize=(log_rminwage-minus)
line normalize year
save "$data_out/Figure7_data.dta", replace


/*------------------------------------------------------------------------------
	Panel A
------------------------------------------------------------------------------*/

use "$data_out/Figure7_data.dta", clear

* figure
twoway ///
	connected normalize year ///
	, yline(0, lcolor(black)) lwidth(medium) xlabel(1973(4)2019, labsize(small)) ///
	ylabel(-0.2(.05)0.2, nogrid labsize(small)) ///
	msymbol(Oh) msize(vsmall) mlwidth(medium) ///
	ytitle("Log points", size(small)) ///
	xtitle("") ///
	title("A. Log changes in the real federal minimum wage 1973-2019 (1973=0)", size(medsmall) color(black)) ///
	legend(off) /// 
	graphregion(color(white)) ///
	plotregion(lcolor(black)) ///
	saving("$figures/Figure7/Figure7_panelA.gph",replace)
graph export "$figures/Figure7/Figure7_panelA.pdf", replace


/*------------------------------------------------------------------------------
	Panel B
------------------------------------------------------------------------------*/

use "$data_out/Figure7_data.dta", clear

* 1) 90/10 ratio
reg ineq_morg_9010 log_rminwage
predict predict_wage9010
label var predict_wage9010 "Predicted 90/10 gap"

* figure
twoway ///
	connected ineq_morg_9010 predict_wage9010 year ///
	, lwidth(medium medium) xlabel(1973(4)2019, labsize(small)) ///
	ylabel(1.1(.05)1.6, nogrid labsize(small)) ///
	msymbol(Oh Dh) msize(vsmall vsmall) mlwidth(medium medium) ///
	xtitle("") ///
	title("B. Log 90/10 hourly earnings inequality and real minimum wage", size(medsmall) color(black)) ///
	legend(label(1 "90-10 Wage Gap") label(2 "E(90-10 Gap | Min Wage)") ///
	region(fcolor(white)) pos(6) size(small) region(lstyle(white))) ///
	graphregion(color(white)) ///
	plotregion(lcolor(black)) ///
	saving("$figures/Figure7/Figure7_panelB.gph",replace)
graph export "$figures/Figure7/Figure7_panelB.pdf", replace

/*------------------------------------------------------------------------------
	Panel C
------------------------------------------------------------------------------*/

use "$data_out/Figure7_data.dta", clear

* 1) 50/10 ratio
reg ineq_morg_5010 log_rminwage
predict predict_wage5010
label var predict_wage5010 "Predicted 50/10 gap"

* figure
twoway ///
	connected ineq_morg_5010 predict_wage5010 year ///
	, lwidth(medium medium) xlabel(1973(4)2019, labsize(small)) ///
	ylabel(0.55(.05)0.75, nogrid labsize(small)) ///
	msymbol(Oh Dh) msize(vsmall vsmall) mlwidth(medium medium) ///
	xtitle("") ///
	title("C. Log 50/10 hourly earnings inequality and real minimum wage", size(medsmall) color(black)) ///
	legend(label(1 "50-10 Wage Gap") label(2 "E(50-10 Gap | Min Wage)") ///
	region(fcolor(white)) pos(6) size(small) region(lstyle(white))) ///
	graphregion(color(white)) ///
	plotregion(lcolor(black)) ///
	saving("$figures/Figure7/Figure7_panelC.gph",replace)
graph export "$figures/Figure7/Figure7_panelC.pdf", replace

/*------------------------------------------------------------------------------
	Panel D
------------------------------------------------------------------------------*/

use "$data_out/Figure7_data.dta", clear

* 1) 90/50 ratio
reg ineq_morg_9050 log_rminwage
predict predict_wage9050
label var predict_wage9050 "Predicted 90/50 gap"

* figure
twoway ///
	connected ineq_morg_9050 predict_wage9050 year ///
	, lwidth(medium medium) xlabel(1973(4)2019, labsize(small)) ///
	ylabel(0.55(.05)0.95, nogrid labsize(small)) ///
	msymbol(Oh Dh) msize(vsmall vsmall) mlwidth(medium medium) ///
	xtitle("") ///
	title("D. Log 90/50 hourly earnings inequality and real minimum wage", size(medsmall) color(black)) ///
	legend(label(1 "90-50 Wage Gap") label(2 "E(90-50 Gap | Min Wage)") ///
	region(fcolor(white)) pos(6) size(small) region(lstyle(white))) ///
	graphregion(color(white)) ///
	plotregion(lcolor(black)) ///
	saving("$figures/Figure7/Figure7_panelD.gph",replace)
graph export "$figures/Figure7/Figure7_panelD.pdf", replace
