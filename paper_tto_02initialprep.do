** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    paper_tto_02initialprep.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	31-MAr-2021
    //  algorithm task			    Reading the WHO GHE dataset - disease burden, YLL and DALY

    ** General algorithm set-up
    version 16
    clear all
    macro drop _all
    set more 1
    set linesize 80

    ** Set working directories: this is for DATASET and LOGFILE import and export

    ** DATASETS to encrypted SharePoint folder
    local datapath "X:\OneDrive - The University of the West Indies\Writing\w008\data"

    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath "X:\OneDrive - The University of the West Indies\Writing\w008\tech-docs"

    ** REPORTS and Other outputs
    local outputpath "X:\OneDrive - The University of the West Indies\Writing\w008\outputs"

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\paper_tto_02initialprep", replace
** HEADER -----------------------------------------------------

** RUN covidprofiles_002_jhopkins.do BEFORE this algorithm
use "`datapath'\owid_time_series_6Mar2022", clear 

rename iso_code iso

** RESTRICT TO SELECTED COUNTRIES
** We keep 14 CARICOM countries:    --> ATG BHS BRB BLZ DMA GRD GUY HTI JAM KNA LCA VCT SUR TTO
** We keep 6 UKOTS                  --> AIA BMU VGB CYM MSR TCA 
** + Cuba                           --> CUB
** + Dominican Republic             --> DOM
#delimit ;
keep if
    iso == "AIA" |
    iso == "ATG" |
    iso == "BHS" |
    iso == "BRB" |
    iso == "BLZ" |
    iso == "BMU" |
    iso == "VGB" |
    iso == "CYM" |
    iso == "CUB" |
    iso == "DMA" |
    iso == "DOM" |
    iso == "GRD" |
    iso == "GUY" |
    iso == "HTI" |
    iso == "JAM" |
    iso == "MSR" |
    iso == "KNA" |
    iso == "LCA" |
    iso == "VCT" |
    iso == "SUR" |
    iso == "TCA" |
    iso == "TTO" |

    iso == "NZL" |
    iso == "SGP" |
    iso == "ISL" |
    iso == "FJI" |
    iso == "VNM" |
    iso == "KOR" |
    iso == "ITA" |
    iso == "GBR" |
    iso == "DEU" |
    iso == "SWE" |

    iso == "CRI" |
    iso == "SLV" |
    iso == "GTM" |
    iso == "HND" |
    iso == "MEX" |
    iso == "NIC" |
    iso == "PAN" |

    iso == "ARG" |
    iso == "BOL" |
    iso == "BRA" |
    iso == "CHL" |
    iso == "COL" |
    iso == "ECU" |
    iso == "PRY" |
    iso == "PER" |
    iso == "URY" |
    iso == "VEN" 
    ;
#delimit cr

** Sort the dataset, ready for morning manual review 
sort iso date

** ---------------------------------------------------------
** FINAL PREPARATION
** ---------------------------------------------------------

preserve
    tempfile tto 
    keep if iso=="TTO"
    replace iso="TTO2"
    save `tto', replace
restore


** Create internal numeric variable for countries 
encode iso, gen(iso_num)
order iso_num pop, after(iso)

** CARICOM, UKOT, OTHER, COMPARATOR
gen cgroup = .
replace cgroup = 1 if iso=="ATG" | iso=="BHS" | iso=="BRB" | iso=="BLZ" | iso=="DMA" | iso=="GRD" | iso=="GUY" | iso=="HTI" | iso=="JAM" | iso=="KNA" | iso=="LCA" | iso=="VCT" | iso=="SUR" 
replace cgroup = 2 if iso=="AIA" | iso=="BMU" | iso=="VGB" | iso=="CYM" | iso=="MSR" | iso=="TCA"
replace cgroup = 3 if iso=="CUB" | iso=="DOM"
replace cgroup = 4 if iso=="NZL" | iso=="SGP" | iso=="ISL" | iso=="FJI" | iso=="VNM" | iso=="KOR" | iso=="ITA" | iso=="GBR" | iso=="DEU" | iso=="SWE"
replace cgroup = 5 if iso=="CRI" | iso=="SLV" | iso=="GTM" | iso=="HND" | iso=="MEX" | iso=="NIC" | iso=="PAN"
replace cgroup = 6 if iso=="ARG" | iso=="BOL" | iso=="BRA" | iso=="CHL" | iso=="COL" | iso=="ECU" | iso=="PRY" | iso=="PER" | iso=="URY" | iso=="VEN"
replace cgroup = 7 if iso=="TTO"
label define cgroup_ 1 "caricom" 2 "ukot" 3 "car-other" 4 "comparator" 5 "central america" 6 "south america" 7 "trinidad & tobago"
label values cgroup cgroup_ 

** Keep just the Caribbean right now AND regroup
keep if cgroup==1 | cgroup==2 | cgroup==3 | cgroup==7
gen group = 1 if cgroup==1 | cgroup==2
replace group = 2 if cgroup==7
replace group = 3 if cgroup==3
label define group_ 1 "caricom" 3 "latin caribbean" 2 "trinidad & tobago"
label values group group_

** Fill-in missing data 
replace new_deaths = 0 if new_deaths==. 
replace total_deaths = 0 if total_deaths==. 

** Save the cleaned and restricted dataset
save "`datapath'\paper_tto_covid", replace
