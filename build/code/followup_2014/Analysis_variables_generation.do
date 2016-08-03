/*****************************************************************
PROJECT: 		IN_Rainfall, India Rainfall Insurance
				
TITLE:			Analysis_variables_generation.do
			
AUTHOR: 		Seungmin Lee (seungmin.lee@yale.edu, eatorange@gmail.com)

DATE CREATED:	April 8, 2016

LAST EDITED:	April 9, 2016 by Seungmin Lee

DESCRIPTION: 	Generate custom variables for analyses from 2014 follow-up survey data
	
ORGANIZATION:	0 - Preamble
				1 - 
				X - Save and Exit
				
INPUTS: 		
				
OUTPUTS: 		${builddta}/followup_2014/Analysis_variables.dta
				
NOTE:			
******************************************************************/

/****************************************************************
	SECTION 0: Preamble					 									
****************************************************************/

version 13.1

set more off
clear all
cap log close 

loc name_do Analysis_variables_generation
log using "${buildlog}/`name_do'", replace


/****************************************************************
	SECTION 0: Generate Variables			 									
****************************************************************/

// Masterdata (Id)
use "${builddta}/followup_2014/MasterData_cleaned.dta", clear
isid Id
keep Id
tempfile Id
save `Id'



************************  Section A (Household Roster)  **********************************

use "${builddta}/followup_2014/SectionA1_HHroster_cleaned.dta", clear

// # of household member
bys Id: egen NumberOfHHmembers = count(subid)
notes NumberOfHHmembers: bys Id: egen NumberOfHHmembers = count(subid)
label var NumberOfHHmembers "Number of HH members"

// # of household member engaged in daily wage employment since June 2014
bys Id: egen temp = count(subid) if (q106_engdlywageemp==1)
bys Id: egen NumberOfHHmembers_dailyworker = max(temp)
replace NumberOfHHmembers_dailyworker=0 if mi(NumberOfHHmembers_dailyworker)
notes NumberOfHHmembers_dailyworker: bys Id: egen NumberOfHHmembers_dailyworker = count(subid) if (q106_engdlywageemp==1)
label var NumberOfHHmembers_dailyworker "Number of HH members engaged in daily wage employment since June 2014"
drop temp

// Total household health expenditure
bys Id: egen Health_Expenditure_Kharif = sum(q110_hlthexpkha)
notes Health_Expenditure_Kharif: bys Id: egen Health_Expenditure_Kharif = sum(q110_hlthexpkha)
label var Health_Expenditure_Kharif "Total household health expenditure since the beginning of Kharif season"

// Per capita household health expenditure
gen Health_Expenditure_pc_Kharif = (Health_Expenditure_Kharif/NumberOfHHmembers)
notes Health_Expenditure_pc_Kharif: gen Health_Expenditure_pc_Kharif = (Health_Expenditure_Kharif/NumberOfHHmembers)
label var Health_Expenditure_pc_Kharif "Per capita household health expenditure since the beginning of Kharif season"

keep Id NumberOfHHmembers-Health_Expenditure_pc_Kharif
duplicates drop
isid Id
tempfile SecA
save `SecA'


// Section B1

use "${builddta}/followup_2014/SectionB1_WageIncome_cleaned.dta", clear

// Number of Agricultural wage earners in a household
bys Id: egen NumberOfAgrEarners = count(subid)
notes NumberOfAgrEarners: bys Id: egen NumberOfAgrEarners = count(subid)
label var NumberOfAgrEarners "Number of Agricultural wage earners in a household - Kharif"

// Total earning (money + non-monetary compensation) - using cleaned variable
egen Total_agri_earning_kharif_indiv = rowtotal (q208_totearnlolagrikha11_c q211_totvalnonmonkha11_c)
notes Total_agri_earning_kharif_indiv: egen Total_agri_earning_kharif_indiv = rowtotal (q208_totearnlolagrikha11_c q211_totvalnonmonkha11_c)
label var Total_agri_earning_kharif_indiv "Total individual earning (monetary + compensation) from agricultural wage employment - Kharif"

// Average daily wage: Total earning divided by # of days worked
gen Daily_agri_wage_kharif_indiv = (Total_agri_earning_kharif_indiv / q206_totdaylocagrikhar11)
notes Daily_agri_wage_kharif_indiv: gen Daily_agri_wage_kharif_indiv = (Total_agri_earning_kharif_indiv / q206_totdaylocagrikhar11) 
label var Daily_agri_wage_kharif_indiv "Daily wage from agricultrual employment in Kharif (Individual-average)"

// Total household earning
bys Id: egen Total_agri_earning_kharif_HH = sum(Total_agri_earning_kharif_indiv) 
notes Total_agri_earning_kharif_HH: bys Id: egen Total_agri_earning_kharif_HH = sum(Total_agri_earning_kharif_indiv)
label var Total_agri_earning_kharif_HH "Total household earning (monetary + compensation) from agricultural wage employment - Kharif"

// Total # of days worked - Household level
bys Id: egen Total_agri_worksdays_HH = sum(q206_totdaylocagrikhar11) 
notes Total_agri_worksdays_HH: bys Id: egen Total_agri_worksdays_HH = sum(q206_totdaylocagrikhar11)
label var Total_agri_worksdays_HH "# of days worked in Kharif - HH level"

// Average daily wage - Household level.
gen Daily_agri_wage_kharif_HH = (Total_agri_earning_kharif_HH / Total_agri_worksdays_HH) 
notes Daily_agri_wage_kharif_HH: gen Daily_agri_wage_kharif_HH = (Total_agri_earning_kharif_HH / Total_agri_worksdays_HH)
label var Daily_agri_wage_kharif_HH "Daily wage from agricultrual employment in Kharif (Household-average)"

// Keep HH-level variables only
keep Id NumberOfAgrEarners Total_agri_earning_kharif_HH Total_agri_worksdays_HH Daily_agri_wage_kharif_HH
duplicates drop
isid Id
tempfile SecB1
save `SecB1'



// Section B2
use "${builddta}/followup_2014/SectionB2_NonAgri_WageIncome_cleaned.dta", clear

// Total individual earning (estimated)
gen Tot_Nonag_earn_Kharif_indiv_est = q214_totdaynonagriwork * q217_avdaiwag 
notes Tot_Nonag_earn_Kharif_indiv_est: gen Tot_Nonagri_earning_Kharif_indiv_est = q214_totdaynonagriwork * q217_avdaiwag
label var Tot_Nonag_earn_Kharif_indiv_est "Total individual non-agricultural earning (estimated)"

/// Total household earning
bys Id: egen Tot_Nonag_earn_Kharif_HH = sum(q218_totearnlocnonagr)
label var Tot_Nonag_earn_Kharif_HH "Total household non-agricultural earning - Kharif"

/// Total household earning (estimated)
bys Id: egen Tot_Nonag_earn_Kharif_HH_est = sum(Tot_Nonag_earn_Kharif_indiv_est) 
label var Tot_Nonag_earn_Kharif_HH_est "Total household non-agricultural earning (estimated)"

/// Total number of days worked - HH level
bys Id: egen Tot_Nonag_worksdays_HH = sum(q214_totdaynonagriwork) 
label var Tot_Nonag_worksdays_HH "Total household non-agricultural workdays - Kharif"

/// Average daily wage - Household level.
gen Daily_Nonagr_wage_kharif_HH = (Tot_Nonag_earn_Kharif_HH_est / Tot_Nonag_worksdays_HH) 
label var Daily_Nonagr_wage_kharif_HH "Daily non-agricultural wage in Kharif (Household-average)"
notes Daily_Nonagr_wage_kharif_HH: gen Daily_Nonagr_earn_kharif_HH = (Tot_Nonag_earn_Kharif_HH_est / Tot_Nonag_worksdays_HH)

/// Keep HH-level variables only
keep Id Tot_Nonag_earn_Kharif_HH Tot_Nonag_worksdays_HH Daily_Nonagr_wage_kharif_HH
duplicates drop
isid Id
tempfile SecB2
save `SecB2'


