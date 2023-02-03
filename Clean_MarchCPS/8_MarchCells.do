/*==============================================================================
						March Cells
==============================================================================*/		
cap log close 
clear all 
set more off

** Set paths here
run "SET/PATHS/HERE"

/*------------------------------------------------------------------------------
	Defining new variables
------------------------------------------------------------------------------*/
use "$data_out/ASEC_all_cleaned_TOP.dta", clear

* keep ages 16-64
keep if agely>=16 & agely<=64
replace exp=round(exp,1)
gen ftfy=fulltime*fullyear
gen hsd=(school==1)
gen hsg=(school==2)
gen smc=(school==3)
gen clg=(school==4)
gen gtc=(school==5)

* replace earnings & wages as missing if not full-time full-year ("ftfy") or if top/bottom coded
replace winc_ws=. if !ftfy | bcwkwgkm
replace hinc_ws=. if !ftfy | bchrwgkm

* create earnings variables
gen rwinc = winc_ws*deflator
label var rwinc "Real earnings (2012$)"
gen lnwinc=ln(winc_ws)
label var lnwinc "Log of earnings"
gen rlnwinc = lnwinc + ln(deflator)
label var rlnwinc "Log of real earnings (2012$)"
gen rhinc = hinc_ws*deflator
label var rhinc "Real hourly wage (2012$)"
gen lnhinc=ln(hinc_ws)
label var lnhinc "Log of hourly wage"
gen rlnhinc = lnhinc + ln(deflator)
label var rlnhinc "Log of real hourly wages (2012$)"

* create count variables
gen q_obs=1
label var q_obs "Number of observations"
gen q_weight=wgt
label var q_weight "Earnings weight"
gen q_lsweight=wgt*weeks_lastyear
label var q_lsweight "Earnings weight times weeks last year"
gen q_lshrsweight=wgt*weeks_lastyear*hours_lastyear
label var q_lshrsweight "Earnings weight times weeks last year times hours last year"

* create education-experience interactions
gen exphsd=exp*hsd
gen exphsg=exp*hsg
gen expsmc=exp*smc
gen expclg=exp*clg
gen expgtc=exp*gtc

gen expsq=exp^2
gen expsqhsd=expsq*hsd
gen expsqhsg=expsq*hsg
gen expsqsmc=expsq*smc
gen expsqclg=expsq*clg
gen expsqgtc=expsq*gtc

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
gcollapse (mean) rwinc rlnwinc rhinc rlnhinc [aweight=p_weight], by(year school exp female)
sort year school exp female
merge 1:1 year school exp female using "$data_out/marchcells1.dta"

* define two earnings variables 
gen lnrwinc=ln(rwinc)
label var lnrwinc "Log real weekly FT earnings, 2012$ (using p_weight)"
gen lnrhinc=ln(rhinc)
label var lnrhinc "Log real hourly FT wage, 2012$ (using p_weight)"

* labeling
label var school "Education groups (HSD, HSG, SMC, CLG, GTC)"
label var rlnwinc "Mean log weekly earnings, 2012$"
label var rlnhinc "Mean log wage, 2012$"
label var exp "Potential experience years (max(min(age-educomp-7,age-17),0))"
label var q_obs "Number of observations"
label var q_weight "Sum of (CPS weights*weeks last year) for all obs"
label var q_lsweight "Sum of (CPS weights*weeks*hours) for all obs"
label var p_obs "Number of FT obs (FT flag) with non-missing earnings, not self employed (may be reweighted for allocation issues)"
label var p_weight "Sum of (CPS weights*weeks last year) for FT obs (FT flag) with non-missing earnings, not self employed (may be reweighted for allocation issues)"
label var p_lsweight "Sum of (CPS weights*weeks last year*hours last wk) for FT obs (FT flag) with non-missing earnings, not self employed (may be reweighted for allocation issues)"
label var _merge "Merge==2 if cell DOES NOT have earnings/wage data"

* saving
save "$data_out/MarchCells_1963_2020.dta", replace


* removing not needed data files
!rm "$data_out/precollapsemarch.dta"
!rm "$data_out/marchcells1.dta"


