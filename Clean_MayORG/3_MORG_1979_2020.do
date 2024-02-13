/*==============================================================================
	DESCRIPTION: cleaning MORG CPS 1979-2020
	
	DATE: February 2024
==============================================================================*/		

/*------------------------------------------------------------------------------
	Set paths here
------------------------------------------------------------------------------*/
do "/XX.do"

/*------------------------------------------------------------------------------
	Cleaning MORG
------------------------------------------------------------------------------*/
* importing data
clear	
forval y=79(1)99 {
	append using "$data_raw/MORG/morg`y'.dta"
}
forval y=0(1)9 {
	append using "$data_raw/MORG/morg0`y'.dta"
}
forval y=10(1)20 {
	append using "$data_raw/MORG/morg`y'.dta"
}

/*------------------------------------------------------------------------------
	Worker characteristics
------------------------------------------------------------------------------*/
* keep ages 16-64 
keep if inrange(age,16,64)

* employment status
egen empstat=rowtotal(esr lfsr89 lfsr94)
keep if (empstat==1 | empstat==2)

* class of worker
egen class_new=rowtotal(class class94)
label define class_new 0 "Not sure" 1 "Private, Non-Profit or For Profit" 2 "Government - Federal" ///
	3 "Government - State" 4 "Government - Local" 5 "Self-Employed, Incorporated" ///
	6 "Self-Employed, Unincorporated" 7 "Without Pay" 8 "Never worked or never worked full-time"
label val class_new class_new
keep if (inrange(class_new, 0, 6) & year>=1979 & year<=1993) | (inrange(class_new, 1, 7) & year>=1994) 

* race groups
gen white=race==1
gen black=race==2
gen other=race>=3
assert white+black+other==1
lab var white "Race: white"
lab var black "Race: black"
lab var other "Race: other"
label define race 1 "White" 2 "Black" 3 "Other", replace
label values race race

* female variable
gen female=sex==2
lab var female "Female (1:yes 0:no)"
drop sex

* region
rename state x7
merge m:1 x7 using "$data_out/MORG_state_crosswalk.dta", nogen keepusing(region)
rename x7 state
gen mw=(region=="mw")
gen ne=(region=="ne")
gen so=(region=="so")
gen we=(region=="we")
drop region

/*------------------------------------------------------------------------------
	Education
------------------------------------------------------------------------------*/
* "educomp" is number of schooling years completed
gen educomp=gradeat if gradecp==1 & gradeat~=0 // if highest grade not completed, "educomp" is 1 < highest grade attended
replace educomp=gradeat-1 if gradecp==2 & gradeat~=0
replace educomp=0 if gradeat==0

* replace educomp based on grade attained starting in 1992
replace educomp=1 if grade92==31
replace educomp=4 if grade92==32
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

* education from 1992 onwards
rename grade92 educ
do "$scripts/Clean_MayORG/CPS_education_post92.do"

/*------------------------------------------------------------------------------
	Experience
------------------------------------------------------------------------------*/
* experience variable
gen exp=max(age-educomp-6,0)
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

/*------------------------------------------------------------------------------
	Hourly wages prep
------------------------------------------------------------------------------*/
replace uhours=99 if uhours>=99 & uhours<.
replace uhourse=99 if uhourse>=99 & uhourse<.
replace uhourse=0 if empstat==2
replace uhourse=. if uhourse<0

* full-time variable
gen ft=uhourse>=35
replace ft=0 if uhourse==.
label var ft "Hours >= 35 last week"

* part-time
gen pt=!ft 

* deal with wage inconsistencies
replace earnhre=earnhre/100

* hourly worker
gen hourlyworker=(paidhre==1)

/*------------------------------------------------------------------------------
	Allocation flags
------------------------------------------------------------------------------*/
** hourly wage 
gen hr_wage=earnwke/uhourse 
replace hr_wage=(earnwke*1.5)/uhourse if earnwke==999 & year>=1979 & year<=1988
replace hr_wage=(earnwke*1.5)/uhourse if earnwke==1923 & year>=1989 & year<=1997
replace hr_wage=(earnwke*1.5)/uhourse if earnwke==2884 & year>=1998 & year<=2002
replace hr_wage=(earnwke*1.5)/uhourse if earnwke==2884.61 & year>=2003 & year<=2020
replace hr_wage=earnhre if hourlyworker==1 & earnhre!=. & earnhre>0 

* allow hourly workers to use hourly wage
gen hwage=earnhre
replace hr_wage=hwage if hourlyworker==1 & earnhre!=. & earnhre>0

* ft wage for ft people
gen ft_wage=.
replace ft_wage=earnwke if ft==1

* allocated wages
gen alloc=(I25d==1)
replace alloc=0 if I25c==0 & paidhre==1

