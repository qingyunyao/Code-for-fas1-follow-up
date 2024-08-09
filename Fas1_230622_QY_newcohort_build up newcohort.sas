/*File name..: Fas1 follow up-multiple rounds of screening */
/*Study......: Phd project study 1 the efficiency of hpv as primary test among post-menopause women (56-61)*/
/*Author.....: Qingyun Yao*/
/*Date.......: 2023/06/22*/
/*Updated....: 2023/09/13-2023/09/14 keep the hpv severity and follow the exclusion criteria
2024/02/05 end of follow up set to '31dec2022'd.*/
/*Purpose....: use the population we found create the cohort needed for the new analysis*/
/*Note.......: the previous cohort includes multiple screening test from one participants, these may be addressed and only keep one screening test (in this code we keep the first one because it is also the most severe one)

*/
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
/*find ppl have multiple screening test in F1_02*/
proc sort data=fas1.f1_02;
by person_id;
run;

data multi_hpv;
set fas1.f1_02;
by person_id;
if first.person_id and last.person_id then delete;
run;
/*NOTE: There were 7331 observations read from the data set FAS1.F1_02.
NOTE: The data set WORK.MULTI_HPV has 26 observations and 12 variables.
*/
/*after inspection there are 13 women have two hpv screening tests within the specific time interval 2012.1.1-2014.5.31
the positive results appeared all in the first screening test, here we will keep the first hpv screening test*/
proc sort data=fas1.f1_02;
by person_id hpv_sample_date;
run;
proc sort data=fas1.f1_02 nodupkey out=newcoh.f1_02;
by person_id;
run;
/*NOTE: There were 7331 observations read from the data set FAS1.F1_02.
NOTE: 13 observations with duplicate key values were deleted.
NOTE: The data set NEWCOH.F1_02 has 7318 observations and 12 variables.
*/

/*match F1_02 with the information of hpv type*/
data nkc_hpv_type;
set v_ncsr.nkc_hpv;
keep person_id x_sample_date sample_id hpv_type translation;
where x_sample_yr In (2012 2013 2014) and scr_type='1';
run;
/*NOTE: There were 87010 observations read from the data set V_NCSR.nkc_hpv.
      WHERE x_sample_yr in (2012, 2013, 2014) and (scr_type='1');
NOTE: The data set WORK.NKC_HPV_TYPE has 87010 observations and 5 variables
*/
proc freq data=nkc_hpv_type;
tables translation hpv_type;
run;
/*hpv_severity:
4-16/18/45
3-high risk other than 16/18/45
2-other hpv positive
1-sample not sufficient/invalid snomed etc
0-negative
DNA testing of high-risk HPV types was done with the
hybrid capture 2 assay (types 16, 18, 31, 33, 35, 39, 45, 51,
52, 56, 58, 59, and 68 (jw)),
put 45 with 18(karin)*/
data hpv_sev;
set nkc_hpv_type;
If translation='Examination not performed/Sample not sufficient/ Result not available' then hpv_severity=1;
If translation='HPV  high risk type other than HPV16 or 18-positive' then hpv_severity=3;
If translation='HPV 16-negative' then hpv_severity=0;
If translation='HPV 16-positive' then hpv_severity=4;
If translation='HPV 18 45-positive' then hpv_severity=4;
If translation='HPV 18, 45-positive' then hpv_severity=4;
If translation='HPV 18-45-negative' then hpv_severity=0;
If translation='HPV 18-negative' then hpv_severity=0;
If translation='HPV 18-positive' then hpv_severity=4;
If translation='HPV 26-positive' then hpv_severity=2;
If translation='HPV 30-positive' then hpv_severity=2;
If translation='HPV 31, 33, 52, 58 grupp)-positive' then hpv_severity=3;
If translation='HPV 31-positive' then hpv_severity=3;
If translation='HPV 33 52 58-positive' then hpv_severity=3;
If translation='HPV 33,58 (grupp)-positive' then hpv_severity=3;
If translation='HPV 33-positive' then hpv_severity=3;
If translation='HPV 35, 39, 51, 56, 59, 66, 68 (grupp)-positive' then hpv_severity=3;
If translation='HPV 35, 39, 68 (grupp)-positive' then hpv_severity=3;
If translation='HPV 35-positive' then hpv_severity=3;
If translation='HPV 39-positive' then hpv_severity=3;
If translation='HPV 42-positive' then hpv_severity=2;
If translation='HPV 43-positive' then hpv_severity=2;
If translation='HPV 45-positive' then hpv_severity=4;
If translation='HPV 51-positive' then hpv_severity=3;
If translation='HPV 52-positive' then hpv_severity=3;
If translation='HPV 53-positive' then hpv_severity=2;
If translation='HPV 54-positive' then hpv_severity=2;
If translation='HPV 56, 59, 66 (grupp)-positive' then hpv_severity=3;
If translation='HPV 56-positive' then hpv_severity=3;
If translation='HPV 58-positive' then hpv_severity=3;
If translation='HPV 59-positive' then hpv_severity=3;
If translation='HPV 6-positive' then hpv_severity=2;
If translation='HPV 61-positive' then hpv_severity=2;
If translation='HPV 62-positive' then hpv_severity=2;
If translation='HPV 66-positive' then hpv_severity=2;
If translation='HPV 67-positive' then hpv_severity=2;
If translation='HPV 68-positive' then hpv_severity=3;
If translation='HPV 70-positive' then hpv_severity=2;
If translation='HPV 73-positive' then hpv_severity=3;
If translation='HPV 74-positive' then hpv_severity=2;
If translation='HPV 83-positive' then hpv_severity=2;
If translation='HPV 86-positive' then hpv_severity=2;
If translation='HPV 87-positive' then hpv_severity=2;
If translation='HPV 89-positive' then hpv_severity=2;
If translation='HPV 90- positive' then hpv_severity=2;
If translation='HPV 90-positive' then hpv_severity=2;
If translation='HPV 91-positive' then hpv_severity=2;
If translation='HPV DNA extracted from sample-negative' then hpv_severity=0;
If translation='HPV DNA extracted from sample-positive' then hpv_severity=2;
If translation='HPV high risk type other than HPV16 or 18-positive' then hpv_severity=3;
If translation='HPV high risk types-negative' then hpv_severity=0;
If translation='HPV high risk types-positive' then hpv_severity=3;
If translation='HPV type unknown-negative' then hpv_severity=0;
If translation='HPV type unknown-positive' then hpv_severity=2;
If translation='Irrelevant code-ignore' then hpv_severity=1;
run;

/*keep the most severe result*/
proc sort data=hpv_sev;
by person_id x_sample_date descending hpv_severity;
run;
proc sort data=hpv_sev nodupkey out=hpv_out (keep=person_id x_sample_date hpv_severity translation);
by person_id x_sample_date;
run;
/*NOTE: There were 87010 observations read from the data set WORK.HPV_SEV.
NOTE: 11426 observations with duplicate key values were deleted.
NOTE: The data set WORK.HPV_OUT has 75584 observations and 4 variables.
*/

proc freq data=hpv_out;
tables hpv_severity hpv_severity*translation;
run;
/*hpv_severity Frequency Percent Cumulative
Frequency Cumulative
Percent 
0 56129 74.26 56129 74.26 
1 2096 2.77 58225 77.03 
2 1471 1.95 59696 78.98 
3 13750 18.19 73446 97.17 
4 2138 2.83 75584 100.00 
*/
/*keep reference how to define the most */
/*change the date format for easier calculation*/
data hpv_out;
set hpv_out;
sample_date=datepart(x_sample_date);
format sample_date yymmdd10.;
run;
/*merge f1_02 and type information*/
proc sort data=newcoh.f1_02;
by person_id hpv_sample_date;
run; 
data f1_02_type;
merge newcoh.f1_02(in=a) hpv_out(in=b);
by person_id;
if a;
if hpv_sample_date=sample_date;
run; 
/*check the type information*/
proc freq data=f1_02_type;
table hpv_severity hpv_severity*hpvdiag;
run;
data newcoh.f1_02_type (drop=sample_date);
set f1_02_type;
run;
/*The FREQ Procedure

hpv_severity Frequency Percent Cumulative
Frequency Cumulative
Percent 
0 6911 94.44 6911 94.44 
1 3 0.04 6914 94.48 
2 35 0.48 6949 94.96 
3 369 5.04 7318 100.00 

There is no 16/18/45 positive in this population
3 includes 16/18/45 positive based on the v_ncsr.nkc_extended_hpv
*/




/*start to build up the new cohort*/
/*find all the tests among the population in F1_02 and f1_12 before and after the fas1;
find out before fas1 is there a positve results no matter when;
the following tests needs to know the test time and results;
all arranged in the order of time*/

/*F1_02 hpv test after the fas1 test*/
data nkc_hpv;
set v_ncsr.nkc_hpv;
keep person_id x_sample_date age county_id sample_id x_snomed hpv_type scr_type hpvdiag translation x_referral_type;
run;

data nkc_hpv_sev;
set nkc_hpv;
If translation='Examination not performed/Sample not sufficient/ Result not available' then hpv_severity=1;
If translation='HPV  high risk type other than HPV16 or 18-positive' then hpv_severity=3;
If translation='HPV 16-negative' then hpv_severity=0;
If translation='HPV 16-positive' then hpv_severity=4;
If translation='HPV 18 45-positive' then hpv_severity=4;
If translation='HPV 18, 45-positive' then hpv_severity=4;
If translation='HPV 18-45-negative' then hpv_severity=0;
If translation='HPV 18-negative' then hpv_severity=0;
If translation='HPV 18-positive' then hpv_severity=4;
If translation='HPV 26-positive' then hpv_severity=2;
If translation='HPV 30-positive' then hpv_severity=2;
If translation='HPV 31, 33, 52, 58 grupp)-positive' then hpv_severity=3;
If translation='HPV 31-positive' then hpv_severity=3;
If translation='HPV 33 52 58-positive' then hpv_severity=3;
If translation='HPV 33,58 (grupp)-positive' then hpv_severity=3;
If translation='HPV 33-positive' then hpv_severity=3;
If translation='HPV 35, 39, 51, 56, 59, 66, 68 (grupp)-positive' then hpv_severity=3;
If translation='HPV 35, 39, 68 (grupp)-positive' then hpv_severity=3;
If translation='HPV 35-positive' then hpv_severity=3;
If translation='HPV 39-positive' then hpv_severity=3;
If translation='HPV 42-positive' then hpv_severity=2;
If translation='HPV 43-positive' then hpv_severity=2;
If translation='HPV 45-positive' then hpv_severity=4;
If translation='HPV 51-positive' then hpv_severity=3;
If translation='HPV 52-positive' then hpv_severity=3;
If translation='HPV 53-positive' then hpv_severity=2;
If translation='HPV 54-positive' then hpv_severity=2;
If translation='HPV 56, 59, 66 (grupp)-positive' then hpv_severity=3;
If translation='HPV 56-positive' then hpv_severity=3;
If translation='HPV 58-positive' then hpv_severity=3;
If translation='HPV 59-positive' then hpv_severity=3;
If translation='HPV 6-positive' then hpv_severity=2;
If translation='HPV 61-positive' then hpv_severity=2;
If translation='HPV 62-positive' then hpv_severity=2;
If translation='HPV 66-positive' then hpv_severity=2;
If translation='HPV 67-positive' then hpv_severity=2;
If translation='HPV 68-positive' then hpv_severity=3;
If translation='HPV 70-positive' then hpv_severity=2;
If translation='HPV 73-positive' then hpv_severity=3;
If translation='HPV 74-positive' then hpv_severity=2;
If translation='HPV 83-positive' then hpv_severity=2;
If translation='HPV 86-positive' then hpv_severity=2;
If translation='HPV 87-positive' then hpv_severity=2;
If translation='HPV 89-positive' then hpv_severity=2;
If translation='HPV 90- positive' then hpv_severity=2;
If translation='HPV 90-positive' then hpv_severity=2;
If translation='HPV 91-positive' then hpv_severity=2;
If translation='HPV DNA extracted from sample-negative' then hpv_severity=0;
If translation='HPV DNA extracted from sample-positive' then hpv_severity=2;
If translation='HPV high risk type other than HPV16 or 18-positive' then hpv_severity=3;
If translation='HPV high risk types-negative' then hpv_severity=0;
If translation='HPV high risk types-positive' then hpv_severity=3;
If translation='HPV type unknown-negative' then hpv_severity=0;
If translation='HPV type unknown-positive' then hpv_severity=2;
If translation='Irrelevant code-ignore' then hpv_severity=1;
run;


