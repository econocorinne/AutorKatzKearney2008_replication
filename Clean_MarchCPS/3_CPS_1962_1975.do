/*==============================================================================
						Cleaning -- CPS ASEC years 1962-1975
==============================================================================*/		
cap log close 
clear all 
set more off

** SET PATHS HERE
run "SET/PATHS/HERE"

/*------------------------------------------------------------------------------
	CPS ASEC cleaning, 1962-1975
------------------------------------------------------------------------------*/
* data downloaded from IPUMS
use "$data_raw/cps_asec.dta", clear

* keep relevant years
keep if inrange(year, 1962, 1975)

* exclude armed forces (missing variables some years)
keep if popstat==1 
drop popstat

* keep those who were at least age 16 last year (i.e. age>=17)
keep if age>=17

* keep those who worked at least 1 week last year
keep if wkswork2>=1 & wkswork2<=6

* create allocated flag
gen allocated=(qincwage==1)

* variable for those who were going to school last year and worked part-year (_wklyr<=49). Just 1962!!
gen studently=actnlfly==3 & wkswork1<=5 & year==1962
drop actnlfly

* redefine top coding for "ahrsworkt" and "uhrsworkly" to be 98 for all years
replace ahrsworkt=0 if ahrsworkt==100 & year==1962
replace ahrsworkt=98 if ahrsworkt==99 & year==1962
replace ahrsworkt=0 if ahrsworkt==99 & (year>=1964 & year<=1967)
replace ahrsworkt=98 if ahrsworkt==99 & (year>=1968 & year<=1975)

* fulltime variable individual worked 35+ hrs/wk last yr
gen fulltime=fullpart==1
label var fulltime "Usually worked 35+ hours/week last year"

* NILF if not in labor force
gen NILF=0
replace NILF=1 if empstat==31 | empstat==32 | empstat==33 | empstat==34 | empstat==35
replace ahrsworkt=0 if NILF==1

* hours0 if worked 0 hours
gen hours0=ahrsworkt==0

* interactions of fulltime, NILF, and hours0
gen NILF_fulltime=NILF*fulltime
gen hours29=ahrsworkt>=15 & ahrsworkt<=29
gen hours34=ahrsworkt>=30 & ahrsworkt<=34
gen hours39=ahrsworkt>=35 & ahrsworkt<=39
gen hours40=ahrsworkt==40
gen hours48=ahrsworkt>=41 & ahrsworkt<=48
gen hours59=ahrsworkt>=49 & ahrsworkt<=59
gen hours60=ahrsworkt>=60
gen hours0_fulltime=hours0*fulltime
gen hours29_fulltime=hours29*fulltime
gen hours34_fulltime=hours34*fulltime
gen hours39_fulltime=hours39*fulltime
gen hours40_fulltime=hours40*fulltime
gen hours48_fulltime=hours48*fulltime
gen hours59_fulltime=hours59*fulltime
gen hours60_fulltime=hours60*fulltime
drop empstat

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
drop if missing(educomp)
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
replace race=3 if race==700
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

* create variable weeks worked last year ("weeks") using calculations from years 1976-78
append using "$data_out/ASEC_1976_1978_wkslyr.dta"
gen weeks=0
sort female race X13 
by female race: replace weeks=X13[1] if wkswork2==1
sort female race X26 
by female race: replace weeks=X26[1] if wkswork2==2
sort female race X39 
by female race: replace weeks=X39[1] if wkswork2==3
sort female race X47 
by female race: replace weeks=X47[1] if wkswork2==4
sort female race X49 
by female race: replace weeks=X49[1] if wkswork2==5
sort female race X52 
by female race: replace weeks=X52[1] if wkswork2==6
drop X*
drop if year>=1976

