/*==============================================================================
	DESCRIPTION: run cleaning files for March ASEC CPS data portion of	
	replication of Autor, Katz, Kearney (2008)
	
	DATE: February 2024
==============================================================================*/		

/*------------------------------------------------------------------------------
	Set paths here
------------------------------------------------------------------------------*/
do "/XX.do"

/*------------------------------------------------------------------------------
	Execute do files
------------------------------------------------------------------------------*/
do "$scripts/Clean_MarchCPS/Deflator_gdp_pce.do"
do "$scripts/Clean_MarchCPS/2_CPS_1976_1978.do"
do "$scripts/Clean_MarchCPS/3_CPS_1962_1975.do"
do "$scripts/Clean_MarchCPS/4_CPS_1979_1987.do"
do "$scripts/Clean_MarchCPS/5_CPS_1988_1991.do"
do "$scripts/Clean_MarchCPS/6_CPS_1992_2023.do"
do "$scripts/Clean_MarchCPS/7_AppendingYears.do"
do "$scripts/Clean_MarchCPS/8_MarchCells.do"
do "$scripts/Clean_MarchCPS/9_EfficiencyUnits.do"
do "$scripts/Clean_MarchCPS/10_PredictWages.do"
do "$scripts/Clean_MarchCPS/11_LaborSupplyWeights.do"
do "$scripts/Clean_MarchCPS/12_AssembleWages.do"
do "$scripts/Clean_MarchCPS/13_WageGaps.do"

