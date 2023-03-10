******* Education and Experience coding, 1992 on *****

** Create supplemental vars for alternate educational imputations

* men, white
replace educomp = .32  if (white==1 & female==0 & (grade92 ==31|grade92==00) & year>=1992)
replace educomp = 3.19 if (white==1 & female==0 & grade92 ==32 & year>=1992)
replace educomp = 7.24 if (white==1 & female==0 & (grade92 ==33 | grade92==34) & year>=1992)
replace educomp = 8.97 if (white==1 & female==0 & grade92 == 35 & year>=1992)
replace educomp = 9.92 if (white==1 & female==0 & grade92 == 36 & year>=1992)
replace educomp = 10.86 if (white==1 & female==0 & grade92 ==37 & year>=1992)
replace educomp = 11.58 if (white==1 & female==0 & grade92 ==38 & year>=1992)
replace educomp = 11.99 if (white==1 & female==0 & grade92 ==39 & year>=1992)
replace educomp = 13.48 if (white==1 & female==0 & grade92 ==40 & year>=1992)
replace educomp = 14.23 if (white==1 & female==0 & (grade92 ==41 | grade92==42) & year>=1992)
replace educomp = 16.17 if (white==1 & female==0 & grade92 ==43 & year>=1992)
replace educomp = 17.68 if (white==1 & female==0 & grade92 ==44 & year>=1992)
replace educomp = 17.71 if (white==1 & female==0 & grade92 ==45 & year>=1992)
replace educomp = 17.83 if (white==1 & female==0 & grade92 ==46 & year>=1992)

* female, white
replace educomp = 0.62 if (white==1 & female==1 & (grade92 ==31|grade92==00) & year>=1992)
replace educomp = 3.15 if (white==1 & female==1 & grade92 ==32 & year>=1992)
replace educomp = 7.23 if (white==1 & female==1 & (grade92 ==33 | grade92==34) & year>=1992)
replace educomp = 8.99 if (white==1 & female==1 & grade92 == 35 & year>=1992)
replace educomp = 9.95 if (white==1 & female==1 & grade92 == 36 & year>=1992)
replace educomp = 10.87 if (white==1 & female==1 & grade92 ==37 & year>=1992)
replace educomp = 11.73 if (white==1 & female==1 & grade92 ==38 & year>=1992)
replace educomp = 12.00 if (white==1 & female==1 & grade92 ==39 & year>=1992)
replace educomp = 13.35 if (white==1 & female==1 & grade92 ==40 & year>=1992)
replace educomp = 14.22 if (white==1 & female==1 & (grade92 ==41 | grade92==42) & year>=1992)
replace educomp = 16.15 if (white==1 & female==1 & grade92 ==43 & year>=1992)
replace educomp = 17.64 if (white==1 & female==1 & grade92 ==44 & year>=1992)
replace educomp = 17.00 if (white==1 & female==1 & grade92 ==45 & year>=1992)
replace educomp = 17.76 if (white==1 & female==1 & grade92 ==46 & year>=1992)

* men, black
replace educomp = .92  if (black==1 & female==0 & (grade92 ==31|grade92==00) & year>=1992)
replace educomp = 3.28 if (black==1 & female==0 & grade92 ==32 & year>=1992)
replace educomp = 7.04 if (black==1 & female==0 & (grade92 ==33 | grade92==34) & year>=1992)
replace educomp = 9.02 if (black==1 & female==0 & grade92 == 35 & year>=1992)
replace educomp = 9.91 if (black==1 & female==0 & grade92 == 36 & year>=1992)
replace educomp = 10.90 if (black==1 & female==0 & grade92 ==37 & year>=1992)
replace educomp = 11.41 if (black==1 & female==0 & grade92 ==38 & year>=1992)
replace educomp = 11.98 if (black==1 & female==0 & grade92 ==39 & year>=1992)
replace educomp = 13.57 if (black==1 & female==0 & grade92 ==40 & year>=1992)
replace educomp = 14.33 if (black==1 & female==0 & (grade92 ==41 | grade92==42) & year>=1992)
replace educomp = 16.13 if (black==1 & female==0 & grade92 ==43 & year>=1992)
replace educomp = 17.51 if (black==1 & female==0 & grade92 ==44 & year>=1992)
replace educomp = 17.83 if (black==1 & female==0 & grade92 ==45 & year>=1992)
replace educomp = 18.00 if (black==1 & female==0 & grade92 ==46 & year>=1992)