* impute usual hours worked per week last year ("hrslyr") from 1976-78 regressions
append using "$data_out/ASEC_1976_1978_uhrsworkly.dta"
gsort female race -year
by female race: gen hrslyr = c_cons[1] + c_hours0[1]*hours0 + c_hours29[1]*hours29 + ///
	c_hours34[1]*hours34 + c_hours39[1]*hours39 + c_hours40[1]*hours40 + ///
	c_hours48[1]*hours48 + c_hours59[1]*hours59 + c_hours60[1]*hours60 + ///
	c_fulltime[1]*fulltime + c_NILF[1]*NILF + c_hours0_fulltime[1]*hours0_fulltime + ///
	c_hours29_fulltime[1]*hours29_fulltime + c_hours34_fulltime[1]*hours34_fulltime + ///
	c_hours39_fulltime[1]*hours39_fulltime + c_hours40_fulltime[1]*hours40_fulltime + ///
	c_hours48_fulltime[1]*hours48_fulltime + c_hours59_fulltime[1]*hours59_fulltime + ///
	c_hours60_fulltime[1]*hours60_fulltime + c_NILF_fulltime[1]*NILF_fulltime
drop if year>=1976
drop hours* NILF* c_*
	
* create age last year (agely): age=71 for age>=71
gen agely=age-1 if age>=17 & age<=71
replace agely=71 if age>=72
drop age

* create flag if HH main industry last year is private sector
gen phh=(indly==32 & year==1962)
replace phh=1 if indly==33 & inrange(year,1964,1967)
replace phh=1 if indly==816 & inrange(year,1968,1970)
replace phh=1 if indly==769 & inrange(year,1971,1975)

* create wage-worker and self-employed variables
gen wageworker=0
replace wageworker=1 if classwly==22 | classwly==24
gen selfemp=0
replace selfemp=1 if classwly==10
keep if wageworker==1 | selfemp==1
lab var wageworker "Wage worker"
lab var selfemp "Self-employed"

* create fullyear worker variable (40-52 weeks)
gen fullyear=wkswork2>=4 & wkswork2<=6
label var fullyear "Full year workers (40-52 weeks last year)"

* define new weights
gen wgt_wks=wgt*weeks
gen wgt_hrs=wgt*weeks*hrslyr
gen wgt_hrs_ft=wgt*hrslyr
lab var wgt_wks "Weight x weeks last yr"
lab var wgt_hrs "Weight x weeks last yr x weekly hours worked"
lab var wgt_hrs_ft "Weight x hours worked per week"
	
/* CPI and GDP deflator_2000 are in 2000$. The indexes refer to the year prior to the 
CPS year. This is accounted for in the file: deflator_gdp_pce.do */
merge m:1 year using "$data_out/deflator_pce.dta", keepusing(deflator_2000) keep(matched) nogen

/*  Very important.  IPUMS CPS has specific coding for variables that are:
1) not in the universe (NIU) or 2) missing. This is not the case in AKK's source files. */ 

* not in universe
foreach var of varlist incwage inctot incbus incfarm inclongj {
	replace `var'=. if `var'==99999999	
}
* missing
foreach var of varlist incbus incfarm inctot {
	replace `var'=. if `var'==99999998 & year>=1962 & year<=1964
}
replace incwage=. if incwage==99999998 & year>=1962 & year<=1966
replace ahrsworkt=. if ahrsworkt==999

* top codes and restrictions
replace incbus=incbus*1.5 if incbus==90000 & year>=1962 & year<=1964 
replace incfarm=incfarm*1.5 if incfarm==90000 & year>=1962 & year<=1964 
replace incwage=incwage*1.5 if incwage==90000 & year>=1962 & year<=1964 

replace incbus=incbus*1.5 if incbus==99900 & year>=1965 & year<=1967 
replace incfarm=incfarm*1.5 if incfarm==99900 & year>=1965 & year<=1967 
replace incwage=incwage*1.5 if incwage==99900 & year>=1965 & year<=1967 

replace incbus=incbus*1.5 if incbus==50000 & year>=1968 & year<=1981 
replace incfarm=incfarm*1.5 if incfarm==50000 & year>=1968 & year<=1981 
replace incwage=incwage*1.5 if incwage==50000 & year>=1968 & year<=1981 

replace incbus=incbus*1.5 if incbus==75000 & year>=1982 & year<=1984 
replace incfarm=incfarm*1.5 if incfarm==75000 & year>=1982 & year<=1984 
replace incwage=incwage*1.5 if incwage==75000 & year>=1982 & year<=1984 

replace incbus=incbus*1.5 if incbus==99999 & year>=1985 & year<=1987 
replace incfarm=incfarm*1.5 if incfarm==99999 & year>=1985 & year<=1987 
replace incwage=incwage*1.5 if incwage==99999 & year>=1985 & year<=1987 

