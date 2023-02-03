/*==============================================================================
						Cleaning -- CPS ASEC years 1988-1991
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
keep if inrange(year, 1988, 1991)

* exclude armed forces (missing variables some years)
keep if popstat==1 
drop popstat

* keep those who were at least age 16 last year (i.e. age>=17)
keep if age>=17

* create allocated flag
gen allocated=((qoincwage==1 | qinclong==1) & srcearn==1)

* redefine top coding for "ahrsworkt" and "uhrsworkly" to be 98 for all years
replace ahrsworkt=98 if ahrsworkt==99
replace uhrsworkly=98 if uhrsworkly==99

* redefine age topcode to be 90 (varies by year)
replace age=90 if age>=90

/* In Autor's cleaning code, he constructs an educational attainment variable "educomp" 
 based on two other variables: 1) "_grdhi" (Autor) or "higrade" in IPUMS CPS, 
 and 2) "grdcom". The variable "educomp" is equivalent to "educ" in IPUMS CPS 
 except with different values.  I create "educomp" based on the IPUMS "educ" variable. */
gen educomp=.
replace educomp=0 if educ==1 | educ==2
replace educomp=1 if educ==11
replace educomp=2 if educ==12
replace educomp=3 if educ==13
replace educomp=4 if educ==14
replace educomp=5 if educ==21
replace educomp=6 if educ==22
replace educomp=7 if educ==31
replace educomp=8 if educ==32
replace educomp=9 if educ==40
replace educomp=10 if educ==50
replace educomp=11 if educ==60
replace educomp=12 if educ==72 
replace educomp=13 if educ==73 | educ==80
replace educomp=14 if educ==90
replace educomp=15 if educ==100
replace educomp=16 if educ==110
replace educomp=17 if educ==121
replace educomp=18 if educ==122

* create school variable
assert educomp>=0 & educomp<=18
gen school=1 if (educomp<12)
replace school=2 if (educomp==12)
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
replace race=3 if (race==300 | race==650 | race==700)
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

* create female variable
gen female=sex==2
lab var female "Female (1:yes 0:no)"
drop sex

* create experience variable
gen exp=max(age-educomp-7,0)
lab var exp "Experience (years)"
// drop educomp

* create age last year (agely): age=71 for age>=71
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
lab var wgt_wks "Weight x weeks last yr"
lab var wgt_hrs "Weight x weeks last yr x hours worked per week"
lab var wgt_hrs_ft "Weight x hours worked per week"

/* GDP deflator are in 2000$. The indexes refer to the year prior to the 
CPS year. This is accounted for in the file: Deflator_pce.do */
merge m:1 year using "$data_out/deflator_pce.dta", keepusing(deflator_2000) keep(matched) nogen

/*  Very important.  IPUMS CPS has specific coding for variables that are:
1) not in the universe (NIU) or 2) missing. This is not the case in AKK's source files. */ 

* not in universe
foreach var of varlist incwage inctot incbus incfarm inclongj oincwage {
	replace `var'=. if `var'==99999999	
}

* missing
replace ahrsworkt=. if ahrsworkt==999

/* create consistent wage measures:
1) flag those who earn below $1/hr using PCE deflator_2000
2) flag their hourly AND weekly wage since both implictly depend on $1 per hour */

gen winc_ws=(inclongj+oincwage)/wkswork1 if wageworker==1 & (inclongj+oincwage)>0 
label var winc_ws "Weekly wage" 

gen hinc_ws=winc_ws/uhrsworkly if wageworker==1 & (inclongj+oincwage)>0 
label var hinc_ws "Hourly wage" 

gen bcwkwg=(winc_ws*deflator_2000)<(40*(100/49.378))
label var bcwkwg "wkwage<$40/wk in 1982$ following Katz-Murphy (1992), using GDP PCE deflator_2000" 

gen bchrwg=(winc_ws*deflator_2000/uhrsworkly)<(1*(100/49.378))
label var bchrwg "hrwage<$1/hr in 1982$, using GDP PCE deflator_2000"

gen bcwkwgkm=(winc_ws*deflator_2000)<(67*(100/49.378))
label var bcwkwgkm "wkwage<$67/wk in 1982$ following Katz-Murphy (1992), using GDP PCE deflator_2000" 

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
label var weeks_lastyear "Heeks worked last year"
gen hours_lastyear=uhrsworkly
label var hours_lastyear "Weekly hours worked last year"

* keep necessary variables
keep wgt* agely exp female year school fulltime fullyear wageworker selfemp deflator_2000 ///
	white black other inc* wkswork1 uhrsworkly hrslwk phh higrade classwly ///
	winc_ws hinc_ws bchrwg bcwkwg bchrwgkm bcwkwgkm statefip allocated cpsidp ///
	weeks_lastyear hours_lastyear inclongj oincwage educomp

* saving 
save "$data_out/ASEC_1988_1991_cleaned_notop.dta", replace	// top-coded earnings not multiplied by 1.5


* top codes and restrictions
if year== 1988 {
	scalar MAXER = 99999
	}
if year== 1989 {
	scalar MAXER = 99999 
	}
if year== 1990 {
	scalar MAXER = 99999 
	}
if year== 1991 {
	scalar MAXER = 99999 
	}

if year== 1988 {
	scalar MAXWG = 99999
	}
if year== 1989 { 
	scalar MAXWG = 95000
	} 
if year== 1990 { 
	scalar MAXWG = 99999
	} 
if year== 1991 { 
	scalar MAXWG = 90000
	} 

scalar list MAXER MAXWG 

replace inclongj=MAXER*1.5 if inclongj!=. & inclongj>=MAXER 
replace oincwage=MAXWG*1.5 if oincwage!=. & oincwage>=MAXWG 

gen tcwkwg= ((inclongj+oincwage)/wkswork1)>((MAXER+MAXWG)*1.5/40) 
tab tcwkwg, miss 

gen tchrwg= ((inclongj+oincwage)/(uhrsworkly*wkswork1))>((MAXER+MAXWG)*1.5/1400) 
tab tchrwg, miss 

* saving 
save "$data_out/ASEC_1988_1991_cleaned_top.dta", replace // top-coded earnings multiplied by 1.5