/*only keep the most severe case of each sample_date*/
proc sort data=nkc_hpv_sev;
by person_id x_sample_date descending hpv_severity;
run;
proc sort data=nkc_hpv_sev nodupkey out=nkc_hpv_sev_nd;
by person_id x_sample_date;
run;
/*change the format and variable name; easier to merge*/
data nkc_hpv_sev_nd;
set nkc_hpv_sev_nd;
n_hpvdiag=hpvdiag;
n_hpv_severity=hpv_severity;
n_scr_type=scr_type;
sample_date=datepart(x_sample_date);
format sample_date yymmdd10.;
run;
/*save it for the f1_12 population;all the hpv restults with hpv_severity*/
data newcoh.nkc_hpv_sev_nd (drop=hpvdiag scr_type);
set nkc_hpv_sev_nd;
run;
proc sort data=newcoh.nkc_hpv_sev_nd;
by person_id;
run;
proc sort data=newcoh.f1_02_type;
by person_id;
run;
/*f1_02 population, hpv test after fas1*/ 
data f1_02_af_hpv;
merge newcoh.f1_02_type(in=a) newcoh.nkc_hpv_sev_nd(in=b);
by person_id;
if a and b;
if sample_date>=hpv_sample_date;
run; 
/*NOTE: There were 7318 observations read from the data set NEWCOH.F1_02_TYPE.
NOTE: There were 3499836 observations read from the data set NEWCOH.NKC_HPV_SEV_ND.
NOTE: The data set WORK.F1_02_AF_HPV has 15159 observations and 22 variables.
*/
proc sort data=f1_02_af_hpv;
by person_id;
run;
data f1_02_af_hpv_count;
set f1_02_af_hpv;
by person_id;
if first.person_id then nr_hpv_test=0;
nr_hpv_test+1;
run;
proc freq data=f1_02_af_hpv_count;
tables nr_hpv_test;
run;
/*count	Frequency
	
1	7318
2	6158
3	1072
4	281
5	141
6	77
7	54
8	29
9	13
10	8
11	5
12	2
13	1
*/

/*hpv test before fas1*/
data f1_02_bf_hpv;
merge newcoh.f1_02(in=a) newcoh.nkc_hpv_sev_nd(in=b);
by person_id;
if a and b;
if sample_date<hpv_sample_date;
run; 
/*NOTE: There were 7318 observations read from the data set NEWCOH.F1_02.
NOTE: There were 3499836 observations read from the data set NEWCOH.NKC_HPV_SEV_ND.
NOTE: The data set WORK.F1_02_BF_HPV has 26 observations and 22 variables.
*/
/*save for later useage*/
data newcoh.f1_02_bf_hpv;
set f1_02_bf_hpv;
run;
data newcoh.f1_02_af_hpv;
set f1_02_af_hpv;
run;

/*finding all the hpv test for f1_12 population*/
proc sort data=fas1.f1_12;
by person_id;
run;
/*keep the first screening test
here we keep the first test*/
data f1_12_multi;
set fas1.f1_12;
by person_id;
if first.person_id and last.person_id then delete;
run;

proc sort data=fas1.f1_12;
by person_id cyto_sample_date descending snomed_severity;
run;
proc sort data=fas1.f1_12 nodupkey out=f1_12;
by person_id;
run;
/*NOTE: There were 7452 observations read from the data set FAS1.F1_12.
NOTE: 51 observations with duplicate key values were deleted.
NOTE: The data set WORK.F1_12 has 7401 observations and 12 variables
*/
data newcoh.f1_12;
set f1_12;
run;
/*F12 hpv test before fas1*/
data newcoh.f1_12_bf_hpv;
merge newcoh.f1_12(in=a) newcoh.nkc_hpv_sev_nd(in=b);
by person_id;
if a and b;
if sample_date<cyto_sample_date;
run; 
/*F12 hpv test after fas1*/
data f1_12_af_hpv;
merge newcoh.f1_12(in=a) newcoh.nkc_hpv_sev_nd(in=b);
by person_id;
if a and b;
if sample_date>=cyto_sample_date;
run; 
proc sort data=f1_12_af_hpv;
by person_id;
run;
/*count all the hpv test after fas1*/
data f1_12_af_hpv_count;
set f1_12_af_hpv;
by person_id;
if first.person_id then nr_hpv_test=0;
nr_hpv_test+1;
run;

proc freq data=f1_12_af_hpv_count;
tables nr_hpv_test;
run;
/*count	Frequency
	
1	6513
2	3013
3	448
4	120
5	60
6	27
7	10
8	5
9	2
10	1
11	1
*/
data newcoh.f1_12_af_hpv;
set f1_12_af_hpv;
run;

/*find all the cytological test for f1_02 and f1_12 population*/
/*match the cytological test with the translated test results*/
data cyto (keep=person_id referral_type scr_type county_id x_sample_date sample_id);
set v_ncsr.nkc_cell_6922;
run;
data cyto_trans (keep=person_id county_id x_sample_date sample_id snomed_worst snomed_severity scr_type);
set v_ncsr.nkc_trans_cell;
run;

/*merge the test and the results, sort first and only keep one test/person/day use nodupkep*/
proc sort data=cyto;
by person_id x_sample_date;
run;
proc sort data=cyto nodupkey;
by person_id x_sample_date;
run;
/*NOTE: There were 43117075 observations read from the data set WORK.CYTO.
NOTE: 18002466 observations with duplicate key values were deleted.
NOTE: The data set WORK.CYTO has 25114609 observations and 6 variables.
*/
/*and only keep the most severe results*/
proc sort data=cyto_trans;
by person_id x_sample_date descending snomed_severity;
run;
proc sort data=cyto_trans nodupkey out=cyto_trans_ndk;
by person_id x_sample_date;
run;
/*
NOTE: There were 25213551 observations read from the data set WORK.CYTO_TRANS.
NOTE: 113797 observations with duplicate key values were deleted.
NOTE: The data set WORK.CYTO_TRANS_NDK has 25099754 observations and 7 variables.
*/
/*merge to create a table with cyto test and the translated results*/
data cyto_results;
merge cyto(in=a) cyto_trans_ndk(in=b);
by person_id x_sample_date;
if a and b;
run;
/*NOTE: There were 25114609 observations read from the data set WORK.CYTO.
NOTE: There were 25099754 observations read from the data set WORK.CYTO_TRANS_NDK.
NOTE: The data set WORK.CYTO_RESULTS has 25099681 observations and 8 variables.
*/

/*rename variables*/
data cyto_results;
set cyto_results;
n_cyto_sample_date=datepart(x_sample_date);
n_snomed_worst=snomed_worst;
n_scr_type=scr_type;
n_sample_id=sample_id;
n_county_id=county_id;
n_referral_type=referral_type;
n_snomed_severity=snomed_severity;
format n_cyto_sample_date yymmdd10.;
run;
data cyto_results;
set cyto_results;
keep person_id n_cyto_sample_date n_snomed_worst n_scr_type n_sample_id n_county_id n_referral_type n_snomed_severity;
run;
/*this dataset has all the cyto test and it's results /person/date/most severe*/
data newcoh.cyto;
set cyto_results;
run;
/*find all the cyto test before fas1 for f1_02 population*/
/*sort all the datasets*/
proc sort data=newcoh.cyto;
by person_id;
run;
proc sort data=newcoh.f1_02;
by person_id;
run;
proc sort data=newcoh.f1_12;
by person_id;
run;
/*find all the cyto test before fas1 for f1_02 population*/
data f1_02_bf_cyto;
merge newcoh.f1_02(in=a) newcoh.cyto(in=b);
by person_id;
if a and b;
if n_cyto_sample_date<hpv_sample_date;
run;
/*find the most severe diagnosis before fas1 screening test*/
proc sort data=f1_02_bf_cyto;
by person_id descending n_snomed_severity;
run;
proc sort data=f1_02_bf_cyto nodupkey out=f1_02_bf_cyto_worst;
by person_id;
run;
/*NOTE: There were 43304 observations read from the data set WORK.F1_02_BF_CYTO.
NOTE: 36105 observations with duplicate key values were deleted.
NOTE: The data set WORK.F1_02_BF_CYTO_WORST has 7199 observations and 19 variables.
*/
proc freq data=f1_02_bf_cyto_worst;
tables n_snomed_severity;
run;
data newcoh.f1_02_bf_cyto_worst;
set f1_02_bf_cyto_worst;
run;/*this dataset have the previous positive screening results*/
/*
n_snomed_severity	Frequency
	
2	1
4	6610
5	54
6	98
7	173
8	12
9	109
10	1
11	94
12	42
13	1
14	1
15	3

>=5
n=588 previously positive test*/

/*find all the cytological test after fas1 for f1_02*/
data newcoh.f1_02_af_cyto;
merge newcoh.f1_02(in=a) newcoh.cyto(in=b);
by person_id;
if a and b;
if n_cyto_sample_date>=hpv_sample_date;
run;
/*NOTE: There were 7318 observations read from the data set NEWCOH.F1_02.
NOTE: There were 25099681 observations read from the data set NEWCOH.CYTO.
NOTE: The data set NEWCOH.F1_02_AF_CYTO has 3819 observations and 19 variables.*/
/*count how many test they have taken after fas1*/
data newcoh.f1_02_af_cyto;
set newcoh.f1_02_af_cyto;
by person_id;
if first.person_id then nr_cyto_test=0;
nr_cyto_test+1;
run;

/*find all the cytological test before fas1 for f1_12 population*/
data f1_12_bf_cyto;
merge newcoh.f1_12(in=a) newcoh.cyto(in=b);
by person_id;
if a and b;
if n_cyto_sample_date<cyto_sample_date;
run;
/*find the most severe diagnosis before fas1*/
proc sort data=f1_12_bf_cyto;
by person_id descending n_snomed_severity;
run;
proc sort data=f1_12_bf_cyto nodupkey out=f1_12_bf_cyto_worst;
by person_id;
run;
/*NOTE: There were 43512 observations read from the data set WORK.F1_12_BF_CYTO.
NOTE: 36250 observations with duplicate key values were deleted.
NOTE: The data set WORK.F1_12_BF_CYTO_WORST has 7262 observations and 19 variables.
*/
proc freq data=f1_12_bf_cyto_worst;
tables n_snomed_severity;
run;
data newcoh.f1_12_bf_cyto_worst;
set f1_12_bf_cyto_worst;
run;/*this dataset contains the most severe cytological diagnosis for f1_12 population before fas1*/
/*n_snomed_severity	Frequency
	
4	6703
5	57
6	91
7	186
8	13
9	86
11	76
12	47
13	1
15	2
snomed severity>=5
n=559*/
/*find all the cytological test after fas1 for f1_12 population*/
data f1_12_af_cyto;
merge newcoh.f1_12(in=a) newcoh.cyto(in=b);
by person_id;
if a and b;*check;
if n_cyto_sample_date>=cyto_sample_date;
run;
/*NOTE: There were 7401 observations read from the data set NEWCOH.F1_12.
NOTE: There were 25099681 observations read from the data set NEWCOH.CYTO.
NOTE: The data set WORK.F1_12_AF_CYTO has 10127 observations and 19 variables.
*/
/*count how many cyto test participants have taken*/
data newcoh.f1_12_af_cyto;
set f1_12_af_cyto;
by person_id;
if first.person_id then nr_cyto_test=0;
nr_cyto_test+1;
run;

