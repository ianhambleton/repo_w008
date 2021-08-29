** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    paper_tto_03figure.do
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
    log using "`logpath'\paper_tto_03figure", replace
** HEADER -----------------------------------------------------

use "`datapath'\paper_tto_covid", clear

rename total_cases confirmed
rename total_deaths deaths

** Attack Rate (per 1,000 --> not yet used)
gen confirmed_rate = (confirmed / pop) * 100000

** SMOOTHED CASES for graphic
bysort iso: asrol confirmed , stat(mean) window(date 3) gen(confirmed_av3)
bysort iso: asrol deaths , stat(mean) window(date 3) gen(deaths_av3)
** REGIONAL VALUES
rename confirmed metric1
rename confirmed_rate metric2
rename deaths metric3
reshape long metric, i(iso_num iso date) j(mtype)
label define mtype_ 1 "cases" 2 "attack rate" 3 "deaths"
label values mtype mtype_
sort iso mtype date 



** LINE CHART (LOGARITHM)
** LINE against region for other 13 CARICOM countries 

** Drop Caribbean (Other-CUB DOM) or 10 GLobal comparators
** label define cgroup_ 1 "caricom" 2 "ukot" 3 "car-other" 4 "comparator" 5 "central america" 6 "south america"
drop if cgroup==3 | cgroup==4

** Create 2 sub-regionl groups
gen srgroup = . 
replace srgroup = 1 if cgroup==1 | cgroup==2
replace srgroup = 2 if cgroup==5 | cgroup==6
replace srgroup = 3 if cgroup==7
label define srgroup_ 1 "caribbean" 2 "latin america" 3 "trinidad & tobago"
label values srgroup srgroup_

** Cleaning
drop if confirmed==.

#delimit ;
    collapse    (sum) metric_tot=metric
                (mean) metric_av=metric
                (p05) metric_p05=metric
                (p10) metric_p10=metric
                (p20) metric_p20=metric
                (p25) metric_p25=metric
                (p30) metric_p30=metric
                (p40) metric_p40=metric
                (p50) metric_p50=metric
                (p60) metric_p60=metric
                (p70) metric_p70=metric
                (p75) metric_p75=metric
                (p80) metric_p80=metric
                (p90) metric_p90=metric
                (p95) metric_p95=metric
                (min) metric_min=metric
                (max) metric_max=metric
                , by(srgroup mtype date);
#delimit cr 
bysort srgroup mtype: gen elapsed = _n
order elapsed , after(date)

** SMOOTHED CASES for graphic
    sort srgroup mtype date
    bysort srgroup mtype: asrol metric_tot , stat(mean) window(date 14) gen(tots)
    bysort srgroup mtype: asrol metric_p05 , stat(mean) window(date 14) gen(p05s)
    bysort srgroup mtype: asrol metric_p10 , stat(mean) window(date 14) gen(p10s)
    bysort srgroup mtype: asrol metric_p20 , stat(mean) window(date 14) gen(p20s)
    bysort srgroup mtype: asrol metric_p25 , stat(mean) window(date 14) gen(p25s)
    bysort srgroup mtype: asrol metric_p30 , stat(mean) window(date 14) gen(p30s)
    bysort srgroup mtype: asrol metric_p40 , stat(mean) window(date 14) gen(p40s)
    bysort srgroup mtype: asrol metric_p50 , stat(mean) window(date 14) gen(p50s)
    bysort srgroup mtype: asrol metric_p60 , stat(mean) window(date 14) gen(p60s)
    bysort srgroup mtype: asrol metric_p70 , stat(mean) window(date 14) gen(p70s)
    bysort srgroup mtype: asrol metric_p75 , stat(mean) window(date 14) gen(p75s)
    bysort srgroup mtype: asrol metric_p80 , stat(mean) window(date 14) gen(p80s)
    bysort srgroup mtype: asrol metric_p90 , stat(mean) window(date 14) gen(p90s)
    bysort srgroup mtype: asrol metric_p95 , stat(mean) window(date 14) gen(p95s)


