/*==============================================================================
	DESCRIPTION: The do file calculates an average relative wage by year-education-experience-gender 
	cell over the entire time period. It then calculates efficiency units by education, 
	first not taking into account experience levels and then taking it into account.  
	It calculates efficiency units for all individuals, and then broken down by gender. 
	
	INPUT: MarchCells_1963_2023.dta
	OUTPUT: Efficiency_units_1963_2023.dta
==============================================================================*/		

/*------------------------------------------------------------------------------
	Set paths here
------------------------------------------------------------------------------*/
do "/XX.do"

/*------------------------------------------------------------------------------
	Calculate efficiency units
------------------------------------------------------------------------------*/
use "$data_out/MarchCells_1963_2022.dta", clear

* change max experience to 48 to allow full range of experience for each education-age level
keep if exp>=0 & exp<=48
gen expcat=1
replace expcat=2 if exp>=10 & exp<=19
replace expcat=3 if exp>=20 & exp<=29
replace expcat=4 if exp>=30 & exp<=39
replace expcat=5 if exp>=40 & exp<=48 
label var expcat "Experience groups"
label define expcat 1 "0-9" 2 "10-19" 3 "20-29" 4 "30-39" 5 "40-48"
label values expcat expcat

* calculate average relative wage by cell over time period
* efficiency units translation: Base is HSD Male with 10 years of potential experience in each year
egen refwage=max(rwinc*(female==0)*(school==2)*(exp==10)), by(year)
label var refwage "Reference wage, yearly: HSD male with 10 yr exp"
gen relwage=rwinc/refwage
label var relwage "Wage relative to reference wage"
tab year, summ(relwage)
egen celleu=mean(relwage), by(school female exp)
label var celleu "Cell eff. unit. = mean relative wage, school-female-exp"
tab year, summ(celleu)

* overall efficiency units (not by experience group)
egen tot_euwt = sum(celleu*q_lshrsweight), by(year)
label var tot_euwt "Total efficiency unit, weight: q_lshrsweight"
egen tot_euwt_m = sum(celleu*q_lshrsweight*(1-female)), by(year)
label var tot_euwt_m "Male efficiency unit, weight: q_lshrsweight"
egen tot_euwt_f = sum(celleu*q_lshrsweight*female), by(year)
label var tot_euwt_f "Female efficiency unit, weight: q_lshrsweight"

* share of efficiency unit
gen sh_euwt=celleu*q_lshrsweight/tot_euwt
label var sh_euwt "Share efficiency unit (all)"
gen sh_euwt_m=celleu*q_lshrsweight/tot_euwt_m*(female==0)
label var sh_euwt_m "Share efficiency unit (male)"
gen sh_euwt_f=celleu*q_lshrsweight/tot_euwt_f*female
label var sh_euwt_f "Share efficiency unit (female)"

table year, c(mean sh_euwt mean sh_euwt_m mean sh_euwt_f)

/*------------------------------------------------------------------------------
	Calculating efficiency units by education: non-college and college-plus
------------------------------------------------------------------------------*/
egen eu_shclg=sum(sh_euwt*((school==4 | school==5) + 0.5*(school==3))), by(year)
egen eu_shclg_m=sum(sh_euwt_m*(female==0)*((school==4 | school==5) + 0.5*(school==3))), by(year)
egen eu_shclg_f=sum(sh_euwt_f*female*((school==4 | school==5) + 0.5*(school==3))), by(year)

gen eu_lnclg=ln(eu_shclg/(1-eu_shclg))
gen eu_lnclg_m=ln(eu_shclg_m/(1-eu_shclg_m))
gen eu_lnclg_f=ln(eu_shclg_f/(1-eu_shclg_f))
drop tot_* sh_*

table year, c(mean eu_shclg mean eu_shclg_m mean eu_shclg_f)
table year, c(mean eu_lnclg mean eu_lnclg_m mean eu_lnclg_f)

* labeling
label var eu_shclg "Eff units CLP supply share: All"
label var eu_shclg_m "Eff units CLP supply share: M"
label var eu_shclg_f "Eff units CLP supply share: F"

label var eu_lnclg "Eff units Ln CLG/NON-CLG supply: All"
label var eu_lnclg_m "Eff units Ln CLG/NON-CLG supply: M"
label var eu_lnclg_f "Eff units Ln CLG/NON-CLG supply: F"
label var year "MORG year"

/*------------------------------------------------------------------------------
	Tabulating total hours by CLG and HSG equivalents
------------------------------------------------------------------------------*/
egen hr_clg = sum(q_lshrsweight*((school==4 | school==5) + 0.5*(school==3))), by(year)
egen hr_clg_m = sum(q_lshrsweight*(female==0)*((school==4 | school==5) + 0.5*(school==3))), by(year)
egen hr_clg_f = sum(q_lshrsweight*female*((school==4 | school==5) + 0.5*(school==3))), by(year)

