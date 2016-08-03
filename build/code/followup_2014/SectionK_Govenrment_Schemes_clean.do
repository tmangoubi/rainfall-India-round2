/*****************************************************************
PROJECT: 		IN_Rainfall, India Rainfall Insurance
				
TITLE:			SectionK_Govenrment_Schemes_clean.do
			
AUTHOR: 		Seungmin Lee (seungmin.lee@yale.edu, eatorange@gmail.com)

DATE CREATED:	May 22, 2016

LAST EDITED:	May 22, 2016 by Seungmin Lee

DESCRIPTION: 	Import & clean Section J1 of 2014 follow-up survey data
	
ORGANIZATION:	0 - Preamble
				1 - Import & clean 
				X - Save and Exit
				
INPUTS: 		// Raw data 
					${builddta}/followup_2014/MasterData_cleaned.dta
						
OUTPUTS: 		${builddta}/followup_2014/SectionK_Govenrment_Schemes_cleaned.dta
				
NOTE:			
******************************************************************/

/****************************************************************
	SECTION 0: Preamble					 									
****************************************************************/

version 13.1

set more off
clear all
cap log close 

loc name_do SectionK_Govenrment_Schemes_clean
log using "${buildlog}/`name_do'", replace


/****************************************************************
	SECTION 1: Import Raw Data				 									
****************************************************************/


// Master Data
use "${builddta}/followup_2014/MasterData_cleaned.dta", clear

/// Keep ID and Section J1
keep Id q1001_nregkha11-q1015_oth_reanotrecsche_12
rename q103* q1013*
order *, alphabetic

/// Correct errors
ds, has(type string)
local str_var `r(varlist)'
foreach var of local str_var {
	qui replace `var'=subinstr(`var',":",".",.)
	qui replace `var'="" if (`var'=="-")
}
*
/*
replace q1007_1_recitemnumunit_2="-333" if (q1007_1_recitemnumunit_2=="1:50")
replace q1007_1_recitemnumunit_3="-333" if regexm(q1007_1_recitemnumunit_3,"0:5")
*/

/// Destring and recode variables
destring *, replace
ds, has(type numeric)
local num_var `r(varlist)'
foreach var of local num_var {
	qui replace `var'=.b if mi(`var') // Blank response (but not a valid response)
	qui recode `var' (-999=.d) (-777=.r) (-666=.n) (-333=.b) (-555=.) // -999 "Don't Know" -888 "Others" -777 "Refuse" -666 "N/A" -333 "Missing" -555 "Valid Skip"
}
*

// Logic check (Skip pattern)

/// q1001~q1003
replace q1002_totdayHHnreg11=.m if ((q1001_nregkha11!=1) & !mi(q1002_totdayHHnreg11))
replace q1003_totvalHHnreg11=.m if ((q1001_nregkha11!=1) & !mi(q1003_totvalHHnreg11))

/// q1006 ~ q1010
ds q1006_recitemkha11_1-q1010_nummonpdskha11_8
loc PDSvar `r(varlist)'
foreach var of local PDSvar {
	if "`var'"=="q1006_recitemkha11_oth_8" {
		continue
	}
	replace `var'=.m if ((q1005_usepdskha11!=1) & !mi(`var'))
}
*

lab define unit 1 "KGS" 2 "Liter" 3 "Gram" 4 "Pieces"
/// q1005 ~ q1010
forval i=1/8 {
	replace q1007_recitemunitmon_`i'=.m if ((q1006_recitemkha11_`i'==2) & !mi(q1007_recitemunitmon_`i'))
	replace q1007_1_recitemnumunit_`i'=.m if ((q1006_recitemkha11_`i'==2) & !mi(q1007_1_recitemnumunit_`i'))
	replace q1008_subpricperunit_`i'=.m if ((q1006_recitemkha11_`i'==2) & !mi(q1008_subpricperunit_`i'))
	replace q1009_avemarkpricpunit_`i'=.m if ((q1006_recitemkha11_`i'==2) & !mi(q1009_avemarkpricpunit_`i'))
	replace q1010_nummonpdskha11_`i'=.m if ((q1006_recitemkha11_`i'==2) & !mi(q1010_nummonpdskha11_`i'))
	
	lab value q1007_recitemunitmon_`i' unit
}
*

/// q1012~q1015
forval i=1/12 {
	di "i is `i'"
	replace q1013_usedschememay11_`i'=.m if ((q1012_heardnameprog_`i'==2) & !mi(q1013_usedschememay11_`i'))
	replace q1014_amtvalrec_`i'=.m if ((q1012_heardnameprog_`i'==2) & !mi(q1014_amtvalrec_`i'))
	replace q1015_reanotrecsche_`i'=.m if ((q1012_heardnameprog_`i'==2) & !mi(q1015_reanotrecsche_`i'))
	replace q1015_oth_reanotrecsche_`i'="Valid Skip" if ((q1012_heardnameprog_`i'==2) & !mi(q1015_oth_reanotrecsche_`i'))
	
	/// q1013,q1014
	replace q1014_amtvalrec_`i'=.m if ((q1013_usedschememay11_`i'==2) & !mi(q1014_amtvalrec_`i'))
}
*




/****************************************************************
	SECTION X: Save and Exit
****************************************************************/

qui compress
save "${builddta}/followup_2014/SectionK_Govenrment_Schemes_cleaned.dta", replace

cap file close _all
cap log close
copy "${buildlog}/`name_do'.smcl" ///
	"${buildlog}/archive/`name_do' - `c(current_date)' - `c(username)'.smcl" ///
	, replace
exit
