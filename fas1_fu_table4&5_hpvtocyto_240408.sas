/*File name..: Fas1 follow up population */
/*Study......: Phd project study 1 the efficiency of hpv as primary test among post-menopause women (56-61)*/
/*Author.....: Qingyun Yao*/
/*Date.......: 2023/12/5*/
/*Updated....: */
/*Purpose....: generate table 4&5 and supplementary tables.Incidence rate*/
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
%let mydir=P:\ACCES\ACCES_Research\Qingyun\Fas1_Followup\Documents\;

proc datasets library=work kill;quit;
/*incidence rate fro HSIL*/
data analysis;
set newcoh.analysis_0205;
rename p_HSIL=HSIL can_sur_time=cancer_sur_time;
keep person_id even p_HSIL HSIL_sur_time cancer can_sur_time pre_abn group pre_pad_hsil;
run;
/*used when do senstivity analysis excluding women without any previous screening history*/
data analysis;
set newcoh.sensitive_exclude_nohis_240808;
rename p_HSIL=HSIL can_sur_time=cancer_sur_time;
keep person_id even p_HSIL HSIL_sur_time cancer can_sur_time pre_abn group pre_pad_hsil;
run;

option nomlogic nomprint;
%MACRO IR(outcome,sub);
proc summary data=analysis;
var &outcome. &outcome._sur_time;
class group;
%if &sub.=0 %then %do; where pre_abn=0 %if &outcome.=HSIL %then %do; and pre_pad_HSIL=0 %end;; %end;
%else %if &sub.=1 %then %do; where pre_abn=1 %if &outcome.=HSIL %then %do; and pre_pad_HSIL=0 %end;; %end;
%else %do;%if &outcome.=HSIL %then %do;where pre_pad_HSIL=0;%end; %end;
output out=&outcome._count sum()=/autoname;
run;
proc summary data=analysis;
var &outcome. &outcome._sur_time;
class even;
%if &sub.=0 %then %do; where pre_abn=0 %if &outcome.=HSIL %then %do; and pre_pad_HSIL=0 %end;; %end;
%else %if &sub.=1 %then %do; where pre_abn=1 %if &outcome.=HSIL %then %do; and pre_pad_HSIL=0 %end;; %end;
%else %do;%if &outcome.=HSIL %then %do;where pre_pad_HSIL=0;%end; %end;
output out=&outcome._count_even sum()=/autoname;
run;
data &outcome._IR;
format cat $10. name $20.;
set &outcome._count &outcome._count_even;
if group='' then cat="ALL&sub.";
if even^=. then cat="Mehod&sub.";
if group IN ('HPV_P' 'CYT_P') then cat="POS&sub.";
if group IN ('HPV_N' 'CYT_N') then cat="NEG&sub.";
IRs=&outcome._sum/&outcome._sur_time_sum*100000;
Low=exp(log(&outcome._sum/&outcome._sur_time_sum)-1.96*(1/sqrt(&outcome._sum)))*100000;
High=exp(log(&outcome._sum/&outcome._sur_time_sum)+1.96*(1/sqrt(&outcome._sum)))*100000;
rename _freq_=N &outcome._sum=num_cases;
name=compress(cat(compress(cat),'_',group,'_',even));
keep name cat _freq_ &outcome._sum IRs Low High;
run;

proc sort data=&outcome._IR; by cat name ;run;

data &outcome._IRR&sub.;
set &outcome._ir;
by cat;
IRR=IRs/(lag(IRs));
low_IRR=exp(log(IRR)-1.96*sqrt(1/lag(num_cases)+1/num_cases));
Up_IRR=exp(log(IRR)+1.96*sqrt(1/lag(num_cases)+1/num_cases));
if first.cat then do; IRR=.; low_IRR=.;up_IRR=.;end;
run;

%mend IR;


%IR(HSIL);
%IR(cancer);
%IR(outcome=HSIL,sub=1);
%IR(cancer,1);
%IR(HSIL,0);
%IR(cancer,0);


/*export for the figures*/
proc export data=cancer_irr outfile="&mydir.table4_figure.xlsx" dbms=xlsx replace; sheet='cancer_irr'; run;
proc export data=cancer_irr0 outfile="&mydir.table4_figure.xlsx" dbms=xlsx replace; sheet='cancer_irr0'; run;
proc export data=cancer_irr1 outfile="&mydir.table4_figure.xlsx" dbms=xlsx replace; sheet='cancer_irr1'; run;
proc export data=HSIL_irr outfile="&mydir.table4_figure.xlsx" dbms=xlsx replace; sheet='HSIL_irr'; run;
proc export data=HSIL_irr0 outfile="&mydir.table4_figure.xlsx" dbms=xlsx replace; sheet='HSIL_irr0'; run;
proc export data=HSIL_irr1 outfile="&mydir.table4_figure.xlsx" dbms=xlsx replace; sheet='HSIL_irr1'; run;


/*organize table 4*/
%macro org(out,sub);
data table_&out._&sub.;
set &out._IRR&sub;
&out._IR=cat(compress(put(IRs,8.2)),' (',compress(put(Low,8.2)),', ',compress(put(High,8.2)),')');
&out._IRR=cat(compress(put(IRR,8.2)),' (',compress(put(Low_IRR,8.2)),', ',compress(put(Up_IRR,8.2)),')');
if IRR=. then &out._IRR='Ref.';
rename N=&out._N num_cases=&out._cases;
keep cat name N num_cases &out._IR &out._IRR;
run;
%mend org;
%org(HSIL);
%org(cancer);
%org(HSIL,1);
%org(cancer,1);
%org(HSIL,0);
%org(cancer,0);

data table_4_a;
set table_hsil_ table_hsil_0 table_hsil_1;
run;

