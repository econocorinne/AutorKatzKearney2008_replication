******* Education and Experience coding, 1992 on *****

** Create supplemental vars for alternate educational imputations

/* Recoding Autor's "grdatn" to be consistent with IPUMS CPS "educ".
Grade						IPUMS CPS (educ)	Autor (educ)
niu or blank				1					0		
none or preschool			2					31
grades 1,2,3,4				10					32
grades 5 or 6				20					33
grades 7 or 8				30					34
grade 9						40					35
grade 10					50					36
grade 11					60					37
grade 12,no diploma			71					38
school diploma 				73					39
some college				81					40
assoc. deg. occupational	91					41
assoc. deg. academic		92					42
bachelor's degree			111					43
master's degree				123					44
professional school degree	124					45
doctorate degree			125					46  */

* men, whites
replace educomp = .32  if (race==1 & female==0 & (educ==1 | educ==2))
replace educomp = 3.19 if (race==1 & female==0 & educ ==10)
replace educomp = 7.24 if (race==1 & female==0 & (educ ==20 | educ==34))
replace educomp = 8.97 if (race==1 & female==0 & educ ==40)
replace educomp = 9.92 if (race==1 & female==0 & educ ==50)
replace educomp = 10.86 if (race==1 & female==0 & educ ==60)
replace educomp = 11.58 if (race==1 & female==0 & educ ==71)
replace educomp = 11.99 if (race==1 & female==0 & educ ==73)
replace educomp = 13.48 if (race==1 & female==0 & educ ==81)
replace educomp = 14.23 if (race==1 & female==0 & (educ ==91 | educ ==92))
replace educomp = 16.17 if (race==1 & female==0 & educ ==111)
replace educomp = 17.68 if (race==1 & female==0 & educ ==123)
replace educomp = 17.71 if (race==1 & female==0 & educ ==124)
replace educomp = 17.83 if (race==1 & female==0 & educ ==125)

* female, white
replace educomp = 0.62 if (race==1 & female==1 & (educ==1 | educ==2))
replace educomp = 3.15 if (race==1 & female==1 & educ ==10)
replace educomp = 7.23 if (race==1 & female==1 & (educ ==20 | educ==34))
replace educomp = 8.99 if (race==1 & female==1 & educ ==40)
replace educomp = 9.95 if (race==1 & female==1 & educ ==50)
replace educomp = 10.87 if (race==1 & female==1 & educ ==60)
replace educomp = 11.73 if (race==1 & female==1 & educ ==71)
replace educomp = 12.00 if (race==1 & female==1 & educ ==73)
replace educomp = 13.35 if (race==1 & female==1 & educ ==81)
replace educomp = 14.22 if (race==1 & female==1 & (educ ==91 | educ ==92))
replace educomp = 16.15 if (race==1 & female==1 & educ ==111)
replace educomp = 17.64 if (race==1 & female==1 & educ ==123)
replace educomp = 17.00 if (race==1 & female==1 & educ ==124)
replace educomp = 17.76 if (race==1 & female==1 & educ ==125)

* men, black
replace educomp = .92  if (race==2 & female==0 & (educ==1 | educ==2))
replace educomp = 3.28 if (race==2 & female==0 & educ ==10)
replace educomp = 7.04 if (race==2 & female==0 & (educ ==20 | educ==34))
replace educomp = 9.02 if (race==2 & female==0 & educ ==40)
replace educomp = 9.91 if (race==2 & female==0 & educ ==50)
replace educomp = 10.90 if (race==2 & female==0 & educ ==60)
replace educomp = 11.41 if (race==2 & female==0 & educ ==71)
replace educomp = 11.98 if (race==2 & female==0 & educ ==73)
replace educomp = 13.57 if (race==2 & female==0 & educ ==81)
replace educomp = 14.33 if (race==2 & female==0 & (educ ==91 | educ ==92))
replace educomp = 16.13 if (race==2 & female==0 & educ ==111)
replace educomp = 17.51 if (race==2 & female==0 & educ ==123)
replace educomp = 17.83 if (race==2 & female==0 & educ ==124)
replace educomp = 18.00 if (race==2 & female==0 & educ ==125)

* female, black
replace educomp = 0.00 if (race==2 & female==1 & (educ==1 | educ==2))
replace educomp = 2.90 if (race==2 & female==1 & educ ==10)
replace educomp = 7.03 if (race==2 & female==1 & (educ ==20 | educ==34))
replace educomp = 9.05 if (race==2 & female==1 & educ ==40)
replace educomp = 9.99 if (race==2 & female==1 & educ ==50)
replace educomp = 10.85 if (race==2 & female==1 & educ ==60)
replace educomp = 11.64 if (race==2 & female==1 & educ ==71)
replace educomp = 12.00 if (race==2 & female==1 & educ ==73)
replace educomp = 13.43 if (race==2 & female==1 & educ ==81)
replace educomp = 14.33 if (race==2 & female==1 & (educ ==91 | educ ==92))
replace educomp = 16.04 if (race==2 & female==1 & educ ==111)
replace educomp = 17.69 if (race==2 & female==1 & educ ==123)
replace educomp = 17.40 if (race==2 & female==1 & educ ==124)
replace educomp = 18.00 if (race==2 & female==1 & educ ==125)

* men, other
replace educomp = .62  if (race==3 & female==0 & (educ==1 | educ==2))
replace educomp = 3.24 if (race==3 & female==0 & educ ==10)
replace educomp = 7.14 if (race==3 & female==0 & (educ ==20 | educ==34))
replace educomp = 9.00 if (race==3 & female==0 & educ ==40)
replace educomp = 9.92 if (race==3 & female==0 & educ ==50)
replace educomp = 10.88 if (race==3 & female==0 & educ ==60)
replace educomp = 11.50 if (race==3 & female==0 & educ ==71)
replace educomp = 11.99 if (race==3 & female==0 & educ ==73)
replace educomp = 13.53 if (race==3 & female==0 & educ ==81)
replace educomp = 14.28 if (race==3 & female==0 & (educ ==91 | educ ==92))
replace educomp = 16.15 if (race==3 & female==0 & educ ==111)
replace educomp = 17.60 if (race==3 & female==0 & educ ==123)
replace educomp = 17.77 if (race==3 & female==0 & educ ==124)
replace educomp = 17.92 if (race==3 & female==0 & educ ==125)

* female, other
replace educomp = 0.31 if (race==3 & female==1 & (educ==1 | educ==2))
replace educomp = 3.03 if (race==3 & female==1 & educ ==10)
replace educomp = 7.13 if (race==3 & female==1 & (educ ==20 | educ==34))
replace educomp = 9.02 if (race==3 & female==1 & educ ==40)
replace educomp = 9.97 if (race==3 & female==1 & educ ==50)
replace educomp = 10.86 if (race==3 & female==1 & educ ==60)
replace educomp = 11.69 if (race==3 & female==1 & educ ==71)
replace educomp = 12.00 if (race==3 & female==1 & educ ==73)
replace educomp = 13.47 if (race==3 & female==1 & educ ==81)
replace educomp = 14.28 if (race==3 & female==1 & (educ ==91 | educ ==92))
replace educomp = 16.10 if (race==3 & female==1 & educ ==111)
replace educomp = 17.67 if (race==3 & female==1 & educ ==123)
replace educomp = 17.20 if (race==3 & female==1 & educ ==124)
replace educomp = 17.88 if (race==3 & female==1 & educ ==125)
gen exp=max(min(age-educomp-7,age-17),0)
