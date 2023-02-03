/*==============================================================================
	Directories for Replication of Autor, Katz, Kearney (2008)
	Corinne Stephenson, January 2023
==============================================================================*/		
cap log close 
clear all 
set more off

/*------------------------------------------------------------------------------
	Setting Directories for Project
------------------------------------------------------------------------------*/
* ! Change main path here:
global main "SET/PATH/HERE"

* other directories used
global scripts "$main/Scripts"
global data_raw "$main/Data_Raw"
global data_out "$main/Data_Output"
global figures "$main/Figures"
	
