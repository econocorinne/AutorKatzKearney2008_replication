/*==============================================================================
						Replicating Figure 9
==============================================================================*/		
cap log close 
clear all 
set more off

** SET PATHS HERE
run "/Users/corinnes/Dropbox/0 Research/5_AKK_replication/Scripts/Clean_MarchCPS/0_Paths"

/*------------------------------------------------------------------------------
	Panel A
------------------------------------------------------------------------------*/

use "$data_out/Simulated/sim-DFL-X-allyrs.dta", clear
keep if sex==0 // males

* figure
twoway ///
	(connected t9050simx x_year if a_year==1973, lwidth(thin) msymbol(Oh) msize(tiny) mlwidth(thin)) ///
	(connected t9050simx x_year if a_year==1989, lwidth(thin) msymbol(Oh) msize(tiny) mlwidth(thin)) ///
	(connected t9050simx x_year if a_year==2005, lwidth(thin) msymbol(Oh) msize(tiny) mlwidth(thin)) ///
	(connected t9050simx x_year if a_year==2018, lwidth(thin) msymbol(Oh) msize(tiny) mlwidth(thin)) ///
	(connected t9050x x_year if a_year==2018, lwidth(thin) msymbol(O) msize(small) mlwidth(thin)) ///
	, ///
	ylabel(0.5(.05).95, labsize(small) nogrid) ///
	xlabel(1973(4)2019, labsize(small)) ///
	legend(label(1 "1973 f(w | skills)") label(2 "1989 f(w | skills)") label(3 "2005 f(w | skills)") ///
	label(4 "2018 f(w | skills)") label(5 "Observed 90/50") ///
	region(fcolor(white)) pos(6) size(small) region(lstyle(none))) ///
	graphregion(color(white)) plotregion(lcolor(black) lwidth(thin)) ///	
	title("Male 90/50", size(medsmall) color(black)) ///
	xtitle("") ///
	ytitle("Log 90/50 ratio", size(small)) ///	
	saving("$figures/Figure9/Figure9_replication_PanelA.gph",replace)
graph export "$figures/Figure9/Figure9_replication_PanelA.pdf", replace

/*------------------------------------------------------------------------------
	Panel B
------------------------------------------------------------------------------*/

use "$data_out/Simulated/sim-DFL-X-allyrs.dta", clear
keep if sex==1 // females

* figure
twoway ///
	(connected t9050simx x_year if a_year==1973, lwidth(thin) msymbol(Oh) msize(tiny) mlwidth(thin)) ///
	(connected t9050simx x_year if a_year==1989, lwidth(thin) msymbol(Oh) msize(tiny) mlwidth(thin)) ///
	(connected t9050simx x_year if a_year==2005, lwidth(thin) msymbol(Oh) msize(tiny) mlwidth(thin)) ///
	(connected t9050simx x_year if a_year==2018, lwidth(thin) msymbol(Oh) msize(tiny) mlwidth(thin)) ///
	(connected t9050x x_year if a_year==2018, lwidth(thin) msymbol(O) msize(small) mlwidth(thin)) ///
	, ///
	ylabel(0.5(.05).95, labsize(small) nogrid) ///
	xlabel(1973(4)2019, labsize(small)) ///
	legend(label(1 "1973 f(w | skills)") label(2 "1989 f(w | skills)") label(3 "2005 f(w | skills)") ///
	label(4 "2018 f(w | skills)") label(5 "Observed 90/50") ///
	region(fcolor(white)) pos(6) size(small) region(lstyle(none))) ///
	graphregion(color(white)) plotregion(lcolor(black) lwidth(thin)) ///	
	title("Female 90/50", size(medsmall) color(black)) ///
	xtitle("") ///
	ytitle("Log 90/50 ratio", size(small)) ///	
	saving("$figures/Figure9/Figure9_replication_PanelB.gph",replace)
graph export "$figures/Figure9/Figure9_replication_PanelB.pdf", replace	


/*------------------------------------------------------------------------------
	Panel C
------------------------------------------------------------------------------*/

use "$data_out/Simulated/sim-DFL-X-allyrs.dta", clear
keep if sex==0 // males

* figure
twoway ///
	(connected t5010simx x_year if a_year==1973, lwidth(thin) msymbol(Oh) msize(tiny) mlwidth(thin)) ///
	(connected t5010simx x_year if a_year==1989, lwidth(thin) msymbol(Oh) msize(tiny) mlwidth(thin)) ///
	(connected t5010simx x_year if a_year==2005, lwidth(thin) msymbol(Oh) msize(tiny) mlwidth(thin)) ///
	(connected t5010simx x_year if a_year==2018, lwidth(thin) msymbol(Oh) msize(tiny) mlwidth(thin)) ///
	(connected t5010x x_year if a_year==2018, lwidth(thin) msymbol(O) msize(small) mlwidth(thin)) ///
	, ///
	ylabel(0.35(.1)0.95, labsize(small) nogrid) ///
	xlabel(1973(4)2019, labsize(small)) ///
	legend(label(1 "1973 f(w | skills)") label(2 "1989 f(w | skills)") label(3 "2005 f(w | skills)") ///
	label(4 "2018 f(w | skills)") label(5 "Observed 50/10") ///
	region(fcolor(white)) pos(6) size(small) region(lstyle(none))) ///
	graphregion(color(white)) plotregion(lcolor(black) lwidth(thin)) ///	
	title("Male 50/10", size(medsmall) color(black)) ///
	xtitle("") ///
	ytitle("Log 50/10 ratio", size(small)) ///	
	saving("$figures/Figure9/Figure9_replication_PanelC.gph",replace)
graph export "$figures/Figure9/Figure9_replication_PanelC.pdf", replace


/*------------------------------------------------------------------------------
	Panel D
------------------------------------------------------------------------------*/

use "$data_out/Simulated/sim-DFL-X-allyrs.dta", clear
keep if sex==1 // females

* figure
twoway ///
	(connected t5010simx x_year if a_year==1973, lwidth(thin) msymbol(Oh) msize(tiny) mlwidth(thin)) ///
	(connected t5010simx x_year if a_year==1989, lwidth(thin) msymbol(Oh) msize(tiny) mlwidth(thin)) ///
	(connected t5010simx x_year if a_year==2005, lwidth(thin) msymbol(Oh) msize(tiny) mlwidth(thin)) ///
	(connected t5010simx x_year if a_year==2018, lwidth(thin) msymbol(Oh) msize(tiny) mlwidth(thin)) ///
	(connected t5010x x_year if a_year==2018, lwidth(thin) msymbol(O) msize(small) mlwidth(thin)) ///
	, ///
	ylabel(0.35(.1)0.95, labsize(small) nogrid) ///
	xlabel(1973(4)2019, labsize(small)) ///
	legend(label(1 "1973 f(w | skills)") label(2 "1989 f(w | skills)") label(3 "2005 f(w | skills)") ///
	label(4 "2018 f(w | skills)") label(5 "Observed 50/10") ///
	region(fcolor(white)) pos(6) size(small) region(lstyle(none))) ///
	graphregion(color(white)) plotregion(lcolor(black) lwidth(thin)) ///	
	title("Female 50/10", size(medsmall) color(black)) ///
	xtitle("") ///
	ytitle("Log 50/10 ratio", size(small)) ///	
	saving("$figures/Figure9/Figure9_replication_PanelD.gph",replace)
graph export "$figures/Figure9/Figure9_replication_PanelD.pdf", replace

	