// Section M1: Lean period earning
use "${builddta}/followup_2014/SectionM1_LeanPeriod_cleaned.dta", clear

egen Tot_earning_lean_indiv = rowtotal (q223_2_homeearning q224_destearning q225_7_totmnrgaearning) // Total earning (indiv-level)
bys Id: egen Tot_earning_lean_HH = sum(Tot_earning_lean_indiv) // Total earning (HH-level)
bys Id: egen Avg_monthly_income_lean_HH = sum(q223_1_avgmonthwage) // Avg earning (HH-level)
bys Id: egen Tot_saving_lean_HH = sum(q224_1_homesaving) // Total saving (HH-level)

notes Tot_earning_lean_indiv: egen Tot_earning_indiv = rowtotal (q223_2_homeearning q224_destearning q225_7_totmnrgaearning)
notes Tot_earning_lean_indiv: earning at home + earning at destination + earning via MNREGA
notes Tot_earning_lean_HH: bys Id: egen Tot_earning_HH = sum (Tot_earning_lean_indiv)
notes Avg_monthly_income_lean_HH:bys Id: egen Avg_monthly_income_lean_HH = sum(q223_1_avgmonthwage)
notes Tot_saving_lean_HH: bys Id: egen Tot_saving_lean_HH = sum(q224_1_homesaving)

label var Tot_earning_lean_indiv "Total individual earning during lean period"
label var Tot_earning_lean_HH "Total household earning during lean period "
label var Avg_monthly_income_lean_HH "Average household monthly income during lean period"
label var Tot_saving_lean_HH "Total household saving during lean period"