* female, black
replace educomp = 0.00 if (black==1 & female==1 & (grade92 ==31|grade92==00) & year>=1992)
replace educomp = 2.90 if (black==1 & female==1 & grade92 ==32 & year>=1992)
replace educomp = 7.03 if (black==1 & female==1 & (grade92 ==33 | grade92==34) & year>=1992)
replace educomp = 9.05 if (black==1 & female==1 & grade92 == 35 & year>=1992)
replace educomp = 9.99 if (black==1 & female==1 & grade92 == 36 & year>=1992)
replace educomp = 10.85 if (black==1 & female==1 & grade92 ==37 & year>=1992)
replace educomp = 11.64 if (black==1 & female==1 & grade92 ==38 & year>=1992)
replace educomp = 12.00 if (black==1 & female==1 & grade92 ==39 & year>=1992)
replace educomp = 13.43 if (black==1 & female==1 & grade92 ==40 & year>=1992)
replace educomp = 14.33 if (black==1 & female==1 & (grade92 ==41 | grade92==42) & year>=1992)
replace educomp = 16.04 if (black==1 & female==1 & grade92 ==43 & year>=1992)
replace educomp = 17.69 if (black==1 & female==1 & grade92 ==44 & year>=1992)
replace educomp = 17.40 if (black==1 & female==1 & grade92 ==45 & year>=1992)
replace educomp = 18.00 if (black==1 & female==1 & grade92 ==46 & year>=1992)


** NOTE:  I am assigning the unweighted averpeage of black & white
** education levels by category to other race groups (this is done
** seperately by gender)
* men, other
replace educomp = .62  if (other==1 & female==0 & (grade92 ==31|grade92==00) & year>=1992)
replace educomp = 3.24 if (other==1 & female==0 & grade92 ==32 & year>=1992)
replace educomp = 7.14 if (other==1 & female==0 & (grade92 ==33 | grade92==34) & year>=1992)
replace educomp = 9.00 if (other==1 & female==0 & grade92 == 35 & year>=1992)
replace educomp = 9.92 if (other==1 & female==0 & grade92 == 36 & year>=1992)
replace educomp = 10.88 if (other==1 & female==0 & grade92 ==37 & year>=1992)
replace educomp = 11.50 if (other==1 & female==0 & grade92 ==38 & year>=1992)
replace educomp = 11.99 if (other==1 & female==0 & grade92 ==39 & year>=1992)
replace educomp = 13.53 if (other==1 & female==0 & grade92 ==40 & year>=1992)
replace educomp = 14.28 if (other==1 & female==0 & (grade92 ==41 | grade92==42) & year>=1992)
replace educomp = 16.15 if (other==1 & female==0 & grade92 ==43 & year>=1992)
replace educomp = 17.60 if (other==1 & female==0 & grade92 ==44 & year>=1992)
replace educomp = 17.77 if (other==1 & female==0 & grade92 ==45 & year>=1992)
replace educomp = 17.92 if (other==1 & female==0 & grade92 ==46 & year>=1992)

* female, other
replace educomp = 0.31 if (other==1 & female==1 & (grade92 ==31|grade92==00) & year>=1992)
replace educomp = 3.03 if (other==1 & female==1 & grade92 ==32 & year>=1992)
replace educomp = 7.13 if (other==1 & female==1 & (grade92 ==33 | grade92==34) & year>=1992)
replace educomp = 9.02 if (other==1 & female==1 & grade92 == 35 & year>=1992)
replace educomp = 9.97 if (other==1 & female==1 & grade92 == 36 & year>=1992)
replace educomp = 10.86 if (other==1 & female==1 & grade92 ==37 & year>=1992)
replace educomp = 11.69 if (other==1 & female==1 & grade92 ==38 & year>=1992)
replace educomp = 12.00 if (other==1 & female==1 & grade92 ==39 & year>=1992)
replace educomp = 13.47 if (other==1 & female==1 & grade92 ==40 & year>=1992)
replace educomp = 14.28 if (other==1 & female==1 & (grade92 ==41 | grade92==42) & year>=1992)
replace educomp = 16.10 if (other==1 & female==1 & grade92 ==43 & year>=1992)
replace educomp = 17.67 if (other==1 & female==1 & grade92 ==44 & year>=1992)
replace educomp = 17.20 if (other==1 & female==1 & grade92 ==45 & year>=1992)
replace educomp = 17.88 if (other==1 & female==1 & grade92 ==46 & year>=1992)
