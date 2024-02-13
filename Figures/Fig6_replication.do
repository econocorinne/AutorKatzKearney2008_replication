/*==============================================================================
	DESCRIPTION: replicating Figure 6
==============================================================================*/		

/*------------------------------------------------------------------------------
	Set paths here
------------------------------------------------------------------------------*/
do "/XX.do"

/*------------------------------------------------------------------------------
	Figure 6
------------------------------------------------------------------------------*/

* Panel A: Wage Gap
use "$data_out/College_HS_wage_premium_exp.dta", clear
keep year expcat clphsg_exp clghsg_exp
keep if expcat==1 | expcat==3

twoway ///
	(connected clphsg_exp year if expcat==1 ///
	, msymbol(Oh) msize(vsmall) mlwidth(thin)) ///
	(connected clphsg_exp year if expcat==3 ///
	, msymbol(Dh) msize(vsmall) mlwidth(thin)) ///
	, xlabel(1963(6)2022, labsize(small)) xtitle("") ///
	ylabel(0.3(.1)0.8, nogrid labsize(small)) ytitle("Log wage gap", size(small)) ///
	title("A. College/high school wage gap by potential experience group", size(medsmall) color(black)) ///
	legend(label(1 "Experience 0-9") label(2 "Experience 20-29") region(fcolor(white)) pos(6) size(small) nobox) ///
	graphregion(color(white)) ///
	plotregion(lcolor(black) lwidth(thin)) 
graph export "$figures/Figure6/Figure6_panelA_replication.eps", replace

* Panel B: Labor Supply
use "$data_out/Efficiency_units_1963_2022.dta", clear
keep year expcat euexp_lnclg
twoway ///
	(connected euexp_lnclg year if expcat==1 ///
	, msymbol(Oh) msize(vsmall) mlwidth(thin)) ///
	(connected euexp_lnclg year if expcat==3 ///
	, msymbol(Dh) msize(vsmall) mlwidth(thin)) ///
	, xlabel(1963(6)2022, labsize(small)) xtitle("") ///
	ylabel(-1(.5)1, nogrid labsize(small)) ytitle("Log relative supply index", size(small)) ///
	title("B. College/high school relative supply by potential experience group", size(medsmall) color(black)) ///
	legend(label(1 "Experience 0-9") label(2 "Experience 20-29") region(fcolor(white)) pos(6) size(small) nobox) ///
	graphregion(color(white)) ///
	plotregion(lcolor(black) lwidth(thin)) 
graph export "$figures/Figure6/Figure6_panelB_replication.eps", replace


