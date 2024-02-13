/*==============================================================================
	DESCRIPTION: replicating Table 3
==============================================================================*/		

/*------------------------------------------------------------------------------
	Set paths here
------------------------------------------------------------------------------*/
do "/XX.do"

/*------------------------------------------------------------------------------
	Merging in minimum wage and unemployment rates
------------------------------------------------------------------------------*/

use "$data_out/College_HS_wage_premium_exp.dta", clear
sort year expcat
merge 1:1 year expcat using "$data_out/Efficiency_units_1963_2022.dta", nogen keep(matched)
sort year expcat
merge m:1 year using "$data_out/minnimumwage_unemploymentrate.dta", nogen keep(matched)
gen t=year-1963
gen tsq=t^2/100

* trend breaks
gen t92 = max(year-1992, 0) // change in CPS education coding in 1992 (incorporate trend shift)
gen t89 = max(year-1989, 0)
gen t91 = max(year-1991, 0)
gen t94 = max(year-1994, 0)
tab expcat, gen(expd)

* real minimum wage variables, 2012$ 
sort year
// replace year=year-1
merge m:1 year using "$data_out/deflator_pce.dta", keepusing(deflator* pce*) keep(matched) nogen
gen rminpce=(minimumwage*deflator)
gen lrminpce=ln(rminpce)
list year deflator minimumwage rminpce lrminpce

* difference of: experience group relative supply - aggregate relative supply
gen diffe=euexp_lnclg-eu_lnclg
save "$data_out/Table3_regressions.dta", replace


/*------------------------------------------------------------------------------
	Table 3. Regression models for college/high school log wage gap by potential 
	experience group, 1963-2022, males and female pooled
------------------------------------------------------------------------------*/
use "$data_out/Table3_regressions.dta", clear

* labelling
label var diffe "Own supply minus aggregate supply"
label var eu_lnclg "Aggregate supply"
label var t "Time" 
label var tsq "Time-squared/100"
label var unemp_male "Prime-age male unemployment"
label var lrminpce "Log real minimum wage"

* Regressions 
drop if expcat==5 // don't include last experience group in replication table
eststo clear
eststo m1: reg clphsg_exp diffe eu_lnclg t tsq expd2-expd4  
eststo m2: reg clphsg_exp diffe eu_lnclg t tsq lrminpce unemp_male expd2-expd4
eststo m3: reg clphsg_exp diffe eu_lnclg t tsq lrminpce unemp_male if expcat==1
eststo m4: reg clphsg_exp diffe eu_lnclg t tsq lrminpce unemp_male if expcat==2
eststo m5: reg clphsg_exp diffe eu_lnclg t tsq lrminpce unemp_male if expcat==3
eststo m6: reg clphsg_exp diffe eu_lnclg t tsq lrminpce unemp_male if expcat==4
esttab m1 m2 m3 m4 m5 m6 using out.txt, b(3) se(3)  ///
	label replace booktabs keep(diffe eu_lnclg t tsq lrminpce unemp_male _cons) ///
	order(diffe eu_lnclg lrminpce unemp_male t tsq _cons) ///
	mtitles("" "" "0-9 yrs" "10-19 yrs" "20-29 yrs" "30-39 yrs") nonumber ///
	stats(N r2, labels("Observations" "R-squared") fmt(0 2)) 

/*------------------------------------------------------------------------------
	Extension
------------------------------------------------------------------------------*/

* Regressions: experience category 5
use "$data_out/Table3_regressions.dta", clear

* labelling
label var diffe "Own supply minus aggregate supply"
label var eu_lnclg "Aggregate supply"
label var t "Time" 
label var tsq "Time-squared/100"
label var unemp_male "Prime-age male unemployment"
label var lrminpce "Log real minimum wage"

* Regressions 
eststo clear
eststo m1: reg clphsg_exp diffe eu_lnclg t tsq expd2-expd5
eststo m2: reg clphsg_exp diffe eu_lnclg t tsq lrminpce unemp_male expd2-expd5
eststo m3: reg clphsg_exp diffe eu_lnclg t tsq lrminpce unemp_male if expcat==5
esttab m1 m2 m3 using out.txt, b(3) se(3)  ///
	label replace booktabs keep(diffe eu_lnclg t tsq lrminpce unemp_male _cons) ///
	order(diffe eu_lnclg lrminpce unemp_male t tsq _cons) ///
	mtitles("Model A" "Model B" "40-49 yrs") nonumber ///
	stats(N r2, labels("Observations" "R-squared") fmt(0 2)) 
	
	
	
	