foreach var in Tot_earning_lean_indiv Tot_earning_lean_HH Avg_monthly_income_lean_HH Tot_saving_lean_HH {
	notes `var': Lean period is from April to July in UP and AP, and from June to September in TN
}
*

keep Id Tot_earning_lean_HH Avg_monthly_income_lean_HH Tot_saving_lean_HH
duplicates drop
isid Id
tempfile SecM1
save `SecM1'


// Section M2: Migration during lean season

* M2A
use "${builddta}/followup_2014/SectionM2A_Migration_LeanPeriod_cleaned.dta", clear


/// Migrated during Lean season
keep if q219_migserwork==1 // Keep only household members who actually migrated
loc var migrant_lean_HH
gen `var'=1
label var `var' "Any household member migrated for work during cropping season"
label value `var' yesno

/// Total # of HH members migrated - lean season
loc var migmembers_lean_HH
bys Id: egen `var' = count(subid)
lab var `var' "# of HH members migrated during lean season - HH level"

/// Total migration episodes per HH
loc var migepisodes_lean_HH
bys Id: egen `var'=count(q213_4_migepisode)
lab var `var' "Total migration episodes during lean season - HH level"

/// Total days migrated during lean season - HH level
loc var migdays_lean_HH
bys Id: egen `var' = sum(q222_1_days)
lab var `var' "Total # of days HH members migrated - HH total"


/// Total migration expense (travel + others (visa fee, etc.) + food & lodging before finding a job), per each episode
loc var migexpense_lean_episode
egen `var' = rowtotal(q12_costoftravel q13_otrcostmig q21_costfoodlodge)
lab var `var' "Total migration expense during lean season, per migration episode"
note `var': Travel cost + other cost + food & lodging at migration destination


/// Migration expenses - HH level
loc var migtravelcost_lean_HH
bys Id: egen `var' = sum(q12_costoftravel)
lab var `var' "Migration travel cost during lean season - HH level"

loc var migothercost_lean_HH
bys Id: egen `var' = sum(q13_otrcostmig)
lab var `var' "Other migration cost (ex. VISA fee, etc.) - HH level"

loc var migfoodlodgegcost_lean_HH
bys Id: egen `var' = sum(q21_costfoodlodge)
lab var `var' "Cost of food and lodging before starting work at migrationd destination"

loc var migexpense_lean_HH
bys Id: egen `var' = sum(migexpense_lean_episode)
lab var `var' "Total migration expense during lean season - HH level"
note `var': Travel cost + other cost + food & lodging at migration destination
drop migexpense_lean_episode


/// Days of travel + days taken before starting a job at migration destination - HH total
loc var migtraveldays_lean_HH
bys Id: egen `var' = sum(q14_daytoreach1)
lab var `var' "Total days of migration travel - HH total"

loc var migdaysbeforejob_lean_HH
bys Id: egen `var' = sum(q20_daytotakejob)
lab var `var' "Total days taken before starting work at migration destination - HH total"

/// Savings from migration episode
loc var migsaving_lean_HH
bys Id: egen `var' = sum(q21_1_savingonreturn)
lab var `var' "Total savings from migration during lean season"


/*
// Tag outliers
loc money_vars (list of variables to be tagged)
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
*/

keep Id migrant_lean_HH-migsaving_lean_HH
duplicates drop
isid Id
tempfile SecM2A
save `SecM2A'


*M2B: Migration Remittance during lean season
use "${builddta}/followup_2014/SectionM2B_Migration_LeanPeriod_cleaned.dta", clear

/// Total migration income during lean season - HH level
loc var migincome_lean_HH
bys Id: egen `var' = sum(q25_totincome)
lab var `var' "Total Migration income during lean season, HH-level"

/// Migration remittance
loc var migremitt_lean_HH
bys Id: egen `var' = min(q26_sendtohh)
recode `var' (1/3=1) (4=0)
lab var `var' "Whether HH member remitted migration income"
lab value `var' yesno

loc var migremittcost_lean_HH
bys Id: egen `var'=sum(q29_costofremittance)
lab var `var' "Total remittance cost - HH total"

keep Id migincome_lean_HH migremitt_lean_HH migremittcost_lean_HH
duplicates drop
isid Id
tempfile SecM2B
save `SecM2B'

*Merge M2A and M2B
use `SecM2A', clear
/* I (SL) decided to keep observations which have complete responses only - who answered both M2A and M2B - to maintain consistency in responses. 
Also, the number of HHs with complete response (299) is not significantly different from # of HH who originallay answered "migrated" in q213 (319). */
merge 1:1 Id using `SecM2B', nogen keep(3)
tempfile SecM2
save `SecM2'

/// Avg daily earning via migration (lean season)
loc var migavgdailyearn_lean_HH
gen `var' = (migincome_lean_HH/migdays_lean_HH) // Daily earning = Total income / total days migrated
note `var': Avg daily earning = (Total income at migration / Total days migrated)
label var `var' "Average daily earning at migration during lean season - HH level average"

// Section M3: Migration during Cropping Season
use "${builddta}/followup_2014/SectionM3_CropSeason_cleaned.dta", clear
keep if match_roster_q218X==3 // We keep observations with complete responses only.

/// Migrated during Cropping season
*bys Id: egen migrant_cropseason_HH = min(q218_6_migsearwor) // If there's any migrant worker, then min(q218_6_migsearwor) should equal to 1. 2 otherwise.
keep if q218_6_migsearwor==1 // Keep only household members who actually migrated
loc var migrant_crop_HH
gen `var'=1
label var `var' "Any household member migrated for work during cropping season"
label value `var' yesno

/// Total migration episodes per household
loc var migepisodes_crop_HH
bys Id: egen `var'=count(q218_8_migepisode)
lab var `var' "Total migration episodes during cropping season - HH level"

/// Total migration income during cropping season - HH level
loc var migincome_crop_HH
bys Id: egen `var' = sum(q218_16_totearning) // if (q218_6_migsearwor==1)
label var `var' "Total income at migration destination during cropping season - HH level"

/// Total migration day during cropping season - HH level
loc var migdays_crop_HH
bys Id: egen `var' = sum(q218_11_daysepisode) // if (q218_6_migsearwor==1)
label var `var' "Total # days migrated during cropping season, HH level"

/// Avg daily earning via migration (cropping season)
loc var migavgdailyearn_crop_HH
gen `var' = (migincome_crop_HH/migdays_crop_HH) // Daily earning = Total income / total days migrated
note `var': Avg daily earning = (Total income at migration / Total days migrated)
label var `var' "Average daily earning at migration during cropping season - HH level average"

keep Id migrant_crop_HH-migavgdailyearn_crop_HH
duplicates drop
isid Id
tempfile SecM3
save `SecM3'


// Section M4: MNREGA during Kharif (cropping season)
use "${builddta}/followup_2014/SectionM4_MRNREGA_Kharif_cleaned.dta", clear
keep if (q218_22_mnrega==1) // Keep employed observations only

/// Generate variables for analysis

loc var MNREGA_employed_Kharif_HH
gen `var' = 1
lab var `var' "Was anyone in HH employed under MNREGA during Kharif season?"

loc var MNREGA_numemployed_Khariff_HH
bys Id: egen `var' = count(subid)
lab var `var' "# of HH members employed under MNREGA during Kharif season"

loc var MNREGA_days_Khariff_HH
bys Id: egen `var' = sum(q218_23_daysempl)
lab var `var' "# of days in total HH members employed under MREGA during Kharif season"

loc var MNREGA_earning_Kharif_HH
bys Id: egen `var' = sum(q218_24_totearning)
lab var `var' "Total earning HH members earned under MNNREGA during Kharif season"

keep Id MNREGA*
duplicates drop
isid Id
tempfile SecM4
save `SecM4'


// Section C: Other Income
use "${builddta}/followup_2014/SectionC_OtherIncome_Kharif_cleaned.dta", clear

// Total "other income"
loc var Otherearn_Kharif_HH
egen `var' = rowtotal(q226_totincearnrecei_? q226_totincearnrecei_??)
note `var': egen `var' = rowtotal(q226_totincearnrecei_? q226_totincearnrecei_??)
note `var': Total income from other sources suchs family business, sale of asset, animals, pension, etc.
label var `var' "Total amount of earning from other sources during Kharif season"

// Keep HH-level analysis variables only
keep Id Otherearn_Kharif_HH
duplicates drop
isid Id
tempfile SecC
save `SecC'


// Section D1: Cultivation Details
use "${builddta}/followup_2014/SectionD1_CultivationDetail_cleaned.dta", clear

/// Ag-Coops

loc var AgCoop_enrolled_HH
clonevar `var'=q300_AgrCoop
lab var `var' "Is anyone in HH a part of Agricultural Cooperative?"

loc var AgCoop_numenrolled_HH
gen `var'=0
replace `var' = `var'+1 if !mi(q300_1_listname1) & !inlist(q300_1_listname1,"-999","1","3")
replace `var' = `var'+1 if !mi(q300_1_listname2)
replace `var' = `var'+1 if !mi(q300_1_listname3)
lab var `var' "# of AgCoops HH members enrolled in"

loc var AgCoop_memberfee_HH
egen `var' = rowtotal(q300_4_MemFee1 q300_4_MemFee2 q300_4_MemFee3), missing
lab var `var' "Total AgCoop membership fee HH paid"

loc var AgCoop_estbenefit_HH
egen `var' = rowtotal(q300_5_EstBen1 q300_5_EstBen2 q300_5_EstBen3), missing
lab var `var' "Total estimated benefits from AgCoop"


/// Land cultivation

loc var cultivated_crop_Kharif
clonevar `var'=q301_lastyeahhcropownrent
lab var `var' "HH cultivated crops on either own or rented land during Kharif 2014"

loc var cultivated_irrcrop_2014
clonevar `var'=q302_lastyeahhIrrcropownrent
lab var `var' "HH cultivated irregular crops on either own or rented land last year (Jan - Dec 2014)"



/// Convert the unit of land area into single unit ("acre")
/// Unit convert sourece: http://www.webconversiononline.com/area-conversion.aspx

scalar bhigha_to_acre=0.4004
scalar cent_to_acre=0.01
scalar kuzhi_to_acre=0.0132 // This is from Wiki: https://en.wikipedia.org/wiki/Tamil_units_of_measurement
scalar guntha_to_acre=(1/40)
scalar biswa_to_acre=8.0083
scalar hectare_to_acre=2.4711
scalar kuli_to_acre=(1/2.25) // Source: https://tamilvaralaru.wordpress.com/tamil-units-of-measurement/
scalar MA_to_acre=(6.43/20) // 20 MA = 1 Veli = 6.43 acre. Source: https://en.wikipedia.org/wiki/Tamil_units_of_measurement
	
forval i=1/4 {
	*local l`i': variable label q301_1_1_AreaCult_`i'
	loc v AreaCult_`i'
	clonevar `v'=q301_1_1_AreaCult_`i'
	
	replace `v' = `v' * bhigha_to_acre if inlist(q301_2_AreaUnit_`i',2,6)
	replace `v' = `v' * cent_to_acre if (q301_2_AreaUnit_`i'==3)
	replace `v' = `v' * guntha_to_acre if (q301_2_AreaUnit_`i'==4)
	replace `v' = `v' * biswa_to_acre if (q301_2_AreaUnit_`i'==5)
	replace `v' = `v' * kuli_to_acre if (q301_2_AreaUnit_`i'==7)
	replace `v' = `v' * MA_to_acre if (q301_2_AreaUnit_`i'==8)
	
	note `v': Unit is acre.
}
*

forval i=1/4 {
	*local l`i': variable label q301_1_1_AreaCult_`i'
	loc v AreaIrreCult_`i'
	clonevar `v'=q302_1_AreaCult_`i'
	
	replace `v' = `v' * bhigha_to_acre if inlist(q302_2_AreaUnit_`i',2,6)
	replace `v' = `v' * cent_to_acre if (q302_2_AreaUnit_`i'==3)
	replace `v' = `v' * guntha_to_acre if (q302_2_AreaUnit_`i'==4)
	replace `v' = `v' * biswa_to_acre if (q302_2_AreaUnit_`i'==5)
	replace `v' = `v' * kuli_to_acre if (q302_2_AreaUnit_`i'==7)
	replace `v' = `v' * MA_to_acre if (q302_2_AreaUnit_`i'==8)
	
	note `v': Unit is acre.
}
*

rename	(AreaCult_1 AreaCult_2 AreaCult_3 AreaCult_4 AreaIrreCult_1 AreaIrreCult_2 AreaIrreCult_3 AreaIrreCult_4) ///
		(Ownirrig_crop_Kharif Ownnonirrig_crop_Kharif Leasedirrig_crop_Kharif Leasednonirrig_crop_Kharif ///
		Ownirrig_irrecrop_2014 Ownnonirrig_irrecrop_2014 Leasedirrig_irrecrop_2014 Leasednonirrig_irrecrop_2014)


// Save
keep Id AgCoop_enrolled_HH-Leasednonirrig_irrecrop_2014
duplicates drop
isid Id
tempfile SecD1
save `SecD1'
		
		
// Section E: 2014 Kharif Crop

