/*File name..: Fas1 follow up population */
/*Study......: Phd project study 1 the efficiency of hpv as primary test among post-menopause women (56-61)*/
/*Author.....: Qingyun Yao*/
/*Date.......: 2023/12/5*/
/*Updated....: */
/*Purpose....: generate table 2, follow up participation*/
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
libname newcoh 'P:\ACCES\ACCES_Research\Qingyun\Fas1_Followup\Data\newcohort';
data negative_fu;
set newcoh.analysis_scr_test_0206;
if group=:'CYT' then even=0;
if group=:'HPV' then even=1;
where negative^='';
keep person_id even group fas1_sample_date fu_test_date_1;
run;
data positive_fu;
set newcoh.analysis_pos_fu_scr_0206;
keep person_id even group fas1_sample_date fu_test_date_1;
run;
/*create dataset needed to generate participation*/
data fu;
set negative_fu positive_fu;
yr_dif=(fu_test_date_1-fas1_sample_date)/365.25;
if .<yr_dif<=3 then fu_3=1; else fu_3=0;
if .<yr_dif<=6 then fu_6=1; else fu_6=0;
if .<yr_dif<=10 then fu_10=1; else fu_10=0;
if fu_test_date_1>. then fu=1;else fu=0;
run;
/*time point guideline 1.5 years interval 2. the whole follow up is about 10 years*/
proc freq data=fu;
tables fu*even/chisq;
where group IN ('HPV_N' 'CYT_N');
run;
proc summary data=fu;
var fu_3 fu_6 fu_10 fu;
class group;
output out=table2_stat_result sum()= mean()=/autoname;
run;
proc summary data=fu;
var fu_3 fu_6 fu_10 fu;
class even;
output out=table2_stat_even sum()= mean()=/autoname;
run;

data table2_stat;
set  table2_stat_even table2_stat_result;
run;

data table_2;
format cat $30.;
set table2_stat;
if even=. and group=. then cat='All population';
if even=0 then cat='Primary Cytology';
else if even=1 then cat='Primary HPV';
if group='CYT_N' then cat='Cytology Negative';
else if group='CYT_P' then cat='Cytology Positive';
else if group='HPV_N' then cat='HPV Negative';
else if group='HPV_P' then cat='HPV Positive';
Within_3_years=cat(compress(put(fu_3_sum,8.0)),' (', compress(put(fu_3_mean*100,8.2)),'%)');
Within_6_years=cat(compress(put(fu_6_sum,8.0)),' (', compress(put(fu_6_mean*100,8.2)),'%)');
Within_10_years=cat(compress(put(fu_10_sum,8.0)),' (', compress(put(fu_10_mean*100,8.2)),'%)');
whole_fu=cat(compress(put(fu_sum,8.0)),' (', compress(put(fu_mean*100,8.2)),'%)');
keep cat within_3_years within_6_years within_10_years whole_fu;
run;

proc sort data=table_2 nodupkey; by cat;
run; 

/*test if there is a difference in follow-up participation among primary HPV and primary Cytology group*/
proc freq data=fu;
table even*fu_3 even*fu_6 even*fu_10 even*fu/chisq norow nocol;
run;

proc freq data=fu;
table group*fu_3 group*fu_6 group*fu_10 group*fu/chisq norow nocol;
where group IN ('HPV_P' 'CYT_P');
run;
proc freq data=fu;
table group*fu_3 group*fu_6 group*fu_10 group*fu/chisq norow nocol;
where group IN ('HPV_N' 'CYT_N');
run;



%let mydir=P:\ACCES\ACCES_Research\Qingyun\Fas1_Followup\Documents\;
ods rtf file="&mydir.table2_&sysdate..rtf";
proc print data=table_2 noobs;run;
ods rtf close;
