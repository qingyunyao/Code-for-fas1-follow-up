/*File name..: Fas1 follow up-describe table generation*/
/*Study......: Phd project study 1 the efficiency of hpv as primary test among post-menopause women (56-61)*/
/*Author.....: Qingyun Yao*/
/*Date.......: 2023/08-16*/
/*Updated....: 2023.09.14 apply the exclusion criteria and add the information of hpv type in the analysis data set
			   2023.09.30 limit the outcomes to pathological outcomes
			   2023.10.02 update the cancer outcomes
			   2023,10,20 including indicative hpv test in the all tests
			   2024.02.05 the end of follow up set to 2022.12.31*/
/*Purpose....: check the screening frequency and population characteristics among study population
				recalculate the survival time and the censor status*/
/*Note.......: */
*------------------------------------------------------------------------;
/* Data used...:V_ncsr.nkc_cell_6922 V_ncsr.nkc_hpv V_ncsr.nkc_trans_cell V_ncsr.nkc_pad_translated fas1.f1_02 fas1.f1_12
libname NCSR  odbc complete="server=meb-sql02.meb.ki.se;driver=SQL Server Native Client 11.0;Trusted_Connection=Yes;database=NCSR" schema=NCSR ;
libname V_NCSR     odbc complete="server=meb-sql02.meb.ki.se;driver=SQL Server Native Client 11.0;Trusted_Connection=Yes;database=NCSR" schema=V_NCSR ;
libname fas1 'P:\ACCES\ACCES_Research\Qingyun\Fas1_Followup\Data\0531';
/* Data created.:  */
/*sas version.: SAS9.4*/
proc datasets kill; quit;
/*main program*/
libname NCSR  odbc complete="server=meb-sql02.meb.ki.se;driver=SQL Server Native Client 11.0;Trusted_Connection=Yes;database=NCSR" schema=NCSR ;
libname V_NCSR     odbc complete="server=meb-sql02.meb.ki.se;driver=SQL Server Native Client 11.0;Trusted_Connection=Yes;database=NCSR" schema=V_NCSR ;
libname fas1 'P:\ACCES\ACCES_Research\Qingyun\Fas1_Followup\Data\0531';

libname newcoh 'P:\ACCES\ACCES_Research\Qingyun\Fas1_Followup\Data\newcohort';

/*main program*/
/*number of test*/
/*all test including hpv & cytological test*/
/*arranage all the hpv&cytological test into the same structure for merging*/
data f1_02_af_cyto;
set newcoh.f1_02_af_cyto;
if .<n_snomed_severity<=4 then n_result='NEG';
else if n_snomed_severity>4 then n_result='POS';
rename n_cyto_sample_date=n_sample_date;
where n_cyto_sample_date<='31Dec2022'd;
keep person_id sample_id HPVDIAG hpv_sample_date n_cyto_sample_date n_scr_type n_snomed_severity n_result;
run;
data f1_02_af_hpv;
set newcoh.f1_02_af_hpv;
if n_hpvdiag='POS' then n_result='POS';
else if n_hpvdiag='NEG' then n_result='NEG';
rename sample_date=n_sample_date;
where sample_date<='31Dec2022'd;
keep person_id sample_id HPVDIAG hpv_sample_date sample_date n_scr_type n_hpvdiag n_result;
run;
data f1_02_af_ind;
set newcoh.f1_02_af_ind_ndk;
if ind_hpvdiag='POS' then n_result='POS';
else if ind_hpvdiag='NEG' then n_result='NEG';
n_scr_type='3';/*scr_type=3 :indicative hpv*/
where ind_sample_date<='31Dec2022'd;
keep person_id sample_id HPVDIAG hpv_sample_date n_scr_type ind_hpvdiag ind_sample_date n_result;
run;
data f1_02_af_ind;
set f1_02_af_ind;
rename ind_sample_date=n_sample_date;
rename ind_hpvdiag=n_hpvdiag;
run;

