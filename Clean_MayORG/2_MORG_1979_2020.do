/*==============================================================================
						Cleaning May ORG
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
	Cleaning: 1979-2020
------------------------------------------------------------------------------*/
clear	
forval y=1979(1)2020 {
	append using "$data_raw/MORG/morg`y'.dta"
}

* keep ages 16-64 
keep if inrange(age,16,64)

* class of worker: keep wage and salary workers who had job wk before survey
gegen class_new=rowtotal(class class94)
keep if (class_new>=1 & class_new<=6)
// drop if class>5 // drop self-employed??

* drop if not in labor force or unemployed
egen labforce=rowtotal(esr lfsr89 lfsr94)
keep if labforce==1 | labforce==2

* create race groups
replace race=1 if race==1
replace race=2 if race==2
replace race=3 if race>=3
gen white=race==1
gen black=race==2
gen other=race==3
assert white+black+other==1
lab var white "Race: white"
lab var black "Race: black"
lab var other "Race: other"

* create female variable
gen female=sex==2
lab var female "Female (1:yes 0:no)"
drop sex

* create variable fulltime variable (hours>=35). Cannot use MORG flag because of inconsistency
rename uhourse hours
gen ft=hours>=35
replace ft=0 if hours==.
label var ft "Full-time worker, usually 35+ hours/week"

************************************
*   HOURLY WAGES
************************************
gen hwage = earnhre/100
* hourly Wage and Top Coding Adjustment	
gen hr_wage=earnwke/hours
count if hours==-4 & paidhr==2
replace hr_wage=earnwke/hourslw if hours==-4 & paidhre==2 // correction for non-hourly workers
replace hr_wage=(earnwke*1.5)/hours if earnwke==2884.61
* allow hourly workers to use their hourly rate of pay
replace hr_wage=hwage if paidhre==1
gen hourly=paidhre==1
sum hr_wage

* windsorize hourly wages that are based on top coded earnings (other windsorizing and top coding below)
replace hr_wage=(earnwke*1.5)/hours if earnwke==999 & year>=1973 & year<=1988
replace hr_wage=(earnwke*1.5)/hours if earnwke==1923 & year>=1989 & year<=1997
replace hr_wage=(earnwke*1.5)/hours if earnwke==2884 & year>=1998 & year<=2002
replace hr_wage=(earnwke*1.5)/hours if earnwke==2884.61 & year>=2003 & year<=2020

* full-time wage for full-time workers
gen ft_wage=.
replace ft_wage=hr_wage if ft==1
sum ft_wage

** ALLOCATED WAGES
gen allocated=I25d==1
replace allocated=1 if (I25c==1 & paidhre==1)


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
*   Education
************************************
/* create variable "educomp" to indicate the number of years of completed schooling.  
If individual did not complete the highest grade attended, the years of completed 
schooling is assigned to be one less than the highest grade attended.*/
gen grade_NEW=gradeat if gradecp==1 & gradeat~=0 // this is for years<=1991
replace grade_NEW=gradeat-1 if gradecp==2 & gradeat~=0
replace grade_NEW=0 if gradeat==0

* create "educomp"
gen educomp=.
replace educomp=grade_NEW
// replace educomp=0 if grade92==
replace educomp=1 if grade92==31
// replace educomp=2 if grade92==
// replace educomp=3 if grade92==
replace educomp=4 if grade92==32
// replace educomp=5 if grade92==
replace educomp=6 if grade92==33
replace educomp=7 if grade92==34
replace educomp=8 if grade92==35
replace educomp=9 if grade92==36
replace educomp=10 if grade92==37
replace educomp=11 if grade92==38
replace educomp=12 if grade92==39
replace educomp=13 if grade92==40
replace educomp=14 if grade92==41
replace educomp=15 if grade92==42
replace educomp=16 if grade92==43
// replace educomp=17 if grade92==
replace educomp=18 if grade92==44 | grade92==45 | grade92==46 

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

* additional schooling groups
gen edsq = educomp*educomp // Education Squared
*Post-Secondary Schooling 
gen ed12p = max(educomp-12,0)  
*Post-College       
gen ed16p = max(educomp-16,0)  

* modify "educomp" based on AKK's do file for education and experience
do "$scripts/Clean_MayORG/CPS_education_post92.do"

************************************
*   Experience
************************************
gen exp_unrounded=max(age-educomp-6,0)
gen exp=round(exp_unrounded,1)
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
gen pt = !ft // part-time

************************************
*   Weights
************************************
gen wgt_hrs=earnwt*hourslw	
label var wgt_hrs "earnings weight*hours last week"
gen wgtrd_hrs=round(wgt_hrs,1)
label var wgtrd_hrs "earnings weight*hours last week, rounded to nearest integer"

************************************
*   Region dummies
************************************
gen mw = inlist(stfips,17,18,26,39,55,19,20,27,29,31,38,46)
gen so = inlist(stfips,10,11,12,13,24,37,45,51,54,1,21,28,47,5,22,40,48)
gen we = inlist(stfips,4,8,16,30,32,35,49,56,2,6,15,41,53)
replace mw=1 if state>30 & state<50 & year<=1988
replace so=1 if state>50 & state<80 & year<=1988
replace we=1 if state>80 & year<=1988

************************************
*   Defining sample
************************************
gen hr_wage_sample=(!allocated & hr_wage!=. & !hr_w2low)
label var hr_wage_sample "Equal to 1 if hr wage not allocated, & hr wage not missing, & hr wage not too low"     
keep if hr_wage_sample==1 & hr_wage~=.

* keeping needed variables
keep year exp hr_w2low hr_w2hi allocated female age class_new lnrhinc wgt_hrs ///
	hr_wage_sample hr_wage mw so we state stfips earnwt hourslw	f* e* school ///
	deflator_2000 lnrhinc nominal* earnwke hours pt white black other

* saving
save "$data_out/MORG_1979_2020.dta", replace

