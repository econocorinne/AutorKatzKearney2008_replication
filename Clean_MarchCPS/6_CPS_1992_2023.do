/*==============================================================================
	DESCRIPTION: clean CPS-ASEC years 1992-2023
==============================================================================*/		

/*------------------------------------------------------------------------------
	Set paths here
------------------------------------------------------------------------------*/
do "/XX.do"

/*------------------------------------------------------------------------------
	CPS ASEC cleaning, 1992-2023
------------------------------------------------------------------------------*/
* data downloaded from IPUMS
use "$data_raw/cps_asec.dta", clear

* keep relevant years
keep if inrange(year, 1992, 2023)

* exclude armed forces bc missing variables some years (e.g. "ahrsworkt" in 1962)
keep if popstat==1 
drop popstat

* keep if worked between 1 and 52 weeks
keep if wkswork1>=1 & wkswork1<=52

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

* create allocated flag
gen allocated=((qoincwage==1 | qinclong==1 | qinclong==3) & srcearn==1)

* redefine top coding for "ahrsworkt" and "uhrsworkly" to be 98 for all years
replace ahrsworkt=98 if ahrsworkt==99 
replace uhrsworkly=98 if uhrsworkly==99

/*------------------------------------------------------------------------------
	Education
------------------------------------------------------------------------------*/
* create school variable
drop if educ==999
gen school=1 if (educ<=60)
replace school=2 if (educ==71 | educ==72 | educ==73) 
replace school=3 if (educ>=80 & educ<=100)
replace school=4 if (educ>=110 & educ<=121) 
replace school=5 if (educ>=122)
assert school!=.
label define school 1 "HSD" 2 "HSG" 3 "SMC" 4 "CLG" 5 "GTC", replace
label values school school
lab var school "Highest schooling completed (5 groups)"

* 9 schooling groups: 0-4, 5-8, 9, 10, 11, 12, 13-15, 16, 17 
gen ed0_4=(educ<=14) 
gen ed5_8=(educ>=21 & educ<=32)
gen ed9=(educ==40)
gen ed10=(educ==50)
gen ed11=(educ==60)
gen ed12=(educ==71 | educ==73)
gen ed13_15=(educ>=81 & educ<=100)
gen ed16=(educ==111)
gen ed17p=(educ>=123)

* create consistent education categories
gen ed8=(educ<=30)
// 	replace ed9  = educ==40
// 	replace ed10 = educ==50
// 	replace ed11 = educ==60 
gen edhsg = (educ==71 | educ==73)
gen edsmc = (educ>=81 & educ<=92)
gen edclg = educ==111
gen edgtc = educ>=123
assert ed8+ed9+ed10+ed11+edhsg+edsmc+edclg+edgtc==1
gen edhsd = ed8+ed9+ed10+ed11

/** to create the 9 schooling groups used in some of the analysis, we redefine
"educomp" based on the do file below  **/
gen educomp=.
do "$scripts/Clean_MarchCPS/CPS_education_post92.do"
lab var exp "Experience (years)"

* create age last year (agely): age=71 for age>=71
gen agely=age-1 if age>=17 & age<=71
replace agely=71 if age>=72
drop age


/*------------------------------------------------------------------------------
	Experience
------------------------------------------------------------------------------*/
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
gen phh=(indly==761)

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
replace wgt=wgt/2 if year==2014

* define new weights
gen wgt_wks=wgt*wkswork1
gen wgt_hrs=wgt*wkswork1*uhrsworkly
gen wgt_hrs_ft=wgt*uhrsworkly
lab var wgt_wks "Weight x weeks lasts yr"
lab var wgt_hrs "Weight x weeks last yr x hours worked per week"
lab var wgt_hrs_ft "Weight x hours worked per week"

* GDP deflator corresponds to year prior to CPS year, hence subtract 1 from year before merging
replace year=year-1
merge m:1 year using "$data_out/deflator_pce.dta", keepusing(deflator) keep(matched) nogen
replace year=year+1

/* !!  This is very important.  The IPUMS CPS has coding for missing variables and 
those not in the universe (NIU). This is not the case in AKK's source files. */ 
* not in universe
foreach var of varlist incwage inctot incbus incfarm inclongj oincwage {
	replace `var'=. if `var'==99999999	
}
replace ahrsworkt=. if ahrsworkt==999

/* create consistent wage measures:
1) flag those who earn below $1/hr using PCE deflator
2) flag their hourly AND weekly wage since both implictly depend on $1 per hour */

gen winc_ws=(inclongj+oincwage)/wkswork1 if wageworker==1 & (inclongj+oincwage)>0 
label var winc_ws "Weekly wage" 

gen hinc_ws=winc_ws/uhrsworkly if wageworker==1 & (inclongj+oincwage)>0 
label var hinc_ws "Hourly wage" 

