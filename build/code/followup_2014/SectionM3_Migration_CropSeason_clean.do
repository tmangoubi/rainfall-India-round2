/*****************************************************************
PROJECT: 		IN_Rainfall, India Rainfall Insurance
				
TITLE:			SectionM3_Migration_CropSeason_clean.do
			
AUTHOR: 		Seungmin Lee (seungmin.lee@yale.edu, eatorange@gmail.com)

DATE CREATED:	April 8, 2016

LAST EDITED:	April 8, 2016 by Seungmin Lee

DESCRIPTION: 	Import & clean Section M3 of 2014 follow-up survey data
	
ORGANIZATION:	0 - Preamble
				1 - Import & clean 
				X - Save and Exit
				
INPUTS: 		// Raw data 
					// Master
						${builddta}/followup_2014/MasterData_cleaned.dta - Master Data (q218.4, q218.5)
					
					// Section M3
						// Roster (q218.6, q218.7)
						${followup_data}/AP Raw/SectionM3Roster_1.dta
						${followup_data}/TN Raw/SectionM3Roster_1.dta
						${followup_data}/UP Raw/SectionM3Roster_1.dta
						
						// q218.8 ~ 218.24 (*** Datasets below are named as "M2B", but they are actually "M3" data
						${followup_data}/AP Raw/SectionM2B_1.dta
						${followup_data}/TN Raw/SectionM2B_1.dta
						${followup_data}/UP Raw/SectionM2B_1.dta
						
OUTPUTS: 		${builddta}/followup_2014/SectionM3_CropSeason_cleaned.dta
				
NOTE:			This do-file is based on
				- "${follow_data}/Do Files/SectionM2B_1.do" (written by Alreena Pinto)
				with additional modifications.
******************************************************************/


/****************************************************************
	SECTION 0: Preamble					 									
****************************************************************/

version 13.1

set more off
clear all
cap log close 

loc name_do SectionM3_Migration_CropSeason_clean
log using "${buildlog}/`name_do'", replace

/****************************************************************
	SECTION 1: Import & Clean Data				 									
****************************************************************/

// Master Data
use "${builddta}/followup_2014/MasterData_cleaned.dta", clear

keep Id q218_4_migratetemper q218_5_reasonmig q218_5_reasonmig_oth
order Id q218_4_migratetemper q218_5_reasonmig q218_5_reasonmig_oth
* keep if (q218_2_mwl==1) // Only those who answered "Yes" answered the rest of M2 section.

/// Destring and recode variables
destring *, replace
ds, has(type numeric)
local num_var `r(varlist)'
foreach var of local num_var {
	qui replace `var'=.b if mi(`var') // Blank response (but not a valid response)
	qui recode `var' (-999=.d) (-777=.r) (-666=.n) (-333=.b) (-555=.) // -999 "Don't Know" -888 "Others" -777 "Refuse" -666 "N/A" -333 "Missing" -555 "Valid Skip"
	if ("`var'" == "q218_4_migratetemptaer") {
		qui recode `var' (-222=.n)
	}
}
*
// Label variable
label define yesno 1 "Yes" 2 "No", replace
label value q218_4_migratetemper yesno

// Save
tempfile q218
save `q218'

// M3 - Cropping Season Migration (Roster)
use "${followup_data}/AP Raw/SectionM3Roster_1.dta", clear
append using "${followup_data}/TN Raw/SectionM3Roster_1.dta" 
append using "${followup_data}/UP Raw/SectionM3Roster_1.dta" 
isid Id subid

/// Destring & recode variables
destring *, replace
ds, has(type numeric)
local num_var `r(varlist)'
foreach var of local num_var {
	qui replace `var'=.b if mi(`var') // Blank response (but not a valid skip)
	qui recode `var' (-999=.d) (-777=.r) (-666=.n) (-333=.b) (-555=.) // -999 "Don't Know" -888 "Others" -777 "Refuse" -666 "N/A" -333 "Missing" -555 "Valid Skip"
}
*

/// Label variables
label var Id "Household ID"
label var subid "SubId"
label var qM3_BHHID "Baseline HH Roster ID"
label var qM3_HHRID "Current HH Roster ID"
label var q218_6_migsearwor "Did this sperson Migrate in search of work? - Cropping Season"
label value q218_6_migsearwor yesno
label var q218_7_timesmig "How many times did this person migrated during Cropping Season?"

/// Save
tempfile SecM3_Roster
save `SecM3_Roster'


// M3 - Cropping Season Migration (q218.8 ~ q218.14)
use "${followup_data}/AP Raw/SectionM2B_1.dta", clear
append using "${followup_data}/TN Raw/SectionM2B_1.dta" 
append using "${followup_data}/UP Raw/SectionM2B_1.dta" 
isid Id subid q218_8_migepisode


