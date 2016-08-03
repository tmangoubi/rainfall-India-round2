/*****************************************************************
PROJECT: 		IN_Rainfall, India Rainfall Insurance
				
TITLE:			SectionE9_KharifCrop_ByProduct_clean.do
			
AUTHOR: 		Seungmin Lee (seungmin.lee@yale.edu, eatorange@gmail.com)

DATE CREATED:	May 18, 2016

LAST EDITED:	May 18, 2016 by Seungmin Lee

DESCRIPTION: 	Import & clean Section E9 of 2014 follow-up survey data
	
ORGANIZATION:	0 - Preamble
				1 - Import & clean 
				X - Save and Exit
				
INPUTS: 		// Raw data 
					${followup_data}/AP Raw/SectionELabor7_1.dta
					${followup_data}/TN Raw/SectionELabor7_1.dta
					${followup_data}/UP Raw/SectionELabor7_1.dta
						
OUTPUTS: 		${builddta}/followup_2014/SectionE9_KharifCrop_ByProduct_cleaned.dta
				
NOTE:			This do-file is based on
				- "${follow_data}/Do Files/SectionELabor7_1.do"
				with additional modifications.
******************************************************************/

/****************************************************************
	SECTION 0: Preamble					 									
****************************************************************/

version 13.1

set more off
clear all
cap log close 

loc name_do SectionE9_KharifCrop_ByProduct_clean
log using "${buildlog}/`name_do'", replace


/****************************************************************
	SECTION 1: Import Raw Data				 									
****************************************************************/

// Section E8
use "${followup_data}/AP Raw/SectionELabor7_1.dta", clear
append using "${followup_data}/TN Raw/SectionELabor7_1.dta" 
append using "${followup_data}/UP Raw/SectionELabor7_1.dta" 
isid Id subid
order Id subid

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

label var q571_byprodcode "ByProduct Code"
label var q571_byprodcode_oth "ByProduct Code - Other"
label define byprod 204 "Rice Straw/Fodder" 205 "Wheat Straw" 206 "OTHER byproducts" 207 "Plantain leaves" 208 "Arecanut leaves" 209 "Coconut leaves" -888 "Others"

label	var 	q572_prodquankha11	"Kh14 ByProduct - Quantity"
label	var 	q572_1_byprodunitkha11	"Kh14 ByProduct - Units"
label	var 	q572_1_byprodunit11oth	"Kh14 ByProduct - Units (Other)"
label	var 	q572_2_byprodunitkgs	"Kh14 ByProduct - KG/Unit"
label   var     q573_byproquankha10     "Kh13 - ByProduct Qty"
label	var 	q574_byprodgiftquan11	"Kh14 ByProduct - Given as gift/payment?"
label	var 	q575_byprodsalequan11	"Kh14 ByProduct - Sale Quantity"
label	var 	q575_1_byprodsaleval11	"Kh14 ByProduct - Sale Value"
label	var 	q576_byprodanifeed11	"Kh14 ByProduct - Animal Feed Qty"
label	var 	q577_byprodhomecons11	"Kh14 ByProduct - Home Consumption Qty"
label	var 	q578_byprodinve11	"Kh14 ByProduct -Inventory/further processing Qty"

/****************************************************************
	SECTION X: Save and Exit
****************************************************************/

qui compress
save "${builddta}/followup_2014/SectionE9_KharifCrop_ByProduct_cleaned.dta", replace

cap file close _all
cap log close
copy "${buildlog}/`name_do'.smcl" ///
	"${buildlog}/archive/`name_do' - `c(current_date)' - `c(username)'.smcl" ///
	, replace
exit
