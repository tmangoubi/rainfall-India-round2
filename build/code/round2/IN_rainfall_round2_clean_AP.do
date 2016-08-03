/*****************************************************************
PROJECT: 		IN_Rainfall, India Rainfall Insurance
				
TITLE:			IN_rainfall_round2_clean_AP.do
			
AUTHOR: 		Seungmin Lee (seungmin.lee@yale.edu)

DATE CREATED:	January 28, 2016

LAST EDITED:	January 28, 2016 by Seungmin Lee

DESCRIPTION: 	Import round2 survey of Andhra Pradesh from raw data and clean it
	
ORGANIZATION:	0 - Preamble
				1 - Converting csv files to dta
				2 - Data Cleaning
				3 - Save and Exit
				
INPUTS: 		$mk/csv/aicwi2_ap_common.csv
				$mk/csv\aicwi2_ap_insurance.csv
				$mk/csv\aicwi2_ap_migration.csv
				$mk/dta\raw\aicwi2_ap_cash.dta

OUTPUTS: 		${builddta}/Substation_location.dta
				
NOTE:			This do-file is based on "${r2_data}/AP/ap_marketing.do" with additional modifications.
******************************************************************/

/****************************************************************
	SECTION 0: Preamble					 									
****************************************************************/

version 13.1

set more off
clear all
cap log close 

global mk "${r2_data}/AP"
cap mkdir "$mk/dta/"
cap mkdir "$mk/dta/raw"
cap mkdir "$mk/log_table"

loc name_do IN_rainfall_round2_clean_AP
log using "${buildlog}/`name_do'", replace

/****************************************************************
	SECTION 1: Converting csv files to dta					 									
****************************************************************/

* Pulling different .csv files and savings as .dta
	insheet using "$mk/csv\aicwi2_ap_common.csv", clear
	tostring d_1_o_other backch_accompmonitor_other1  d_1_f_other c_11_shockother d_1_e_whymigdest b_4other, replace
	gen category=1
	save "$mk/dta\raw\aicwi2_ap_common.dta", replace
	

	insheet using "$mk/csv\aicwi2_ap_insurance.csv", clear
	tostring d_1_o_other backch_accompmonitor_other1 e_4_whybuyins d_1_f_other d_1_e_other e_3_insurance b_4other  doorno b_7_1doorno c_1_other  c_11_shocktype  c_11_shockother d_1_k_other   d_1_o_sendmoney, replace
	gen category=2
	
	save "$mk/dta\raw\aicwi2_ap_insurance.dta", replace

	insheet using "$mk/csv\aicwi2_ap_migration.csv", clear
	tostring d_1_o_other d_1_c_migmember backch_accompmonitor_other1 e_4_whybuyins a1_2other d_1_f_other d_1_e_other c_11_shockother d_1_e_whymigdest  doorno e_3_insurance b_4other  b_7_1doorno c_1_other  c_11_shocktype c_11_shockother d_1_k_other   d_1_o_sendmoney, replace
	rename g_a_6incentother g_a_6otherincent 
	gen category=3
	save "$mk/dta\raw\aicwi2_ap_migration.dta", replace
	
    insheet using "$mk/csv\aicwi2_ap_cash.csv", clear
	tostring d_1_o_other backch_accompmonitor_other1  e_4_whybuyins  d_1_c_migmember doorno d_1_f_other d_1_e_other b_3hhheadreplace c_11_shockother d_1_e_whymigdest d_1_l_other  e_3_insurance b_4other b_7_1doorno c_1_other  c_11_shocktype  c_11_shockother d_1_k_other   d_1_o_sendmoney backch_accompsign_mon, replace
	gen category=4
	save "$mk/dta\raw\aicwi2_ap_cash.dta", replace
	
	
	use "$mk/dta\raw\aicwi2_ap_common.dta", clear
	append using "$mk/dta\raw\aicwi2_ap_insurance.dta"
	append using "$mk/dta\raw\aicwi2_ap_migration.dta"
	append using "$mk/dta\raw\aicwi2_ap_cash.dta"
	
* Final Aggregated Dataset
	save "$mk/dta\raw\aicwi2_ap_allsurveys.dta", replace
	clear 
	
	
/****************************************************************
	SECTION 2: Data Cleaning					 									
****************************************************************/

*.......................Dropping unnecessary variables......................................
  use "$mk/dta\raw\aicwi2_ap_allsurveys.dta"
  do "$mk/drop.ado"
*.......................Labelling data set..................................................
    
   do "$mk/label.ado"
   rename (g_4datesecvisit g_5purchasins g_6unitsins) (f_4datesecvisit f_5purchasins f_6unitsins)
   save "$mk/dta\raw\aicwi2_ap_allsurveys.dta", replace
   
*----------------------------------------CHANGING DATE FORMAT-------------------------
*Date
split submissiondate, p(" ")
split submissiondate1, p("-") // SML: For category=3 observations, since they have different date notation
destring submissiondate1 submissiondate2 submissiondate3 submissiondate11 submissiondate12 submissiondate13, replace
egen date=concat(submissiondate1 submissiondate2 submissiondate3)
egen date2=concat(submissiondate11 submissiondate12 submissiondate13) // SML: For category=3
replace date=date2 if (category==3)
gen final_date = date(date, "DM20Y")
gen final_date2 = mdy(submissiondate12, submissiondate11, submissiondate13) // SML: For category=3
replace final_date=final_date2 if (category==3)
format final_date %td
sort final_date
drop date date2 final_date2 submissiondate? submissiondate??
label var final_date "Date of Submission"

gen survey_date = date(today, "DM20Y")
format survey_date %td
label var survey_date "Date of Survey"

