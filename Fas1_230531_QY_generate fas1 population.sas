/*File name..: Fas1 follow up population */
/*Study......: Phd project study 1 the efficiency of hpv as primary test among post-menopause women (56-61)*/
/*Author.....: Qingyun Yao*/
/*Date.......: 2023/05/31*/
/*Updated....: 20230621 added some comments on the code to make it easier to read and to track*/
/*Purpose....: to find the original participated population in fas1*/
/*Note.......: change date format to yymmdd10.
			   and limit the time for pathological test to the same year
*/
*------------------------------------------------------------------------;
/* Data used...:V_ncsr.nkc_cell_6922 V_ncsr.nkc_hpv V_ncsr.nkc_trans_cell V_ncsr.nkc_pad_translated fas1.fas1_pop_withdup_jw20230524
libname NCSR  odbc complete="server=meb-sql02.meb.ki.se;driver=SQL Server Native Client 11.0;Trusted_Connection=Yes;database=NCSR" schema=NCSR ;
libname V_NCSR     odbc complete="server=meb-sql02.meb.ki.se;driver=SQL Server Native Client 11.0;Trusted_Connection=Yes;database=NCSR" schema=V_NCSR ;
libname fas1 'P:\ACCES\ACCES_Research\Qingyun\Fas1_Followup\Data\0531';
/* Data created.:  */
/*sas version.: SAS9.4*/
/*main program*/
libname NCSR  odbc complete="server=meb-sql02.meb.ki.se;driver=SQL Server Native Client 11.0;Trusted_Connection=Yes;database=NCSR" schema=NCSR ;
libname V_NCSR     odbc complete="server=meb-sql02.meb.ki.se;driver=SQL Server Native Client 11.0;Trusted_Connection=Yes;database=NCSR" schema=V_NCSR ;
libname fas1 'P:\ACCES\ACCES_Research\Qingyun\Fas1_Followup\Data\0531';/*create a lib to store all the newly created datasets*/
/*F1 1 och 2*/
/*make a copy of the original dataset to avoid unnecessary changes in the original dataset*/
data F1_pop;
set fas1.Fas1_pop_withdup_jw20230524;
run;
/*choose women whoes personal number ends with an even number in the whole population
according to the fas1 design, these women were assigned to the primary HPV group*/
data fas1.F1_01;
set f1_pop;
where even=1;
run;
/*based on fas1 design the screening period is from 01jan2012 to 31may2014 
find all the hpv test within this time period
and change the format of the date into yymmdd10. for easy calculation afterwards*/
data hpv1214;
set v_ncsr.nkc_hpv;
where x_sample_yr IN (2012 2013 2014);
hpv_sample_date=datepart(x_sample_date);
format hpv_sample_date yymmdd10.;
if '01Jan2012'd<=hpv_sample_date<='31may2014'd;
run;
/*this study focus on the program screening test
in 2012 scr_type can be used to differentiate the program screening and other test
started in 2013 all the program screening test in stockholm will have a referral type of 'Y' or 'YS'*/
data hpv12 hpv1314;
set hpv1214;
if x_sample_yr=2012 and scr_type='1' then output hpv12;
if x_sample_yr IN (2013 2014) and scr_type='1' and referral_type IN ('Y' 'YS') then output hpv1314;
run;
/*put the datasets i generated above together and only keep the variables i want*/
data hpv_1214_scr(keep=person_id age county_id x_sample_yr hpv_sample_date sample_id referral_type scr_type hpvdiag);
set hpv12 hpv1314;
run;
/*find all the population who has hpv primary test by merging f1_01 and the hpvscr test dataset, by person_id, and therefore have to sort both datasets
because for some participants they would have multiple hpv results in the same sample_date, and we only want to keep the most severe results, therefor use the nodupkey here to delete the multiple results*/
proc sort data=fas1.f1_01;
by person_id x_sample_yr;
run;
proc sort data=hpv_1214_scr;
by person_id hpv_sample_date descending hpvdiag;
run;
/*keep track of women with multiple test paste the results merge*/
proc sort data=hpv_1214_scr nodupkey out=hpv_1214_scr_ndk;
by person_id hpv_sample_date;
run;
/*NOTE: There were 19287 observations read from the data set WORK.HPV_1214_SCR.
NOTE: 1161 observations with duplicate key values were deleted.
NOTE: The data set WORK.HPV_1214_SCR_NDK has 18126 observations and 9 variables.
NOTE: PROCEDURE SORT used (Total process time):
      real time           0.06 seconds
      cpu time            0.04 seconds

*/
/*generate f1_02 by merging f1_01 and the hpv_1214_scr_ndk*/
data fas1.F1_02;
merge fas1.f1_01(in=a) hpv_1214_scr_ndk(in=b);
by person_id x_sample_yr;
if a and b;
run;
proc freq data=fas1.f1_02;
tables x_sample_yr;
run;
/*7331 obs in f1_02
x_sample_yr Frequency Percent Cumulative
Frequency Cumulative
Percent 
2012 2867 39.11 2867 39.11 
2013 2839 38.73 5706 77.83 
2014 1625 22.17 7331 100.00 
*/
data multi_hpv;
set fas1.f1_02;
by person_id;
if first.person_id and last.person_id then delete;
if first.person_id then nr_hpv_test=0;
nr_hpv_test+1;
run;
/*there are 13 participants who have multiple hpv primary test in 2012 to 2014
according to pouran's code, the multiple tests in different years were not deleted, to match the population in the original files we will keep these tests here
!!!but I think we should delete the multiple test when we do the calculation */
/*generate f1_03 by choosing those with positive hpv results*/
data fas1.f1_03;
set fas1.f1_02;
where hpvdiag='POS';
run;
proc freq data=fas1.f1_03;
tables x_sample_yr;
run;
/*X_SAMPLE_YR 
x_sample_yr Frequency Percent Cumulative
Frequency Cumulative
Percent 
2012 156 38.52 156 38.52 
2013 174 42.96 330 81.48 
2014 75 18.52 405 100.00 
*/
/*generate f1_07 by choosing those with negative hpv results*/
data fas1.f1_07;
set fas1.f1_02;
where hpvdiag='NEG';
run;
proc freq data=fas1.f1_07;
tables x_sample_yr;
run;
/*X_SAMPLE_YR 
x_sample_yr Frequency Percent Cumulative
Frequency Cumulative
Percent 
2012 2710 39.14 2710 39.14 
2013 2664 38.48 5374 77.63 
2014 1549 22.37 6923 100.00 
*/
/*find all the participants who have a cytology test within 30 days after they have the primary hpv test*/
/*find all the cytology test within 2012-2014*/
data cyto12_14 (keep=person_id referral_type county_id x_sample_yr x_sample_date sample_id);
set v_ncsr.nkc_cell_6922;
where x_sample_yr IN (2012 2013 2014);
run;
/*find the results of all the cytology test within 2012-2014*/
data cyto1214_trans (keep=person_id county_id x_sample_yr x_sample_date sample_id snomed_worst snomed_severity scr_type);
set v_ncsr.nkc_trans_cell;
where x_sample_yr IN (2012 2013 2014);
run;
/*merge the test and the results, sort first and only keep one test/person/day use nodupkep*/
proc sort data=cyto12_14;
by person_id x_sample_date;
run;
proc sort data=cyto12_14 nodupkey;
by person_id x_sample_date;
run;
/*NOTE: There were 3455925 observations read from the data set WORK.CYTO12_14.
NOTE: 1394753 observations with duplicate key values were deleted.
NOTE: The data set WORK.CYTO12_14 has 2061172 observations and 6 variables.
*/
/*and only keep the most severe results*/
proc sort data=cyto1214_trans;
by person_id x_sample_date descending snomed_severity;
run;
proc sort data=cyto1214_trans nodupkey out=cyto1214_trans_ndk;
by person_id x_sample_date;
run;
/*
NOTE: There were 2063612 observations read from the data set WORK.CYTO1214_TRANS.
NOTE: 2484 observations with duplicate key values were deleted.
NOTE: The data set WORK.CYTO1214_TRANS_NDK has 2061128 observations and 8 variables.
*/
/*merge to create a table with cyto test and the translated results*/
data cyto_1214;
merge cyto12_14(in=a) cyto1214_trans_ndk(in=b);
by person_id x_sample_date;
if a and b;
run;
/*change the date format for easy calculation*/
data cyto_1214(drop=x_sample_date sample_id);
set cyto_1214;
cyto_sample_date=datepart(x_sample_date);
cyto_sample_id=sample_id;
format cyto_sample_date yymmdd10.;
run;
/*merge to find all the participants with a cytological test within 30 days of their hpv tests*/
data hpv_cyto;
merge fas1.f1_02(in=a) cyto_1214(in=b);
by person_id;
if a and b;
if 0<=cyto_sample_date-hpv_sample_date<=30;
run;
/*comment on every single step; easier to check*/
/*find women with cytology test within 30 days after a hpv positive test*/
data f1_04;
merge fas1.f1_03(in=a) cyto_1214(in=b);
by person_id;
if a and b;
if 0<=cyto_sample_date-hpv_sample_date<=30;
run;
/*NOTE: MERGE statement has more than one data set with repeats of BY values.
NOTE: There were 405 observations read from the data set FAS1.F1_03.
NOTE: There were 2061122 observations read from the data set WORK.CYTO_1214.
NOTE: The data set WORK.F1_04 has 406 observations and 16 variables.
*/
/*there is 406 obs in f1_04 which is different from f1_03, need to find the one with multipel resutls*/
data multi_04;
set f1_04; 
by person_id;
if first.person_id and last.person_id then delete;
run;
/* One women took two cytological tests after a hpv test and the second test's scr_type is 2 person_id:aaaaaaa  )
One of the positive woman did two seperate test in 2012 and in 2013 person_id */
data fas1.f1_04;
set f1_04;
if person_id=aaaaaaa and scr_type='2' then delete;
run;
/*the critieria of abnormal in cytology test is the snomed_severity>=5
find participants with positive hpv test and a positive cytology test*/
data fas1.f1_05;
set fas1.f1_04;
if snomed_severity>=5;
run;
proc freq data=fas1.f1_05;
tables x_sample_yr;
run;
/*X_SAMPLE_YR 
x_sample_yr Frequency Percent Cumulative
Frequency Cumulative
Percent 
2012 22 28.21 22 28.21 
2013 39 50.00 61 78.21 
2014 17 21.79 78 100.00 
*/
/*participants with negative hpv test and a cytological test within 30 days of the hpv test*/
data fas1.f1_08;
set hpv_cyto;
if hpvdiag='NEG';
run;
proc freq data=fas1.f1_08;
tables x_sample_yr;
run;
/*X_SAMPLE_YR 
x_sample_yr Frequency Percent Cumulative
Frequency Cumulative
Percent 
2012 4 80.00 4 80.00 
2014 1 20.00 5 100.00 
*/
/*participants with negative hpv test and a positive cytological test within 30 days of the hpv test*/
data fas1.f1_09;
set fas1.f1_08;
if snomed_severity>=5;
run;
proc freq data=fas1.f1_09;
tables x_sample_yr;
run;
/*NOTE: No observations in data set FAS1.F1_09.
*/

