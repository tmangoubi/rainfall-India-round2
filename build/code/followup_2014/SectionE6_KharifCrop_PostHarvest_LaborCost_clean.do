/*****************************************************************
PROJECT: 		IN_Rainfall, India Rainfall Insurance
				
TITLE:			SectionE6_KharifCrop_PostHarvest_LaborCost_clean.do
			
AUTHOR: 		Seungmin Lee (seungmin.lee@yale.edu, eatorange@gmail.com)

DATE CREATED:	May 18, 2016

LAST EDITED:	May 18, 2016 by Seungmin Lee

DESCRIPTION: 	Import & clean Section E6 of 2014 follow-up survey data
	
ORGANIZATION:	0 - Preamble
				1 - Import & clean 
				X - Save and Exit
				
INPUTS: 		// Raw data 
					${followup_data}/AP Raw/SectionELabor4_1.dta
					${followup_data}/TN Raw/SectionELabor4_1.dta
					${followup_data}/UP Raw/SectionELabor4_1.dta
						
OUTPUTS: 		${builddta}/followup_2014/SectionE6_KharifCrop_PostHarvest_LaborCost_cleaned.dta
				
NOTE:			This do-file is based on
				- "${follow_data}/Do Files/SectionELabor4_1.do"
				with additional modifications.
******************************************************************/

/****************************************************************
	SECTION 0: Preamble					 									
****************************************************************/

version 13.1

set more off
clear all
cap log close 

loc name_do SectionE6_KharifCrop_PostHarvest_LaborCost_clean
log using "${buildlog}/`name_do'", replace


/****************************************************************
	SECTION 1: Import Raw Data				 									
****************************************************************/

// Section E6
use "${followup_data}/AP Raw/SectionELabor4_1.dta", clear
append using "${followup_data}/TN Raw/SectionELabor4_1.dta" 
append using "${followup_data}/UP Raw/SectionELabor4_1.dta" 
isid Id subid

/// Destring and recode variables
qui destring *, replace
ds, has(type numeric)
local num_var `r(varlist)'
foreach var of local num_var {
	qui replace `var'=.b if mi(`var') // Blank response (but not a valid response)
	qui recode `var' (-999=.d) (-777=.r) (-666=.n) (-333=.b) (-555=.) // -999 "Don't Know" -888 "Others" -777 "Refuse" -666 "N/A" -333 "Missing" -555 "Valid Skip"
}
*
// Label variables
label var Id "Household ID"
label var subid "SubId"

label	var	q534_postcaslabdayM	"PostHarvest - Casual Labour Male"
label	var	q535_postcaslabdayF	"PostHarvest - Casual Labour Female"
label	var	q536_postcaslabdayC	"PostHarvest - Casual Labour Child"
label	var	q537_postpermlabdayM	"PostHarvest - Permanent Labour Male"
label	var	q538_postpermlabdayF	"PostHarvest - Permanent Labour Female"
label	var	q539_postpermlabdayc	"PostHarvest - Permanent Labour Child"
label	var	q540_postfamlabdayM	"PostHarvest - Family Labour Male"
label	var	q541_postfamlabdayF	"PostHarvest - Family Labour Female"
label	var	q542_postfamlabdayC	"PostHarvest - Family Labour Child"
label	var	q543_proccaslabdayM	"AddProcess - Casual Labour Male"
label	var	q544_proccaslabdayF	"AddProcess - Casual Labour Female"
label	var	q545_proccaslabdayc	"AddProcess - Casual Labour Child"
label	var	q546_procpermlabdaym	"AddProcess - Permanent Labour Male"
label	var	q547_procpermlabdayF	"AddProcess - Permanent Labour Female"
label	var	q548_procpermlabdayc	"AddProcess - Permanent Labour Child"
label	var	q549_procfamlabdayM	"AddProcess - Family Labour Male"
label	var	q550_procfamlabdayf	"AddProcess - Family Labour Female"
label	var	q551_procfamlabdayc	"AddProcess - Family Labour Child"
label	var	q552_markcaslabdayM	"Marketing - Casual Labour Male"
label	var	q553_markcaslabdayF	"Marketing - Casual Labour Female"
label	var	q554_markcaslabdayC	"Marketing - Casual Labour Child"
label	var	q555_markpermlabdaym	"Marketing - Permanent Labour Male"
label	var	q556_markpermlabdayF	"Marketing - Permanent Labour Female"
label	var	q557_markpermlabdayC	"Marketing - Permanent Labour Child"
label	var	q558_markfamlabdayM	"Marketing - Family Labour Male"
label	var	q559_markfamlabdayF	"Marketing - Family Labour Female"
label	var	q560_markfamlabdayC	"Marketing - Family Labour Child"

/****************************************************************
	SECTION X: Save and Exit
****************************************************************/

qui compress
save "${builddta}/followup_2014/SectionE6_KharifCrop_PostHarvest_LaborCost_cleaned.dta", replace

cap file close _all
cap log close
copy "${buildlog}/`name_do'.smcl" ///
	"${buildlog}/archive/`name_do' - `c(current_date)' - `c(username)'.smcl" ///
	, replace
exit
