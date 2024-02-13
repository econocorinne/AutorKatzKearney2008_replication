/*==============================================================================
	DESCRIPTION: This do file creates labor supply weights for year-school-experience-gender cells. 
	The weights are equal to the sum of ASEC weights multiplied by weeks worked last
	year multiplied by usual hours worked in a week. 

	INPUT: MarchCells_1963_2023.dta
	OUTPUT: March_labor_supply_weights.dta
==============================================================================*/		

/*------------------------------------------------------------------------------
	Set paths here
------------------------------------------------------------------------------*/
do "/XX.do"

/*------------------------------------------------------------------------------
	Consolidate March cells count data into compatible format, need counts for college and high school groups
------------------------------------------------------------------------------*/
use "$data_out/MarchCells_1963_2022.dta", clear
keep q_lsweight exp school year female

* create experience categories: 5, 15, 25, 35, 45
gen expcat=.
replace expcat=1 if exp>=0 & exp<=9
replace expcat=2 if exp>=10 & exp<=19
replace expcat=3 if exp>=20 & exp<=29
replace expcat=4 if exp>=30 & exp<=39
replace expcat=5 if exp>=40 & exp<=48
tab exp, summ(expcat)

* sum weighting variable by cells
egen lswt=sum(q_lsweight), by(expcat school female year)
quietly bysort year female school expcat: keep if _n==1
drop q_lsweight exp

* labeling
label var expcat "1: 0-9(5), 2:10-19(15), 3:20-29(25), 4:30-39(35) 5:40-48(45)"
label define expcat 1 "5" 2 "15" 3 "25" 4 "35" 5 "45"
label values expcat expcat 
label var lswt "Labor supply weight (sum of wgt*weeks*hours)" 
sort year school expcat female 
label data "March labor supply by grouped experience levels"

* saving
save "$data_out/March_labor_supply_weights.dta", replace