data pad_1214;
set v_ncsr.nkc_pad_translated;
where TOPO3='T83' and x_sample_yr IN (2012 2013 2014) and translated=1;
run;
/*leave the most severe result of the pad test*/
proc sort data=pad_1214;
by person_id x_sample_date descending pad_sev;
run;
proc sort data=pad_1214 nodupkey out=pad_1214_ndp;
by person_id x_sample_date;
run;
/*
NOTE: There were 170478 observations read from the data set WORK.PAD_1214.
NOTE: 993 observations with duplicate key values were deleted.
NOTE: The data set WORK.PAD_1214_NDP has 169485 observations and 21 variables.
*/
data pad_1214_ndp (keep=person_id pad_sev topo3 pad_class age pad_sample_date pad_sample_yr pad_sample_id snomed_translated x_sample_yr);
set pad_1214_ndp;
pad_sample_date=datepart(x_sample_date);
pad_sample_yr=x_sample_yr;
pad_sample_id=sample_id;
format pad_sample_date yymmdd10.;
run;
/*merge f1_03 with pad, find the population with positive hpv results and a pathological test afterwards*/
proc sort data=fas1.f1_03;
by person_id x_sample_yr;
run;
proc sort data=pad_1214_ndp;
by person_id x_sample_yr;
run;
data f1_06_multi_re;
merge fas1.f1_03(in=a) pad_1214_ndp(in=b);
if a and b;
by person_id x_sample_yr;
if pad_sample_date>hpv_sample_date;
run;
/*NOTE: There were 405 observations read from the data set FAS1.F1_03.
NOTE: There were 169485 observations read from the data set WORK.PAD_1214_NDP.
NOTE: The data set WORK.F1_06_MULTI_RE has 95 observations and 19 variables.
*/
/*some participants may have multiple pad test after the positive hpv test and keep the one with most severe result*/
proc sort data=f1_06_multi_re;
by person_id hpv_sample_date descending pad_sev;
run;
proc sort data=f1_06_multi_re nodupkey out=fas1.f1_06;
by person_id;
run;
/*NOTE: There were 95 observations read from the data set WORK.F1_06_MULTI_RE.
NOTE: 35 observations with duplicate key values were deleted.
NOTE: The data set FAS1.F1_06 has 60 observations and 19 variables.
*/
proc freq data=fas1.f1_06;
tables x_sample_yr;
run;
/*X_SAMPLE_YR 
x_sample_yr Frequency Percent Cumulative
Frequency Cumulative
Percent 
2012 12 20.00 12 20.00 
2013 31 51.67 43 71.67 
2014 17 28.33 60 100.00 
*/
/*participation with negatice hpv test and a pad*/
data f1_10_multi_re;
merge fas1.f1_07(in=a) pad_1214_ndp(in=b);
if a and b;
by person_id x_sample_yr;
if pad_sample_date>hpv_sample_date;
run;
proc freq data=f1_10_multi_re;
tables x_sample_yr;
run;
/*X_SAMPLE_YR 
x_sample_yr Frequency Percent Cumulative
Frequency Cumulative
Percent 
2012 7 23.33 7 23.33 
2013 13 43.33 20 66.67 
2014 10 33.33 30 100.00 
*/
/*some participants may have multiple pad tests and only keep the one with most severe result*/
proc sort data=f1_10_multi_re nodupkey out=fas1.f1_10;
by person_id;
run;
/*NOTE: There were 30 observations read from the data set WORK.F1_10_MULTI_RE.
NOTE: 3 observations with duplicate key values were deleted.
NOTE: The data set FAS1.F1_10 has 27 observations and 19 variables.
*/
proc freq data=fas1.f1_10;
tables x_sample_yr;
run;
/*X_SAMPLE_YR 
x_sample_yr Frequency Percent Cumulative
Frequency Cumulative
Percent 
2012 7 25.93 7 25.93 
2013 12 44.44 19 70.37 
2014 8 29.63 27 100.00 
*/