/*find all the pathological test in f1_12 and f1_02 population, use pad_translated_hpv*/
data pad;
set v_ncsr.nkc_pad_translated;
where TOPO3='T83';
keep person_id age county_id x_sample_date sample_id translated pad_sev pad_class snomed_translated topo3;
run;
/*rename for easier curation*/
data pad;
set pad;
pad_snomed_translated=snomed_translated;
pad_sample_date=datepart(x_sample_date);
pad_sample_id=sample_id;
format pad_sample_date yymmdd10.;
run;
data pad;
set pad;
drop x_sample_date sample_id snomed_translated;
run;
/*find all the pathological test before fas1 in f1_02 population*/
proc sort data=pad;
by person_id;
run;
proc sort data=newcoh.f1_02_type;
by person_id;
run;
data f1_02_bf_pad;
merge newcoh.f1_02_type(in=a) pad(in=b);
by person_id;
if a and b;
if pad_sample_date<hpv_sample_date;
run;
/*NOTE: There were 7318 observations read from the data set NEWCOH.F1_02_TYPE.
NOTE: There were 1818057 observations read from the data set WORK.PAD.
NOTE: The data set WORK.F1_02_BF_PAD has 1821 observations and 22 variables.
*/
/*keep the most severe diagnosis for each person*/
proc sort data=f1_02_bf_pad;
by person_id descending pad_sev;
run;
proc sort data=f1_02_bf_pad nodupkey out=f1_02_bf_pad_worst;
by person_id;
run;
proc freq data=f1_02_bf_pad_worst;
tables pad_class pad_class*hpvdiag/nocol norow nopercent;
run;
data newcoh.f1_02_bf_pad_worst;
set f1_02_bf_pad_worst;
run;
/*PAD_CLASS	Frequency
	
AIS	2
CIN1	53
CIN2	62
CIN3	89
Cancer	2
Normal	917
Not diagnostic	16
Other	85

PAD_CLASS(PAD_CLASS)	HPVDIAG(HPVDIAG)		
	NEG	POS	Total
AIS	1	1	2
CIN1	48	5	53
CIN2	58	4	62
CIN3	82	7	89
Cancer	2	0	2
Normal	865	52	917
Not diagnostic	15	1	16
Other	75	10	85
Total	1146	80	1226
*/
/*find all the pad test after fas1 f1_02*/
data f1_02_af_pad;
merge newcoh.f1_02_type(in=a) pad(in=b);
by person_id;
if a and b;
if pad_sample_date>=hpv_sample_date;
run;
/*NOTE: There were 7318 observations read from the data set NEWCOH.F1_02_TYPE.
NOTE: There were 1818057 observations read from the data set WORK.PAD.
NOTE: The data set WORK.F1_02_AF_PAD has 1072 observations and 22 variables.
*/
proc sort data=f1_02_af_pad;
by person_id pad_sample_date descending pad_sev;
run;
proc sort data=f1_02_af_pad nodupkey out=newcoh.f1_02_af_pad;
by person_id pad_sample_date;
run;
/*NOTE: There were 1072 observations read from the data set WORK.F1_02_AF_PAD.
NOTE: 25 observations with duplicate key values were deleted.
NOTE: The data set NEWCOH.F1_02_AF_PAD has 1047 observations and 22 variables
*/
data newcoh.f1_02_af_pad;
set newcoh.f1_02_af_pad;
by person_id;
if first.person_id then nr_pad=0;
nr_pad+1;
run;
/*only keep the most severe results of each pad test*/
/*all the pad test from f1_12 population before fas1 screening test*/
data f1_12_bf_pad;
merge newcoh.f1_12(in=a) pad(in=b);
by person_id;
if a and b;
if pad_sample_date<cyto_sample_date;
run;
/*find the most severe diagnosis*/
proc sort data=f1_12_bf_pad;
by person_id descending pad_sev;
run;
proc sort data=f1_12_bf_pad nodupkey out=newcoh.f1_12_bf_pad_worst;
by person_id;
run;
/*NOTE: There were 1778 observations read from the data set WORK.F1_12_BF_PAD.
NOTE: 612 observations with duplicate key values were deleted.
NOTE: The data set NEWCOH.F1_12_BF_PAD_WORST has 1166 observations and 20 variables
*/
proc freq data=newcoh.f1_12_bf_pad_worst;
tables pad_class;
run;
/*PAD_CLASS	Frequency
	
AIS	2
CIN1	68
CIN2	57
CIN3	76
Cancer	4
Normal	873
Not diagnostic	15
Other	71
*/
proc freq data=newcoh.f1_12_bf_pad_worst;
tables pad_class;
where snomed_severity>=5;
run;
/*PAD_CLASS	Frequency
	
CIN1	2
CIN2	3
CIN3	1
Cancer	1
Normal	7
Other	2
*/

/*pad after fas1 f1_12*/
data f1_12_af_pad;
merge newcoh.f1_12(in=a) pad(in=b);
by person_id;
if a and b;
if pad_sample_date>=cyto_sample_date;
run;
/*NOTE: There were 7401 observations read from the data set NEWCOH.F1_12.
NOTE: There were 1818057 observations read from the data set WORK.PAD.
NOTE: The data set WORK.F1_12_AF_PAD has 760 observations and 20 variables.
*/
proc sort data=f1_12_af_pad;
by person_id pad_sample_date descending pad_sev;
run;
/*find the most severe result per test/day*/
proc sort data=f1_12_af_pad nodupkey out=newcoh.f1_12_af_pad;
by person_id pad_sample_date;
run;
/*NOTE: There were 760 observations read from the data set WORK.F1_12_AF_PAD.
NOTE: 10 observations with duplicate key values were deleted.
NOTE: The data set NEWCOH.F1_12_AF_PAD has 750 observations and 20 variables
*/
data newcoh.f1_12_af_pad;
set newcoh.f1_12_af_pad;
by person_id;
if first.person_id then nr_pad=0;
nr_pad+1;
run;


/*the indicative test before is used to identify women with previous any kind of positive
the indicative test after need to be added into the screening pattern and assign screening type =2 non-program hpv screening
the type of hpv is not a question of concern here so didn't differentiate the hpv types*/
/*find all indicative test for population in f1_12 and f1_02 also before and after fas1, using nkc_ext_hpv*/
data nkc_ext_hpv;
set v_ncsr.nkc_ext_hpv;
ind_sample_date=datepart(x_sample_date);
ind_hpvdiag=hpvdiag;
ind_hpv_type=hpv_type;
ind_trans=translation;
format ind_sample_date yymmdd10.;
keep person_id ind_sample_date ind_hpvdiag ind_hpv_type ind_trans;
run;
/*indicative hpv before fas1 f1_02*/
proc sort data=nkc_ext_hpv;
by person_id;
run;
data newcoh.f1_02_bf_ind;
merge newcoh.f1_02_type(in=a) nkc_ext_hpv(in=b);
by person_id;
if a and b;
if ind_sample_date<hpv_sample_date;
run;
data newcoh.f1_02_af_ind;
merge newcoh.f1_02_type(in=a) nkc_ext_hpv(in=b);
by person_id;
if a and b;
if ind_sample_date>=hpv_sample_date;
run;
proc sort data=newcoh.f1_02_af_ind;
by person_id ind_sample_date descending ind_hpvdiag;
run;
/*keep one test result per day, the most severe diagnosis*/
proc sort data=newcoh.f1_02_af_ind nodupkey out=newcoh.f1_02_af_ind_ndk;
by person_id ind_sample_date;
run;
/*NOTE: There were 942 observations read from the data set NEWCOH.F1_02_AF_IND.
NOTE: 578 observations with duplicate key values were deleted.
NOTE: The data set NEWCOH.F1_02_AF_IND_NDK has 364 observations and 19 variables.
*/
/*f1_12 indicative hpv test*/
data newcoh.f1_12_bf_ind;
merge newcoh.f1_12(in=a) nkc_ext_hpv(in=b);
by person_id;
if a and b;
if ind_sample_date<cyto_sample_date;
run;
/*NOTE: There were 7401 observations read from the data set NEWCOH.F1_12.
NOTE: There were 485797 observations read from the data set WORK.NKC_EXT_HPV.
NOTE: The data set NEWCOH.F1_12_BF_IND has 21 observations and 16 variables.
*/
data newcoh.f1_12_af_ind;
merge newcoh.f1_12(in=a) nkc_ext_hpv(in=b);
by person_id;
if a and b;
if ind_sample_date>=cyto_sample_date;
run;
/*NOTE: There were 7401 observations read from the data set NEWCOH.F1_12.
NOTE: There were 485797 observations read from the data set WORK.NKC_EXT_HPV.
NOTE: The data set NEWCOH.F1_12_AF_IND has 820 observations and 16 variables.
*/
proc sort data=newcoh.f1_12_af_ind;
by person_id ind_sample_date descending ind_hpvdiag;
run;
proc sort data=newcoh.f1_12_af_ind nodupkey out=newcoh.f1_12_af_ind_ndk;
by person_id ind_sample_date;
run;
/*NOTE: There were 820 observations read from the data set NEWCOH.F1_12_AF_IND.
NOTE: 577 observations with duplicate key values were deleted.
NOTE: The data set NEWCOH.F1_12_AF_IND_NDK has 243 observations and 16 variables.
*/



/*need to find out if there is ppl deregister because of other problem and reason*/
data dereg_pop;
set v_ncsr.nkc_dereg_pop_2022;
run;
data deregister;
set v_ncsr.nkc_deregister;
run;
proc sort data=dereg_pop;
by person_id;
proc sort data=deregister;
by person_id;
run;
data f1_02_dereg_pop;
merge newcoh.f1_02_type(in=a) dereg_pop(in=b);
by person_id;
if a and b;
run;
proc freq data=f1_02_dereg_pop;
tables dereg_reas;
run;
/*dereg_reas	Frequency
	
AV	261
GN	2
OB	1
UV	92
*/
data newcoh.f1_02_dereg_pop;
set f1_02_dereg_pop;
dereg_yr=substr(dereg_date,1,4);
dereg_m=substr(dereg_date,5,2);
dereg_d=substr(dereg_date,7,2);
dereg_date_n=catx('-',dereg_yr,dereg_m,dereg_d);
d_day=input(dereg_date, yymmdd10.);
format d_day yymmdd10.;
drop dereg_date dereg_yr dereg_m dereg_d dereg_date_n;
run;
/*F1_12 dereg_pop*/
data f1_12_dereg_pop;
merge newcoh.f1_12(in=a) dereg_pop(in=b);
by person_id;
if a and b;
run;
proc freq data=f1_12_dereg_pop;
tables dereg_reas;
run;
/*dereg_reas	Frequency
	
AV	265
OB	1
UV	97
*/
data newcoh.f1_12_dereg_pop;
set f1_12_dereg_pop;
dereg_yr=substr(dereg_date,1,4);
dereg_m=substr(dereg_date,5,2);
dereg_d=substr(dereg_date,7,2);
dereg_date_n=catx('-',dereg_yr,dereg_m,dereg_d);
d_day=input(dereg_date, yymmdd10.);
format d_day yymmdd10.;
drop dereg_date dereg_yr dereg_m dereg_d dereg_date_n;
run;

/*deregister f1_02 f1_12*/
data nkc_deregister;
set v_ncsr.nkc_deregister;
keep person_id x:;
run;
proc sort data=nkc_deregister;
by person_id;
run;
data newcoh.f1_02_deregister;
merge newcoh.f1_02_type(in=a) nkc_deregister(in=b);
by person_id;
if a and b;
run;
/*NOTE: There were 7318 observations read from the data set NEWCOH.F1_02_TYPE.
NOTE: There were 99843 observations read from the data set WORK.NKC_DEREGISTER.
NOTE: The data set NEWCOH.F1_02_DEREGISTER has 52 observations and 20 variables.
*/
data newcoh.f1_12_deregister;
merge newcoh.f1_12(in=a) nkc_deregister(in=b);
by person_id;
if a and b;
run;
/*NOTE: There were 7401 observations read from the data set NEWCOH.F1_12.
NOTE: There were 99843 observations read from the data set WORK.NKC_DEREGISTER.
NOTE: The data set NEWCOH.F1_12_DEREGISTER has 54 observations and 17 variables.
*/





/*20230630
match the hpv screening results of f1_02 with nkc_extended_hpv*/
data nkc_extended;
set v_ncsr.nkc_extended_hpv;
keep person_id hpv16 hpv18 otherhr sample_id x_sample_date e_sample_date referral_type hpv1618;
/*hpv1618
hpv16+----2
hpv18+----2
other+----1
all negative---0*/
if hpv16='POS' then hpv1618=2;
else if hpv18='POS' then hpv1618=2;
else if otherhr='POS' then hpv1618=1;
else hpv1618=0;
e_sample_date=datepart(x_sample_date);
format e_sample_date yymmdd10.;
run;

