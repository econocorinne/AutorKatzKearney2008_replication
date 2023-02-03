/*==============================================================================
						Cleaning -- combine all ASEC years
==============================================================================*/		
cap log close 
clear all 
set more off

** Set paths here
run "SET/PATHS/HERE"

/*------------------------------------------------------------------------------
	Appending all years together
------------------------------------------------------------------------------*/
* Dataset WITHOUT top-coded income variables multiplied by 1.5
use "$data_out/ASEC_1962_1975_cleaned.dta", clear
append using "$data_out/ASEC_1976_1978_cleaned.dta"
append using "$data_out/ASEC_1979_1987_cleaned.dta"
append using "$data_out/ASEC_1988_1991_cleaned_notop.dta"
append using "$data_out/ASEC_1992_2020_cleaned_notop.dta"
* saving 
save "$data_out/ASEC_all_cleaned_NOTOP.dta", replace	

* Dataset WITH top-coded income variables multiplied by 1.5
use "$data_out/ASEC_1962_1975_cleaned.dta", clear
append using "$data_out/ASEC_1976_1978_cleaned.dta"
append using "$data_out/ASEC_1979_1987_cleaned.dta"
append using "$data_out/ASEC_1988_1991_cleaned_top.dta"
append using "$data_out/ASEC_1992_2020_cleaned_top.dta"
* saving 
save "$data_out/ASEC_all_cleaned_TOP.dta", replace	



/* Autor's data to compare
clear
foreach year of numlist 64/99 {
	append using "$main/0_Original_paper_codes/AGK_2020_original/CPS/cleaned/mar`year'.dta"
}
foreach year of numlist 0/9 {
	append using "$main/0_Original_paper_codes/AGK_2020_original/CPS/cleaned/mar0`year'.dta"
}
foreach year of numlist 10/18 {
	append using "$main/0_Original_paper_codes/AGK_2020_original/CPS/cleaned/mar`year'.dta", force
}
replace year=year+1
save "$data_out/Autor_allyears.dta", replace	







