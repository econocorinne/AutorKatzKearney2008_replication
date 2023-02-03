/*==============================================================================
						Replicating Figure 6
==============================================================================*/		
cap log close 
clear all 
set more off

** SET PATHS HERE
run "/Users/corinnes/Dropbox/0 Research/5_AKK_replication/Scripts/Clean_MarchCPS/0_Paths"

/*------------------------------------------------------------------------------
	Figures
------------------------------------------------------------------------------*/

* Panel A: Wage Gap
use "$data_out/College_HS_wage_premium_exp.dta", clear
keep year expcat clphsg_exp clghsg_exp
keep if expcat==1 | expcat==3
replace year=year-1
twoway ///
	(connected clphsg_exp year if expcat==1 ///
	, msymbol(Oh) msize(vsmall) mlwidth(thin)) ///
	(connected clphsg_exp year if expcat==3 ///
	, msymbol(Dh) msize(vsmall) mlwidth(thin)) ///
	, xlabel(1963(6)2019, labsize(small)) xtitle("") ///
	ylabel(0.3(.1)0.8, nogrid labsize(small)) ytitle("Log wage gap", size(small)) ///
	title("A. College/high school wage gap by potential experience group", size(medsmall) color(black)) ///
	legend(label(1 "Experience 0-9") label(2 "Experience 20-29") region(fcolor(white)) pos(6) size(small) nobox) ///
	graphregion(color(white)) ///
	plotregion(lcolor(black) lwidth(thin)) ///
	saving("$figures/Figure6/Figure6_panelA_replication.gph",replace)
graph export "$figures/Figure6/Figure6_panelA_replication.pdf", replace

* Panel B: Labor Supply
/* The college/high school log relative supply index is the natural logarithm 
of the ratio of collegeequivalent to noncollege-equivalent labor supply 
in efficiency units in each year. See the data appendix for details. */
use "$data_out/Efficiency_units_1963_2020.dta", clear
keep if expcat==1 | expcat==3
drop if year==1962
keep year expcat euexp_lnclg
twoway ///
	(connected euexp_lnclg year if expcat==1 ///
	, msymbol(Oh) msize(vsmall) mlwidth(thin)) ///
	(connected euexp_lnclg year if expcat==3 ///
	, msymbol(Dh) msize(vsmall) mlwidth(thin)) ///
	, xlabel(1963(6)2019, labsize(small)) xtitle("") ///
	ylabel(-1(.5)1, nogrid labsize(small)) ytitle("Log relative supply index", size(small)) ///
	title("B. College/high school relative supply by potential experience group", size(medsmall) color(black)) ///
	legend(label(1 "Experience 0-9") label(2 "Experience 20-29") region(fcolor(white)) pos(6) size(small) nobox) ///
	graphregion(color(white)) ///
	plotregion(lcolor(black) lwidth(thin)) ///
	saving("$figures/Figure6/Figure6_panelB_replication.gph",replace)
graph export "$figures/Figure6/Figure6_panelB_replication.pdf", replace


