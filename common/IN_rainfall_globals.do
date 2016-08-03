/*****************************************************************
PROJECT: 		IN_Rainfall, India Rainfall Insurance
				
TITLE:			IN_rainfall_globals.do
			
AUTHOR: 		Seungmin Lee (seungmin.lee@yale.edu, eatorange@gmail.com)

DATE CREATED:	January 27, 2016

LAST EDITED:	June 22, 2016

DESCRIPTION: 	Declares macros used in other do-files
	
ORGANIZATION:	1 - User-directory setup
				2 - Working directory setup
				
INPUTS: 		N/A

OUTPUTS: 		N/A

NOTE:			This file should always be run first for other do-files to be run properly.
******************************************************************/

/****************************************************************
	SECTION 1: User-directory setup					 									
****************************************************************/

// Add username of each collaborator and directory

if "`c(username)'" == "ftac2"{ // Min
	global dropbox "C:/Users/ftac2/Dropbox"
}
*
if "`c(username)'" == "mbrooks"{ // Meir
	global dropbox "C:/Users/mbrooks/Dropbox"
}
*

loc error_dropbox "set a global -dropbox- as the filepath to your main dropbox folder, the parent directory of the overall -Rainfall insurance India - Round 2- folder"

if "${dropbox}" == "" { 
	di as error "`error_dropbox'"
	exit
}
*
/****************************************************************
	SECTION 2: Working directory setup					 									
****************************************************************/

global IN_rainfall_r1 			"${dropbox}/Malawi_lisa & talya"

global IN_rainfall_r2r3			"${dropbox}/Rainfall insurance India - Round 2"
	global r2r3_data			"${IN_rainfall_r2r3}/Data"
		global r2_data			"${r2r3_data}/Marketing_Intervention_2014"
		global r3_data			"${r2r3_data}/Marketing_Intervention_Round_2_2014"
		global followup_data	"${r2r3_data}/StataData_2014_follow-up_survey"
	
	global build_analysis		"${IN_rainfall_r2r3}/Data Analysis"
		
		global common			"${build_analysis}/common"
			global ado  		"${common}/ado"
				adopath ++		"${ado}"
		
		global build			"${build_analysis}/build"
			global builddo		"${build}/code"
			global buildlog		"${build}/logs"
			global builddta		"${build}/output/datasets"
			global buildfig		"${build}/output/figures"
			global buildtab		"${build}/output/tables"
		
		global analysis			"${build_analysis}/analysis"
		
			global ADB			"${analysis}/ADB Final Report"
				global ADBdo	"${ADB}/code"
				global ADBlog	"${ADB}/logs"
				global ADBdta	"${ADB}/output/datasets"
				global ADBfig	"${ADB}/output/figures"
				global ADBtab	"${ADB}/output/tables"
		
		global outdated			"${build_analysis}/Old works until 2016-01-27"

cd "${build_analysis}"