data f1_02_af_hpv_ind;
set f1_02_af_ind f1_02_af_hpv;
run;
/*NOTE: There were 364 observations read from the data set WORK.F1_02_AF_IND.
NOTE: There were 15159 observations read from the data set WORK.F1_02_AF_HPV.
NOTE: The data set WORK.F1_02_AF_HPV_IND has 15523 observations and 8 variables.
*/

/*sorting and delete multiple test on the same sample date, all the test on thee same sample date only account for one test*/
data f1_02_af;
set f1_02_af_hpv f1_02_af_cyto f1_02_af_ind;
run;
proc sort data=f1_02_af;
by person_id n_sample_date;
run;
proc sort data=f1_02_af out=f1_02_af_nodupk nodupkey;
by person_id n_sample_date;
run;
/*NOTE: There were 19342 observations read from the data set WORK.F1_02_AF.
NOTE: 2277 observations with duplicate key values were deleted.
NOTE: The data set WORK.F1_02_AF_NODUPK has 17065 observations and 9 variables.
*/
/*count number of all test*/
data f1_02_af_all_count;
set f1_02_af_nodupk;
by person_id;
if first.person_id then nr_test_all=0;
nr_test_all+1;
run;
/*only keep the largest test number
keep the date of the test with the largest number, that's the date of end of the follow up*/
data f1_02_alltestnr;
set f1_02_af_all_count;
by person_id;
if last.person_id;
keep person_id n_sample_date nr_test_all;
run;
/*NOTE: There were 17065 observations read from the data set WORK.F1_02_AF_ALL_COUNT.
NOTE: The data set WORK.F1_02_ALLTESTNR has 7318 observations and 3 variables.
*/
/*count the number of screening test and non-screening test; scr_type=1/2*/
data f1_02_af_screen f1_02_af_non_screen;
set f1_02_af_nodupk;
if n_scr_type='1' then output f1_02_af_screen;
else if n_scr_type^='1' then output f1_02_af_non_screen;
run;
/*NOTE: There were 17065 observations read from the data set WORK.F1_02_AF_NODUPK.
NOTE: The data set WORK.F1_02_AF_SCREEN has 13924 observations and 9 variables.
NOTE: The data set WORK.F1_02_AF_NON_SCREEN has 3141 observations and 9 variables
*/
/*sort the data before count*/
proc sort data=f1_02_af_screen;
by person_id;
proc sort data=f1_02_af_non_screen;
by person_id;
run;
/*count the test number*/
data f1_02_af_screen_count;
set f1_02_af_screen;
by person_id;
if first.person_id then nr_screen_test=0;
nr_screen_test+1;
run;
data f1_02_af_non_screen_count;
set f1_02_af_non_screen;
by person_id;
if first.person_id then nr_nscreen_test=0;
nr_nscreen_test+1;
run;
/*keep the number of screen/nonscreen test*/
data f1_02_scrtestnr;
set f1_02_af_screen_count;
by person_id;
if last.person_id;
keep person_id nr_screen_test;
run;
/*NOTE: There were 13924 observations read from the data set WORK.F1_02_AF_SCREEN_COUNT.
NOTE: The data set WORK.F1_02_SCRTESTNR has 7318 observations and 2 variables.
*/
data f1_02_nscrtestnr;
set f1_02_af_non_screen_count;
by person_id;
if last.person_id;
keep person_id nr_nscreen_test;
run;
/*NOTE: There were 3141 observations read from the data set WORK.F1_02_AF_NON_SCREEN_COUNT.
NOTE: The data set WORK.F1_02_NSCRTESTNR has 1433 observations and 2 variables.
*/
/*stratified by sample type*/
/*sort before count*/
proc sort data=f1_02_af_cyto;
by person_id;
proc sort data=f1_02_af_hpv_ind;
by person_id;
run;
/*count the test number*/
data f1_02_af_cyto_count;
set f1_02_af_cyto;
by person_id;
if first.person_id then nr_cyto=0;
nr_cyto+1;
run;
data f1_02_af_hpv_count;
set f1_02_af_hpv_ind;
by person_id;
if first.person_id then nr_hpv=0;
nr_hpv+1;
run;
/*only keep person number and count*/
data f1_02_cytonr;
set f1_02_af_cyto_count;
by person_id;
if last.person_id;
keep person_id nr_cyto;
run;
data f1_02_hpvnr;
set f1_02_af_hpv_count;
by person_id;
if last.person_id;
keep person_id nr_hpv;
run;
/*f1_02_population age and fas1 age*/
data f1_02_age;
set newcoh.f1_02;
keep even person_id age hpv_sample_date;
rename hpv_sample_date=fas1_sample_date;
run;
/*sort before merge*/
proc sort data=f1_02_age;
by person_id;
proc sort data=f1_02_alltestnr;
by person_id;
proc sort data=f1_02_cytonr;
by person_id;
proc sort data=f1_02_hpvnr;
by person_id;
proc sort data=f1_02_nscrtestnr;
by person_id;
proc sort data=f1_02_scrtestnr;
by person_id;
run;
/*merge*/
data f1_02_af_count;
merge f1_02_age f1_02_alltestnr f1_02_cytonr f1_02_hpvnr f1_02_nscrtestnr f1_02_scrtestnr;
by person_id;
run;
/*NOTE: There were 7318 observations read from the data set WORK.F1_02_AGE.
NOTE: There were 7318 observations read from the data set WORK.F1_02_ALLTESTNR.
NOTE: There were 1727 observations read from the data set WORK.F1_02_CYTONR.
NOTE: There were 7318 observations read from the data set WORK.F1_02_HPVNR.
NOTE: There were 1433 observations read from the data set WORK.F1_02_NSCRTESTNR.
NOTE: There were 7318 observations read from the data set WORK.F1_02_SCRTESTNR.
NOTE: The data set WORK.F1_02_AF_COUNT has 7318 observations and 10 variables
*/