*--------------------------------------------------------------------------------------------
* FIXING ERRORS IN UPLOADED SURVEYS----------------------------------------------------------
*--------------------------------------------------------------------------------------------  
*HHID entered incorrectly by surveyor in Chagallu*
	replace a_1hhid="F2584" if a_1hhid=="P2584" & submissiondate=="15 Feb, 2014 10:24:10 PM"
	replace distname="WEST GODAVARI" if a_1hhid=="F2584"
	replace distid=90 if a_1hhid=="F2584"
	replace tehsname="CHAGALLU" if a_1hhid=="F2584"
	replace tehsid=134 if a_1hhid=="F2584"
	replace blockid=137 if a_1hhid=="F2584"
	replace blockname="CHAGALLU" if a_1hhid=="F2584"
	replace villid=212 if a_1hhid=="F2584"
	replace villname="CHAGALLU" if a_1hhid=="F2584"
	replace doorno="2-74" if a_1hhid=="F2584"
	replace stname="THURPUPETA RICEMILL BACKSIDE" if a_1hhid=="F2584"
	replace prevresp="VANKAYALA VENKATARATNAM" if a_1hhid=="F2584"
	
	
*Dropping Pilot surveys still stored in certain tablets*
	drop if today=="25 Jan, 2014"
   
*--------------------------------------------------------------------------------------------
* Looking for Duplicate Household I.D.'s
*--------------------------------------------------------------------------------------------  
	duplicates tag a_1hhid, gen(hhid)
	list a_1hhid if hhid==1
	label var a_1hhid "Household ID"
	note: There is a duplicate entry for Household I.D. A1036. Literally the same respondent who refused twice. Will drop one I.D.
	drop if a_1hhid=="A1036" & today=="5 Feb, 2014"
	note: There is a duplicate entry for Household I.D. F2627. Same survey. Will drop one I.D.
	drop if a_1hhid=="F2627" & submissiondate=="18 Feb, 2014 8:31:05 PM"
	note: There is a duplicate entry for F2964. Checked with field staff and the earlier survey is the correct one. 
	drop if a_1hhid=="F2964" & submissiondate=="17 Feb, 2014 11:41:22 PM"
	note: There is a duplicate entry for F2838. The survey dated earlier is correct.
	drop if a_1hhid=="F2838" & submissiondate=="22 Feb, 2014 10:15:44 PM"
	note: There is a duplicate entry for P1889. The surveys are identical, dropping one I.D.
	drop if a_1hhid=="P1889" & endtime=="21 Feb, 2014 6:40:45 AM"
	note: There is a duplicate entry for FA832. The survey dated earlier is correct.
	drop if a_1hhid=="FA832" & submissiondate=="5 Mar, 2014 10:54:48 PM"
	note: There is a duplicate entry for P2705. The more recent version of the survey is correct (The respondent is dead)
	drop if a_1hhid=="P2705" & submissiondate=="28 Feb, 2014 8:43:49 AM"
	note: There is a duplicate entry for P2486. The more recent version of the survey is correct.
	drop if a_1hhid=="P2486" & submissiondate=="28 Feb, 2014 8:44:04 AM"
	note: There is a duplicate entry for P2660. The more recent version of the survey is correct.
	drop if a_1hhid=="P2660" & submissiondate=="5 Mar, 2014 2:17:37 PM"
	note: There is a duplicate entry for P1716. The surveys are identical, dropping one.
	drop if a_1hhid=="P1716" & submissiondate=="11 Mar, 2014 7:37:09 AM"
	drop if a_1hhid=="P2660" & subscriberid==.
	drop if a_1hhid=="A1036" & backch_accompaccom_check==0
		
	isid a_1hhid // No more duplicates
	drop hhid
	

*--------------------------------------------------------------------------------------------
* Labeling Values and Splitting Variables and Checks
*--------------------------------------------------------------------------------------------
	*use "dta\raw\aicwi2_ap_allsurveys.dta", clear 
	label define category1 1 "Control (no-ins or no-mig)" 2 "Insurance" 3 "Migration-ticket" 4 "Unconditional Cash Transfer"
	label values category category1
	label var category "Treatment in Round 2"
	
*-------------------------------labeling  all 0 and 1 to YES & NO-------------------------------------------------------------------------------------*

	mvdecode _all, mv (-666=.a \ -777=.b \ -888=.c \ -999=.d )
	label define yesno 1 "Yes" 0 "No" .a "Not Applicable" .b "Refused to Answer" .c "Other" .d "Do not Know
	label values  g_1migaccep g_a_5migwithout g_8anydestoffer g_7cashovertick e_5_payout e_6_deservepayout f_1insexplain f_2purchasins  f_5purchasins f_1mig d_1_j_success d_1_migrant d_1_n_earnmore c_11_shock c_9_bankaccount b_8_1confirmno b_5consent b_2availability a1_1locatehh d_2_migrabi d_3_migkharif  yesno


**************************************************************************************************************************************************************
*-----------------------------------MERGING WITH AP FULL SAMPLE DATASET TO ENSURE HOUSEHOLDS HAVEN'T BEEN SKIPPED--------------------------------------------*

/*merge 1:1 a_1hhid using "$ap"
sort village
br if _merge==2
count if village=="ADADAKULAPALLE" & _merge==2
count if village=="AREPALLE" & _merge==2
count if village=="BOLLAPADU" & _merge==2
count if village=="CHAGALLU" & _merge==2
count if village=="KRISHNAPURAM" & _merge==2
count if village=="PAPPALA LINGALAVALASA" & _merge==2	
*/

*Tracking Cash Amounts given for unconditional transfer*