/*merge f1_02_type with nkc_extended*/
proc sort data=nkc_extended;
by person_id e_sample_date;
run;
proc sort data=newcoh.f1_02_type;
by person_id hpv_sample_date;
run;
data f1_02_1618;
merge newcoh.f1_02_type(in=a) nkc_extended(in=b);
by person_id;
if a;
if hpv_sample_date=e_sample_date;
run;
/*NOTE: There were 7318 observations read from the data set NEWCOH.F1_02_TYPE.
NOTE: There were 562667 observations read from the data set WORK.NKC_EXTENDED.
NOTE: The data set WORK.F1_02_1618 has 4449 observations and 20 variables.
*/

proc sort data=f1_02_1618;
by person_id;
proc sort data=newcoh.f1_02_type;
by person_id;
run;
/*dataset with both hpv type information*/
data newcoh.f1_02_type_1618;
merge newcoh.f1_02_type(in=a) f1_02_1618(in=b);
by person_id;
if a;
run;

proc freq data=f1_02_1618;
tables hpv1618 x_sample_yr;
run;
/*hpv1618 Frequency Percent Cumulative
Frequency Cumulative
Percent 
0 4201 94.43 4201 94.43 
1 189 4.25 4390 98.67 
2 59 1.33 4449 100.00 

X_SAMPLE_YR 
x_sample_yr Frequency Percent Cumulative
Frequency Cumulative
Percent 
2013 2827 63.54 2827 63.54 
2014 1622 36.46 4449 100.00 

nkc_extended doesn't have 2012's hpv's results 
*/
proc freq data=v_ncsr.nkc_extended_hpv;
tables x_sample_yr;
run;
/*
X_SAMPLE_YR	Frequency
	
2013	8334
2014	29486
2015	60072
2016	57609
2017	93967
2018	102376
2019	130423
2020	78894
2021	1506
*/
proc freq data=newcoh.f1_02_type;
tables x_sample_yr;
run;
/*X_SAMPLE_YR 
x_sample_yr Frequency Percent Cumulative
Frequency Cumulative
Percent 
2012 2867 39.18 2867 39.18 
2013 2828 38.64 5695 77.82 
2014 1623 22.18 7318 100.00 
*/


/*screening history*/
/*2023-0703*/
/*find the positive results of all the cervical cancer related test before fas1 screening
create new variables:
HPV previously positive: HPV_pre_p 0-no 1-yes
cytological test previously positive: cyto_pre_p 0-no 1-yes 
previous CIN2+ positive:pre_HSIL 0-no 1-yes
previously CIN3+ positive:pre_CIN3 0-no 1-yes
previously cancer positive: pre_can 0-no 1-yes
pad_snomed*/
/*
find the deregistered information 
create new variables:
dereg: 0-no 1-yes
dereg_time: yymmdd10.*/
/*cyto_pre_p*/
data f1_02_cyto;
set newcoh.f1_02_bf_cyto_worst;
if n_snomed_severity>=5 then cyto_pre_p=1;
else if n_snomed_severity<5 then cyto_pre_p=0;
keep person_id n_sample_id n_snomed_worst n_cyto_sample_date n_snomed_severity cyto_pre_p;
run;
data f1_12_cyto;
set newcoh.f1_12_bf_cyto_worst;
if n_snomed_severity>=5 then cyto_pre_p=1;
else if n_snomed_severity<5 then cyto_pre_p=0;
keep person_id n_sample_id n_snomed_worst n_cyto_sample_date n_snomed_severity cyto_pre_p;
run;
proc freq data=f1_02_cyto;
tables cyto_pre_p;
run;
/*cyto_pre_p	Frequency
	
0	6611
1	588
*/
proc freq data=f1_12_cyto;
tables cyto_pre_p;
run;
/*
cyto_pre_p	Frequency
	
0	6703
1	559
*/
/*previous CIN2+ positive:pre_HSIL 0-no 1-yes
previously CIN3+ positive:pre_CIN3 0-no 1-yes
previously cancer positive: pre_can 0-no 1-yes
pad_snomed*/
data f1_02_pad;
set newcoh.f1_02_bf_pad_worst;
if pad_sev>=5 then pre_HSIL=1;
else pre_HSIL=0;
if pad_sev>=6 then pre_CIN3=1;
else pre_CIN3=0;
if pad_sev>=9 then pre_can=1;
else pre_can=0;
keep person_id pad_sev topo3 pad_class pad_snomed_translated pad_sample_date pre_HSIL pre_CIN3 pre_can;
run;
data f1_12_pad;
set newcoh.f1_12_bf_pad_worst;
if pad_sev>=5 then pre_HSIL=1;
else pre_HSIL=0;
if pad_sev>=6 then pre_CIN3=1;
else pre_CIN3=0;
if pad_sev>=9 then pre_can=1;
else pre_can=0;
keep person_id pad_sev topo3 pad_class pad_snomed_translated pad_sample_date pre_HSIL pre_CIN3 pre_can;
run;
proc freq data=f1_02_pad;
tables pre_HSIL pre_CIN3 pre_can;
run;
/*pre_HSIL	Frequency
	
0	1071
1	155
	
pre_CIN3	Frequency
	
0	1133
1	93
	
pre_can	Frequency
	
0	1224
1	2
*/
proc freq data=f1_12_pad;
tables pre_HSIL pre_CIN3 pre_can;
run;
/*
pre_HSIL	Frequency
	
0	1027
1	139
	
pre_CIN3	Frequency
	
0	1084
1	82
	
pre_can	Frequency
	
0	1162
1	4
*/
/*HPV previously positive: HPV_pre_p 0-no 1-yes*/
/*merge previous hpv and previous indicated results*/
data f1_02_hpv;
set newcoh.f1_02_bf_hpv;
rename sample_date=n_hpv_sample_date;
keep person_id n_hpvdiag n_hpv_severity sample_date;
run; 
/**hpv_severity:
4-16/18/45
3-high risk other than 16/18/45
2-other hpv positive
1-sample not sufficient/invalid snomed etc
0-negative*/
data f1_02_hpv_ind;
set newcoh.f1_02_bf_ind;
if ind_hpvdiag='NEG' then ind_hpv_severity=0;
else ind_hpv_severity=2;
rename ind_hpvdiag=n_hpvdiag ind_hpv_severity=n_hpv_severity ind_sample_date=n_hpv_sample_date;
keep person_id ind_hpvdiag ind_sample_date ind_hpv_severity;
run; 
data f1_12_hpv;
set newcoh.f1_12_bf_hpv;
rename sample_date=n_hpv_sample_date;
keep person_id n_hpvdiag n_hpv_severity sample_date;
run; 
data f1_12_hpv;
set f1_12_hpv;
if person_id=1755715 and n_hpvdiag='POS' then n_hpv_severity=4;
run;

data f1_12_hpv_ind;
set newcoh.f1_12_bf_ind;
if ind_hpvdiag='NEG' then ind_hpv_severity=0;
else ind_hpv_severity=2;
rename ind_hpvdiag=n_hpvdiag ind_hpv_severity=n_hpv_severity ind_sample_date=n_hpv_sample_date;
keep person_id ind_hpvdiag ind_sample_date ind_hpv_severity;
run; 

/*using set to put indicative hpv test with all test*/
data f1_02_hpv_all;
set f1_02_hpv f1_02_hpv_ind;
run;
/*NOTE: There were 26 observations read from the data set WORK.F1_02_HPV.
NOTE: There were 22 observations read from the data set WORK.F1_02_HPV_IND.
NOTE: The data set WORK.F1_02_HPV_ALL has 48 observations and 4 variables.
NOTE: DATA statement used (Total process time):
*/
data f1_12_hpv_all;
set f1_12_hpv f1_12_hpv_ind;
run;
/*NOTE: There were 27 observations read from the data set WORK.F1_12_HPV.
NOTE: There were 21 observations read from the data set WORK.F1_12_HPV_IND.
NOTE: The data set WORK.F1_12_HPV_ALL has 48 observations and 4 variables.
NOTE: DATA statement used (Total process time):
*/
proc sort data=f1_02_hpv_all;
by person_id descending n_hpv_severity;
run;
proc sort data=f1_02_hpv_all nodupkey out=f1_02_hpv_pre;
by person_id;
run;
/*NOTE: There were 48 observations read from the data set WORK.F1_02_HPV_ALL.
NOTE: 17 observations with duplicate key values were deleted.
NOTE: The data set WORK.F1_02_HPV_PRE has 31 observations and 4 variables
*/
proc sort data=f1_12_hpv_all;
by person_id descending n_hpv_severity;
run;
proc sort data=f1_12_hpv_all nodupkey out=f1_12_hpv_pre;
by person_id;
run;
/*NOTE: There were 48 observations read from the data set WORK.F1_12_HPV_ALL.
NOTE: 20 observations with duplicate key values were deleted.
NOTE: The data set WORK.F1_12_HPV_PRE has 28 observations and 4 variables.
*/

/*merge all the previous test result into one data set*/
/*start with population*/
data f1_02_pop;
set newcoh.f1_02_type;
keep person_id even;
run;
data f1_12_pop;
set newcoh.f1_12;
keep person_id even;
run;
/*add all the pre results
sort first*/
proc sort data=f1_02_pop;
by person_id;
run;
proc sort data=f1_02_cyto;
by person_id;
run;
proc sort data=f1_02_hpv_pre;
by person_id;
run;
proc sort data=f1_02_pad;
by person_id;
run;

proc sort data=f1_12_pop;
by person_id;
run;
proc sort data=f1_12_cyto;
by person_id;
run;
proc sort data=f1_12_hpv_pre;
by person_id;
run;
proc sort data=f1_12_pad;
by person_id;
run;

/*merge*/
data f1_02_pre;
merge f1_02_pop(in=a) f1_02_hpv_pre(in=b);
by person_id;
if a;
run;
data f1_02_pre;
merge f1_02_pre(in=a) f1_02_cyto(in=b);
by person_id;
if a;
run;
data f1_02_pre;
merge f1_02_pre(in=a) f1_02_pad(in=b);
by person_id;
if a;
run;

/*whether the participaints have previous hpv test; pre_test=1 yes/0 no*/
data f1_02_pre;
set f1_02_pre;
if n_hpvdiag='POS' then HPV_pre_p=1;
else hpv_pre_p=0;
if n_hpvdiag IN ('POS' 'NEG') or cyto_pre_p IN (0 1) or pre_HSIL IN (0 1) or pre_CIN3 IN (0 1) or pre_can IN (0 1) then pre_test=1;
else pre_test=0;
run;

/*replacing all the missing value in cyto_pre_p pre_HSIL pre_CIN3 pre_can*/
data f1_02_pre_nm;
set f1_02_pre;
array replacM cyto_pre_p pre_HSIL pre_CIN3 pre_can;
do over replacM;
if replacM=. then replacM=0;
end;
run;


/*f1_12*/
data f1_12_pre;
merge f1_12_pop(in=a) f1_12_hpv_pre(in=b);
by person_id;
if a;
run;
data f1_12_pre;
merge f1_12_pre(in=a) f1_12_cyto(in=b);
by person_id;
if a;
run;
data f1_12_pre;
merge f1_12_pre(in=a) f1_12_pad(in=b);
by person_id;
if a;
run;

/*whether the participaints have previous hpv test; pre_test=1 yes/0 no*/
data f1_12_pre;
set f1_12_pre;
if n_hpvdiag='POS' then HPV_pre_p=1;
else hpv_pre_p=0;
if n_hpvdiag IN ('POS' 'NEG') or cyto_pre_p IN (0 1) or pre_HSIL IN (0 1) or pre_CIN3 IN (0 1) or pre_can IN (0 1) then pre_test=1;
else pre_test=0;
run;

/*replacing all the missing value in cyto_pre_p pre_HSIL pre_CIN3 pre_can*/
data f1_12_pre_nm;
set f1_12_pre;
array replacM cyto_pre_p pre_HSIL pre_CIN3 pre_can;
do over replacM;
if replacM=. then replacM=0;
end;
run;