/*try to find the population in the flow chart 
doi:10.1136/bmjopen-2016-014788*/

/*participaints hpv positive-cytology positive-pad*/
proc sort data=fas1.f1_05;
by person_id x_sample_yr;
run;
data hpv_p_cy_p_pad_multi_re;
merge fas1.f1_05(in=a) pad_1214_ndp(in=b);
if a and b;
by person_id x_sample_yr;
if pad_sample_date>hpv_sample_date;
run;
/*NOTE: There were 78 observations read from the data set FAS1.F1_05.
NOTE: There were 169485 observations read from the data set WORK.PAD_1214_NDP.
NOTE: The data set WORK.HPV_P_CY_P_PAD_MULTI_RE has 92 observations and 23 variables.
leave the pad test with the most severe results*/
proc sort data=hpv_p_cy_p_pad_multi_re;
by person_id hpv_sample_date descending pad_sev;
run;
proc sort data=hpv_p_cy_p_pad_multi_re nodupkey out=fas1.hpv_p_cy_p_pad;
by person_id;
run;
/*
NOTE: There were 92 observations read from the data set WORK.HPV_P_CY_P_PAD_MULTI_RE.
NOTE: 34 observations with duplicate key values were deleted.
NOTE: The data set FAS1.HPV_P_CY_P_PAD has 58 observations and 23 variables.
*/
proc freq data=fas1.hpv_p_cy_p_pad;
tables pad_class;
run;
/*PAD_CLASS	Frequency
CIN1	16
CIN2	7
CIN3	14
Cancer	1
Normal	14
Not diagnostic	2
Other	4
*/
/*hpv positive cytology negative and pad*/
data hpv_p_cy_n_pad_multi_re;
merge fas1.f1_04(in=a) pad_1214_ndp(in=b);
if snomed_severity<5;
if a and b;
by person_id x_sample_yr;
if pad_sample_date>hpv_sample_date;
run;
proc sort data=hpv_p_cy_n_pad_multi_re;
by person_id hpv_sample_date descending pad_sev;
run;
proc sort data=hpv_p_cy_n_pad_multi_re nodupkey out=fas1.hpv_p_cy_n_pad;
by person_id;
run;
/*NOTE: There were 3 observations read from the data set WORK.HPV_P_CY_N_PAD_MULTI_RE.
NOTE: 1 observations with duplicate key values were deleted.
NOTE: The data set FAS1.HPV_P_CY_N_PAD has 2 observations and 23 variables.
*/
proc freq data=fas1.hpv_p_cy_n_pad;
tables pad_class;
run;
/*PAD_CLASS	Frequency
Normal	2
*/