/// Destring and recode variables
/// Destring and recode variables
destring *, replace
ds, has(type numeric)
local num_var `r(varlist)'
foreach var of local num_var {
	qui replace `var'=.b if mi(`var') // Blank response (but not a valid response)
	qui recode `var' (-999=.d) (-777=.r) (-666=.n) (-333=.b) (-555=.) // -999 "Don't Know" -888 "Others" -777 "Refuse" -666 "N/A" -333 "Missing" -555 "Valid Skip"
}
*

/// Clean variables

//// q218_9_migweek
//// Couple of observations have values greater than 5. 
replace q218_9_migweek=.m if !mi(q218_9_migweek) & !inrange(q218_9_migweek,1,5) // ".m" indicates "Failure to follow direction"

//// q218_10_migmonth
//// Some obserations have values outside 1 to 12.
replace q218_10_migmonth=.m if !mi(q218_10_migmonth) & !inrange(q218_10_migmonth,1,12) // ".m" indicates "Failure to follow direction"

//// MNREGA variables (q218_22 ~ q218_24)
//// They are measured in different data (M4) so it will be dropped.
drop q218_22_mnrega q218_23_daysempl q218_24_totearning

/// Label variables
label define yesno 1 "Yes" 2 "No"

label var Id "Household ID"
label var subid "SubId"
label var q218_8_migepisode "Migration Episode SL number"
label var q218_9_migweek "Migration - Week"
label var q218_10_migmonth "Migration - Month"
label var q218_11_daysepisode "Days out in migration episode"
label var q218_12_priresonmig "Primary reason for migration" //coding for reasons for migration is not defined in questionnaire
label var q218_12_priresonmig_oth "Primary reason for migration - Other"
label var q218_12_industrywork "Industry after migration"
label var q218_12_industrywork_oth "Industry after migration - Other"
label var q218_13_priactivity "Activities for work"
label var q218_13_priactivity_oth "Activities for work - Other"
label var q218_14_avgdailywage "Average daily wage"
label var q218_15_avgmthlyinc "Average monthly income"
label var q218_16_totearning "Total earnings at migration destination"
label var q218_17_relation "Relationship to employer"
label var q218_17_relation_oth "Relationship to employer - Other"
label var q218_18_knewanyone "Knew someone at migration destination?"
label var q218_19_rel1 "Relationship with people at migration destination_1"
label var q218_20_rel2 "Relationship with people at migration destination_2"
label var q218_21_rel3 "Relationship with people at migration destination_3"
*label var q218_22_mnrega "Employed under MNREGA"
*label var q218_23_daysempl "Days employed under MNREGA"
*label var q218_24_totearning "Total earnings - MNREGA"

//codes for industry, primary activity, relationships not defined in questionnaire

*label value q218_18_knewanyone q218_22_mnrega yesno

// Save
tempfile SecM3_main
save `SecM3_main'

// Merge roster and main questions
use `SecM3_Roster', clear
merge 1:m Id subid using `SecM3_main', gen(match_roster_q218X)
label define match_roster_q218X 1 "No, Roster Only" 2 "No, q218.X Only" 3 "Yes - both roster and q218.X"
label value match_roster_q218X match_roster_q218X
label var match_roster_q218X "Does this household member have a complete answer for Section M3?"
note match_roster_q218X: 	In the raw data, section M3 is separated into two different datasets (SectionM3Roster_1 (roster), SectionM2B_1 (q218.X)).
tempfile SecM3
save `SecM3'
		
// Merge q218 and M3
use `q218', clear
merge 1:m Id using `SecM3', nogen keep(3)


/* This code may be used if we want to keep ALL households in Master Data
merge 1:m Id using `SecM3', gen(SecM3_answered) keep(1 3)
label define SecM3_answered 1 "No" 3 "Yes"
label value SecM3_answered SecM3_answered
label var SecM3_answered "Did this household answer Section M3?"
*/

/*
// Generate variables for analyses

// Migrated during Cropping season
bys Id: egen migrant_cropseason_HH = min(q218_6_migsearwor) // If there's any migrant worker, then min(q218_6_migsearwor) should equal to 1. 2 otherwise.
label var migrant_cropseason_HH "Any household member migrated for work during cropping season"
label value migrant_cropseason_HH yesno

// Total migration episodes per household
loc var Tot_migepisodes_cropseason_HH
bys Id: egen `var'=count(q218_8_migepisode)
lab var `var' "Total migration episodes - HH level"

// Total migration income during cropping season - HH level
bys Id: egen Tot_migincome_cropseason_HH = sum(q218_16_totearning) if (q218_6_migsearwor==1)
label var Tot_migincome_cropseason_HH "Total income at migration destination - HH level"

// Total migration day during cropping season - HH level
bys Id: egen Tot_migdays_cropseason_HH = sum(q218_11_daysepisode) if (q218_6_migsearwor==1)
label var Tot_migdays_cropseason_HH "Total # days migrated during cropping season, HH level"

// Average daily migration wage
gen Avg_daily_migwage_cropseason_HH = (Tot_migincome_cropseason_HH / Tot_migdays_cropseason_HH)
label var Avg_daily_migwage_cropseason_HH "Daily migration wage - HH level average"

/*
/// Individual-level
clonevar migrate_work_cropseason_ind = q218_6_migsearwor // Migrated for work or NOT
clonevar migrate_episodes_cropseaon_indiv = q218_7_timesmig if (migrate_work_cropseason_ind==1) // # of migration episodes
bys Id subid: egen migrate_days_cropseason_indiv = sum(q218_11_daysepisode) if (migrate_work_cropseason_ind==1) // # of days migrated



clonevar migrant_cropseason_HH = q218_4_migratetemper // Any migrant during cropping season
clonevar migrant_worker_cropseason_ind = q218_6_migsearwor // Any migrant-worker during cropping season (i
clonevar 

clonevar migrant_episodes_cropseason = q218_7_timesmig // # of migrant episodes
clonevar migrant_daysout_cropseason = q218_11_daysepisode

*/
*/
/****************************************************************
	SECTION X: Save and Exit
****************************************************************/

compress
save "${builddta}/followup_2014/SectionM3_CropSeason_cleaned.dta", replace

cap file close _all
cap log close
copy "${buildlog}/`name_do'.smcl" ///
	"${buildlog}/archive/`name_do' - `c(current_date)' - `c(username)'.smcl" ///
	, replace
exit