proc freq data=f1_02_pre_nm;
tables cyto_pre_p pre_HSIL pre_CIN3 HPV_pre_p pre_can pre_test;
run;
/*cyto_pre_p	Frequency
	
0	6730
1	588
	
pre_HSIL	Frequency
	
0	7163
1	155
	
pre_CIN3	Frequency
	
0	7225
1	93
	
HPV_pre_p	Frequency
	
0	7311
1	7
	
pre_can	Frequency
	
0	7316
1	2
	
pre_test	Frequency
	
0	117
1	7201
*/
proc freq data=f1_12_pre_nm;
tables cyto_pre_p pre_HSIL pre_CIN3 HPV_pre_p pre_can pre_test;
run;
/*cyto_pre_p	Frequency
	
0	6842
1	559
	
pre_HSIL	Frequency
	
0	7262
1	139
	
pre_CIN3	Frequency
	
0	7319
1	82
	
HPV_pre_p	Frequency
	
0	7394
1	7
	
pre_can	Frequency
	
0	7397
1	4
	
pre_test	Frequency
	
0	137
1	7264
*/
/*save for later use
these two dataset the pre_hsil pre_cin3 pre_can all based on pathological test*/
data newcoh.f1_02_pre;
set f1_02_pre_nm;
run;
data newcoh.f1_12_pre;
set f1_12_pre_nm;
run;


/*20230704*/
/*match the register information*/
/*new variable dreg 0--no/1--yes*/
/*copy the needed information in work library*/
data f1_02_dereg;
set newcoh.f1_02_dereg_pop;
keep person_id dereg_reas d_day;
run;
data f1_02_deregister;
set newcoh.f1_02_deregister;
format x_dereg_from_date yymmdd10.;
keep person_id x_dereg_reason x_dereg_from_date;
run;
/*sort before merge*/
proc sort data=f1_02_dereg;
by person_id;
proc sort data=f1_02_deregister;
by person_id;
run;
data f1_02_d;
merge f1_02_dereg(in=a) f1_02_deregister(in=b);
by person_id;
if a;
run;
/*check if someone has two deregistration*/
proc freq data=f1_02_d;
tables dereg_reas*x_dereg_reason/missing nopercent nocol norow;
run;
/*dereg_reas(dereg_reas)	X_DEREG_REASON(X_DEREG_REASON)				
		Andra orsaker	Egen vilja	Hysterektomi	Total
	6912	3	4	43	6962
AV	260	0	0	1	261
GN	2	0	0	0	2
OB	1	0	0	0	1
UV	91	0	0	1	92
Total	7266	3	4	45	7318


There are two ppl who has both hysterektomi and AV/UV
choose the earlier dereg time*/

data f1_02_d;
set f1_02_d;
diff=x_dereg_from_date-d_day;
run;
proc freq data=f1_02_d;
tables diff;
run;
/*diff<0 so x_dereg_from_date is earlier than d_day keep the x_dereg_from_date*/
/*merge dereg_reas and dereg_date
dereg=2 deregistered from nkc_deregister
dereg=1 deregistered from nkc_dereg_pop*/
data f1_02_d_merge;
set f1_02_d;
if diff<0 then dereg=2;
if x_dereg_reason='' and dereg_reas='' then dereg=0;
else if dereg_reas='' and x_dereg_reason^='' then dereg=2;
else if x_dereg_reason='' and dereg_reas^='' then dereg=1;
run;
data f1_02_d_merge;
set f1_02_d_merge;
if dereg=1 then dereg_date=d_day;
else if dereg=2 then dereg_date=x_dereg_from_date;
format dereg_date yymmdd10.;
run;
data f1_02_d_merge;
set f1_02_d_merge;
if dereg=2 then dereg_rea=x_dereg_reason;
else if dereg=1 then dereg_rea=dereg_reas; 
run;

data f1_02_d_merge;
set f1_02_d_merge;
keep person_id dereg dereg_date dereg_rea;
run;



/*12*/
data f1_12_dereg;
set newcoh.f1_12_dereg_pop;
keep person_id dereg_reas d_day;
run;
data f1_12_deregister;
set newcoh.f1_12_deregister;
format x_dereg_from_date yymmdd10.;
keep person_id x_dereg_reason x_dereg_from_date;
run;
/*sort before merge*/
proc sort data=f1_12_dereg;
by person_id;
proc sort data=f1_12_deregister;
by person_id;
run;
data f1_12_d;
merge f1_12_dereg(in=a) f1_12_deregister(in=b);
by person_id;
if a;
run;
/*check if someone has two deregistration*/
proc freq data=f1_12_d;
tables dereg_reas*x_dereg_reason/missing nopercent nocol norow;
run;
/*dereg_reas(dereg_reas)	X_DEREG_REASON(X_DEREG_REASON)			
		Andra orsaker	Hysterektomi	Total
	6984	4	50	7038
AV	265	0	0	265
OB	1	0	0	1
UV	97	0	0	97
Total	7347	4	50	7401
*/


data f1_12_d_merge;
set f1_12_d;
if x_dereg_reason='' and dereg_reas='' then dereg=0;
else if dereg_reas='' and x_dereg_reason^='' then dereg=2;
else if x_dereg_reason='' and dereg_reas^='' then dereg=1;
run;
data f1_12_d_merge;
set f1_12_d_merge;
if dereg=1 then dereg_date=d_day;
else if dereg=2 then dereg_date=x_dereg_from_date;
format dereg_date yymmdd10.;
run;
data f1_12_d_merge;
set f1_12_d_merge;
if dereg=2 then dereg_rea=x_dereg_reason;
else if dereg=1 then dereg_rea=dereg_reas; 
run;
data f1_12_d_merge;
set f1_12_d_merge;
keep person_id dereg dereg_date dereg_rea;
run;

/*merge pre and deregist*/
proc sort data=newcoh.f1_02_pre;
by person_id;
proc sort data=newcoh.f1_12_pre;
by person_id;
proc sort data=f1_02_d_merge;
by person_id;
proc sort data=f1_12_d_merge;
by person_id;
run;
data newcoh.f1_02_pre_d;
merge newcoh.f1_02_pre(in=a) f1_02_d_merge(in=b);
by person_id;
if a;
data newcoh.f1_12_pre_d;
merge newcoh.f1_12_pre(in=a) f1_12_d_merge(in=b);
by person_id;
if a;
run;

/*
2023/7/5
find out the endpoint of each observation
dereg
CIN2
CIN3
Cancer
focus on cytological test and pathology test after fas1
should sort the dataset by the sample_date
0. also find the LSIL
1. find out all the HSIL results and find the earliest date
2. find out all the CIN3+ results and find the earliest date
3. find out all the cancer results and use the earliest date
2023/10/20
the cancer need to base on the GQCR, the code of cancer will be commented
*/

/*
cytology 
severity
6----ASCUS
7----CIN1 LSIL
8----AGC
9----unclear atypia
10---suspected high grade dysplasia
11---CIN2 HSIL JW
12---CIN3 HSIL
13---invasive adenocarcinoma
14---Malignant tumor with unclear origin*/

/*find all the LSIL and above results*/
data f1_02_LSIL_cyto;
set newcoh.f1_02_af_cyto;
if n_snomed_severity>=7;
keep person_id n_cyto_sample_date n_snomed_worst n_sample_id n_snomed_severity;
where n_cyto_sample_date<='31dec2022'd;
run;
/*find the earliest date of the LSIL diagnosis*/
proc sort data=f1_02_LSIL_cyto;
by person_id n_cyto_sample_date;
run;
proc sort data=f1_02_LSIL_cyto nodupkey out=f1_02_LSIL_cyto_e;
by person_id;
run;
/*NOTE: There were 280 observations read from the data set WORK.F1_02_LSIL_CYTO.
NOTE: 104 observations with duplicate key values were deleted.
NOTE: The data set WORK.F1_02_LSIL_CYTO_E has 176 observations and 5 variables.
*/
/*new variable: c_LSIL 0-no 1-have a diagnosis severer than LSIL change n_cyto_sample_date to c_LSIL_date c_LSIL_snomed c_LSIL_sample_id c_LSIL_severity*/
data f1_02_LSIL_cyto_e;
set f1_02_LSIL_cyto_e;
rename n_cyto_sample_date=c_LSIL_date n_snomed_worst=c_LSIL_snomed n_sample_id=c_LSIL_sample_id n_snomed_severity=c_LSIL_severity;
c_LSIL=1;
run;

/*find all the HSIL/CIN2+ and above results*/
data f1_02_HSIL_cyto;
set newcoh.f1_02_af_cyto;
if n_snomed_severity>=11;
keep person_id n_cyto_sample_date n_snomed_worst n_sample_id n_snomed_severity;
where n_cyto_sample_date<='31dec2022'd;
run;
/*NOTE: There were 3819 observations read from the data set NEWCOH.F1_02_AF_CYTO.
NOTE: The data set WORK.F1_02_HSIL_CYTO has 68 observations and 5 variables.
*/
/*find the earliest date of the HSIL diagnosis*/
proc sort data=f1_02_HSIL_cyto;
by person_id n_cyto_sample_date;
run;
proc sort data=f1_02_HSIL_cyto nodupkey out=f1_02_HSIL_cyto_e;
by person_id;
run;
/*NOTE: There were 68 observations read from the data set WORK.F1_02_HSIL_CYTO.
NOTE: 15 observations with duplicate key values were deleted.
NOTE: The data set WORK.F1_02_HSIL_CYTO_E has 53 observations and 5 variables.
*/
/*new variable: c_HSIL 0-no 1-have a diagnosis severer than HSIL change n_cyto_sample_date to c_HSIL_date c_HSIL_snomed c_HSIL_sample_id c_HSIL_severity*/
data f1_02_HSIL_cyto_e;
set f1_02_HSIL_cyto_e;
rename n_cyto_sample_date=c_HSIL_date n_snomed_worst=c_HSIL_snomed n_sample_id=c_HSIL_sample_id n_snomed_severity=c_HSIL_severity;
c_HSIL=1;
run;

/*find all the CIN3+ and above results*/
data f1_02_CIN3_cyto;
set newcoh.f1_02_af_cyto;
if n_snomed_severity>=12;
keep person_id n_cyto_sample_date n_snomed_worst n_sample_id n_snomed_severity;
where n_cyto_sample_date<='31dec2022'd;
run;
/*find the earliest date of the LSIL diagnosis*/
proc sort data=f1_02_CIN3_cyto;
by person_id n_cyto_sample_date;
run;
proc sort data=f1_02_CIN3_cyto nodupkey out=f1_02_CIN3_cyto_e;
by person_id;
run;
/*NOTE: There were 22 observations read from the data set WORK.F1_02_CIN3_CYTO.
NOTE: 2 observations with duplicate key values were deleted.
NOTE: The data set WORK.F1_02_CIN3_CYTO_E has 20 observations and 5 variables.
*/
/*new variable: c_CIN3 0-no 1-have a diagnosis severer than CIN3 change n_cyto_sample_date to c_CIN3_date c_CIN3_snomed c_CIN3_sample_id c_CIN3_severity*/
data f1_02_CIN3_cyto_e;
set f1_02_CIN3_cyto_e;
rename n_cyto_sample_date=c_CIN3_date n_snomed_worst=c_CIN3_snomed n_sample_id=c_CIN3_sample_id n_snomed_severity=c_CIN3_severity;
c_CIN3=1;
run;

/*find all the cancer*/
*data f1_02_can_cyto;
*set newcoh.f1_02_af_cyto;
*if n_snomed_severity>=13;
*keep person_id n_cyto_sample_date n_snomed_worst n_sample_id n_snomed_severity;
*run;
/*find the earliest date of the LSIL diagnosis*/
*proc sort data=f1_02_can_cyto;
*by person_id n_cyto_sample_date;
*run;
*proc sort data=f1_02_can_cyto nodupkey out=f1_02_can_cyto_e;
*by person_id;
*run;
/*
*/
/*new variable: c_can 0-no 1-have a diagnosis severer than can change n_cyto_sample_date to c_can_date c_can_snomed c_can_sample_id c_can_severity*/
*data f1_02_can_cyto_e;
*set f1_02_can_cyto_e;
*rename n_cyto_sample_date=c_can_date n_snomed_worst=c_can_snomed n_sample_id=c_can_sample_id n_snomed_severity=c_can_severity;
*c_can=1;
*run;
 
/*PAD severity
1---benign
3---ASCUS
4---CIN1 LSIL 
5---CIN2 HSIL 
6---CIN3
9---cancer*/

/*find all the diagnosis severer than LSIL in pad test*/

