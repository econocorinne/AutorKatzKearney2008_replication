/*==============================================================================
						Cleaning -- combine May CPS and MORG
==============================================================================*/		
cap log close 
clear all 
set more off

** SET PATHS HERE
run "/Users/corinnes/Dropbox/0 Research/5_AKK_replication/Scripts/Clean_MarchCPS/0_Paths"

/* Note: The subsequent do files build on code publicly available that is used
in AKK (2008) and Autor, Goldin and Katz (2020). */

/*------------------------------------------------------------------------------
	Appending all years together
------------------------------------------------------------------------------*/
use "$data_out/MayCPS_1973_1978_cleaned.dta", clear
append using "$data_out/MORG_1979_2020.dta"
* saving 
save "$data_out/MayCPS_MORG_cleaned.dta", replace	