*------------------------------------------------------------------------------------------------------------------------------------------------------*

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
	tab a1_2reasonfornofind
	recode a1_2reasonfornofind (0=.) (.c=0)
	label define nolocate 1 "Household Moved" 2 "Non-existent address" 0 "Other" 
	label values  a1_2reasonfornofind nolocate 
	* Distribution of reasons for not locating households
	tab a1_2reasonfornofind
	*Check to see 'Other' reasons for not locating households make sense
	tab  a1_2other
	replace a1_2other="Temporary migration" if a_1hhid=="FA371"
	
	gen reason=soundex(a1_2other)
	br a1_2other reason
	
	foreach i in D300 E216 R215 U514{
	replace a1_2other="Respondent Expired" if reason=="`i'"
	}
	
	foreach i in A136 A141 N421 N314 O136 T215 S536 H411 {
	replace a1_2other="Household Unavailable for interview" if reason=="`i'"
	}
	
	foreach i in F542 S133 T516  {
	replace a1_2reasonfornofind=1 if reason=="`i'"
	replace a1_2other="" if reason=="`i'"
	}
	
	
	foreach i in S524 S530 S532 D143 {
	replace a1_2other="Id Merge" if reason=="`i'"
	}
	
	
	foreach i in R123 {
	replace a1_2other="Refused" if reason=="`i'"
	}
	
	tab  a1_2other
	drop reason
	
	***---------ATTRITION 
    gen attrition=a1_1locatehh==0 | b_5consent==0
	note attrition: gen attrition=a1_1locatehh==0 | b_5consent==0
	label var attrition "Failture to locate household OR refused to take survey"
    tab attrition


