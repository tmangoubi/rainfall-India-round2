/*****************************************************************
PROJECT: 		IN_Rainfall, India Rainfall Insurance
				
TITLE:			SectionM2_Migration_LeanPeriod_clean.do
			
AUTHOR: 		Seungmin Lee (seungmin.lee@yale.edu, eatorange@gmail.com)

DATE CREATED:	April 9, 2016

LAST EDITED:	April 10, 2016 by Seungmin Lee 

DESCRIPTION: 	Import & clean Section M2 of 2014 follow-up survey data
	
ORGANIZATION:	0 - Preamble
				1 - Import & clean 
				X - Save and Exit
				
INPUTS: 		// Raw data 
					// Master
						${builddta}/followup_2014/MasterData_cleaned.dta - Master Data (q218)
					
					// Section M2A
						// q219
						${followup_data}/AP Raw/SectionM2A_1.dta
						${followup_data}/TN Raw/SectionM2A_1.dta
						${followup_data}/UP Raw/SectionM2A_1.dta
						
						// q220.X
						${followup_data}/AP Raw/SectionM2A1_1.dta
						${followup_data}/TN Raw/SectionM2A1_1.dta
						${followup_data}/UP Raw/SectionM2A1_1.dta
						
					// Section M2B (Dataset missing)
						${followup_data}/AP Raw/XXX.dta
						${followup_data}/TN Raw/XXX.dta
						${followup_data}/UP Raw/XXX.dta

OUTPUTS: 		${builddta}/followup_2014/SectionM2_Migration_LeanPeriod_cleaned.dta
				
NOTE:			This do-file is based on
				- "${follow_data}/Do Files/SectionM2A_1.do" (written by Alreena Pinto)
				- "${follow_data}/Do Files/SectionM2A1_1.do" (written by Alreena Pinto)
				with additional modifications.
******************************************************************/

/****************************************************************
	SECTION 0: Preamble					 									
****************************************************************/

version 13.1

set more off
clear all
cap log close 

loc name_do SectionM1_LeanPeriod_clean
log using "${buildlog}/`name_do'", replace


/****************************************************************
	SECTION 1: Import & Clean Data				 									
****************************************************************/

// Master Data
use "${builddta}/followup_2014/MasterData_cleaned.dta", clear

