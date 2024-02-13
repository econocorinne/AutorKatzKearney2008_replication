/*==============================================================================
	DESCRIPTION: This do file creates earnings variables. It collapses the cleaned 
	CPS ASEC dataset into year-education-experience-gender cells of weekly and 
	hourly earnings, with different weighting definitions.

	INPUT: ASEC_all_cleaned_TOP.dta
	OUTPUT: MarchCells_1963_2023.dta
==============================================================================*/		

/*------------------------------------------------------------------------------
	Set paths here
------------------------------------------------------------------------------*/
do "/XX.do"

/*------------------------------------------------------------------------------
	Defining new variables
------------------------------------------------------------------------------*/
use "$data_out/ASEC_all_cleaned_TOP.dta", clear

* keep ages 16-64
keep if agely>=16 & agely<=64
replace exp=round(exp,1)

* replace earnings & wages as missing if not full-time full-year ("ftfy") or if top/bottom coded
replace winc_ws=. if !ftfy | bcwkwgkm
replace hinc_ws=. if !ftfy | bchrwgkm

* create count variables
gen q_obs=1
label var q_obs "Number of observations"
gen q_weight=wgt
label var q_weight "Earnings weight"
gen q_lsweight=wgt*weeks_lastyear
label var q_lsweight "Earnings weight times weeks last year"
gen q_lshrsweight=wgt*weeks_lastyear*hours_lastyear
label var q_lshrsweight "Earnings weight times weeks last year times hours last year"

* create count variables without the allocators
gen p_obs=1
replace p_obs=0 if winc_ws==. | allocated==1 | selfemp==1
label var p_obs "Number of FTFY obs with non-missing earnings"
gen p_weight=wgt
replace p_weight=0  if winc_ws==. | allocated==1 | selfemp==1
label var p_weight "Earnings weight for FTFY obs with non-missing earnings"
gen p_lsweight=wgt*weeks_lastyear
replace p_lsweight=0 if winc_ws==. | allocated==1 | selfemp==1
label var p_lsweight "Earnings weight times weeks last year for FTFY obs with non-missing earnings"

* saving 
save "$data_out/precollapsemarch.dta", replace

**** collapse to year-education-experience-gender cells
gcollapse (sum) q_obs q_weight q_lsweight q_lshrsweight p_obs p_weight p_lsweight, by(year school exp female)
sort year school exp female
save "$data_out/marchcells1.dta", replace

use "$data_out/precollapsemarch.dta", clear
gcollapse (mean) rwinc rhinc lnrwinc lnrhinc [aweight=p_weight], by(year school exp female)
sort year school exp female
merge 1:1 year school exp female using "$data_out/marchcells1.dta"

* labeling
label var lnrwinc "Log real weekly FT earnings, 2017$ (using p_weight)"
label var lnrhinc "Log real hourly FT wage, 2017$ (using p_weight)"
label var school "Education groups (HSD, HSG, SMC, CLG, GTC)"
label var exp "Potential experience years (max(min(age-educomp-7,age-17),0))"
label var q_obs "Number of observations"
label var q_weight "Sum of (CPS weights*weeks last year) for all obs"
label var q_lsweight "Sum of (CPS weights*weeks*hours) for all obs"
label var p_obs "Number of FT obs (FT flag) with non-missing earnings, not self employed (may be reweighted for allocation issues)"
label var p_weight "Sum of (CPS weights*weeks last year) for FT obs (FT flag) with non-missing earnings, not self employed (may be reweighted for allocation issues)"
label var p_lsweight "Sum of (CPS weights*weeks last year*hours last wk) for FT obs (FT flag) with non-missing earnings, not self employed (may be reweighted for allocation issues)"
label var _merge "Merge==2 if cell DOES NOT have earnings/wage data"

* saving
compress
save "$data_out/MarchCells_1963_2022.dta", replace




