/*==============================================================================
	DESCRIPTION: This do file uses the predicted wages from the previous do file 
	to calculate the wage gaps by education, and education-experience. 
	
	INPUT: Predicted_wages_1963_2022.dta
	OUTPUT: College_HS_wage_premium_exp.dta
==============================================================================*/		

/*------------------------------------------------------------------------------
	Set paths here
------------------------------------------------------------------------------*/
do "/XX.do"

/*------------------------------------------------------------------------------
	Calculating wage gaps by education, and education-experience
------------------------------------------------------------------------------*/

* Loop over each gender
foreach i in m f mf {

 /*--------------------------------
   Calculate weighted wage series
 ---------------------------------*/
	use "$data_out/Predicted_wages_1963_2022.dta", clear // dataset that results from: 12_AssembleWages.do
		
	* Gender exclusions
	if "`i'"=="m" {
		keep if female==0
	}
	if "`i'"=="f" {
		keep if female==1
	}

 /*--------------------------------
   Education groupings
 ---------------------------------*/
	* high school
	egen v1=sum(rplnwkw*avlswt*(school==2)), by(year)
	egen v2=sum(avlswt*(school==2)), by(year)
	gen hsg_wage=v1/v2
	label var hsg_wage "High-school grad wages"
	drop v1 v2
 
	* just college
	egen v1=sum(rplnwkw*avlswt*(school==4)), by(year)
	egen v2=sum(avlswt*(school==4)), by(year)
	gen clg_wage=v1/v2
	label var clg_wage "College grad wages"
	drop v1 v2
 
	* college-plus
	egen v1=sum(rplnwkw*avlswt*(school==4 | school==5)), by(year)
	egen v2=sum(avlswt*(school==4 | school==5)), by(year)
	gen clp_wage=v1/v2
	label var clp_wage "College or more wages"
	drop v1 v2

	* postgrad
	egen v1=sum(rplnwkw*avlswt*(school==5)), by(year) 
	egen v2=sum(avlswt*(school==5)), by(year)
	gen pg_wage=v1/v2
	label var pg_wage "Postgrad wages"
	drop v1 v2
 
 
 /*--------------------------------
   Education-experience groupings
 ---------------------------------*/
	* high school x experience
	egen v1=sum(rplnwkw*avlswt*(school==2)), by(year expcat)
	egen v2=sum(avlswt*(school==2)), by(year expcat)
	gen exp_hsg_wage=v1/v2
	label var exp_hsg_wage "High school wages, by year-experience"
	drop v1 v2

	* just college x experience
	egen v1=sum(rplnwkw*avlswt*(school==4)), by(year expcat)
	egen v2=sum(avlswt*(school==4)), by(year expcat)
	gen exp_clg_wage=v1/v2
	label var exp_clg_wage "College wages, by year-experience"
	drop v1 v2

	* college-plus x experience
	egen v1=sum(rplnwkw*avlswt*(school==4 | school==5)), by(year expcat)
	egen v2=sum(avlswt*(school==4 | school==5)), by(year expcat)
	gen exp_clp_wage=v1/v2
	label var exp_clp_wage "College-plus wages, by year-experience"
	drop v1 v2
 
	* post grad x experience
	egen v1=sum(rplnwkw*avlswt*(school==5)), by(year expcat)
	egen v2=sum(avlswt*(school==5)), by(year expcat)
	gen exp_pg_wage=v1/v2
	label var exp_pg_wage "Postgrad wages, by year-experience"
	drop v1 v2

  /*--------------------------------
   College wage premium (wrt high school)
  ---------------------------------*/
	gen clphsg_all = clp_wage - hsg_wage 
	label var clphsg_all "Wage premium of college-plus to HSG, all experience"
	
	gen clghsg_all = clg_wage - hsg_wage 
	label var clghsg_all "Wage premium of college to HSG, all experience"
	
	gen clphsg_exp = exp_clp_wage - exp_hsg_wage	
	label var clphsg_exp "Wage premium of college-plus to HSG, by experience" 
	
	gen clghsg_exp = exp_clg_wage - exp_hsg_wage
	label var clghsg_exp "Wage premium of college to HSG, by experience"

  /*--------------------------------
   Postgrad wage premium (wrt college)
  ---------------------------------*/
	gen pg_clg_all = pg_wage - exp_clg_wage 
	label var pg_clg_all "Wage premium of postgrad to college, all experience"
	
	gen pg_clg_exp = exp_pg_wage - exp_clg_wage
	label var pg_clg_exp "Wage premium of postgrad to college, by experience"
 
  /*--------------------------------
   Organize
  ---------------------------------*/
	bysort year expcat: keep if _n==1
	keep year expcat clphsg_* clghsg_* pg_*
	sort year expcat

	desc
	list year clp*
	list year clg*

  /*--------------------------------
   Saving
  ---------------------------------*/	
	if "`i'" != "mf" {
		foreach var of varlist pg_* clphsg_* clghsg_* {
			rename `var' `var'_`i'
		}
		save "$data_out/College_HS_wage_premium_exp_`i'.dta", replace // clghsgwg-march-regseries-exp-`i'
	}

	if "`i'"=="mf" {
		merge 1:1 year expcat using "$data_out/College_HS_wage_premium_exp_m.dta", nogen // clghsgwg-march-regseries-exp-m
		sort year expcat
		merge 1:1 year expcat using "$data_out/College_HS_wage_premium_exp_f.dta", nogen // clghsgwg-march-regseries-exp-f
		sort year expcat
		label data "College-HS wage gap, overall and by experience-gender using Handbook approach, average March weights 1964-2023"

	* saving
	save "$data_out/College_HS_wage_premium_exp.dta", replace // clghsgwg-march-regseries-exp
	}
}


/* removing datasets no longer needed
rm "$data_out/ASEC_1976_1978_wkslyr.dta"
rm "$data_out/ASEC_1976_1978_uhrsworkly.dta"
rm "$data_out/ASEC_1976_1978_hrswks.dta"
rm "$data_out/ASEC_1962_1975_cleaned.dta"
rm "$data_out/ASEC_1976_1978_cleaned.dta"
rm "$data_out/ASEC_1979_1987_cleaned.dta"
rm "$data_out/ASEC_1988_1991_cleaned_notop.dta"
rm "$data_out/ASEC_1992_2023_cleaned_notop.dta"
rm "$data_out/ASEC_1988_1991_cleaned_top.dta"
rm "$data_out/ASEC_1992_2023_cleaned_top.dta"
rm "$data_out/precollapsemarch.dta"
rm "$data_out/marchcells1.dta"
local workdir "$data_out/marchhr"
cd `workdir'
local datafiles: dir "`workdir'" files "*.dta"
foreach datafile of local datafiles {
   rm `datafile'
}
local workdir "$data_out/marchwk"
cd `workdir'
local datafiles: dir "`workdir'" files "*.dta"
foreach datafile of local datafiles {
   rm `datafile'
}
rm "$data_out/pwkwageskm.dta"
rm "$data_out/marchtmp.dta"
rm "$data_out/Predicted_wages.dta"
rm "$data_out/College_HS_wage_premium_exp_m.dta"
rm "$data_out/College_HS_wage_premium_exp_f.dta"