/*population with cytology as primary test
the personl number end with an odd number*/
data fas1.F1_11;
set f1_pop;
where even=0;
run;
/*cytological test within the specified time interval 01jan2021-31may2014*/
data cyto_12_scr cyto_1314_scr;
set cyto_1214;
where '01jan2012'd<=cyto_sample_date<='31may2014'd;
if x_sample_yr=2012 and scr_type='1' then output cyto_12_scr;
if x_sample_yr IN (2013 2014) and scr_type='1' and referral_type IN ('Y' 'YS') then output cyto_1314_scr;
run;
data cyto_1214_scr;
set cyto_12_scr cyto_1314_scr;
run;
/*merge f1_11 with cytological test find the participants with cytological primary test in 2012-2014;sort first*/
proc sort data=fas1.f1_11;
by person_id x_sample_yr;
proc sort data=cyto_1214_scr;
by person_id x_sample_yr;
run;
data fas1.f1_12;
merge fas1.f1_11(in=a) cyto_1214_scr(in=b);
by person_id x_sample_yr;
if a and b;
run;
/*
NOTE: There were 104438 observations read from the data set FAS1.F1_11.
NOTE: There were 574245 observations read from the data set WORK.CYTO_1214_SCR.
NOTE: The data set FAS1.F1_12 has 7476 observations and 12 variables.
*/
proc sort data=fas1.f1_12;
by person_id cyto_sample_date descending snomed_severity;
run;
/*only keep the most severe results /person/sampledate*/
proc sort data=fas1.f1_12 nodupkey;
by person_id x_sample_yr;
run;
data multi_cyto;
set fas1.f1_12;
by person_id;
if first.person_id and last.person_id then delete;
run;
/*according to pouran's code tests were taken in different year were not deleted but I think we should delete them
but some people's second test result is more severe than the first one */
proc freq data=fas1.f1_12;
tables x_sample_yr;
run;
/*X_SAMPLE_YR 
x_sample_yr Frequency Percent Cumulative
Frequency Cumulative
Percent 
2012 2817 37.80 2817 37.80 
2013 2941 39.47 5758 77.27 
2014 1694 22.73 7452 100.00 
*/

