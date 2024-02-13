/*==============================================================================
	DESCRIPTION: Merging all years together
==============================================================================*/		

/*------------------------------------------------------------------------------
	Set paths here
------------------------------------------------------------------------------*/
do "/XX.do"

/*------------------------------------------------------------------------------
	Merging
------------------------------------------------------------------------------*/

use "$data_out/Simulated/sim-DFL-X-1973-allyrs.dta", clear
append using "$data_out/Simulated/sim-DFL-X-1989-allyrs.dta"
append using "$data_out/Simulated/sim-DFL-X-2005-allyrs.dta"
append using "$data_out/Simulated/sim-DFL-X-2018-allyrs.dta"
save "$data_out/Simulated/sim-DFL-X-allyrs.dta", replace

* biggest difference: 2018-1973
use "$data_out/Simulated/sim-DFL-X-allyrs.dta", clear
keep if x_year==1973 | x_year==2018
keep a_year x_year sex t9010simx t9050simx t5010simx r9010simx r9050simx r5010simx
order a_year x_year sex r9050simx r5010simx r9010simx t9050simx t5010simx t9010simx
foreach var of varlist r9050simx r5010simx r9010simx t9050simx t5010simx t9010simx {
	bysort sex a_year (x_year): gen d_`var' = (`var'[_n]-`var'[_n-1])*100
}
drop if d_r9050simx==.
keep a_year x_year sex d_* 
label define sex 0 "male" 1 "female"
label val sex sex
drop x_year
drop if d_r5010simx==.
rename (*simx) (*)
* reshape
reshape long d_r d_t, i(sex a_year) j(ineq)
rename d_r r_1973_2018
rename d_t t_1973_2018
gen order=1 if ineq==9050
replace order=2 if ineq==5010
replace order=3 if ineq==9010
sort order sex a_year
save "$data_out/Simulated/diff_2018_1973.dta", replace

* difference: 2005-1973
use "$data_out/Simulated/sim-DFL-X-allyrs.dta", clear
keep if x_year==1973 | x_year==2005
keep a_year x_year sex t9010simx t9050simx t5010simx r9010simx r9050simx r5010simx
order a_year x_year sex r9050simx r5010simx r9010simx t9050simx t5010simx t9010simx
foreach var of varlist r9050simx r5010simx r9010simx t9050simx t5010simx t9010simx {
	bysort sex a_year (x_year): gen d_`var' = (`var'[_n]-`var'[_n-1])*100
}
drop if d_r9050simx==.
keep a_year x_year sex d_* 
label define sex 0 "male" 1 "female"
label val sex sex
drop x_year
drop if d_r5010simx==.
rename (*simx) (*)
* reshape
reshape long d_r d_t, i(sex a_year) j(ineq)
rename d_r r_1973_2005
rename d_t t_1973_2005
gen order=1 if ineq==9050
replace order=2 if ineq==5010
replace order=3 if ineq==9010
sort order sex a_year
save "$data_out/Simulated/diff_2005_1973.dta", replace

* difference: 2005-1989
use "$data_out/Simulated/sim-DFL-X-allyrs.dta", clear
keep if x_year==1989 | x_year==2005
keep a_year x_year sex t9010simx t9050simx t5010simx r9010simx r9050simx r5010simx
order a_year x_year sex r9050simx r5010simx r9010simx t9050simx t5010simx t9010simx
foreach var of varlist r9050simx r5010simx r9010simx t9050simx t5010simx t9010simx {
	bysort sex a_year (x_year): gen d_`var' = (`var'[_n]-`var'[_n-1])*100
}
drop if d_r9050simx==.
keep a_year x_year sex d_* 
label define sex 0 "male" 1 "female"
label val sex sex
drop x_year
drop if d_r5010simx==.
rename (*simx) (*)
* reshape
reshape long d_r d_t, i(sex a_year) j(ineq)
rename d_r r_1989_2005
rename d_t t_1989_2005
gen order=1 if ineq==9050
replace order=2 if ineq==5010
replace order=3 if ineq==9010
sort order sex a_year
save "$data_out/Simulated/diff_2005_1989.dta", replace

* difference: 1989-1973
use "$data_out/Simulated/sim-DFL-X-allyrs.dta", clear
keep if x_year==1973 | x_year==1989
keep a_year x_year sex t9010simx t9050simx t5010simx r9010simx r9050simx r5010simx
order a_year x_year sex r9050simx r5010simx r9010simx t9050simx t5010simx t9010simx
foreach var of varlist r9050simx r5010simx r9010simx t9050simx t5010simx t9010simx {
	bysort sex a_year (x_year): gen d_`var' = (`var'[_n]-`var'[_n-1])*100
}
drop if d_r9050simx==.
keep a_year x_year sex d_* 
label define sex 0 "male" 1 "female"
label val sex sex
drop x_year
drop if d_r5010simx==.
rename (*simx) (*)
* reshape
reshape long d_r d_t, i(sex a_year) j(ineq)
rename d_r r_1973_1989
rename d_t t_1973_1989
gen order=1 if ineq==9050
replace order=2 if ineq==5010
replace order=3 if ineq==9010
sort order sex a_year
save "$data_out/Simulated/diff_1989_1973.dta", replace

* merging all tables together
use "$data_out/Simulated/diff_2018_1973.dta", clear
merge 1:1 a_year ineq sex using "$data_out/Simulated/diff_2005_1973.dta", nogen 
merge 1:1 a_year ineq sex using "$data_out/Simulated/diff_2005_1989.dta", nogen 
merge 1:1 a_year ineq sex using "$data_out/Simulated/diff_1989_1973.dta", nogen 

* ordering
order a_year ineq sex r_1973_1989 r_1989_2005 r_1973_2005 r_1973_2018 ///
	t_1973_1989 t_1989_2005 t_1973_2005 t_1973_2018 
