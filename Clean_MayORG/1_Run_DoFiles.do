/*==============================================================================
	DESCRIPTION: run cleaning files for CPS MORG data portion of	
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
do "$scripts/Clean_MayORG/2_MayCPS_1973_1978.do"
do "$scripts/Clean_MayORG/3_MORG_1979_2020.do"
do "$scripts/Clean_MayORG/4_AppendingYears.do"
do "$scripts/Clean_MayORG/5_PredictWages.do"
do "$scripts/Clean_MayORG/6_AssembleWages.do"
do "$scripts/Clean_MayORG/7_WageGaps.do"

/*------------------------------------------------------------------------------
	Overview of data sources
------------------------------------------------------------------------------*/
/* 1) Data for the May CPS from years 1973-1978 is from the NBER: 
https://www.nber.org/research/data/current-population-survey-cps-may-extracts-1969-1987

2) Data for the May ORG from years 1979-2020 is from the NBER: 
https://www.nber.org/research/data/current-population-survey-cps-may-extracts-1969-1987 */

