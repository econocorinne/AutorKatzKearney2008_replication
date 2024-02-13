/*==============================================================================
	DESCRIPTION: replicating Figure 4
==============================================================================*/		

/*------------------------------------------------------------------------------
	Set paths here
------------------------------------------------------------------------------*/
do "/XX.do"

/*------------------------------------------------------------------------------
	Panel A
------------------------------------------------------------------------------*/

* wage differential 
use "$data_out/College_HS_wage_premium_exp.dta", clear
keep year clphsg_all
gduplicates drop
reg clphsg_all year
predict resid_wage, residuals
save "$data_out/Figure4_panelA_wagediff.dta", replace

* relative supply
use "$data_out/Efficiency_units_1963_2022.dta", clear
keep year eu_lnclg
gduplicates drop
reg eu_lnclg year
predict resid_supply, residuals
save "$data_out/Figure4_panelA_relsupply.dta", replace

* merging
use "$data_out/Figure4_panelA_wagediff.dta", clear
merge 1:1 year using "$data_out/Figure4_panelA_relsupply.dta", nogen keepusing(resid_supply) keep(matched)

* figure
twoway ///
	connected resid_wage resid_supply year ///
	, lwidth(medium medium) xlabel(1963(6)2022, labsize(small)) ///
	ylabel(-0.15(.05)0.15, nogrid labsize(small)) ///
	msymbol(Oh Dh) msize(vsmall vsmall) mlwidth(medium medium) ///
	lpattern(solid dash) yline(0, lcolor(black)) ///
	ytitle("Log points", size(small)) ///
	xtitle("", size(small)) ///
	title("A. Detrended college/high school wage differential and relative supply, 1963-2022", size(medsmall) color(black)) ///
	legend(label(1 "Detrended wage differential") label(2 "Detrended relative supply") ///
	region(col(white)) size(small)) ///
	graphregion(color(white)) ///
	plotregion(lcolor(black) lwidth(thin)) 
graph export "$figures/Figure4/Figure4_panelA_replication.eps", replace


/*------------------------------------------------------------------------------
	Panel B
------------------------------------------------------------------------------*/

* observed college/high school wage gap
use "$data_out/College_HS_wage_premium_exp.dta", clear
keep year clphsg_all
gduplicates drop
save "$data_out/Figure4_panelB_observed.dta", replace

* predicted wage gap
use "$data_out/College_HS_wage_premium_exp.dta", clear
merge 1:1 year expcat using "$data_out/Efficiency_units_1963_2022.dta", nogen keepusing(eu_lnclg)
gen t=year-1962
reg clphsg_all t eu_lnclg if year<1988
predict gap6387
label var gap6387 "Katz-Murphy Predicted Wage Gap: 1963-1987 Trend"
keep year gap6387
gduplicates drop
drop if gap6387==.
save "$data_out/Figure4_panelB_predicted.dta", replace

* predicted wage gap: 1963-2022 trend
use "$data_out/College_HS_wage_premium_exp.dta", clear
merge 1:1 year expcat using "$data_out/Efficiency_units_1963_2022.dta", nogen keepusing(eu_lnclg)
gen t=year-1962
reg clphsg_all t eu_lnclg if year<2005
predict gap6305
label var gap6305 "Katz-Murphy Predicted Wage Gap: 1963-2005 Trend"
keep year gap6305
gduplicates drop
drop if gap6305==.
save "$data_out/Figure4_panelB_predicted2.dta", replace

* merging
use "$data_out/Figure4_panelB_observed.dta", clear
merge 1:1 year using "$data_out/Figure4_panelB_predicted.dta", nogen keepusing(gap6387) 
merge 1:1 year using "$data_out/Figure4_panelB_predicted2.dta", nogen keepusing(gap6305)

* figure
twoway ///
	connected clphsg_all gap6387 gap6305 year ///
	, lwidth(medium medium medium) xlabel(1963(6)2022, labsize(small)) ///
	ylabel(0.35(.1)0.95, nogrid labsize(small)) ///
	msymbol(Oh Dh Oh) msize(vsmall vsmall vsmall) mlwidth(medium medium medium) ///
	lpattern(solid dash dot) yline(0, lcolor(black)) ///
	ytitle("Log wage gap", size(small)) ///
	xtitle("", size(small)) ///
	title("B. Katz-Murphy prediction model for the college/high school wage gap", size(medsmall) color(black)) ///
	legend(label(1 "Observed college/HS gap") label(2 "Katz-Murphy pred. gap: 1963-1987 trend") ///
	label(3 "Katz-Murphy pred. gap: 1963-2005 trend") ///
	region(col(white)) size(small)) ///
	graphregion(color(white)) ///
	plotregion(lcolor(black) lwidth(thin)) 
graph export "$figures/Figure4/Figure4_panelB_replication.eps", replace


* removing datasets no longer needed
rm "$data_out/Figure4_panelA_wagediff.dta"
rm "$data_out/Figure4_panelA_relsupply.dta"
rm "$data_out/Figure4_panelB_observed.dta"
rm "$data_out/Figure4_panelB_predicted.dta"
rm "$data_out/Figure4_panelB_predicted2.dta"
