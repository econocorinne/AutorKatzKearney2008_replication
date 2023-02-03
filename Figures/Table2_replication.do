/*==============================================================================
						Replicating Table 2
==============================================================================*/		
cap log close 
clear all 
set more off

** SET PATHS HERE
run "/Users/corinnes/Dropbox/0 Research/5_AKK_replication/Scripts/Clean_MarchCPS/0_Paths"

/*------------------------------------------------------------------------------
	REGRESSION MODELS FOR THE COLLEGE/HIGH SCHOOL LOG WAGE GAP, 1963–2005
------------------------------------------------------------------------------*/

* wprem2 = clphsg_all (from "$data_out/College_HS_wage_premium_exp.dta") 
* relsup = eu_lnclg (from "$data_out/Efficiency_units_1963_2020.dta")

use "$data_out/College_HS_wage_premium_exp.dta", clear
merge 1:1 year expcat using "$data_out/Efficiency_units_1963_2020.dta", nogen 
replace year=year-1
merge m:1 year using "$data_out/unemp_male.dta", nogen keepusing(unemp_male)
merge m:1 year using "$data_out/minimumwage.dta", nogen keepusing(minimumwage)
merge m:1 year using "$data_out/deflator_pce.dta", nogen keepusing(deflator_2000) keep(matched)

* creating log real minimum wage
gen real_minwage=minimumwage*deflator_2000
gen log_rminwage=ln(real_minwage)

* trend terms
gen t = year-1962
gen t2 = (t^2/100)
gen t3 = (t^3/1000)

* trend break
gen t92 = max(year-1992, 0) // change in CPS education coding in 1992 (incorporate trend shift)
gen time_post92 = t*t92

* labelling
label var t "Time" 
label var t2 "Time-squared/100"
label var t3 "Time-cubed/1000"
label var time_post92 "post-1992"
label var unemp_male "Male prime-age unemp. rate."
label var real_minwage "Real minimum wage"
label var log_rminwage "Log real minimum wage"
label var eu_lnclg "CLG/HS relative supply"

* regression 
keep year clphsg_all eu_lnclg log_rminwage unemp_male t t2 t3 t92
gduplicates drop

* Regressions 
eststo clear
eststo m1: reg clphsg_all eu_lnclg t if year<=1987
eststo m2: reg clphsg_all eu_lnclg t if year<=2005
eststo m3: reg clphsg_all eu_lnclg t time_post92 if year<=2005
eststo m4: reg clphsg_all eu_lnclg t t2 if year<=2005 
eststo m5: reg clphsg_all eu_lnclg t t2 t3 if year<=2005
eststo m6: reg clphsg_all eu_lnclg log_rminwage unemp_male t t2 t3 if year<=2005
eststo m7: reg clphsg_all eu_lnclg log_rminwage unemp_male t if year<=2005
eststo m8: reg clphsg_all log_rminwage unemp_male t if year<=2005
esttab m1 m2 m3 m4 m5 m6 m7 m8 using out.txt, b(3) se(3)  ///
	label replace booktabs  ///
	mtitles("(1)" "(2)" "(3)" "(4)" "(5)" "(6)" "(7)" "(8)") nonumber ///
	order(eu_lnclg log_rminwage unemp_male t t2 t3 time_post92) ///
	stats(N r2, labels("Observations" "R-squared") fmt(0 2)) 

* Extension: to 2019
eststo clear
eststo m1: reg clphsg_all eu_lnclg t t2
eststo m2: reg clphsg_all eu_lnclg t t2 t3
eststo m3: reg clphsg_all eu_lnclg t time_post92
eststo m4: reg clphsg_all log_rminwage unemp_male t
eststo m5: reg clphsg_all eu_lnclg log_rminwage unemp_male t
eststo m6: reg clphsg_all eu_lnclg log_rminwage unemp_male t t2 t3
esttab m1 m2 m3 m4 m5 m6 using out.txt, b(3) se(3)  ///
	label replace booktabs  ///
	mtitles("(1)" "(2)" "(3)" "(4)" "(5)" "(6)") nonumber ///
	order(eu_lnclg log_rminwage unemp_male t t2 t3 time_post92) ///
	stats(N r2, labels("Observations" "R-squared") fmt(0 2)) 


* regression 1
reg clphsg_all eu_lnclg t if year<=1987
* regression 2
reg clphsg_all eu_lnclg t if year<=2005
* regression 3
reg clphsg_all eu_lnclg t time_post92 if year<=2005
* regression 4
reg clphsg_all eu_lnclg t t2 if year<=2005 
* regression 5
reg clphsg_all eu_lnclg t t2 t3 if year<=2005
* regression 6
reg clphsg_all eu_lnclg log_rminwage unemp_male t t2 t3 if year<=2005
* regression 7
reg clphsg_all eu_lnclg log_rminwage unemp_male t if year<=2005
* regression 8
reg clphsg_all log_rminwage unemp_male t if year<=2005

