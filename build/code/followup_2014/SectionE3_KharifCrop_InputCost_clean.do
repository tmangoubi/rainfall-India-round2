/*****************************************************************
PROJECT: 		IN_Rainfall, India Rainfall Insurance
				
TITLE:			SectionE3_KharifCrop_InputCost_clean.do
			
AUTHOR: 		Seungmin Lee (seungmin.lee@yale.edu, eatorange@gmail.com)

DATE CREATED:	May 18, 2016

LAST EDITED:	May 18, 2016 by Seungmin Lee

DESCRIPTION: 	Import & clean Section E3 (Roster) of 2014 follow-up survey data
	
ORGANIZATION:	0 - Preamble
				1 - Import & clean 
				X - Save and Exit
				
INPUTS: 		// Raw data 
					${builddta}/followup_2014/MasterData_cleaned.dta
						
OUTPUTS: 		${builddta}/followup_2014/SectionE2_KharifCrop_Cost_cleaned.dta
				
NOTE:			
******************************************************************/

/****************************************************************
	SECTION 0: Preamble					 									
****************************************************************/

version 13.1

set more off
clear all
cap log close 

loc name_do SectionE3_KharifCrop_InputCost_clean
log using "${buildlog}/`name_do'", replace


/****************************************************************
	SECTION 1: Import Raw Data				 									
****************************************************************/


// Master Data
use "${builddta}/followup_2014/MasterData_cleaned.dta", clear

// Keep ID and E3 variables
keep Id q400_cultivate q401_decculkhar q401_decculkhar_cou q434_pestname_1-q433_plausekha12_10
order *, alphabetic
order Id q400_cultivate q401_decculkhar q401_decculkhar_cou
order q431_1_chemfertquauni_1-q431_2_chemfertval_9, after(q431_chemfertquant_9)
order q436_pestunit_1-q436_pestunit_9, before(q436_1_pestunitval_1)
order q437_usekha11_1-q437_usekha11_9, before(q437_1_planusekha12_1)
* keep if (q218_2_mwl==1) // Only those who answered "Yes" answered the rest of M2 section.

/// Label variable
label var q400_cultivate "Did your household cultivate crops during 2014 Kharif season?"
label var q401_decculkhar "Did you make decision on cultivating during 2014 Kharif season?"

label define yesno 1 "Yes" 2 "No", replace
label value q400_cultivate q401_decculkhar yesno

/// Clean errors
replace q431_2_chemfertval_6="-333" if (q431_2_chemfertval_6=="-")
replace q431_2_chemfertval_9="-333" if (q431_2_chemfertval_9=="-")

/// Destring and recode variables
destring *, replace
ds, has(type numeric)
local num_var `r(varlist)'
foreach var of local num_var {
	qui replace `var'=.b if mi(`var') // Blank response (but not a valid response)
	qui recode `var' (-999=.d) (-777=.r) (-666=.n) (-333=.b) (-555=.) // -999 "Don't Know" -888 "Others" -777 "Refuse" -666 "N/A" -333 "Missing" -555 "Valid Skip"
}
*




/****************************************************************
	SECTION X: Save and Exit
****************************************************************/

qui compress
save "${builddta}/followup_2014/SectionE3_KharifCrop_InputCost_cleaned.dta", replace

cap file close _all
cap log close
copy "${buildlog}/`name_do'.smcl" ///
	"${buildlog}/archive/`name_do' - `c(current_date)' - `c(username)'.smcl" ///
	, replace
exit
