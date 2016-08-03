/*****************************************************************
PROJECT: 		IN_Rainfall, India Rainfall Insurance
				
TITLE:			IN_rainfall_round2_clean_UP.do
			
AUTHOR: 		Seungmin Lee (seungmin.lee@yale.edu)

DATE CREATED:	January 28, 2016

LAST EDITED:	January 28, 2016 by Seungmin Lee

DESCRIPTION: 	Import round2 survey of Uttar Pradesh from raw data and clean it
	
ORGANIZATION:	0 - Preamble
				1 - Converting csv files to dta
				2 - Data Cleaning
				3 - Save and Exit
				
INPUTS: 		$mk/csv\aicwi2_up_common.csv
				$mk/csv\aicwi2_up_insurance.csv
				$mk/csv\aicwi2_up_migration.csv
				$mk/csv\aicwi2_up_cash.csv

OUTPUTS: 		$mk/dta\raw\aicwi2_up_allsurveys.dta
				$mk/Final_Data\final_cleaned_data.dta
				${builddta}/round2/IN_rainfall_r2_cleaned_TN.dta
				
NOTE:			This do-file is based on "${r2_data}/UP/up_marketing.do" with additional modifications.
******************************************************************/

/****************************************************************
	SECTION 0: Preamble					 									
****************************************************************/

version 13.1

set more off
clear all
cap log close 
set mem 500m

global mk "${r2_data}/UP"
cap mkdir "$mk/dta/"
cap mkdir "$mk/dta/raw"
cap mkdir "$mk/log_table"

loc name_do IN_rainfall_round2_clean_UP
log using "${buildlog}/`name_do'", replace


/****************************************************************
	SECTION 1: Converting csv files to dta					 									
****************************************************************/


* Pulling different .csv files and savings as .dta
	insheet using "$mk/csv\aicwi2_up_common.csv", clear
	tostring d_1_c_migmember d_1_o_other e_4_other e_4_whybuyins  d_1_c_other d_1_c_migmember d_1_f_other c_11_shockother d_1_e_whymigdest, replace
	drop if a_1hhid=="037FA"
	gen category=1
	save "$mk/dta\raw\aicwi2_up_common.dta", replace
	

	insheet using "$mk/csv\aicwi2_up_insurance.csv", clear
	tostring  d_1_c_migmember d_1_o_other  backch_accompmonitor_other1 backch_accompsupervisor_other1 e_4_other e_4_whybuyins  d_1_c_other d_1_c_migmember d_1_e_other e_3_insurance b_4other  doorno b_7_1doorno c_1_other  c_11_shocktype  c_11_shockother d_1_k_other   d_1_o_sendmoney, replace
	destring  backch_accompsupervisor_other1, replace
	drop if a_1hhid=="P5037" 
	gen category=2
	
	save "$mk/dta\raw\aicwi2_up_insurance.dta", replace

	insheet using "$mk/csv\aicwi2_up_migration.csv", clear
	tostring  d_1_c_migmember d_1_o_other  a1_2other backch_accompmonitor_other1 e_4_other e_4_whybuyins d_1_c_other d_1_c_migmember d_1_f_other d_1_e_other c_11_shockother d_1_e_whymigdest  doorno e_3_insurance b_4other  b_7_1doorno c_1_other  c_11_shocktype c_11_shockother d_1_k_other   d_1_o_sendmoney, replace
	gen category=3
	save "$mk/dta\raw\aicwi2_up_migration.dta", replace
	
    insheet using "$mk/csv\aicwi2_up_cash.csv", clear
	tostring d_1_c_migmember d_1_o_other backch_accompmonitor_other1  e_4_other e_4_whybuyins d_1_c_other d_1_c_migmember doorno d_1_f_other d_1_e_other b_3hhheadreplace c_11_shockother d_1_e_whymigdest d_1_l_other  e_3_insurance b_4other b_7_1doorno c_1_other  c_11_shocktype  c_11_shockother d_1_k_other   d_1_o_sendmoney backch_accompsign_mon, replace
	gen category=4
	save "$mk/dta\raw\aicwi2_up_cash.dta", replace
	
	
	use "$mk/dta\raw\aicwi2_up_common.dta", clear
	append using "$mk/dta\raw\aicwi2_up_insurance.dta"
	append using "$mk/dta\raw\aicwi2_up_migration.dta"
	append using "$mk/dta\raw\aicwi2_up_cash.dta"
	
* Final Aggregated Dataset
	save "$mk/dta\raw\aicwi2_up_allsurveys.dta", replace
	clear 
	
	
	
/****************************************************************
	SECTION 2: Data Cleaning					 									
****************************************************************/


*.......................Dropping unnecessary variables......................................
  use "$mk/dta\raw\aicwi2_up_allsurveys.dta"
  do "$mk/drop-SL-2016-1-6.ado" // SL: Revised ado file
  
*.......................Labelling data set..................................................
    
   do "$mk/label.ado"
   rename (g_4datesecvisit g_5purchasins g_6unitsins) (f_4datesecvisit f_5purchasins f_6unitsins)
   save "$mk/dta\raw\aicwi2_up_allsurveys.dta", replace
   
*----------------------------------------CHANGING DATE FORMAT-------------------------
*Date
split submissiondate, p(" ")
split submissiondate1, p("-") // SML: For category=1 observations, since they have different date notation
destring submissiondate1 submissiondate2 submissiondate3 submissiondate11 submissiondate12 submissiondate13, replace
egen date=concat(submissiondate1 submissiondate2 submissiondate3)
egen date2=concat(submissiondate11 submissiondate12 submissiondate13) // SML: For category=1
replace date=date2 if (category==1)
gen final_date = date(date, "DM20Y")
gen final_date2 = mdy(submissiondate12, submissiondate11, submissiondate13) // SML: For category=1
replace final_date=final_date2 if (category==1 | (mi(final_date)&!mi(final_date2)))
format final_date %td
sort final_date
drop date date2 final_date2 submissiondate? submissiondate??
label var final_date "Date of Submission"