/*count the age of participant at the last test date*/
data f1_02_af_count;
set f1_02_af_count;
if nr_cyto=. then nr_cyto=0;
if nr_nscreen_test=. then nr_nscreen_test=0;
years_diff=intck('year',fas1_sample_date,n_sample_date);
age_fup=AGE+years_diff;
run;


/*fas1 cytology*/
/*number of test*/
/*all test including hpv & cytological test*/
/*arranage all the hpv&cytological test into the same structure for merging*/
data f1_12_af_cyto;
set newcoh.f1_12_af_cyto;
if .<n_snomed_severity<=4 then n_result='NEG';
else if n_snomed_severity>4 then n_result='POS';
if .<snomed_severity<=4 then cytodiag='NEG';
else if snomed_severity>4 then cytodiag='POS';
rename n_cyto_sample_date=n_sample_date;
where n_cyto_sample_date<='31Dec2022'd;
keep person_id cytodiag cyto_sample_date n_cyto_sample_date n_scr_type n_snomed_severity n_result;
run;
data f1_12_af_hpv;
set newcoh.f1_12_af_hpv;
if n_hpvdiag='POS' then n_result='POS';
else if n_hpvdiag='NEG' then n_result='NEG';
if .<snomed_severity<=4 then cytodiag='NEG';
else if snomed_severity>4 then cytodiag='POS';
rename sample_date=n_sample_date;
where sample_date<='31Dec2022'd;
keep person_id cytodiag cyto_sample_date sample_date n_scr_type n_hpvdiag n_result;
run;

data f1_12_af_ind;
set newcoh.f1_12_af_ind_ndk;
if .<snomed_severity<=4 then cytodiag='NEG';
else if snomed_severity>4 then cytodiag='POS';
if ind_hpvdiag='POS' then n_result='POS';
else if ind_hpvdiag='NEG' then n_result='NEG';
n_scr_type='3';/*scr_type=3 :indicative hpv*/
where ind_sample_date<='31Dec2022'd;
keep person_id cytodiag cyto_sample_date n_scr_type ind_hpvdiag ind_sample_date n_result;
run;
data f1_12_af_ind;
set f1_12_af_ind;
rename ind_sample_date=n_sample_date;
rename ind_hpvdiag=n_hpvdiag;
run;

