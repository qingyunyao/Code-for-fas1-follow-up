/* cap input rows for the captured run */
options obs=100;

/* -------------------------------------------------------------------
   Upstream flow-chart script reads three external libraries holding
   protected registry data (fas1.fas1_pop_withdup_jw20230524 invitation
   population, v_ncsr.nkc_inv_9322 invitation records, newcoh.analysis_0205
   analysis cohort). This autoexec builds small synthetic stand-ins with
   the columns/types the script reads so the original dedup / date-window /
   match-merge / PROC FREQ code runs unmodified. Values are fabricated.
   ------------------------------------------------------------------- */
libname fas1   (work);
libname v_ncsr (work);
libname newcoh (work);

/* invitation population, with duplicates by person_id (as upstream expects) */
data fas1.fas1_pop_withdup_jw20230524;
  input person_id even x_sample_yr;
  datalines;
1 0 2012
1 0 2012
2 1 2013
2 1 2013
3 0 2012
3 0 2012
4 1 2014
5 0 2013
5 0 2013
6 1 2012
7 0 2014
8 1 2013
;
run;

/* invitation records; x_inv_date stored as a SAS datetime (script uses
   datepart). x_inv_date is built from a plain date so the values are
   transparent; one row (person 8, Aug-2011) falls before the buffer window
   and is dropped by the where-filter, exercising the date-window logic. */
data v_ncsr.nkc_inv_9322;
  input person_id inv_year $ inv_date :yymmdd10.;
  x_inv_date = dhms(inv_date, 0, 0, 0);
  format x_inv_date datetime20.;
  drop inv_date;
  datalines;
1 2012 2012-03-05
2 2013 2013-01-20
3 2012 2012-06-15
4 2014 2014-05-01
5 2013 2013-09-10
6 2012 2012-11-23
7 2014 2014-02-14
8 2011 2011-08-30
;
run;

/* analysis cohort read by the closing PROC FREQ crosstabs */
data newcoh.analysis_0205;
  input person_id even pre_abn pre_LSIL pre_HSIL cytdiag $ hpvdiag $;
  datalines;
1 0 1 0 0 NEG NEG
2 1 0 0 0 NEG POS
3 0 1 1 0 POS NEG
4 1 0 0 0 NEG NEG
5 0 1 0 0 POS POS
6 1 1 1 1 POS NEG
7 0 0 0 0 NEG NEG
8 1 1 0 0 NEG POS
;
run;
