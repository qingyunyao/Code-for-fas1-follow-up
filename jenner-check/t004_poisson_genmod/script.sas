/* Source: possion_20231128_QY_pvalue.sas (upstream analysis, unmodified).
   Purpose: Poisson regression (crude and year-adjusted incidence-rate ratios).
   newcoh.analysis_0205 is supplied by the bundle autoexec as a small
   synthetic stand-in matching the columns the script reads. The `analysis`
   preparation, the %poisson macro definition, and its invocations for the
   HSIL and cancer outcomes below are the author's original code; the
   sensitivity-analysis re-read of an external derived dataset and the
   trailing ODS RTF export to a hardcoded Windows path are omitted so the
   run is self-contained. A closing PROC PRINT makes the result observable. */

/*create dataset for the following analysis*/
data analysis;
set newcoh.analysis_0205;
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
data result_cancer_poisson_org result_cancer_poisson_adj;
format parameter $30. cat 2.;
run;
%poisson(cancer,group,HPV_N);
%poisson(cancer,even,0)

/* Show the crude Poisson parameter estimates (incidence-rate ratio = exp(estimate))
   for the two exposures on the HSIL outcome. */
data hsil_group_rr;
set hsil_group;
IRR=exp(estimate);
run;
data hsil_even_rr;
set hsil_even;
IRR=exp(estimate);
run;

title 'Crude Poisson incidence-rate ratios by screening group (HSIL outcome)';
proc print data=hsil_group_rr noobs;
var parameter estimate IRR probchisq;
run;
title 'Crude Poisson incidence-rate ratio, primary HPV vs Cytology (HSIL outcome)';
proc print data=hsil_even_rr noobs;
var parameter estimate IRR probchisq;
run;
title;