sort order sex a_year

* saving
save "$data_out/Simulated/diff_all.dta", replace

/*------------------------------------------------------------------------------
	Observed inequality
------------------------------------------------------------------------------*/
	
use "$data_out/Simulated/sim-DFL-X-allyrs.dta", clear
order a_year x_year sex t9010x t9050x t5010x r9010x r9050x r5010x
sort a_year x_year sex
keep if x_year==1973 | x_year==1989 | x_year==2005 | x_year==2018
sort x_year sex
keep a_year x_year sex r* t*
sort x_year sex a_year
drop a_year
bysort x_year sex: gen id=_n
drop if id==1
drop id
gduplicates drop
save "$data_out/Simulated/observed_ineq.dta", replace

* biggest difference: 2018-1973
use "$data_out/Simulated/observed_ineq.dta", clear
keep if x_year==1973 | x_year==2018
keep x_year sex t* r*
keep x_year sex t9010x t9050x t5010x r9010x r9050x r5010x
gduplicates drop
foreach var of varlist t9010x t9050x t5010x r9010x r9050x r5010x {
	bysort sex (x_year): gen d_`var' = (`var'[_n]-`var'[_n-1])*100
}
drop if d_t9010x==.
keep x_year sex d_* 
label define sex 0 "male" 1 "female"
label val sex sex
drop x_year
rename (*x) (*)
rename se sex
* reshape
reshape long d_r d_t, i(sex) j(ineq)
rename d_r r_1973_2018
rename d_t t_1973_2018
gen order=1 if ineq==9050
replace order=2 if ineq==5010
replace order=3 if ineq==9010
sort order sex
save "$data_out/Simulated/observeddiff_2018_1973.dta", replace

* difference: 2005-1973
use "$data_out/Simulated/observed_ineq.dta", clear
keep if x_year==1973 | x_year==2005
keep x_year sex t* r*
foreach var of varlist t9010x t9050x t5010x r9010x r9050x r5010x {
	bysort sex (x_year): gen d_`var' = (`var'[_n]-`var'[_n-1])*100
}
drop if d_t9010x==.
keep x_year sex d_* 
drop if d_t9010x==0
label define sex 0 "male" 1 "female"
label val sex sex
drop x_year
rename (*x) (*)
rename se sex
* reshape
reshape long d_r d_t, i(sex) j(ineq)
rename d_r r_1973_2005
rename d_t t_1973_2005
gen order=1 if ineq==9050
replace order=2 if ineq==5010
replace order=3 if ineq==9010
sort order sex
save "$data_out/Simulated/observeddiff_2005_1973.dta", replace

* difference: 2005-1989
use "$data_out/Simulated/observed_ineq.dta", clear
keep if x_year==1989 | x_year==2005
keep x_year sex t* r*
foreach var of varlist t9010x t9050x t5010x r9010x r9050x r5010x {
	bysort sex (x_year): gen d_`var' = (`var'[_n]-`var'[_n-1])*100
}
drop if d_t9010x==.
keep x_year sex d_*
drop if d_t9010x==0 
label define sex 0 "male" 1 "female"
label val sex sex
drop x_year
rename (*x) (*)
rename se sex
* reshape
reshape long d_r d_t, i(sex) j(ineq)
rename d_r r_1989_2005
rename d_t t_1989_2005
gen order=1 if ineq==9050
replace order=2 if ineq==5010
replace order=3 if ineq==9010
sort order sex
save "$data_out/Simulated/observeddiff_2005_1989.dta", replace

* difference: 1989-1973
use "$data_out/Simulated/observed_ineq.dta", clear
keep if x_year==1973 | x_year==1989
keep x_year sex t* r*
foreach var of varlist t9010x t9050x t5010x r9010x r9050x r5010x {
	bysort sex (x_year): gen d_`var' = (`var'[_n]-`var'[_n-1])*100
}
drop if d_t9010x==.
keep x_year sex d_* 
drop if d_t9010x==0
label define sex 0 "male" 1 "female"
label val sex sex
drop x_year
rename (*x) (*)
rename se sex
* reshape
reshape long d_r d_t, i(sex) j(ineq)
rename d_r r_1973_1989
rename d_t t_1973_1989
gen order=1 if ineq==9050
replace order=2 if ineq==5010
replace order=3 if ineq==9010
sort order sex
save "$data_out/Simulated/observeddiff_1989_1973.dta", replace

* merging years together
use "$data_out/Simulated/observeddiff_2018_1973.dta", clear
merge 1:1 ineq sex order using "$data_out/Simulated/observeddiff_2005_1973.dta", nogen 
merge 1:1 ineq sex order using "$data_out/Simulated/observeddiff_2005_1989.dta", nogen 
merge 1:1 ineq sex order using "$data_out/Simulated/observeddiff_1989_1973.dta", nogen 
replace order=order-0.5
save "$data_out/Simulated/observeddiff_all.dta", replace


/*------------------------------------------------------------------------------
	Table
------------------------------------------------------------------------------*/

use "$data_out/Simulated/diff_all.dta", clear
append using "$data_out/Simulated/observeddiff_all.dta"
order order ineq sex a_year
gen order2=1 if ineq==9050
replace order2=2 if ineq==5010
replace order2=3 if ineq==9010
sort order2 ineq sex order a_year
tostring a_year, replace
replace a_year="Observed" if a_year=="."
replace a_year="1973 X's" if a_year=="1973"
replace a_year="1989 X's" if a_year=="1989"
replace a_year="2005 X's" if a_year=="2005"
replace a_year="2018 X's" if a_year=="2018"
format r* t* %9.1fc
format t* %9.1fc

* then copy into a latex table-making program
