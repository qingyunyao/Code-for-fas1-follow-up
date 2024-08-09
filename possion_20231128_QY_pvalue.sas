/*File name..: Fas1 follow up population */
/*Study......: Phd project study 1 the efficiency of hpv as primary test among post-menopause women (56-61)*/
/*Author.....: Qingyun Yao*/
/*Date.......: 2023/10/30*/
/*Updated....: */
/*Purpose....: poisson regression (crude and adjusted!)*/
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
libname NCSR  odbc complete="server=meb-sql02.meb.ki.se;driver=SQL Server Native Client 11.0;Trusted_Connection=Yes;database=NCSR" schema=NCSR ;
libname V_NCSR     odbc complete="server=meb-sql02.meb.ki.se;driver=SQL Server Native Client 11.0;Trusted_Connection=Yes;database=NCSR" schema=V_NCSR ;
libname fas1 'P:\ACCES\ACCES_Research\Qingyun\Fas1_Followup\Data\0531';
libname newcoh 'P:\ACCES\ACCES_Research\Qingyun\Fas1_Followup\Data\newcohort';
/*main program*/
proc datasets library=work kill;quit;
/*create dataset for the following analysis*/
data analysis;
set newcoh.analysis_0205;
log_HSIL=log(HSIL_sur_time);
log_cancer=log(can_sur_time);
rename p_HSIL=HSIL;
fas1_sample_yr=year(fas1_sample_date);
run;

/*used when do senstivity analysis excluding women without any previous screening history*/
data analysis;
set newcoh.sensitive_exclude_nohis_240808;
log_HSIL=log(HSIL_sur_time);
log_cancer=log(can_sur_time);
rename p_HSIL=HSIL;
fas1_sample_yr=year(fas1_sample_date);
run;

data analysis;
set analysis;
if group='HPV_P' then positive='HPV';
if group='CYT_P' then positive='CYT';
run;
/*out=outcome (HSIL,cancer)
exp=exposure (even group negative positive)
sub=pre_abn(pre_abnormality or not)*/
%macro poisson(out,exp,ref,sub);
proc genmod data=analysis;
  class &exp.  (ref="&ref.")/param=glm;
  model &out. = &exp.   / type3 dist=poisson link=log offset=log_&out.;
  store p1;
  %if &out.=HSIL %then %do; 
  where pre_pad_HSIL=0 
  %if &sub.=0 %then %do; and pre_abn=0 %end;
  %else %if &sub.=1 %then %do; and pre_abn=1 %end;
  ;
  %end;
  %else %do;
  %if &sub.=0 %then %do; where pre_abn=0; %end;
  %else %if &sub.=1 %then %do; where pre_abn=1; %end;
  %end;
  ods output ParameterEstimates=&out._&exp.;
run;
proc genmod data=analysis;
  class &exp.   (ref="&ref.") fas1_sample_yr/param=glm;
  model &out. = &exp.  fas1_sample_yr / type3 dist=poisson link=log offset=log_&out.;
  store p1;  
  %if &out=HSIL %then %do; 
  where pre_pad_HSIL=0 
  %if &sub.=0 %then %do; and pre_abn=0 %end;
  %else %if &sub.=1 %then %do; and pre_abn=1 %end;
  ;
  %end;
  %else %do;
  %if &sub.=0 %then %do; where pre_abn=0; %end;
  %else %if &sub.=1 %then %do; where pre_abn=1; %end;
  %end;
  ods output ParameterEstimates=&out._&exp._adj;
run;
data result_&out._poisson_org;
set result_&out._poisson_org &out._&exp. ;
RR_org=exp(estimate);
RR_L_org=exp(lowerwaldcl);
RR_U_org=exp(upperwaldcl);
where parameter In ('group' 'even' 'negative' 'positive');
run;
data result_&out._poisson_adj;
set result_&out._poisson_adj  &out._&exp._adj;
RR_adj=exp(estimate);
RR_L_adj=exp(lowerwaldcl);
RR_U_adj=exp(upperwaldcl);
where parameter In ('group' 'even' 'negative' 'positive');
run;
%mend poisson;
data result_HSIL_poisson_org result_HSIL_poisson_adj ;
format parameter $30. cat 2.;
run;
%poisson(HSIL,group,HPV_N);
%poisson(HSIL,even,0)
%poisson(HSIL,negative,CYT)
%poisson(HSIL,positive,CYT)
option mlogic mprint;
data result_cancer_poisson_org result_cancer_poisson_adj;
format parameter $30. cat 2.;
run;
%poisson(cancer,group,HPV_N);
%poisson(cancer,even,0)
%poisson(cancer,negative,CYT)
%poisson(cancer,positive,CYT)


/*organize th results*/

