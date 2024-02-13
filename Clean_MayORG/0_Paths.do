/*==============================================================================
	DESCRIPTION: housekeeping, defining directories, and do file description for the
	May Outgoing Rotation Group (MORG) replication of Autor, Katz, Kearney (2008)
	
	AUTHOR:	Corinne Stephenson. The subsequent do files build on publicly available 
	code used in AKK (2008) and Autor, Goldin and Katz (2020).
	
	DATE: February 2024
==============================================================================*/		

/*------------------------------------------------------------------------------
	Initial housekeeping
------------------------------------------------------------------------------*/
set more off
clear all 
set graphics on
set varabbrev off
set matsize 11000
set linesize 100
cap log close

/*------------------------------------------------------------------------------
	Setting directories
------------------------------------------------------------------------------*/
* ! Change main path here
global main "/Users/XX"

* other directories
global scripts "$main/Scripts"
global data_raw "$main/Data_Raw"
global data_out "$main/Data_Output"
global figures "$main/Figures"

/*------------------------------------------------------------------------------
	Description of do files
--------------------------------------------------------------------------------

** 0_Paths 
This do file defines directories.

** 1_Run_DoFiles
This do file runs each do file.

** 2_CPS_1973_1978
This do file cleans the May Outgoing Rotation Group for years 1973-1978. The data source is from
the NBER: nber.org/research/data/current-population-survey-cps-may-extracts-1969-1987 

** 3_MORG_1979_2020
This do file cleans the MORG data from 1979 to 2020.  The data source is from the NBER: 
https://www.nber.org/research/data/current-population-survey-cps-merged-outgoing-rotation-group-earnings-data

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
the average labor supply share in each cell between 1963-2020. 
Input dataset: Predicted_wages_MORG.dta
Resulting dataset: Predicted_wages_1979_2020_MORG.dta

** 7_WageGaps
This do file uses the predicted wages from the previous do file to calculate the
wage gaps by education, and education-experience. 
Input dataset: Predicted_wages_1979_2020_MORG.dta
Resulting dataset: College_HS_wage_premium_exp_MORG.dta

** CPS_education_post92
This do file replaces values for the experience variables ("exp" and "exp_unrounded")
with some floor values for individuals with a 10th grade education or less by age, 
regardless of gender or race. For example, 17-year olds have an experience of 0 while 
18-year olds have an experience of 1, and so on until age 99 (oldest in dataset). 

** Labeling_variables_May_CPS.do
This do file labels the variables for the MORG dataset from the NBER. 

