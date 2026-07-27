/* cap input rows for the captured run */
options obs=100;

/* -------------------------------------------------------------------
   The upstream script reads two datasets from an external SAS library
   (libname newcoh 'P:\ACCES\...') holding protected Swedish screening
   registry data that cannot be redistributed.  This autoexec builds a
   small synthetic stand-in with the same columns/types the script reads
   (person_id, group, negative, fas1_sample_date, fu_test_date_1) so the
   original analysis code below runs unmodified against WORK-backed
   newcoh.  Values are fabricated, not real subjects.
   ------------------------------------------------------------------- */
libname newcoh (work);

data newcoh.analysis_scr_test_0206;
  input person_id group $ negative $ fas1_sample_date :yymmdd10. fu_test_date_1 :yymmdd10.;
  format fas1_sample_date fu_test_date_1 yymmdd10.;
  datalines;
1  CYT_N N 2012-03-01 2014-09-10
2  CYT_N N 2012-04-11 2015-11-02
3  CYT_N N 2012-06-20 .
4  HPV_N N 2013-01-15 2016-02-20
5  HPV_N N 2013-02-01 2019-08-14
6  HPV_N N 2013-03-19 .
7  CYT_N N 2012-08-05 2013-10-01
8  HPV_N N 2013-05-22 2024-01-30
9  CYT_N N 2012-09-14 2018-12-05
10 HPV_N N 2013-06-30 2015-01-19
11 CYT_N N 2012-10-02 2023-11-11
12 HPV_N N 2013-07-08 .
;
run;

data newcoh.analysis_pos_fu_scr_0206;
  input person_id group $ even fas1_sample_date :yymmdd10. fu_test_date_1 :yymmdd10.;
  format fas1_sample_date fu_test_date_1 yymmdd10.;
  datalines;
101 CYT_P 0 2012-03-10 2012-09-05
102 CYT_P 0 2012-05-04 2013-02-11
103 HPV_P 1 2013-02-14 2013-08-20
104 HPV_P 1 2013-04-01 2016-05-15
105 CYT_P 0 2012-07-19 2012-12-30
106 HPV_P 1 2013-06-06 2014-01-02
107 CYT_P 0 2012-11-23 2021-03-17
108 HPV_P 1 2013-08-30 .
;
run;
