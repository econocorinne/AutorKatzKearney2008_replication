/*==============================================================================
	DESCRIPTION: assemble predicted MORG wages
	
	DATE: February 2024
==============================================================================*/		

/*------------------------------------------------------------------------------
	Set paths here
------------------------------------------------------------------------------*/
do "/XX.do"

/*------------------------------------------------------------------------------
	Additional cleaning to predicted wages
------------------------------------------------------------------------------*/
use "$data_out/Predicted_wages_MORG.dta", clear 

* rename variables
tab school
rename exp1 expcat
recode expcat 5=1 15=2 25=3 35=4 45=5

* add employment shares
sort year school expcat female
merge 1:1 year school expcat female using "$data_out/March_labor_supply_weights.dta", nogen keep(matched)

* calculate fixed weights
egen t1=sum(lswt),by(year)
gen normlswt=lswt/t1
egen avlswt=mean(normlswt), by(school female expcat)
drop t1

* labeling
label var lswt "Labor supply in cell"
label var normlswt "Labor supply share in cell/year"
label var avlswt "Average labor supply share in cell over 1973-2022"
label var plnhrw "Pred ln hr wg"
table year, c(mean lswt sd lswt )
table year, c(mean normlswt sd normlswt mean avlswt sd avlswt)

* creating real predicted wages
gen rplnhrw = plnhrw + ln(deflator)
label var rplnhrw "Real predicted log hourly wage"

* labeling
label drop _all
label define expcat 1 "5 years" 2 "15 years" 3 "25 years" 4 "35 years" 5 "45 years"
label values expcat expcat
label var expcat "Experience categories"
tab expcat
label var female "Female: (0:no, 1: yes)"
label var school "Education (5 groups)"

* ordering and labeling dataset
aorder
order year female school expcat rplnhrw plnhrw deflator avlswt normlswt lswt
summ
desc
label data "May Predicted Wages 1973-2020: by year-gender-education-experience"

* saving
save "$data_out/Predicted_wages_1973_2020_MORG.dta", replace