data f1_12_af_hpv_ind;
set f1_12_af_ind f1_12_af_hpv;
run;
/*NOTE: NOTE: There were 243 observations read from the data set WORK.F1_12_AF_IND.
NOTE: There were 10198 observations read from the data set WORK.F1_12_AF_HPV.
NOTE: The data set WORK.F1_12_AF_HPV_IND has 10441 observations and 7 variables.
*/

/*sorting and delete multiple test on the same sample date, all the test on thee same sample date only account for one test*/
data f1_12_af;
set f1_12_af_hpv f1_12_af_cyto f1_12_af_ind;
run;
proc sort data=f1_12_af;
by person_id n_sample_date;
run;
proc sort data=f1_12_af out=f1_12_af_nodupk nodupkey;
by person_id n_sample_date;
run;
/*NOTE: There were 20568 observations read from the data set WORK.F1_12_AF.
NOTE: 1590 observations with duplicate key values were deleted.
NOTE: The data set WORK.F1_12_AF_NODUPK has 18978 observations and 8 variables
*/
/*count number of all test*/
data f1_12_af_all_count;
set f1_12_af_nodupk;
by person_id;
if first.person_id then nr_test_all=0;
nr_test_all+1;
run;
/*only keep the largest test number*/
data f1_12_alltestnr;
set f1_12_af_all_count;
by person_id;
if last.person_id;
keep person_id n_sample_date nr_test_all;
run;
/*NOTE: There were 18978 observations read from the data set WORK.F1_12_AF_ALL_COUNT.
NOTE: The data set WORK.F1_12_ALLTESTNR has 7401 observations and 3 variables.
*/
/*count the number of screening test and non-screening test; scr_type=1/2*/
data f1_12_af_screen f1_12_af_non_screen;
set f1_12_af_nodupk;
if n_scr_type='1' then output f1_12_af_screen;
else if n_scr_type^='1' then output f1_12_af_non_screen;
run;
/*NOTE: There were 18978 observations read from the data set WORK.F1_12_AF_NODUPK.
NOTE: The data set WORK.F1_12_AF_SCREEN has 16908 observations and 8 variables.
NOTE: The data set WORK.F1_12_AF_NON_SCREEN has 2070 observations and 8 variables.
*/
/*sort the data before count*/
proc sort data=f1_12_af_screen;
by person_id;
proc sort data=f1_12_af_non_screen;
by person_id;
run;
/*count the test number*/
data f1_12_af_screen_count;
set f1_12_af_screen;
by person_id;
if first.person_id then nr_screen_test=0;
nr_screen_test+1;
run;
data f1_12_af_non_screen_count;
set f1_12_af_non_screen;
by person_id;
if first.person_id then nr_nscreen_test=0;
nr_nscreen_test+1;
run;
/*keep the number of screen/nonscreen test*/
data f1_12_scrtestnr;
set f1_12_af_screen_count;
by person_id;
if last.person_id;
keep person_id nr_screen_test;
run;
/*NOTE: There were 16908 observations read from the data set WORK.F1_12_AF_SCREEN_COUNT.
NOTE: The data set WORK.F1_12_SCRTESTNR has 7401 observations and 2 variables.
*/
data f1_12_nscrtestnr;
set f1_12_af_non_screen_count;
by person_id;
if last.person_id;
keep person_id nr_nscreen_test;
run;
/*NOTE: There were 2070 observations read from the data set WORK.F1_12_AF_NON_SCREEN_COUNT.
NOTE: The data set WORK.F1_12_NSCRTESTNR has 1187 observations and 2 variables.
*/
/*stratified by sample type*/
/*sort before count*/
proc sort data=f1_12_af_cyto;
by person_id;
proc sort data=f1_12_af_hpv_ind;
by person_id;
run;
/*count the test number*/
data f1_12_af_cyto_count;
set f1_12_af_cyto;
by person_id;
if first.person_id then nr_cyto=0;
nr_cyto+1;
run;
data f1_12_af_hpv_count;
set f1_12_af_hpv_ind;
by person_id;
if first.person_id then nr_hpv=0;
nr_hpv+1;
run;
/*only keep person number and count*/
data f1_12_cytonr;
set f1_12_af_cyto_count;
by person_id;
if last.person_id;
keep person_id nr_cyto;
run;
data f1_12_hpvnr;
set f1_12_af_hpv_count;
by person_id;
if last.person_id;
keep person_id nr_hpv;
run;
/*f1_12_population age and fas1 age*/
data f1_12_age;
set newcoh.f1_12_outcomes;
keep even person_id age fas1_sample_date;
run;
/*sort before merge*/
proc sort data=f1_12_age;
by person_id;
proc sort data=f1_12_alltestnr;
by person_id;
proc sort data=f1_12_cytonr;
by person_id;
proc sort data=f1_12_hpvnr;
by person_id;
proc sort data=f1_12_nscrtestnr;
by person_id;
proc sort data=f1_12_scrtestnr;
by person_id;
run;
/*merge*/
data f1_12_af_count;
merge f1_12_age f1_12_alltestnr f1_12_cytonr f1_12_hpvnr f1_12_nscrtestnr f1_12_scrtestnr;
by person_id;
run;
/*NOTE: There were 7401 observations read from the data set WORK.F1_12_AGE.
NOTE: There were 7401 observations read from the data set WORK.F1_12_ALLTESTNR.
NOTE: There were 7401 observations read from the data set WORK.F1_12_CYTONR.
NOTE: There were 6540 observations read from the data set WORK.F1_12_HPVNR.
NOTE: There were 1187 observations read from the data set WORK.F1_12_NSCRTESTNR.
NOTE: There were 7401 observations read from the data set WORK.F1_12_SCRTESTNR.
*/
data f1_12_af_count;
set f1_12_af_count;
if nr_hpv=. then nr_hpv=0;
if nr_nscreen_test=. then nr_nscreen_test=0;
years_diff=intck('year',fas1_sample_date,n_sample_date);
age_fup=AGE+years_diff;
run;