gen bcwkwg=(winc_ws*deflator)<(40*(100/44.771))
label var bcwkwg "wkwage<$40/wk in 1982$, using GDP PCE deflator 2017" 

gen bchrwg=(winc_ws*deflator/uhrsworkly)<(1*(100/44.771))
label var bchrwg "hrwage<$1/hr in 1982$, using GDP PCE deflator 2017"

gen bcwkwgkm=(winc_ws*deflator)<(67*(100/44.771))
label var bcwkwgkm "wkwage<$67/wk in 1982$, using GDP PCE deflator 2017"

gen bchrwgkm=(winc_ws*deflator/uhrsworkly)<(1.675*(100/44.771))
label var bchrwgkm "hrwage<$1.675/hr in 1982$, using GDP PCE deflator 2017"

/*------------------------------------------------------------------------------
	Real wages -- not top coded
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
label var weeks_lastyear "Weeks worked last year"
gen hours_lastyear=uhrsworkly
label var hours_lastyear "Weekly hours worked last year"

* saving 
save "$data_out/ASEC_1992_2023_cleaned_notop.dta", replace	// this version is for Figure 1

/*------------------------------------------------------------------------------
	Top coding
------------------------------------------------------------------------------*/
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
if year== 2016 {
	scalar MAXER = 300000 
	}
if year== 2017 {
	scalar MAXER = 300000 
	}
if year== 2018 {
	scalar MAXER = 300000 
	}
if year== 2019 {
	scalar MAXER = 310000 
	}
if year== 2020 {
	scalar MAXER = 360000 
	}
if year== 2021 {
	scalar MAXER = 350000 
	}
if year== 2022 {
	scalar MAXER = 400000 
	}
if year== 2023 {
	scalar MAXER = 400000 
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
	scalar MAXWG = 60000
	}
if year== 2020 {
	scalar MAXWG = 70000 
	}
if year== 2021 {
	scalar MAXWG = 65000 
	}
if year== 2022 {
	scalar MAXWG = 75000 
	}
if year== 2023 {
	scalar MAXWG = 83991
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
1) flag those who earn below $1/hr using PCE deflator
2) flag their hourly AND weekly wage since both implictly depend on $1 per hour */

replace winc_ws=(inclongj+oincwage)/wkswork1 if wageworker==1 & (inclongj+oincwage)>0 
label var winc_ws "Weekly wage" 

replace hinc_ws=winc_ws/uhrsworkly if wageworker==1 & (inclongj+oincwage)>0 
label var hinc_ws "Hourly wage" 

// replace bcwkwg=(winc_ws*deflator)<(40*(100/48.439))
replace bcwkwg=(winc_ws*deflator)<(40*(100/44.771))
label var bcwkwg "wkwage<$40/wk in 1982$, using GDP PCE deflator"

// replace bchrwg=(winc_ws*deflator/uhrsworkly)<(1*(100/48.439))
replace bchrwg=(winc_ws*deflator/uhrsworkly)<(1*(100/44.771))
label var bchrwg "hrwage<$1/hr in 1982$, using GDP PCE deflator"

// replace bcwkwgkm=(winc_ws*deflator)<(67*(100/48.439))
replace bcwkwgkm=(winc_ws*deflator)<(67*(100/44.771))
label var bcwkwgkm "wkwage<$67/wk in 1982$, using GDP PCE deflator"

// replace bchrwgkm=(winc_ws*deflator/uhrsworkly)<(1.675*(100/48.439))
replace bchrwgkm=(winc_ws*deflator/uhrsworkly)<(1.675*(100/44.771))
label var bchrwgkm "hrwage<$1.675/hr in 1982$, using GDP PCE deflator"

/*------------------------------------------------------------------------------
	Real wages -- after top coding
------------------------------------------------------------------------------*/
replace rwinc=winc_ws*deflator
label var rwinc "Real earnings (2017$)"

replace lnrwinc=ln(rwinc)
label var lnrwinc "Log of real earnings (2017$)"

replace rhinc=hinc_ws*deflator
label var rhinc "Real hourly wage (2017$)"

replace lnrhinc=ln(hinc_ws)
label var lnrhinc "Log of real hourly wage (2017$)"

* keep necessary variables
keep ed* wgt* agely exp* female year school fulltime fullyear wageworker selfemp deflator* ///
	white black other inc* wkswork1 uhrsworkly hrslwk phh higrade classwly ///
	winc_ws hinc_ws bchrwg bcwkwg bchrwgkm bcwkwgkm statefip allocated cpsidp ///
	weeks_lastyear hours_lastyear lnr* ftfy rwinc rhinc e1* e2* e3* e4* pt
	
* saving 
compress
save "$data_out/ASEC_1992_2023_cleaned_top.dta", replace	