%macro arrange(out,adj);
proc sort data=result_&out._poisson_&adj.;
by parameter df;run;
data &out._&adj.;
set result_&out._poisson_&adj.;
keep parameter level1 ProbChiSq rr_&out._&adj.;
rename ProbChiSq=&out._&adj._p;
rr_&out._&adj.=cat(compress(put(rr_&adj.,8.2)),' (',compress(put(rr_L_&adj.,8.2)),', ',compress(put(rr_U_&adj.,8.2)),')');
if rr_&adj.=1 then rr_&out._&adj.='ref';
run;
%mend arrange;
%arrange(HSIL,org)
%arrange(HSIL,adj)
%arrange(cancer,org)
%arrange(cancer,adj)
proc sql;
create table table_6 as
select * from HSIL_org as a, HSIL_adj as b, cancer_org as c, cancer_adj as d where a.level1= b.level1 and
a.level1= c.level1 and a.level1= d.level1 and a.parameter= b.parameter and
a.parameter= c.parameter and a.parameter= d.parameter;
quit;



%let mydir=P:\ACCES\ACCES_Research\Qingyun\Fas1_Followup\Documents\;
title 'Table 6. Poisson regression_pvalue.';
ods rtf file="&mydir.table6_&sysdate..rtf";
proc print data=table_6 noobs;run;
ods rtf close;
title;



data result_HSIL_poisson_org result_HSIL_poisson_adj ;
format parameter $30. cat 2.;
run;
%poisson(HSIL,group,HPV_N,0)
%poisson(HSIL,even,0,0)
%poisson(HSIL,negative,CYT,0)
%poisson(HSIL,positive,CYT,0)
data result_cancer_poisson_org result_cancer_poisson_adj;
format parameter $30. cat 2.;
run;
%poisson(cancer,group,HPV_N,0)
%poisson(cancer,even,0,0)
%poisson(cancer,negative,CYT,0)
%poisson(cancer,positive,CYT,0)
%arrange(HSIL,org)
%arrange(HSIL,adj)
%arrange(cancer,org)
%arrange(cancer,adj)
proc sql;
create table table_6_without as
select * from HSIL_org as a, HSIL_adj as b, cancer_org as c, cancer_adj as d where a.level1= b.level1 and
a.level1= c.level1 and a.level1= d.level1 and a.parameter= b.parameter and
a.parameter= c.parameter and a.parameter= d.parameter;
quit;

title 'Table 6-1. Poisson regression among women without pre-abnormality.';
ods rtf file="&mydir.table6_without_p&sysdate..rtf";
proc print data=table_6_without noobs;run;
ods rtf close;
title;





data result_HSIL_poisson_org result_HSIL_poisson_adj ;
format parameter $30. cat 2.;
run;
%poisson(HSIL,group,HPV_N,1)
%poisson(HSIL,even,0,1)
%poisson(HSIL,negative,CYT,1)
%poisson(HSIL,positive,CYT,1)
data result_cancer_poisson_org result_cancer_poisson_adj;
format parameter $30. cat 2.;
run;
%poisson(cancer,group,HPV_N,1)
%poisson(cancer,even,0,1)
%poisson(cancer,negative,CYT,1)
%poisson(cancer,positive,CYT,1)
%arrange(HSIL,org)
%arrange(HSIL,adj)
%arrange(cancer,org)
%arrange(cancer,adj)
proc sql;
create table table_6_with as
select * from HSIL_org as a, HSIL_adj as b, cancer_org as c, cancer_adj as d where a.level1= b.level1 and
a.level1= c.level1 and a.level1= d.level1 and a.parameter= b.parameter and
a.parameter= c.parameter and a.parameter= d.parameter;
quit;

title 'Table 6-2. Poisson regression among women with pre-abnormality.';
ods rtf file="&mydir.table6_with_p&sysdate..rtf";
proc print data=table_6_with noobs;run;
ods rtf close;
title;





/*pre_abnormality as the exposre
out=outcome (HSIl cancer)
exp= use to limit the population(even group negative)
cat=use to limit the population(0,1 hpv_p hpv_n cyt_p cyt_n hpv cyt)*/

%macro poisson_abn(out=,exp=A,cat=);
proc genmod data=analysis;
  class pre_abn  (ref="0")/param=glm;
  model &out. = pre_abn / type3 dist=poisson link=log offset=log_&out.;
  store p1;

%if &exp.=A %then %do;%if &out.=HSIL %then %do; where pre_pad_HSIL=0; %end; %end;
%else %do;
where &exp.=&cat. %if &out.=HSIL %then %do; and pre_pad_HSIL=0 %end;;
%end;

  ods output ParameterEstimates=&out._&exp.;