data f1_02_LSIL_pad;
set newcoh.f1_02_af_pad;
if pad_sev>=4;
where TOPO3='T83' and pad_sample_date<='31dec2022'd;
keep person_id pad_sev TOPO3 pad_class pad_snomed_translated pad_sample_date pad_sample_id;
run;
/*NOTE: There were 1046 observations read from the data set NEWCOH.F1_02_AF_PAD.
      WHERE (TOPO3='T83') and (pad_sample_date<='31DEC2022'D);
NOTE: The data set WORK.F1_02_LSIL_PAD has 384 observations and 7 variables.
*/
/*find the earliest date of the LSIL diagnosis*/
proc sort data=f1_02_LSIL_pad;
by person_id pad_sample_date;
run;
proc sort data=f1_02_LSIL_pad nodupkey out=f1_02_LSIL_pad_e;
by person_id;
run;
/*NOTE: There were 384 observations read from the data set WORK.F1_02_LSIL_PAD.
NOTE: 171 observations with duplicate key values were deleted.
NOTE: The data set WORK.F1_02_LSIL_PAD_E has 213 observations and 7 variables.
*/
/*new variable: p_LSIL 0-no 1-have a diagnosis severer than LSIL change  p_LSIL_date p_LSIL_snomed p_LSIL_sample_id p_LSIL_severity*/
data f1_02_LSIL_pad_e;
set f1_02_LSIL_pad_e;
rename pad_sample_date=p_LSIL_date pad_snomed_translated=p_LSIL_snomed pad_sample_id=p_LSIL_sample_id PAD_SEV=p_LSIL_sev PAD_CLASS=p_LSIL_class TOPO3=p_LSIL_TOPO3;
p_LSIL=1;
run;

/*delete all the label*/
proc datasets lib=work;
modify F1_02_Lsil_pad_e;
attrib _all_ label='';
run;


/*find all the diagnosis severer than HSIL/CIN2 in pad test*/

data f1_02_HSIL_pad;
set newcoh.f1_02_af_pad;
if pad_sev>=5;
where TOPO3='T83' and pad_sample_date<='31Dec2022'd;
keep person_id pad_sev TOPO3 pad_class pad_snomed_translated pad_sample_date pad_sample_id;
run;
/*NOTE: There were 1046 observations read from the data set NEWCOH.F1_02_AF_PAD.
      WHERE (TOPO3='T83') and (pad_sample_date<='31DEC2022'D);
NOTE: The data set WORK.F1_02_HSIL_PAD has 122 observations and 7 variables.
*/
/*find the earliest date of the HSIL diagnosis*/
proc sort data=f1_02_HSIL_pad;
by person_id pad_sample_date;
run;
proc sort data=f1_02_HSIL_pad nodupkey out=f1_02_HSIL_pad_e;
by person_id;
run;
/*NOTE: There were 122 observations read from the data set WORK.F1_02_HSIL_PAD.
NOTE: 37 observations with duplicate key values were deleted.
NOTE: The data set WORK.F1_02_HSIL_PAD_E has 85 observations and 7 variables.
*/
/*new variable: p_HSIL 0-no 1-have a diagnosis severer than HSIL change  p_HSIL_date p_HSIL_snomed p_HSIL_sample_id p_HSIL_severity*/
data f1_02_HSIL_pad_e;
set f1_02_HSIL_pad_e;
rename pad_sample_date=p_HSIL_date pad_snomed_translated=p_HSIL_snomed pad_sample_id=p_HSIL_sample_id PAD_SEV=p_HSIL_sev PAD_CLASS=p_HSIL_class TOPO3=p_HSIL_TOPO3;
p_HSIL=1;
run;

/*delete all the label*/
proc datasets lib=work;
modify F1_02_hsil_pad_e;
attrib _all_ label='';
run;

/*find all the diagnosis severer than CIN3+ in pad test*/

data f1_02_CIN3_pad;
set newcoh.f1_02_af_pad;
if pad_sev>=6;
where TOPO3='T83'and pad_sample_date<='31Dec2022'd;
keep person_id pad_sev TOPO3 pad_class pad_snomed_translated pad_sample_date pad_sample_id;
run;
/*NOTE: There were 1046 observations read from the data set NEWCOH.F1_02_AF_PAD.
      WHERE TOPO3='T83';
NOTE: The data set WORK.F1_02_CIN3_PAD has 79 observations and 7 variables.
*/
/*find the earliest date of the CIN3 diagnosis*/
proc sort data=f1_02_CIN3_pad;
by person_id pad_sample_date;
run;
proc sort data=f1_02_CIN3_pad nodupkey out=f1_02_CIN3_pad_e;
by person_id;
run;
/*NOTE: There were 79 observations read from the data set WORK.F1_02_CIN3_PAD.
NOTE: 25 observations with duplicate key values were deleted.
NOTE: The data set WORK.F1_02_CIN3_PAD_E has 54 observations and 7 variables.
*/
/*new variable: p_CIN3 0-no 1-have a diagnosis severer than CIN3 change  p_CIN3_date p_CIN3_snomed p_CIN3_sample_id p_CIN3_severity*/
data f1_02_CIN3_pad_e;
set f1_02_CIN3_pad_e;
rename pad_sample_date=p_CIN3_date pad_snomed_translated=p_CIN3_snomed pad_sample_id=p_CIN3_sample_id PAD_SEV=p_CIN3_sev PAD_CLASS=p_CIN3_class TOPO3=p_CIN3_TOPO3;
p_CIN3=1;
run;

/*delete all the label*/
proc datasets lib=work;
modify F1_02_cin3_pad_e;
attrib _all_ label='';
run;




/*find all the cancer diagnosis in pad test*/
*data f1_02_can_pad;
*set newcoh.f1_02_af_pad;
*if pad_sev>=9;
*where TOPO3='T83';
*keep person_id pad_sev TOPO3 pad_class pad_snomed_translated pad_sample_date pad_sample_id;
*run;
/*NOTE: There were 1044 observations read from the data set NEWCOH.F1_02_AF_PAD.
      WHERE TOPO3='T83';
NOTE: The data set WORK.F1_02_CAN_PAD has 14 observations and 7 variables
*/
/*find the earliest date of the cancer diagnosis*/
*proc sort data=f1_02_can_pad;
*by person_id pad_sample_date;
*run;
*proc sort data=f1_02_can_pad nodupkey out=f1_02_can_pad_e;
*by person_id;
*run;
/*NOTE: There were 14 observations read from the data set WORK.F1_02_CAN_PAD.
NOTE: 3 observations with duplicate key values were deleted.
NOTE: The data set WORK.F1_02_CAN_PAD_E has 11 observations and 7 variables.
*/
/*new variable: p_can 0-no 1-have a diagnosis severer than cancer change  p_can_date p_can_snomed p_can_sample_id p_can_severity*/
*data f1_02_can_pad_e;
*set f1_02_can_pad_e;
*rename pad_sample_date=p_can_date pad_snomed_translated=p_can_snomed pad_sample_id=p_can_sample_id PAD_SEV=p_can_sev PAD_CLASS=p_can_class TOPO3=p_can_TOPO3;
*p_can=1;
*run;

/*delete all the label*/
*proc datasets lib=work;
*modify F1_02_can_pad_e;
*attrib _all_ label='';
*run;

/*merge all the datasets to f1_02_pop*/
data f1_02_pop;
set newcoh.f1_02_type;
keep person_id even age hpv_sample_date;
rename hpv_sample_date=fas1_sample_date;
run;
*proc sort data=f1_02_can_cyto_e;
*by person_id;
*proc sort data=f1_02_can_pad_e;
*by person_id;
proc sort data=f1_02_cin3_cyto_e;
by person_id;
proc sort data=f1_02_cin3_pad_e;
by person_id;
proc sort data=f1_02_hsil_cyto_e;
by person_id;
proc sort data=f1_02_hsil_pad_e;
by person_id;
proc sort data=f1_02_lsil_cyto_e;
by person_id;
proc sort data=f1_02_lsil_pad_e;
by person_id;
proc sort data=f1_02_pop;
by person_id;
run;

data f1_02_outcomes;
merge f1_02_pop(in=a) f1_02_lsil_cyto_e f1_02_lsil_pad_e f1_02_hsil_cyto_e f1_02_hsil_pad_e f1_02_cin3_cyto_e f1_02_cin3_pad_e; *f1_02_can_cyto_e f1_02_can_pad_e;
by person_id;
if a;
run;
/*NOTE: There were 7318 observations read from the data set WORK.F1_02_POP.
NOTE: There were 176 observations read from the data set WORK.F1_02_LSIL_CYTO_E.
NOTE: There were 213 observations read from the data set WORK.F1_02_LSIL_PAD_E.
NOTE: There were 53 observations read from the data set WORK.F1_02_HSIL_CYTO_E.
NOTE: There were 85 observations read from the data set WORK.F1_02_HSIL_PAD_E.
NOTE: There were 20 observations read from the data set WORK.F1_02_CIN3_CYTO_E.
NOTE: There were 54 observations read from the data set WORK.F1_02_CIN3_PAD_E.
NOTE: The data set WORK.F1_02_OUTCOMES has 7318 observations and 39 variables.

*/
/*replace missing value in c_LSIL p_LSIL c_HSIL p_HSIL c_CIN3 p_CIN3 c_can p_can to 0*/
data f1_02_outcomes;
set f1_02_outcomes;
array outcomes c_LSIL p_LSIL c_HSIL p_HSIL c_CIN3 p_CIN3; *c_can p_can;
do over outcomes;
if outcomes=. then outcomes=0;
end;
run;

/*save the f1_02_outcomes 20231020*/
data newcoh.f1_02_outcomes;
set f1_02_outcomes;
run;

/*correct in 2024/02/05 the follow up ends on 31dec2022*/


/*2023/7/6*/
/*calculate the time interval*/
/*2023/9/14 comment: the LSIL_date was recalulate later, the end of LSIL,HSIL and CIN3 will be the date the participant took the last test*/
/*2023/10/20 the survival time was calculated based on golden standard, here all the code will be commented*/
*data f1_02_followup;
*set f1_02_outcomes;
*if c_LSIL=1 or p_LSIL=1 then LSIL=1;
*else LSIL=0; 
*if p_LSIL=1 then LSIL_date=p_LSIL_date;
*else if p_LSIL=0 and c_LSIL=1 then LSIL_date=c_LSIL_date;
*else if p_LSIL=0 and c_LSIL=0 then LSIL_date='20jan2023'd;
/*hsil*/
*if c_HSIL=1 or p_HSIL=1 then HSIL=1;
*else HSIL=0;
*if p_HSIL=1 then HSIL_date=p_HSIL_date;
*else if p_HSIL=0 and c_HSIL=1 then HSIL_date=c_HSIL_date;
*else if p_HSIL=0 and c_HSIL=0 then HSIL_date='20jan2023'd;
/*cin3*/
*if c_CIN3=1 or p_CIN3=1 then CIN3=1;
*else CIN3=0;
*if p_CIN3=1 then CIN3_date=p_CIN3_date;
*else if p_CIN3=0 and c_CIN3=1 then CIN3_date=c_CIN3_date;
*else if p_CIN3=0 and c_CIN3=0 then CIN3_date='20jan2023'd;
/*can*/
*if c_can=1 or p_can=1 then can=1;
*else can=0;
*if p_can=1 then can_date=p_can_date;
*else if p_can=0 and c_can=1 then can_date=c_can_date;
*else if p_can=0 and c_can=0 then can_date='20jan2023'd;
*format LSIL_date yymmdd10. HSIL_date yymmdd10. CIN3_date yymmdd10. can_date yymmdd10.;
*run;

/*merge with othr information e.g. screening history and deregister to calculate survival time and censor station*/
*proc sort data=f1_02_followup;
*by person_id;
*proc sort data=newcoh.f1_02_pre_d;
*by person_id;
*run;

*data f1_02_data;
*merge newcoh.f1_02_pre_d (in=a) f1_02_followup;
*by person_id;
*run;
*data newcoh.f1_02_data;
*set f1_02_data;
*run;