* Kharif Crop roster
*** Note: I (SL) included only 5 major crops (Paddy, Maize, Bajra, Jawar) described in Section D2. 
*** Wheat is NOT included, since there is only 1 response 

use "${builddta}/followup_2014/SectionE_KharifCrop_Roster_cleaned.dta", clear
rename q316_HHculkarownrent cultivate_13to15_Kharif
*keep if cultivate_13to15_Kharif==1 // (Keep only those who did/will cultivate crops from 2013 to 2015)

/// Clean 5 major crops by names & code
gen cropname_cleaned = soundex(q317_namecrop)
replace cropname_cleaned = "PADDY" if (cropname_cleaned=="P300")
replace cropname_cleaned = "MAIZE" if (cropname_cleaned=="M200")
replace cropname_cleaned = "JAWAR" if inlist(cropname_cleaned,"J600","J613")
replace cropname_cleaned = "BAJRA" if (cropname_cleaned=="B260")
replace cropname_cleaned = "Others" if !inlist(cropname_cleaned,"PADDY","MAIZE","JAWAR","BAJRA")

/// Convert the unit of land area into single unit ("acre")
/// Unit convert sourece: http://www.webconversiononline.com/area-conversion.aspx

scalar bhigha_to_acre=0.4004
scalar cent_to_acre=0.01
scalar kuzhi_to_acre=0.0132 // This is from Wiki: https://en.wikipedia.org/wiki/Tamil_units_of_measurement
scalar guntha_to_acre=(1/40)
scalar biswa_to_acre=8.0083
scalar hectare_to_acre=2.4711
scalar kuli_to_acre=(1/2.25) // Source: https://tamilvaralaru.wordpress.com/tamil-units-of-measurement/
scalar MA_to_acre=(6.43/20) // 20 MA = 1 Veli = 6.43 acre. Source: https://en.wikipedia.org/wiki/Tamil_units_of_measurement

rename (q319_crop10kha q321_crop11kha q323_plancropkha12) (growtemp_kh13 growtemp_kh14 growtemp_kh15)
rename (q320_areaplanquan q322_areaplankha11 q324_areaplanquan12) (areatemp_kh13 areatemp_kh14 areatemp_kh15)
rename (q320_1_areaplanunit q322_1_areacropkha10unit q324_1_areaplanunit12) (areaunit_kh13 areaunit_kh14 areaunit_kh15)
rename (q320_1_areaplanunit_oth q322_1_areacrop10unit_oth q324_1_areaplanunit12_oth) (areaotherunit_kh13 areaotherunit_kh14 areaotherunit_kh15)
	
foreach year in kh13 kh14 kh15 {
	loc v area_`year'_subcroplevel
	clonevar `v'=areatemp_`year'
	
	replace `v' = `v' * bhigha_to_acre if inlist(areaunit_`year',2)
	replace `v' = `v' * cent_to_acre if (areaunit_`year'==3)
	replace `v' = `v' * guntha_to_acre if (areaunit_`year'==4)
	replace `v' = `v' * biswa_to_acre if (areaunit_`year'==5)
	replace `v' = `v' * kuli_to_acre if (areaunit_`year'==7)
	replace `v' = `v' * MA_to_acre if (areaunit_`year'==8)
	replace `v' =.b if (areaunit_`year'==-888) // Only 1 observation. Safe to drop.
	replace `v' =.b if ((growtemp_`year'==2) & !mi(`v')) // If did not grow/plan to grow, replace it as missing
	
	// Create HH-crop level variables
	bys Id cropname_cleaned: egen grow_`year' = min(growtemp_`year') // grow indicator
	lab value grow_`year' yesno
	bys Id cropname_cleaned: egen area_`year' = total(area_`year'_subcroplevel), missing
	
}
*

keep Id cultivate_13to15_Kharif cropname_cleaned grow_kh* area_kh13 area_kh14 area_kh15
duplicates drop
reshape wide grow_kh* area_kh*, i(Id) j(cropname_cleaned) string
drop *Others

/// Variable labeling
forval year=13/15 {
	foreach crop in BAJRA JAWAR MAIZE PADDY {
		label var grow_kh`year'`crop' "Did household grow (or plan to grow if 2015) `crop' in Kharif 20`year'?"
		label var area_kh`year'`crop' "Area `crop' is planted (or plan to plant if 2015) in Kharif 20`year'(acre)"
	}
}
*

/// Save
isid Id
order cultivate_13to15_Kharif, after(Id)
tempfile SecEroster
save `SecEroster'


// Section E1: Kharif Crop Section (2014) - sowing cost

use "${builddta}/followup_2014/SectionE1_KharifCrop_Sowing_cleaned.dta", clear

loc var NurseryCost_Kh14
bys Id: egen `var'=total(q404_cosraisnurs), missing
lab var `var' "Cost of Raising Nursery, Kharif 2014 (HH-level)"

loc var SeedsCost_Kh14
bys Id: egen `var'=total(q408_seedpurval), missing
lab var `var' "Cost of Purchasing Seeds, Kharif 2014 (HH-level)"

loc var SeedlingsCost_Kh14
bys Id: egen `var'=total(q408_seedpurval), missing
lab var `var' "Cost of Purchasing Seedlings, Kharif 2014 (HH-level)"

loc var OrgmeasureCost_Kh14
bys Id: egen `var'=total(q408_seedpurval), missing
lab var `var' "Cost of Purchasing Organic Measures, Kharif 2014 (HH-level)"

loc var SowingCost_Kh14
egen `var'=rowtotal(NurseryCost_Kh14 SeedsCost_Kh14 SeedlingsCost_Kh14 OrgmeasureCost_Kh14), missing
note `var': egen `var'=rowtotal(NurseryCost_Kh14 SeedsCost_Kh14 SeedlingsCost_Kh14 OrgmeasureCost_Kh14), missing
lab var `var' "Total Cost of Sowing, Kharif 2014 (HH-level)"

keep Id NurseryCost_Kh14 SeedsCost_Kh14 SeedlingsCost_Kh14 OrgmeasureCost_Kh14 SowingCost_Kh14
duplicates drop
isid Id

tempfile SecE1
save `SecE1'


// Section E2 - Input cost
use "${builddta}/followup_2014/SectionE2_KharifCrop_Cost_cleaned.dta", clear

loc var TractorCost_Kh14
bys Id: egen `var'=total(q421_trahireval), missing
lab var `var' "Cost of Hiring Tractor, Kharif 2014 (HH-level)"

loc var IrrigationOwnExp_Kh14
bys Id: egen `var'=total(q423_ownirrexpe), missing
lab var `var' "Cost of Irrigation Expense(Own), Kharif 2014 (HH-level)"

loc var IrrigationCost_Kh14
bys Id: egen `var'=total(q425_irrpurval), missing
lab var `var' "Cost of Irrigation Purchased, Kharif 2014 (HH-level)"

loc var TransportCost_Kh14
bys Id: egen `var'=total(q427_trancost), missing
lab var `var' "Cost of Transportation, Kharif 2014 (HH-level)"

loc var Othermaterial_Kh14
bys Id: egen `var'=total(q428_othmatinputcost), missing
lab var `var' "Cost of other material input, Kharif 2014 (HH-level)"

keep Id TractorCost_Kh14 IrrigationOwnExp_Kh14 IrrigationCost_Kh14 TransportCost_Kh14 Othermaterial_Kh14
duplicates drop
isid Id