keep Id q218_2_mwl q218_3_mwl q218_3_oth_mwl
order Id q218_2_mwl q218_3_mwl q218_3_oth_mwl
* keep if (q218_2_mwl==1) // Only those who answered "Yes" answered the rest of M2 section.
tempfile q218_part1
save `q218_part1'

// M2A - Migration Wage labor, Part 1 (q213, q219)
use "${followup_data}/AP Raw/SectionM2A_1.dta", clear
append using "${followup_data}/TN Raw/SectionM2A_1.dta" 
append using "${followup_data}/UP Raw/SectionM2A_1.dta" 
isid Id subid

/// Destring & recode variables
destring *, replace
ds, has(type numeric)
local num_var `r(varlist)'
foreach var of local num_var {
	qui replace `var'=.b if mi(`var') // Blank response (but not a valid response)
	qui recode `var' (-999=.d) (-777=.r) (-666=.n) (-333=.b) (-555=.) // -999 "Don't Know" -888 "Others" -777 "Refuse" -666 "N/A" -333 "Missing" -555 "Valid Skip"
	if ("`var'" == "q224_destearning") {
		qui recode `var' (-222=.n)
	}
}
*

// Label variables
label define yesno 1 "Yes" 2 "No"

label var Id "Household ID"
label var subid "SubId"
label var q213_2_bhhid "Baseline HH Roster ID"
label var q213_3_hhrid "Current HH Roster ID"
label var q219_migserwork "Migrate in search of work?"
label value q219_migserwork yesno

// q219_1_timesmig
/// Oringal question asks "how many times migrated b/w April to June, but lean period is actually from April to July in AP and UP, and from June to Sep in TN"
/// I (SL) do not know whether households answered this question based on the period from April to June, or based on actual lean period.
/// Final questionnaire might clarified this issue. 
label var q219_1_timesmig "How many times migrated during lean period?"
note q219_1_timesmig: Lean period is from April to July in UP and AP, and from June to September in TN

tempfile SecM2A_1
save `SecM2A_1'


// M2A, Part 2
use "${followup_data}/AP Raw/SectionM2A1_1.dta", clear
append using "${followup_data}/TN Raw/SectionM2A1_1.dta" 
append using "${followup_data}/UP Raw/SectionM2A1_1.dta" 
isid Id subid q213_4_migepisode

/// Destring and recode variables
destring *, replace
ds, has(type numeric)
local num_var `r(varlist)'
foreach var of local num_var {
	qui replace `var'=.b if mi(`var') // Blank response (but not a valid response)
	qui recode `var' (-999=.d) (-777=.r) (-666=.n) (-333=.b) (-555=.) // -999 "Don't Know" -888 "Others" -777 "Refuse" -666 "N/A" -333 "Missing" -555 "Valid Skip"
	if ("`var'" == "q224_destearning") {
		qui recode `var' (-222=.n)
	}
}
*

/// Clean variables

/// subid
/// Id=="00A22" has only subid==2 in part 1, while only subid==1 in part 2. Need to match this number.
replace subid=2 if (Id=="00A22")

//// q220_1_migweek
//// Couple of observations have values greater than 5. 
replace q220_1_migweek=.m if !mi(q220_1_migweek) & !inrange(q220_1_migweek,1,5) // ".m" indicates "Failure to follow direction"

/// Label variables
label define yesno 1 "Yes" 2 "No"

label var Id "Household ID"
label var subid "SubId"
label var q213_4_migepisode "Migration Episode SL number"
label var q220_1_migweek "Migration - Week"
label var q220_1_migmonth "Migration - Month"
label var q222_1_days "Days out in migration episode"
label var q222_2_prireason "Primary reason for migration"
label var q222_2_prireason_oth "Primary reason for migration - Other"
label var q12_costoftravel "Cost of travel" 
label var q13_otrcostmig "Other migration costs"
label var q14_daytoreach1 "Travel duration - days"
label var q19_payforcost "Pay for migration costs"
label var q19_payforcost_oth "Pay for migration costs - Other"
label var q20_daytotakejob "Days to get a job"
label var q21_costfoodlodge "Cost of food and lodging"
label var q21_1_savingonreturn "Total savings from migration episode"

//coding for reasons for migration is not defined in questionnaire

label define migcost 1 "From own/family savings" 2 "Sold land/real estate" 3 "Sold jewellery" 4 "Spouse's family (grant)" 5 "Other Relatives (grants)" ///
	6 "Employer in destination" 7 "Credit from money lender" 8 "Credit from NGOs" 9 "Credit from Banks" 10 "Other" 11 "Cash received from NGO"  ///
	12 "Credit/money from relatives" 13 "Money from group members"

label value q19_payforcost migcost


/// Save
tempfile SecM2A_2
save `SecM2A_2'


/// Merge Part 1 and Part 2
use `SecM2A_1', clear
merge 1:m Id subid using `SecM2A_2', gen(match_q219_q220X)
label define match_q219_q220X 1 "q219 Only" 2 "q220.X Only" 3 "Both q219 and q220.X"
label value match_q219_q220X match_q219_q220X
label var match_q219_q220X "Does this household member have a complete answer for Section M2A?"
note match_q219_q220X: 	In the raw data, section M2A is separated into two different datasets (SectionM2A_1 (q219), SectionM2A1_1 (q220.X)).
note match_q219_q220X: 	Not existing in both data at the same time does not necessarily mean that a respondent made mistake. ///
						For those who answered "No" in q219, they should skip the rest of Section M2A, thus should not exist in q220.x data


// Apply logical skip patterns
/// If not migrated, then there should be no non-missing responses.
ds q213_4_migepisode-q21_1_savingonreturn, has(type numeric)
loc 219vars_num `r(varlist)'
ds q213_4_migepisode-q21_1_savingonreturn, has(type string)
loc 219vars_str `r(varlist)'

foreach var of local 219vars_num {
	replace `var'=.m if ((q219_migserwork==2) & !mi(`var'))
}
*
foreach var of local 219vars_str {
	replace `var'="Failure to follow directions" if ((q219_migserwork==2) & !mi(`var'))
}
*

