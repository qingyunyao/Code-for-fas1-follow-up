/*File name..: Fas1 follow up population */
/*Study......: Phd project study 1 the efficiency of hpv as primary test among post-menopause women (56-61)*/
/*Author.....: Qingyun Yao*/
/*Date.......: 2023/09/15*/
/*Updated....: 2023-09-28 correct the flow chart number*/
/*Purpose....: generate statistics for flow chart and baseline characteristics*/
/*Note.......: 
*/
*------------------------------------------------------------------------;
/* Data used...:V_ncsr.nkc_cell_6922 V_ncsr.nkc_hpv V_ncsr.nkc_trans_cell V_ncsr.nkc_pad_translated fas1.fas1_pop_withdup_jw20230524
libname NCSR  odbc complete="server=meb-sql02.meb.ki.se;driver=SQL Server Native Client 11.0;Trusted_Connection=Yes;database=NCSR" schema=NCSR ;
libname V_NCSR     odbc complete="server=meb-sql02.meb.ki.se;driver=SQL Server Native Client 11.0;Trusted_Connection=Yes;database=NCSR" schema=V_NCSR ;
libname fas1 'P:\ACCES\ACCES_Research\Qingyun\Fas1_Followup\Data\0531';
libname newcoh 'P:\ACCES\ACCES_Research\Qingyun\Fas1_Followup\Data\newcohort';
/* Data created.:  */
/*sas version.: SAS9.4*/
/*main program*/

libname NCSR  odbc complete="server=meb-sql02.meb.ki.se;driver=SQL Server Native Client 11.0;Trusted_Connection=Yes;database=NCSR" schema=NCSR ;
libname V_NCSR     odbc complete="server=meb-sql02.meb.ki.se;driver=SQL Server Native Client 11.0;Trusted_Connection=Yes;database=NCSR" schema=V_NCSR ;
libname fas1 'P:\ACCES\ACCES_Research\Qingyun\Fas1_Followup\Data\0531';
libname newcoh 'P:\ACCES\ACCES_Research\Qingyun\Fas1_Followup\Data\newcohort';
libname cancer 'P:\ACCES\ACCES_Research\Qingyun\Fas1_Followup\Data';


/*flow chart*/
/*whole population: women aged 56-61 in 2012-2014 and living in stockholm*/
proc freq data=fas1.fas1_pop_withdup_jw20230524;
tables x_sample_yr even;
run;
/*even Frequency Percent Cumulative
Frequency Cumulative
Percent 
0 104438 50.28 104438 50.28 
1 103278 49.72 207716 100.00 
*/
data invitation;
set fas1.fas1_pop_withdup_jw20230524;
run;

proc sort data=invitation;
by person_id;
run;

proc sort data=invitation nodupkey out=invitation_ndk;
by person_id;
run;
/*NOTE: There were 207716 observations read from the data set WORK.INVITATION.
NOTE: 114076 observations with duplicate key values were deleted.
NOTE: The data set WORK.INVITATION_NDK has 93640 observations and 5 variables.
*/


/*women invited between 2012,1,1-2014,5,31*/
data inv_1214;
set v_ncsr.nkc_inv_9322;
where inv_year in ('2011' '2012' '2013' '2014');
run;

data inv_1214;
set inv_1214;
inv_date_n=datepart(x_inv_date);
format inv_date_n yymmdd10.;
run;

/*buffer time 3 months*/
data inv_1214_3;
set inv_1214;
where '01Oct2011'd<inv_date_n<'31may2014'd;/*change the buffer time to 3 month 6 month 1 years */
run;

proc sort data=inv_1214_3;
by person_id;
run;

data inv;
merge invitation_ndk(in=a) inv_1214_3(in=b);
by person_id;
if a and b;
run;

proc sort data=inv;
by person_id;
proc sort data=inv nodupkey;
by person_id;
run;

/*NOTE: There were 74039 observations read from the data set WORK.INV.
NOTE: 31607 observations with duplicate key values were deleted.
NOTE: The data set WORK.INV has 42432 observations and 22 variables.
*/


proc freq data=inv;
tables even;
run;
/*even Frequency Percent Cumulative
Frequency Cumulative
Percent 
0 21279 50.15 21279 50.15 
1 21153 49.85 42432 100.00 
*/








/*women participate in fas1 screening*/
proc freq data=newcoh.f1_02;
tables even;
proc freq data=newcoh.f1_12;
tables even;
run;
/*
hpv  7318 
cytological test 7401
*/
proc freq data=newcoh.analysis_0205;
tables even;
run;
/*
cyt 7400 50.29 7400 50.29 
hpv 7313 49.71 14716 100.00 
*/
proc freq data=newcoh.analysis_0205;
tables even*pre_abn even*pre_LSIL even*pre_HSIL;
run;

proc freq data=newcoh.analysis_0205;
tables hpvdiag*pre_abn hpvdiag*pre_LSIL hpvdiag*pre_HSIL;
run;
proc freq data=newcoh.analysis_0205;
tables cytdiag*pre_abn cytdiag*pre_LSIL cytdiag*pre_HSIL;
run;


proc freq data=newcoh.analysis_0205;
tables p_LSIL*pre_abn p_LSIL*pre_LSIL p_LSIL*pre_HSIL;
where cytdiag="NEG";
run;

proc freq data=newcoh.analysis_0205;
tables p_HSIL*pre_abn p_HSIL*pre_LSIL p_HSIL*pre_HSIL;
where cytdiag="NEG";
run;
proc freq data=newcoh.analysis_0205;
tables cancer*pre_abn cancer*pre_LSIL cancer*pre_HSIL;
where cytdiag="NEG" ;
run;

proc freq data=newcoh.analysis_0205;
tables p_LSIL*pre_abn p_LSIL*pre_LSIL p_LSIL*pre_HSIL;
where cytdiag="POS" ;
run;

proc freq data=newcoh.analysis_0205;
tables p_HSIL*pre_abn p_HSIL*pre_LSIL p_HSIL*pre_HSIL;
where cytdiag="POS";
run;
proc freq data=newcoh.analysis_0205;
tables cancer*pre_abn cancer*pre_LSIL cancer*pre_HSIL;
where cytdiag="POS";
run;

proc freq data=newcoh.analysis_0205;
tables p_LSIL*pre_abn p_LSIL*pre_LSIL p_LSIL*pre_HSIL;
where hpvdiag="POS";
run;

proc freq data=newcoh.analysis_0205;
tables p_HSIL*pre_abn p_HSIL*pre_LSIL p_HSIL*pre_HSIL;
where hpvdiag="POS" ;
run;
proc freq data=newcoh.analysis_0205;
tables cancer*pre_abn cancer*pre_LSIL cancer*pre_HSIL;
where hpvdiag="POS";
run;


proc freq data=newcoh.analysis_0205;
tables p_LSIL*pre_abn p_LSIL*pre_LSIL p_LSIL*pre_HSIL;
where hpvdiag="NEG";
run;

proc freq data=newcoh.analysis_0205;
tables p_HSIL*pre_abn p_HSIL*pre_LSIL p_HSIL*pre_HSIL;
where hpvdiag="NEG";
run;
proc freq data=newcoh.analysis_0205;
tables cancer*pre_abn cancer*pre_LSIL cancer*pre_HSIL;
where hpvdiag="NEG";
run;