tempfile SecE2
save `SecE2'


// Section E3 - Fertilizer & Pesticide
use "${builddta}/followup_2014/SectionE3_KharifCrop_InputCost_cleaned.dta", clear

loc var FertCost_Kh14
egen `var'=rowtotal(q431_2_chemfertval_*), missing
lab var `var' "Cost of fertilizer, Kharif 2014 (HH-level)"

loc var Fertuse_Kh13
egen `var'=rowmin(q431_2_chemfertval_*)
lab var `var' "Used fertilizer, Kharif 2013 (HH-level)"

loc var Fertuse_Kh15
egen `var'=rowmin(q433_plausekha12_*)
lab var `var' "Will use fertilizer, Kharif 2015 (HH-level)"

loc var PestCost_Kh14
egen `var'=rowtotal(q436_1_pestunitval_*), missing
lab var `var' "Cost of Pesticide, Kharif 2014 (HH-level)"

loc var Pestuse_Kh13
egen `var'=rowmin(q437_usekha11_*)
lab var `var' "Used Pesticide, Kharif 2013 (HH-level)"

loc var Pestuse_Kh15
egen `var'=rowmin(q437_1_planusekha12_*)
lab var `var' "Will use Pesticide, Kharif 2015 (HH-level)"


keep Id Fert* Pest*
duplicates drop
isid Id

tempfile SecE3
save `SecE3'



// Section G: Insurance
use "${builddta}/followup_2014/SectionG_Insurance_cleaned.dta", clear

// Heard of ANY insurance
loc var Insur_heardany
egen `var' = rowmin(q1402_hrdschename_?),
label var `var' "Have you ever heard about any insurance scheme?"
label value `var' yesno

// Purchased ANY insurance
loc var Insur_purchany
egen `var' = rowmin(q1403_purcscheme_?)
label var `var' "Have you purchased any insurance scheme?"
label value `var' yesno

// Total premium paid from all insurance scheme
loc var Insur_premiumpaidany
egen `var' = rowtotal(q1404_totprempaidlastyear_?), missing
label var `var' "Total premium paid from all insurance scheme"

// Purchasing ANY insurance in the future
loc var Insur_futurepurchany
egen `var' = rowmin(q1405_purins_?)
label var `var' "Will you consider purchasing any insurance scheme in the future?"
label value `var' yesno

// Amount of premium willing to pay for insurance scheme in the future
loc var Insur_futurepremiumany
egen `var' = rowmax(q1406_amt_?)
label var `var' "If you plan to purchase any insurance in the future, how much will you pay for it?"


// Variable for each insurance scheme
loc scheme1 VB
loc scheme2 NAIS
loc scheme3 MNAIS
loc scheme4 WBCIS
loc scheme5 DMOS


forval i=1/5 {
	loc var Insur_heard
	clonevar `var'`scheme`i''=q1402_hrdschename_`i'
	lab var `var'`scheme`i'' "Have you ever heard about `scheme`i''?"
	
	loc var Insur_purch
	clonevar `var'`scheme`i''=q1403_purcscheme_`i'
	lab var `var'`scheme`i'' "Have you purchased `scheme`i''?"
	
	loc var Insur_premiumpaid
	clonevar `var'`scheme`i''=q1404_totprempaidlastyear_`i'
	lab var `var'`scheme`i'' "Total premium paid for `scheme`i'' last year(2013)"
	
	loc var Insur_futurepurch
	clonevar `var'`scheme`i''=q1405_purins_`i'
	lab var `var'`scheme`i'' "Will you consider purchasing `scheme`i'' in the future?"
	
	loc var Insur_futurepremium
	clonevar `var'`scheme`i''=q1406_amt_`i'
	lab var `var'`scheme`i'' "If you will purchase `scheme`i'' in the future, how much will you pay for it?"
}
*

// Keep generated variable only
keep Id Insur*
duplicates drop
isid Id
tempfile SecG
save `SecG'


// Section H2 - Irregular Crop Cost
use "${builddta}/followup_2014/SectionH2_IrregularCrops_Costs_cleaned.dta", clear
rename q600_culirrcrop cultivateIrrcrop_1415


loc var NurseryCostIrr_2014
bys Id: egen `var'=total(q603_cosraisnurs), missing
lab var `var' "Cost of Raising Nursery (Irregular Crop in 2014 (HH-level)"

loc var SeedsCostIrr_2014
bys Id: egen `var'=total(q607_seedpurval), missing
lab var `var' "Cost of Purchasing Seeds (Irregular Crop) in 2014 (HH-level)"

loc var SeedlingsCostIrr_2014
bys Id: egen `var'=total(q611_sdlingpurval), missing
lab var `var' "Cost of Purchasing Seedlings (Irregular Crop) in 2014 (HH-level)"

loc var OrgmeasureCostIrr_2014
bys Id: egen `var'=total(q614_orgmanpurval), missing
lab var `var' "Cost of Purchasing Organic Measures (Irregular Crop) in 2014 (HH-level)"

loc var SowingCostIrr_2014
egen `var'=rowtotal(NurseryCostIrr_2014 SeedsCostIrr_2014 SeedlingsCostIrr_2014 OrgmeasureCostIrr_2014), missing
note `var': egen `var'=rowtotal(NurseryCostIrr_2014 SeedsCostIrr_2014 SeedlingsCostIrr_2014 OrgmeasureCostIrr_2014), missing
lab var `var' "Total Cost of Sowing (Irregular Crop) in 2014 (HH-level)"

loc var TractorCostIrr_2014
bys Id: egen `var'=total(q620_trahireval), missing
lab var `var' "Cost of Hiring Tractor (Irregular Crop) in 2014 (HH-level)"

loc var IrrigationOwnExpIrr_2014
bys Id: egen `var'=total(q622_ownirrexpe), missing
lab var `var' "Cost of Irrigation Expense(Own) (Irregular Crop) in 2014 (HH-level)"

loc var IrrigationCostIrr_2014
bys Id: egen `var'=total(q624_irrpurval), missing
lab var `var' "Cost of Irrigation Purchased (Irregular Crop) in 2014 (HH-level)"

loc var TransportCostIrr_2014
bys Id: egen `var'=total(q626_trancost), missing
lab var `var' "Cost of Transportation (Irregular Crop) in 2014 (HH-level)"

loc var OthermaterialIrr_2014
bys Id: egen `var'=total(q627_othmatinputcost), missing
lab var `var' "Cost of other material input (Irregular Crop) in 2014 (HH-level)"

drop q600_culirrcrop_count-q627_othmatinputcost
duplicates drop
isid Id

tempfile SecH2
save `SecH2'


// Section H3 ~ H5: Fertiliser & Pesticide cost (irregular crop)
use "${builddta}/followup_2014/SectionH3_H5_IrregularCrops_Costs_cleaned.dta", clear


loc var FertCost_Kh14
egen `var'=rowtotal(q630_2_chemfertval_*), missing
lab var `var' "Cost of fertilizer (Irregular Crop) in 2014"

loc var Fertuse_Kh13
egen `var'=rowmin(q631_usekha2011_*)
lab var `var' "Used fertilizer (Irregular Crop) in 2013"

loc var Fertuse_Kh15
egen `var'=rowmin(q632_plausekha12_*)
lab var `var' "Will use fertilizer (Irregular Crop) in 2015"

loc var PestCost_Kh14
egen `var'=rowtotal(q634_2_pestunitval_*), missing
lab var `var' "Cost of pesticide (Irregular Crop) in 2014"

loc var Pestuse_Kh13
egen `var'=rowmin(q635_usekha11_*)
lab var `var' "Used pesticide (Irregular Crop) in 2013"

loc var Pestuse_Kh15
egen `var'=rowmin(q635_1_planusekha12_*)
lab var `var'"Will use pesticide (Irregular Crop) in 2015"