// Tag observation validity
gen valid_lean_migration_sample = 2 // Indicator variable - did this household member answer question properly?
replace valid_lean_migration_sample = 1 if (q219_migserwork == 1 & match_q219_q220X == 3) // Those who answered "Yes" in q219 should also answer the rest of M2A section
replace valid_lean_migration_sample = 1 if (q219_migserwork == 2 & match_q219_q220X == 1) // Those who answered "No" in q219 should skip the rest of section M2A
replace valid_lean_migration_sample = 2 if mi(q213_4_migepisode) // Responses with missing migration episode is not a valid observation.
label var valid_lean_migration_sample "Is this lean-season migration observation valid? (i.e. answered questions properly?)"
label value valid_lean_migration_sample yesno


tempfile SecM2A
save `SecM2A'


// Section M2B
** This data has been later added by Rupika in April 2016. 
use "${followup_data}/Final Data/20.04.2016/M2B Migration Remittance/SectionM2B_1_cleaned.dta", clear
*isid Id subid

/// Destring and recode variables
destring *, replace
ds, has(type numeric)
local num_var `r(varlist)'
foreach var of local num_var {
	qui replace `var'=.b if mi(`var') // Blank response (but not a valid response)
	qui recode `var' (-999=.d) (-777=.r) (-666=.n) (-333=.b) (-555=.) // -999 "Don't Know" -888 "Others" -777 "Refuse" -666 "N/A" -333 "Missing" -555 "Valid Skip"
}
*

// Apply skip pattern
ds q27_remit q27_remit_oth q28_daystofundreach q29_costofremittance q30_freqremittance q30_freqremittance_oth, has(type numeric)
loc remittvar_num `r(varlist)'
ds q27_remit q27_remit_oth q28_daystofundreach q29_costofremittance q30_freqremittance q30_freqremittance_oth, has(type string)
loc remittvar_str `r(varlist)'

foreach var of local remittvar_num {
	replace `var'=.n if (q26_sendtohh==4)
}
*
foreach var of local remittvar_str {
	replace `var'="Not Appicable" if (q26_sendtohh==4)
}
*

// Tag outliers
loc money_vars q25_totincome q29_costofremittance
foreach var of loc money_vars {
	gen byte `var'_outlier=0
	order `var'_outlier, after(`var')
	qui sum `var', detail
	scalar `var'_IQR = r(p75)-r(p25)
	replace `var'_outlier=1 if !inrange(`var',r(p25)-(3*`var'_IQR),r(p75)+(3*`var'_IQR))
	label var `var'_outlier "=1: this obs is an outlier"
	note `var'_outlier: Defined as outlier if x < Q(25)-3IQR  or  x > Q(75)+3IQR
	scalar drop `var'_IQR
}
*

// Label variables
label var Id "Household ID"
label var subid "SubId"

label var q22_support "Means of support"
label var q22_support_oth "Other means of support"
label var q23_howfindwork "Source of finding work"
label var q23_howfindwork_oth "Source of finding work"
label var q24_kindofwork "Kind of work"
label var q24_kindofwork_oth "Kind of work,other specify"
label var q25_totincome "Total lean period migration income"
label var q26_sendtohh "Remittance of money or goods to household"
label var q27_remit "Source of remittance"
label var q27_remit_oth "Source of remittance, other specify"
label var q28_daystofundreach "Time taken for remittance to reach"
label var q29_costofremittance "Cost of remittance"
label var q30_freqremittance "Frequency of remittance"
label var q30_freqremittance_oth "Frequency of remittance, other specify"
label var q31_oftenvisithh "Frequency of visit to household"
label var q31_oftenvisithh_oth "Frequency of visit to household"
label var q32_whyreturn "Reason for return"
label var q32_whyreturn_oth "Reason for return"
label var q213_4_migepisode "Migration episode"

tempfile SecM2B
save `SecM2B'



*
/****************************************************************
	SECTION X: Save and Exit
****************************************************************/

use `SecM2A'
compress
save "${builddta}/followup_2014/SectionM2A_Migration_LeanPeriod_cleaned.dta", replace

use `SecM2B'
compress
save "${builddta}/followup_2014/SectionM2B_Migration_LeanPeriod_cleaned.dta", replace

cap file close _all
cap log close
copy "${buildlog}/`name_do'.smcl" ///
	"${buildlog}/archive/`name_do' - `c(current_date)' - `c(username)'.smcl" ///
	, replace
exit