gen survey_date = date(today, "DM20Y")
label var survey_date "Date of Survey"
format survey_date %td
   
*--------------------------------------------------------------------------------------------
* Step 2: Looking for Duplicate Household I.D.'s
*--------------------------------------------------------------------------------------------  
	duplicates tag a_1hhid, gen(hhid)
	list a_1hhid if hhid==1
	label var a_1hhid "Household ID"
	drop if a_1hhid=="F1271" &  b_2availability==1
	replace a_1hhid="F1274" if a_1hhid=="F1247" &  a1_1locatehh==0
	drop if a_1hhid=="P4273" & survey_date==td(27feb2014)
	drop if a_1hhid=="P4267" & survey_date==td(27feb2014)
	drop if a_1hhid=="P4266" & survey_date==td(27feb2014)
	drop if a_1hhid=="P4261" & survey_date==td(27feb2014)
	drop if a_1hhid=="A1707" & survey_date==td(27feb2014)
    drop if a_1hhid=="P4590" & survey_date==td(28feb2014)
	isid a_1hhid // No more duplicates
	drop hhid
*--------------------------------------------------------------------------------------------
* Step 3: Labeling Values and Splitting Variables and Checks
*--------------------------------------------------------------------------------------------
	*use "dta\raw\aicwi2_up_allsurveys.dta", clear 
	label define category1 1 "Control (no-ins or no-mig)" 2 "Insurance" 3 "Migration-ticket" 4 "Unconditional Cash Transfer"
	label values category category1	
	label var category "Treatment in Round 2"
	
*-------------------------------labeling  all 0 and 1 to YES & NO-------------------------------------------------------------------------------------*

	mvdecode _all, mv (-666=.a \ -777=.b \ -888=.c \ -999=.d )
	label define yesno 1 "Yes" 0 "No" .a "Not Applicable" .b "Refused to Answer" .c "Other" .d "Do not Know
	label values  g_1migaccep g_a_5migwithout g_8anydestoffer g_7cashovertick e_5_payout e_6_deservepayout f_1insexplain f_2purchasins  f_5purchasins f_1mig d_1_j_success d_1_migrant d_1_n_earnmore c_11_shock c_9_bankaccount b_8_1confirmno b_5consent b_2availability a1_1locatehh d_2_migrabi d_3_migkharif  yesno

*------------------------------------------------------------------------------------------------------------------------------------------------------*

save "$mk/dta\raw\aicwi2_up_allsurveys.dta", replace





*************************************************************************************************************************************************	
* ------------------------------------------------------SECTION A- HOUSEHOLD INFORMATION --------------------------------------------------------
*************************************************************************************************************************************************



	*A_8 Were you able to locate the household?*
	
	recode a1_1locatehh(2=0) (1=1)
	note: All other variables have already been programmed to be 0 if it is a "NO"  
	tab a1_1locatehh, m
	*Count Number of Households not found
	count if a1_1locatehh==0
	 
    *---A_9 Why were you unable to find the household?  -----*
	
	recode a1_2reasonfornofind (0=.) (.c=0)
	label define nolocate 1 "Household Moved" 2 "Non-existent address" 0 "Other" 
	label values  a1_2reasonfornofind nolocate 
	* Distribution of reasons for not locating households
	tab a1_2reasonfornofind,m
	*Check to see 'Other' reasons for not locating households make sense
	tab  a1_2other
	gen reason=soundex(a1_2other)
	foreach i in F251 P251 P225 M623 P256 A251 {
	replace a1_2other="Id Merge" if reason =="`i'"
	}
	
	foreach i in G653 G642 {
	replace a1_2other="Door Locked" if reason=="`i'"
	}
	
	tab a1_2reasonfornofind,m 
	tab  a1_2other,m
	drop reason

***---------ATTRITION 
gen attrition=a1_1locatehh==0 | b_5consent==0
note attrition: gen attrition=a1_1locatehh==0 | b_5consent==0
label var attrition "Failture to locate household OR refused to take survey"
tab attrition


