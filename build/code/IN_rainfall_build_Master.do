/*****************************************************************
PROJECT: 		IN_Rainfall, India Rainfall Insurance
				
TITLE:			IN_rainfall_build_Master.do
			
AUTHOR: 		Seungmin Lee (seungmin.lee@yale.edu)

DATE CREATED:	January 28, 2016

LAST EDITED:	January 28, 2016 by Seungmin Lee

DESCRIPTION: 	calls do-files to generate a compiled dataset acroos round2, round3 and intervention.
	
ORGANIZATION:	0 - Preamble
				1 - Call do-files
					1.1 - Round2
					1.2 - Round3
					1.3 - Intervention
					1.4 - Compile
				2 - Exit
				
INPUTS: 		<do-files>
					// Round 2
						${builddo}/round2/IN_rainfall_round2_clean_AP.do
						${builddo}/round2/IN_rainfall_round2_clean_TN.do
						${builddo}/round2/IN_rainfall_round2_clean_UP.do
						${builddo}/round2/IN_rainfall_round2_compile.do
					// Round 3
						${builddo}/round3/IN_rainfaill_round3_clean.do
						${builddo}/round3/IN_rainfaill_round3_analysis_prep.do
					// Intervention
						${builddo}/intervention/IN_rainfaill_intervention.do
					// Compile
						${builddo}/compile/IN_rainfaill_compile.do

OUTPUTS: 		${dta}/compiled/IN_rainfall_compiled.dta
				
NOTE:			Please make sure "IN_rainfall_globals.do" is run before running this code
				Please refer to each do-file to see what they do.
******************************************************************/

/****************************************************************
	SECTION 0: Preamble					 									
****************************************************************/
version 13.1

set more off
clear all

/****************************************************************
	SECTION 1: Call do-files				 									
****************************************************************/

// 1-1. Round 2

do "${builddo}/round2/IN_rainfall_round2_clean_AP.do" // AP data
do "${builddo}/round2/IN_rainfall_round2_clean_TN.do" // TN data
do "${builddo}/round2/IN_rainfall_round2_clean_UP.do" // UP data
do "${builddo}/round2/IN_rainfall_round2_compile.do" // Compile AP, TN and UP and analysis_prep

// 1-2. Round 3

do "${builddo}/round3/IN_rainfall_round3_clean.do" // Round 3 clean
do "${builddo}/round3/IN_rainfall_round3_analysis_prep.do" // Round 3 analysis_prep

// 1-3. Intervention

do "${builddo}/intervention/IN_rainfall_intervention.do" // Intervention

// 1-4. 2014 Follow-up

do "${builddo}/followup_2014/Followup_2014_build_Master.do" 

// 1-5. Admin

do "${builddo}/admin/Insur_payout_Kharif2014.do" 

// 1-6. Compile

do "${builddo}/compile/IN_rainfall_compile.do" // Compile round2,3 and intervention

/****************************************************************
	SECTION 2: Exit
****************************************************************/

exit
