/*****************************************************************
PROJECT: 		IN_Rainfall, India Rainfall Insurance
				
TITLE:			IN_rainfall_round3_clean.do
			
AUTHOR: 		Seungmin Lee (seungmin.lee@yale.edu)

DATE CREATED:	January 28, 2016

LAST EDITED:	January 29, 2016 by Seungmin Lee

DESCRIPTION: 	Import round3 survey data and clean it
	
ORGANIZATION:	0 - Preamble
				1 - Converting csv files to dta
				2 - Data Cleaning
				3 - Save and Exit
				
INPUTS: 		$mk\csv\AICWI 2 - Andhra Pradesh - Insurance Survey.csv
				$mk\csv\AICWI 2 - Andhra Pradesh - Insurance Survey - FINAL.csv
				$mk\csv\AICWI 2 - Andhra Pradesh - Insurance+IMD Survey.csv
				$mk\csv\AICWI 2 - Andhra Pradesh - Insurance+IMD Survey - FINAL.csv
				$mk\csv\AICWI 2 - Uttar Pradesh - Insurance Survey - FINAL.csv
				$mk\csv\AICWI 2 - Uttar Pradesh - Insurance Survey - FINAL_New.csv
				$mk\csv\AICWI 2 - Uttar Pradesh - Insurance Survey -IMD- FINAL.csv
				$mk\csv\AICWI 2 - Uttar Pradesh - Insurance Survey -IMD- FINAL_New.csv
				$mk\csv\AIC_WI_TAMIL_NADU_2014.csv

OUTPUTS: 		$mk/dta\AICWI2-FULL.dta
				$mk/dta\AICWI2-FULL BACKUP.dta
				$mk/dta\labelled_dataset.dta
				${buildtab}/INTERVENTION2.rtf
				${builddta}/round3/IN_rainfall_r3_cleaned.dta
				
NOTE:			This do-file is based on "${r3_data}/MARKETING ROUND II.do" with additional modifications.
******************************************************************/

/****************************************************************
	SECTION 0: Preamble					 									
****************************************************************/

version 13.1

set more off
clear all
cap log close 
set mem 500m

global mk "${r3_data}"
cap mkdir "$mk/dta/"
cap mkdir "$mk/dta/raw"

loc name_do IN_rainfall_round3_clean
log using "${buildlog}/`name_do'", replace

		
/****************************************************************
	SECTION 1: Converting csv files to dta					 									
****************************************************************/

//INSURANCE SURVEY ANDHRA PRADESH
insheet using "$mk\csv\AICWI 2 - Andhra Pradesh - Insurance Survey.csv", clear
tostring a1_2other b_4other c_1_d_whymigdest c_1_f_findjob c_1_g_other c_1_d_other c_1_a_other , replace
gen category = 1
save "$mk/dta\AICWI 2 - Andhra Pradesh - Insurance Survey.dta", replace

//INSURANCE SURVEY FINAL ANDHRA PRADESH
insheet using "$mk\csv\AICWI 2 - Andhra Pradesh - Insurance Survey - FINAL.csv", clear
tostring c_1_d_other c_1_a_other , replace
gen category = 2
save "$mk/dta\AICWI 2 - Andhra Pradesh - Insurance Survey - FINAL.dta", replace

//INSURANCE + IMD ANDHRA PRADESH
insheet using "$mk\csv\AICWI 2 - Andhra Pradesh - Insurance+IMD Survey.csv", clear
tostring b_4other c_1_g_other c_1_a_other , replace
gen category = 3
save "$mk/dta\AICWI 2 - Andhra Pradesh - Insurance+IMD Survey.dta", replace

//INSURANCE + IMD FINAL ANDHRA PRADESH
insheet using "$mk\csv\AICWI 2 - Andhra Pradesh - Insurance+IMD Survey - FINAL.csv", clear
tostring c_1_a_other c_1_d_other , replace
gen category = 4
save "$mk/dta\AICWI 2 - Andhra Pradesh - Insurance+IMD Survey - FINAL.dta", replace

//INSURANCE SURVEY UTTAR PRADESH FINAL
drop cnote
insheet using "$mk\csv\AICWI 2 - Uttar Pradesh - Insurance Survey - FINAL.csv",clear
tostring doorno d_8nobuyins c_1_l_nomigrate backch_accompsign_mon d_8_othernobuy c_1_l_other c_1_a_other c_1_c_1_c_state b_7_1doorno c_1_f_findjob c_1_g_other c_1_d_other c_1_c_1_c_district c_1_c_1_c_towncity c_1_d_whymigdest  contno c_1_c_1_c_state a1_2other b_7_2stname b_7_3landmark c_1_a_member_mig, replace
tostring d_7_a_whybuy d_7_a_otherbuy d_2_a_whybuy d_2_a_otherbuy  , replace
gen category = 5
save "$mk/dta\AICWI 2 - Uttar Pradesh - Insurance Survey - FINAL.dta", replace 
 
//INSURANCE SURVEY UTTAR PRADESH FINAL NEW
drop cnote
insheet using "$mk\csv\AICWI 2 - Uttar Pradesh - Insurance Survey - FINAL_New.csv",clear
tostring doorno d_8nobuyins c_1_l_nomigrate backch_accompsign_mon d_8_othernobuy c_1_l_other c_1_a_other c_1_c_1_c_state b_7_1doorno c_1_f_findjob c_1_g_other c_1_d_other c_1_c_1_c_district c_1_c_1_c_towncity c_1_d_whymigdest  contno c_1_c_1_c_state a1_2other b_7_2stname b_7_3landmark c_1_a_member_mig, replace
tostring  d_7_a_whybuy d_7_a_otherbuy d_2_a_whybuy d_2_a_otherbuy , replace
gen category = 6
save "$mk/dta\AICWI 2 - Uttar Pradesh - Insurance Survey - FINAL_New.dta",replace