data fas1.f1_13;
set fas1.f1_12;
where snomed_severity>=5;/*abnormal threshold set it to be 5*/
run;
proc freq data=fas1.f1_13;
tables x_sample_yr;
run;
/*X_SAMPLE_YR 
x_sample_yr Frequency Percent Cumulative
Frequency Cumulative
Percent 
2012 56 36.84 56 36.84 
2013 56 36.84 112 73.68 
2014 40 26.32 152 100.00 
*/

data fas1.f1_17;
set fas1.f1_12;
where snomed_severity<5;/*abnormal threshold set it to be 5*/
run;
proc freq data=fas1.f1_17;
tables x_sample_yr;
run;
/*X_SAMPLE_YR 
x_sample_yr Frequency Percent Cumulative
Frequency Cumulative
Percent 
2012 2761 37.82 2761 37.82 
2013 2885 39.52 5646 77.34 
2014 1654 22.66 7300 100.00 
*/

/*participants with primary cytology test and a hpv triage within 30 days */
data hpv1214_triage;
set v_ncsr.nkc_hpv;
where x_sample_yr IN (2012 2013 2014);
hpv_sample_date=datepart(x_sample_date);
format hpv_sample_date yymmdd10.;
hpv_sample_id=sample_id;
run;
/*keep the most severe results /person/sample_date*/
proc sort data=hpv1214_triage;
by person_id hpv_sample_date descending hpvdiag;
run;
proc sort data=hpv1214_triage nodupkey;
by person_id hpv_sample_date;
run;
/*NOTE: There were 146832 observations read from the data set WORK.HPV1214_TRIAGE.
NOTE: 29292 observations with duplicate key values were deleted.
NOTE: The data set WORK.HPV1214_TRIAGE has 117540 observations and 35 variables.
*/
data cyto_hpv;
merge fas1.f1_12(in=a) hpv1214_triage(in=b);
if a and b;
if 0<=hpv_sample_date-cyto_sample_date<=30;
by person_id;
run;
proc freq data=cyto_hpv;
tables x_sample_yr;
run;
/*X_SAMPLE_YR 
x_sample_yr Frequency Percent Cumulative
Frequency Cumulative
Percent 
2012 47 35.61 47 35.61 
2013 48 36.36 95 71.97 
2014 37 28.03 132 100.00 
*/
data fas1.f1_14;
merge fas1.f1_13(in=a) hpv1214_triage(in=b);
if a and b;
if 0<=hpv_sample_date-cyto_sample_date<=30;
by person_id;
run;
proc freq data=fas1.f1_14;
tables x_sample_yr;
run;
/*X_SAMPLE_YR 
x_sample_yr Frequency Percent Cumulative
Frequency Cumulative
Percent 
2012 47 35.34 47 35.34 
2013 48 36.09 95 71.43 
2014 38 28.57 133 100.00 
*/

