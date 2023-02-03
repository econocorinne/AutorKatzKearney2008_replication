/*==============================================================================
						Replicating Figure 5
==============================================================================*/		
cap log close 
clear all 
set more off

** SET PATHS HERE
run "/Users/corinnes/Dropbox/0 Research/5_AKK_replication/Scripts/Clean_MarchCPS/0_Paths"

/*------------------------------------------------------------------------------
	Series prep
------------------------------------------------------------------------------*/

forval gender=0/1 {
	use "$data_out/Predicted_wages_1964_2020.dta", clear
	replace year=year-1
	keep if female==`gender'

	egen rplnwkwav=sum(rplnwkw*avlswt), by(year)
	egen totwt=sum(avlswt),by(year)
	replace rplnwkwav=rplnwkwav/totwt

	collapse (mean) rplnwkw rplnwkwav[aw=avlswt], by (school year)

	sort year school
	list year school rplnwkw rplnwkwav

	* calculate starting values for graph (1963 mean is zero, all other levels are deviations)
	assert rplnwkwav>0
	egen mn79=max(rplnwkw*(year==1963)), by(school)

	gen normw=rplnwkw-mn79
	gen normwav = rplnwkwav-mn79

	keep year school normw rplnwkw
	list year school normw rplnwkw
	reshape wide normw rplnwkw, i(year) j(school)

	* calculate education differences
	gen grad_hsg = rplnwkw5-rplnwkw2
	gen clg_hsg  = rplnwkw4-rplnwkw2
	gen smc_hsg  = rplnwkw3-rplnwkw2
	gen hsg_hsd  = rplnwkw2-rplnwkw1

	* labeling
	label data "March comp-adjusted FTFY real weekly wages, 1963-2019"
	label var rplnwkw1 "Real wage HSD"
	label var rplnwkw2 "Real wage HSG"
	label var rplnwkw3 "Real wage SMC"
	label var rplnwkw4 "Real wage CLG"
	label var rplnwkw5 "Real wage GTC"

	label var normw1 "HS Dropout"
	label var normw2 "HS Grad"
	label var normw3 "Some College"
	label var normw4 "College Grad"
	label var normw5 "Post-College"
	label var year "Year"

	label var grad_hsg "GTC-HSG wage gap"
	label var clg_hsg  "CLG-HSG wage gap"
	label var smc_hsg  "SMC-HSG wage gap"
	label var hsg_hsd  "HSG-HSD wage gap"

	* saving
	if `gender'==0 {
	save "$data_out/Figure5_male.dta", replace
	}
	else if `gender'==1 {
	save "$data_out/Figure5_female.dta", replace
	}
}

/*------------------------------------------------------------------------------
	Figures
------------------------------------------------------------------------------*/

scatter normw1 normw2 normw3 normw4 normw5 year, /// 
  connect( l l l l l) ///
  msymbol(i Oh Dh Th x) msize(small small small small medsmall) 
  /* title("Trends in Real Log Full-Time Weekly `gen' Wages, 1963-2005 (March CPS)", size(medium)) */
  title("`gen'", size(medium))
  l2title("Changes in Log Real Wage Levels (1963 = 0)") 
  legend(region(lstyle(none))) 
  xlabel(1963(6)2005) 
  ylabel(-0.10(.1)0.60)
 
 
* Panel A: Males
use "$data_out/Figure5_male.dta", clear
twoway ///
	scatter normw1 normw2 normw3 normw4 normw5 year ///
	, connect( l l l l l) ///
	msymbol(i Oh Dh Th x) msize(vsmall vsmall vsmall vsmall medsmall)  ///
	title("A. Males", size(medsmall) color(black)) ///
	xlabel(1963(6)2019, labsize(small)) /// 
	ylabel(-0.1(.1)0.7, nogrid labsize(small)) ///
	ytitle("Changes in log real wage levels (1963=0)", size(small)) ///
	xtitle("", size(small)) ///
	legend(label(1 "High school dropout") label(2 "High school grad") label(3 "Some college") ///
	label(4 "College grad") label(5 "Post-college") symysize(0) pos(6) region(col(white)) size(small)) ///
	graphregion(color(white)) ///
	plotregion(lcolor(black) lwidth(thin)) ///
	saving("$figures/Figure5/Figure5_panelA_replication.gph",replace)
graph export "$figures/Figure5/Figure5_panelA_replication.pdf", replace

* Panel B: Females
use "$data_out/Figure5_female.dta", clear
twoway ///
	scatter normw1 normw2 normw3 normw4 normw5 year ///
	, connect( l l l l l) ///
	msymbol(i Oh Dh Th x) msize(vsmall vsmall vsmall vsmall medsmall)  ///
	title("B. Females", size(medsmall) color(black)) ///
	xlabel(1963(6)2019, labsize(small)) /// 
	ylabel(-0.1(.1)0.7, nogrid labsize(small)) ///
	ytitle("Changes in log real wage levels (1963=0)", size(small)) ///
	xtitle("", size(small)) ///
	legend(label(1 "High school dropout") label(2 "High school grad") label(3 "Some college") ///
	label(4 "College grad") label(5 "Post-college") symysize(0) pos(6) region(col(white)) size(small)) ///
	graphregion(color(white)) ///
	plotregion(lcolor(black) lwidth(thin)) ///
	saving("$figures/Figure5/Figure5_panelB_replication.gph",replace)
graph export "$figures/Figure5/Figure5_panelB_replication.pdf", replace