//INSURANCE SURVEY UTTAR PRADESH IMD FINAL
drop cnote
insheet using "$mk\csv\AICWI 2 - Uttar Pradesh - Insurance Survey -IMD- FINAL.csv",clear
tostring doorno d_8nobuyins c_1_l_nomigrate backch_accompsign_mon d_8_othernobuy c_1_l_other c_1_a_other c_1_c_1_c_state b_7_1doorno c_1_f_findjob c_1_g_other c_1_d_other c_1_c_1_c_district c_1_c_1_c_towncity c_1_d_whymigdest  contno c_1_c_1_c_state a1_2other b_7_2stname b_7_3landmark c_1_a_member_mig, replace
tostring b_4other d_7_a_whybuy d_7_a_otherbuy d_2_a_whybuy d_2_a_otherbuy , replace
gen category = 7
save "$mk/dta\AICWI 2 - Uttar Pradesh - Insurance Survey -IMD- FINAL.dta",replace

//INSURANCE SURVEY UTTAR PRADESH IMD FINAL NEW
drop cnote
insheet using "$mk\csv\AICWI 2 - Uttar Pradesh - Insurance Survey -IMD- FINAL_New.csv",clear
tostring doorno d_8nobuyins c_1_l_nomigrate backch_accompsign_mon d_8_othernobuy c_1_l_other c_1_a_other c_1_c_1_c_state b_7_1doorno c_1_f_findjob c_1_g_other c_1_d_other c_1_c_1_c_district c_1_c_1_c_towncity c_1_d_whymigdest  contno c_1_c_1_c_state a1_2other b_7_2stname b_7_3landmark c_1_a_member_mig, replace
tostring b_4other d_7_a_whybuy d_7_a_otherbuy d_2_a_whybuy d_2_a_otherbuy , replace
gen category = 8
save "$mk/dta\AICWI 2 - Uttar Pradesh - Insurance Survey -IMD- FINAL_New.dta",replace

//TAMIL NADU INSURANCE SURVEY

insheet using "$mk\csv\AIC_WI_TAMIL_NADU_2014.csv",clear
tostring doorno d_8nobuyins c_1_l_nomigrate backch_accompsign_mon d_8_othernobuy c_1_l_other c_1_a_other c_1_c_1_c_state b_7_1doorno c_1_f_findjob c_1_g_other c_1_d_other c_1_c_1_c_district c_1_c_1_c_towncity c_1_d_whymigdest  contno c_1_c_1_c_state a1_2other b_7_2stname b_7_3landmark c_1_a_member_mig, replace
tostring b_4other d_7_a_whybuy d_7_a_otherbuy d_2_a_whybuy d_2_a_otherbuy , replace
gen category = 9
gen a_1hhid = _1hhid
drop _1hhid
save "$mk/dta\AIC_WI_TAMIL_NADU_2014.dta",replace

//APPENDING
use "$mk/dta\AICWI 2 - Andhra Pradesh - Insurance Survey.dta", clear
append using "$mk/dta\AICWI 2 - Andhra Pradesh - Insurance Survey - FINAL.dta"
append using "$mk/dta\AICWI 2 - Andhra Pradesh - Insurance+IMD Survey.dta"
append using "$mk/dta\AICWI 2 - Andhra Pradesh - Insurance+IMD Survey - FINAL.dta"
append using "$mk/dta\AICWI 2 - Uttar Pradesh - Insurance Survey - FINAL.dta"
append using "$mk/dta\AICWI 2 - Uttar Pradesh - Insurance Survey - FINAL_New.dta"
append using "$mk/dta\AICWI 2 - Uttar Pradesh - Insurance Survey -IMD- FINAL.dta"
append using "$mk/dta\AICWI 2 - Uttar Pradesh - Insurance Survey -IMD- FINAL_New.dta"
append using "$mk/dta\AIC_WI_TAMIL_NADU_2014.dta"


gen states = "Andhra Pradesh"
replace states = "Tamil Nadu" if category == 9
replace states = "Uttar Pradesh" if category >4 & category <8
label var states "State of Survey"

// Generate an indicator variable of treatment group
gen treatment = 1
replace treatment = 2 if inlist(category,3,4,7,8)
label define treatment_r3 1 "Insurance" 2 "Insurance+IMD"
label value treatment treatment_r3
label var treatment "Treatment in Marketing Round 3"

drop category note // Drop unnecessory variables.

//SAVING CONSOLIDATED DATA SET
save "$mk/dta\AICWI2-FULL.dta", replace
save "$mk/dta\AICWI2-FULL BACKUP.dta", replace


/****************************************************************
	SECTION 2: Data Cleaning
****************************************************************/

clear
set more off

use "$mk/dta\AICWI2-FULL.dta", clear

//CHECKING FOR DUPLICATE HOUSEHOLD IDs
duplicates list a_1hhid
duplicates tag  a_1hhid, gen(duplicates)
*10 pairs of duplicates found

sort a_1hhid

drop if submissiondate == "Jun 8, 2014 7:11:21 AM" & a_1hhid == "A1089" // Both are identical across all variables. Dropped one entry.
drop if submissiondate == "May 15, 2014 10:54:57 AM" & a_1hhid == "F2271" // Both are identical across all variables. Dropped one entry.
drop if submissiondate == "May 15, 2014 11:23:20 AM" & a_1hhid == "F2317" // A second surveyor went to this HH because of wrong allocation, terminated when told survey was already complete
drop if submissiondate == "Jun 3, 2014 11:45:48 AM" & a_1hhid == "F2621" // Later version is correct and complete
drop if submissiondate == "Jun 3, 2014 10:52:29 AM" & a_1hhid == "F2846" // Both are identical. One has been dropped
drop if submissiondate == "May 28, 2014 4:45:45 PM" & a_1hhid == "P2134" //Incomplete survey dropped
drop if submissiondate == "Jun 19, 2014 2:26:07 PM" & a_1hhid == "P4570" //Survey was given to HH Head replacement. When HH Head became available, survey was retaken. Have retained survey with HH Head. 
drop if submissiondate == "Jun 11, 2014 10:40:51 PM" & a_1hhid == "P4843" //Survey was given to HH Head replacement. When HH Head became available, survey was retaken. Have retained survey with HH Head. 
drop if submissiondate == "Jul 1, 2014 3:50:37 PM" & a_1hhid == "P4920" //Survey was given to HH Head replacement. When HH Head became available, survey was retaken. Have retained survey with HH Head. 
drop if submissiondate == "Jul 1, 2014 3:50:46 PM" & a_1hhid == "P4922" //Survey has been carried out by two different surveyors, but with same responses. One has been dropped