data fas1.f1_14_2;
set cyto_hpv;
if snomed_severity>=5;
run;
data difference;
merge fas1.f1_14(in=a) fas1.f1_14_2(in=b);
by person_id;
if a and ^b;
run;
/*couldn't figure out why the 1802366 was in both f1_12 and hpv1214_triage and it fit the requirements
??????one women has two cytological screening test and the fisrt one didn't fit the requirements and sas skip the second test
the merge cannot do multiple to multiple! I didn't consider this in former analysis!!!!
this won't be alarmed!!!!!!!!!!!!!!!!! Be careful!!!!!
will keep the first f1_14 dataset*/

proc sql;
create table cyto_hpv as select * from fas1.f1_12 a, hpv1214_triage b where a.person_id=b.person_id and 0<=hpv_sample_date-cyto_sample_date<=30;
quit;
/*use sql can avoid this problem!*/

/*cyto-negative-hpv test within 30 days*/
data fas1.f1_18;
set cyto_hpv;
if snomed_severity<5;
run;
/*NOTE: There were 133 observations read from the data set WORK.CYTO_HPV.
NOTE: The data set FAS1.F1_18 has 0 observations and 42 variables.
*/
/*cytology-positive-hpv-positive*/
data fas1.f1_15;
set fas1.f1_14;
if hpvdiag='POS';
run;
proc freq data=fas1.f1_15;
tables x_sample_yr;
run;
/*X_SAMPLE_YR 
x_sample_yr Frequency Percent Cumulative
Frequency Cumulative
Percent 
2012 13 30.23 13 30.23 
2013 11 25.58 24 55.81 
2014 19 44.19 43 100.00 
*/
/*cytology-negative-hpv-positive*/
data fas1.f1_19;
set fas1.f1_18;
if hpvdiag='POS';
run;
/*NOTE: There were 0 observations read from the data set FAS1.F1_18.
NOTE: The data set FAS1.F1_19 has 0 observations and 42 variables.
*/

