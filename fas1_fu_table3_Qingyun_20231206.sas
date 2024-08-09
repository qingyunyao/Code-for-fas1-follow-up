/*File name..: Fas1 follow up population */
/*Study......: Phd project study 1 the efficiency of hpv as primary test among post-menopause women (56-61)*/
/*Author.....: Qingyun Yao*/
/*Date.......: 2023/12/5*/
/*Updated....: */
/*Purpose....: generate table 3.longitudinal characteristics*/
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
/*get the data that needed for the analysis*/
data longitudinal;
set newcoh.analysis_0205;
if pre_pad_HSIL=0;
keep person_id group p_HSIL HSIL_sur_time p_HSIL;
rename HSIL_sur_time=HSIL_sur_time;
run;
/*get the survival probability and std for each time point*/
ods exclude ProductLimitEstimates;
proc lifetest data=longitudinal nelson
plot=(survival) outsurv=sur_pro_detail;
time HSIL_sur_time*p_HSIL(0);
strata group/test=all;
ods output ProductLimitEstimates=Sur_pro;
run;
data sur_pro;
set sur_pro;
where censor=0;
run;
data sur_pro_detail;
set sur_pro_detail;
where _censor_=0;
run;
option nomlogic nomprint;
%macro SurPro(year);
data sur_&year.;
set sur_pro_detail;
where hsil_sur_time<=&year. and survival>.;
run;
data sur_&year._1;
set sur_pro;
where hsil_sur_time<=&year.;
run;
proc sort data=sur_&year.;by group descending HSIL_sur_time;run;
proc sort data=sur_&year. nodupkey; by group; run;
data sur_&year._pro;
set sur_&year.;
rename survival=survival_&year. ;
keep group survival;
run;
proc sort data=sur_&year._1;by group descending HSIL_sur_time;run;
proc sort data=sur_&year._1 nodupkey; by group; run;
data sur_&year._err;
set sur_&year._1;
rename stderr=stderr_&year.;
keep group stderr;
run;
data sur_&year._pro_err;
merge sur_&year._pro sur_&year._err;
by group;
run;
%mend;
%surpro(3)
%surpro(5)
%surpro(7)
%surpro(10)



/*merge the sur_pro with all cases*/
proc sql;
create table longitudinal_pro as
select a.*, b.survival from longitudinal as a
left join sur_pro_detail as b on a.HSIL_sur_time= b.HSIL_sur_time and a.group=b.group and b._censor_=1-a.p_HSIL;
quit;
proc sort data=longitudinal_pro;by group;run;
proc sort data=sur_3_pro_err;by group;run;
proc sort data=sur_5_pro_err;by group;run;
proc sort data=sur_7_pro_err;by group;run;
proc sort data=sur_10_pro_err;by group;run;
data longitudinal_all;
merge longitudinal_pro(in=a) sur_3_pro_err sur_5_pro_err sur_7_pro_err sur_10_pro_err;
by group;
drop stderr_3 stderr_5 stderr_7 stderr_10;
run;
proc datasets lib=work;
attrib _all_ label='';
run;
/*mark the status base on survival time*/
data longitudinal_status;
set longitudinal_all;
if HSIL_sur_time<=3 and p_HSIL=1 then do;
status3=1;
status5=1;
status7=1;
status10=1;
end;
if HSIL_sur_time<=3 and p_HSIL=0 then do;
status3=.;
status5=.;
status7=.;
status10=.;
end;
if 3<HSIL_sur_time<=5 and p_HSIL=1 then do;
status3=0;
status5=1;
status7=1;
status10=1;
end;
if 3<HSIL_sur_time<=5 and p_HSIL=0 then do;
status3=0;
status5=.;
status7=.;
status10=.;
end;
if 5<HSIL_sur_time<=7 and p_HSIL=1 then do;
status3=0;
status5=0;
status7=1;
status10=1;
end;
if 5<HSIL_sur_time<=7 and p_HSIL=0 then do;
status3=0;
status5=0;
status7=.;
status10=.;
end;
if 7<HSIL_sur_time<=10 and p_HSIL=1 then do;
status3=0;
status5=0;
status7=0;
status10=1;
end;
if 7<HSIL_sur_time<=10 and p_HSIL=0 then do;
status3=0;
status5=0;
status7=0;
status10=.;
end;
if HSIL_sur_time>10 then do;
status3=0;
status5=0;
status7=0;
status10=0;
end;
run;


/*count the adjusted cases and no cases number and calculate sensitivity and specificity based on years*/
%macro chr(year);
data year&year.;
set longitudinal_status;
if status&year.=1 then year&year.=1/SURVIVAL;
else if status&year.=0 then year&year.=1/survival_&year.;
run;
proc summary data=year&year.;
var year&year.;
class status&year.;
by group;
output out=year&year._count sum()=/autoname;
run;
data HSIL_&year. no_HSIL_&year.;
format cat $5.;
set year&year._count;
if group=:'C' then cat='CYT';
if group=:'H' then cat='HPV';
if status&year.=1 then output HSIL_&year.;
if status&year.=0 then output no_HSIL_&year.;
run;
data sen_&year.;
set hsil_&year.;
by cat;
sen_&year.=year&year._sum/(year&year._sum+lag(year&year._sum));
if first.cat then sen_&year.=.;
if sen_&year.^=.;
keep cat sen_&year.;
run;