*************************************************************************************************************************************************
*--------------------------------------------------- SECTION B-VERIFICATION OF HEAD OF THE  HOUSEHOLD ------------------------------------------
*************************************************************************************************************************************************
		
	*Count number of HoH/Alternate Heads
	count
	*HoH
	count if  b_2availability==1
	*Alternate Head
	count if b_4hhmember !=.
	*destring _all, replace 	

	*-----B_4 What is your relationship to the primary decision maker? -----
	label define relationship 1 "Spouse" 2 "Son" 3 "Daughter" 4 "Father" 5 "Mother" 6 "Brother" .c "Other" 
	label values b_4hhmember relationship
	tab b_4hhmember, m
	tab  b_4other, m
	replace b_4other="Uncle" if b_4other=="Unkul"
	
	
	*-------B_5 Do you agree to take the survey?
	
	tab  b_5consent, m
	replace b_5consent=.z if b_5consent==.
	label define consent .z "HH not found" 0"No" 1"Yes"
	label values b_5consent consent
	tab  b_5consent, m
	
	
	
	*-----B_8 contact Number ------*
	label define phone 0 "None" .a "Not Applicable" .b "Refused to Answer" 
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
	//18% of households state non-agricultural wage employment as major source of employment. Other income sources is 17%. Need to figure this out.  
	//Other income sources
	tab c_1_incomesource, m
	tab c_1_other, m 
	replace c_1_other="PENSION" if c_1_other=="0ld age pinchan"|c_1_other=="Old Age Pension"|c_1_other=="Old Age pension"|c_1_other=="Oldage pension"|c_1_other=="Oldege pension"|c_1_other=="PENSION "|c_1_other==" Penction"|c_1_other=="Penction amount"|c_1_other=="Pension"|c_1_other=="Pension (retaird)"|c_1_other=="Pention"|c_1_other=="OLD AGE PENSION"|c_1_other=="RETAIRED GOVT SCHOOL MASTER"
	replace c_1_other=upper(c_1_other)
	replace c_1_other="PENSION" if c_1_other=="PENCTION"
	replace c_1_other="ASTROLOGIST" if c_1_other=="AUSTRIOLOGIST"
	replace c_1_other="BARBER SHOP" if c_1_other=="BARBAR SHOPE"
	replace c_1_other="WASHERMAN" if c_1_other=="CHAKALI PANI"	
	replace c_1_other="PASTOR" if c_1_other=="CHURCH PASTOR"|c_1_other=="CHARCH PASTAR"
	replace c_1_other="CLEANER" if c_1_other=="CLINOR"
	replace c_1_other="LANDLORD" if c_1_other=="HOUSE RENT"|c_1_other=="LAND LEASING"|c_1_other=="OWN LAND GIVING TO RENT" 
	replace c_1_other="HOUSEWIFE" if c_1_other=="HOUSE WIFE"|c_1_other=="HOUSE WIFE(HEALTH PROBLAM)"
	replace c_1_other="OWN BUSINESS" if c_1_other=="AUTO OWNER"|c_1_other=="BARBER SHOP"|c_1_other=="BUSINESS"|c_1_other=="MEDICAL SHOP"|c_1_other=="OWN BUSINESS (BARBER)"|c_1_other=="OWN BUSINESS(TAILORING)"|c_1_other=="OWN BUSSINES"|c_1_other=="OWN BUSSINESS"|c_1_other=="STORE KEEPAR"|c_1_other=="TAILAR"|c_1_other=="TAILARING"|c_1_other=="TAILOR"|c_1_other=="TAILORING"|c_1_other=="TIFFIN HOTEL BUSINESS"|c_1_other=="SELF EMPLOYED"|c_1_other=="SELF EMPLOYMENT"  
	replace c_1_other="PRIEST" if c_1_other=="PUJARI CULTURAL ACTIVITIES (PRIEST)."
	replace c_1_other="REMITTANCE" if c_1_other=="REMEDENS"|c_1_other=="REMMITTANCE"|c_1_other=="PINTION KODUKU PRATHI NELA DABBU ISTHADU"

	replace c_1_other="PENSION AND REMITTANCE" if c_1_other=="PENSION & REMITENCE"|c_1_other=="PENSION AND REMITTENDE"|c_1_other=="REMITTANCE ,PENSION" 
	replace c_1_other="PENSION AND FAMILY SUPPORT" if c_1_other=="OLD AGE PENSION AND DAUGHTER'S GAVE SOME MONEY."
	replace c_1_other="KIRANA SHOP AND PENSION" if c_1_other=="VERY SMALL KIRANAM SHOP AND OLDAGE PENSION"
	
	*For court broker, factory employee, mid day meal food preparer, government employees, lorry driver, drivers, mechanic, private employee, private job, state government employees, teacher, technician, watchman, etc.  - switch to non-agricultural wage employment
	
	replace c_1_incomesource=8 if c_1_other=="COURT BROKER"|c_1_other=="DRIVER"|c_1_other=="DRIVING"|c_1_other=="FACTORY EMPLOYEE"|c_1_other=="FOOD PREPEROR (MID DAY MEALS)"|c_1_other=="GOVERNMENT EMPLOYE"|c_1_other=="GOVERNMENT EMPLOYEE"|c_1_other=="GOVERNMENT JOB"|c_1_other=="LOARY DRIVER"|c_1_other=="LORRY DRIVER"|c_1_other=="MEKANIK"|c_1_other=="PRAVITE JOB"|c_1_other=="PRIVATE EMPLOYEE"|c_1_other=="PRIVATE JOB"|c_1_other=="PRIVATE SALARIED JOB"|c_1_other=="STATE GOVERNAMENT EMPLOYEE , (V.R.O)."|c_1_other=="TECHNICIAN"|c_1_other=="TEACHER"|c_1_other=="VRA"|c_1_other=="WATCHMAN"
	
	replace c_1_other="" if c_1_other=="COURT BROKER"|c_1_other=="DRIVER"|c_1_other=="DRIVING"|c_1_other=="FACTORY EMPLOYEE"|c_1_other=="FOOD PREPEROR (MID DAY MEALS)"|c_1_other=="GOVERNMENT EMPLOYE"|c_1_other=="GOVERNMENT EMPLOYEE"|c_1_other=="GOVERNMENT JOB"|c_1_other=="LOARY DRIVER"|c_1_other=="LORRY DRIVER"|c_1_other=="MEKANIK"|c_1_other=="PRAVITE JOB"|c_1_other=="PRIVATE EMPLOYEE"|c_1_other=="PRIVATE JOB"|c_1_other=="PRIVATE SALARIED JOB"|c_1_other=="STATE GOVERNAMENT EMPLOYEE , (V.R.O)."|c_1_other=="TECHNICIAN"|c_1_other=="TEACHER"|c_1_other=="VRA"|c_1_other=="WATCHMAN"

		
	*---C_2 How many weeks did you work during the last Kharif season?
	tab c_2_weeksworked, m
	tabstat c_2_weeksworked, stat(mean median)
	sum c_2_weeksworked, d
	
	*---C_3 How many days in a week did you work during the last Kharif (June-November 2013) season?
	tab  c_3_daysworked, m
	tabstat  c_3_daysworked
	sum  c_3_daysworked, d
	
	*---C_4 How many hours in a day did you work during the last Kharif (June-November 2013) season? 
	tab  c_4_hoursworked, m
	tabstat  c_4_hoursworked
	
	*----C_5 What was your daily wage during the last Kharif (June-November 2013) season? 
	tab  c_5_dailywage, m
	sum c_5_dailywage,d
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
	label values  c_6_landcultivated land_cultivated 
	tab c_6_landcultivated, m 
	//Acre is the most common unit of land in AP
	sum c_6_1acre, d

	
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
	
	note: Cultivators who depend on irrigated land have a much higher income than those who live of non-irrigated land. 
	count if  c_8_annualincome==.b
	count if c_8_annualincome==.d
	
	*--- C_9 Do you or a member of your household have a bank account?----* 
	
	tab c_9_bankaccount, m 
	count if  c_9_bankaccount==0 & c_1_incomesource==1
	note: Little less than 50% are agricultural labourers who don't have bank accounts.
	
	*--C_10 Was the last Kharif season a good rainfall or bad rainfall year?---*
	
	label define last_kharif 1 "Good" 0 "Bad" .d "Do not Know" .b "Refused to Answer" .a "Not applicable"
	label values  c_10_lastkharif last_kharif 
	ta  c_10_lastkharif, m
	//Last Kharif seems to have been bad for farmers. 

	*--C_11 Since 2011 did the household experience a bad shock?---*
	tab  c_11_shock, m
	
	*--C_11_A What type of shock did your household face?--*
	ta c_11_shocktype
    **Split Multiple Option Variable**
	split c_11_shocktype, p(" ")
	destring c_11_shocktype1 c_11_shocktype2 c_11_shocktype3 c_11_shocktype4 c_11_shocktype5, replace
    **Label New Variables**
	 label var c_11_shocktype1 "Shock Choice 1"
	 label var c_11_shocktype2 "Shock Choice 2"
	 label var c_11_shocktype3 "Shock Choice 3"
	 label var c_11_shocktype4 "Shock Choice 4"
	 label var c_11_shocktype5 "Shock Choice 5"
	 
	 note: More shock variables may be created if more shocks are chosen by a single household.	
	 foreach x of varlist c_11_shocktype1-c_11_shocktype5 {
     replace `x'=.c if `x'==-888
     } 
	 label define shock  1 "Drought/Irregular Rains" 2 "Flood" 3	"Storm/Winds" 4	"Crops damaged by insects/disease/animals" 5 "Livestock Illness" 6	"Lack of household labour" 7 "Lack of agricultural Inputs" 8 "Household member ill or injured" 9 "Death of household member" 10 "Loss of job or unemployment" 11 "Theft of crops or livestock"  12 "Political Problems" 13 "Price Fluctuations" 14	"Civil Conflict"  .c "Other"
	
	 label values c_11_shocktype1 c_11_shocktype2 c_11_shocktype3 c_11_shocktype4 c_11_shocktype5 shock 
	 tab c_11_shocktype1,m
	 tab c_11_shocktype2,m
	 tab c_11_shocktype3,m
	 tab c_11_shocktype4,m
	 tab c_11_shocktype5,m
	  
	  
	 *************************************************************************************************************************************************
	 *--------------------------------------------------- SECTION D : PAST EXPERIENCES WITH MIGRATION ------------------------------------------------
	 ************************************************************************************************************************************************* 
	 
	 
	*---D_1 Have you or any members of your household seasonally migrated to find work elsewhere (outside your village) during the lean season from March to May 2013? 
	tab  d_1_migrant, m
	//Agricultural Wage Employment
	ta d_1_migrant if c_1_incomesource==1
	//Cultivation on owned irrigated land 
	 ta d_1_migrant if c_1_incomesource==2
	//Cultivation on owned non-irrigated land 
	ta d_1_migrant if c_1_incomesource==3
	//Cultivated on rented irrigated land 
	ta d_1_migrant if c_1_incomesource==4
	//Cultivation on rented non-irrigated land
	ta d_1_migrant if c_1_incomesource==5
	//Non-Agricultural Wage Employment 
	ta d_1_migrant if c_1_incomesource==8
	//Other source
	ta d_1_migrant if c_1_incomesource==.c
	
	note: Agricultural wage labour has highest migration rate (~8%) when compared to other groups. 
	
	*--D_1_A How many days was he/she  away for work during the lean season---
	sum  d_1_a_daysaway, d
	
	*----D_1_B What was the total income earned from migrating during the lean season 
	sum  d_1_b_migincome, d
	count if d_1_b_migincome==.a
	count if d_1_b_migincome==.b
	count if d_1_b_migincome==.d
	
	*---D_1_C Who in your household has seasonally migrated for employment during the lean season --
	tab  d_1_c_migmember, m
	**Split Multiple Option Variable**
	split d_1_c_migmember, p(" ")
	label var d_1_c_migmember1 "Member 1 to migrate"
	label var d_1_c_migmember2 "Member 2 to migrate"
	label var d_1_c_migmember3 "Member 3 to migrate"
	destring d_1_c_migmember1 d_1_c_migmember2 d_1_c_migmember3, replace
	note: More variables may be created if more than two choices are chosen by a single household. 
	label values  d_1_c_migmember1 d_1_c_migmember2 d_1_c_migmember3 mig_member
	foreach x of varlist d_1_c_migmember1-d_1_c_migmember3{
		replace `x'=.c if `x'==-888
		}
	label define mig_member 1 "Head of Household" 2 "Spouse" 3 "Son/Daughter" 4 "Daughter-in-L/Son-in-L" 5 "Grandson/Granddaughter" 6 "Parents" 7 "Father-in-L/Mother-in-L" 8 "Brother/Sister" 9 "Brother-in-L/Sister-in-L" 10 "Uncle/Aunt" .c "Other" 
	tab  d_1_c_migmember1, m
	ta d_1_c_migmember2, m
	ta d_1_c_migmember3, m
	
	*---D_1_D Where did he/she seasonally migrate to during the lean season
	
	label define india_abroad 1 "India" 0 "Abroad" 
	label values d_1_d_indiaabroad india_abroad
	tab  d_1_d_indiaabroad, m
	
	*----D_1_E Why did he/she choose to migrate to the above city during the lean season 
	tab d_1_e_whymigdest, m
	
	**Split Multiple Option Variable**
	split d_1_e_whymigdest, p(" ")
	
	**Label New Variables**
	label var d_1_e_whymigdest1 "Reason 1 for choosing mig dest"
	label var d_1_e_whymigdest2 "Reason 2 for choosing mig dest"
	label var d_1_e_whymigdest3 "Reason 3 for choosing mig dest"
	label var d_1_e_whymigdest4 "Reason 4 for choosing mig dest"
	note: More than two new variables may be created if more than two choices are chosen by a single household.
	destring d_1_e_whymigdest1- d_1_e_whymigdest4, replace
	foreach x of varlist d_1_e_whymigdest1- d_1_e_whymigdest4 {
     replace `x'=.c if `x'==-888
     } 
	label define why_mig_dest 1 "Returning to the same employer" 2 "Many opportunities available" 3 "Employer recruited at the village" 4 "Friends/Family at the destination" 5 "Close to home" 6 "Common migration destination" .c "Other" 	
	label values d_1_e_whymigdest1 d_1_e_whymigdest2 d_1_e_whymigdest3 d_1_e_whymigdest4 why_mig_dest
	
	tab d_1_e_whymigdest1,m
	tab d_1_e_whymigdest2,m
	tab d_1_e_whymigdest3,m
	tab d_1_e_whymigdest4,m
	
	*---D_1_F What mode of transportation did he/she take to reach the migration destination?
	label define transport 1 "Bus" 2 "Train" 3 "Lorry" 4 "Auto-Rickshaw" 5 "Shared car" 6 "By foot" 7 "Bullock cart" .c "Other" .d "Do not know"
	label values  d_1_f_transport transport
	tab d_1_f_transport,m
	br if d_1_f_transport==.c
	
	
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
	tab  d_1_k_findjob,m
	split d_1_k_findjob, p(" ") 
	lab var  d_1_k_findjob1 "Way 1 to find job"
	lab var  d_1_k_findjob2 "Way 2 to find job"
	lab var  d_1_k_findjob3 "Way 3 to find job"
	lab var  d_1_k_findjob4 "Way 4 to find job"
	destring d_1_k_findjob1-d_1_k_findjob4, replace
	foreach x of varlist d_1_k_findjob1-d_1_k_findjob4{
		replace `x'=.c if `x'==-888
	}
	
	
	label define find_job 1 "Returning to the same employer from previous migration" 2 "Through a friend or relative" 3 "Employer came to the village" 4 "Employer came to neighborhood at mig destination" 5 "Newspaper/Ads" 6 "Middleman" .c "Other" 
	label values d_1_k_findjob1 d_1_k_findjob2 d_1_k_findjob3 d_1_k_findjob4 find_job
	tab  d_1_k_findjob1,m
	ta d_1_k_findjob2, m
	drop d_1_k_findjob
	
	
	tab d_1_k_other
	replace d_1_k_other="INTERVIEW" if d_1_k_other=="Interveiw"
	
	*----- D_1_L What was his/her occupation while migrating? 
	
	label define occupation 1 "Construction Worker" 2 "Driver" 3 "Factory Worker" 4 "Carpenter" 5 "Mason" 6 "Welder" 7 "Agricultural Labourer" 8 "Coolie" .c "Other" .d "Do not Know"
	label values d_1_l_occupation occupation
	tab  d_1_l_occupation,m
	ta  d_1_l_other, m
	replace d_1_l_other="HOUSEKEEPER" if d_1_l_other=="House Keeper"|d_1_l_other=="House keeping"
	replace d_1_l_other="PRIEST" if d_1_l_other=="Worship"
	
	
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
	**Split multiple Option Variable**
	note: More than two new variables may be created if more than two choices are chosen by a single household.
	split d_1_o_sendmoney, p(" ")
	**Label new variables**
	label var  d_1_o_sendmoney1 "Way 1 of sending money home"
	label var  d_1_o_sendmoney2 "Way 2 of sending money home"
	label var  d_1_o_sendmoney3 "Way 3 of sending money home"
	destring d_1_o_sendmoney1 d_1_o_sendmoney2 d_1_o_sendmoney3, replace
	
	label define send_money 1 "Returned home several times" 2 "Returned with lump sum at end" 3 "Bank account" 4 "Postal office" 5 "Hawala courier" 6 "Cash courier" 7 "Through family/friends" .c "Other" .d "Do not Know"
	label values d_1_o_sendmoney1 d_1_o_sendmoney2 send_money
	tab d_1_o_sendmoney1,m
	tab d_1_o_sendmoney2,m
	
	*--D_2 Have you or any member of your household seasonally migrated to find work elsewhere during the Rabi season from November2012 to February2013?
	tab  d_2_migrabi,m
	
	
	*--D_2_A How many days were was he/she away for work during the Rabi season 
	sum  d_2_a_daysaway,d
	
	*--D_2_B What was the tottaal income earned from migrating during the Rabi season
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
	label var  d_4_nomigrate5 "reason 5 for not migrating"
	label var  d_4_nomigrate6 "reason 6 for not migrating"
	label var  d_4_nomigrate7 "reason 7 for not migrating"
	note: More new variables may be created if more choices are chosen by a single household.
	destring  d_4_nomigrate1 d_4_nomigrate2 d_4_nomigrate3 d_4_nomigrate4 d_4_nomigrate5 d_4_nomigrate6 d_4_nomigrate7, replace
	label define nomigrate 1 "No money" 2 "Many opportunities available" 3 "No destination job information" 4 "No guarantee of job" 5 "Professional commitment" 6 "Enrolled in MNREGA" 7 "Cannot share costs" 8 "No contacts" 9 "Death or sickness" 10 "Cannot leave family" -999 "Do not Know" -888 "Other"
	label values d_4_nomigrate1 d_4_nomigrate2 d_4_nomigrate3  d_4_nomigrate4 d_4_nomigrate5 d_4_nomigrate6 d_4_nomigrate7 nomigrate 
	tab d_4_nomigrate1, m
	tab d_4_nomigrate2, m
	tab d_4_nomigrate3, m
	tab d_4_nomigrate4, m
	tab d_4_nomigrate5, m
	tab d_4_nomigrate6, m
	tab d_4_nomigrate7, m
	ta d_4_other, m
	

	
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
	note: 5 instances of a surveyor pressing "do not know" and "none of the above." Switching to do not know. 
	replace e_3_insurance="-999" if e_3_insurance=="6 -999"
	tab e_3_insurance
	label define insurance 1"Rainfall Insurance " 2"National Agricultural Insurance Scheme" 3"Modified National Agricultural Insurance Scheme " 4"Weather Based Crop Insurance Scheme " 5"Delayed Monsoon Onset Scheme " 6"None of the above " -999 "Do not Know"
	split e_3_insurance, p(" ")destring 
	label var e_3_insurance1 "Insurance Purchased_1"
	label var e_3_insurance2 "Insurance Purchased_2"
	label var e_3_insurance3 "Insurance Purchased_3"
	label values  e_3_insurance1  e_3_insurance2 e_3_insurance3 insurance
	tab e_3_insurance1,m
	tab e_3_insurance2,m
	tab e_3_insurance3,m
	
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
	
	label define whybuy 1"good investment" 2"mandatory" 3"family or friend suggested" .d "Do not know"
	tab e_4_whybuyins,m 
	split e_4_whybuyins, p(" ")
	label var e_4_whybuyins1 "Reason 1 for buying insurance"
	label var e_4_whybuyins2 "Reason 2 for buying insurance"
	label var e_4_whybuyins3 "Reason 3 for buying insurance"
	destring e_4_whybuyins1 e_4_whybuyins2 e_4_whybuyins3, replace
	label values e_4_whybuyins1 e_4_whybuyins2 e_4_whybuyins3 whybuy
	
	
	
	*----E_5 Have you ever received a pay out as a result of buying insurance? ---*
	tab  e_5_payout,m
	
	*---E_6 Did it ever happen that you did not get a payout when you thought you deserved to get it? ---*
	tab  e_6_deservepayout,m
	
	
	
	
	******************************************************************************************************************************************************
	*---------------------------------------------------------------- SECTION F: INSURANCE ---------------------------------------------------------------
	******************************************************************************************************************************************************
	
	
	*--------F_1  Shall we proceed with the explanation and offer? 
	tab f_1insexplain,m
	*gen insurance_offered=f_1insexplain==1 
	*label var insurance_offered "Shall we proceed with the explanation and offer?"
	
	* note: First visit purchasing
	*------F_2 Do you want to purchase Delayed Monsoon Onset Kharif 2014 Insurance? 
	tab  f_2purchasins,m
	bysort villname: tab  f_2purchasins, m
	
	*------- F_3 How many units would you like to purchase? 
	replace  f_3unitsins=0 if  f_3unitsins==. & category==2 & attrition==0
	tab  f_3unitsins,m
	bysort villname: tab  f_3unitsins,m
	
	*note: Second Visit Purchase
	*--------F_5 Do you want to purchase Delayed Monsoon Onset Kharif 2014 Insurance?  
	tab  f_5purchasins,m
	bysort villname: tab  f_5purchasins, m
	
	*------F_6 How many units would you like to purchase? 
	bysort villname: tab f_6unitsins,m
	
	replace f_6unitsins=0 if f_6unitsins==. & category==2 & attrition==0
	tab f_6unitsins,m
	/*
	*---Total clients agreed to buy insurance---
	gen insurance_agreed = (f_2purchasins==1 |f_5purchasins==1)
	replace insurance_agreed=. if (f_1insexplain!=1) // Correctedly skipped
	label var insurance_agreed "Do you want to purchase Delayed Monsoon Onset Kharif 2014 Insurance? " // Added by SLee-2016-1-22
	label value insurance_agreed yesno
	tab insurance_agreed
	bysort villname: tab insurance_agreed if (category==2 & attrition==0)
	
	
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
	
	/*
	replace insurance_units=. if insurance_units==0
	sort villname 
	*/
	
	by villname: tab  insurance_unit_purchased if  insurance_unit_purchased>0
	tabstat insurance_unit_purchased, by (villname) stat(mean min max sd)
	*/

	

	*------F_7 What is the primary reason for not purchasing insurance? 
	rename (_7nobuyins _7_othernobuy) (f_7nobuyins f_7_othernobuy)
	
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
	tab f_7nobuyins1
	tab f_7nobuyins2
	tab f_7nobuyins3
	
	/*
	gen no_buy_reason=0
	replace no_buy_reason=1 if (f_7nobuyins1==1|f_7nobuyins2==1|f_7nobuyins3==1)
	replace no_buy_reason=2 if (f_7nobuyins1==2|f_7nobuyins2==2|f_7nobuyins3==2)
	replace no_buy_reason=3 if (f_7nobuyins1==3|f_7nobuyins2==3|f_7nobuyins3==3)
	replace no_buy_reason=4 if (f_7nobuyins1==4|f_7nobuyins2==4|f_7nobuyins3==4)
	replace no_buy_reason=5 if (f_7nobuyins1==5|f_7nobuyins2==5|f_7nobuyins3==5)
	replace no_buy_reason=6 if (f_7nobuyins1==6|f_7nobuyins2==6|f_7nobuyins3==6)
	replace no_buy_reason=7 if (f_7nobuyins1==7|f_7nobuyins2==7|f_7nobuyins3==7)
	replace no_buy_reason=-888 if (f_7nobuyins1==-888|f_7nobuyins2==-888|f_7nobuyins3==-888)
	label values no_buy_reason nobuyings
	ta no_buy_reason if no_buy_reason != 0
	*/
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
	tab  f_2migaccep
	
	
	*---F_3 Who from the household will be sent to seasonally migrate for employment purposes?  ----*
	
	label define migmember 1"Head of the Household" 2"Spouse" 3"Son or Daughter" 4"Daughter/Son in law" 5"Granddaughter/son" 6"Parents" 7"Father/Mother in law" 8"Brother/Sister" 9"Brother/Sisiter in law" 10"Uncle/Aunt" -888 "Other"
	label values f_3migmember migmember
	tab  f_3migmember, m
	tab f_3migother, m
	
	*--- F_4 Migration Destination ---------------*
	tab  f_4choosedest, m
	
	*--- G Second Visit Date ---------------*
	// compulsory second visit date this should be equal to respondents allowing to proceed f_1mig
	tab g_datesecvisit, m
	
	*--- G_1 Will you or any member of your household be participating in our migration incentive in which we buy you a round trip ticket to seasonally migrate to one of the top three migration destinations in your state?  ---------------*
	//accept to migrate and willing to get train ticket
	tab g_1migaccep
	*gen migration_accepted=(f_2migaccep==1 | g_1migaccep==1)
	*replace migration_accepted=. if (migration_offered!=1) // Correctedly skipped
	*label var migration_accepted "Accepted Migration Offer"
	
			
	*-----G_a_2 Who from the household will be sent to seasonally migrate for employment purposes?
	
	//confirming migrating member	
	label values g_a_2migmember migmember
	tab  g_a_2migmember, m
	tab g_a_2migother, m
	
	*--- G_a_2 Do you or the migrating member of the household have a mobile phone that you can use for receiving the travel ticket via SMS/text message?
	//mobile phone availability
	tab g_a_2cellphone
	
	*-----G_a_b date of departure and return to and from the migration destination
		
	//leave month & date
	label define month 1 "MARCH" 2 "APRIL" 3 "MAY"
	label values g_a_b_1migmonthleave month
	tab  g_a_b_1migmonthleave g_a_b_1migdateleave, m
	
	//return month & date
	label values g_a_b_2migmonthreturn month
	tab  g_a_b_2migmonthreturn g_a_b_2migdayreturn, m
	
	*-----G_a_3 final confirmation of destination
	tab g_a_3destconfirm, m
	
	*---G_a_4 Reason for migrating to the specific city
		
	split g_a_4whymigcity, p(" ") destring
	label define whymigcity 1"High wages" 2"Many Contacts " 3"Have migrated to the city before" 4"Have a place to stay" 5"Job Leads" 6"Low Moving Costs" -666"Not applicable" -888"Other"
    label values  g_a_4whymigcity1 g_a_4whymigcity2 g_a_4whymigcity3 g_a_4whymigcity4 whymigcity
	ta g_a_4whymigcity1, m
	ta g_a_4whymigcity2, m
	ta g_a_4whymigcity3, m
	ta g_a_4whymigcity4, m
	label var g_a_4whymigcity1 "Reason 1 for specific city migration"
	label var g_a_4whymigcity2 "Reason 2 for specific city migration"
	label var g_a_4whymigcity3 "Reason 3 for specific city migration"
	label var g_a_4whymigcity4 "Reason 4 for specific city migration"
	drop g_a_4whymigcity
	
	*OTHER REASON*
	ta  g_a_4otherwhycity

	*---- G_a_5 migration without incentive
	tab  g_a_5migwithout, m
	
	
	*---- G_a_6 What was the main reason for accepting the incentive? -------------*
	split  g_a_6chooseincent, p(" ") destring
	label define chooseincent 1"Makes migration affordable" 2"Allows me to explore options" 3"willing to take the risk" -999"Do not Know" -888"Other 
	label values g_a_6chooseincent1 g_a_6chooseincent2 g_a_6chooseincent3 chooseincent
	tab g_a_6chooseincent1, m
	ta g_a_6chooseincent2, m
	ta g_a_6chooseincent3, m
	label var g_a_6chooseincent1 "Reason 1 for accepting migration incentive"
	label var g_a_6chooseincent2 "Reason 2 for accepting migration incentive"
	label var g_a_6chooseincent3 "Reason 3 for accepting migration incentive"
	
		
	*---- G_7 Accepted cash rather than round trip ticket
	tab  g_7cashovertick
	
	*---- G_8 Accepted offer if own choice destination was offered.
	tab g_8anydestoffer
	
	*---- G_9 Reasons for not accepting migration.
	
	//check -888 and make the data consistent if family reasons are added in others
	//splitting the values & table most frequent reasons for not accepting migration
	tab g_9noaccept, m
	tab g_9other, m
	gen noaccept=soundex(g_9other)
	
	foreach i in O432 {
	replace g_9other="Old Age" if noaccept=="`i'"
	}
	
	
	
	split g_9noaccept, p(" ") destring
	label var g_9noaccept1 "reason 1 for not accepting"
	label var g_9noaccept2 "reason 2 for not accepting"
	label var g_9noaccept3 "reason 3 for not accepting"
	label var g_9noaccept4 "reason 4 for not accepting"
	label var g_9noaccept5 "reason 5 for not accepting"
	
	destring g_9noaccept1 g_9noaccept2 g_9noaccept3 g_9noaccept4 , replace
	label define noaccept 1"Still too expensive" 2"Do not know opportunities at destination" 3"Too risky" 4"enough opportunities at local job markets" 5"No guarantee of employment" 6"Cannot leave land" 7"Enrolled in government program" 8"Death/Sickness" 9" Family obligations" -888"other"
	label values  g_9noaccept1 g_9noaccept2 g_9noaccept3 g_9noaccept4 noaccept
	tab g_9noaccept1
	tab g_9noaccept2
	ta g_9noaccept3
	ta g_9noaccept4
	ta g_9noaccept5
	drop noaccept
	
	/*gen no_accept_mig=0
	replace no_accept_mig=1 if (g_9noaccept1==1|g_9noaccept2==1|g_9noaccept3==1|g_9noaccept4==1)
	replace no_accept_mig=2 if (g_9noaccept1==2|g_9noaccept2==2|g_9noaccept3==2|g_9noaccept4==2)	
	replace no_accept_mig=3 if (g_9noaccept1==3|g_9noaccept2==3|g_9noaccept3==3|g_9noaccept4==3)
	replace no_accept_mig=4 if (g_9noaccept1==4|g_9noaccept2==4|g_9noaccept3==4|g_9noaccept4==4)
	replace no_accept_mig=5 if (g_9noaccept1==5|g_9noaccept2==5|g_9noaccept3==5|g_9noaccept4==5)
	replace no_accept_mig=6 if (g_9noaccept1==6|g_9noaccept2==6|g_9noaccept3==6|g_9noaccept4==6)
	replace no_accept_mig=7 if (g_9noaccept1==7|g_9noaccept2==7|g_9noaccept3==7|g_9noaccept4==7)
	replace no_accept_mig=8 if (g_9noaccept1==8|g_9noaccept2==8|g_9noaccept3==8|g_9noaccept4==8)
	replace no_accept_mig=9 if (g_9noaccept1==9|g_9noaccept2==9|g_9noaccept3==9|g_9noaccept4==9)
	replace no_accept_mig=-888 if (g_9noaccept1==-888|g_9noaccept2==-888|g_9noaccept3==-888|g_9noaccept4==-888)
	label values no_accept_mig noaccept
	ta no_accept_mig if no_accept_mig !=0
	*/
	
	
	
	//Village wise take up
	sort villname 
	

	
	*Final migration take up
	
	by villname: tab category if category==3
	by villname: tab f_1mig
	by villname: tab  g_1migaccep
	tabstat  g_1migaccep , by (villname) stat(min max sd)
	
	
	tab a1_2reasonfornofind if category==3
	tab a1_2other if category==3
	
	tabm  g_9noaccept1 g_9noaccept2 g_9noaccept3 g_9noaccept4 g_9noaccept5 
	
	*/

// Drop intervention variable (will be merged with correct intervention information later)
drop category
	

/****************************************************************
	SECTION 3: Save and Exit		 									
****************************************************************/

compress
save "$mk/Final_Data\final_cleaned_data.dta", replace
save "${builddta}/round2/IN_rainfall_r2_cleaned_AP.dta", replace

cap file close _all
cap log close
copy "${buildlog}/`name_do'.smcl" ///
	"${buildlog}/archive/`name_do' - `c(current_date)' - `c(username)'.smcl" ///
	, replace
exit
	

	
	
	
