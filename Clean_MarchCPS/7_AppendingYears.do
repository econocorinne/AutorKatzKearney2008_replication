/*==============================================================================
	DESCRIPTION: combine all cleaned ASEC years
==============================================================================*/		

/*------------------------------------------------------------------------------
	Set paths here
------------------------------------------------------------------------------*/
do "/XX.do"

/*------------------------------------------------------------------------------
	Appending all years together
------------------------------------------------------------------------------*/
* Dataset with NO top-coded income variables -- this is used in Figure 1
use "$data_out/ASEC_1962_1975_cleaned.dta", clear
append using "$data_out/ASEC_1976_1978_cleaned.dta"
append using "$data_out/ASEC_1979_1987_cleaned.dta"
append using "$data_out/ASEC_1988_1991_cleaned_notop.dta"
append using "$data_out/ASEC_1992_2023_cleaned_notop.dta"
replace year=year-1 // income is earned in year prior to the CPS year, hence subtract 1
* saving 
compress
save "$data_out/ASEC_all_cleaned_NOTOP.dta", replace	

* Dataset with YES top-coded income variables 
use "$data_out/ASEC_1962_1975_cleaned.dta", clear
append using "$data_out/ASEC_1976_1978_cleaned.dta"
append using "$data_out/ASEC_1979_1987_cleaned.dta"
append using "$data_out/ASEC_1988_1991_cleaned_top.dta"
append using "$data_out/ASEC_1992_2023_cleaned_top.dta"
replace year=year-1 // income is earned in year prior to the CPS year, hence subtract 1
* saving 
compress
save "$data_out/ASEC_all_cleaned_TOP.dta", replace	


