/*****************************************************************
PROJECT: 		IN_Rainfall, India Rainfall Insurance
				
TITLE:			SectionE8_KharifCrop_MainProduct_clean.do
			
AUTHOR: 		Seungmin Lee (seungmin.lee@yale.edu, eatorange@gmail.com)

DATE CREATED:	May 18, 2016

LAST EDITED:	May 18, 2016 by Seungmin Lee

DESCRIPTION: 	Import & clean Section E8 of 2014 follow-up survey data
	
ORGANIZATION:	0 - Preamble
				1 - Import & clean 
				X - Save and Exit
				
INPUTS: 		// Raw data 
					${followup_data}/AP Raw/SectionELabor6_1.dta
					${followup_data}/TN Raw/SectionELabor6_1.dta
					${followup_data}/UP Raw/SectionELabor6_1.dta
						
OUTPUTS: 		${builddta}/followup_2014/SectionE8_KharifCrop_MainProduct_cleaned.dta
				
NOTE:			This do-file is based on
				- "${follow_data}/Do Files/SectionELabor6_1.do"
				with additional modifications.
******************************************************************/

/****************************************************************
	SECTION 0: Preamble					 									
****************************************************************/

version 13.1

set more off
clear all
cap log close 

loc name_do SectionE8_KharifCrop_MainProduct_clean
log using "${buildlog}/`name_do'", replace


/****************************************************************
	SECTION 1: Import Raw Data				 									
****************************************************************/

// Section E8
use "${followup_data}/AP Raw/SectionELabor6_1.dta", clear
append using "${followup_data}/TN Raw/SectionELabor6_1.dta" 
append using "${followup_data}/UP Raw/SectionELabor6_1.dta" 
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

label	var 	q563_proquankha11	"Kh14 Production - Quantity"
label	var 	q563_1_prokha11unit	"Kh14 Production - Units"
label	var 	q563_1_oth_prokha11unit	"Kh14 Production - Units (Other)"
label	var 	q563_2_pasprounitkha10	"Kh14 Production - KG/Unit"
label	var 	q565_proquangiftkha11	"Kh14 Production - Given as gift/payment?"
label	var 	q566_salequakha11	"Kh14 Production - Sale Quantity"
label	var 	q566_1_salevalkha11	"Kh14 Production - Sale Value"
label	var 	q567_anifeedquankha11	"Kh14 Production - Animal Feed Qty"
label	var 	q568_homeconquakha11	"Kh14 Production - Home Consumption Qty"
label	var 	q569_invquankha11	"Kh14 Production -Inventory/further processing Qty"

/****************************************************************
	SECTION X: Save and Exit
****************************************************************/

qui compress
save "${builddta}/followup_2014/SectionE8_KharifCrop_MainProduct_cleaned.dta", replace

cap file close _all
cap log close
copy "${buildlog}/`name_do'.smcl" ///
	"${buildlog}/archive/`name_do' - `c(current_date)' - `c(username)'.smcl" ///
	, replace
exit
