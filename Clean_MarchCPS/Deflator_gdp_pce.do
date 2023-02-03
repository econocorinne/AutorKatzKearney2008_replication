/*==============================================================================
						Converting prices to 2000 USD
	This file converts prices to 2000 USD using the Personal Consumption
	Expenditure Deflator from the BEA. This is found from Table 1.1.4 at the 
	following website: 
	https://apps.bea.gov/iTable/?reqid=19&step=2&isuri=1&categories=survey
	It is annual data, numbers can be revised 1-2 years later. These data were
	downloaded December 1, 2022. 
==============================================================================*/	
cap log close 
clear all 
set more off

** Set paths here
run "SET/PATHS/HERE"

* import excel file
import excel using "$data_raw/BEA_PCE_Table114.xlsx", clear cellrange(B6:BI9)

* defining new variable names
drop in 2/3
foreach var of varlist B-BI {
	replace `var' = subinstr(`var'," ","_",.) if _n == 1
	local new y`=`var'[1]'
	rename `var' `new'
}
drop in 1
rename y item

* reshaping
reshape long y, i(item) j(year) string
rename y pce
label var pce "Personal Consumption Expenditures (2012=100)"
label var year "Year"
drop item
destring year pce, replace

* creating constant gdp in 2012$
gen deflator=.
replace deflator=100/pce
label var deflator "GDP PCE Deflator, 2012$"

* creating constant gdp in 2000$
gen pce_00=pce if year==2000
sort pce_00
carryforward pce_00, replace
gen pce_2000=pce/pce_00*100
sort year
drop pce_00
gen deflator_2000=1/pce_2000*100
label var pce_2000 "PCE, 2000=100"
label var deflator_2000 "GDP PCE Deflator, 2012$"

* saving
keep year deflator pce* deflator*
save "$data_out/deflator_pce.dta", replace
