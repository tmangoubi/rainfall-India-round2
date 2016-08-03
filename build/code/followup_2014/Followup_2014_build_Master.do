/*****************************************************************
PROJECT: 		IN_Rainfall, India Rainfall Insurance
				
TITLE:			Followup_2014_build_Master.do
			
AUTHOR: 		Seungmin Lee (seungmin.lee@yale.edu, eatorange@gmail.com)

DATE CREATED:	April 10, 2016

LAST EDITED:	June 26, 2016 by Seungmin Lee

DESCRIPTION: 	Run all build do-files of 2014 follow-up survey.
	
ORGANIZATION:	0 - Preamble
				1 - Run do-files
				X - Exit
				
INPUTS: 		// do-files
			
					MasterData_clean
					
OUTPUTS: 		${builddta}/followup_2014/SectionG_Insurance_cleaned.dta
				
NOTE:			
******************************************************************/


/****************************************************************
	SECTION 0: Preamble					 									
****************************************************************/
version 13.1

set more off
clear all


/****************************************************************
	SECTION 1: Run do-files			 									
****************************************************************/

do "${builddo}/followup_2014/MasterData_clean.do" 
do "${builddo}/followup_2014/SectionA_HHRoster_clean.do" 
do "${builddo}/followup_2014/SectionB1_WageIncome_clean.do" 
do "${builddo}/followup_2014/SectionB2_NonAgri_WageIncome_clean.do" 
do "${builddo}/followup_2014/SectionC_OhterIncome_Kharif_clean.do" 
do "${builddo}/followup_2014/SectionD1_CultivationDetail_clean.do" 
do "${builddo}/followup_2014/SectionD2_CropDetails_clean.do" 
do "${builddo}/followup_2014/SectionE_KharifCrop_Roster_clean.do" 
do "${builddo}/followup_2014/SectionE1_KharifCrop_Sowing_clean.do" 
do "${builddo}/followup_2014/SectionE2_KharifCrop_Cost_clean.do" 
do "${builddo}/followup_2014/SectionE3_KharifCrop_InputCost_clean.do" 
do "${builddo}/followup_2014/SectionE4_E5_KharifCrop_LaborCost_clean.do" 
do "${builddo}/followup_2014/SectionE6_KharifCrop_PostHarvest_LaborCost_clean.do" 
do "${builddo}/followup_2014/SectionE7_KharifCrop_PostHarvest_LaborCost_clean.do" 
do "${builddo}/followup_2014/SectionE8_KharifCrop_MainProduct_clean.do" 
do "${builddo}/followup_2014/SectionE9_KharifCrop_ByProduct_clean.do" 
do "${builddo}/followup_2014/SectionF1_KharifCrop_NotThisYear_clean.do" 
do "${builddo}/followup_2014/SectionF2_KharifCrop_NextYear_clean.do" 
do "${builddo}/followup_2014/SectionG_Insurance_clean.do" 
do "${builddo}/followup_2014/SectionH1_IrrCrop_cropdetail_2014_clean.do" 
do "${builddo}/followup_2014/SectionH2_IrregularCrops_Costs_clean.do" 
do "${builddo}/followup_2014/SectionH3_H5_IrregularCrops_Costs_clean.do" 
do "${builddo}/followup_2014/SectionH6_IrregularCrops_Labor_clean.do" 
do "${builddo}/followup_2014/SectionH7_IrregularCrops_Output_clean.do" 
do "${builddo}/followup_2014/SectionH8_IrregularCrops_Accounting_clean.do" 
do "${builddo}/followup_2014/SectionH8_IrregularCrops_Byproduct_clean.do" 
do "${builddo}/followup_2014/SectionI1_Financial_Assistance_clean.do" 
do "${builddo}/followup_2014/SectionI2_Gifts_Loans_clean.do" 
do "${builddo}/followup_2014/SectionI3_Savings_Durables_clean.do" 
do "${builddo}/followup_2014/SectionJ1_Asset_part1_clean.do" 
do "${builddo}/followup_2014/SectionJ2_Asset_part2_clean.do" 
do "${builddo}/followup_2014/SectionK_Govenrment_Schemes_clean.do" 
do "${builddo}/followup_2014/SectionL_Consumption_clean.do" 
do "${builddo}/followup_2014/SectionM1_LeanPeriod_clean.do" 
do "${builddo}/followup_2014/SectionM2_Migration_LeanPeriod_clean.do" 
do "${builddo}/followup_2014/SectionM3_Migration_CropSeason_clean.do" 
do "${builddo}/followup_2014/SectionM4_MNREGA_Kharif_clean.do" 
do "${builddo}/followup_2014/SectionN_Hazards_clean.do" 
do "${builddo}/followup_2014/SectionO_Food_Security_clean.do" 
do "${builddo}/followup_2014/SectionP_SocialNetwork_clean.do" 


do "${builddo}/followup_2014/Analysis_variables_generation.do" 

/****************************************************************
	SECTION X: Exit
****************************************************************/
