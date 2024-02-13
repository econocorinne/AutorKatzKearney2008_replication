/*==============================================================================
	DESCRIPTION: housekeeping, defining directories, and do file description for
	March ASEC CPS data portion of replication of Autor, Katz, Kearney (2008)
	
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

** 2_CPS_1976_1978
This do file cleans CPS ASEC data from 1976-1978. Earlier years (1962-1975) do not 
have data on usual hours worked per week last year ("uhrsworkly" in IPUMS). 
Hence predicted hours by group are imputed in 1962-1975 using data from 1976-1978.

** 3_CPS_1962_1975
This do file cleans CPS ASEC data from 1962-1975. It imputes usual hours using 
predicted hours from previous do file "2_CPS_1976_1978". 

** 4_CPS_1979_1987
This do file cleans CPS ASEC data from 1979-1987.

** 5_CPS_1988_1991
This do file cleans CPS ASEC data from 1988-1991.

** 6_CPS_1992_2023
This do file cleans CPS ASEC data from 1992-2023.

** 7_AppendingYears
This do file appends the cleaned years into a single file.  
There are two versions, one with the top-coded income variables multiplied by 1.5, 
and one without this top-coding. 
Resulting dataset 1: ASEC_all_cleaned_NOTOP.dta
Resulting dataset 2: ASEC_all_cleaned_TOP.dta

** 8_MarchCells
This do file creates earnings variables. It collapses the cleaned CPS ASEC dataset 
into year-education-experience-gender cells of weekly and hourly earnings, 
with different weighting definitions.
Input dataset: ASEC_all_cleaned_TOP.dta
Resulting dataset: MarchCells_1963_2023.dta

** 9_EfficiencyUnits
The do file calculates an average relative wage by year-education-experience-gender 
cell over the entire time period. It then calculates efficiency units by education, 
first not taking into account experience levels and then taking it into account.  
It calculates efficiency units for all individuals, and then broken down by gender. 
Input dataset: MarchCells_1963_2023.dta
Resulting dataset: Efficiency_units_1963_2023.dta

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
Input dataset: MarchCells_1963_2023.dta
Resulting dataset: March_labor_supply_weights.dta

** 12_AssembleWages
This do file merges the predicted wages with the labor supply dataset. It then 
creates a variable for the labor supply share in each cell-year. It also finds
the average labor supply share in each cell between 1963-2019. 
Input dataset: Predicted_wages.dta
Resulting dataset: Predicted_wages_1964_2023.dta

** 13_WageGaps
This do file uses the predicted wages from the previous do file to calculate the
wage gaps by education, and education-experience. 
Input dataset: Predicted_wages_1964_2023.dta
Resulting dataset: College_HS_wage_premium_exp. dta

** CPS_education_post92 
This do file is executed within the "6_CPS_1992_2023" file. It replaces values for 
"educomp" from those by Autor et al. for 1992 on. 

** Deflator_gdp_pce
This do file imports an anuual series of personal consumption expenditures from 
the BEA to construct a deflator and put earnings variables in real terms. 

	
