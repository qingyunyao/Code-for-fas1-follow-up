

/*File name..: Fas1 follow up population */
/*Study......: Phd project study 1 the efficiency of hpv as primary test among post-menopause women (56-61)*/
/*Author.....: Qingyun Yao*/
/*Date.......: 2023/12/5*/
/*Updated....: */
/*Purpose....: generate table 1*/
/*Note.......: 
*/
*------------------------------------------------------------------------;
/* Data used...:
libname NCSR  odbc complete="server=meb-sql02.meb.ki.se;driver=SQL Server Native Client 11.0;Trusted_Connection=Yes;database=NCSR" schema=NCSR ;
libname V_NCSR     odbc complete="server=meb-sql02.meb.ki.se;driver=SQL Server Native Client 11.0;Trusted_Connection=Yes;database=NCSR" schema=V_NCSR ;
libname fas1 'P:\ACCES\ACCES_Research\Qingyun\Fas1_Followup\Data\0531';
libname newcoh 'P:\ACCES\ACCES_Research\Qingyun\Fas1_Followup\Data\newcohort';
/* Data created.:  */
/*sas version.: SAS9.4*/
/*main program*/
proc datasets kill;quit;
libname newcoh 'P:\ACCES\ACCES_Research\Qingyun\Fas1_Followup\Data\newcohort';

proc sql;
create table table1_stat as
select even, group_n, person_id, case when group_n=2 or group_n=4 then 0 else 1 end as fas1_result
,pre_pad_HSIL, birth_year, fas1_sample_date, nr_test_all, nr_cyto, nr_hpv, nr_nscreen_test, nr_screen_test,eof_HSIL_date,
p_LSIL, p_HSIL, cancer, LSIL_sur_time, HSIL_sur_time, eof_cancer, can_sur_time, year(fas1_sample_date)-birth_year as age_fas1, year(eof_HSIL_date)-birth_year as age_HSIL,
year(eof_cancer)-birth_year as age_cancer, pre_abn, pre_LSIL, pre_HSIL from newcoh.analysis_0205;
quit;
/*create a work dateset with all the variables we need in the baseline characteristics table*/

