/*****************************************************************
PROJECT: 		IN_Rainfall, India Rainfall Insurance
				
TITLE:			SectionB1_WageIncome_clean.do
			
AUTHOR: 		Seungmin Lee (seungmin.lee@yale.edu, eatorange@gmail.com)

DATE CREATED:	April 8, 2016

LAST EDITED:	April 9, 2016 by Seungmin Lee

DESCRIPTION: 	Import & clean Section B1 of 2014 follow-up survey data
	
ORGANIZATION:	0 - Preamble
				1 - Import & clean
				X - Save and Exit
				
INPUTS: 		// Raw data 
					${builddta}/followup_2014/MasterData_cleaned.dta - Masterdata (q201)
					${followup_data}/AP Raw/SectionBWageIncomeP2_1.dta
					${followup_data}/TN Raw/SectionBWageIncomeP2_1.dta
					${followup_data}/UP Raw/SectionBWageIncomeP2_1.dta
				
OUTPUTS: 		${builddta}/followup_2014/SectionB1_WageIncome_cleaned.dta
				
NOTE:			This do-file is based on
				- "${follow_data}/Do Files/SectionBWageIncomeP2_1.do"
				with additional modifications.
******************************************************************/

/****************************************************************
	SECTION 0: Preamble					 									
****************************************************************/

version 13.1

set more off
clear all
cap log close 

loc name_do SectionB_WageIncome_clean
log using "${buildlog}/`name_do'", replace


/****************************************************************
	SECTION 1: Import Raw Data				 									
****************************************************************/

