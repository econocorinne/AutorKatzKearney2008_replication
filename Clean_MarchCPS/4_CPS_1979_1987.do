/*==============================================================================
	DESCRIPTION: clean CPS-ASEC years 1979-1987
==============================================================================*/		

/*------------------------------------------------------------------------------
	Set paths here
------------------------------------------------------------------------------*/
do "/XX.do"

/*------------------------------------------------------------------------------
	CPS ASEC cleaning, 1979-1987
------------------------------------------------------------------------------*/
* data downloaded from IPUMS
use "$data_raw/cps_asec.dta", clear

* keep relevant years
keep if inrange(year, 1979, 1987)

* exclude armed forces (missing variables some years)
keep if popstat==1 
drop popstat

/*------------------------------------------------------------------------------
	Demographics
------------------------------------------------------------------------------*/
* keep those who were at least age 16 last year (i.e. age>=17)
keep if age>=17

* redefine age topcode to be 90 (varies by year)
replace age=90 if age>=90

* create female variable
gen female=sex==2
lab var female "Female (1:yes 0:no)"
drop sex

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

* create allocated flag
gen allocated=(qincwage>=1 & qincwage<=3)

* redefine top coding for "ahrsworkt" and "uhrsworkly" to be 98 for all years
replace ahrsworkt=98 if ahrsworkt==99
replace uhrsworkly=98 if uhrsworkly==99

/*------------------------------------------------------------------------------
	Education
------------------------------------------------------------------------------*/
* create school variable
gen school=1 if (educ<=71)
replace school=2 if (educ==72)
replace school=3 if (educ>=73 & educ<=100)
replace school=4 if (educ>=110 & educ<=121) 
replace school=5 if (educ>=122)

assert school!=.
label define school 1 "HSD" 2 "HSG" 3 "SMC" 4 "CLG" 5 "GTC"
label values school school
lab var school "Highest schooling completed (5 groups)"

* 9 schooling groups: 0-4, 5-8, 9, 10, 11, 12, 13-15, 16, 17 
gen ed0_4=(educ<=14) 
gen ed5_8=(educ>=21 & educ<=32)
gen ed9=(educ==40)
gen ed10=(educ==50)
gen ed11=(educ==60 | educ==71)
gen ed12=(educ==72)
gen ed13_15=(educ>=73 & educ<=100)
gen ed16=(educ==110)
gen ed17p=(educ>=122)

* create consistent education categories
drop if educ==999
if year<=1991 {
	gen ed8 = educ<=32
	gen edhsg = (educ==72)
	gen edsmc = (educ>=73 & educ<=100)
	gen edclg = (educ>=110 & educ<=121)
	gen edgtc = (educ>=122)
}
assert ed8+ed9+ed10+ed11+edhsg+edsmc+edclg+edgtc==1
gen edhsd = ed8+ed9+ed10+ed11

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

/*------------------------------------------------------------------------------
	Experience
------------------------------------------------------------------------------*/
* create experience variable
gen exp=max(age-educomp-7,0)
lab var exp "Experience (years)"

* create age last year (agely): age=71 for age>=71
gen agely=age-1 if age>=17 & age<=71
replace agely=71 if age>=72
drop age

* experience education interactions
gen exp1=exp
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

* create education-experience interactions
gen exphsd=exp*edhsd
gen exphsg=exp*edhsg
gen expsmc=exp*edsmc
gen expclg=exp*edclg
gen expgtc=exp*edgtc

gen expsq=exp^2
gen expsqhsd=expsq*edhsd
gen expsqhsg=expsq*edhsg
gen expsqsmc=expsq*edsmc
gen expsqclg=expsq*edclg
gen expsqgtc=expsq*edgtc

/*------------------------------------------------------------------------------
	Worker characteristics
------------------------------------------------------------------------------*/
* create flag if HH main industry last year is private sector
gen phh=0
replace phh=1 if indly==769 & inrange(year,1979,1982)
replace phh=1 if indly==761 & inrange(year,1983,1987)

* create wage-worker and self-employed variables
gen wageworker=(classwly>=22 & classwly<=28)
gen selfemp=(classwly>=13 & classwly<=14)
keep if wageworker==1 | selfemp==1
lab var wageworker "Wage worker"
lab var selfemp "Self-employed"

* create fullyear worker variable (40-52 weeks)
gen fullyear=wkswork1>=40 & wkswork1<=52
label var fullyear "Full year workers (40-52 weeks last year)"
gen fulltime=fullpart==1
label var fulltime "Fulltime worker, 35+ hours"

* part-time and full-time full-year
gen pt=!fulltime // part-time
gen ftfy=fulltime*fullyear // full-time and full-year

/*------------------------------------------------------------------------------
	Weights
------------------------------------------------------------------------------*/
* "wgt" has two unwritten decimal places; exclude negative weights
rename asecwt wgt
replace wgt=wgt/100
keep if wgt>=0 & wgt~=.