// Fix household ID to be matched with round2
replace a_1hhid = "P1880" if (a_1hhid=="1880")
replace a_1hhid = "P533" if (a_1hhid=="533")

isid a_1hhid // Double-check whether ID variable is unique
drop duplicates

 //DROPPING UNNECESSARY VARIABLES AND STRIPPING DATASET OF PII

drop backch_accompsign_sup c_1_c_1_c_mig_dest backch_accompsign_mon anote a1note cnote dnote a_2identify key devicephonenum metainstanceid bnote bhhhead bintroconsent contno dnote_ins_intro dexplanationnote_ins dexplanationnote_ins1 dexplanationnote_ins2 dexplanationnote_ins3 dexplanationnote_ins4 dexplanationnote_ins5 dexplanationnote_ins6 dexplanationnote_ins7 dexplanationnote_ins8 dexplanationnote_ins9 dcomicnote_com1 dcomicnote_com2 dcomicnote_com3 dcomicnote_com4 dcomicnote_com5 dcomicnote_com6 dcomicnote_com7 dcomicnote_com8 dcomicnote_com9 dcomicnote_com10 dcomicnote_com11 dcomicnote_com12 dcomicnote_com13 dendinsnote_endins1 dendinsnote_endins2 dendinsnote_endins3 dendinsnote_endins4 d_notebuyins1 d_notenobuyins1 d_notesevisit d_noteinsend dimd_scriptnote_imd1 dimd_scriptnote_imd2 dimd_scriptnote_imd3 dimd_scriptnote_imd4 dimd_scriptnote_imd5 dimd_scriptnote_imd6 dimd_scriptnote_imd7 dimd_scriptnote_imd8 today deviceid subscriberid simid distid distname tehsid tehsname blockid blockname villid  villname doorno stname landmark
drop  b_10_surveyorsign b_12_respondentsign backch_accompsupervisor_name backch_accompsupervisor_other1 backch_accompsupervisor_other2 backch_accompmonitor_name backch_accompmonitor_other1 backch_accompmonitor_other2 backch_accompaccom_check backch_accompback_check metainstancename dimdscriptnote_imd1 dimdscriptnote_imd2 dimdscriptnote_imd3 dimdscriptnote_imd4 dimdscriptnote_imd5 dimdscriptnote_imd6 dimdscriptnote_imd7 dimdscriptnote_imd8 dimdscriptnote_imd9 dimdscriptnote_imd9
drop noconsent hhnotfound
drop  imd bintroconsent1 bintroconsent2 bintroconsent3 bintroconsent4 dnote_ins_intro1

//LABELLING DATASET

//Label variables

*SECTION A
			  
label variable a1_1locatehh "Able to Locate Household"
label variable a1_2reasonfornofind "Reasons For Not Locating"
label variable a1_2other "Other Reasons for Not Locating"
label variable father_husband "Father/Husband's Name"
label variable prevresp "Previous Respondent"
label variable starttime "Start Time"
label variable endtime "End Time"
label variable a_1hhid "Household ID"

*SECTION B

label variable b_1findecmaker "Name of Decision Maker"
label variable b_2availability "Was Decision Maker Availabe?"
label variable b_3hhheadreplace "Replacement Decision Maker"
label variable b_4hhmember "Relationship of Respondent to Decision Maker"
label variable b_4other "Other Relationship"
label variable b_5consent "Consent"
label variable b_6_address "Has Address Changed?"
label variable b_7_4address "Address"	
label variable b_7_1doorno "Door No"
label variable b_7_2stname "Street Name"
label variable b_7_3landmark "Landmark"
label variable b_8_contactno "Contact Number"
label variable b_9_new_no "New number"
label variable b_11_surveyorname "Surveyor Name"

*SECION C

label variable c_1_seasonal_mig "Did anyone migrate during the lean season (March 2014 ~ May 2014)?"
label variable c_1_a_member_mig "Who migrated?"
label variable c_1_a_other "If others migrated, who?"
label variable c_1_b_daysaway "How many days were they away?" 
label variable c_1_c_1_c_state "State"
label variable c_1_c_1_c_district "District"
label variable c_1_c_1_c_towncity "Town/City"
label variable c_1_d_whymigdest "Reason for Choosing Destination"
label variable c_1_d_other "Other Reasons for Destination"
label variable c_1_e_success "Did you find a job?" 
label variable c_1_f_findjob "How did you find your job?"
label variable c_1_f_other "Other ways of Finding Job"
label variable c_1_g_occupation "What did you do?"
label variable c_1_g_other "Other Occupation"
label variable c_1_h_hours "Hours Worked Per Day"
label variable c_1_i_months "Weeks Worked Per Month"
label variable c_1_j_1_j_earnings "Total Earnings"
label variable c_1_j_1_j_salary "Salary"
label variable c_1_j_1_j_kind "In Kind"
label variable c_1_k_earninglevel "Earned More?"
label variable c_1_l_nomigrate "Why No Migration?"
label variable c_1_l_other "Other Reasons for No Migration"

*SECTION D

label variable  d_1purchasins "Purchased Insurance"
label variable  d_2unitsins "Units Purchased"
label variable  d_3awstation "Aware of AWS"
label variable  d_4awslocation "Aware of AWS Location"
label variable  d_4awskms "Distance from AWS"
label variable  d_5datesecvisit "Second Visit Date"
label variable  d_6purchasins "Purchased Insurance Second Visit"
label variable  d_7unitsins "Units Purchased Second Visit"
label variable  d_8nobuyins "Why no insurance?"
label variable  d_8nobuyins "Why no insurance - Other?"
label variable  d_8nobuyins "Why no insurance?"
label variable  d_8_othernobuy "Why no insurance - Other?"
label variable  d_2_a_whybuy "Why buy insurance?"
label variable  d_2_a_otherbuy "Why buy insurance? - Other"
label variable  d_7_a_otherbuy "Why buy insurance Second Visit? - Other"
label variable  d_7_a_whybuy "Why buy insurance Second Visit?"

label define yesno 0 "No" 1 "Yes"

save "$mk/dta\labelled_dataset.dta", replace


			*****************************************************************************************************************
            ****************************************************SECTION A*****************************************************
            *****************************************************************************************************************
              
estpost tab states
esttab . using "${buildtab}/INTERVENTION2.rtf" , nostar unstack label append nomtitles title("State-wise Breakup")cells("b pct")
			  