data table_4_b;
set table_cancer_ table_cancer_0 table_cancer_1;
run;

proc sort data=table_4_a;by cat  name;
proc sort data=table_4_b;by cat  name;
run;
data table_4;
merge table_4_a table_4_b;
by cat  name;
run;

data table_4;
set table_4;
if name=:'A' and HSIL_IRR='Ref.' then delete;
drop cat;
run;

%let mydir=P:\ACCES\ACCES_Research\Qingyun\Fas1_Followup\Documents\;
title 'Table 4. Incidence rate of HSIL and cancer by fas1 results.';
ods rtf file="&mydir.table4_&sysdate..rtf";
proc print data=table_4 noobs;run;
ods rtf close;
title;

/*consider pre-abnormality*/
%macro abn_ir(outcome,fas1_re);
proc summary data=analysis;
var &outcome. &outcome._sur_time;
class pre_abn;
%if &fas1_re.=ALL %then %do; %if &outcome.=HSIL %then %do;where pre_pad_HSIL=0;%end;%end;
%else %if &fas1_re.=0 %then %do; where even=0 %if &outcome.=HSIL %then %do; and pre_pad_HSIL=0 %end;;%end;
%else %if &fas1_re.=1 %then %do; where even=1 %if &outcome.=HSIL %then %do; and pre_pad_HSIL=0 %end;;%end;
%else %do;where group="&fas1_re."  %if &outcome.=HSIL %then %do; and pre_pad_HSIL=0 %end;;%end;
output out=&outcome._count sum()=/autoname;
run;
data &outcome._count_&fas1_re.;
format type $8.;
type="&fas1_re.";
set &outcome._count;
rename _freq_=N;
IRs=&outcome._sum/&outcome._sur_time_sum*100000;
Low=exp(log(&outcome._sum/&outcome._sur_time_sum)-1.96*(1/sqrt(&outcome._sum)))*100000;
High=exp(log(&outcome._sum/&outcome._sur_time_sum)+1.96*(1/sqrt(&outcome._sum)))*100000;
IRR=IRs/(lag(IRs));
low_IRR=exp(log(IRR)-1.96*sqrt(1/lag(&outcome._sum)+1/&outcome._sum));
Up_IRR=exp(log(IRR)+1.96*sqrt(1/lag(&outcome._sum)+1/&outcome._sum));
if pre_abn=0 or pre_abn=. then do;
IRR=.;low_IRR=.;Up_IRR=.;end;
run;
%mend abn_ir;
option mlogic mprint;
%abn_ir(HSIL,ALL);
%abn_ir(cancer,ALL);
%abn_ir(HSIL,0);
%abn_ir(cancer,0);
%abn_ir(HSIL,1);
%abn_ir(cancer,1);
%abn_ir(HSIL,HPV_N);
%abn_ir(cancer,HPV_N);
%abn_ir(HSIL,HPV_P);
%abn_ir(cancer,HPV_P);
%abn_ir(HSIL,CYT_N);
%abn_ir(cancer,CYT_N);
%abn_ir(HSIL,CYT_P);
%abn_ir(cancer,CYT_P);




/*make table 5*/
data hsil;
format cat $20.;
set hsil_count_all hsil_count_1 hsil_count_hpv_n hsil_count_hpv_p
hsil_count_0 hsil_count_cyt_n hsil_count_cyt_p;
rename N=HSIL_N;
HSIL_IR=cat(compress(put(IRs,8.2)),' (',compress(put(Low,8.2)),', ',compress(put(High,8.2)),')');
HSIL_IRR=cat(compress(put(IRR,8.2)),' (',compress(put(Low_IRR,8.2)),', ',compress(put(Up_IRR,8.2)),')');
cat=compress(cat(type,'-',pre_abn));
keep cat N hsil_sum HSIL_IR HSIL_IRR;
run;

data cancer;
format cat $20.;
set  cancer_count_all cancer_count_1 cancer_count_hpv_n cancer_count_hpv_p
cancer_count_0 cancer_count_cyt_n cancer_count_cyt_p;
rename N=can_N;
can_IR=cat(compress(put(IRs,8.2)),' (',compress(put(Low,8.2)),', ',compress(put(High,8.2)),')');
can_IRR=cat(compress(put(IRR,8.2)),' (',compress(put(Low_IRR,8.2)),', ',compress(put(Up_IRR,8.2)),')');
cat=compress(cat(type,'-',pre_abn));
keep cat N cancer_sum can_IR can_IRR;
run;

proc sql;
create table table_5 as
select * from hsil as a, cancer as b where a.cat=b.cat;
quit;



title 'Table 5. Incidence rate of HSIL and cancer among women with or without pre-abnormality.';
ods rtf file="&mydir.table5_&sysdate..rtf";
proc print data=table_5 noobs;run;
ods rtf close;
title;


/*figure_dataset*/
data HSIL;
set hsil_count_all hsil_count_1 hsil_count_hpv_n hsil_count_hpv_p
hsil_count_0 hsil_count_cyt_n hsil_count_cyt_p;
keep type pre_abn HSIL_sum IRR low_IRR up_IRR;
run;

data cancer;
set  cancer_count_all cancer_count_1 cancer_count_hpv_n cancer_count_hpv_p
cancer_count_0 cancer_count_cyt_n cancer_count_cyt_p;
keep type pre_abn cancer_sum IRR low_IRR up_IRR;
run;

proc export data=cancer outfile="&mydir.table5_figure.xlsx" dbms=xlsx replace; sheet='cancer'; run;
proc export data=HSIL outfile="&mydir.table5_figure.xlsx" dbms=xlsx replace; sheet='HSIL'; run;