* define new weights
gen wgt_wks=wgt*wkswork1
gen wgt_hrs=wgt*wkswork1*uhrsworkly
gen wgt_hrs_ft=wgt*uhrsworkly
lab var wgt_wks "Weight x weeks last yr"
lab var wgt_hrs "Weight x weeks last yr x hours worked per week"
lab var wgt_hrs_ft "Weight x hours worked per week"

* GDP deflator corresponds to year prior to CPS year, hence subtract 1 from year before merging
replace year=year-1
merge m:1 year using "$data_out/deflator_pce.dta", keepusing(deflator*) keep(matched) nogen
replace year=year+1

/* !!  This is very important.  The IPUMS CPS has coding for missing variables and 
those not in the universe (NIU). This is not the case in AKK's source files. */ 
* not in universe
foreach var of varlist incwage inctot incbus incfarm inclongj {
	replace `var'=. if `var'==99999999	
}
replace ahrsworkt=. if ahrsworkt==999

* top codes and restrictions
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
replace tcwkwg=1 if (incwage/wkswork1)>(50000*1.5/40) & year>=1968 & year<=1981 
replace tcwkwg=1 if (incwage/wkswork1)>(75000*1.5/40) & year>=1982 & year<=1984 
replace tcwkwg=1 if (incwage/wkswork1)>(99999*1.5/40) & year>=1985 & year<=1987 

gen tchrwg=0
replace tchrwg=1 if (incwage/(wkswork1*uhrsworkly))>(50000*1.5/1400) & year>=1968 & year<=1981
replace tchrwg=1 if (incwage/(wkswork1*uhrsworkly))>(75000*1.5/1400) & year>=1982 & year<=1984
replace tchrwg=1 if (incwage/(wkswork1*uhrsworkly))>(99999*1.5/1400) & year>=1985 & year<=1987

/* create consistent wage measures:
1) flag those who earn below $1/hr using PCE deflator
2) flag their hourly AND weekly wage since both implictly depend on $1 per hour */

gen winc_ws=incwage/wkswork1 if wageworker==1 & incwage>0 
label var winc_ws "Weekly wage" 

gen hinc_ws=winc_ws/uhrsworkly if wageworker==1 & incwage>0 
label var hinc_ws "Hourly wage" 

// gen bcwkwg=(winc_ws*deflator)<(40*(100/48.439))
gen bcwkwg=(winc_ws*deflator)<(40*(100/44.771))
label var bcwkwg "wkwage<$40/wk in 1982$, using GDP PCE deflator" 

// gen bchrwg=(winc_ws*deflator/uhrsworkly)<(1*(100/48.439))
gen bchrwg=(winc_ws*deflator/uhrsworkly)<(1*(100/44.771))
label var bchrwg "hrwage<$1/hr in 1982$ following Katz-Murphy (1992), using GDP PCE deflator" 

// gen bcwkwgkm=(winc_ws*deflator)<(67*(100/48.439))
gen bcwkwgkm=(winc_ws*deflator)<(67*(100/44.771))
label var bcwkwgkm "wkwage<$67/wk in 1982$, using GDP PCE deflator" 

// gen bchrwgkm=(winc_ws*deflator/uhrsworkly)<(1.675*(100/48.439))
gen bchrwgkm=(winc_ws*deflator/uhrsworkly)<(1.675*(100/44.771))
label var bchrwgkm "hrwage<$1.675/hr in 1982$ following Katz-Murphy (1992), using GDP PCE deflator" 

* windsorize final wages
if year>=1980 & year<=1988 {
	replace hinc_ws=((50000*1.5)/1400) if tchrwg & year<=1982
}
if year>=1980 & year<=1988 {
	replace hinc_ws=((75000*1.5)/1400) if tchrwg & (year>=1983 & year<=1985)
}
if year>=1980 & year<=1988 {
	replace hinc_ws=((99999*1.5)/1400) if tchrwg & (year>=1986 & year<=1988)
}

/*------------------------------------------------------------------------------
	Real wages
------------------------------------------------------------------------------*/
gen rwinc = winc_ws*deflator
label var rwinc "Real earnings (2017$)"

gen lnrwinc=ln(rwinc)
label var lnrwinc "Log of real earnings (2017$)"

gen rhinc = hinc_ws*deflator
label var rhinc "Real hourly wage (2017$)"

gen lnrhinc=ln(hinc_ws)
label var lnrhinc "Log of real hourly wage (2017$)"

/*------------------------------------------------------------------------------
	Labeling variables
------------------------------------------------------------------------------*/
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
keep ed* wgt* agely exp* female year school fulltime fullyear wageworker selfemp deflator* ///
	white black other inc* wkswork1 uhrsworkly hrslwk phh higrade ///
	winc_ws hinc_ws tchrwg tcwkwg bchrwg bcwkwg bchrwgkm bcwkwgkm statefip allocated cpsidp ///
	weeks_lastyear hours_lastyear educomp lnr* ftfy rwinc rhinc e1* e2* e3* e4* pt

* saving 
compress
save "$data_out/ASEC_1979_1987_cleaned.dta", replace	