*Were you able to locate the household?
label define noyes 0 "NO" 1 "YES"
label value a1_1locatehh noyes

*Why were you unable to locate the household?

//Adding "Merged" and "Temporarily Unavailable" to include oft-repeated answers in 'Other'
label define locatehousehold 1 "Shifted" 2 "Does Not Exist" 3 "Death" 4 "Merged" 5 "Temporarily Unavailable" 6 "Refused" -888 "Other"
label value a1_2reasonfornofind locatehousehold

//Recoding 'other' responses where they fall into categories already listed
replace a1_2reasonfornofind = 1 if strpos(a1_2other, "MIG") != 0 | strpos(a1_2other, "SHIFT") !=0 | strpos(a1_2other ,"mig") != 0 
replace a1_2reasonfornofind = 1 if strpos(a1_2other, "Mai") != 0 | strpos(a1_2other, "went") != 0 | strpos(a1_2other, "WENT") != 0 | strpos(a1_2other, "shift") != 0 | strpos(a1_2other, "mai") != 0 
replace a1_2reasonfornofind = 3 if strpos(a1_2other, "DEAD") != 0 | strpos(a1_2other, "dead") !=0
replace a1_2reasonfornofind = 5 if strpos(a1_2other, "fter") != 0 | strpos(a1_2other, "FTER") !=0 | strpos(a1_2other, "ft") !=0 | strpos(a1_2other, "AFT") != 0 | strpos(a1_2other, "Aft") != 0 | strpos(a1_2other, "TEMP") != 0
replace a1_2reasonfornofind = 6 if strpos(a1_2other, "REF") != 0 | strpos(a1_2other, "Ref") !=0 | a1_2other == "Baat karne se mana kiya hai"
replace a1_2reasonfornofind = 4 if strpos(a1_2other, "Same") != 0 | strpos(a1_2other, "same") != 0 | strpos(a1_2other, "SAME") != 0
replace a1_2reasonfornofind = 5 if strpos(a1_2other,"Resp")!=0

replace a1_2other="" if (a1_2other==".")

*generating summary for section A
estpost tab a1_1locatehh
esttab . using "${buildtab}/INTERVENTION2.rtf" , nostar unstack label append nomtitles title("Were you able to locate the household?")cells("b pct")
estpost tab a1_2reasonfornofind
esttab . using "${buildtab}/INTERVENTION2.rtf" , nostar unstack label append nomtitles title("Why were you unable to locate the household?")cells("b pct")

*graph pie, over(a1_1locatehh)
*graph pie, over(a1_2reasonfornofind)

			*****************************************************************************************************************
            ****************************************************SECTION B*****************************************************
            *****************************************************************************************************************
             
* Is Primary Decision Maker available?
label value b_2availability noyes
tab b_2availability

* If not, What is your relationship to primary decision maker?
label define relationship 1 "Spouse" 2 "Son" 3 "Daughter" 4 "Father" 5 "Mother" 6 "Brother" -888 "Other", replace
replace  b_4hhmember = - 888 if  b_4hhmember == 7 | b_4hhmember == 8 | b_4hhmember == 10 | b_4hhmember == 9
label value b_4hhmember relationship
tab b_4hhmember

* generating summary for section B 
* graph pie, over(b_2availability)
* graph pie, over(b_4hhmember)

estpost tab b_2availability
esttab . using "${buildtab}/INTERVENTION2.rtf" , nostar unstack label append nomtitles title("Was the primary decision maker available?")cells("b pct")

estpost tab b_4hhmember
esttab . using "${buildtab}/INTERVENTION2.rtf" , nostar unstack label append nomtitles title("Relationship of Substitute Respondent to HH Head")cells("b pct")

* attrition status
gen attrition=(a1_1locatehh==0 | b_5consent==0)
label var attrition "Failture to locate household OR refused to take survey"

			*****************************************************************************************************************
            ****************************************************SECTION C*****************************************************
            *****************************************************************************************************************
             
* Has anyone in your family migrated?
label define yesno 1 "Yes" 0 "No", replace
label value c_1_seasonal_mig yesno
estpost tab  c_1_seasonal_mig
esttab . using "${buildtab}/INTERVENTION2.rtf" , nostar unstack label append nomtitles title("Has anyone in your family migrated?")cells("b pct")

* Who migrated? MORE THAN ONE ANSWER


replace c_1_a_member_mig = "" if c_1_a_member_mig == "."
replace c_1_a_member_mig = "" if c_1_a_member_mig == "-888"
split c_1_a_member_mig, destring

label define whomigrated 1 "Household Head" 2 "Spouse" 3 "Son or Daughter" 4 "Daughter-in-law / Son-in-law" 5 "Grandson/Granddaughter" 6 "Parents" 7 "Father-in-law / Mother-in-law" 8 "Brother/Sister" 9 "Brother-in-law/Sister-in-law" 10 "Uncle/Aunt" -888 "Other", replace

foreach x in 1 2 3 {
	label var c_1_a_member_mig`x' "Who migrated? Member `x'"
	label value c_1_a_member_mig`x' whomigrated
	estpost tab  c_1_a_member_mig`x'
	esttab . using "${buildtab}/INTERVENTION2.rtf" , nostar unstack label append nomtitles title("Migrant `x'")cells("b pct")
}

*Following questions pertain to MOST RECENT EPISODE

* How many days were they away? (pertains to most recent episode)

clonevar daysaway=c_1_b_daysaway
gen daysaway_categorized = .
replace daysaway_categorized = 0 if  c_1_b_daysaway > 0 & c_1_b_daysaway <11
replace daysaway_categorized = 1 if  c_1_b_daysaway > 10 & c_1_b_daysaway <21
replace daysaway_categorized = 2 if  c_1_b_daysaway > 20 & c_1_b_daysaway <31
replace daysaway_categorized = 3 if  c_1_b_daysaway > 30 & c_1_b_daysaway <41
replace daysaway_categorized = 4 if  c_1_b_daysaway > 40 & c_1_b_daysaway <51
replace daysaway_categorized = 5 if  c_1_b_daysaway > 50 & c_1_b_daysaway <61
replace daysaway_categorized = 6 if  c_1_b_daysaway > 60 & c_1_b_daysaway <71
replace daysaway_categorized = 7 if  c_1_b_daysaway > 70 & c_1_b_daysaway <81
replace daysaway_categorized = 8 if  c_1_b_daysaway > 80 & c_1_b_daysaway <91

