/*==============================================================================
						Cleaning -- CPS ASEC years 1992-2020
==============================================================================*/		
cap log close 
clear all 
set more off

** Set paths here
run "SET/PATHS/HERE"

/*------------------------------------------------------------------------------
	CPS ASEC cleaning
------------------------------------------------------------------------------*/
* data downloaded from IPUMS
use "$data_raw/cps_asec.dta", clear

* keep relevant years
keep if inrange(year, 1992, 2020)

* exclude armed forces bc missing variables some years (e.g. "ahrsworkt" in 1962)
keep if popstat==1 
drop popstat

* keep if worked between 1 and 52 weeks
keep if wkswork1>=1 & wkswork1<=52

* keep those aged 16+ last year (aka age>=17)
keep if age>=17

* create allocated flag
gen allocated=((qincwage==1 | qinclong==1) & srcearn==1)

* redefine top coding for "ahrsworkt" and "uhrsworkly" to be 98 for all years
replace ahrsworkt=98 if ahrsworkt==99 
replace uhrsworkly=98 if uhrsworkly==99

/* In Autor's cleaning code, he constructs an educational attainment variable "educomp" 
 based on two other variables: 1) "_grdhi" (Autor) or "higrade" in IPUMS CPS, 
 and 2) "grdcom". The variable "educomp" is equivalent to "educ" in IPUMS CPS 
 except with different values.  I create "educomp" based on the IPUMS "educ" variable. */
gen educomp=.
replace educomp=0 if educ==1 | educ==2
replace educomp=1 if educ==10 | educ==11
replace educomp=2 if educ==12
replace educomp=3 if educ==13
replace educomp=4 if educ==14
replace educomp=5 if educ==20 | educ==21
replace educomp=6 if educ==22
replace educomp=7 if educ==30 | educ==31
replace educomp=8 if educ==32
replace educomp=9 if educ==40
replace educomp=10 if educ==50
replace educomp=11 if (educ==60 | educ==71)
replace educomp=12 if (educ==72 | educ==73)
replace educomp=13 if (educ==73 | educ==80 | educ==81)
replace educomp=14 if educ==90 | educ==91 | educ==92
replace educomp=15 if educ==100
replace educomp=16 if educ==110 | educ==111
replace educomp=17 if educ==121
replace educomp=18 if educ==122 | educ==123 | educ==124 | educ==125
replace educomp=12 if (educ==72 | educ==73)

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

* create race groups
replace race=1 if race==100
replace race=2 if race==200
replace race=3 if race>=300
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

* "wgt" has two unwritten decimal places; exclude negative weights
rename asecwt wgt
replace wgt=wgt/100
keep if wgt>=0 & wgt~=.
replace wgt=wgt/2 if year==2014

* create female variable
gen female=sex==2
lab var female "Female (1:yes 0:no)"
drop sex

* convert "educ" into years of experience ("exp") using file from AKK
do "$scripts/Clean_MarchCPS/CPS_education_post92.do"
lab var exp "Experience (years)"

* create age last year variable "agely": age=71 for age>=71
gen agely=age-1 if age>=17 & age<=71
replace agely=71 if age>=72
drop age

* create flag if HH main industry last year is private sector
gen phh=indly==761

* create wage-worker and self-employed variables
gen wageworker=classwly>=22 & classwly<=28
gen selfemp=classwly>=13 & classwly<=14
keep if wageworker==1 | selfemp==1
lab var wageworker "Wage worker"
lab var selfemp "Self-employed"

* create fullyear worker variable (40-52 weeks)
gen fullyear=wkswork1>=40 & wkswork1<=52
label var fullyear "Full year workers (40-52 weeks last year)"
gen fulltime=fullpart==1
label var fulltime "Fulltime worker, 35+ hours"

* define new weights
gen wgt_wks=wgt*wkswork1
gen wgt_hrs=wgt*wkswork1*uhrsworkly
gen wgt_hrs_ft=wgt*uhrsworkly
lab var wgt_wks "Weight x weeks lasts yr"
lab var wgt_hrs "Weight x weeks last yr x hours worked per week"
lab var wgt_hrs_ft "Weight x hours worked per week"

/* GDP PCE deflator is in 2000$. The indexes refer to the year prior to the 
CPS year. This is accounted for in the file: deflator_pce.do */
merge m:1 year using "$data_out/deflator_pce.dta", keepusing(deflator_2000) keep(matched) nogen

