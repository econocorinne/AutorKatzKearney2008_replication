/*==============================================================================
						Cleaning May CPS
==============================================================================*/		
cap log close 
clear all 
set more off

** Set paths here
run "SET/PATHS/HERE"

/* Note: The subsequent do files build on code publicly available that is used
in AKK (2008) and Autor, Goldin and Katz (2020). */

/*------------------------------------------------------------------------------
	Overview of data sources
------------------------------------------------------------------------------*/
/* 1) Data for the May CPS from years 1973-1978 is from the NBER: 
https://www.nber.org/research/data/current-population-survey-cps-may-extracts-1969-1987

2) Data for the May ORG from years 1979-2020 is from IPUMS CPS:
https://data.nber.org/morg/annual/ */


/*------------------------------------------------------------------------------
	Cleaning: 1973-1978
------------------------------------------------------------------------------*/
clear	
forval y=73(1)78 {
	append using "$data_raw/MORG/cpsmay`y'.dta"
}

* label variables
do "$scripts/Clean_MayORG/Labeling_variables_May_CPS.do"

* renaming variables
rename x200 year
rename x67 age
rename x28 hours
rename x72 gradeat
rename x73 gradecp
rename x69 race
rename x70 sex
rename x108 wageworker
rename x80 wgt
rename x62 class_new
lab var class_new "Class of worker 5 categories"
rename x68 marst
rename x66 relate
rename x2 month
rename x95 wkstat
rename x75 mlr // this is the same as "empstat" in AKK code
rename x188 hourern 
lab var hourern "Earnings per hour principal job (cents)"
rename x186 wkusern 
lab var wkusern "Usual weekly earnings, principal job"
rename x187 hourpd
label define hourpd 0 "No, not paid hourly" 1 "Yes, paid hourly"
label values hourpd hourpd
rename x29 uslft

* replacing missing with "."
foreach var of varlist x7 x9 hours class_new wkusern hourpd hourern {
	replace `var'=. if `var'==-99
}


* state and region variables
// import delimited using "$data_raw/states_mayCPS_1977.csv", clear
// save "$data_out/MORG_state_crosswalk.dta", replace
merge m:1 x7 using "$data_out/MORG_state_crosswalk.dta", nogen keepusing(region)
gen mw = inlist(x9,41,42,43,31,32,33,34,35)
gen so = inlist(x9,62,73,51,56,55,54,61,71,53,72,52)
gen we = inlist(x9,93,81,91,92)
gen ne = inlist(x9,12,11,13,22,21,23)

* dropping unneeded variables
drop x* 

* keep those who were at least age 16 last year (i.e. age>=17)
keep if age>=17

* redefine age topcode to be 90 (varies by year)
replace age=90 if age>=90

* negative hours
replace hours=0 if hours<0

* missing hours
drop if hours==.


************************************
*   Worker characteristics
************************************

* create race groups
gen white=race==1
gen black=race==2
gen other=race==3
assert white+black+other==1
lab var white "Race: white"
lab var black "Race: black"
lab var other "Race: other"

* relabel variable "race"
label define race 1 "White" 2 "Black" 3 "Other"
label values race race

* create female variable
gen female=sex==2
lab var female "Female (1:yes 0:no)"
drop sex

* class of worker
label define class_new 0 "niu" 1 "wage/salary, private" 2 "wage/salary, government" 3 "self-employed" 4 "unpaid family worker" 5 "unknown"
label values class_new class_new

* full-time worker
gen ft=hours>=35
label var ft "Hours >= 35 last week"
gen pt=!ft // part-time
label var pt "Part-time worker"

* create self-employed variables
gen selfemp=class_new==3
lab var selfemp "Self-employed"

* fulltime variable (wkstat)
label define wkstat ///
	0 "niu, blank, or not in labor force" 1 "full-time schedules" ///
	2 "part-time for economic reasons" 3 "unemployed, seeking full-time work" ///
	4 "part-time for non-economic reasons, usu" 5 "unemployed, seeking part-time work"
label values wkstat wkstat

* employment status (empstat)
label define mlr ///
	1 "at work" 2 "has job, not at work last week" 3 "unemployed" 4 "nilf, housework" ///
	5 "nilf, school" 6 "nilf, unable to work" 7 "nilf, other"
label values mlr mlr

* define new weights
gen wgt_hrs=wgt*wgt*hours
label var wgt_hrs "weight*hours last week"


************************************
*   Education
************************************
* recoding highest level of education
gen educomp=gradeat if gradecp==1 & gradeat~=0 // this is for years<=1991
replace educomp=gradeat-1 if gradecp==2 & gradeat~=0
replace educomp=0 if gradeat==0
replace educomp=educomp-1 if educomp>0

* create school variable
assert educomp>=0 & educomp<=18
gen school=1 if (educomp<12)
replace school=2 if educomp==12
replace school=3 if (educomp>=13 & educomp<=15)
replace school=4 if (educomp==16 | educomp==17)
replace school=5 if (educomp>=18)
assert school!=.
label define school 1 "HSD" 2 "HSG" 3 "SMC" 4 "CLG" 5 "GTC"
label values school school
lab var school "Highest schooling completed (5 groups)"
gen edhsd=(school==1)
gen edhsg=(school==2)
gen edsmc=(school==3)
gen edclg=(school==4)
gen edgtc=(school==5)

