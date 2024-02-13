/*==============================================================================
	DESCRIPTION: cleaning May CPS 1973-1978
	
	DATE: February 2024
==============================================================================*/		

/*------------------------------------------------------------------------------
	Set paths here
------------------------------------------------------------------------------*/
do "/XX.do"

/*------------------------------------------------------------------------------
	Cleaning MORG 1973-1978
------------------------------------------------------------------------------*/
* state and region variables
import delimited using "$data_raw/states_mayCPS_1977.csv", clear
save "$data_out/MORG_state_crosswalk.dta", replace

* importing data
clear	
forval y=73(1)78 {
	append using "$data_raw/MORG/cpsmay`y'.dta"
}

* label variables
do "$scripts/Clean_MayORG/Labeling_variables_May_CPS.do"

* renaming variables
rename x200 year
rename x8 region
rename x67 age
rename x28 hours
label var hours "Hours worked last week all jobs"
rename x72 grdhi
label var grdhi "Highest grade attended"
rename x73 grdcom
label var grdcom "Completed highest grade attained"
rename x69 race
rename x70 sex
rename x80 wgtfnl
rename x62 class5
label var class5 "Class of worker 5 categories"
rename x75 empstat
rename x185 uhours
label var uhours "Hours per week usually works"
rename x186 wkusern 
label var wkusern "Usual weekly earnings, principal job"
rename x187 hourpd
label define hourpd 0 "No, not paid hourly" 1 "Yes, paid hourly"
label values hourpd hourpd
rename x188 hourern  
label var hourern "Earnings per hour principal job (cents)"
drop x*

* replacing missing with "."
foreach var of varlist hours class5 wkusern hourpd hourern {
	replace `var'=. if `var'==-99
}


/*------------------------------------------------------------------------------
	Worker characteristics
------------------------------------------------------------------------------*/
* keep ages 16-64 
keep if inrange(age,16,64)

* employment status
keep if empstat==1 | empstat==2

* class of worker
rename class5 class_new
label define class_new 0 "niu" 1 "wage/salary, private" 2 "wage/salary, government" ///
	3 "self-employed" 4 "unpaid family worker" 5 "unknown", replace
label values class_new 
keep if (class_new>=1 & class_new<=3) // keeping wage and salary workers and self-employed

* race groups
gen white=race==1
gen black=race==2
gen other=race==3
assert white+black+other==1
lab var white "Race: white"
lab var black "Race: black"
lab var other "Race: other"
label define race 1 "White" 2 "Black" 3 "Other"
label values race race

* female variable
gen female=sex==2
lab var female "Female (1:yes 0:no)"
drop sex

* region 
gen ne=(region==1)
gen mw=(region==2)
gen so=(region==3)
gen we=(region==4)
drop region

/*------------------------------------------------------------------------------
	Education
------------------------------------------------------------------------------*/
* variable "educomp" is number of schooling years completed
* if highest grade is not completed, "educome" is 1 less than highest grade attended
replace grdhi=grdhi-1
gen educomp=grdhi if grdcom==1 & grdhi~=0
replace educomp=grdhi-1 if grdcom==2 & grdhi~=0
replace educomp=0 if grdhi==0

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
replace hours=99 if hours>=99 & hours<.
replace hours=0 if empstat==2

* full-time variable
gen ft=(hours>=35)
replace ft=0 if hours==.
label var ft "Hours >= 35 last week"

* part-time
gen pt=!ft // part-time

* deal with wage inconsistencies
replace hourern=hourern/100

* hourly worker
gen hourlyworker=(hourpd==0 & hourern>=0 & hourern<.)

/*------------------------------------------------------------------------------
	Allocation flags
------------------------------------------------------------------------------*/
** hourly wage 
gen hr_wage=wkusern/hours
replace hr_wage=(wkusern*1.5)/hours if wkusern==999 & year>=1973 & year<=1978 // windsorize wages

* allow hourly workers to use hourly wage
replace hr_wage=hourern if hourlyworker==1 & hourern!=. & hourern>0

* hourly allocation flag; un-allocated observations have the flag being either 0 or missing
gen aernhr=0
gen aernhr_flag = (aernhr>0 & aernhr!=.)
label var aernhr_flag "Consistent recode of aernhr flag: 1 if obs allocated"

* weekly allocation flag; un-allocated observations have the flag being either 0 or missing
gen aernwk=0
gen aernwk_flag = (aernwk>0 & aernwk!=.)
label var aernwk_flag "Consistent recode of aernwk flag: 1 if obs allocated"

* flag if wage is allocated or not
gen hr_alloc=0
replace hr_alloc=1 if ((aernhr_flag) & hourlyworker==1) & (year<1989 | year>1993)
replace hr_alloc=1 if (aernwk>0 & aernwk!=.) & hourlyworker!=1 & (year<1989 | year>1993)
replace hr_alloc=0 if hr_wage==.
label var hr_alloc "Hourly wage allocated based on both allocation flag and raw hourly/weekly earnings"
tab hr_alloc , miss

* ft wage for ft people
gen ft_wage=.
replace ft_wage=wkusern if ft==1
sum ft_wage

* ft allocated flag
gen ft_alloc=0
replace ft_alloc=1 if (aernwk_flag) & ft==1 & (year<1989  | year>1993)
replace ft_alloc=0 if ft_wage==. | ft==0
label var ft_alloc "Weekly earnings allocated based on both allocation flag and raw weekly earnings"
tab ft_alloc , miss

* create hrs last wk/fulltime interactions
gen ft_hours=hours*ft
label var ft_hours "Interaction between ft and hours"
gen uhrsvary=uhours==-4

/*------------------------------------------------------------------------------
	Weights
------------------------------------------------------------------------------*/
rename wgtfnl wgt
replace wgt=wgt/100
label variable wgt "earnings weight"
gen wgtrd=round(wgt,1)
label variable wgtrd "earnings weight, rounded"

* hours weights can change across different years
gen wgt_hrs=wgt*hours	
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

** flag those earning more than the current earnings top coded times 1.5 divided by 35 hours/week
gen hr_w2hi=0
replace hr_w2hi=1 if ((hr_wage)>((999*1.5)/35)) & year>=1973 & year<=1985 & hr_wage<.
replace hr_w2hi=0 if hr_wage==.
label var hr_w2hi "Equal to one if earning more than the current earnings top code times 1.5 divided by 35 hours/week"

* windsorize wages (set these hourly wages to the top code times 1.5)
replace hr_wage=((999*1.5)/35) if hr_w2hi & year>=1973 & year<=1985

* mark observations as top-coded
gen ft_tp=0
replace ft_tp=1 if ft_wage==999 & year>=1973 & year<=1985
replace ft_tp=0 if ft_wage==.

* ft weekly earnings
replace ft_wage=ft_wage*1.5 if ft_tp==1

/*------------------------------------------------------------------------------
	Sample flags
------------------------------------------------------------------------------*/
gen ft_wage_sample=(ft & !ft_alloc & ft_wage!=. & !ft_w2low)
label var ft_wage_sample "Equal to 1 if full-time, & ft earnings not allocated, & ft wage not missing, & ft wage not too low"

gen hr_wage_sample=(!hr_alloc & hr_wage!=. & !hr_w2low)
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

gen rlnhinc = lnhrwage + ln(deflator)
label var rlnhinc "Log of real hourly wage (2017$)" // these two variables should be the same: lnrhinc and rlnhinc

* saving 
compress
save "$data_out/MayCPS_1973_1978.dta", replace	