/*  Very important.  IPUMS CPS has specific coding for variables that are:
1) not in the universe (NIU) or 2) missing. This is not the case in AKK's source files. */ 

* not in universe
foreach var of varlist incwage inctot incbus incfarm inclongj oincwage {
	replace `var'=. if `var'==99999999	
}

*  missing
replace ahrsworkt=. if ahrsworkt==999

/* create consistent wage measures:
1) flag those who earn below $1/hr using PCE deflator_2000
2) flag their hourly AND weekly wage since both implictly depend on $1 per hour */

gen winc_ws=(inclongj+oincwage)/wkswork1 if wageworker==1 & (inclongj+oincwage)>0 
label var winc_ws "Weekly wage" 

gen hinc_ws=winc_ws/uhrsworkly if wageworker==1 & (inclongj+oincwage)>0 
label var hinc_ws "Hourly wage" 

gen bcwkwg=(winc_ws*deflator_2000)<(40*(100/49.378))
label var bcwkwg "wkwage<$40/wk in 1982$, using GDP PCE deflator_2000" 

gen bchrwg=(winc_ws*deflator_2000/uhrsworkly)<(1*(100/49.378))
label var bchrwg "hrwage<$1/hr in 1982$, using GDP PCE deflator_2000" 

gen bcwkwgkm=(winc_ws*deflator_2000)<(67*(100/49.378))
label var bcwkwgkm "wkwage<$67/wk in 1982$, using GDP PCE deflator_2000" 

gen bchrwgkm=(winc_ws*deflator_2000/uhrsworkly)<(1.675*(100/49.378))
label var bchrwgkm "hrwage<$1.675/hr in 1982$, using GDP PCE deflator_2000" 

* labeling variables
label var statefip "State fip"
label var wgt "ASEC weight"
label var higrade "High school grade completed"
label var inctot "Total personal income"
label var incwage "Income, wage and salary"
label var incbus "Income, non-farm business"
label var incfarm "Income, farm"
label var inclongj "Earnings from longest job"
label var agely "Age last year"
label var phh "Household industry is private industry"
label var fulltime "Fulltime worker, 35+ hours"
label var wkswork1 "Weeks worked last year"
label var allocated "Allocated flag"
label var uhrsworkly "Usual weekly hours, last yr"
label variable year "Year income earned" 
rename ahrsworkt hrslwk
label variable hrslwk "Hours last week"
gen weeks_lastyear=wkswork1
label var weeks_lastyear "Weeks worked last year"
gen hours_lastyear=uhrsworkly
label var hours_lastyear "Weekly hours worked last year"

* saving 
save "$data_out/ASEC_1992_2020_cleaned_notop.dta", replace	

** Now saving a different version to use in later analysis
* top codes and restrictions
if year== 1992 {
	scalar MAXER = 99999
	}
if year== 1993 {
	scalar MAXER = 99999
	}
if year== 1994 {
	scalar MAXER = 99999
	}
if year== 1995 {
	scalar MAXER = 99999
	}
if year== 1996 {
	scalar MAXER = 150000
	}
if year== 1997 {
	scalar MAXER = 150000
	}
if year== 1998 {
	scalar MAXER = 150000
	}
if year== 1999 {
	scalar MAXER = 150000
	}
if year== 2000 {
	scalar MAXER = 150000
	}
if year== 2001 {
	scalar MAXER = 150000
	}
if year== 2002 {
	scalar MAXER = 150000
	}
if year== 2003 {
	scalar MAXER = 200000
	}
if year== 2004 {
	scalar MAXER = 200000
	}
if year== 2005 {
	scalar MAXER = 200000
	}
if year== 2006 {
	scalar MAXER = 200000
	}
if year== 2007 {
	scalar MAXER = 200000
	}
if year== 2008 {
	scalar MAXER = 200000
	}
if year== 2009 {
	scalar MAXER = 200000 
	}
if year== 2010 {
	scalar MAXER = 200000 
	}
if year== 2011 {
	scalar MAXER = 250000 
	}
if year== 2012 {
	scalar MAXER = 250000 
	}
if year== 2013 {
	scalar MAXER = 250000 
	}
if year== 2014 {
	scalar MAXER = 250000 
	}
if year== 2015 {
	scalar MAXER = 280000 
	}
if year>= 2016 {
	scalar MAXER = 300000 
	}