/*fas1 population screening numbers*/
data f1_af_count;
set f1_02_af_count f1_12_af_count;
run;
data newcoh.f1_af_count;
set f1_af_count;
run;


/*screening history all pre_HSIL pre_LSIL pre_abn*/
data f1_pre;
set newcoh.f1_02_pre newcoh.f1_12_pre;
run;

data scr_his;
set f1_pre;
keep even person_id n_hpvdiag n_hpv_sample_date n_cyto_sample_date n_snomed_severity pad_sev pad_sample_date;
run;
/*cyto: snomed_severity>4 abnormal   snomed_severity>=7 LSIL  snomed_severity>=11 HSIL
PAD_sev>=5 CIN2+ pad_sev=4 LSIL
0-negative;1-positive*/
data scr_his;
set scr_his;
if .<n_snomed_severity<=4 then pre_cyto=0;
else if n_snomed_severity>4 then pre_cyto=1;
if .<n_snomed_severity<7 then pre_cyto_LSIL=0;
else if n_snomed_severity>=7 then pre_cyto_LSIL=1;
if .<n_snomed_severity<11 then pre_cyto_HSIL=0;
else if n_snomed_severity>=11 then pre_cyto_HSIL=1;
if n_hpvdiag='POS' then pre_hpv=1;
else if n_hpvdiag='NEG' then pre_hpv=0;
if pad_sev<4 then pre_pad_LSIL=0;
else if pad_sev>=4 then pre_pad_LSIL=1;
if pad_sev<5 then pre_pad_HSIL=0;
else if pad_sev>=5 then pre_pad_HSIL=1;
run;
data scr_his;
set scr_his;
if pre_pad_HSIL=1 or pre_cyto_HSIL=1 then pre_HSIL=1;
else pre_HSIL=0;
if pre_pad_LSIL=1 or pre_cyto_LSIL=1 then pre_LSIL=1;
else pre_LSIL=0;
if pre_cyto=1 or pre_hpv=1 or pad_sev>=4 then pre_abn=1;
else pre_abn=0;
run;