* fulltime allocated flag
gen ft_alloc=0
replace ft_alloc=1 if alloc & ft==1
replace ft_alloc=0 if ft_wage==. | ft==0
label var ft_alloc "Weekly earnings allocated based on both allocation flag and raw weekly earnings"

* interaction of: hrs last wk X fulltime 
gen ft_hours=uhourse*ft
label var ft_hours "Interaction between ft and hours"
gen uhrsvary=uhourse==-4


/*------------------------------------------------------------------------------
	Weights
------------------------------------------------------------------------------*/
rename earnwt wgt

* hours weights can change across different years
gen wgt_hrs=wgt*uhourse
label variable wgt_hrs "earnings weight*hours last week"
gen wgtrd_hrs=round(wgt_hrs,1)
label variable wgtrd_hrs "earnings weight*hours last week, rounded"

/*------------------------------------------------------------------------------
	Wage flags
------------------------------------------------------------------------------*/
merge m:1 year using "$data_out/deflator_pce.dta", keepusing(deflator) keep(matched) nogen

** flag those earning < $1.675 in 1982 dollars (which is 1.675*2.064452=$3.4579571 in 2017 dollars)
gen step1=hr_wage*deflator
gen hr_w2low=(step1<3.4579571)
replace hr_w2low=0 if hr_wage==.
label var hr_w2low "Equal to one if earning less than the 1982 minimum wage (converted to the 2017$)"
tab hr_w2low, miss

gen step2=ft_wage*deflator
gen ft_w2low=(step2<138.31828) // 1982 minimum wage in 2017 dollars times 40
replace ft_w2low=0 if ft_wage==.
label var ft_w2low "Equal to one if earning less than the 1982 minimum wage (converted to the 2017$)"
tab ft_w2low, miss
drop step*

** flag those earning more than current earnings top coded times 1.5 divided by 35 hours/week
gen hr_w2hi=0
replace hr_w2hi=1 if ((hr_wage)>((999*1.5)/35)) & year>=1973 & year<=1988 & hr_wage<.
replace hr_w2hi=1 if ((hr_wage)>((1923*1.5)/35)) & year>=1989 & year<=1997 & hr_wage<.
replace hr_w2hi=1 if ((hr_wage)>((2884*1.5)/35)) & year>=1998 & year<=2002 & hr_wage<.
replace hr_w2hi=1 if ((hr_wage)>((2884.61*1.5)/35)) & year>=2003 & year<=2020 & hr_wage<.
replace hr_w2hi=0 if hr_wage==.
label var hr_w2hi "Equal to one if earning more than the current earnings top code times 1.5 divided by 35 hours/week"

* windsorize wages (set these hourly wages to the top code times 1.5)
replace hr_wage=((999*1.5)/35) if hr_w2hi & year>=1973 & year<=1988
replace hr_wage=((1923*1.5)/35) if hr_w2hi & year>=1989 & year<=1997
replace hr_wage=((2884*1.5)/35) if hr_w2hi & year>=1998 & year<=2002
replace hr_wage=((2884.61*1.5)/35) if hr_w2hi & year>=2003 & year<=2020

* mark observations as top-coded
gen ft_tp=0
replace ft_tp=1 if ft_wage==999 & year>=1973 & year<=1988
replace ft_tp=1 if ft_wage==1923 & year>=1989 & year<=1997
replace ft_tp=1 if ft_wage==2884 & year>=1998 & year<=2002
replace ft_tp=1 if ft_wage==2884.61 & year>=2003 & year<=2020
replace ft_tp=0 if ft_wage==.

* fulltime weekly earnings
replace ft_wage=ft_wage*1.5 if ft_tp==1


/*------------------------------------------------------------------------------
	Sample flags
------------------------------------------------------------------------------*/
gen ft_wage_sample=(ft & !ft_alloc & ft_wage!=. & !ft_w2low)
label var ft_wage_sample "Equal to 1 if full-time, & ft earnings not allocated, & ft wage not missing, & ft wage not too low"

gen hr_wage_sample=(!alloc & hr_wage!=. & !hr_w2low)
label var hr_wage_sample "Equal to 1 if hr wage not allocated, & hr wage not missing, & hr wage not too low"

/*------------------------------------------------------------------------------
	Real wages
------------------------------------------------------------------------------*/
replace ft_wage=ft_wage*deflator
label var ft_wage "Weekly earnings for full time employees, 2017$"

gen rhinc=hr_wage*deflator
label var hr_wage "Hourly wage for hourly employees & Earnings / last week's hours for full time employees, 2017$"

gen lnrhinc=ln(rhinc)
label var lnrhinc "Log of real hourly wage (2017$)"

gen lnhrwage=ln(hr_wage)
label var lnhrwage "Log of hourly wage"

gen rlnhinc=lnhrwage+ln(deflator)
label var rlnhinc "Log of real hourly wage (2017$)" // these two variables should be the same: lnrhinc and rlnhinc

* saving 
compress
save "$data_out/MORG_1979_2020.dta", replace	

