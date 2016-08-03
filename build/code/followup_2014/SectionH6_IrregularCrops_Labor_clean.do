/*****************************************************************
PROJECT: 		IN_Rainfall, India Rainfall Insurance
				
TITLE:			SectionH6_IrregularCrops_Labor_clean.do
			
AUTHOR: 		Seungmin Lee (seungmin.lee@yale.edu, eatorange@gmail.com)

DATE CREATED:	May 22, 2016

LAST EDITED:	May 22, 2016 by Seungmin Lee

DESCRIPTION: 	Import & clean Section H6 of 2014 follow-up survey data
	
ORGANIZATION:	0 - Preamble
				1 - Import & clean
				X - Save and Exit
				
INPUTS: 		// Raw data 
					// Master data
					${builddta}/followup_2014/MasterData_cleaned.dta
											
OUTPUTS: 		${builddta}/followup_2014/SectionH6_IrregularCrops_Labor_cleaned.dta
				
NOTE:			This do-file is based on
				- "${follow_data}/Do Files/SectionH4Labor4_1.do"
				with additional modifications.
******************************************************************/

/****************************************************************
	SECTION 0: Preamble					 									
****************************************************************/

version 13.1

set more off
clear all
cap log close 

loc name_do SectionH6_IrregularCrops_Labor_clean
log using "${buildlog}/`name_do'", replace


/****************************************************************
	SECTION 1: Import Raw Data				 									
****************************************************************/

// Section H6
use "${followup_data}/AP Raw/SectionH4Labor4_1.dta", clear
append using "${followup_data}/TN Raw/SectionH4Labor4_1.dta" 
append using "${followup_data}/UP Raw/SectionH4Labor4_1.dta" 
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
// Label Variables
label var Id "Household ID"
label var subid "SubId"

label var q720_postcaslabdayM "Casual  M Threshing/Winnowing.."
label var q721_postcaslabdayF "Casual  F Threshing/Winnowing.."
label var q722_postcaslabdayC "Casual  C Threshing/Winnowing.."
label var q723_postpermlabdayM "Permanent M Threshing/Winnowing.."
label var q724_postpermlabdayF "Permanent F Threshing/Winnowing.."
label var q725_postpermlabdayc "Permanent C Threshing/Winnowing.."
label var q726_postfamlabdayM "Family M Threshing/Winnowing.."
label var q727_postfamlabdayF "Family F Threshing/Winnowing.."
label var q728_postfamlabdayC "Family C Threshing/Winnowing.."
label var q729_proccaslabdayM "Casual  M Additional Processing"
label var q730_proccaslabdayF "Casual  F Additional Processing"
label var q731_proccaslabdayc "Casual  C Additional Processing"
label var q732_procpermlabdaym "Permanent M Additional Processing"
label var q733_procpermlabdayF "Permanent F Additional Processing"
label var q734_procpermlabdayc "Permanent C Additional Processing"
label var q735_procfamlabdayM "Family M Additional Processing"
label var q736_procfamlabdayf "Family F Additional Processing"
label var q737_procfamlabdayc "Family C Additional Processing"
label var q738_markcaslabdayM "Casual  M Marketing"
label var q739_markcaslabdayF "Casual  F Marketing"
label var q740_markcaslabdayC "Casual  C Marketing"
label var q741_markpermlabdaym "Permanent M Marketing"
label var q742_markpermlabdayF "Permanent F Marketing"
label var q743_markpermlabdayC "Permanent C Marketing"
label var q744_markfamlabdayM "Family M Marketing"
label var q745_markfamlabdayF "Family F Marketing"
label var q746_markfamlabdayC "Family C Marketing"


/****************************************************************
	SECTION X: Save and Exit
****************************************************************/

qui compress
save "${builddta}/followup_2014/SectionH6_IrregularCrops_Labor_cleaned.dta", replace

cap file close _all
cap log close
copy "${buildlog}/`name_do'.smcl" ///
	"${buildlog}/archive/`name_do' - `c(current_date)' - `c(username)'.smcl" ///
	, replace
exit