drop q600_culirrcrop-q709_supfamlabdayC
isid Id
tempfile SecH3H4H5
save `SecH3H4H5'


// Section I1: Financial Assistance Provided
use "${builddta}/followup_2014/SectionI1_Financial_Assistance_cleaned.dta", clear

loc varname1 children
loc varname2 parents
loc varname3 relatfred_svsj
loc varname4 relatfred_svdj
loc varname5 relatfred_dvsj
loc varname6 relatfred_dvdj
loc varname7 privlender
loc varname8 ldlordemployer
loc varname9 agcoop
loc varname10 bank
loc varname11 coopsociety
loc varname12 MFI
loc varname13 selfhelpgroup
loc varname14 others

loc entity1 Children
loc entity2 Parents
loc entity3 Relatives/Friend (same jati, same village)
loc entity4 Relatives/Friend (different jati, same village)
loc entity5 Relatives/Friend (same jati, different village)
loc entity6 Relatives/Friend (different jati, different village)
loc entity7 Private Lender
loc entity8 Lendlord/Employer
loc entity9 Ag.Coop/Ag.Input trader
loc entity10 Bank
loc entity11 Coop. Society
loc entity12 Microfinance Institution
loc entity13 Self-Help Group(s)
loc entity14 Others (Specify)

/// Generate variables for each entity
forval i=1/14{
	loc var gavegift_`varname`i''
	clonevar `var' = q1111_givgiftkha10_`i'
	note `var': EXCLUDE gifts from marriage
	lab var `var' "Gave gift to `entity`i'' (last Kharif)"
	
	loc var gavegiftval_`varname`i''
	clonevar `var' = q1112_totvalallgift_`i'
	lab var `var' "Total value (Rs.) of Gifts to `entity`i'' (last Kharif)"
	
	loc var gavemrggiftval_`varname`i''
	clonevar `var' = q1113_totvalallmarrgift_`i'
	lab var `var' "Total value (Rs.) of all marriage gifts taken `entity`i'' (last Kharif)"
	
	loc var madeloan_`varname`i''
	clonevar `var' = q1114_giveloankha11_`i'
	lab var `var' "Made a loan to `entity`i'' (last Kharif)"
	
	loc var madeloanval_`varname`i''
	clonevar `var' = q1115_totamtloangiv_`i'
	lab var `var' "Total value (Rs.) of all loans to `entity`i'' (last Kharif)"
	
	loc var madeloanint_`varname`i''
	clonevar `var' = q1115_1_intcharloan_`i'
	lab var `var' "Interested charged for loans to `entity`i'' (last Kharif)"
	
	loc var madeloancol_`varname`i''
	clonevar `var' = q1116_totvalcolforloan_`i'
	lab var `var' "Total value (Rs.) of collateral used for loans to `entity`i'' (last Kharif)"
	
}
*
/// Generate total variables
loc var gavegift_any
egen `var'=rowmin(gavegift_*)
note `var':egen `var'=rowmin(gavegift_*)
lab var `var' "Did you give any gift for last Kharif season (since Oct 13)?"

loc var gavegiftval_tot
egen `var'=rowtotal(gavegiftval_*), missing
note `var':egen `var'=rowtotal(gavegiftval_*), missing
lab var `var' "Total values (Rs.) of gifts gave for last Kharif season (since Oct 13)"

loc var gavemrggiftval_tot
egen `var'=rowtotal(gavemrggiftval_*), missing
note `var': egen `var'=rowtotal(gavegiftval_*), missing
lab var `var' "Total values (Rs.) of marriage gifts gave for last Kharif season (since Oct 13)"

loc var madeloan_any
egen `var'=rowmin(madeloan_*)
note `var':egen `var'=rowmin(madeloan_*)
lab var `var' "Did you make any loan for last Kharif season (since Oct 13)?"

loc var madeloanval_tot
egen `var'=rowtotal(madeloanval_*), missing
note `var':egen `var'=rowtotal(madeloanval_*), missing
lab var `var' "Total values (Rs.) of loans made for last Kharif season (since Oct 13)"

loc var madeloanint_tot
egen `var'=rowtotal(madeloanint_*), missing
note `var':egen `var'=rowtotal(madeloanint_*), missing
lab var `var' "Total values (Rs.) of interests charged on loans for last Kharif season (since Oct 13)"

loc var madeloancol_tot
egen `var'=rowtotal(madeloancol_*), missing
note `var':egen `var'=rowtotal(madeloancol_*), missing
lab var `var' "Total values (Rs.) of collateral used for all loans for last Kharif season (since Oct 13)"

drop q1111_givgiftkha10_1-q1116_totvalcolforloan_14
isid Id
tempfile SecI1
save `SecI1'


// Section I2: Financial Assistance Received
use "${builddta}/followup_2014/SectionI2_Gifts_Loans_cleaned.dta", clear

/// Generate variables for each entity
forval i=1/14{
	loc var rcvgift_`varname`i''
	clonevar `var' = q1102_recgiftKha11_`i'
	note `var': EXCLUDE gifts from marriage
	lab var `var' "Received gift from `entity`i'' in 2014"
	
	loc var rcvgiftval_`varname`i''
	clonevar `var' = q1103_totvalallgiftrs_`i'
	lab var `var' "Total value (Rs.) of Gifts received from `entity`i'' in 2014"
	
	loc var rcvmrggiftval_`varname`i''
	clonevar `var' = q1104_totvalmarrgift_`i'
	lab var `var' "Total value (Rs.) of all marriage gifts received from `entity`i'' in 2014"
	
	loc var rcvloan_`varname`i''
	clonevar `var' = q1105_recloankha11_`i'
	lab var `var' "Received a loan from `entity`i'' in 2014"
	
	loc var rcvloanval_`varname`i''
	clonevar `var' = q1106_amtloanrec_`i'
	lab var `var' "Total value (Rs.) of all loans received from `entity`i'' in 2014"
	
	loc var moneyowe_`varname`i''
	clonevar `var' = q1107_totmonownloan_`i'
	lab var `var' "Total amount (Rs.) currently owe `entity`i''"
	
	loc var loannumpayment_`varname`i''
	clonevar `var' = q1108_numpayloanper_`i'
	lab var `var' "Number of Payments to `entity`i'' in 2014"
	
	loc var loantotperiod_`varname`i''
	clonevar `var' = q1108_1_totMMloanper_`i'
	lab var `var' "Total length of loan period `entity`i'' in 2014"
		
	loc var loanamtpaid_`varname`i''
	clonevar `var' = q1109_totpaidwitint_`i'
	lab var `var' "Total loan amount (loan + interest) being paid to `entity`i'' in 2014"
	
	loc var rcvloancol_`varname`i''
	clonevar `var' = q1109_1_totvalcol_`i'
	note `var': zero collateral implies not given.
	lab var `var' "Total value (Rs.) of collateral used for loans received from `entity`i'' in 2014"
	
}
*
/// Generate total variables