/*survival time and censor*/
/*status=0---censor status=1----event*/
/*2023/09/14 the censor status was corrected later, any participant didn't end up in a case should be censored at the end of their follow up*/
*data f1_02_pre_d_f;
*set f1_02_data;
/*LSIL_status LSIL_surv_time*/
*if dereg=1 and dereg_date<LSIL_date then LSIL_status=0;
*else LSIL_status=1;
*if dereg=1 and dereg_date<LSIL_date then LSIL_surv_time=(dereg_date-fas1_sample_date)/365.25;
*else  LSIL_surv_time=(LSIL_date-fas1_sample_date)/365.25;
/*HSIL status HSIL_surv_time*/
*if dereg=1 and dereg_date<HSIL_date then HSIL_status=0;
*else HSIL_status=1;
*if dereg=1 and dereg_date<HSIL_date then HSIL_surv_time=(dereg_date-fas1_sample_date)/365.25;
*else  HSIL_surv_time=(HSIL_date-fas1_sample_date)/365.25;
/*cin3 status cin3_surv_time*/
*if dereg=1 and dereg_date<CIN3_date then CIN3_status=0;
*else CIN3_status=1;
*if dereg=1 and dereg_date<CIN3_date then CIN3_surv_time=(dereg_date-fas1_sample_date)/365.25;
*else  CIN3_surv_time=(CIN3_date-fas1_sample_date)/365.25;
/*can status can_surv_time*/
*if dereg=1 and dereg_date<can_date then can_status=0;
*else can_status=1;
*if dereg=1 and dereg_date<can_date then can_surv_time=(dereg_date-fas1_sample_date)/365.25;
*else  can_surv_time=(can_date-fas1_sample_date)/365.25;
*run;

*data newcoh.f1_02_pre_d_f;
*set f1_02_pre_d_f;
*run;
/*merge the fas1 results with f1_02_pre_d_f*/
*data f1_02_fas1;
*set newcoh.f1_02_type;
*keep x_sample_yr even person_id age hpvdiag hpv_severity;
*run;
*proc sort data=f1_02_fas1;
*by person_id;
*proc sort data=f1_02_pre_d_f;
*by person_id;
*run;
*data newcoh.f1_02_analysis;
*merge f1_02_fas1(in=a) newcoh.f1_02_pre_d_f;
*by person_id;
*run;


/*find all the LSIL and above results*/
data f1_12_LSIL_cyto;
set newcoh.f1_12_af_cyto;
if n_snomed_severity>=7;
keep person_id n_cyto_sample_date n_snomed_worst n_sample_id n_snomed_severity;
where n_cyto_sample_date<='31dec2022'd;
run;
/*NOTE: There were 10127 observations read from the data set NEWCOH.F1_12_AF_CYTO.
NOTE: The data set WORK.F1_12_LSIL_CYTO has 239 observations and 5 variables.
*/
/*find the earliest date of the LSIL diagnosis*/
proc sort data=f1_12_LSIL_cyto;
by person_id n_cyto_sample_date;
run;
proc sort data=f1_12_LSIL_cyto nodupkey out=f1_12_LSIL_cyto_e;
by person_id;
run;
/*NOTE: There were 239 observations read from the data set WORK.F1_12_LSIL_CYTO.
NOTE: 84 observations with duplicate key values were deleted.
NOTE: The data set WORK.F1_12_LSIL_CYTO_E has 155 observations and 5 variables.

*/
/*new variable: c_LSIL 0-no 1-have a diagnosis severer than LSIL change n_cyto_sample_date to c_LSIL_date c_LSIL_snomed c_LSIL_sample_id c_LSIL_severity*/
data f1_12_LSIL_cyto_e;
set f1_12_LSIL_cyto_e;
rename n_cyto_sample_date=c_LSIL_date n_snomed_worst=c_LSIL_snomed n_sample_id=c_LSIL_sample_id n_snomed_severity=c_LSIL_severity;
c_LSIL=1;
run;

/*find all the HSIL/CIN2+ and above results*/
data f1_12_HSIL_cyto;
set newcoh.f1_12_af_cyto;
if n_snomed_severity>=11;
keep person_id n_cyto_sample_date n_snomed_worst n_sample_id n_snomed_severity;
where n_cyto_sample_date<='31dec2022'd;
run;
/*NOTE: There were 10127 observations read from the data set NEWCOH.F1_12_AF_CYTO.
NOTE: The data set WORK.F1_12_HSIL_CYTO has 72 observations and 5 variables.
*/
/*find the earliest date of the HSIL diagnosis*/
proc sort data=f1_12_HSIL_cyto;
by person_id n_cyto_sample_date;
run;
proc sort data=f1_12_HSIL_cyto nodupkey out=f1_12_HSIL_cyto_e;
by person_id;
run;
/*NOTE: There were 72 observations read from the data set WORK.F1_12_HSIL_CYTO.
NOTE: 20 observations with duplicate key values were deleted.
NOTE: The data set WORK.F1_12_HSIL_CYTO_E has 52 observations and 5 variables.
*/
/*new variable: c_HSIL 0-no 1-have a diagnosis severer than HSIL change n_cyto_sample_date to c_HSIL_date c_HSIL_snomed c_HSIL_sample_id c_HSIL_severity*/
data f1_12_HSIL_cyto_e;
set f1_12_HSIL_cyto_e;
rename n_cyto_sample_date=c_HSIL_date n_snomed_worst=c_HSIL_snomed n_sample_id=c_HSIL_sample_id n_snomed_severity=c_HSIL_severity;
c_HSIL=1;
run;

/*find all the CIN3+ and above results*/
data f1_12_CIN3_cyto;
set newcoh.f1_12_af_cyto;
if n_snomed_severity>=12;
keep person_id n_cyto_sample_date n_snomed_worst n_sample_id n_snomed_severity;
where n_cyto_sample_date<='31dec2022'd;
run;
/*NOTE: There were 10127 observations read from the data set NEWCOH.F1_12_AF_CYTO.
NOTE: The data set WORK.F1_12_CIN3_CYTO has 40 observations and 5 variables.
*/
/*find the earliest date of the LSIL diagnosis*/
proc sort data=f1_12_CIN3_cyto;
by person_id n_cyto_sample_date;
run;
proc sort data=f1_12_CIN3_cyto nodupkey out=f1_12_CIN3_cyto_e;
by person_id;
run;
/*NOTE: There were 40 observations read from the data set WORK.F1_12_CIN3_CYTO.
NOTE: 11 observations with duplicate key values were deleted.
NOTE: The data set WORK.F1_12_CIN3_CYTO_E has 29 observations and 5 variables.
*/
/*new variable: c_CIN3 0-no 1-have a diagnosis severer than CIN3 change n_cyto_sample_date to c_CIN3_date c_CIN3_snomed c_CIN3_sample_id c_CIN3_severity*/
data f1_12_CIN3_cyto_e;
set f1_12_CIN3_cyto_e;
rename n_cyto_sample_date=c_CIN3_date n_snomed_worst=c_CIN3_snomed n_sample_id=c_CIN3_sample_id n_snomed_severity=c_CIN3_severity;
c_CIN3=1;
run;

/*find all the cancer*/
*data f1_12_can_cyto;
*set newcoh.f1_12_af_cyto;
*if n_snomed_severity>=13;
*keep person_id n_cyto_sample_date n_snomed_worst n_sample_id n_snomed_severity;
*run;
/*NOTE: There were 10127 observations read from the data set NEWCOH.F1_12_AF_CYTO.
NOTE: The data set WORK.F1_12_CAN_CYTO has 9 observations and 5 variables.
*/
/*find the earliest date of the LSIL diagnosis*/
*proc sort data=f1_12_can_cyto;
*by person_id n_cyto_sample_date;
*run;
*proc sort data=f1_12_can_cyto nodupkey out=f1_12_can_cyto_e;
*by person_id;
*run;
/*NOTE: There were 9 observations read from the data set WORK.F1_12_CAN_CYTO.
NOTE: 2 observations with duplicate key values were deleted.
NOTE: The data set WORK.F1_12_CAN_CYTO_E has 7 observations and 5 variables.
*/
/*new variable: c_can 0-no 1-have a diagnosis severer than can change n_cyto_sample_date to c_can_date c_can_snomed c_can_sample_id c_can_severity*/
*data f1_12_can_cyto_e;
*set f1_12_can_cyto_e;
*rename n_cyto_sample_date=c_can_date n_snomed_worst=c_can_snomed n_sample_id=c_can_sample_id n_snomed_severity=c_can_severity;
*c_can=1;
*run;

/*PAD severity
1---benign
3---ASCUS
4---CIN1 LSIL 
5---CIN2 HSIL 
6---CIN3
9---cancer*/

/*find all the diagnosis severer than LSIL in pad test*/

data f1_12_LSIL_pad;
set newcoh.f1_12_af_pad;
if pad_sev>=4;
where TOPO3='T83' and pad_sample_date<='31dec2022'd;
keep person_id pad_sev TOPO3 pad_class pad_snomed_translated pad_sample_date pad_sample_id;
run;
/*NOTE: There were 750 observations read from the data set NEWCOH.F1_12_AF_PAD.
      WHERE TOPO3='T83';
NOTE: The data set WORK.F1_12_LSIL_PAD has 237 observations and 7 variables.
*/
/*find the earliest date of the LSIL diagnosis*/
proc sort data=f1_12_LSIL_pad;
by person_id pad_sample_date;
run;
proc sort data=f1_12_LSIL_pad nodupkey out=f1_12_LSIL_pad_e;
by person_id;
run;
/*NOTE: There were 237 observations read from the data set WORK.F1_12_LSIL_PAD.
NOTE: 91 observations with duplicate key values were deleted.
NOTE: The data set WORK.F1_12_LSIL_PAD_E has 146 observations and 7 variables.
*/
/*new variable: p_LSIL 0-no 1-have a diagnosis severer than LSIL change  p_LSIL_date p_LSIL_snomed p_LSIL_sample_id p_LSIL_severity*/
data f1_12_LSIL_pad_e;
set f1_12_LSIL_pad_e;
rename pad_sample_date=p_LSIL_date pad_snomed_translated=p_LSIL_snomed pad_sample_id=p_LSIL_sample_id PAD_SEV=p_LSIL_sev PAD_CLASS=p_LSIL_class TOPO3=p_LSIL_TOPO3;
p_LSIL=1;
run;

/*delete all the label*/
proc datasets lib=work;
modify F1_12_Lsil_pad_e;
attrib _all_ label='';
run;


/*find all the diagnosis severer than HSIL/CIN2 in pad test*/

data f1_12_HSIL_pad;
set newcoh.f1_12_af_pad;
if pad_sev>=5;
where TOPO3='T83' and pad_sample_date<='31dec2022'd;
keep person_id pad_sev TOPO3 pad_class pad_snomed_translated pad_sample_date pad_sample_id;
run;
/*NOTE: There were 750 observations read from the data set NEWCOH.F1_12_AF_PAD.
      WHERE TOPO3='T83';
NOTE: The data set WORK.F1_12_HSIL_PAD has 122 observations and 7 variables.
*/
/*find the earliest date of the LSIL diagnosis*/
proc sort data=f1_12_HSIL_pad;
by person_id pad_sample_date;
run;
proc sort data=f1_12_HSIL_pad nodupkey out=f1_12_HSIL_pad_e;
by person_id;
run;
/*NOTE: There were 122 observations read from the data set WORK.F1_12_HSIL_PAD.
NOTE: 42 observations with duplicate key values were deleted.
NOTE: The data set WORK.F1_12_HSIL_PAD_E has 80 observations and 7 variables.
*/
/*new variable: p_HSIL 0-no 1-have a diagnosis severer than HSIL change  p_HSIL_date p_HSIL_snomed p_HSIL_sample_id p_HSIL_severity*/
data f1_12_HSIL_pad_e;
set f1_12_HSIL_pad_e;
rename pad_sample_date=p_HSIL_date pad_snomed_translated=p_HSIL_snomed pad_sample_id=p_HSIL_sample_id PAD_SEV=p_HSIL_sev PAD_CLASS=p_HSIL_class TOPO3=p_HSIL_TOPO3;
p_HSIL=1;
run;

/*delete all the label*/
proc datasets lib=work;
modify F1_12_hsil_pad_e;
attrib _all_ label='';
run;

/*find all the diagnosis severer than CIN3+ in pad test*/

