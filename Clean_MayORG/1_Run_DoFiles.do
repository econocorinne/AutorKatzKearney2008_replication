/*==============================================================================
	File to run do files
==============================================================================*/		
cap log close 
clear all 
set more off

** Set paths here
run "SET/PATHS/HERE"

/* Note: The subsequent do files build on code publicly available that is used
in AKK (2008) and Autor, Goldin and Katz (2020). */

/*------------------------------------------------------------------------------
	Execute do files
------------------------------------------------------------------------------*/

do "$scripts/Clean_MayORG/2_MORG_1979_2020.do"
do "$scripts/Clean_MayORG/3_CPS_1973_1978.do"
do "$scripts/Clean_MayORG/4_AppendingYears.do"
do "$scripts/Clean_MayORG/5_PredictWages.do"
do "$scripts/Clean_MayORG/6_AssembleWages.do"
do "$scripts/Clean_MayORG/7_WageGaps.do"

/*------------------------------------------------------------------------------
	Description of do files
--------------------------------------------------------------------------------

** 2_MORG_1979_2020
This do file cleans the CPS Merged Outgoing Rotation Group (MORG) data from 
1979 to 2020.  There are two sources of the MORG data, hence two separate
cleaning files. These years are from IPUMS CPS (data.nber.org/morg/annual). 
While the measure of real weekly wages comes from the March CPS ASEC, the 
measure of real hourly wages is from the MORG. 

** 3_CPS_1973_1978
This do file similarly cleans the MORG for years 1973-1978. The data source is from
the NBER (nber.org/research/data/current-population-survey-cps-may-extracts-1969-1987). 

** 4_AppendingYears
The do file appends the cleaned datasets together. 
Resulting dataset: MayCPS_MORG_cleaned.dta

** 5_PredictWages
This dataset predicts hourly wages by gender for each year.
It does so from a regression of real wages regressed on four education categories, 
race dummies for black and other, a quartic in experience, and interactions of 
education (3 broad groupings) with the experience quartic. 
Input dataset: MayCPS_MORG_cleaned.dta
Resulting dataset: Predicted_wages_MORG.dta

** 6_AssembleWages
This do file merges the predicted hourly wages with the labor supply dataset. It then 
creates a variable for the labor supply share in each cell-year. It also finds
the average labor supply share in each cell between 1963-2019. 
Input dataset: Predicted_wages_MORG.dta
Resulting dataset: Predicted_wages_1979_2020_MORG.dta

** 7_WageGaps
This do file uses the predicted wages from the previous do file to calculate the
wage gaps by education, and education-experience. 
Input dataset: Predicted_wages_1979_2020_MORG.dta
Resulting dataset: College_HS_wage_premium_exp_MORG.dta

** CPS_education_post92
This do file is executed within "2_CPS_ASEC_Cleaning". It replaces values for 
the experience variables ("exp" and "exp_unrounded") with some floor values for
individuals with a 10th grade education or less by age, regardless of gender or race. 
For example, 17-year olds have an experience of 0 while 18-year olds have an 
experience of 1, and so on until age 99 (oldest in dataset). 

** Labeling_variables_May_CPS.do
This do file labels the variables for the MORG dataset from the NBER. 