label define daysmigrated 0 "1-10" 1 "11-20" 2 "21-30" 3 "31-40" 4 "41-50" 5 "51-60" 6 "61-70" 7 "71-80" 8 "81-90" 9 "90+", replace
label value daysaway_categorized daysmigrated
label var daysaway_categorized "How many days were they away? (Categorized)"
estpost tab daysaway_categorized
esttab . using "${buildtab}/INTERVENTION2.rtf" , nostar unstack label append nomtitles title("Duration of Migration")cells("b pct")

* Where did they go?
	
	*state
gen statemig =  c_1_c_1_c_state
replace statemig = "" if statemig == "."
replace statemig = "Karnataka" if strpos(statemig,"Kar") != 0 | strpos(statemig,"KAR") != 0 | strpos(statemig,"Ban") != 0 | strpos(statemig,"BEN") != 0 | strpos(statemig,"Kal") != 0
replace statemig = "Andhra Pradesh" if strpos(statemig,"And") != 0 | strpos(statemig,"AND") != 0 | strpos(statemig,"AP") != 0 | strpos(statemig,"Ap") != 0 | strpos(statemig,"HYD") != 0 | strpos(statemig,"Hyd") != 0 | strpos(statemig,"Ap") != 0
replace statemig = "Abroad" if strpos(statemig,"AB") != 0 | strpos(statemig,"Ab") != 0
replace statemig = "Tamil Nadu" if strpos(statemig,"CHE") != 0 | strpos(statemig,"MAD") != 0 | strpos(statemig,"THAM") != 0 | strpos(statemig,"Tam") != 0
replace statemig = "Gujarat" if strpos(statemig,"GUJ") != 0 | strpos(statemig,"Guj") != 0
replace statemig = "Uttar Pradesh" if strpos(statemig,"Utt") != 0 | strpos(statemig,"Up") != 0
replace statemig = "Haryana" if strpos(statemig,"Har") != 0
replace statemig = "Delhi" if strpos(statemig,"Del") != 0
replace statemig = "Himachal Pradesh" if strpos(statemig,"Him") != 0
replace statemig = "Kerala" if strpos(statemig,"KER") != 0 | strpos(statemig,"Ker") != 0 | strpos(statemig,"ker") != 0
replace statemig = "Maharashtra" if strpos(statemig,"Mum") != 0
replace statemig = "Punjab" if strpos(statemig,"Pun") != 0
replace statemig = "Orissa" if strpos(statemig,"OR") != 0
label var statemig "To which state did they migrate?"
estpost tab statemig
esttab . using "${buildtab}/INTERVENTION2.rtf" , nostar unstack label append nomtitles title("Which state did you go to?")cells("b pct")

	*city
gen districtmig = c_1_c_1_c_district
replace districtmig = "" if statemig == "."
replace statemig = "" if statemig == "-999"
replace districtmig = "Hyderabad" if strpos(districtmig,"HYD") != 0 | strpos(districtmig,"Hyd") != 0
replace districtmig = "West Godavari" if strpos(districtmig,"WEST") != 0 | strpos(districtmig,"West") != 0
replace districtmig = "Varanasi" if strpos(districtmig,"Var") != 0
replace districtmig = "Chittoor" if strpos(districtmig,"CHIT") != 0
replace districtmig = "Bangalore" if strpos(districtmig,"BAN") != 0 | strpos(districtmig,"BEN") != 0 | strpos(districtmig,"Ben") != 0 | strpos(districtmig,"Ban") != 0
replace districtmig = "Guntur" if strpos(districtmig,"GUNT") != 0
replace districtmig = "East Godavari" if strpos(districtmig,"EAST") != 0
replace districtmig = "Chennai" if strpos(districtmig,"CHEN") != 0 | strpos(districtmig,"MAD") != 0
replace districtmig = "Faridabad" if strpos(districtmig,"Fari") != 0
replace districtmig = "Ludhiana" if strpos(districtmig,"Ludh") != 0 | strpos(districtmig,"Lodh") != 0
replace districtmig = "Kallakurichi" if strpos(districtmig,"KALAV") != 0 | strpos(districtmig,"KALVA") != 0
replace districtmig = "Nellore" if strpos(districtmig,"NEL") != 0 | strpos(districtmig,"Nel") != 0
replace districtmig = "Kodaikanal" if strpos(districtmig,"odai") != 0
replace districtmig = "Tiruppur" if strpos(districtmig,"hiru") != 0 
replace districtmig = "Kozhikode" if strpos(districtmig,"zhik") != 0 
replace districtmig = "Warangal" if strpos(districtmig,"WAR") != 0 
replace districtmig = "Coimbatore" if strpos(districtmig,"ooyampu") != 0 
replace districtmig = "" if strpos(districtmig,".") != 0 
replace districtmig = "Do Not Know" if strpos(districtmig,"99") != 0 
label var districtmig "To which district did they migrate?"

*Include splits of statemig "within state" "outside state" "abroad"
	gen statecategory = 2
	replace statecategory = 1 if (states == statemig)
	replace statecategory = 3 if statemig == "Abroad"
	label define statecategory 1 "Within State" 2 "Outside State" 3 "Abroad"
	label value statecategory statecategory
	label var statecategory "Did they migrate within state or not, or abroad?"
	estpost tab statecategory 
	esttab . using "${buildtab}/INTERVENTION2.rtf" , nostar unstack label append nomtitles title("Migrated Within State / Outside State")cells("b pct")

foreach i in "Andhra Pradesh" "Tamil Nadu" "Uttar Pradesh" {
	estpost tab statemig if states == "`i'"
	esttab . using "${buildtab}/INTERVENTION2.rtf" , nostar unstack label append nomtitles title("Migrants in`i' migrated to")cells("b pct")
	estpost tab statecategory if states == "`i'"
	esttab . using "${buildtab}/INTERVENTION2.rtf" , nostar unstack label append nomtitles title("Migrants in`i' migrated Within/Outside State")cells("b pct")
}
	* Why did they go there?