** COLORS - PURPLES for CVD
    colorpalette sfso, languages nograph
    local list r(p) 
    ** Age groups
    local red `r(p1)'  
    local blu `r(p2)'    
    local gre `r(p3)'    
    local yel `r(p4)'    
    local pur `r(p5)'    

** Matrix type
** 1 - cases
** 2 - attack rate 
** 3 - deaths
local type = 1
    #delimit ;
        gr twoway             
            /// Caribbean (SFSO VOTES color collection - colorpalette)
            ///(rarea p25s p40s elapsed if srgroup==1 & mtype==`type' , col("`blu'*0.2") lw(none))
            (rarea p40s p60s elapsed if srgroup==1 & mtype==`type' , col("`blu'*0.6") lw(none))
            ///(rarea p60s p75s elapsed if srgroup==1 & mtype==`type' , col("`blu'*0.2") lw(none))
            (line p50s elapsed       if srgroup==1 & mtype==`type' , lc("`blu'") lw(0.4) lp("-"))
            /// Latin America (SFSO VOTES color collection - colorpalette)
            ///(rarea p25s p40s elapsed if srgroup==2 & mtype==`type' , col("`pur'*0.2") lw(none))
            (rarea p40s p60s elapsed if srgroup==2 & mtype==`type' , col("`pur'*0.6") lw(none))
            ///(rarea p60s p75s elapsed if srgroup==2 & mtype==`type' , col("`pur'*0.2") lw(none))
            (line p50s elapsed       if srgroup==2 & mtype==`type' , lc("`pur'") lw(0.4) lp("-"))
            /// TTO
            (rarea p25s p40s elapsed if srgroup==3 & mtype==`type' , col("`gre'*0.2") lw(none))
            (rarea p40s p60s elapsed if srgroup==3 & mtype==`type' , col("`gre'*0.6") lw(none))
            (rarea p60s p75s elapsed if srgroup==3 & mtype==`type' , col("`gre'*0.2") lw(none))
            (line p50s elapsed       if srgroup==3 & mtype==`type' , lc("`gre'") lw(0.4) lp("-"))
            ,
            plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
            graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
            bgcolor(white) 
            ysize(12) xsize(6)
            
                xlab(0(100)500
                , 
                labs(3) notick nogrid glc(gs16))
                xscale(noline) 
                xtitle("Days since first case", size(3) margin(l=2 r=2 t=4 b=2)) 
                
                ylab(1 10 100 1000 "1k" 10000 "10k" 100000 "100k" 500000 "500k"
                ,
                labs(3) nogrid glc(gs16) angle(0) format(%9.0f))
                ytitle("Cumulative # of Cases", size(3) margin(l=2 r=2 t=2 b=2)) 
                yscale(log)

                legend(size(3) position(5) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lc(gs16)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                order(2 6) 
                lab(2 "Caribbean")
                lab(6 "Latin America")
                )
                name(cases) 
                ;
        #delimit cr
        graph export "`outputpath'/paper_tto_cases_$S_DATE.png", replace width(4000) 


local type = 2
    #delimit ;
        gr twoway             
            /// Caribbean
            (rarea p25s p40s elapsed if srgroup==1 & mtype==`type' , col("`blu'*0.1") lw(none))
            (rarea p40s p60s elapsed if srgroup==1 & mtype==`type' , col("`blu'*0.6") lw(none))
            (rarea p60s p75s elapsed if srgroup==1 & mtype==`type' , col("`blu'*0.1") lw(none))
            (line p50s elapsed       if srgroup==1 & mtype==`type' , lc("`blu'") lw(0.4) lp("-"))
            /// Latin America (SFSO VOTES color collection - colorpalette)
            (rarea p25s p40s elapsed if srgroup==2 & mtype==`type' , col("`pur'*0.1") lw(none))
            (rarea p40s p60s elapsed if srgroup==2 & mtype==`type' , col("`pur'*0.6") lw(none))
            (rarea p60s p75s elapsed if srgroup==2 & mtype==`type' , col("`pur'*0.1") lw(none))
            (line p50s elapsed       if srgroup==2 & mtype==`type' , lc("`pur'") lw(0.4) lp("-"))
            /// Trinidad
            (rarea p25s p40s elapsed if srgroup==3 & mtype==`type' , col("`gre'*0.1") lw(none))
            (rarea p40s p60s elapsed if srgroup==3 & mtype==`type' , col("`gre'*0.6") lw(none))
            (rarea p60s p75s elapsed if srgroup==3 & mtype==`type' , col("`gre'*0.1") lw(none))
            (line p50s elapsed       if srgroup==3 & mtype==`type' , lc("`gre'") lw(0.4) lp("-"))
            ,
            plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
            graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
            bgcolor(white) 
            ysize(12) xsize(6)
            
                xlab(0(100)500
                , 
                labs(3) notick nogrid glc(gs16))
                xscale(noline) 
                xtitle("Days since first case", size(3) margin(l=2 r=2 t=4 b=2)) 
                
                ylab(1 10 100 1000 10000
                ,
                labs(3) nogrid glc(gs16) angle(0) format(%9.0f))
                ytitle("Cases per 100,000 population", size(3) margin(l=2 r=2 t=2 b=2)) 
                yscale(log)

                legend(off size(3) position(11) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lc(gs16)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                order(2 6) 
                lab(2 "Caribbean")
                lab(6 "Latin America")
                )
                name(rates) 
                ;
        #delimit cr
        graph export "`outputpath'/paper_tto_rates_$S_DATE.png", replace width(4000) 


local dagger1 = uchar(8224)
local dagger2 = uchar(8225)
local sup1 = uchar(185)
local sup2 = uchar(178)
local sup3 = uchar(179)




/*


        ** Save to PDF file
    putpdf begin, pagesize(letter) landscape font("Calibri", 10) margin(top,1cm) margin(bottom,0.5cm) margin(left,1cm) margin(right,1cm)

    ** Figure 1 Title 
    putpdf paragraph ,  font("Calibri Light", 12)
    putpdf text ("Figure. ") , bold
    putpdf text ("Average numbers `sup1' of confirmed cases in 20 Caribbean countries `sup2' and 17 Latin American countries `sup3' up to 17 June 2020")

    putpdf table fig1 = (2,2), width(90%) halign(left)    
    putpdf table fig1(.,.), border(all, nil) valign(center)
    putpdf table fig1(1,1)=("(A) Cumulative cases (regional average)"),  halign(left) font("Calibri Light", 11, 000000)
    putpdf table fig1(1,2)=("(B) Cumulative rate per 100,000 people (regional average)"),  halign(left) font("Calibri Light", 11, 000000)
    putpdf table fig1(2,1) = image("`outputpath'/04_TechDocs/paper2_cases_$S_DATE.png")
    putpdf table fig1(2,2) = image("`outputpath'/04_TechDocs/paper2_rates_$S_DATE.png")

    putpdf table t1 = (3,1), width(80%) halign(center)    
    putpdf table t1(1,1), font("Calibri Light", 9, 808080) border(all, nil) 
    putpdf table t1(2,1), font("Calibri Light", 9, 808080) border(all, nil) 
    putpdf table t1(3,1), font("Calibri Light", 9, 808080) border(all, nil) 
    putpdf table t1(1,1)=("(1) "), bold halign(left)
    putpdf table t1(1,1)=("Dotted line is the median value on each day. Darker shading represents 40th to 60th percentiles. "), append halign(left)
    putpdf table t1(1,1)=("Lighter shading represents 25th to 75th percentile. "), append halign(left)
    putpdf table t1(1,1)=("Data Source: "), bold italic append halign(left)
    putpdf table t1(1,1)=("European Centre for Disease Control (ECDC). Daily data download on the geographic distribution of "), italic append halign(left)
    putpdf table t1(1,1)=("COVID19 cases worldwide. [Available from: https://www.ecdc.europa.eu/en/publications-data/"), italic append halign(left)
    putpdf table t1(1,1)=("download‐todays‐data‐geographic‐distribution‐covid‐19‐cases‐worldwide. "), italic append halign(left)
    putpdf table t1(2,1)=("(2) "), bold halign(left)
    putpdf table t1(2,1)=("Caribbean countries: Anguilla, Antigua and Barbuda, The Bahamas, Barbados, Belize, Bermuda, British Virgin Islands, Cayman Islands, "), append halign(left)
    putpdf table t1(2,1)=("Dominica, Grenada, Guyana, Haiti, Jamaica, Montserrat, St Kitts and Nevis, St Lucia, "), append halign(left)
    putpdf table t1(2,1)=("St Vincent and the Grenadines, Suriname, Turks and Caicos Islands, Trinidad and Tobago."), append halign(left)
    putpdf table t1(3,1)=("(3) "), bold halign(left)
    putpdf table t1(3,1)=("Latin American countries: Argentina, Bolivia, Brazil, Chile, Colombia, Costa Rica, "), append halign(left)
    putpdf table t1(3,1)=("Ecuador, El Salvador, Guatemala, Honduras, Mexico, Nicaragua, Panama, Paraguay, "), append halign(left)
    putpdf table t1(3,1)=("Peru, Uruguay, Venezuela."), append halign(left)

** Save the PDF
    local c_date = c(current_date)
    local date_string = subinstr("`c_date'", " ", "", .)
    putpdf save "X:\The University of the West Indies\DataGroup - DG_Projects\PROJECT_p151\05_Outputs_Papers\04_SIDS\Paper2_figure1_`date_string'", replace