proc summary data=table1_stat;
var age_fas1 age_HSIL age_cancer HSIL_sur_time can_sur_time nr_test_all nr_cyto nr_hpv nr_nscreen_test nr_screen_test fas1_result pre_abn pre_LSIL pre_HSIL;
output out=table1_even sum(pre_abn pre_LSIL pre_HSIL fas1_result)= mean(age_fas1 age_HSIL age_cancer pre_abn pre_LSIL pre_HSIL fas1_result)= std(age_fas1 age_HSIL age_cancer)=
median(HSIL_sur_time can_sur_time nr_test_all nr_cyto nr_hpv nr_nscreen_test nr_screen_test)= 
q1(HSIL_sur_time can_sur_time nr_test_all nr_cyto nr_hpv nr_nscreen_test nr_screen_test)= 
q3(HSIL_sur_time can_sur_time nr_test_all nr_cyto nr_hpv nr_nscreen_test nr_screen_test)=
min(nr_test_all nr_cyto nr_hpv nr_nscreen_test nr_screen_test)= 
max(nr_test_all nr_cyto nr_hpv nr_nscreen_test nr_screen_test)=/autoname;
class group_n even;
run;
/*calculated the needed statistics*/
data table1_organize;
format cat $30.;
set table1_even;
if group_n=. and even=. then cat='ALL population';
else if group_n=1 and even=. then cat='HPV Positive';
else if group_n=2 and even=. then cat='HPV Negative';
else if group_n=3 and even=. then cat='Cytology Positive';
else if group_n=4 and even=.  then cat='Cytology Negative';
else if even=0 then cat='Cytology';
else if even=1 then cat='HPV';
if _TYPE_=3 then delete;
rename _FREQ_=N;
keep cat _FREQ_ age_fas1 age_HSIL age_cancer HSIL_fu_year can_fu_year nr_all_test nr_cyto nr_hpv nr_screen nr_nscreen fas1_result
pre_abn pre_LSIL pre_HSIL;
age_fas1=cat(compress(put(age_fas1_mean,8.2)),' (', compress(put(age_fas1_stddev,8.2)),')');
age_HSIL=cat(compress(put(age_HSIL_mean,8.2)),' (', compress(put(age_HSIL_stddev,8.2)),')');
age_cancer=cat(compress(put(age_cancer_mean,8.2)),' (', compress(put(age_cancer_stddev,8.2)),')');
HSIL_fu_year=cat(compress(put(HSIL_sur_time_median,8.2)),' (', compress(put(HSIL_sur_time_Q1,8.2)),'-',compress(put(HSIL_sur_time_Q3,8.2)),')');
can_fu_year=cat(compress(put(can_sur_time_median,8.2)),' (', compress(put(can_sur_time_Q1,8.2)),'-',compress(put(can_sur_time_Q3,8.2)),')');
nr_all_test=cat(compress(put(nr_test_all_median,8.0)),' (', compress(put(nr_test_all_min,8.0)),'-',compress(put(nr_test_all_max,8.0)),')');
nr_cyto=cat(compress(put(nr_cyto_median,8.0)),' (', compress(put(nr_cyto_min,8.0)),'-',compress(put(nr_cyto_max,8.0)),')');
nr_hpv=cat(compress(put(nr_hpv_median,8.0)),' (', compress(put(nr_hpv_min,8.0)),'-',compress(put(nr_hpv_max,8.0)),')');
nr_screen=cat(compress(put(nr_screen_test_median,8.0)),' (', compress(put(nr_screen_test_min,8.0)),'-',compress(put(nr_screen_test_max,8.0)),')');
nr_nscreen=cat(compress(put(nr_nscreen_test_median,8.0)),' (', compress(put(nr_nscreen_test_min,8.0)),'-',compress(put(nr_nscreen_test_max,8.0)),')');
fas1_result=cat(compress(put(fas1_result_sum,8.0)),' (', compress(put(fas1_result_mean*100,8.1)),'%)');
pre_abn=cat(compress(put(pre_abn_sum,8.0)),' (', compress(put(pre_abn_mean*100,8.2)),'%)');
pre_LSIL=cat(compress(put(pre_LSIL_sum,8.0)),' (', compress(put(pre_LSIL_mean*100,8.2)),'%)');
pre_HSIL=cat(compress(put(pre_HSIL_sum,8.0)),' (', compress(put(pre_HSIL_mean*100,8.2)),'%)');
run;
/*formating*/
proc transpose data=table1_organize out=table1_trans;
var N age_fas1 age_HSIL age_cancer HSIL_fu_year can_fu_year nr_all_test nr_cyto nr_hpv nr_screen nr_nscreen fas1_result
pre_abn pre_LSIL pre_HSIL;
id cat;
run;

proc summary data=table1_stat;
var hsil_sur_time  p_HSIL ;
output out=IR_HSIL sum()=/autoname;
where pre_pad_HSIL=0;
class group_n even;
run;

proc summary data=table1_stat;
var  can_sur_time  cancer;
output out=IR_cancer sum()=/autoname;
class group_n even;
run;
proc sql;
create table IRs as select
a.*, b.hsil_sur_time_sum, b.p_HSIL_sum from ir_cancer as a, ir_hsil as b where a.group_n=b.group_n and a.even=b.even;
quit;
data table1_IR;
format cat $30.;
set IRs;
if group_n=. and even=. then cat='ALL population';
else if group_n=1 and even=. then cat='HPV Positive';
else if group_n=2 and even=. then cat='HPV Negative';
else if group_n=3 and even=. then cat='Cytology Positive';
else if group_n=4 and even=.  then cat='Cytology Negative';
else if even=0 then cat='Cytology';
else if even=1 then cat='HPV';
if _TYPE_=3 then delete;
keep cat HSIL Cancer;
HSIL_IR= (p_HSIL_sum/HSIL_sur_time_sum)*100000;
Low_HSIL=exp(log(p_HSIL_sum/HSIL_sur_time_sum)-1.96*(1/sqrt(p_HSIL_sum)))*100000;
High_HSIL=exp(log(p_HSIL_sum/HSIL_sur_time_sum)+1.96*(1/sqrt(p_HSIL_sum)))*100000;
HSIL=cat(compress(put(HSIL_IR,8.2)),' (',compress(put(low_HSIL,8.2)),', ',compress(put(high_hsil,8.2)),')');
can_IR= (cancer_sum/can_sur_time_sum)*100000;
Low_can=exp(log(cancer_sum/can_sur_time_sum)-1.96*(1/sqrt(cancer_sum)))*100000;
High_can=exp(log(cancer_sum/can_sur_time_sum)+1.96*(1/sqrt(cancer_sum)))*100000;
cancer=cat(compress(put(can_IR,8.2)),' (',compress(put(low_can,8.2)),', ',compress(put(high_can,8.2)),')');
run;