data f1_12_CIN3_pad;
set newcoh.f1_12_af_pad;
if pad_sev>=6;
where TOPO3='T83' and pad_sample_date<='31dec2022'd;
keep person_id pad_sev TOPO3 pad_class pad_snomed_translated pad_sample_date pad_sample_id;
run;
/*NOTE: There were 750 observations read from the data set NEWCOH.F1_12_AF_PAD.
      WHERE TOPO3='T83';
NOTE: The data set WORK.F1_12_CIN3_PAD has 96 observations and 7 variables.
*/
/*find the earliest date of the LSIL diagnosis*/
proc sort data=f1_12_CIN3_pad;
by person_id pad_sample_date;
run;
proc sort data=f1_12_CIN3_pad nodupkey out=f1_12_CIN3_pad_e;
by person_id;
run;
/*NOTE: There were 96 observations read from the data set WORK.F1_12_CIN3_PAD.
NOTE: 30 observations with duplicate key values were deleted.
NOTE: The data set WORK.F1_12_CIN3_PAD_E has 66 observations and 7 variables.
*/
/*new variable: p_HSIL 0-no 1-have a diagnosis severer than HSIL change  p_HSIL_date p_HSIL_snomed p_HSIL_sample_id p_HSIL_severity*/
data f1_12_CIN3_pad_e;
set f1_12_CIN3_pad_e;
rename pad_sample_date=p_CIN3_date pad_snomed_translated=p_CIN3_snomed pad_sample_id=p_CIN3_sample_id PAD_SEV=p_CIN3_sev PAD_CLASS=p_CIN3_class TOPO3=p_CIN3_TOPO3;
p_CIN3=1;
run;

/*delete all the label*/
proc datasets lib=work;
modify F1_12_cin3_pad_e;
attrib _all_ label='';
run;




/*find all the cancer diagnosis in pad test*/
*data f1_12_can_pad;
*set newcoh.f1_12_af_pad;
*if pad_sev>=9;
*where TOPO3='T83';
*keep person_id pad_sev TOPO3 pad_class pad_snomed_translated pad_sample_date pad_sample_id;
*run;
/*NOTE: There were 748 observations read from the data set NEWCOH.F1_12_AF_PAD.
      WHERE TOPO3='T83';
NOTE: The data set WORK.F1_12_CAN_PAD has 17 observations and 7 variables.
*/
/*find the earliest date of the LSIL diagnosis*/
*proc sort data=f1_12_can_pad;
*by person_id pad_sample_date;
*run;
*proc sort data=f1_12_can_pad nodupkey out=f1_12_can_pad_e;
*by person_id;
*run;
/*NOTE: There were 17 observations read from the data set WORK.F1_12_CAN_PAD.
NOTE: 4 observations with duplicate key values were deleted.
NOTE: The data set WORK.F1_12_CAN_PAD_E has 13 observations and 7 variables.
*/
/*new variable: p_HSIL 0-no 1-have a diagnosis severer than HSIL change  p_HSIL_date p_HSIL_snomed p_HSIL_sample_id p_HSIL_severity*/
*data f1_12_can_pad_e;
*set f1_12_can_pad_e;
*rename pad_sample_date=p_can_date pad_snomed_translated=p_can_snomed pad_sample_id=p_can_sample_id PAD_SEV=p_can_sev PAD_CLASS=p_can_class TOPO3=p_can_TOPO3;
*p_can=1;
*run;

/*delete all the label*/
*proc datasets lib=work;
*modify F1_12_can_pad_e;
*attrib _all_ label='';
*run;

/*merge all the datasets to f1_12_pop*/
data f1_12_pop;
set newcoh.f1_12;
keep person_id even cyto_sample_date;
rename cyto_sample_date=fas1_sample_date;
run;
*proc sort data=f1_12_can_cyto_e;
*by person_id;
*proc sort data=f1_12_can_pad_e;
*by person_id;
proc sort data=f1_12_cin3_cyto_e;
by person_id;
proc sort data=f1_12_cin3_pad_e;
by person_id;
proc sort data=f1_12_hsil_cyto_e;
by person_id;
proc sort data=f1_12_hsil_pad_e;
by person_id;
proc sort data=f1_12_lsil_cyto_e;
by person_id;
proc sort data=f1_12_lsil_pad_e;
by person_id;
proc sort data=f1_12_pop;
by person_id;
run;

data f1_12_outcomes;
merge f1_12_pop(in=a) f1_12_lsil_cyto_e f1_12_lsil_pad_e f1_12_hsil_cyto_e f1_12_hsil_pad_e f1_12_cin3_cyto_e f1_12_cin3_pad_e;* f1_12_can_cyto_e f1_12_can_pad_e;
by person_id;
if a;
run;
/*NOTE: There were 7401 observations read from the data set WORK.F1_12_POP.
NOTE: There were 155 observations read from the data set WORK.F1_12_LSIL_CYTO_E.
NOTE: There were 146 observations read from the data set WORK.F1_12_LSIL_PAD_E.
NOTE: There were 52 observations read from the data set WORK.F1_12_HSIL_CYTO_E.
NOTE: There were 80 observations read from the data set WORK.F1_12_HSIL_PAD_E.
NOTE: There were 29 observations read from the data set WORK.F1_12_CIN3_CYTO_E.
NOTE: There were 66 observations read from the data set WORK.F1_12_CIN3_PAD_E.

*/
/*replace missing value in c_LSIL p_LSIL c_HSIL p_HSIL c_CIN3 p_CIN3 c_can p_can to 0*/
data f1_12_outcomes;
set f1_12_outcomes;
array outcomes c_LSIL p_LSIL c_HSIL p_HSIL c_CIN3 p_CIN3; *c_can p_can;
do over outcomes;
if outcomes=. then outcomes=0;
end;
run;

/*save the f1_12_outcomes 20231020*/
data newcoh.f1_12_outcomes;
set f1_12_outcomes;
run;

/*the latest sample date is 20jan2023*/

/*calculate the time interval*/
/*2023/09/14 the time interval is recalculate on 230816 program*/
*data f1_12_followup;
*set f1_12_outcomes;
*if c_LSIL=1 or p_LSIL=1 then LSIL=1;
*else LSIL=0;
*if p_LSIL=1 then LSIL_date=p_LSIL_date;
*else if p_LSIL=0 and c_LSIL=1 then LSIL_date=c_LSIL_date;
*else if p_LSIL=0 and c_LSIL=0 then LSIL_date='20jan2023'd;
/*hsil*/
*if c_HSIL=1 or p_HSIL=1 then HSIL=1;
*else HSIL=0;
*if p_HSIL=1 then HSIL_date=p_HSIL_date;
*else if p_HSIL=0 and c_HSIL=1 then HSIL_date=c_HSIL_date;
*else if p_HSIL=0 and c_HSIL=0 then HSIL_date='20jan2023'd;
/*cin3*/
*if c_CIN3=1 or p_CIN3=1 then CIN3=1;
*else CIN3=0;
*if p_CIN3=1 then CIN3_date=p_CIN3_date;
*else if p_CIN3=0 and c_CIN3=1 then CIN3_date=c_CIN3_date;
*else if p_CIN3=0 and c_CIN3=0 then CIN3_date='20jan2023'd;
/*can*/
*if c_can=1 or p_can=1 then can=1;
*else can=0;
*if p_can=1 then can_date=p_can_date;
*else if p_can=0 and c_can=1 then can_date=c_can_date;
*else if p_can=0 and c_can=0 then can_date='20jan2023'd;
*format LSIL_date yymmdd10. HSIL_date yymmdd10. CIN3_date yymmdd10. can_date yymmdd10.;
*run;

/*merge with othr information e.g. screening history and deregister to calculate survival time and censor station*/
*proc sort data=f1_12_followup;
*by person_id;
*proc sort data=newcoh.f1_12_pre_d;
*by person_id;
*run;

*data f1_12_data;
*merge newcoh.f1_12_pre_d (in=a) f1_12_followup;
*by person_id;
*run;
*data newcoh.f1_12_data;
*set f1_12_data;
*run;

/*survival time and censor*/
/*status=0---censor status=1----event*/
/*2023/09/14 the censor status is redefined in 230816 program*/
*data f1_12_pre_d_f;
*set f1_12_data;
/*LSIL_status LSIL_surv_time*/
*if dereg=1 and dereg_date<LSIL_date then LSIL_status=0;
*else LSIL_status=1;
*if dereg=1 and dereg_date<LSIL_date then LSIL_surv_time=(dereg_date-fas1_sample_date)/365.25;
*else  LSIL_surv_time=(LSIL_date-fas1_sample_date)/365.25;
/*HSIL status HSIL_surv_time*/
*if dereg=1 and dereg_date<HSIL_date then HSIL_status=0;
*else HSIL_status=1;
*if dereg=1 and dereg_date<HSIL_date then HSIL_surv_time=(dereg_date-fas1_sample_date)/365.25;
*else  HSIL_surv_time=(HSIL_date-fas1_sample_date)/365.25;
/*cin3 status cin3_surv_time*/
*if dereg=1 and dereg_date<CIN3_date then CIN3_status=0;
*else CIN3_status=1;
*if dereg=1 and dereg_date<CIN3_date then CIN3_surv_time=(dereg_date-fas1_sample_date)/365.25;
*else  CIN3_surv_time=(CIN3_date-fas1_sample_date)/365.25;
/*can status can_surv_time*/
*if dereg=1 and dereg_date<can_date then can_status=0;
*else can_status=1;
*if dereg=1 and dereg_date<can_date then can_surv_time=(dereg_date-fas1_sample_date)/365.25;
*else  can_surv_time=(can_date-fas1_sample_date)/365.25;
*run;

*data newcoh.f1_12_pre_d_f;
*set f1_12_pre_d_f;
*run;
/*merge the fas1 results with f1_12_pre_d_f*/
*data f1_12_fas1;
*set newcoh.f1_12;
*keep x_sample_yr even person_id snomed_severity;
*run;
*proc sort data=f1_12_fas1;
*by person_id;
*proc sort data=f1_12_pre_d_f;
*by person_id;
*run;
*data newcoh.f1_12_analysis;
*merge f1_12_fas1(in=a) newcoh.f1_12_pre_d_f;
*by person_id;
*run;

/*match the age for f1_12*/
data age;
set v_ncsr.nkc_cell_6922;
keep person_id age x_sample_date;
where x_sample_yr IN (2012 2013 2014);
run;
data age;
set age;
sample_date=datepart(x_sample_date);
format sample_date yymmdd10.;
drop x_sample_date;
run;
proc sort data=f1_12_pop;
by person_id;
proc sort data=age;
by person_id;
run;
data age;
merge f1_12_pop(in=a) age(in=b);
by person_id;
if a;
if fas1_sample_date=sample_date;
run;
proc sort data=age nodupkey;
by person_id;
run;
data age;
set age;
drop fas1_sample_date sample_date even;
run;

data newcoh.f1_12_outcomes;
merge age(in=a) newcoh.f1_12_outcomes(in=b);
by person_id;
if b;
run;

data newcoh.outcomes;
set newcoh.f1_02_outcomes newcoh.f1_12_outcomes;
run;


/*2023/10/20 bith cohort was update, the code will be commented*/
/*confounder: birth cohort
devide the population in two birth cohort
(1)1951-1954 (2)1955-1958
based on age and sample yr*/
*data newcoh.analysis;
*set newcoh.analysis;
*if x_sample_yr=2012 and age>=58 then birth_cohort=1;
*else if x_sample_yr=2012 then birth_cohort=2;
*else if x_sample_yr=2013 and age>=59 then birth_cohort=1;
*else if x_sample_yr=2013 then birth_cohort=2;
*else if x_sample_yr=2014 and age>=60 then birth_cohort=1;
*else if x_sample_yr=2014 then birth_cohort=2;
*run;
*proc freq data=newcoh.analysis;
*tables birth_cohort;
*run;
/*birth_cohort Frequency Percent Cumulative
Frequency Cumulative
Percent 
1 4710 32.00 4710 32.00 
2 10009 68.00 14719 100.00 
*/
/*excluding women with hysterectomy before fas1 test*/

/*2023/10/20 this process repeated in later code, so commented out here */
*data analysis;
*set newcoh.analysis;
*exlude=dereg_date-fas1_sample_date;
*run;
*data analysis;
*set analysis;
*if .<exlude<0 then delete;
*drop exlude;
*run;
/*
NOTE: There were 14719 observations read from the data set WORK.ANALYSIS.
NOTE: The data set WORK.ANALYSIS has 14716 observations and 94 variables.
*/
*data newcoh.analysis;
*set analysis;
*run;