data newcoh.scr_his;
set scr_his;
run;

/*merge a dataset for analysis
1.fas1 results (f1_02 f1_12)
2.history (scr_his)
3.outcomes (outcomes)
4.dereg (f1)
5.number of test counts (f1_af_count)
*/
data f1_02_fas1;
set newcoh.f1_02_type_1618;
keep person_id even scr_type hpvdiag hpv_severity hpv1618;
run;
data f1_12_fas1;
set newcoh.f1_12;
if snomed_severity<5 then cytdiag='NEG';
else if snomed_severity>=5 then cytdiag='POS';
keep person_id even scr_type snomed_severity cytdiag;
run;
data fas1;
set f1_02_fas1 f1_12_fas1;
run;

data outcomes;*limited to pad outcomes;
set newcoh.outcomes;
keep person_id p_LSIL p_LSIL_date p_LSIL_sev p_HSIL p_HSIL_date p_HSIL_sev;
run;

data dereg_02;
set newcoh.f1_02_pre_d;
keep person_id pre_test dereg dereg_date dereg_rea;
data dereg_12;
set newcoh.f1_12_pre_d;
keep person_id pre_test dereg dereg_date dereg_rea;
data dereg;
set dereg_02 dereg_12;
run;

/*id:aaaaaaa bbbbbbb ccccccc ddddddd eeeeeee fffffff ggggggg hhhhhhh
deregister date is invalid for sas because it missing the day*/
data dereg;
set dereg;
if person_id=aaaaaaa then dereg_date=MDY(2,15,2022);
if person_id=bbbbbbb then dereg_date=MDY(9,15,2022);
if person_id=ccccccc then dereg_date=MDY(6,15,2022);
if person_id=ddddddd then dereg_date=MDY(3,15,2017);
if person_id=eeeeeee then dereg_date=MDY(6,15,2017);
if person_id=fffffff then dereg_date=MDY(7,15,2015);
if person_id=ggggggg then dereg_date=MDY(7,15,2018);
if person_id=hhhhhhh then dereg_date=MDY(3,15,2017);
run;

proc sort data=dereg;
by person_id;
proc sort data=Fas1;
by person_id;
proc sort data=outcomes;
by person_id;
proc sort data=newcoh.F1_af_count;
by person_id;
proc sort data=newcoh.scr_his;
by person_id;
run;

data analysis;
merge Fas1 newcoh.scr_his newcoh.f1_af_count dereg outcomes;
by person_id;
run;

/*1.exclude hpv=EB
2.exclude dereg before fas1*/
data analysis;
set analysis;
if dereg^=0 and dereg_date<fas1_sample_date then delete;
run;
/*NOTE: There were 14719 observations read from the data set WORK.ANALYSIS.
NOTE: The data set WORK.ANALYSIS has 14716 observations and 43 variables.
*/

data analysis;
set analysis;
if hpvdiag='EB' then delete;
run;
/*NOTE: There were 14716 observations read from the data set WORK.ANALYSIS.
NOTE: The data set WORK.ANALYSIS has 14713 observations and 43 variables.
*/


/*fas1_sample_date is the date for the baseline test
n_sample_date is the date for the end of the follow up (last screening test date)

survival time calculation:
if outcome of interest appears than the end of the follow up is the day of diagnosis
if the outcome dosen't appear then the eof will be the n_sample_date or the deregistered date whichever comes first
*/
data analysis_eof;
set analysis;
if p_LSIL=1 then eof_LSIL_date=p_LSIL_date;
if p_LSIL=0 then do;
if .<dereg_date<n_sample_date then eof_LSIL_date=dereg_date;
else eof_LSIL_date=n_sample_date;
end;
if p_HSIL=1 then eof_HSIL_date=p_HSIL_date;
if p_HSIL=0 then do;
if .<dereg_date<n_sample_date then eof_HSIL_date=dereg_date;
else eof_HSIL_date=n_sample_date;
end;
format eof_LSIL_date yymmdd10. eof_HSIL_date yymmdd10.;
run;