gen tcwkwg=0 
replace tcwkwg=1 if (incwage/weeks)>(99900*1.5/40) & year>=1962 & year<=1967 
replace tcwkwg=1 if (incwage/weeks)>(50000*1.5/40) & year>=1968 & year<=1981 
replace tcwkwg=1 if (incwage/weeks)>(75000*1.5/40) & year>=1982 & year<=1984 
replace tcwkwg=1 if (incwage/weeks)>(99999*1.5/40) & year>=1985 & year<=1987 

gen tchrwg=0 
replace tchrwg=1 if (incwage/(weeks*hrslyr))>(99900*1.5/1400) & year>=1962 & year<=1967
replace tchrwg=1 if (incwage/(weeks*hrslyr))>(50000*1.5/1400) & year>=1968 & year<=1981
replace tchrwg=1 if (incwage/(weeks*hrslyr))>(75000*1.5/1400) & year>=1982 & year<=1984
replace tchrwg=1 if (incwage/(weeks*hrslyr))>(99999*1.5/1400) & year>=1985 & year<=1987

/* create consistent wage measures:
1) flag those who earn below $1/hr using PCE deflator_2000
2) flag their hourly AND weekly wage since both implictly depend on $1 per hour */

gen winc_ws=incwage/weeks if wageworker==1 & incwage>0 
label var winc_ws "Weekly wage" 

gen hinc_ws=winc_ws/hrslyr if wageworker==1 & incwage>0 
label var hinc_ws "Hourly wage" 

gen bcwkwg=(winc_ws*deflator_2000)<(40*(100/49.378))
label var bcwkwg "wkwage<$40/wk in 1982$, using GDP PCE deflator_2000" 

gen bchrwg=(winc_ws*deflator_2000/hrslyr)<(1*(100/49.378))
label var bchrwg "hrwage<$1/hr in 1982$, using GDP PCE deflator_2000" 

gen bcwkwgkm=(winc_ws*deflator_2000)<(67*(100/49.378))
label var bcwkwgkm "wkwage<$67/wk in 1982$, using GDP PCE deflator_2000" 

gen bchrwgkm=(winc_ws*deflator_2000/hrslyr)<(1.675*(100/49.378))
label var bchrwgkm "hrwage<$1.675/hr in 1982$, using GDP PCE deflator_2000" 

* windsorize final wages
replace hinc_ws=(99900*1.5/1400) if tchrwg & year>=1962 & year<=1967
replace hinc_ws=(50000*1.5/1400) if tchrwg & year>=1968 & year<=1981 & wageworker==1 & incwage>0 

* labeling variables
label var statefip "State fip"
label var wgt "ASEC weight"
label var higrade "High school grade completed"
label var inctot "Total personal income"
label var incwage "Income, wage and salary"
label var incbus "Income, non-farm business"
label var incfarm "Income, farm"
label var inclongj "Earnings from longest job"
label var studently "Attended school and worker part-time"
label var agely "Age last year"
label var phh "Household industry is private industry"
label var fulltime "Fulltime worker, 35+ hours"
label var weeks "Weeks worked last year"
label var allocated "Allocated flag"
label var uhrsworkly "Usual weekly hours, last yr"
label variable year "Year income earned" 
rename ahrsworkt hrslwk
label variable hrslwk "Hours last week"
gen weeks_lastyear=weeks
label var weeks_lastyear "Heeks worked last year"
gen hours_lastyear=hrslyr
label var hours_lastyear "Weekly hours worked last year"

* keep necessary variables
keep wgt* agely exp female year school fulltime fullyear wageworker selfemp deflator_2000 ///
	white black other inc* wkswork2 weeks uhrsworkly hrslwk phh studently higrade ///
	winc_ws hinc_ws tchrwg tcwkwg bchrwg bcwkwg bchrwgkm bcwkwgkm statefip allocated cpsidp ///
	weeks_lastyear hours_lastyear educomp

* saving 
save "$data_out/ASEC_1962_1975_cleaned.dta", replace	

* removing datasets no longer needed
rm "$data_out/ASEC_1976_1978_wkslyr.dta"
rm "$data_out/ASEC_1976_1978_hrslyr.dta"
