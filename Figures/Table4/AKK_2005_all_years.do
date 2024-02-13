/*==============================================================================
	DESCRIPTION: Creating simulated data: 2005 base year
==============================================================================*/		

/*------------------------------------------------------------------------------
	Set paths here
------------------------------------------------------------------------------*/
do "/XX.do"

/*------------------------------------------------------------------------------
	Loop
------------------------------------------------------------------------------*/

foreach y of numlist 1973/2004 2006/2020 {
	forval gender=0/1 {

	use "$data_out/MayCPS_MORG_cleaned.dta", clear
	keep if year==2005 | year==`y'
	
	tab year, missing
	drop if year==0
	rename lnrhinc rlnhrwage
	rename wgt_hrs regweight
	rename female sex
	
	keep rlnhrwage regweight sex year ed0_4 ed5_8 ed9 ed10 ed11 ed12 ed13_15 ed16 ed17p age

	* ACTUAL Overall Inequality

	summ rlnhrwage if sex==`gender' & year==2005 [aw=regweight], det
	gen tot_vln_2005 = _result(4) 
	gen tot_90_2005 = _result(12)
	gen tot_50_2005 = _result(10) 
	gen tot_10_2005=  _result(8)

	gen t9010_2005 =tot_90_2005-tot_10_2005
	gen t9050_2005 =tot_90_2005-tot_50_2005
	gen t5010_2005 =tot_50_2005-tot_10_2005

	* ACTUAL Residual Inequality

	* USE TL'S (2006) CONDITIONING SET: UNRESTRICTED SET OF DUMMIES FOR AGE, YEARS OF SCHOOLING, INTERACTIONS BETWEEN NINE SCHOOLING DUMMIES (0-4, 5-8, 9, 10, 11, 12, 13-15, 16, 17) AND A QUARTIC IN AGE 

	drop if age<16
	xi i.age

	foreach ed of varlist ed0_4 ed5_8 ed9 ed10 ed11 ed12 ed13_15 ed16 ed17p {
	   gen ageX`ed' = age*`ed'
	   gen agesqX`ed' = (age^2)*`ed'
	   gen age3X`ed' = (age^3)*`ed'
	   gen age4X`ed' = (age^4)*`ed'	
	  }

	local RHS_DFLx = "ed0_4 ed5_8 ed9 ed10 ed11 ed12 ed13_15 ed16 ed17p _Iage* ageX* agesqX* age3X* age4X*"

	quietly reg rlnhrwage `RHS_DFLx' if sex==`gender' & year==2005 [aw=regweight]
	predict reslnwage2005 if year==2005, resid
	summ reslnwage2005

	gen reslnwage = reslnwage2005 if year==2005

	summ reslnwage if sex==`gender' & year==2005 [aw=regweight], det
	gen rvln = _result(4) 
	gen r90 = _result(12)
	gen r50 = _result(10) 
	gen r10=  _result(8)

	gen r90102005 =r90-r10 
	gen r90502005 =r90-r50
	gen r50102005 =r50-r10

	* SIMULATE USING X'S FROM YEAR + 1...

	di "BASEYEAR FOR DEMOGRAPHICS ==`y'"

	gen T=(year==`y')

	*--------------------------
	* DFL (re)weight toward baseyear demographics
	*--------------------------

	quietly logit T `RHS_DFLx' if sex==`gender', iterate(50)
	predict p if sex==`gender'
	quietly summ T if sex==`gender' [aw=regweight]
	local pie=r(mean)
	gen DFLweight=(1-T)*regweight*(p/(1-p))/(`pie'/(1-`pie'))+T*regweight

	di "******* YEAR = `y' ********"

	summ `RHS_DFLx'
	summ DFLweight

	*--------------------------
	* Overall inequality
	*--------------------------

	* Calculate 90-10, 90-50, 50-10 wage gaps

	* OVERALL INEQUALITY - ACTUAL in simulation year

	summ rlnhrwage if sex==`gender' & year==`y' [aw=regweight], det
	gen tot_vln_`y' = _result(4) 
	gen tot_90_`y' = _result(12)
	gen tot_50_`y' = _result(10) 
	gen tot_10_`y'=  _result(8)

	gen t9010_`y' =tot_90_`y'-tot_10_`y'
	gen t9050_`y' =tot_90_`y'-tot_50_`y'
	gen t5010_`y' =tot_50_`y'-tot_10_`y'


	* OVERALL INEQUALITY - SIMULATED 

	summ rlnhrwage if sex==`gender' & year==2005 [aw=DFLweight], det
	gen tvln_x`y' = _result(4) 
	gen t90_x`y' = _result(12)
	gen t50_x`y' = _result(10) 
	gen t10_x`y' =  _result(8)

	gen t9010_2005x`y' =t90_x`y'-t10_x`y'
	gen t9050_2005x`y' =t90_x`y'-t50_x`y'
	gen t5010_2005x`y' =t50_x`y'-t10_x`y'


	*--------------------------
	* Residual inequality
	*--------------------------

	quietly reg rlnhrwage `RHS_DFLx' if sex==`gender' & year==`y' [aw=regweight]
	predict reslnwage`y' if year==`y', resid
	summ reslnwage`y'

	replace reslnwage = reslnwage`y' if year==`y'

	* ACTUAL Residual Inequality base year
	summ reslnwage if sex==`gender' & year==`y' [aw=regweight], det
	gen rvln_`y' = _result(4) 
	gen r90_`y' = _result(12)
	gen r50_`y' = _result(10) 
	gen r10_`y'=  _result(8)

	gen r9010_`y' =r90_`y'-r10_`y' 
	gen r9050_`y' =r90_`y'-r50_`y'
	gen r5010_`y' =r50_`y'-r10_`y'


	* SIMULATED Residual Inequality
	summ reslnwage if sex==`gender' & year==2005 [aw=DFLweight], det
	gen rvln_2005x`y' = _result(4) 
	gen r90_2005x`y' = _result(12)
	gen r50_2005x`y' = _result(10) 
	gen r10_2005x`y'=  _result(8)

	gen r9010_2005x`y' =r90_2005x`y'-r10_2005x`y'
	gen r9050_2005x`y' =r90_2005x`y'-r50_2005x`y'
	gen r5010_2005x`y' =r50_2005x`y'-r10_2005x`y'

	* Now, reduce the data set
	keep if _n==1

	gen a_year = 2005
	gen x_year=`y'

	gen t9010simx = t9010_2005x`y'
	gen t9050simx = t9050_2005x`y'
	gen t5010simx = t5010_2005x`y'

	gen r9010simx = r9010_2005x`y'
	gen r9050simx = r9050_2005x`y'
	gen r5010simx = r5010_2005x`y'

	rename r90102005 r9010_2005
	rename r90502005 r9050_2005
	rename r50102005 r5010_2005

	rename t9010_`y' t9010x
	rename t9050_`y' t9050x
	rename t5010_`y' t5010x
	rename r9010_`y' r9010x
	rename r9050_`y' r9050x
	rename r5010_`y' r5010x

	rename tvln_x`y' tvlnsim
	rename rvln_2005x`y' rvlnsim
	rename tot_vln_2005 tvln


	keep a_year x_year t9010simx t9050simx t5010simx r9010simx r9050simx r5010simx ///
		t9010_2005 t9050_2005 t5010_2005 r9010_2005 r9050_2005 r5010_2005 ///
		t9010x t9050x t5010x r9010x r9050x r5010x tvlnsim rvlnsim tvln rvln

	order a_year x_year t9010_2005 t9050_2005 t5010_2005 r9010_2005 r9050_2005 r5010_2005 ///
		t9010x t9050x t5010x r9010x r9050x r5010x ///
		t9010simx t9050simx t5010simx r9010simx r9050simx r5010simx tvlnsim rvlnsim tvln rvln 
		
	* saving
	save "$data_out/Simulated/sim-DFL-X-2005-`y'-`gender'.dta", replace	

}
} 


********* CODE FOR ACTUAL YEAR - "FAKE" SIMULATION VARIABLES ************* 

forval gender=0/1 {

	use "$data_out/MayCPS_MORG_cleaned.dta", clear
	keep if year==2005
	
	tab year, missing
	drop if year==0
	rename lnrhinc rlnhrwage
	rename wgt_hrs regweight
	rename female sex
	
	keep rlnhrwage regweight sex year ed0_4 ed5_8 ed9 ed10 ed11 ed12 ed13_15 ed16 ed17p age

	* ACTUAL Overall Inequality

	summ rlnhrwage if sex==`gender' & year==2005 [aw=regweight], det
	gen tot_vln_2005 = _result(4) 
	gen tot_90_2005 = _result(12)
	gen tot_50_2005 = _result(10) 
	gen tot_10_2005=  _result(8)

	gen t9010_2005 =tot_90_2005-tot_10_2005
	gen t9050_2005 =tot_90_2005-tot_50_2005
	gen t5010_2005 =tot_50_2005-tot_10_2005

	* ACTUAL Residual Inequality

	* USE TL'S (2006) CONDITIONING SET: UNRESTRICTED SET OF DUMMIES FOR AGE, YEARS OF SCHOOLING, INTERACTIONS

	drop if age<16
	xi i.age

	foreach ed of varlist ed0_4 ed5_8 ed9 ed10 ed11 ed12 ed13_15 ed16 ed17p {
	   gen ageX`ed' = age*`ed'
	   gen agesqX`ed' = (age^2)*`ed'
	   gen age3X`ed' = (age^3)*`ed'
	   gen age4X`ed' = (age^4)*`ed'	
	  }

	local RHS_DFLx = "ed0_4 ed5_8 ed9 ed10 ed11 ed12 ed13_15 ed16 ed17p _Iage* ageX* agesqX* age3X* age4X*"

	quietly reg rlnhrwage `RHS_DFLx' if sex==`gender' & year==2005 [aw=regweight]
	predict reslnwage2005 if year==2005, resid
	summ reslnwage2005

	gen reslnwage = reslnwage2005 if year==2005

	summ reslnwage if sex==`gender' & year==2005 [aw=regweight], det
	gen rvln = _result(4) 
	gen r90 = _result(12)
	gen r50 = _result(10) 
	gen r10=  _result(8)

	gen r90102005 =r90-r10 
	gen r90502005 =r90-r50
	gen r50102005 =r50-r10

	* Now, reduce the data set
	keep if _n==1

	gen a_year = 2005
	gen x_year=2005

	gen t9010simx = t9010_2005
	gen t9050simx = t9050_2005
	gen t5010simx = t5010_2005

	rename r90102005 r9010_2005
	rename r90502005 r9050_2005
	rename r50102005 r5010_2005

	gen r9010simx = r9010_2005
	gen r9050simx = r9050_2005
	gen r5010simx = r5010_2005

	gen t9010x = t9010_2005
	gen t9050x = t9050_2005
	gen t5010x = t5010_2005

	gen r9010x = r9010_2005
	gen r9050x = r9050_2005
	gen r5010x = r5010_2005

	gen tvlnsim = tot_vln_2005
	gen rvlnsim = rvln
	rename tot_vln_2005 tvln
	
	keep a_year x_year t9010simx t9050simx t5010simx r9010simx r9050simx r5010simx ///
		t9010_2005 t9050_2005 t5010_2005 r9010_2005 r9050_2005 r5010_2005 ///
		t9010x t9050x t5010x r9010x r9050x r5010x tvlnsim rvlnsim tvlnsim rvlnsim tvln rvln 

	order a_year x_year t9010_2005 t9050_2005 t5010_2005 r9010_2005 r9050_2005 r5010_2005 ///
		t9010x t9050x t5010x r9010x r9050x r5010x ///
		t9010simx t9050simx t5010simx r9010simx r9050simx r5010simx tvlnsim rvlnsim tvlnsim rvlnsim tvln rvln 
		
	* saving
	save "$data_out/Simulated/sim-DFL-X-2005-2005-`gender'.dta", replace	
}


********  APPEND ALL YEARS OF DATA  ************

* adding gender variable
clear
forval y=1973(1)2020 {
	forval gender=0/1 {
		use "$data_out/Simulated/sim-DFL-X-2005-`y'-`gender'.dta", clear
		gen sex=`gender'
		save "$data_out/Simulated/sim-DFL-X-2005-`y'-`gender'.dta", replace
}
}

* appending
clear
forval y=1973(1)2020 {
	forval gender=0/1 {
		append using "$data_out/Simulated/sim-DFL-X-2005-`y'-`gender'.dta"
}
}

* saving
save "$data_out/Simulated/sim-DFL-X-2005-allyrs.dta", replace	
	