*************************************************************************************************************************************************
*--------------------------------------------------- SECTION B- VERIFICATION OF HEAD OF THE  HOUSEHOLD ------------------------------------------
*************************************************************************************************************************************************
	

	
	*Count number of HoH/Alternate Heads
	count
	*HoH
	count if  b_2availability==1
	count if  b_2availability==0
	*Alternate Head
	count if b_4hhmember !=.
		

	*-----B_4 What is your relationship to the primary decision maker? -----
	label define relationship 1 "Spouse" 2 "Son" 3 "Daughter" 4 "Father" 5 "Mother" 6 "Brother" .c "Other" 
	label values b_4hhmember relationship
	tab b_4hhmember, m
	tab b_4other
	// Do we want the others to be translated?
	*-------B_5 Do you agree to take the survey?
	
	tab  b_5consent, m
	replace b_5consent=.z if b_5consent==.
	label define consent .z "HH not found" 0"No" 1"Yes"
	label values b_5consent consent
	tab  b_5consent, m
	
	***Counting no of surveys not done****
	
	
	*----Surveyor Details--------*
	
	do "${mk}/surveyor_name_recoding.ado"
	tab b_6_3surveyorname, m
	drop sn
	
	*-----B_8 contact Number ------*
	note: Lot's of 0's for contact numbers - what does that mean? 
	label define phone 0 "None" .a "Not Applicable" .b "Refused to Answer" 
	note: here I am replacing not applicable to 0 as this both means same that these clients do not have mobile phone.
	replace b_8_contactno=0  if b_8_contactno==.a
	label values b_8_contactno phone 
	count if b_8_contactno==0 
	count if b_8_contactno==.b
	
	
	
	
	*************************************************************************************************************************************************
	*--------------------------------------------------SECTION C: HOUSEHOLD AND INCOME INFORMATION --------------------------------------------------
	*************************************************************************************************************************************************
	
	
  
    *------C_1What is the primary source of income for this household last year? 
		 
	label define income_source 1 "Agricultural Wage Employment" 2 "Cultivation on own irrig land" 3 "Cultivation on own non irrig land" 4 "Cultivation on rented irrig land" 5 "Cultivation on rented non irrig land" 6 "Livestock" 7 "Fishery" 8 "Non-agri wage employment" .c "Other" 
	label values  c_1_incomesource income_source
	//Main source of income
	//15% of households state non-agricultural wage employment as major source of employment. Should that be happening? Our sample should be cultivators and labourers right?
	//Other income sources
	tab c_1_incomesource, m
	tab c_1_other, m 
	
	**C_1 Other - Source of income
     
	 gen source=soundex(c_1_other)
	 br source c_1_other

    *Changed to Non agricultural wage Employment

    foreach i in A650 A651 B315 B416 D616 G324 G121 G165 G132 G655 H215 J100 K221 P525 P613 R363 S126 S460 S626 S646 S263 S163 T260 {
    replace c_1_incomesource=8 if source=="`i'"
    replace c_1_other="" if source=="`i'" 
    }

    *Changed all forms of business
	
    foreach i in A322 B215 B236 S421 K115 C332 D250 D252 D253 F652 G652 H400 H423 J564 K322 K132 K652 K562 L232 L200 N232 P523 P526 P625  S420 S425 S121 T460 T215 T442 V435 {
    replace c_1_other="OWN BUSINESS" if source=="`i'" 
    }
	
	tab c_1_incomesource, m
	tab c_1_other, m
	//Change Other specfy everytime there is a new category
	br source c_1_other
	drop source
	
	*---C_2 How many weeks did you work during the last Kharif season?
	tab c_2_weeksworked, m
	tabstat c_2_weeksworked, stat(mean median)
	sum c_2_weeksworked, d
	
	*---C_3 How many days in a week did you work during the last Kharif (June-November 2013) season?
	tab  c_3_daysworked, m
	tabstat  c_3_daysworked
	sum  c_3_daysworked,d
	
	*---C_4 How many hours in a day did you work during the last Kharif (June-November 2013) season? 
	tab  c_4_hoursworked, m
	tabstat  c_4_hoursworked
	sum c_4_hoursworked,d
	
	*----C_5 What was your daily wage during the last Kharif (June-November 2013) season? 
	tab  c_5_dailywage, m
	sum c_5_dailywage,d
	
	//21-02-2014
	*Calculating income of daily wage earner
	/*
	gen weekly_income=c_5_dailywage*c_3_daysworked
	sum weekly_income,d
	label var weekly_income "Weekly Income"
	
	gen monthly_income=weekly_income*c_2_weeksworked
	sum monthly_income,d
	label var monthly_income "Monthly Income"
	*/
		
	*--C_6 How much land did you cultivate during the last Kharif season ?---*
	
	*Amount of land cultivated (unit)
	label define land_cultivated 1 "Acre" 2 "Bigha" 3 "Cent" 4 "Kuzhi" 5 "Biswa" 6 "Hectare" .b "Refused to Answer" .d "Do Not Know" 
	label values c_6_landcultivated land_cultivated 
	tab c_6_landcultivated, m 
		
	//Most people in U.P. seem to be going by the Bigha unit of measuring land.
	sum c_6_2bigha, d
	
	// Convert land unit area into single unit "acre"
	// Unit convert sourece: http://www.webconversiononline.com/area-conversion.aspx

	loc bigha_to_acre=0.4004
	loc cent_to_acre=0.01
	loc kuzhi_to_acre=0.0132 // This is from Wiki: https://en.wikipedia.org/wiki/Tamil_units_of_measurement
	loc biswa_to_acre=8.0083
	loc hectare_to_acre=2.4711

	loc X c_6_landcultivated_acre
	loc Y c_6_landcultivated
	gen `X'=.
	replace `X'=c_6_1acre if (`Y'==1)
	replace `X'=(c_6_2bigha*`bigha_to_acre') if (`Y'==2)
	replace `X'=(c_6_3cent*`cent_to_acre') if (`Y'==3)
	replace `X'=(c_6_4kuzhi*`kuzhi_to_acre') if (`Y'==4)
	replace `X'=(c_6_5biswa*`biswa_to_acre') if (`Y'==5)
	replace `X'=(c_6_6hectare*`hectare_to_acre') if (`Y'==6)

	* replace `Y'=`X'
	label var `X' "(In acre) How much land did you cultivate during the last Kharif season (July-November 2013)?"
	* label drop land_cultivated
	* drop `X' c_6_1* c_6_2* c_6_3* c_6_4* c_6_5* c_6_6*
	
	
	*-----C_7 What were your total earnings during the last Kharif season (June-November 2013)? ---*
	//Huge range: .9-30 bighas
	tab c_7_kharifearnings, m
	sum c_7_kharifearnings, d 
	count if c_7_kharifearnings==.b 
	
	*----C_8 What was the total household income last year?-------*
	//Annual income for the household
	sum c_8_annualincome, d 
	//Agricultural Wage Employment
	sum c_8_annualincome if c_1_incomesource==1
	//Cultivation on owned irrigated land 
	sum c_8_annualincome if c_1_incomesource==2
	//Cultivation on owned non-irrigated land 
	sum c_8_annualincome if c_1_incomesource==3
	//Cultivated on rented irrigated land 
	sum c_8_annualincome if c_1_incomesource==4
	//Cultivation on rented non-irrigated land
	sum c_8_annualincome if c_1_incomesource==5
	//Livestock
	sum c_8_annualincome if c_1_incomesource==6
	//Fishery
	sum c_8_annualincome if c_1_incomesource==7
	//Non-Agricultural Wage Employment 
	sum c_8_annualincome if c_1_incomesource==8
	//Other source
	sum c_8_annualincome if c_1_incomesource==.c
	
	//Large range and SD. Also, some really rich households out there. Clearly derive income from other sources than agriculture. 
	// Here I feel if we want present annual income we will have to measure it based on the source of income. As non-agricultural familes can have high income.
	count if  c_8_annualincome==.b
	count if c_8_annualincome==.d
	
	
	*--- C_9 Do you or a member of your household have a bank account?----* 
	
	tab c_9_bankaccount, m 
	count if  c_9_bankaccount==1 & c_1_incomesource==1
	
	*--C_10 Was the last Kharif season a good rainfall or bad rainfall year?---*
	
	label define last_kharif 1 "Good" 0 "Bad" .d "Do not Know" .b "Refused to Answer" .a "Not applicable"
	label values  c_10_lastkharif last_kharif
	tab  c_10_lastkharif,m
	
	*--C_11 Since 2011 did the household experience a bad shock?---*
	tab  c_11_shock, m
	
	*--C_11_A What type of shock did your household face?--*
	
    **Split Multiple Option Variable**
	split c_11_shocktype, p(" ")
	destring c_11_shocktype1 c_11_shocktype2 c_11_shocktype3 , replace
    **Label New Variables**
	 label var c_11_shocktype1 "Shock Choice 1"
	 label var c_11_shocktype2 "Shock Choice 2"
	 label var c_11_shocktype3 "Shock Choice 3" 
	 note: More than three shock variables may be created if more than three shocks are chosen by a single household.	
	 foreach x of varlist c_11_shocktype1 -c_11_shocktype3 {
     replace `x'=.c if `x'==-888
     } 
	 label define shock  1 "Drought/Irregular Rains" 2 "Flood" 3	"Storm/Winds" 4	"Crops damaged by insects/disease/animals" 5 "Livestock Illness" 6	"Lack of household labour" 7 "Lack of agricultural Inputs" 8 "Household member ill or injured" 9 "Death of household member" 10 "Loss of job or unemployment" 11 "Theft of crops or livestock"  12 "Political Problems" 13 "Price Fluctuations" 14	"Civil Conflict"  .c "Other"
	 label values c_11_shocktype1 c_11_shocktype2 c_11_shocktype3 shock 
	 tab c_11_shocktype1,m
	 tab c_11_shocktype2,m
	 tab c_11_shocktype3,m
	 
	 
	 
	 
	 *************************************************************************************************************************************************
	 *--------------------------------------------------- SECTION D : PAST EXPERIENCES WITH MIGRATION ------------------------------------------------
	 *************************************************************************************************************************************************
	 
	 
	 
	*---D_1 Have you or any members of your household seasonally migrated to find work elsewhere (outside your village) during the lean season from March to May 2013? 
	tab  d_1_migrant, m
	
	*--D_1_A How many days was he/she  away for work during the lean season---
	sum  d_1_a_daysaway, d
	
	*----D_1_B What was the total income earned from migrating during the lean season 
	sum  d_1_b_migincome, d
	count if d_1_b_migincome==.a
	count if d_1_b_migincome==.b
	count if d_1_b_migincome==.d
	
	*---D_1_C Who in your household has seasonally migrated for employment during the lean season --
	tab  d_1_c_migmember,m
	// I am replacing it as the relation is similar to option 8.
	replace d_1_c_migmember="9" if d_1_c_migmember=="-888" & d_1_c_other=="Devar"
	replace d_1_c_other="" if d_1_c_other=="Devar"
	
	**Split Multiple Option Variable**
	split d_1_c_migmember, p(" ") 
	label var d_1_c_migmember1 "Member 1 to migrate" 
	label var d_1_c_migmember2 "Member 2 to migrate"
	destring  d_1_c_migmember1 d_1_c_migmember2, replace
	foreach x of varlist  d_1_c_migmember1 - d_1_c_migmember2 {
	replace `x'=.c if `x'==-888
	}
	label define mig_member 1 "Head of Household" 2 "Spouse" 3 "Son/Daughter" 4 "Daughter-in-L/Son-in-L" 5 "Grandson/Granddaughter" 6 "Parents" 7 "Father-in-L/Mother-in-L" 8 "Brother/Sister" 9 "Brother-in-L/Sister-in-L" 10 "Uncle/Aunt" .c "Other" 
	label values d_1_c_migmember1 d_1_c_migmember2  mig_member
	tab d_1_c_migmember1, m
	tab d_1_c_migmember2,m
	tab d_1_c_other
	 
	
	
	*---D_1_D Where did he/she seasonally migrate to during the lean season
	
	label define india_abroad 1 "India" 0 "Abroad" 
	label values d_1_d_indiaabroad india_abroad
	tab  d_1_d_indiaabroad, m
	
	*----D_1_D_state
	
	tab  d_1_d_1_d_state
	gen st=soundex( d_1_d_1_d_state)
	foreach i in A536 {
	replace d_1_d_1_d_state="Andhra Pradesh" if st=="`i'"
	}
	
	foreach i in B524 K653 {
	replace d_1_d_1_d_state="Karnataka" if st=="`i'"
	}
	
	foreach i in D400 {
	replace d_1_d_1_d_state="Delhi" if st=="`i'"
	}
	
	foreach i in G263 {
	replace d_1_d_1_d_state="Gujarat" if st=="`i'"
	}
	
	foreach i in H650 {
	replace d_1_d_1_d_state="Haryana" if st=="`i'"
	}
	
	foreach i in M623 M510 {
	replace d_1_d_1_d_state="Maharashtra" if st=="`i'"
	}
	
	foreach i in P521 {
	replace d_1_d_1_d_state="Punjab" if st=="`i'"
	}
	
	foreach i in R223 R235 {
	replace d_1_d_1_d_state="Rajasthan" if st=="`i'"
	}
	
	foreach i in U100 U361 {
	replace d_1_d_1_d_state="Uttar Pradesh" if st=="`i'"
	}
	
	foreach i in U362 D635 {
	replace d_1_d_1_d_state="Uttarakhand" if st=="`i'"
	}
	
	
	drop st
	
	*----D_1_E Why did he/she choose to migrate to the above city during the lean season 
	tab d_1_e_whymigdest, m
	tab d_1_e_other
	
	// Replacing value as it means same
	replace d_1_e_whymigdest="4" if  d_1_e_other=="Ristedar ke pas"
	replace d_1_e_other="" if d_1_e_other=="Ristedar ke pas"
	
	**Split Multiple Option Variable**
	split d_1_e_whymigdest, p(" ")
	
	**Label New Variables**
	label var d_1_e_whymigdest1 "Reason 1 for choosing mig dest"
	label var d_1_e_whymigdest2 "Reason 2 for choosing mig dest"
	note: More than two new variables may be created if more than two choices are chosen by a single household.
	destring d_1_e_whymigdest1- d_1_e_whymigdest2, replace
	foreach x of varlist d_1_e_whymigdest1- d_1_e_whymigdest2 {
     replace `x'=.c if `x'==-888
     } 
	label define why_mig_dest 1 "Returning to the same employer" 2 "Many opportunities available" 3 "Employer recruited at the village" 4 "Friends/Family at the destination" 5 "Close to home" 6 "Common migration destination" .c "Other" 	
	label values d_1_e_whymigdest1 d_1_e_whymigdest2 why_mig_dest
	
	tab d_1_e_whymigdest1,m
	tab d_1_e_whymigdest2,m
	tab d_1_e_other
	
	*---D_1_F What mode of transportation did he/she take to reach the migration destination? 
	tab d_1_f_transport,m
	tab d_1_f_other
	replace d_1_f_other="Cycle" if d_1_f_other=="Saikil"
	label define transport 1 "Bus" 2 "Train" 3 "Lorry" 4 "Auto-Rickshaw" 5 "Shared car" 6 "By foot" 7 "Bullock cart" .c "Other" .d "Do not know"
	label values  d_1_f_transport transport
	tab d_1_f_transport,m
	
	*---D_1_G What was the cost of transportation for a round trip – going and coming back – from the migration destination?
	sum  d_1_g_transcost, d
	
	*----D_1_H Did he/she migrate alone or in a group? 
	label define alone_group 1 "Group" 0 "Alone" .d "Do not Know"
	label values  d_1_h_alonegroup alone_group
	tab  d_1_h_alonegroup,m
	
		
	*---D_1_I Who did he/she migrate with? 
	
	label define mig_group 1 "Friends" 2 "Family" 3 "A group that formed in the village to migrate"
	label values  d_1_i_miggroup mig_group
	tab  d_1_i_miggroup,m
	
	*----D_1_J During this particular episode, was he/she successful in finding employment? 
	tab  d_1_j_success,m
	
	*--- D_1_K How did he/she find their job? 
	**Split multiple option variable**
	note: split d_1_c_migmember, p(" ") when multiple options are chosen. Will not run without multiple options. and if we split we need to replace -888 to .c
	label values d_1_k_findjob find_job
	label define find_job 1 "Returning to the same employer from previous migration" 2 "Through a friend or relative" 3 "Employer came to the village" 4 "Employer came to neighborhood at mig destination" 5 "Newspaper/Ads" 6 "Middleman" .c "Other" 
	tab  d_1_k_findjob,m
	rename d_1_k_findjob d_1_k_findjob1
	lab var  d_1_k_findjob1 "Way 1 to find job"
	
	tab d_1_k_other
	
	*----- D_1_L What was his/her occupation while migrating? 
	
	label define occupation 1 "Construction Worker" 2 "Driver" 3 "Factory Worker" 4 "Carpenter" 5 "Mason" 6 "Welder" 7 "Agricultural Labourer" 8 "Coolie" .c "Other" .d "Do not Know"
	label values d_1_l_occupation occupation
	tab  d_1_l_occupation,m
	
	*----- D_1_M How much did he/she earn in total during this trip? 
	label define income .b "Refused to Answer" .d "Do Not Know" 
	label values d_1_m_earnings income
	sum  d_1_m_earnings,d
	
	*---D_1_M1 Were the earnings higher or lower than average ?
	
	label define earning_level 1"Higher than Average" 2"Average" 3"Lower thab average" .a"Not Applicable" .d"Do not know"
    label values d_1_m1_earninglevel earning_level
	tab  d_1_m1_earninglevel,m
	
	*--D_1M2 Was the migration episode successful? 
		
	label define mig_success 5 "Very Successful" 4 "Successful" 3 "Average" 2 "Not Successful" 1 "Very Unsuccessful" .d "Do not Know" 
	label values d_1_m2_success mig_success
	tab  d_1_m2_success,m
	
	*---D_1_N Did he/she earn more money while migrating than you would have earned by staying in your village? 
	tab  d_1_n_earnmore,m
	
	*--D_1_O How did he/she send money earned from migration work back home? 
	tab d_1_o_sendmoney,m
	tab  d_1_o_other
	replace d_1_o_sendmoney=".c" if d_1_o_sendmoney=="-888"
	**Split multiple Option Variable**
	note: More than two new variables may be created if more than two choices are chosen by a single household.
	split d_1_o_sendmoney, p(" ")
	**Label new variables**
	label var  d_1_o_sendmoney1 "Way 1 of sending money home"
	label var  d_1_o_sendmoney2 "Way 2 of sending money home"
	destring d_1_o_sendmoney1 d_1_o_sendmoney2, replace
	
	label define send_money 1 "Returned home several times" 2 "Returned with lump sum at end" 3 "Bank account" 4 "Postal office" 5 "Hawala courier" 6 "Cash courier" 7 "Through family/friends" .c "Other" .d "Do not Know"
	label values d_1_o_sendmoney1 d_1_o_sendmoney2 send_money
	tab d_1_o_sendmoney1,m
	tab d_1_o_sendmoney2,m
	
	*--D_2 Have you or any member of your household seasonally migrated to find work elsewhere during the Rabi season from November2012 to February2013?
	tab  d_2_migrabi,m
	
	
	*--D_2_A How many days were was he/she away for work during the Rabi season 
	sum  d_2_a_daysaway,d
	
	*--D_2_B What was the total income earned from migrating during the Rabi season
	sum  d_2_b_rabiincome,d
	
	*--D_3 Have you or any member of your household seasonally migrated to find work elsewhere in the last Kharif season from June-November 2013? 
	tab  d_3_migkharif,m
	
	*--D_3_A How many days was he/she away for work during the Kharif season 
	sum  d_3_a_daysaway,d
	
	*---D_3_B What was the total income earned from migrating during the Kharif season
	sum d_3_b_kharifincome,d
		 
	
	*----D4_ Why has no member of your household including yourself chosen to migrate for work in the past year?----------------*
	**Split multiple Option Variable**
	split  d_4_nomigrate, p(" ")
	
	label var  d_4_nomigrate1 "reason 1 for not migrating"
	label var  d_4_nomigrate2 "reason 2 for not migrating"
	label var  d_4_nomigrate3 "reason 3 for not migrating"
	label var  d_4_nomigrate4 "reason 4 for not migrating"
	note: More than three new variables may be created if more than three choices are chosen by a single household.
	destring  d_4_nomigrate1 d_4_nomigrate2 d_4_nomigrate3 d_4_nomigrate4, replace
	label define nomigrate 1 "No money" 2 "Many opportunities available" 3 "No destination job information" 4 "No guarantee of job" 5 "Professional commitment" 6 "Enrolled in MNREGA" 7 "Cannot find to share cost" 8 "No contacts" 9 "Death or sickenss" 10 "family issues" -999 "Do not Know" -888 "Other"
	label values d_4_nomigrate1 d_4_nomigrate2 d_4_nomigrate3 d_4_nomigrate3 d_4_nomigrate4 nomigrate
	tab d_4_nomigrate1, m
	tab d_4_nomigrate2, m
	tab d_4_nomigrate3, m
	tab d_4_nomigrate4, mi
	
	// Converting others as there is a good sample in this
	tab d_4_other
	gen mig=soundex(d_4_other) 
	drop mig
	

	*************************************************************************************************************************************************
	*---------------------------------------------------- SECTION E: PAST EXPERIENCE WITH INSURANCE -------------------------------------------------
	*************************************************************************************************************************************************
	
	
	
	*---E_1 How many kilometers is the nearest Automatic Weather Station (AWS) from your village? 
	tab e_1_distance
		
	*---E_2 what is the distance of your reference AWS?----------*
	/*
	clonevar distanceaws=e_1_kilometers
	label var distanceaws "(In kilometers) Distance b/w village and AWS"
	tab  distanceaws,m
	*/
	label define distance_opinion 1 "Very Close" 2"Close" 3"Reasonable" 4"Far" 5"Very far" -999"Do not Know"
	label values e_2_distanceopinion distance_opinion
	tab e_2_distanceopinion,m
	
	
	*----E_3 Have you or any member of your household purchased any of the following insurance scheme last year (2012)?----*
	replace e_3_insurance = "-999" if a_1hhid=="P4896"
	replace e_3_insurance = "5" if a_1hhid=="F1382"
	split e_3_insurance, p(" ")
	label var e_3_insurance1 "Insurance Purchased_1"
	label var e_3_insurance2 "Insurance Purchased_2"
	destring  e_3_insurance1 e_3_insurance2 , replace
	label define insurance 1"Rainfall Insurance " 2"National Agricultural Insurance Scheme" 3"Modified National Agricultural Insurance Scheme " 4"Weather Based Crop Insurance Scheme " 5"Delayed Monsoon Onset Scheme " 6"None of the above " -999 "Do not Know"
	label values  e_3_insurance1 e_3_insurance2 insurance
	tab e_3_insurance1,m
	tab e_3_insurance2,m
	
	/*
	// Previous insurance indicator
	gen past_insurance=.
	replace past_insurance=1 if inlist(e_3_insurance1,1,2,3,4,5)
	replace past_insurance=0 if (e_3_insurance1==6)
	replace past_insurance=.d if inlist(e_3_insurance1,-999,.d)
	label var past_insurance "Have you or any member of you household purchased any insurance last year?"
	label value past_insurance yesno
	*/
	
	*-----E_4 Why did you invest in one of the above insurance schemes---------*
	split e_4_whybuyins, p(" ")
	label var e_4_whybuyins1 "Reason 1 for buying insurance"
	label var e_4_whybuyins2 "Reason 2 for buying insurance"
	destring  e_4_whybuyins1 e_4_whybuyins2, replace
	foreach x in e_4_whybuyins1 e_4_whybuyins2 {
	replace `x'=.c if `x'==-888
	replace `x'=.d if `x'==-999
	}
	label define whybuy2 1"good investment" 2"mandatory" 3"family or friend suggested" .d "Do not know" .c "Other"
	label values  e_4_whybuyins1 e_4_whybuyins2 whybuy2
	tab e_4_whybuyins1,m 
	tab e_4_whybuyins1,m 
	
	*----E_5 Have you ever received a pay out as a result of buying insurance? ---*
	tab  e_5_payout,m
	
	*---E_6 Did it ever happen that you did not get a payout when you thought you deserved to get it? ---*
	tab  e_6_deservepayout,m
	
	
	
	
	******************************************************************************************************************************************************
	*---------------------------------------------------------------- SECTION F: INSURANCE ---------------------------------------------------------------
	******************************************************************************************************************************************************
	
	
	
	
	*--------F_1  Shall we proceed with the explanation and offer? 
	tab f_1insexplain,m
	replace f_1insexplain=1 if a_1hhid=="F1349" |  a_1hhid=="F1235" |  a_1hhid=="F1306" | a_1hhid=="P4837" | a_1hhid=="F1367" |a_1hhid=="FA291"| a_1hhid=="A1112"| a_1hhid=="F1435"| a_1hhid=="F1502"
	*gen insurance_offered=f_1insexplain==1 
	*label var insurance_offered "Shall we proceed with the explanation and offer?"
		 
	* note: First visit purchasing
	*------F_2 Do you want to purchase Delayed Monsoon Onset Kharif 2014 Insurance? 
	replace f_2purchasins=1 if a_1hhid=="F1349" |  a_1hhid=="F1235" |  a_1hhid=="F1306" | a_1hhid=="P4837" |a_1hhid=="F1367"|a_1hhid=="FA291"| a_1hhid=="A1112"| a_1hhid=="F1435" || a_1hhid=="F1502"
	tab  f_2purchasins,m
	
	*------- F_3 How many units would you like to purchase? 
	// This helps us to now how many were offered and how many are not in insurance//
	replace  f_3unitsins=0 if  f_3unitsins==. & category==2 & attrition==0
	tab  f_3unitsins,m
		
	*note: Second Visit Purchase
	*--------F_5 Do you want to purchase Delayed Monsoon Onset Kharif 2014 Insurance?  
	replace f_5purchasins=1 if a_1hhid=="F1349" |  a_1hhid=="F1235" |  a_1hhid=="F1306" | a_1hhid=="P4837" |a_1hhid=="F1367"|a_1hhid=="FA291" |a_1hhid=="A1112"|a_1hhid=="F1435"| a_1hhid=="F1502"
	tab  f_5purchasins,m
	
	
	*------F_6 How many units would you like to purchase? 
	replace f_6unitsins=1 if a_1hhid=="F1349" |  a_1hhid=="F1235" |  a_1hhid=="F1306" |a_1hhid=="F1367"|a_1hhid=="FA291"| a_1hhid=="A1112"|a_1hhid=="F1435"| a_1hhid=="F1502"
	replace f_6unitsins=2 if a_1hhid=="P4837"
	replace f_6unitsins=0 if f_6unitsins==. & category==2 & attrition==0
	tab f_6unitsins,m
	
	/*
	*---Total clients agreed to buy insurance---
	gen insurance_agreed = (f_2purchasins==1 |f_5purchasins==1)
	replace insurance_agreed=. if (f_1insexplain!=1) // Correctedly skipped
	label var insurance_agreed "Do you want to purchase Delayed Monsoon Onset Kharif 2014 Insurance? " // Added by SLee-2016-1-22
	label value insurance_agreed yesno
	tab insurance_agreed
	
	*--Total insurance units sold---
	tab  f_3unitsins,m
	egen insurance_unit_purchased=rowtotal(f_3unitsins f_6unitsins) if (category==2 & attrition==0)
	replace insurance_unit_purchased=. if (insurance_agreed!=1) // Correctedly skipped
	label var insurance_unit_purchased "total insurance unit purchased from 2 visits"
	ta insurance_unit_purchased
	
	replace insurance_agreed=0 if (insurance_unit_purchased==0) // If no units were purchased, then it means it did not purchase
	replace insurance_unit_purchased=. if (insurance_agreed!=1)
	
	*bysort villname: egen insurance_unit_purchased_vill=sum(insurance_unit_purchased)
	*label var insurance_unit_purchased_vill "Insurance units purchased (village level)"
		
	*----- Villagewise take up
	sort villname
	by villname : tab  insurance_unit_purchased if  insurance_unit_purchased>0
	*/
	
	*------F_7 What is the primary reason for not purchasing insurance? 
	rename (_7nobuyins _7_othernobuy) (f_7nobuyins f_7_othernobuy)
	
	replace f_7nobuyins=" " if a_1hhid=="F1349" |  a_1hhid=="F1235" |  a_1hhid=="F1306" | a_1hhid=="P4837" |a_1hhid=="F1367"|a_1hhid=="FA291" | a_1hhid=="A1112"|a_1hhid=="F1435"|| a_1hhid=="F1502"
	split  f_7nobuyins, p(" ")
	label var f_7nobuyins1 "Reason 1 for not buying insurance"
	label var f_7nobuyins2 "Reason 2 for not buying insurance"
	label var f_7nobuyins3 "Reason 3 for not buying insurance"
	destring f_7nobuyins1 f_7nobuyins2 f_7nobuyins3, replace
	foreach x of varlist f_7nobuyins1 - f_7nobuyins3 {
    replace `x'=.c if `x'==-888
     } 
	label define nobuyings 1"Too Expensive" 2"No need" 3"Do not understand" 4"currently no cash" 5"Payout unlikely" 6"Do not trust insurance" 7"Too early to insurance" -888"Others"
	label values f_7nobuyins1 f_7nobuyins2 f_7nobuyins3 nobuyings
	tab f_7nobuyins1, m
	tab f_7nobuyins2, m
	tab f_7nobuyins3, m
	
	
	

	*------------------------------------------------------------------------------------------------------------------------------------------------
	*-----------------------------------------------------------CREATNG TABLES-----------------------------------------------------------------------
	*------------------------------------------------------------------------------------------------------------------------------------------------
	// To see the percentage of take up of each village by the state
	*tabout  total_insurance_unit  villname using "$mk/log_tables\Tables\insurance.xls" ,c(fre row col) clab(No. %) replace
	
	
	
	
	
	
	
	
	
	
	
	
	*************************************************************************************************************************************************
	*-----------------------------------------------------------SECTION F: MIGRATION OFFER-----------------------------------------------------------
	*************************************************************************************************************************************************
	
	
	
	
	*-------F_1 allow to proceed with migration
	tab f_1mig, m
	*gen migration_offered=f_1mig==1
	*label var migration_offered "Shall we proceed with the migration explanation and offer?" //
	
	*-------F_2 do you or a member of your household accept this offer of a free trip ticket to the above destinations during this lean season from March to May?----*
	label define migaaccept 1"Yes" 2 "No" 3"Need more time"
	label values f_2migaccep migaaccept
	tab  f_2migaccep, m
	
	
	*---F_3 Who from the household will be sent to seasonally migrate for employment purposes?  ----*
	
	label define migmember 1"Head of the Household" 2"Spouse" 3"Son or Daughter" 4"Daughter/Son in law" 5"Granddaughter/son" 6"Parents" 7"Father/Mother in law" 8"Brother/Sister" 9"Brother/Sisiter in law" 10"Uncle/Aunt" -888 "Other"
	label values f_3migmember migmember
	tab  f_3migmember, m
	tab f_3migother, m
	
	*--- F_4 Migration Destination ---------------*
	
	label define whymigcity 1"High wages" 2"Many Contacts " 3"Have migrated to the city before" 4"Have a place to stay" 5"Job Leads" 6"Low Moving Costs" -666"Not applicable" -888"Other"
    label values  g_a_4whymigcity whymigcity
	tab  f_4choosedest, m
	
	*--- G Second Visit Date ---------------*
	// compulsory second visit date this should be equal to respondents allowing to proceed f_1mig
	tab g_datesecvisit, m
	
	
	*--- G_1 Will you or any member of your household be participating in our migration incentive in which we buy you a round trip ticket to seasonally migrate to one of the top three migration destinations in your state?  ---------------*
	
	//accept to migrate and willing to get train ticket
	tab g_1migaccep, m
	*gen migration_accepted=(f_2migaccep==1 | g_1migaccep==1)
	*replace migration_accepted=. if (migration_offered!=1) // Correctedly skipped
	*label var migration_accepted "Accepted Migration Offer"
	
	
	*-----G_a_2 Who from the household will be sent to seasonally migrate for employment purposes?
	
	//confirming migrating member	
	label define member 1"Head of the Household" 2"Spouse" 3"Son or Daughter" 4"Daughter/Son in law" 5"Granddaughter/son" 6"Parents" 7"Father/Mother in law" 8"Brother/Sister" 9"Brother/Sisiter in law" 10"Uncle/Aunt" -888 "Other"
	label values g_a_2migmember migmember
	tab  g_a_2migmember, m
	tab g_a_2migother, m
	
	*--- G_a_2 Do you or the migrating member of the household have a mobile phone that you can use for receiving the travel ticket via SMS/text message?
	//mobile phone availability
	tab g_a_2cellphone
	
	
	*-----F_10 date of departure and return to and from the migration destination?
		
	//leave month & date
	label define month 1"March" 2"April" 3"May"
	label values g_a_b_1migmonthleave g_a_b_2migmonthreturn month
	tab  g_a_b_1migmonthleave g_a_b_1migdateleave
	
	//return month & date
	tab  g_a_b_2migmonthreturn g_a_b_2migdayreturn, m
	
	*----- F_11 final confirmation of destination
 	tab g_a_3destconfirm, m
	

	
	*---F_12 Reason for migrating to the specific city
	//splitting the values & table most frequent reasons for not choosing the city
	
	tab g_a_4whymigcity, m
	tab g_a_4otherwhycity
	destring g_a_4whymigcity, replace
	label define whymigcity1 1"High wages" 2"Many contacts" 3"Have migrated before" 4"Have a place to stay" 5"Job leads" 6"Low moving cost" .c "others" .a"Not applicable"
	label values g_a_4whymigcity whymigcity1
	tab g_a_4whymigcity, m
	rename g_a_4whymigcity g_a_4whymigcity1 // To be merged with AP and TN datasets
	label var g_a_4whymigcity1 "Reason 1 for specific city migration"
	
	//// This is applicable only if multiple choice are recorded
	/*split g_a_4whymigcity, p(" ")
	label var g_a_4whymigcity1 "Reason 1 for choosing the destination"
	label var g_a_4whymigcity2 "Reason 2 for choosing the destination"
	destring g_a_4whymigcity1 g_a_4whymigcity1, replace
	foreach x in varlist g_a_4whymigcity1 - g_a_4whymigcity3 {
	replace `x'=.c if `x'==-888
	repalce `x'=.a if `x'==-666
	}
	label define whymigcity 1"High wages" 2"Many contacts" 3"Have migrated before" 4"Have a place to stay" 5"Job leads" 6"Low moving cost" .c "others" .a"Not applicable"
	label values g_a_4whymigcity1 g_a_4whymigcity2 whymigcity
	tab g_a_4whymigcity1
	tab g_a_4whymigcity2
	tabm g_a_4whymigcity1 g_a_4whymigcity2
	*/
		
	
	*---- G_a_5 migration without incentive
	tab  g_a_5migwithout, m
	
	
	*---- G_a_6 What was the main reason for accepting the incentive? -------------*
	
	label define chooseincent 1"Makes migration affordable" 2"Allows me to explore options" 3"willing to take the risk" -999"Do not Know" -888"Other 
	label values g_a_6chooseincent chooseincent
	label var g_a_6chooseincent "f14_What was the main reason for accepting the incentive?" 
	tab g_a_6chooseincent, m
	rename g_a_6chooseincent g_a_6chooseincent1
	
	
	*---- G_7 Accepted cash rather than round trip ticket
	tab  g_7cashovertick, m
	
	*---- G_8 Accepted offer if own choice destination was offered.
	tab g_8anydestoffer, m
	
	
	*---- G_9 Reasons for not accepting migration.
	
	//check -888 and make the data consistent if family reasons are added in others
	//splitting the values & table most frequent reasons for not accepting migration
	tab g_9noaccept, m
	tab g_9other, m
	replace g_9noaccept="9" if a_1hhid=="P4704"
	replace g_9other=" " if a_1hhid=="P4704"
	split g_9noaccept, p(" ")
	label var g_9noaccept1 "reason 1 for not accepting"
	label var g_9noaccept2 "reason 2 for not accepting"
	label var g_9noaccept3 "reason 3 for not accepting"
	destring g_9noaccept1 g_9noaccept2 g_9noaccept3, replace
	label define noaccept 1"Still too expensive" 2"Do not know opportunities at destination" 3"Too risky" 4"enough opportunities at local job markets" 5"No guarantee of employment" 6"Cannot leave land" 7"Enrolled in government program" 8"Death/Sickness" 9" Family obligations" -888"other"
	label values  g_9noaccept1 g_9noaccept2 g_9noaccept3 noaccept
	tab g_9noaccept1
	tab g_9noaccept2
	tab g_9noaccept3

// Drop intervention variable (will be merged with correct intervention information later)
drop category	

/****************************************************************
	SECTION 3: Save and Exit		 									
****************************************************************/

compress
save "$mk/Final_Data\final_cleaned_data.dta", replace
save "${builddta}/round2/IN_rainfall_r2_cleaned_UP.dta", replace

cap file close _all
cap log close
copy "${buildlog}/`name_do'.smcl" ///
	"${buildlog}/archive/`name_do' - `c(current_date)' - `c(username)'.smcl" ///
	, replace
exit