replace c_1_d_whymigdest = "" if c_1_d_whymigdest == "."
replace c_1_d_whymigdest =  "5" if  c_1_d_other == "Broker"
split c_1_d_whymigdest, destring
label define whymigdest 1 "Returning to Same Employer" 2 "Many Opportunities Available" 3 "Employer Recruited at the Village" 4 "Friends/Family at Destination" 5 "Close to Home" 6 "Common Migration Destination" -888 "Other", replace

foreach k in 1 2 3 {
	label var c_1_d_whymigdest`k' "Why did they migrate to that destination? Reason `k'"
	label value c_1_d_whymigdest`k' whymigdest
	estpost tab c_1_d_whymigdest`k'
	esttab . using "${buildtab}/INTERVENTION2.rtf" , nostar unstack label append nomtitles title("Reason No `k' for Choosing Destination")cells("b pct")
}

* Did they find employment?
label value c_1_e_success noyes
estpost tab c_1_e_success
esttab . using "${buildtab}/INTERVENTION2.rtf" , nostar unstack label append nomtitles title("Did they find employment?")cells("b pct")

* How did they find employment?
replace  c_1_f_findjob = "" if c_1_f_findjob == "."
label define howfindjob 1 "Return To Same Employer" 2 "Friend/Relative" 3 "Employer Came to Village" 4 "Employer came to Neighbourhood in Destination" 5 "Newspaper/Local Ads" 6 "Middleman" -888 "Other", replace
split  c_1_f_findjob, destring

foreach j in 1 2 {
	label var c_1_f_findjob`j' "How did they find a job? Reason `j'"
	label value c_1_f_findjob`j' howfindjob
	estpost tab c_1_f_findjob`j'
	esttab . using "${buildtab}/INTERVENTION2.rtf" , nostar unstack label append nomtitles title("How Job Was Found #`j'")cells("b pct")
}


* What job did they take up while migrating?
label define occupation 1 "Construction Worker" 2 "Driver" 3 "Factory Worker" 4 "Carpenter" 5 "Mason" 6 "Welder" 7 "Agricultural Labourer" 8 "Coolie" -999 "Do Not Know" -888 "Other", replace
//"Other" occupations include Lorry Cleaner, Painter, Security Guard, Tailor, Vegetable Vendor, Petrol Pump Manager
label value c_1_g_occupation occupation
estpost tab c_1_g_occupation
esttab . using "${buildtab}/INTERVENTION2.rtf" , nostar unstack label append nomtitles title("Job Taken Up By Migrant?")cells("b pct")

* How many hours per day did they work?
label define donotknow -999 "Do Not Know"
label value c_1_i_months  c_1_h_hours donotknow
estpost tab c_1_h_hours
esttab . using "${buildtab}/INTERVENTION2.rtf" , nostar unstack label append nomtitles title("Hours Worked Per Day")cells("b pct")

estpost tab c_1_i_months
esttab . using "${buildtab}/INTERVENTION2.rtf" , nostar unstack label append nomtitles title("Weeks Worked Per Month")cells("b pct")

*Total MigrationEarnings

foreach var in c_1_j_1_j_salary c_1_j_1_j_kind {
	replace `var'=.r if `var'==-777 // Refuse to answer
	replace `var'=.n if `var'==-666 // Not Applicable
	replace `var'=.d if `var'==-999 // Do not know
}
	// make categories 0-1000, 1 - 4000, 4000-8000, 8000-12000, 12-16000, 16-20, 20+
	
		*Wages/Salary
		tab c_1_j_1_j_salary
		gen salarycat_categorized = 0
		gen kindcat_categorized = 0
		replace salarycat_categorized = 1 if c_1_j_1_j_salary > 1000 & c_1_j_1_j_salary <= 4000
		replace salarycat_categorized = 2 if c_1_j_1_j_salary > 4000 & c_1_j_1_j_salary <= 8000
		replace salarycat_categorized = 3 if c_1_j_1_j_salary > 8000 & c_1_j_1_j_salary <= 12000
		replace salarycat_categorized = 4 if c_1_j_1_j_salary > 12000 & c_1_j_1_j_salary <= 16000
		replace salarycat_categorized = 5 if c_1_j_1_j_salary > 16000 & c_1_j_1_j_salary <= 20000
		replace salarycat_categorized = 6 if c_1_j_1_j_salary > 20000 
		label define salarycats 0 "< 1000" 1 "1000- 4000" 2 "4000-8000" 3 "8000-12000" 4 "12000-16000" 5 "16000-20000" 6 "> 20000"
		label value salarycat_categorized salarycats
		label var salarycat_categorized "How much wage/salary did they make?"
		estpost tab salarycat_categorized
		esttab . using "${buildtab}/INTERVENTION2.rtf" , nostar unstack label append nomtitles title("Salary (Wages) Earned in Migration Destination (INR)")cells("b pct")

	*In-kind
		replace kindcat_categorized = 1 if c_1_j_1_j_kind > 1000 & c_1_j_1_j_kind <= 4000
		replace kindcat_categorized = 2 if c_1_j_1_j_kind > 4000 & c_1_j_1_j_kind <= 8000
		replace kindcat_categorized = 3 if c_1_j_1_j_kind > 8000 & c_1_j_1_j_kind <= 12000
		replace kindcat_categorized = 4 if c_1_j_1_j_kind > 12000 & c_1_j_1_j_kind <= 16000
		replace kindcat_categorized = 5 if c_1_j_1_j_kind > 16000 & c_1_j_1_j_kind <= 20000
		replace kindcat_categorized = 6 if c_1_j_1_j_kind > 20000
		label value kindcat_categorized salarycats
		label var kindcat_categorized "How much value of in-kind items did they receive?"
		estpost tab kindcat_categorized
		esttab . using "${buildtab}/INTERVENTION2.rtf" , nostar unstack label append nomtitles title("Amount Earned in Kind (Equivalent INR)")cells("b pct")
		
	* Total Migration income
		egen migration_income=rowtotal(c_1_j_1_j_salary c_1_j_1_j_kind)
		label var migration_income "Total Migration Income (Salary + In_Kind)

* Did they earn more / less money than if they'd stayed back?

label value c_1_k_earninglevel yesno
estpost tab c_1_k_earninglevel
esttab . using "${buildtab}/INTERVENTION2.rtf" , nostar unstack label append nomtitles title("Did you earn more money than if you'd stayed back?")cells("b pct")