loc var rcvgift_any
egen `var'=rowmin(rcvgift_*)
note `var':egen `var'=rowmin(rcvgift_*)
lab var `var' "Did you receive any gift in 2014 (Jan-Dec)?"

loc var rcvgiftval_tot
egen `var'=rowtotal(rcvgiftval_*), missing
lab var `var' "Total values (Rs.) of gifts received in 2014 (Jan-Dec)"

loc var rcvmrggiftval_tot
egen `var'=rowtotal(rcvmrggiftval_*), missing
note `var': egen `var'=rowtotal(rcvmrggiftval_*), missing
lab var `var' "Total values (Rs.) of marriage gifts received in 2014 (Jan-Dec)"

loc var rcvloan_any
egen `var'=rowmin(rcvloan_*)
note `var':egen `var'=rowmin(receiveloan_*)
lab var `var' "Did you receive any loan in 2014 (Jan-Dec)?"

loc var rcvloanval_tot
egen `var'=rowtotal(rcvloanval_*), missing
note `var':egen `var'=rowtotal(rcvloanval_*), missing
lab var `var' "Total values (Rs.) of loans received in 2014 (Jan-Dec)"

loc var moneyowe_tot
egen `var'=rowtotal(moneyowe_*), missing
note `var':egen `var'=rowtotal(moneyowe_*), missing
lab var `var' "Total amount (Rs.) HH currently owe in 2014 (Jan-Dec)"

loc var loanamtpaid_tot
egen `var'=rowtotal(loanamtpaid_*), missing
note `var':egen `var'=rowtotal(loanamtpaid_*), missing
lab var `var' "Total amount (loan + interest) being paid to all loaners in 2014 (Jan-Dec)"

loc var rcvloancol_tot
egen `var'=rowtotal(rcvloancol_*), missing
note `var':egen `var'=rowtotal(rcvloancol_*), missing
lab var `var' "Total values (Rs.) of collateral used for all loans received in 2014 (Jan-Dec)"

drop q1102_recgiftKha11_1-q1109_totpaidwitint_14
isid Id
tempfile SecI2
save `SecI2'

// Section I3: Savings and Durables
use "${builddta}/followup_2014/SectionI3_Savings_Durables_cleaned.dta", clear

loc varname1 animals
loc varname2 cropstock
loc varname3 gold
loc varname4 CFSHG
loc varname5 silver
loc varname6 othmetals
loc varname7 finproducts
loc varname8 savings

/*
loc asset1 Animals
loc asset2 Crop stock
loc asset3 Gold
loc asset4 Chit Funds, SHG group savings
loc asset5 Silver
loc asset6 Other metals
loc asset7 Financial products(stock,bond,etc.)
loc asset8 Savings(formal,informal)
*/

forval i=1/8 {
	loc var owned`varname`i''_bfJan14
	clonevar `var'=q901_ownassbefkha11_`i'
		
	loc var estval`varname`i''_bfJan14
	clonevar `var'=q902_estvalassbefkha11_`i'
		
	loc var own`varname`i''_now
	clonevar `var'=q903_currownass_`i'
	
	loc var estval`varname`i''_now
	clonevar `var'=q904_curestvalass_`i'
	
	if !inlist(`i',2,8) {
		loc var purch`varname`i''_2014
		clonevar `var'=q905_purckha11_`i'
		
		loc var sold`varname`i''_2014
		clonevar `var'=q906_soldkha11_`i'
	}
	
	if !inlist(`i',2) {
		loc var giftgive`varname`i''_2014
		clonevar `var'=q907_giftgivenkha11_`i'
	}
	
	loc var giftrcv`varname`i''
	clonevar `var'=q908_giftreckha11_`i'
	
	if !inlist(`i',1,2) {
		loc var returnon`varname`i''
		clonevar `var'=q909_retintkha11_`i'
	}
}
*
drop q901_ownassbefkha11_1-q909_retintkha11_8
isid Id

tempfile SecI3
save `SecI3'


// Section J1: Asset (part 1)
use "${builddta}/followup_2014/SectionJ1_Asset_part1_cleaned.dta", clear

loc varname1 residH
loc varname2 farmH
loc varname3 rentalH
loc varname4 othuncult
loc varname5 othHHcult

scalar bhigha_to_acre=0.4004
scalar cent_to_acre=0.01
scalar kuzhi_to_acre=0.0132 // This is from Wiki: https://en.wikipedia.org/wiki/Tamil_units_of_measurement
scalar guntha_to_acre=(1/40)
scalar biswa_to_acre=8.0083
scalar hectare_to_acre=2.4711
scalar kuli_to_acre=(1/2.25) // Source: https://tamilvaralaru.wordpress.com/tamil-units-of-measurement/
scalar MA_to_acre=(6.43/20) // 20 MA = 1 Veli = 6.43 acre. Source: https://en.wikipedia.org/wiki/Tamil_units_of_measurement

forval i=1/5{
	loc var own`varname`i''
	rename q910_ownasskha11_`i' `var' 
	
	if inrange(`i',1,3) {
		loc var val`varname`i''_Jan14
		rename q911_totvalkha11_`i' `var' 
		
		loc var val`varname`i''_now
		rename q912_totvalnow_`i' `var'
		
		loc var consyr`varname`i''_now
		rename q914_YYcons_`i' `var'
	}
	else if inlist(`i',4) {
		loc v landarea_uncult
		clonevar `v'=q921_1_area_4
		
		replace `v' = `v' * bhigha_to_acre if inlist(q921_1_areaunit_4,2)
		replace `v' = `v' * cent_to_acre if (q921_1_areaunit_4==3)
		replace `v' = `v' * guntha_to_acre if (q921_1_areaunit_4==4)
		replace `v' = `v' * biswa_to_acre if (q921_1_areaunit_4==5)
		replace `v' = `v' * kuli_to_acre if (q921_1_areaunit_4==7)
		replace `v' =.b if (q921_1_areaunit_4==-888) // Only 1 observation. Safe to drop.
		note `v': measurement unit is acre
		
		drop q921_1_area_4 q921_1_areaunit_4
	}
	else { // i==5
		loc v landarea_HHnotcult
		clonevar `v'=q921_1_area_5	
		
		replace `v' = `v' * bhigha_to_acre if inlist(q921_1_areaunit_5,2)
		replace `v' = `v' * cent_to_acre if (q921_1_areaunit_5==3)
		replace `v' = `v' * guntha_to_acre if (q921_1_areaunit_5==4)
		replace `v' = `v' * biswa_to_acre if (q921_1_areaunit_5==5)
		replace `v' = `v' * kuli_to_acre if (q921_1_areaunit_5==7)
		replace `v' =.b if (q921_1_areaunit_5==-888) // Only 1 observation. Safe to drop.
		note `v': measurement unit is acre
		
		drop q921_1_area_5 q921_1_areaunit_5
	}
	
		loc var rentinc`varname`i''
		rename q913_increntlast12mon_`i' `var' 
		
		loc var consC`varname`i''
		rename q915_constmatcost_`i' `var'
		
		loc var labC`varname`i''
		rename q916_constotwagpayhirelab_`i' `var'
		
		loc var famlab`varname`i''
		rename q917_constotfamday_`i' `var'
		note `var': unit is days
		
		loc var mnt`varname`i''
		rename q918_mainsinkha11_`i' `var'
		
		loc var mntmatC`varname`i''
		rename q919_mainmatcoskha11_`i' `var'
		
		loc var mntlabC`varname`i''
		rename q920_totwagepayhirelabkha_`i' `var'

		loc var mntfamlab`varname`i''
		rename q921_totfamdaylabkha11_`i' `var'
		note `var': unit is days
}
*

tempfile SecJ1
save `SecJ1'

// Section K: Government Scheme
use "${builddta}/followup_2014/SectionK_Govenrment_Schemes_cleaned.dta", clear

loc var NREGadv_Kh14
clonevar `var'=q1001_nregkha11
lab var `var' "Did you take advantage of NREG scheme in the Kharif 2014 season?"

loc var NREGdaysworked_Kh14
clonevar `var'=q1002_totdayHHnreg11
lab var `var' "Total days worked by all HH members (NREG) during Kharif 2014"

