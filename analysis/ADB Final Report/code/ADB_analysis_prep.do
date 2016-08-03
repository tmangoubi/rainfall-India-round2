/*****************************************************************
PROJECT: 		IN_Rainfall, India Rainfall Insurance
				
TITLE:			ADB_analysis_prep.do
			
AUTHOR: 		Seungmin Lee (seungmin.lee@yale.edu)

DATE CREATED:	February 16, 2016

LAST EDITED:	February 16, 2016 by Seungmin Lee

DESCRIPTION: 	Prepares a dataset for ADB Final report analysis.
	
ORGANIZATION:	0 - Preamble
				1 - Preliminary analyses
				2 - 
				3 - Save and Exit
				
INPUTS: 		${builddta}/compiled/IN_rainfall_compiled.dta

OUTPUTS: 		${ADBdta}/analysis_prep.dta
				
NOTE:			Please make sure "IN_rainfall_globals.do" is run before running this code
******************************************************************/


/****************************************************************
	SECTION 0: Preamble					 									
****************************************************************/

version 13.1

set more off
clear all
cap log close 
set mem 500m

loc name_do ADB_analysis_prep
log using "${ADBlog}/`name_do'", replace

// Defining macros for different sample
tempfile r2r3_all r2_noattrition r3_noattrition
use "${builddta}/compiled/IN_rainfall_compiled.dta", clear
save `r2r3_all'
drop if r2_attrition==1 
save `r2_noattrition'
use `r2r3_all', clear
drop if r3_attrition==1
save `r3_noattrition'

/****************************************************************
	SECTION 1: Preliminary analyses
****************************************************************/

// Round 2
use `r2_noattrition'

// Cultivators (Those who were offered insurance randomly)
orth_out r1_treatment r2_past_insurance r2_d_migration_experience r2_distanceaws r2_c_6_landcultivated_acre r2_c_7_kharifearnings using "${ADBtab}/descriptive_stats.xls", by(r2_insurance) se pcompare stars count replace
// Landless laborors (Those who were offered migration randomly)
orth_out r1_treatment r2_past_insurance r2_d_migration_experience r2_distanceaws r2_c_5_dailywage using "${ADBtab}/descriptive_stats.xls" , by(r2_migration) se pcompare test stars count vappend


// Round 3
use `r3_noattrition'
orth_out r1_treatment r2_past_insurance r3_c_1_seasonal_mig r3_d_4awskms using "${ADBtab}/descriptive_stats.xls", by(r3_treatment) se pcompare test stars count vappend


// comparing insurance purchase in round2 b/w previously purchased group and not
orth_out r1_treatment r2_past_insurance r2_d_migration_experience r2_insurance_agreed r3_distanceaws, by(r2_past_insurance) pcompare se // test
*return list
*matrix list r(matrix)

// comparing insurnace purchase in round2 b/w who recieved payout before and who did not
use `r2_noattrition'
orth_out r2_insurance_agreed r3_insurance_agreed, by(r2_past_insurance) pcompare se stars count
orth_out r2_insurance_agreed r3_insurance_agreed, by(r2_e_5_payout) pcompare se stars count // test
orth_out r2_migration_accepted r3_c_1_seasonal_mig, by(r2_d_migration_experience) pcompare se stars count // test
orth_out r2_migration_accepted r3_c_1_seasonal_mig, by(r2_d_1_n_earnmore) pcompare se stars count // test

use `r3_noattrition'
orth_out r3_insurance_agreed, by(r3_treatment) pcompare se stars count

// comparing migration offer status in round2 b/w who migrated before and who did not


/****************************************************************
	SECTION 2: Preliminary analysis
****************************************************************/