* Why didn't anyone migrate? MORE THAN ONE ANSWER

*Including "Old Age" under "Sickness/Death"
*Treat this more carefully on MS Excel 
label define whynomig 1 "Not Enough Money" 2 "Adequate Local Opportunities" 3 "No job info" 4 "No guarantee" 5 "Professional Commitment" 6 "100 Days Program" 7 "No one to Share Costs" 8 "No contacts outside" 9 "Death/Sickness at Home" 10 "Cannot Leave Family" -888 "Other", replace
split c_1_l_nomigrate, destring

foreach i in 1 2 3 4 5 {
	label var c_1_l_nomigrate`i' "Why did you not migrate? Reason `i'"
	label value c_1_l_nomigrate`i' whynomig
	estpost tab c_1_l_nomigrate`i'
	esttab . using "${buildtab}/INTERVENTION2.rtf" , nostar unstack label append nomtitles title("Reason for NOT Migrating `i'")cells("b pct")
}

					
				*****************************************************************************************************************
             	****************************************************SECTION D*****************************************************
				*****************************************************************************************************************
             

*First Visit - Do you want to buy insurance?

label value d_1purchasins noyes
estpost tab d_1purchasins
esttab . using "${buildtab}/INTERVENTION2.rtf" , nostar unstack label append nomtitles title("Do you want to buy insurance? - FIRST VISIT")cells("b pct")


*For those who say YES
	*How many units
	estpost tab  d_2unitsins
	esttab . using "${buildtab}/INTERVENTION2.rtf" , nostar unstack label append nomtitles title("No of Units - FIRST VISIT")cells("b pct")

	*Do you know where the nearest AWS is?
	label value d_3awstation noyes
	estpost tab  d_3awstation
	esttab . using "${buildtab}/INTERVENTION2.rtf" , nostar unstack label append nomtitles title("Do you know where the nearest AWS is?")cells("b pct")

	*Where is it?
	label define whereaws 1 "In Village" 2 "In block/mandal" 3 "In district" 4 "In state", replace
	label value d_4awslocation whereaws
	estpost tab d_4awslocation
	esttab . using "${buildtab}/INTERVENTION2.rtf" , nostar unstack label append nomtitles title("Where is the nearest AWS?")cells("b pct")

	*How far is it?
	clonevar distanceaws=d_4awskms
	tab distanceaws
	*Make categories : <5 , 5-10 , 10-15, 15-20, 20-30, 30-40, 40-50, 50-60, 60-70
	gen distanceaws_categorized = 1 if d_4awskms>0 & d_4awskms<=5
	replace distanceaws_categorized = 2 if d_4awskms>5 & d_4awskms<=10
	replace distanceaws_categorized = 3 if d_4awskms>10 & d_4awskms<=15
	replace distanceaws_categorized = 4 if d_4awskms>15 & d_4awskms<=20
	replace distanceaws_categorized = 5 if d_4awskms>20 & d_4awskms<=30
	replace distanceaws_categorized = 6 if d_4awskms>30 & d_4awskms<=40
	replace distanceaws_categorized = 7 if d_4awskms>40 & d_4awskms<=50
	replace distanceaws_categorized = 8 if d_4awskms>50 & d_4awskms<=60
	replace distanceaws_categorized = 9 if d_4awskms>60 & d_4awskms<=70
	label define distancecat 1 "<5 km" 2 "5-10 km" 3 "10-15 km" 4 "15-20 km" 5 "20-30 km" 6 "30-40 km" 7 "40-50 km" 8 "50-60 km" 9 "60-70 km", replace
	label value distanceaws_categorized distancecat
	label var distanceaws_categorized "How far is AWS in kilometer? (Categorized)"
	estpost tab distanceaws_categorized
	esttab . using "${buildtab}/INTERVENTION2.rtf" , nostar unstack label append nomtitles title("How far is the nearest AWS?")cells("b pct")

*For those who say NO
	*Why not? 
	label define whynoinsurance 1 "Too Expensive" 2 "No Need" 3 "Do Not Understand" 4 "Currently No Cash" 5 "Do Not Trust Insurance" 6 "Payout Unlikely" 7  "Too Early" 8 "Already Bought" 9 "No Bank Account" -888 "Other", replace
	//Recoding 'others' where necessary + adding two categories - No Bank Account + Already Purchased
	replace d_8_othernobuy = "" if d_8_othernobuy == "." 
		
	replace d_8nobuyins = d_8nobuyins + " " + "8" if strpos(d_8_othernobuy, "chuke") != 0 | strpos(d_8_othernobuy, "ALL") != 0 | strpos(d_8_othernobuy, "ALR") != 0 | strpos(d_8_othernobuy, "Alr") != 0 | strpos(d_8_othernobuy, "Allr") != 0 | strpos(d_8_othernobuy, "alr") != 0 | strpos(d_8_othernobuy, "hle") != 0 | strpos(d_8_othernobuy, "march") != 0 | strpos(d_8_othernobuy, "purshesed") != 0 | strpos(d_8_othernobuy, "arly") != 0
	replace d_8_othernobuy = "" if strpos(d_8_othernobuy, "chuke") != 0 | strpos(d_8_othernobuy, "ALL") != 0 | strpos(d_8_othernobuy, "ALR") != 0 | strpos(d_8_othernobuy, "Alr") != 0 | strpos(d_8_othernobuy, "Allr") != 0 | strpos(d_8_othernobuy, "alr") != 0 | strpos(d_8_othernobuy, "hle") != 0 | strpos(d_8_othernobuy, "march") != 0 | strpos(d_8_othernobuy, "purshesed") != 0 | strpos(d_8_othernobuy, "arly") != 0
	
	replace d_8nobuyins = d_8nobuyins + " " + "9" if strpos(d_8_othernobuy, "bank") != 0 | strpos(d_8_othernobuy, "BANK") != 0 | strpos(d_8_othernobuy, "Bank") != 0 
	replace d_8_othernobuy = "" if strpos(d_8_othernobuy, "bank") != 0 | strpos(d_8_othernobuy, "BANK") != 0 | strpos(d_8_othernobuy, "Bank") != 0 

	replace d_8nobuyins = d_8nobuyins + " " + "6" if strpos(d_8_othernobuy, "arsat") != 0 | strpos(d_8_othernobuy, "rain") != 0 
	replace d_8_othernobuy = "" if strpos(d_8_othernobuy, "arsat") != 0 | strpos(d_8_othernobuy, "rain") != 0 

	replace d_8nobuyins = d_8nobuyins + " " + "5" if strpos(d_8_othernobuy, "efore") != 0  
	replace d_8_othernobuy = "" if strpos(d_8_othernobuy, "efore") != 0 
	//Coded "Tried before, no payout" as "Do Not Trust Insurance"
	
	replace d_8nobuyins = d_8nobuyins + " " + "1" if strpos(d_8_othernobuy, "famil") != 0  
	replace d_8_othernobuy = "" if strpos(d_8_othernobuy, "famil") != 0
	//Coded "family in poor circumstances" as "Too Expensive"
	
	replace d_8nobuyins = d_8nobuyins + " " + "4" if strpos(d_8_othernobuy, "income") != 0  
	replace d_8_othernobuy = "" if strpos(d_8_othernobuy, "income") != 0
	
	tab d_8_othernobuy
	
	split d_8nobuyins, destring
	