proc transpose data=table1_ir out=table1_trans_ir;
var HSIL cancer;
id cat;
run;
/*calculate Cumulative incidence*/

ods exclude ProductLimitEstimates;
proc lifetest data=newcoh.analysis_1020 nelson
plot=(survival) outsurv= can_sur_even ;
time can_sur_time*cancer(0);
strata even/test=all;
title 'survival analysis for cancer between fas1 screening method';
*ods output ProductLimitEstimates=can_sur_all;
run;

ods exclude ProductLimitEstimates;
proc lifetest data=newcoh.analysis_1020 nelson
plot=(survival) outsurv= can_sur_group ;
time can_sur_time*cancer(0);
strata group_n/test=all;
title 'survival analysis for cancer between fas1 screening method';
*ods output ProductLimitEstimates=can_sur_all;
run;

ods exclude ProductLimitEstimates;
proc lifetest data=newcoh.analysis_1020 nelson
plot=(survival) outsurv= can_sur_all ;
time can_sur_time*cancer(0);
*strata group_n/test=all;
*title 'survival analysis for cancer between fas1 screening method';
*ods output ProductLimitEstimates=can_sur_all;
run;

data can_sur_even;
set can_sur_even;
where _censor_=0 and can_sur_time<=7;
run;
data can_sur_group;
set can_sur_group;
where _censor_=0 and can_sur_time<=7;
run;
data can_sur_all;
set can_sur_all;
where _censor_=0 and can_sur_time<=7;
run;

proc sort data=can_sur_even nodupkey; by even descending can_sur_time;run;
proc sort data=can_sur_group nodupkey; by group_n descending can_sur_time;run;
proc sort data=can_sur_all nodupkey; by descending can_sur_time;run;

proc sort data=can_sur_even nodupkey; by even;run;
proc sort data=can_sur_group nodupkey; by group_n;run;
proc sort data=can_sur_all nodupkey;by _censor_;run;

data sur_pro;
format cat $30.;
set can_sur_even can_sur_group can_sur_all;
if group_n=. and even=. then cat='ALL population';
else if group_n=1 and even=. then cat='HPV Positive';
else if group_n=2 and even=. then cat='HPV Negative';
else if group_n=3 and even=. then cat='Cytology Positive';
else if group_n=4 and even=.  then cat='Cytology Negative';
else if even=0 then cat='Cytology';
else if even=1 then cat='HPV';
can_cum_I=cat(compress(put((1-survival)*100,8.2)),'% (', compress(put((1-sdf_ucL)*100,8.2)),'%, ',compress(put((1-sdf_lcL)*100,8.2)),'%)');
keep cat can_cum_I;
run;

proc transpose data=sur_pro out=table1_sur_trans;
var can_cum_I;
id cat;
run;
/*calculate survival probability*/
data table_1;
set table1_trans table1_trans_ir table1_sur_trans;
run;
%let mydir=P:\ACCES\ACCES_Research\Qingyun\Fas1_Followup\Documents\;
ods rtf file="&mydir.table1_&sysdate..rtf";
proc print data=table_1 noobs;run;
ods rtf close;
/*export results*/



data sample_yr;
set table1_stat;
sample_yr=year(fas1_sample_date);
keep group_n sample_yr even;
run;

proc freq data=sample_yr;
tables sample_yr*group_n sample_yr*even;
run;
