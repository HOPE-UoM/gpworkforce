clear all

// Set paths dynamically
global currentuser "Insert your username" // eg. global currentuser "s48620if"
if c(username) == $currentuser {
	global path yourpath // e.g. global path C:\Users\s48620if\Dropbox (The University of Manchester)\Workforce research data\
	}

// Setting a path to a specific folder to unzip all the raw files
cd "$path/yourrawdatapath" // e.g. cd "$path/rawdata"

// Download and unzip the raw csv data
unzipfile "https://www.dropbox.com/scl/fi/q6q4kqshf1v9j7xh564vv/csv.zip?rlkey=hndgel7ilt8cgn6ctlelcx2e1&dl=0", replace
	
// Create Stata files from .csv files

// September
forvalues i=2015/2024 {

clear all
import delimited "csv\General Practice September `i' Practice Level", varnames(1) asdouble
gen year=`i'
gen month=9
save "wf_sept_`i'.dta", replace
}

// March
forvalues i=2016/2024 {

clear all
import delimited "csv\General Practice March `i' Practice Level", varnames(1) asdouble
gen year=`i'
gen month=3
save "wf_mar_`i'.dta", replace

}
// December
forvalues i=2016/2024 {

clear all
import delimited "csv\General Practice December `i' Practice Level", varnames(1) asdouble
gen year=`i'
gen month=12
save "wf_dec_`i'.dta", replace

}
// June
foreach i in 2017 2018 2019 2021 2022 2023 2024 {

clear all
import delimited "csv\General Practice June `i' Practice Level", varnames(1) asdouble
gen year=`i'
gen month=6
save "wf_jun_`i'.dta", replace

}

clear all
import delimited "csv\Practice codes with coordinates", varnames(1)
rename code prac_code
save "coordinates.dta", replace

// Merge all years from 2015 to 2024 in the main folder with raw data
clear all
append using `: dir . files "*.dta"', force
keep prac_code prac_name ccg_code ccg_name region_geog_code region_geog_name region_code region_name hee_region_code hee_region_name pcn_code pcn_name contract year month total_patients total_male total_female male_patients_0to4 male_patients_5to14 male_patients_15to44 male_patients_45to64 male_patients_65to74 male_patients_75to84 male_patients_85plus female_patients_0to4 female_patients_5to14 female_patients_15to44 female_patients_45to64 female_patients_65to74 female_patients_75to84 female_patients_85plus total_disp_patients gp_source nurse_source dpc_source admin_source total_gp_hc male_gp_hc female_gp_hc total_nurses_hc male_nurses_hc female_nurses_hc total_dpc_hc male_dpc_hc female_dpc_hc total_dpc_pharma_hc total_dpc_app_pharma_hc male_dpc_pharma_hc male_dpc_app_pharma_hc female_dpc_pharma_hc female_dpc_app_pharma_hc total_dpc_adv_pharma_prac_hc male_dpc_adv_pharma_prac_hc female_dpc_adv_pharma_prac_hc total_dpc_adv_pharma_prac_fte total_gp_fte male_gp_fte female_gp_fte total_nurses_fte male_nurses_fte female_nurses_fte total_dpc_fte male_dpc_fte female_dpc_fte total_dpc_pharma_fte total_dpc_app_pharma_fte male_dpc_pharma_fte male_dpc_app_pharma_fte female_dpc_pharma_fte female_dpc_app_pharma_fte total_dpc_adv_pharma_prac_fte male_dpc_adv_pharma_prac_fte female_dpc_adv_pharma_prac_fte total_dpc_adv_pharma_prac_fte total_dpc_pharmt_hc male_dpc_pharmt_hc female_dpc_pharmt_hc total_dpc_pharmt_fte male_dpc_pharmt_fte female_dpc_pharmt_fte
order pcn_code pcn_name year month, after(contract)

// Set "ND" to missing and destring otherwise numeric variables
global vars total_gp_hc male_gp_hc female_gp_hc total_gp_fte male_gp_fte female_gp_fte total_nurses_hc male_nurses_hc female_nurses_hc total_nurses_fte male_nurses_fte female_nurses_fte total_dpc_hc total_dpc_pharma_hc total_dpc_app_pharma_hc male_dpc_hc male_dpc_pharma_hc male_dpc_app_pharma_hc female_dpc_hc female_dpc_pharma_hc female_dpc_app_pharma_hc total_dpc_fte total_dpc_pharma_fte total_dpc_app_pharma_fte male_dpc_fte male_dpc_pharma_fte male_dpc_app_pharma_fte female_dpc_fte female_dpc_pharma_fte female_dpc_app_pharma_fte total_dpc_adv_pharma_prac_hc male_dpc_adv_pharma_prac_hc female_dpc_adv_pharma_prac_hc total_dpc_adv_pharma_prac_fte male_dpc_adv_pharma_prac_fte female_dpc_adv_pharma_prac_fte total_dpc_pharmt_hc male_dpc_pharmt_hc female_dpc_pharmt_hc total_dpc_pharmt_fte male_dpc_pharmt_fte female_dpc_pharmt_fte
foreach v of global vars {
replace `v'="" if `v'=="ND"
}
destring total_gp_hc-female_dpc_adv_pharma_prac_fte, replace force

// Merge GPS coordinates
merge m:1 prac_code using coordinates
drop if _merge==2
drop _merge

// Save file with quarterly snapshots of workforce data for GP practices in England
save "$path/wf_20152024.dta", replace