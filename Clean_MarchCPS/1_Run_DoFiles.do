/*==============================================================================
	File to run do files
==============================================================================*/		
cap log close 
clear all 
set more off

** Set paths here
run "SET/PATH/HERE"

/*------------------------------------------------------------------------------
	Execute do files
------------------------------------------------------------------------------*/

do "$scripts/Clean_MarchCPS/2_CPS_1976_1978.do"
do "$scripts/Clean_MarchCPS/3_CPS_1962_1975.do"
do "$scripts/Clean_MarchCPS/4_CPS_1979_1987.do"
do "$scripts/Clean_MarchCPS/5_CPS_1988_1991.do"
do "$scripts/Clean_MarchCPS/6_CPS_1992_2020.do"
do "$scripts/Clean_MarchCPS/7_AppendingYears.do"
do "$scripts/Clean_MarchCPS/8_MarchCells.do"
do "$scripts/Clean_MarchCPS/9_EfficiencyUnits.do"
do "$scripts/Clean_MarchCPS/9_EfficiencyUnits.do"
do "$scripts/Clean_MarchCPS/9_EfficiencyUnits.do"
do "$scripts/Clean_MarchCPS/9_EfficiencyUnits.do"
do "$scripts/Clean_MarchCPS/9_EfficiencyUnits.do"

/*------------------------------------------------------------------------------
	Description of do files
--------------------------------------------------------------------------------

** 0_Paths 
This do file sets the directories for all parts of the project and describes
each of the do files. 

** 1_Run_DoFiles
This do file allows the researcher to run each do file in sequence.

** 2_CPS_1976_1978
This do file cleans CPS ASEC data from 1976-1978. We start with these years because
the earlier years (1962-1975) do not have data on usual hours worked per week 
last year ("uhrsworkly" in IPUMS, which is "hrslyr" in the do file). 

** 3_CPS_1962_1975
This do file cleans CPS ASEC data from 1962-1975.

** 4_CPS_1979_1987
This do file cleans CPS ASEC data from 1979-1987.

** 5_CPS_1988_1991
This do file cleans CPS ASEC data from 1988-1991.

** 6_CPS_1992_2020
This do file cleans CPS ASEC data from 1992-2020.

** 7_AppendingYears
This do file appends all the cleaned years to create a single file.  There are
two versions, one with the top-coded income variables multiplied by 1.5, and one
without this top-coding. 
Resulting dataset 1: ASEC_all_cleaned_NOTOP.dta
Resulting dataset 2: ASEC_all_cleaned_TOP.dta

** 8_MarchCells
This do file begins by creating earnings variables.  The main purpose of the file
is to collapses the entire cleaned CPS ASEC dataset into year-education-experience-gender 
cells of weekly and hourly earnings, and different weighting specifications. 
Input dataset: ASEC_all_cleaned_TOP.dta
Resulting dataset: MarchCells_1963_2020.dta

** 9_EfficiencyUnits
The do file begins by calculating an average relative wage by year-education-experience-gender 
cell over the entire time period. It then goes on to calculate efficiency units 
by education, first not taking into account experience levels and then taking it
into account.  It calculates efficiency units for men + women, and then broken 
down by gender. 
Input dataset: MarchCells_1963_2020.dta
Resulting dataset: Efficiency_units_1963_2020.dta

** 10_PredictWages
This do file predicts weekly and hourly wages by gender for each year. It does 
so from a regression of real wages regressed on four education categories, 
three region dummies, race dummies for black and other, a quartic in experience, 
and interactions of education (3 broad groupings) with the experience quartic. 
Input dataset: ASEC_all_cleaned_NOTOP.dta
Resulting dataset: Predicted_wages.dta

** 11_LaborSupplyWeights
This do file creates labor supply weights for year-school-experience-gender cells. 
The weights are equal to the sum of ASEC weights multiplied by weeks worked last
year multiplied by usual hours worked in a week. 
Input dataset: MarchCells_1963_2020.dta
Resulting dataset: March_labor_supply_weights.dta

** 12_AssembleWages
This do file merges the predicted wages with the labor supply dataset. It then 
creates a variable for the labor supply share in each cell-year. It also finds
the average labor supply share in each cell between 1963-2019. 
Input dataset: Predicted_wages.dta
Resulting dataset: Predicted_wages_1964_2020.dta

** 13_WageGaps
This do file uses the predicted wages from the previous do file to calculate the
wage gaps by education, and education-experience. 
Input dataset: Predicted_wages_1964_2020.dta
Resulting dataset: College_HS_wage_premium_exp. dta

** CPS_education_post92 
This do file is executed within the "6_CPS_1992_2020" file. It replaces values for 
"educomp" from those by Autor et al. for 1992 on. 

** Deflator_gdp_pce
This do file imports an anuual series of personal consumption expenditures from 
the BEA to construct a deflator to put earnings variables in real terms. 