* 9 schooling groups: 0-4, 5-8, 9, 10, 11, 12, 13-15, 16, 17 
gen ed0_4=(educomp>=0 & educomp<=4) 
gen ed5_8=(educomp>=5 & educomp<=8)
gen ed9=(educomp==9)
gen ed10=(educomp==10)
gen ed11=(educomp==11)
gen ed12=(educomp==12)
gen ed13_15=(educomp>=13 & educomp<=15)
gen ed16=(educomp==16)
gen ed17p=(educomp>=17 & educomp<=18)


************************************
*   Experience
************************************

* create experience variable
gen exp=max(age-educomp-7,0)
lab var exp "Experience (years)"

* experience education interactions
gen exp1 = exp
gen exp2 = (exp1^2)/100
gen exp3 = (exp1^3)/1000
gen exp4 = (exp1^4)/10000

gen e1edhsd = exp1*edhsd
gen e1edsmc = exp1*edsmc
gen e1edclg = exp1*(edclg|edgtc)

gen e2edhsd = exp2*edhsd
gen e2edsmc = exp2*edsmc
gen e2edclg = exp2*(edclg|edgtc)

gen e3edhsd = exp3*edhsd
gen e3edsmc = exp3*edsmc
gen e3edclg = exp3*(edclg|edgtc)

gen e4edhsd = exp4*edhsd
gen e4edsmc = exp4*edsmc
gen e4edclg = exp4*(edclg|edgtc)

* gender interactions with experience, race, part-time
gen fexp1 = female*exp1 // experience
gen fexp2 = female*exp2
gen fexp3 = female*exp3
gen fexp4 = female*exp4
gen fblack = female*black // race
gen fother = female*other

************************************
*   HOURLY WAGES
************************************
gen hr_wage=wkusern/hours
label var hr_wage "Hourly wage"

* allow hourly workers to use their hourly rate of pay
replace hr_wage=hourern if hourpd==1
gen hourly=hourpd==1
sum hr_wage

* windsorize hourly wages that are based on top coded earnings (other windsorizing and top coding below)
replace hr_wage=(wkusern*1.5)/hours if wkusern==999 & year>=1973 & year<=1978

* full-time wage for full-time workers
gen ft_wage=.
replace ft_wage=hr_wage if ft==1
sum ft_wage

************************************
*   REAL WAGES
************************************
/* CPI and GDP deflator are in 2000$. The indexes refer to the year prior to the 
CPS year. This is accounted for in the file: Deflator_gdp_pce.do */
merge m:1 year using "$data_out/deflator_pce.dta", keepusing(deflator_2000) keep(matched) nogen

* real terms
gen rhinc = hr_wage*deflator_2000
label var rhinc "Real hourly wage (2000$)"
gen lnrhinc=ln(rhinc)
label var lnrhinc "Log of real hourly wage (2000$)"
gen rhinc_ft=ft_wage*deflator_2000
label var rhinc_ft "Real hourly wage for full time employees, 2000$"
gen lnhrwage=ln(hr_wage)
label var lnhrwage "Log of hourly wage"
gen rlnhinc = lnhrwage + ln(deflator_2000)
label var rlnhinc "Log of real hourly wage (2000$)"
// these two variables should be the same: lnrhinc and rlnhinc

* nominal variables
gen nominal_hr_wage=hr_wage
gen nominal_lnhrwage=lnhrwage 


************************************
*   Handle Wage Restrictions  
************************************
** (1) Flag those earning < 1982 minimum wage (converted to 2000$ w/GDP PCE)
gen hr_w2low=((hr_wage*deflator_2000)<(1.675*(100/49.378)))
replace hr_w2low=0 if hr_wage==.
label var hr_w2low "Equals 1 if earning < 1982 minimum wage"
tab hr_w2low, miss

gen ft_w2low=((ft_wage*deflator_2000)<(67*(100/49.378)))
replace ft_w2low=0 if ft_wage==.
label var ft_w2low "Equals 1 if earning < 1982 minimum wage, FT workers"
tab ft_w2low, miss

** (2) Flag those earning > current earnings top coded times 1.5 divided by 35 hours/week
gen hr_w2hi=0
replace hr_w2hi=1 if ((hr_wage)>((999*1.5 )/35)) & year>=1973 & year<=1988
replace hr_w2hi=1 if ((hr_wage)>((1923*1.5)/35)) & year>=1989 & year<=1997
replace hr_w2hi=1 if ((hr_wage)>((2884*1.5)/35)) & year>=1998 & year<=2002
replace hr_w2hi=1 if ((hr_wage)>((2884.61*1.5)/35)) & year>=2003 & year<=2020
replace hr_w2hi=0 if hr_wage==.
label var hr_w2hi "Equals 1 if earning > current earnings top code times 1.5 divided by 35 hours/week"
tab hr_w2hi, miss

************************************
*   Defining sample
************************************
gen hr_wage_sample=(hr_wage!=. & !hr_w2low)
label var hr_wage_sample "Equal to 1 if hr wage not allocated, & hr wage not missing, & hr wage not too low"     
// keep if hr_wage_sample==1 & hr_wage~=.

* keeping needed variables
keep year exp hr_w2low hr_w2hi female age class_new lnrhinc wgt_hrs ///
	hr_wage_sample hr_wage mw so we f* e* school ///
	deflator_2000 lnrhinc nominal* hours pt white black other hourpd
// allocated

* saving 
save "$data_out/MayCPS_1973_1978_cleaned.dta", replace	

// use "$data_out/MayCPS_1973_1978_cleaned.dta", clear
// keep if year==1974