use "${builddta}/followup_2014/MasterData_cleaned.dta", clear
keep Id q201_khaagriwageempl
tempfile Id_q201
save `Id_q201'

use "${followup_data}/AP Raw/SectionBWageIncomeP2_1.dta", clear
append using "${followup_data}/TN Raw/SectionBWageIncomeP2_1.dta" 
append using "${followup_data}/UP Raw/SectionBWageIncomeP2_1.dta" 
isid Id subid

// Destring and recode variables
destring subid q*, replace
ds, has(type numeric)
local num_var `r(varlist)'
foreach var of local num_var {
	qui replace `var'=.b if mi(`var') // Blank response (but not a valid response)
	qui recode `var' (-999=.d) (-777=.r) (-666=.n) (-333=.b) (-555=.) // -999 "Don't Know" -888 "Others" -777 "Refuse" -666 "N/A" -333 "Missing" -555 "Valid Skip"
}
*

// Skip pattern
// q204 and q205
replace q205_curstathhmem=.m if (q204_prefillname!=1 & !mi(q205_curstathhmem)) 

// q206 and the rest of variables
ds q207_avwagkar11-q212_relemp_oth, has(type numeric)
loc varlist `r(varlist)'
foreach var of local varlist {
	replace `var'=.m if (inlist(q206_totdaylocagrikhar11,0,.n) & !mi(`var'))
}
*


// Outlier-cleaning
// (Q206-Q208)
gen tot_earn_calculated = q206_totdaylocagrikhar11* q207_avwagkar11  // Calculated total earning

// Generate "cleaned" variables
clonevar q207_avwagkar11_c = q207_avwagkar11
clonevar q208_totearnlolagrikha11_c = q208_totearnlolagrikha11
clonevar q211_totvalnonmonkha11_c = q211_totvalnonmonkha11

// Clean outliers
/// Basically, if calculated total earning is exactly 10 times greater than actual total earning responded, we assume they are mis-responses and use calculated tot_earning as "cleaned"
/// However, among the cases above, there are also observations which "outlier daily wages" (>=1000). In that case, we assume daily wages are mis-responses and divide it by 10.
replace q208_totearnlolagrikha11_c=tot_earn_calculated if ((tot_earn_calculated/q208_totearnlolagrikha11_c==10) & (q207_avwagkar11_c<1000))
replace q207_avwagkar11_c=(q207_avwagkar11/10) if ((tot_earn_calculated/q208_totearnlolagrikha11_c==10) & (q207_avwagkar11_c>=1000))

/// There's one observation which seems total earning and daily wage were mistakenly swapped. We will fix that.
replace q207_avwagkar11_c=250 if (Id=="P2633" & q203_Hhrosid==4)
replace q208_totearnlolagrikha11_c=12000 if (Id=="P2633" & q203_Hhrosid==4)

/// Apply similar procedure in case "outlier actual total earning" (>=100000) is 10 times greater than calculated total earning and 
replace q208_totearnlolagrikha11_c=(q208_totearnlolagrikha11_c/10) if ((q208_totearnlolagrikha11/tot_earn_calculated==10) & (q208_totearnlolagrikha11>=100000))

drop tot_earn_calculated // drop variable no lonter needed



//Label Variables
label define yesno 1 "Yes" 2 "No"

label var Id "Household ID"
label var subid "Roster ID"
label  var q203_Hhrosid "HH Roster ID"
label var q203_1_wagearname "Name of Wage Earner"
label var  q204_prefillname "Prefilled Or Not"
label value q204_prefillname yesno
label var q205_curstathhmem "Current Status"
label var  q205_curstathhmem_oth "Other Current Status"
label var  q206_totdaylocagrikhar11 "Days in Agriculture - Kharif"
label var  q207_avwagkar11 "Avg Daily Wage - Kharif"
label var  q207_avwagkar11_c "Avg Daily Wage - Kharif (cleaned)"
// ~1% report more than Rs 400, which seems highly improbable
label var  q208_totearnlolagrikha11 "Total Agri Earnings - Khairf"
label var  q208_totearnlolagrikha11_c "Total Agri Earnings - Khairf (cleaned)"
label var  q209_nonmonlolagriwork11 "NON-Monetary Compensation Received for agri labour?"
label val q209_nonmonlolagriwork11 yesno
label var q210_typenonmoncomp "Non-Monetary Compensation 1"
label var q210_typenonmoncompx1 "Non-Monetary Compensation 2"
label var q210_typenonmoncompx2 "Non-Monetary Compensation 3"
label var q210_typenonmoncompx3 "Non-Monetary Compensation 4"

label var  q210_typenonmoncomp_oth "Other Non-Monetary Compensation"
label var  q211_totvalnonmonkha11 "Total Value of Non-Monetary Compensation"
label var  q211_totvalnonmonkha11_c "Total Value of Non-Monetary Compensation (cleaned)"
label var  q212_relemp "Relationship to Employer"
label var  q212_relemp_oth "Other Relationship to Employer"
label var  q202_1_baseHHrosid "Baseline Roster ID" // SL: Rupika said it is changed from Baseline ID to Follow-up ID. Is this dataset updated version?

//Label Values

label define currentstatus -666 "NA" 1 "Current household member" 2 "Dead" 3 "Temporarily Migrated" 4 "Permanently Migrated" 5 "Away at school" 6 "Away because of marriage/festival" 7 "Away because of sickeness" -999 "Don’t know" -888 "Other" -555 "Valid Skip"
label value q205_curstathhmem currentstatus

label define nonmonetary -666 "NA" 1 "Crops" 2 "Labour exchange" 3 "Animal Goods (food/milk)" 4 "Animal Goods (non-food)" 5 "Animal feed (fodder, etc.)" 6 "Loan repayment" 7 "Daily Consumables (tea, snacks)" 8 "Festival gifts" -888 "Other" -777 "Refuse to Answer" -555 "Valid Skip"
label value q210_typenonmoncomp q210_typenonmoncompx1 q210_typenonmoncompx2 q210_typenonmoncompx3 nonmonetary

label define relationship -666 "NA" 1 "Immediate family" 2 "Same sub-caste" 3 "Same caste" 4 "Friend" 5 "No Relation" -888 "Other" -777 "Refuse to Answer" -555 "Valid Skip"
label value q212_relemp relationship


tempfile SecB1
save `SecB1'

// Merge q201 with B1
use `Id_q201', clear
merge 1:m Id using `SecB1', keep(3) nogen

order q*, alpha
order Id
order subid, after(q201_khaagriwageempl)
order q203_Hhrosid, before(q203_1_wagearname)

/****************************************************************
	SECTION X: Save and Exit
****************************************************************/

qui compress
save "${builddta}/followup_2014/SectionB1_WageIncome_cleaned.dta", replace

cap file close _all
cap log close
copy "${buildlog}/`name_do'.smcl" ///
	"${buildlog}/archive/`name_do' - `c(current_date)' - `c(username)'.smcl" ///
	, replace
exit