foreach d in 1 2 3 4 {
	label var d_8nobuyins`d' "Why did you not buy insurance? Reason `d'"
	label value d_8nobuyins`d' whynoinsurance
	estpost tab d_8nobuyins`d'
	esttab . using "${buildtab}/INTERVENTION2.rtf" , nostar unstack label append nomtitles title("Reason #`d' for No Insurance")cells("b pct")
}

*Why buy insurance?
label define whyinsurance 1 "TV/Radio/Newspaper Predict Delayed Monsoon" 2 "Family/Friends Suggested" 3 "Intuition Suggests Delayed Monsoon" 4 "Exposure to IFMR" 5 "Holding Cash to Purchase" 6 "IMD Pie Chart" -888 "Other", replace
replace d_2_a_whybuy = d_2_a_whybuy + " " + "4" if strpos(d_2_a_otherbuy, "IFMR") != 0
split d_2_a_whybuy, destring

foreach v in 1 2 3 4 {
	label var d_2_a_whybuy`v' "(1st visit) Why did you buy insurance? Reason `v'"
	label value d_2_a_whybuy`v' whyinsurance
	estpost tab d_2_a_whybuy`v' 
	esttab . using "${buildtab}/INTERVENTION2.rtf" , nostar unstack label append nomtitles title("Reason #`v' for Purching Insurance - FIRST VISIT")cells("b pct")
}

//Other reasons include "Children's Future", "I like your explanation")
	
//SECOND VISIT

*Want insurance?
label value d_6purchasins noyes
estpost tab d_6purchasins
esttab . using "${buildtab}/INTERVENTION2.rtf" , nostar unstack label append nomtitles title("Do you want insurance? - SECOND VISIT")cells("b pct")

*How much>
estpost tab  d_7unitsins
esttab . using "${buildtab}/INTERVENTION2.rtf" , nostar unstack label append nomtitles title("Number of  units - SECOND VISIT ")cells("b pct")

*Why buy insurance?
replace d_7_a_whybuy = d_7_a_whybuy + " " + "4" if strpos(d_7_a_otherbuy, "Ifmr") != 0
split d_7_a_whybuy, destring

foreach v in 1 2 3 {
	label var d_7_a_whybuy`v' "(2nd visit) Why did you buy insurance? Reason `v'"
	label value d_7_a_whybuy`v' whyinsurance
	estpost tab d_7_a_whybuy`v' 
	esttab . using "${buildtab}/INTERVENTION2.rtf" , nostar unstack label append nomtitles title ("Reason #`v' for Purchasing Insurance") cells ("b pct")
}


//COMBINING FIRST VISIT AND SECOND VISIT
*replace d_6purchasins = 0 if d_6purchasins == .
*replace d_1purchasins = 0 if d_1purchasins == .
egen insurance_agreed = rowtotal(d_1purchasins d_6purchasins)
label value insurance_agreed noyes
label var insurance_agreed "Did you purchase insurance in either visit in round 3?"
estpost tab insurance_agreed 
esttab . using "${buildtab}/INTERVENTION2.rtf" , nostar unstack label append nomtitles title ("Insurance Purchased?") cells ("b pct")

gen insurance_purchased_visit = .
replace insurance_purchased_visit = 1 if d_1purchasins == 1
replace insurance_purchased_visit = 2 if d_6purchasins == 1
label define purchasedvisit /*0 "Round 2 Not Purchased"*/ 1 "Round 3 Visit 1" 2 "Round 3 Visit 2"
label value insurance_purchased_visit purchasedvisit
label var insurance_purchased_visit "In which visit did you purchase insurance during Round 3?"
 
estpost tab insurance_purchased_visit
esttab . using "${buildtab}/INTERVENTION2.rtf" , nostar unstack label append nomtitles title ("In Which Visit was Insurance Purchased? ") cells ("b pct")

*replace d_2unitsins = 0 if d_2unitsins == .
*replace d_7unitsins = 0 if d_7unitsins == .
egen insurance_unit_purchased = rowtotal(d_2unitsins d_7unitsins)
replace insurance_unit_purchased=. if (insurance_agreed!=1) // Correctedly skipped
label var insurance_unit_purchased "Total number of insurance purchased from both rounds"
estpost tab insurance_unit_purchased
esttab . using "${buildtab}/INTERVENTION2.rtf" , nostar unstack label append nomtitles title ("How many units purchased? ") cells ("b pct")

// Drop intervention variable (will be merged with correct intervention information later)
drop treatment

save "$mk\MarketinRound2.dta", replace

order a_1hhid states attrition, first
order a1_* b_* c_* d_*, after(prevresp)
foreach x of varlist _all {
	rename `x' r3_`x'
}

rename (r3_a_1hhid r3_states) (a_1hhid state)

/****************************************************************
	SECTION 3: Save and Exit		 									
****************************************************************/

compress
save "${builddta}/round3/IN_rainfall_r3_cleaned.dta", replace

cap file close _all
cap log close
copy "${buildlog}/`name_do'.smcl" ///
	"${buildlog}/archive/`name_do' - `c(current_date)' - `c(username)'.smcl" ///
	, replace
exit
	
