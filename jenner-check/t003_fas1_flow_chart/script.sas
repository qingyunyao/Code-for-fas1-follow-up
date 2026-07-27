/*File name..: Fas1 follow up population */
/*Purpose....: generate statistics for flow chart and baseline characteristics*/
/* Source: Fas1_fc_bl_QY_flow chart.sas (upstream analysis, unmodified logic).
   The three external registry libraries (fas1, v_ncsr, newcoh) are supplied
   by the bundle autoexec as small synthetic stand-ins matching the columns
   the script reads. The flow-chart dedup / invitation date-window / match-
   merge steps below are the author's original code; only the closing block
   of PROC FREQ crosstabs is trimmed to those referencing the mocked cohort
   columns, so the run is self-contained. */

/*flow chart*/
/*whole population: women aged 56-61 in 2012-2014 and living in stockholm*/
proc freq data=fas1.fas1_pop_withdup_jw20230524;
tables x_sample_yr even;
run;

data invitation;
set fas1.fas1_pop_withdup_jw20230524;
run;

proc sort data=invitation;
by person_id;
run;

proc sort data=invitation nodupkey out=invitation_ndk;
by person_id;
run;

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

proc freq data=inv;
tables even;
run;

/*women participate in fas1 screening*/
proc freq data=newcoh.analysis_0205;
tables even;
run;

proc freq data=newcoh.analysis_0205;
tables even*pre_abn even*pre_LSIL even*pre_HSIL;
run;

proc freq data=newcoh.analysis_0205;
tables hpvdiag*pre_abn hpvdiag*pre_LSIL hpvdiag*pre_HSIL;
run;
proc freq data=newcoh.analysis_0205;
tables cytdiag*pre_abn cytdiag*pre_LSIL cytdiag*pre_HSIL;
run;