loc var NREGrecamt_Kh14
clonevar `var'=q1003_totvalHHnreg11

loc var PDSadv_Kh14
clonevar `var'=q1005_usepdskha11
lab var `var' "Did yout take advantage of PDS (Public Distribution Scheme) in the last Kharif 2014 season?"


// Other government programs

loc var1 heardGovscheme
loc var2 usedGovscheme
loc var3 amtGovscheme
	
forval i=1/11 {

	if inrange(`i',1,10) { // 10 pre-determined scheme
		clonevar `var1'`i'=q1012_heardnameprog_`i'
		clonevar `var2'`i'=q1013_usedschememay11_`i'
		clonevar `var3'`i'=q1014_amtvalrec_`i'
	}
	else { // Others
		egen `var1'`i'=rowmin(q1012_heardnameprog_11 q1012_heardnameprog_12)
		lab var `var1'`i' "Others - Heard?"
		
		egen `var2'`i'=rowmin(q1013_usedschememay11_11 q1013_usedschememay11_12)
		lab var `var2'`i' "Others - Used?"
		
		egen `var3'`i'=rowtotal(q1014_amtvalrec_11 q1014_amtvalrec_12), missing
		lab var `var3'`i' "Others - Amount received?"
	}
}
*

egen `var1'any=rowmin(`var1'*)
lab var `var1'any "Heard any Govn't scheme other than NREG and PDS"
lab value `var1'any yesno

egen `var2'any=rowmin(`var2'*)
lab var `var2'any "Used any Govn't scheme other than NREG and PDS"
lab value `var2'any yesno

egen `var3'tot=rowtotal(`var3'*), missing
lab var `var3'tot "Total mount received from Govn't schemes other than NREG and PDS"

keep Id NREG* PDS* heardGovschemeany usedGovschemeany amtGovschemetot
isid Id
tempfile SecK
save `SecK'

// Section L: Consumption
use "${builddta}/followup_2014/SectionL_Consumption_cleaned.dta", clear

/// Food consumption of each item
loc foodcons1 Cerals
loc foodcons2 Pulses
loc foodcons3 Sugar
loc foodcons4 Cookoil
loc foodcons5 Spices
loc foodcons6 Milk
loc foodcons7 Meat
loc foodcons8 Fruits
loc foodcons9 Veggie
loc foodcons10 Confec
loc foodcons11 Others1
loc foodcons12 Others2
loc foodcons13 Others3
loc foodcons14 Others4


forval i=1/14 {
	loc var1 purchval_`foodcons`i''
	
	// Purchase value
	clonevar `var1'=q1203_1_last30purcunit_`i'
	note `var1': Purchase value in the last 30 days
	
	// Estimated unit price
	loc var2 unitprice_`foodcons`i''
	gen `var2'=(q1203_1_last30purcunit_`i'/q1203_last30purcquan_`i')
	lab var `var2' "(Estimated) Unit price of `foodcons`i''"

	/*
	There are observations where unit price 1, implying purchase value is equal to purchase quantity
	There could be many reasons - data entry error, HH actually paid 1 per unit (after subsidized), actual unit price is 1, or else.
	If needed, we can exclude those observations from analysis.
	*/
	
	// Family provided value (est. price * quantity family provided)
	loc var3 familyval_`foodcons`i''
	gen `var3'=q1202_last30famprov_`i' * `var2'
	note `var3': Price estimaed from purchase * family-provided quantity
	note `var3': Family-provided value in the last 30 days
	
	// Total food_consumption (purchase value + family provided value)
	loc var4 foodconsval`i'
	egen `var4' = rowtotal(`var1' `var3')
	
}
*
/// Total food consumption variables
loc var foodconsval_purch
egen `var' = rowtotal(purchval*)
lab var `var' "Food consumption (purchased) in the last 30 days"

loc var foodconsval_fam
egen `var' = rowtotal(familyva*)
lab var `var' "Food consumption (family provided) in the last 30 days"

loc var foodconsval_tot
egen `var' = rowtotal(foodconsval*), missing
lab var `var' "Total food consumption (purchase + family provided) in the last 30 days"


// Non-food consumption
** Due to the loss of origianl survey data from the field, we do not have unit measurement of some items (Beedis, Cigaretts, etc.)
** Also, we cannot estimate the value of family provided goods due to inconsistency of responses
** (ex. Some households answered "30" as quantity since it is a monthly consumption, no matter actual quantity they spent)
** Thus, I (SL) calculated only the value of purchase only.

loc var nonfoodpurval_tot
egen `var' = rowtotal(q1205_1_last30daypurval*), missing
lab var `var' "Total non-food consumption (purchased only)"

keep Id foodconsval_* nonfoodpurval_tot
isid Id
tempfile SecL
save `SecL'

// Section P: Social Network
use "${builddta}/followup_2014/SectionP_SocialNetwork_cleaned.dta", clear

loc var relsamevil
clonevar `var'=q1501_relresinvill

loc var2 numrelsamevil
bys Id: egen `var2'=count(subid) if (`var'==1)
lab var `var2' "# of relatives living in a same village"

loc var3 numcultrel
bys Id: egen temp=count(subid) if (`var'==1) & (q1507_percult==1)
replace temp=0 if mi(temp)
bys Id: egen `var3'=max(temp)
lab var `var3' "# of cultivating relatives in a same village"

keep Id `var' `var2' `var3'
duplicates drop
isid Id

tempfile SecP
save `SecP'



/****************************************************************
	SECTION X: Compile, Save and Exit
****************************************************************/

use `Id', clear

merge 1:1 Id using `SecA', keep(1 3) nogen // gen(Match_Id_SecA)
merge 1:1 Id using `SecB1', assert(1 3) nogen // gen(Match_Id_SecB1) keep (1 3)
merge 1:1 Id using `SecB2', assert(1 3) nogen // gen(Match_Id_SecB2) keep (1 3)
merge 1:1 Id using `SecM1', keep(1 3) nogen // gen(Match_Id_SecB2) keep (1 3)
merge 1:1 Id using `SecM2', keep(1 3) nogen // gen(Match_Id_SecB2) keep (1 3)
merge 1:1 Id using `SecM3', assert(1 3) nogen // gen(Match_Id_SecB2) keep (1 3)
merge 1:1 Id using `SecM4', assert(1 3) nogen // gen(Match_Id_SecB2) keep (1 3)
merge 1:1 Id using `SecC', assert(3) nogen // gen(Match_Id_SecC) keep (1 3)
merge 1:1 Id using `SecD1', assert(3) nogen // gen(Match_Id_SecC) keep (1 3)
merge 1:1 Id using `SecEroster', keep(1 3) nogen
merge 1:1 Id using `SecE1', keep(1 3) nogen
merge 1:1 Id using `SecE2', keep(1 3) nogen
merge 1:1 Id using `SecE3', keep(1 3) nogen
merge 1:1 Id using `SecG', assert(3) nogen // gen(Match_Id_SecG)
merge 1:1 Id using `SecH2', keep(1 3) nogen
merge 1:1 Id using `SecH3H4H5', keep(1 3) nogen
merge 1:1 Id using `SecI1', keep(1 3) nogen
merge 1:1 Id using `SecI2', keep(1 3) nogen
merge 1:1 Id using `SecI3', keep(1 3) nogen
merge 1:1 Id using `SecJ1', keep(1 3) nogen
merge 1:1 Id using `SecK', keep(1 3) nogen
merge 1:1 Id using `SecL', keep(1 3) nogen
merge 1:1 Id using `SecP', keep(1 3) nogen

// order Match*, last
renvars, pref(fu_)
rename fu_Id a_1hhid // rename ID variable to be matched with round2, round3 survey


qui compress
save "${builddta}/followup_2014/Analysis_variables.dta", replace

cap file close _all
cap log close
copy "${buildlog}/`name_do'.smcl" ///
	"${buildlog}/archive/`name_do' - `c(current_date)' - `c(username)'.smcl" ///
	, replace
exit