if year== 1992 {
	scalar MAXWG = 99999
	}
if year== 1993 {
	scalar MAXWG = 99999
	}
if year== 1994 {
	scalar MAXWG = 99999
	}
if year== 1995 {
	scalar MAXWG = 99999
	}
if year== 1996 {
	scalar MAXWG = 25000
	}
if year== 1997 {
	scalar MAXWG = 25000
	}
if year== 1998 {
	scalar MAXWG = 25000
	}
if year== 1999 {
	scalar MAXWG = 25000
	}
if year== 2000 {
	scalar MAXWG = 25000
	}
if year== 2001 {
	scalar MAXWG = 25000
	}
if year== 2002 {
	scalar MAXWG = 25000
	}
if year== 2003 {
	scalar MAXWG = 35000
	}
if year== 2004 {
	scalar MAXWG = 35000
	}
if year== 2005 {
	scalar MAXWG = 35000
	}
if year== 2006 {
	scalar MAXWG = 35000
	}
if year== 2007 {
	scalar MAXWG = 35000
	}
if year== 2008 {
	scalar MAXWG = 35000
	}
if year== 2009 {
	scalar MAXWG = 35000
	}
if year== 2010 {
	scalar MAXWG = 35000
	}
if year== 2011 {
	scalar MAXWG = 47000
	}
if year== 2012 {
	scalar MAXWG = 50000 
	}
if year== 2013 {
	scalar MAXWG = 50000 
	}
if year== 2014 {
	scalar MAXWG = 46000 
	}
if year== 2015 {
	scalar MAXWG = 56000 
	}
if year== 2016 {
	scalar MAXWG = 55000 
	}
if year== 2017 {
	scalar MAXWG = 55000 
	}
if year== 2018 {
	scalar MAXWG = 56000 
	}
if year== 2019 {
	scalar MAXWG = 56000 
	}
if year== 2020 {
	scalar MAXWG = 56000 
	}

scalar list MAXER MAXWG 

replace inclongj=MAXER*1.5 if inclongj!=. & inclongj>=MAXER 
replace oincwage=MAXWG*1.5 if oincwage!=. & oincwage>=MAXWG 
sum inclongj oincwage

gen tcwkwg= ((inclongj+oincwage)/wkswork1)>((MAXER+MAXWG)*1.5/40) 
tab tcwkwg, miss 

gen tchrwg= ((inclongj+oincwage)/(uhrsworkly*wkswork1))>((MAXER+MAXWG)*1.5/1400) 
tab tchrwg, miss 

/* create consistent wage measures:
1) flag those who earn below $1/hr using PCE deflator_2000
2) flag their hourly AND weekly wage since both implictly depend on $1 per hour */

replace winc_ws=(inclongj+oincwage)/wkswork1 if wageworker==1 & (inclongj+oincwage)>0 
label var winc_ws "Weekly wage" 

replace hinc_ws=winc_ws/uhrsworkly if wageworker==1 & (inclongj+oincwage)>0 
label var hinc_ws "Hourly wage" 

replace bcwkwg=(winc_ws*deflator_2000)<(40*(100/47.363))
label var bcwkwg "wkwage<$40/wk in 1982$, using GDP PCE deflator_2000" 

replace bchrwg=(winc_ws*deflator_2000/uhrsworkly)<(1*(100/47.363))
label var bchrwg "hrwage<$1/hr in 1982$, using GDP PCE deflator_2000" 

replace bcwkwgkm=(winc_ws*deflator_2000)<(67*(100/47.363))
label var bcwkwgkm "wkwage<$67/wk in 1982$, using GDP PCE deflator_2000" 

replace bchrwgkm=(winc_ws*deflator_2000/uhrsworkly)<(1.675*(100/47.363))
label var bchrwgkm "hrwage<$1.675/hr in 1982$, using GDP PCE deflator_2000" 

* keep necessary variables
keep wgt* agely exp female year school fulltime fullyear wageworker selfemp deflator_2000 ///
	white black other inc* wkswork1 uhrsworkly hrslwk phh higrade classwly ///
	winc_ws hinc_ws bchrwg bcwkwg bchrwgkm bcwkwgkm statefip allocated cpsidp ///
	weeks_lastyear hours_lastyear
	
* saving 
save "$data_out/ASEC_1992_2020_cleaned_top.dta", replace	

