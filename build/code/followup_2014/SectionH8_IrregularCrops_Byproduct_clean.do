/*****************************************************************
PROJECT: 		IN_Rainfall, India Rainfall Insurance
				
TITLE:			SectionH8_IrregularCrops_Byproduct_clean.do
			
AUTHOR: 		Seungmin Lee (seungmin.lee@yale.edu, eatorange@gmail.com)

DATE CREATED:	May 22, 2016

LAST EDITED:	May 22, 2016 by Seungmin Lee

DESCRIPTION: 	Import & clean Section H8 of 2014 follow-up survey data
	
ORGANIZATION:	0 - Preamble
				1 - Import & clean
				X - Save and Exit
				
INPUTS: 		// Raw data 
					// Section H7
						${followup_data}/AP Raw/SectionH4byproduct_1.dta
						${followup_data}/TN Raw/SectionH4byproduct_1.dta 
						${followup_data}/UP Raw/SectionH4byproduct_1.dta" 
											
OUTPUTS: 		${builddta}/followup_2014/SectionH8_IrregularCrops_Byproduct_cleaned.dta
				
NOTE:			This do-file is based on
				- "${follow_data}/Do Files/SectionH4byproduct_1.do"
				with additional modifications.
******************************************************************/

/****************************************************************
	SECTION 0: Preamble					 									
****************************************************************/

version 13.1

set more off
clear all
cap log close 

loc name_do SectionH8_IrregularCrops_Byproduct_clean
log using "${buildlog}/`name_do'", replace


/****************************************************************
	SECTION 1: Import Raw Data				 									
****************************************************************/

// Section H8
use "${followup_data}/AP Raw/SectionH4byproduct_1.dta", clear
append using "${followup_data}/TN Raw/SectionH4byproduct_1.dta" 
append using "${followup_data}/UP Raw/SectionH4byproduct_1.dta" 
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

label var q757_byprodcode "By Product Code"
label define byproduct 204 "Rice Straw/Fodder"       205 "Wheat Straw"        206 "OTHER byproducts"        207 "Plantain leaves"    	  208 "Arecanut leaves"           209 "Coconut leaves" 
label value q757_byprodcode byproduct
label var q757_byprodcode_oth "Other By product"
label var q758_prodquanirr11 "Quantity Produced"
label var q758_1_byprodunitirr11 "Unit"
label var q758_1_byprodunit11oth "Other-Unit"
label var q758_2_proirrbypro11kgsun "Kg/Unit"
label var q760_byprodgiftquan11 "Qty given as gift"
label var q761_byprodsalequan11 "Sale in last 12 months - Qty"
label var q761_1_byprodsaleval11 "Sale in last 12 months - Value"
label var q762_byprodanifeed11 "Qty kept for animal feed"
label var q763_byprodhomecons11 "Qty kept for home consumption"
label var q764_byprodinve11 "Qty for Inventory and Further Processing"
label var q759_byproquanirr10 "Production in 2013"


/****************************************************************
	SECTION X: Save and Exit
****************************************************************/

qui compress
save "${builddta}/followup_2014/SectionH8_IrregularCrops_Byproduct_cleaned.dta", replace

cap file close _all
cap log close
copy "${buildlog}/`name_do'.smcl" ///
	"${buildlog}/archive/`name_do' - `c(current_date)' - `c(username)'.smcl" ///
	, replace
exit