egen hr_hsg = sum(q_lshrsweight*((school==1 | school==2) + 0.5*(school==3))), by(year)
egen hr_hsg_m = sum(q_lshrsweight*(female==0)*((school==1 | school==2) + 0.5*(school==3))), by(year)
egen hr_hsg_f = sum(q_lshrsweight*female*((school==1 | school==2) + 0.5*(school==3))), by(year)

egen hr_clg_exp = sum(q_lshrsweight*((school==4 | school==5) + 0.5*(school==3))), by(year expcat)
egen hr_clg_exp_m = sum(q_lshrsweight*(female==0)*((school==4 | school==5) + 0.5*(school==3))), by(year expcat)
egen hr_clg_exp_f = sum(q_lshrsweight*female*((school==4 | school==5) + 0.5*(school==3))), by(year expcat)

egen hr_hsg_exp = sum(q_lshrsweight*((school==1 | school==2) + 0.5*(school==3))), by(year expcat)
egen hr_hsg_exp_m = sum(q_lshrsweight*(female==0)*((school==1 | school==2) + 0.5*(school==3))), by(year expcat)
egen hr_hsg_exp_f = sum(q_lshrsweight*female*((school==1 | school==2) + 0.5*(school==3))), by(year expcat)

table year, c(mean hr_clg mean hr_clg_m mean hr_clg_f)
table year, c(mean hr_hsg mean hr_hsg_m mean hr_hsg_f)

* labeling variables
label var hr_clg "Hours labor supply CLP: All"
label var hr_clg_m "Hours labor supply CLP: M"
label var hr_clg_f "Hours labor supply CLP: F"

label var hr_hsg "Hours labor supply HSG: All"
label var hr_hsg_m "Hours labor supply HSG: M"
label var hr_hsg_f "Hours labor supply HSG: F"

label var hr_clg_exp "Hours labor supply CLP by exper: All"
label var hr_clg_exp_m "Hours labor supply CLP by exper: M"
label var hr_clg_exp_f "Hours labor supply CLP by exper: F"

label var hr_hsg_exp "Hours labor supply HSG by exper: All"
label var hr_hsg_exp_m "Hours labor supply HSG by exper: M"
label var hr_hsg_exp_f "Hours labor supply HSG by exper: F"

/*------------------------------------------------------------------------------
	Efficiency units by experience group
------------------------------------------------------------------------------*/
egen tot_euwt = sum(celleu*q_lshrsweight),by(year expcat)
egen tot_euwt_m = sum(celleu*q_lshrsweight*(1-female)),by(year expcat)
egen tot_euwt_f = sum(celleu*q_lshrsweight*female),by(year expcat)

gen sh_euwt=celleu*q_lshrsweight/tot_euwt
gen sh_euwt_m=celleu*q_lshrsweight/tot_euwt_m*(female==0)
gen sh_euwt_f=celleu*q_lshrsweight/tot_euwt_f*female

table year, c(mean sh_euwt mean sh_euwt_m mean sh_euwt_f)

egen euexp_shclg = sum(sh_euwt*((school==4 | school==5) + 0.5*(school==3))),by(year expcat)
egen euexp_shclg_m = sum(sh_euwt_m*(female==0)*((school==4 | school==5) + 0.5*(school==3))),by(year expcat)
egen euexp_shclg_f = sum(sh_euwt_f*female*((school==4 | school==5) + 0.5*(school==3))),by(year expcat)

gen euexp_lnclg=ln(euexp_shclg/(1-euexp_shclg))
gen euexp_lnclg_m=ln(euexp_shclg_m/(1-euexp_shclg_m))
gen euexp_lnclg_f=ln(euexp_shclg_f/(1-euexp_shclg_f))

table year, c(mean euexp_shclg mean euexp_shclg_m mean euexp_shclg_f)
table year, c(mean euexp_lnclg mean euexp_lnclg_m mean euexp_lnclg_f)

* labeling variables
label var euexp_shclg "Eff by exper units CLP supply share: All"
label var euexp_shclg_m "Eff by exper units CLP supply share: M"
label var euexp_shclg_f "Eff by exper units CLP supply share: F"

label var euexp_lnclg "Eff by exper units Ln CLG/NON-CLG supply: All"
label var euexp_lnclg_m "Eff by exper units Ln CLG/NON-CLG supply: M"
label var euexp_lnclg_f "Eff by exper units Ln CLG/NON-CLG supply: F"
label var year "MORG year"

* keeping variables
keep year expcat euexp_lnclg* euexp_shclg* eu_lnclg* eu_shclg* hr_*
quietly bysort year expcat: keep if _n==1
sort year expcat

* saving
save "$data_out/Efficiency_units_1963_2022.dta", replace


