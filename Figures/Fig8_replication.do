/*==============================================================================
	DESCRIPTION: replicating Figure 8
==============================================================================*/		

/*------------------------------------------------------------------------------
	Set paths here
------------------------------------------------------------------------------*/
do "/XX.do"

/*------------------------------------------------------------------------------
	Panel A
------------------------------------------------------------------------------*/

use "$data_out/Simulated/sim-DFL-X-allyrs.dta", clear
keep if sex==0 // males

* figure
twoway ///
	(connected r9050simx x_year if a_year==1973, lwidth(thin) msymbol(Oh) msize(tiny) mlwidth(thin)) ///
	(connected r9050simx x_year if a_year==1989, lwidth(thin) msymbol(Oh) msize(tiny) mlwidth(thin)) ///
	(connected r9050simx x_year if a_year==2005, lwidth(thin) msymbol(Oh) msize(tiny) mlwidth(thin)) ///
	(connected r9050simx x_year if a_year==2018, lwidth(thin) msymbol(Oh) msize(tiny) mlwidth(thin)) ///
	(connected r9050x x_year if a_year==2018, lwidth(thin) msymbol(O) msize(small) mlwidth(thin)) ///
	, ///
	ylabel(0.4(.05)0.65, labsize(small) nogrid) ///
	xlabel(1973(4)2020, labsize(small)) ///
	legend(label(1 "1973 f(e | skills)") label(2 "1989 f(e | skills)") label(3 "2005 f(e | skills)") ///
	label(4 "2018 f(e | skills)") label(5 "Actual residual") ///
	region(fcolor(white)) pos(6) size(small) region(lstyle(none))) ///
	graphregion(color(white)) plotregion(lcolor(black) lwidth(thin)) ///	
	title("Male 90/50", size(medsmall) color(black)) ///
	xtitle("") ///
	ytitle("Log 90/50 ratio", size(small)) 
graph export "$figures/Figure8/Figure8_replication_PanelA.eps", replace

/*------------------------------------------------------------------------------
	Panel B
------------------------------------------------------------------------------*/

use "$data_out/Simulated/sim-DFL-X-allyrs.dta", clear
keep if sex==1 // females

* figure
twoway ///
	(connected r9050simx x_year if a_year==1973, lwidth(thin) msymbol(Oh) msize(tiny) mlwidth(thin)) ///
	(connected r9050simx x_year if a_year==1989, lwidth(thin) msymbol(Oh) msize(tiny) mlwidth(thin)) ///
	(connected r9050simx x_year if a_year==2005, lwidth(thin) msymbol(Oh) msize(tiny) mlwidth(thin)) ///
	(connected r9050simx x_year if a_year==2018, lwidth(thin) msymbol(Oh) msize(tiny) mlwidth(thin)) ///
	(connected r9050x x_year if a_year==2018, lwidth(thin) msymbol(O) msize(small) mlwidth(thin)) ///
	, ///
	ylabel(0.4(.05)0.65, labsize(small) nogrid) ///
	xlabel(1973(4)2020, labsize(small)) ///
	legend(label(1 "1973 f(e | skills)") label(2 "1989 f(e | skills)") label(3 "2005 f(e | skills)") ///
	label(4 "2018 f(e | skills)") label(5 "Actual residual") ///
	region(fcolor(white)) pos(6) size(small) region(lstyle(none))) ///
	graphregion(color(white)) plotregion(lcolor(black) lwidth(thin)) ///	
	title("Female 90/50", size(medsmall) color(black)) ///
	xtitle("") ///
	ytitle("Log 90/50 ratio", size(small)) 
graph export "$figures/Figure8/Figure8_replication_PanelB.eps", replace	


/*------------------------------------------------------------------------------
	Panel C
------------------------------------------------------------------------------*/

use "$data_out/Simulated/sim-DFL-X-allyrs.dta", clear
keep if sex==0 // males

* figure
twoway ///
	(connected r5010simx x_year if a_year==1973, lwidth(thin) msymbol(Oh) msize(tiny) mlwidth(thin)) ///
	(connected r5010simx x_year if a_year==1989, lwidth(thin) msymbol(Oh) msize(tiny) mlwidth(thin)) ///
	(connected r5010simx x_year if a_year==2005, lwidth(thin) msymbol(Oh) msize(tiny) mlwidth(thin)) ///
	(connected r5010simx x_year if a_year==2018, lwidth(thin) msymbol(Oh) msize(tiny) mlwidth(thin)) ///
	(connected r5010x x_year if a_year==2018, lwidth(thin) msymbol(O) msize(small) mlwidth(thin)) ///
	, ///
	ylabel(0.4(.05)0.65, labsize(small) nogrid) ///
	xlabel(1973(4)2020, labsize(small)) ///
	legend(label(1 "1973 f(e | skills)") label(2 "1989 f(e | skills)") label(3 "2005 f(e | skills)") ///
	label(4 "2018 f(e | skills)") label(5 "Actual residual") ///
	region(fcolor(white)) pos(6) size(small) region(lstyle(none))) ///
	graphregion(color(white)) plotregion(lcolor(black) lwidth(thin)) ///	
	title("Male 50/10", size(medsmall) color(black)) ///
	xtitle("") ///
	ytitle("Log 50/10 ratio", size(small)) 
graph export "$figures/Figure8/Figure8_replication_PanelC.eps", replace


/*------------------------------------------------------------------------------
	Panel D
------------------------------------------------------------------------------*/

use "$data_out/Simulated/sim-DFL-X-allyrs.dta", clear
keep if sex==1 // females

* figure
twoway ///
	(connected r5010simx x_year if a_year==1973, lwidth(thin) msymbol(Oh) msize(tiny) mlwidth(thin)) ///
	(connected r5010simx x_year if a_year==1989, lwidth(thin) msymbol(Oh) msize(tiny) mlwidth(thin)) ///
	(connected r5010simx x_year if a_year==2005, lwidth(thin) msymbol(Oh) msize(tiny) mlwidth(thin)) ///
	(connected r5010simx x_year if a_year==2018, lwidth(thin) msymbol(Oh) msize(tiny) mlwidth(thin)) ///
	(connected r5010x x_year if a_year==2018, lwidth(thin) msymbol(O) msize(small) mlwidth(thin)) ///
	, ///
	ylabel(0.35(.05)0.6, labsize(small) nogrid) ///
	xlabel(1973(4)2020, labsize(small)) ///
	legend(label(1 "1973 f(e | skills)") label(2 "1989 f(e | skills)") label(3 "2005 f(e | skills)") ///
	label(4 "2018 f(e | skills)") label(5 "Actual residual") ///
	region(fcolor(white)) pos(6) size(small) region(lstyle(none))) ///
	graphregion(color(white)) plotregion(lcolor(black) lwidth(thin)) ///	
	title("Female 50/10", size(medsmall) color(black)) ///
	xtitle("") ///
	ytitle("Log 50/10 ratio", size(small)) 
graph export "$figures/Figure8/Figure8_replication_PanelD.eps", replace

	