/*calculate survival time*/
data analysis_sur;
set analysis_eof;
LSIL_sur_time=(eof_LSIL_date-fas1_sample_date)/365.25;
HSIL_sur_time=(eof_HSIL_date-fas1_sample_date)/365.25;
run;


/*2023.10.02
update cancer case*/
/*2024.02.05 update cancer case to 2022.12.31*/
data cancer_update;
set fas1.cxca_2022_gcr_jw20240201;
run;

data cancer;
set fas1.fas1_pop_withcxca_jw20230929;
run;

proc sort data=cancer_update;by person_id;
proc sort data=cancer; by person_id;
run;

data cancer_merge;
merge cancer(in=a) cancer_update;
by person_id;
if a;
run;


proc sort data=cancer_merge nodupkey out=cancer_merge_ndk;
by person_id;
run;

 proc sort data=analysis_sur;
 by person_id;
 run;

data analysis_0205;
merge analysis_sur(in=a) cancer_merge_ndk(in=b);
by person_id;
if a;
run;


data analysis_0205;
set analysis_0205;
if figo_stage='' then cancer=0;
if figo_stage^='' then cancer=1;
if birth_year IN (1951 1952 1953 1954) then birth_cohort=1;
else if birth_year IN (1955 1956 1957 1958) then birth_cohort=2;
run;

/*end of cancer follow up is 2021-12-31*/
data analysis_0205;
set analysis_0205;
if cancer=1 then eof_cancer=cxca_date;
if cancer=0 then eof_cancer=MDY(12,31,2022);
format eof_cancer yymmdd10.;
can_sur_time=(eof_cancer-fas1_sample_date)/365.25;
run;

data analysis_0205;
set analysis_0205;
if cancer=0 and dereg_rea IN ('AV' 'UV' 'Hysterektomi')then do;
if .<dereg_date<eof_cancer then eof_cancer=dereg_date;
end;
can_sur_time=(eof_cancer-fas1_sample_date)/365.25;
run;

proc freq data=analysis_0205;
tables cancer;
run;

data analysis_0205;
set analysis_0205;
if hpvdiag='POS' then do;
group='HPV_P';group_n=1;
end;
if hpvdiag='NEG' then do;
group='HPV_N';group_n=2;
end;
if cytdiag='POS' then do;
group="CYT_P";group_n=3;
end;
if cytdiag='NEG' then do;
group='CYT_N';group_n=4;
end;
run;

data analysis_0205;
set analysis_0205;
if group='HPV_N' then do;
negative='HPV';negative_n=0;
end;
if group='CYT_N' then do;
negative='CYT';negative_n=1;
end;
run;

data newcoh.analysis_0205;
set analysis_0205;
run;

/*
person_id=xxxxxxx hsil lsil survival time need to be correct, missing pathological result but is a cancer case
cancer date=2015.10.21*/

data analysis;
set newcoh.analysis_0205;
run;
data analysis;
set analysis;
if person_id=xxxxxxx then do;
p_LSIL=1;
p_LSIL_date=MDY(10,21,2015);
eof_LSIL_date=MDY(10,21,2015);
LSIL_sur_time=(eof_LSIL_date-fas1_sample_date)/365.25;
p_HSIL=1;
p_HSIL_date=MDY(10,21,2015);
eof_HSIL_date=MDY(10,21,2015);
HSIL_sur_time=(eof_HSIL_date-fas1_sample_date)/365.25;
end;
format p_HSIL_date yymmdd10. p_LSIL_date yymmdd10.;
run;
data newcoh.analysis_0205;
set analysis;
run;