/*cyto_pad*/
data fas1.f1_16;
merge fas1.f1_13(in=a) pad_1214_ndp(in=b);
if a and b;
by person_id x_sample_yr;
if pad_sample_date>=cyto_sample_date;
run;
/*keep the most severe results*/
proc sort data=fas1.f1_16;
by person_id descending pad_sev;
run;
proc sort data=fas1.f1_16 nodupkey;
by person_id;
run;
/*NOTE: There were 81 observations read from the data set FAS1.F1_16.
NOTE: 29 observations with duplicate key values were deleted.
NOTE: The data set FAS1.F1_16 has 52 observations and 20 variables.
*/
proc freq data=fas1.f1_16;
tables x_sample_yr pad_class;
run;
/*X_SAMPLE_YR 
x_sample_yr Frequency Percent Cumulative
Frequency Cumulative
Percent 
2012 16 30.77 16 30.77 
2013 17 32.69 33 63.46 
2014 19 36.54 52 100.00 
PAD_CLASS	Frequency
	
CIN1	8
CIN2	8
CIN3	9
Normal	16
Not diagnostic	1
Other	10
*/

data fas1.f1_20;
merge fas1.f1_17(in=a) pad_1214_ndp(in=b);
if a and b;
by person_id x_sample_yr;
if pad_sample_date>=cyto_sample_date;
run;
proc sort data=fas1.f1_20;
by person_id descending pad_sev;
run;
proc sort data=fas1.f1_20 nodupkey;
by person_id;
run;
proc freq data=fas1.f1_20;
tables x_sample_yr pad_class;
run;
/*X_SAMPLE_YR 
x_sample_yr Frequency Percent Cumulative
Frequency Cumulative
Percent 
2012 8 29.63 8 29.63 
2013 11 40.74 19 70.37 
2014 8 29.63 27 100.00 

PAD_CLASS	Frequency
Cancer	1
Normal	26
*/

/*cyto-hpv-pad*/
data fas1.cyto_p_hpv_pad;
merge fas1.f1_14(in=a) pad_1214_ndp(in=b);
if a and b;
by person_id x_sample_yr;
if pad_sample_date>=cyto_sample_date;
run;
proc sort data=fas1.cyto_p_hpv_pad;
by person_id descending pad_sev;
run;
proc sort data=fas1.cyto_p_hpv_pad nodupkey;
by person_id;
run;


/*cyto-p-wo_hpv_pad*/
data fas1.cyto_p_wo_hpv_pad;
merge fas1.f1_16(in=a) fas1.cyto_p_hpv_pad(in=b);
by person_id;
if a and ^b;
run;
proc freq data=fas1.cyto_p_wo_hpv_pad;
tables pad_class;
run;
/*PAD_CLASS	Frequency
	
CIN1	1
CIN2	6
CIN3	2
Normal	3
Other	1
*/
