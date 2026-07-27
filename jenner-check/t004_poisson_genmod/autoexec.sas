/* cap input rows for the captured run */
options obs=100;

/* -------------------------------------------------------------------
   Upstream Poisson-regression script reads newcoh.analysis_0205 from an
   external library of protected registry data. This autoexec builds a
   small synthetic newcoh.analysis_0205 with the columns/types the script
   reads (HSIL / cancer event and survival-time offsets, screening-method
   group indicators, pre-abnormality flag, sample date) so the original
   PROC GENMOD Poisson code and the %poisson macro run unmodified. Values
   are fabricated, not real subjects.
   ------------------------------------------------------------------- */
libname newcoh (work);

data newcoh.analysis_0205;
  length group $6 negative $1;
  input person_id group $ even negative $ pre_pad_HSIL pre_abn
        p_HSIL HSIL_sur_time cancer can_sur_time fas1_sample_date :yymmdd10.;
  format fas1_sample_date yymmdd10.;
  if negative='.' then negative='';
  datalines;
1  CYT_N 0 N 0 0 0 8.1 0 9.1 2012-03-01
2  CYT_N 0 N 0 1 1 5.2 0 7.2 2012-05-01
3  CYT_P 0 . 0 0 1 6.3 0 8.3 2012-07-01
4  HPV_N 1 N 0 0 0 9.0 0 10.0 2013-02-01
5  HPV_N 1 N 0 1 1 4.5 0 6.5 2013-05-01
6  HPV_P 1 . 0 0 1 7.7 1 3.2 2013-06-01
7  CYT_N 0 N 0 0 0 8.6 0 9.6 2012-08-01
8  HPV_P 1 . 0 1 1 5.4 0 7.4 2013-08-01
9  CYT_P 0 . 0 0 0 9.2 0 11.2 2012-09-01
10 HPV_N 1 N 0 0 0 6.4 0 8.0 2013-06-01
11 CYT_P 0 . 0 1 1 4.0 0 6.0 2012-04-01
12 CYT_N 0 N 0 0 0 7.5 1 5.5 2012-11-01
13 HPV_P 1 . 0 0 0 3.5 0 5.5 2013-03-01
14 HPV_N 1 N 0 1 1 8.8 0 9.8 2013-07-01
15 CYT_P 0 . 0 0 1 6.7 0 8.7 2012-10-01
16 HPV_P 1 . 0 0 1 5.0 1 4.5 2013-09-01
17 CYT_N 0 N 0 0 0 9.3 0 10.3 2012-06-01
18 HPV_N 1 N 0 1 0 5.9 0 7.9 2013-04-01
19 CYT_P 0 . 0 1 1 4.8 0 6.8 2012-12-01
20 HPV_P 1 . 0 0 0 7.1 0 9.1 2013-01-01
;
run;