data spe_&year.;
set no_hsil_&year.;
by cat;
spe_&year.=1-year&year._sum/(year&year._sum+lag(year&year._sum));
if first.cat then spe_&year.=.;
if spe_&year.^=.;
keep cat spe_&year.;
run;

data chr_&year.;
merge sen_&year. spe_&year.;
by cat;
run;
%mend chr;
%chr(3)
%chr(5)
%chr(7)
%chr(10)

data chr;
merge chr_3 chr_5 chr_7 chr_10;
by cat;
run;

/*calculated the 95% CI for sensitivity and specificity based on
Antolini, Laura, and Maria Grazia Valsecchi. “Performance of Binary Markers for Censored Failure Time Outcome: Nonparametric Approach Based on Proportions.” Statistics in Medicine 31, no. 11–12 (2012): 1113–28. https://doi.org/10.1002/sim.4443.
*/

/*calculated variance*/

%macro chr95(year);
data var_&year.;
format cat $5.;
set sur_&year._pro_err;
if group=:'C' then cat='CYT';
if group=:'H' then cat='HPV';
var_&year._sen=(stderr_&year.*survival_&year.)**2/(1-survival_&year.)**2;
var_&year._spe=(stderr_&year.*survival_&year.)**2/(survival_&year.)**2;
run;
data var_&year.;
set var_&year.;
by cat;
var_sen=var_&year._sen+lag(var_&year._sen);
var_spe=var_&year._spe+lag(var_&year._spe);
if first.cat then do;
var_sen=.;var_spe=.;
end;
if var_sen^=.;
keep cat var_sen var_spe;
run;
data var_p_&year.;
format cat $5.;
set year&year._count;
if group=:'C' then cat='CYT';
if group=:'H' then cat='HPV';
if status&year.=. or group in ('CYT_P' 'HPV_P');
help=year&year._sum+lag(year&year._sum);
if _TYPE_=1 and status&year.=0 then help=.;
run;
data var_p_&year.;
set var_p_&year.;
by cat;
where group IN ('CYT_P' 'HPV_P') and status&year.^=0;
p= help/(lag(help));
varP=p*(1-p)/lag(help)/p**2/(1-p)**2;
if first.cat then p=.;
if p^=.;
keep cat varP;
run;

data chr_&year.;
merge chr_&year. var_&year. var_p_&year.;
by cat;
run;
data chr_&year._final;
format year 3.;
set chr_&year.;
year=&year.;
var_all_sen=varP+var_sen;
inf_sen= Log(sen_&year./(1-sen_&year.))-1.96*var_all_sen;
L_sen=exp(inf_sen)/(1+exp(inf_sen));
Sup_sen=Log(sen_&year./(1-sen_&year.))+1.96*var_all_sen;
U_sen=exp(sup_sen)/(1+exp(sup_sen));

var_all_spe=varP+var_spe;
inf_spe= Log((1-spe_&year.)/(spe_&year.))-1.96*var_all_spe;
U_spe=1-exp(inf_spe)/(1+exp(inf_spe));
Sup_spe=Log((1-spe_&year.)/(spe_&year.))+1.96*var_all_spe;
L_spe=1-exp(sup_spe)/(1+exp(sup_spe));

sensitivity_year=cat(compress(put(sen_&year.*100,8.2)),' (',compress(put(L_sen*100,8.2)),', ',compress(put(U_sen*100,8.2)),')');
specificity_year=cat(compress(put(spe_&year.*100,8.2)),' (',compress(put(L_spe*100,8.2)),', ',compress(put(U_spe*100,8.2)),')');
keep year cat sensitivity_year specificity_year;
run;
%mend chr95;
%chr95 (3);
%chr95 (5);
%chr95 (7);
%chr95 (10);

/*count the cases*/
proc sort data=longitudinal;by group;run;
proc summary data=longitudinal_status;
var p_HSIL status3 status5 status7 status10;
class group;
output out=case_num sum()=/autoname;
run;

data case_num;
set case_num;
drop _TYPE_ p_HSIL_sum;
run;
proc transpose data=case_num out=number;
var _freq_ status3_sum status5_sum status7_sum status10_sum;
id group;
run;

data chr_all;
set chr_3_final chr_5_final chr_7_final chr_10_final;
run;
data hpv_chr(rename=(sensitivity_year=sensitivity_hpv specificity_year=specificity_hpv) drop=cat) cyt_chr(rename=(sensitivity_year=sensitivity_cyt specificity_year=specificity_cyt) drop=cat);
set chr_all;
if cat='HPV' then output hpv_chr ;
if cat='CYT' then output cyt_chr ;
run;
data chr_final;
merge hpv_chr cyt_chr;
by year;
run;

data number;
format year 3.;
set number;
if _name_='status3_Sum' then year=3;
if _name_='status5_Sum' then year=5;
if _name_='status7_Sum' then year=7;
if _name_='status10_Sum' then year=10;
drop _name_;
run;
data table_3;
merge number chr_final;
by year;
run;

%let mydir=P:\ACCES\ACCES_Research\Qingyun\Fas1_Followup\Documents\;
title 'Table 3. Longitudinal test characteristics using incident HSIL+ as outcome at 3, 5, 7 and 10 years of follow-up.';
ods rtf file="&mydir.table3_sur_3_&sysdate..rtf";
proc print data=table_3 noobs;run;
ods rtf close;
title;
