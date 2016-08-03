/*****************************************************************
PROJECT: 		IN_Rainfall, India Rainfall Insurance
				
TITLE:			SectionJ1_Asset_part1_clean.do
			
AUTHOR: 		Seungmin Lee (seungmin.lee@yale.edu, eatorange@gmail.com)

DATE CREATED:	May 22, 2016

LAST EDITED:	May 22, 2016 by Seungmin Lee

DESCRIPTION: 	Import & clean Section J1 of 2014 follow-up survey data
	
ORGANIZATION:	0 - Preamble
				1 - Import & clean 
				X - Save and Exit
				
INPUTS: 		// Raw data 
					${builddta}/followup_2014/MasterData_cleaned.dta
						
OUTPUTS: 		${builddta}/followup_2014/SectionJ1_Asset_part1_cleaned.dta
				
NOTE:			
******************************************************************/

/****************************************************************
	SECTION 0: Preamble					 									
****************************************************************/

version 13.1

set more off
clear all
cap log close 

loc name_do SectionJ1_Asset_part1_clean
log using "${buildlog}/`name_do'", replace


/****************************************************************
	SECTION 1: Import Raw Data				 									
****************************************************************/


// Master Data
use "${builddta}/followup_2014/MasterData_cleaned.dta", clear

/// Keep ID and Section J1
keep Id q910_ownasskha11_1-q921_1_areaunit_5
order *, alphabetic
order q921_1_area_4 q921_1_area_5 q921_1_areaunit_4 q921_1_areaunit_5, after(q921_totfamdaylabkha11_5)

/// Correct erros
destring *, replace
ds, has(type string)
local str_var `r(varlist)'
foreach var of local str_var {
	qui replace `var'="" if (`var'=="-")
}
*

/// Destring and recode variables
destring *, replace
ds, has(type numeric)
local num_var `r(varlist)'
foreach var of local num_var {
	qui replace `var'=.b if mi(`var') // Blank response (but not a valid response)
	qui recode `var' (-999=.d) (-777=.r) (-666=.n) (-333=.b) (-555=.) // -999 "Don't Know" -888 "Others" -777 "Refuse" -666 "N/A" -333 "Missing" -555 "Valid Skip"
}
*

/// Logic check
forval i=1/5{
	if inrange(`i',1,3) {
		replace q911_totvalkha11_`i'=.m if ((q910_ownasskha11_`i'==2) & !mi(q911_totvalkha11_`i'))
		replace q912_totvalnow_`i'=.m if ((q910_ownasskha11_`i'==2) & !mi(q912_totvalnow_`i'))
		replace q914_YYcons_`i'=.m if ((q910_ownasskha11_`i'==2) & !mi(q914_YYcons_`i'))
	}
	else {
		replace q921_1_area_`i'=.m if ((q910_ownasskha11_`i'==2) & !mi(q921_1_area_`i'))
		replace q921_1_areaunit_`i'=.m if ((q910_ownasskha11_`i'==2) & !mi(q921_1_areaunit_`i'))
	}
	replace q913_increntlast12mon_`i'=.m if ((q910_ownasskha11_`i'==2) & !mi(q913_increntlast12mon_`i'))
	replace q915_constmatcost_`i'=.m if ((q910_ownasskha11_`i'==2) & !mi(q915_constmatcost_`i'))
	replace q916_constotwagpayhirelab_`i'=.m if ((q910_ownasskha11_`i'==2) & !mi(q916_constotwagpayhirelab_`i'))
	replace q917_constotfamday_`i'=.m if ((q910_ownasskha11_`i'==2) & !mi(q917_constotfamday_`i'))
	replace q918_mainsinkha11_`i'=.m if ((q910_ownasskha11_`i'==2) & !mi(q918_mainsinkha11_`i'))
	replace q919_mainmatcoskha11_`i'=.m if ((q910_ownasskha11_`i'==2) & !mi(q919_mainmatcoskha11_`i'))
	replace q920_totwagepayhirelabkha_`i'=.m if ((q910_ownasskha11_`i'==2) & !mi(q920_totwagepayhirelabkha_`i'))
	replace q921_totfamdaylabkha11_`i'=.m if ((q910_ownasskha11_`i'==2) & !mi(q921_totfamdaylabkha11_`i'))
	
	// maintenance cost
	replace q919_mainmatcoskha11_`i'=.m if ((q918_mainsinkha11_`i'==2) & !mi(q919_mainmatcoskha11_`i'))
	replace q920_totwagepayhirelabkha_`i'=.m if ((q918_mainsinkha11_`i'==2) & !mi(q920_totwagepayhirelabkha_`i'))
	replace q921_totfamdaylabkha11_`i'=.m if ((q918_mainsinkha11_`i'==2) & !mi(q921_totfamdaylabkha11_`i'))

}
*

/****************************************************************
	SECTION X: Save and Exit
****************************************************************/

qui compress
save "${builddta}/followup_2014/SectionJ1_Asset_part1_cleaned.dta", replace

cap file close _all
cap log close
copy "${buildlog}/`name_do'.smcl" ///
	"${buildlog}/archive/`name_do' - `c(current_date)' - `c(username)'.smcl" ///
	, replace
exit