run;
proc genmod data=analysis;
  class pre_abn  (ref="0") fas1_sample_yr/param=glm;
  model &out. = pre_abn fas1_sample_yr/ type3 dist=poisson link=log offset=log_&out.;
  store p1; 
  %if &exp.=A %then %do;%if &out.=HSIL %then %do; where pre_pad_HSIL=0; %end; %end;
%else %do;
where &exp.=&cat. %if &out.=HSIL %then %do; and pre_pad_HSIL=0 %end;;
%end;
  ods output ParameterEstimates=&out._&exp._adj;
run;
data &out._&exp._adj;
set &out._&exp._adj;
cat="&cat._&exp.";
run;
data &out._&exp.;
set &out._&exp.;
cat="&cat._&exp.";
run;
data result_&out._poisson_org;
set result_&out._poisson_org &out._&exp. ;
RR_org=exp(estimate);
RR_L_org=exp(lowerwaldcl);
RR_U_org=exp(upperwaldcl);
where parameter In ('pre_abn');
run;
data result_&out._poisson_adj;
set result_&out._poisson_adj  &out._&exp._adj;
RR_adj=exp(estimate);
RR_L_adj=exp(lowerwaldcl);
RR_U_adj=exp(upperwaldcl);
where parameter In ('pre_abn');
run;
%mend poisson_abn;
data result_HSIL_poisson_org result_HSIL_poisson_adj ;
format parameter $30. cat $10.;
run;
%poisson_abn(out=HSIL,exp=group,cat='HPV_N')
%poisson_abn(out=HSIL,exp=group,cat='HPV_P')
%poisson_abn(out=HSIL,exp=group,cat='CYT_N')
%poisson_abn(out=HSIL,exp=group,cat='CYT_P')
%poisson_abn(out=HSIL,exp=even,cat=1)
%poisson_abn(out=HSIL,exp=even,cat=0)
%poisson_abn(out=HSIL,exp=A,cat='ALL')
data result_cancer_poisson_org result_cancer_poisson_adj ;
format parameter $30. cat $10.;
run;
%poisson_abn(out=cancer,exp=group,cat='HPV_N')
%poisson_abn(out=cancer,exp=group,cat='HPV_P')
%poisson_abn(out=cancer,exp=group,cat='CYT_N')
%poisson_abn(out=cancer,exp=group,cat='CYT_P')
%poisson_abn(out=cancer,exp=even,cat=1)
%poisson_abn(out=cancer,exp=even,cat=0)
%poisson_abn(out=cancer,exp=A,cat='ALL')
%macro arrange_abn(out,adj);
proc sort data=result_&out._poisson_&adj.;
by parameter df;run;
data &out._&adj.;
set result_&out._poisson_&adj.;
if df=1;
keep level1 ProbChiSq rr_&out._&adj. cat;
rename ProbChiSq=&out._&adj._p;
rr_&out._&adj.=cat(compress(put(rr_&adj.,8.2)),' (',compress(put(rr_L_&adj.,8.2)),', ',compress(put(rr_U_&adj.,8.2)),')');
if rr_&adj.=1 then rr_&out._&adj.='ref';
run;
%mend arrange_abn;
%arrange_abn(HSIL,org)
%arrange_abn(HSIL,adj)
%arrange_abn(cancer,org)
%arrange_abn(cancer,adj)

proc sql;
create table table_6_abn as
select * from HSIL_org as a, HSIL_adj as b, cancer_org as c, cancer_adj as d where a.cat= b.cat and
a.cat= c.cat and a.cat= d.cat;
quit;

title 'Table 6-3. Poisson regression among women with pre-abnormality.';
ods rtf file="&mydir.table6_abn_&sysdate..rtf";
proc print data=table_6_abn noobs;run;
ods rtf close;
title;
/*calculated adjusted IRR only in positive women*/

proc genmod data=analysis;
  class even (ref="1")/param=glm;
  model HSIL = even / type3 dist=poisson  link=log offset=log_HSIL;
  store p1;
  where pre_pad_HSIL=0 and group IN ('HPV_P' 'CYT_P');
  ods output ParameterEstimates=HSIL_p;
run;
proc genmod data=analysis;
   class even (ref="1") fas1_sample_yr/param=glm;
  model HSIL = even fas1_sample_yr/ type3 dist=poisson  link=log offset=log_cancer;
  store p1;
  where pre_pad_HSIL=0 and group IN ('HPV_P' 'CYT_P');
  ods output ParameterEstimates=HSIL_p_adj;
run;
data HSIL_P;
set HSIL_p;
RR_org=exp(estimate);
RR_L_org=exp(lowerwaldcl);
RR_U_org=exp(upperwaldcl);
run;
data HSIL_P_adj;
set HSIL_p_adj;
RR_adj=exp(estimate);
RR_L_adj=exp(lowerwaldcl);
RR_U_adj=exp(upperwaldcl);
run;
