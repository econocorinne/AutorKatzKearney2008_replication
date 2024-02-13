/*==============================================================================
	DESCRIPTION: replicating Table 2
==============================================================================*/		

/*------------------------------------------------------------------------------
	Set paths here
------------------------------------------------------------------------------*/
do "/XX.do"

/*------------------------------------------------------------------------------
	External series Prep
------------------------------------------------------------------------------*/

* Federal minimum wage from: FRED (https://fred.stlouisfed.org/series/STTMINWGFG) 
import excel "$data_raw/STTMINWGFG.xls", clear cellrange(A11:B67) firstrow
rename observation_date date
rename STTMINWGFG minimumwage
gen year=year(date)
drop date
local np1=_N+5
set obs `np1'
gen nums=_n
replace year=1963 if nums==57
replace year=1964 if nums==58
replace year=1965 if nums==59
replace year=1966 if nums==60
replace year=1967 if nums==61
drop nums
sort year
replace minimumwage=1.183 if year==1963
replace minimumwage=1.25 if year==1964
replace minimumwage=1.25 if year==1965
replace minimumwage=1.25 if year==1966
replace minimumwage=1.4 if year==1967
label var minimumwage "Federal minimum wage, nominal"
drop if year<1963 | year>2022
save "$data_out/minimumwage.dta", replace

* Overall unemployment rate from: FRED (https://fred.stlouisfed.org/series/UNRATE)
import excel "$data_raw/UNRATE.xls", clear cellrange(A11:B86) firstrow
rename observation_date date
rename UNRATE unemp_rate
gen year=year(date)
drop date
drop if year<1963 | year>2022
label var unemp_rate "Unemployment rate"
save "$data_out/unemp_rate.dta", replace

* Unemployment rate, married men from: FRED (https://fred.stlouisfed.org/series/LNS14000150#0)
import excel "$data_raw/LNS14000150.xls", clear cellrange(A11:B79) firstrow
rename observation_date date
rename LNS14000150 unemp_men_married
gen year=year(date)
drop date
drop if year<1963 | year>2022
label var unemp_men_married "Unemployment rate, married men"
save "$data_out/unemp_men_married.dta", replace

* Unemployment rate, men 25-54 from: FRED (https://fred.stlouisfed.org/series/LNS14000061#0)
import excel "$data_raw/LNS14000061.xls", clear cellrange(A11:B86) firstrow
rename observation_date date
rename LNS14000061 unemp_male
gen year=year(date)
drop date
drop if year<1963 | year>2022
label var unemp_male "Unemployment rate, men 25-54"
save "$data_out/unemp_male.dta", replace

* merge all datasets together
use "$data_out/minimumwage.dta", clear
merge 1:1 year using "$data_out/unemp_rate.dta", nogen
merge 1:1 year using "$data_out/unemp_men_married.dta", nogen
merge 1:1 year using "$data_out/unemp_male.dta", nogen
// replace year=year+1
save "$data_out/minnimumwage_unemploymentrate.dta", replace



/*------------------------------------------------------------------------------
	Regression models for college/high-school wage gap 
------------------------------------------------------------------------------*/

use "$data_out/College_HS_wage_premium_exp.dta", clear
merge 1:1 year expcat using "$data_out/Efficiency_units_1963_2022.dta", nogen 
merge m:1 year using "$data_out/unemp_male.dta", nogen keepusing(unemp_male)
merge m:1 year using "$data_out/minimumwage.dta", nogen keepusing(minimumwage)
merge m:1 year using "$data_out/deflator_pce.dta", nogen keepusing(deflator) keep(matched)

* creating log real minimum wage
gen real_minwage=minimumwage*deflator
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
label var time_post92 "Time X post-1992"
label var unemp_male "Male prime-age unemp. rate."
label var real_minwage "Real minimum wage"
label var log_rminwage "Log real minimum wage"
label var eu_lnclg "CLG/HS relative supply"

* keeping variables 
keep year clphsg_all eu_lnclg log_rminwage unemp_male t t2 t3 t92 time_post92
gduplicates drop

* regression table
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

* regression table extension to 2022
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
