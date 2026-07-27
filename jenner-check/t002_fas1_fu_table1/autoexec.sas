/* cap input rows for the captured run */
options obs=100;

/* -------------------------------------------------------------------
   Upstream table 1 reads newcoh.analysis_0205 (main analysis cohort)
   and newcoh.analysis_1020 (cancer survival cohort) from an external
   SAS library holding protected Swedish screening registry data.
   This autoexec builds small synthetic stand-ins with the columns/types
   the script reads so the original PROC SQL / PROC SUMMARY / PROC
   TRANSPOSE / PROC LIFETEST code runs unmodified. Values are fabricated.
   ------------------------------------------------------------------- */
libname newcoh (work);

data newcoh.analysis_0205;
  input person_id even group_n pre_pad_HSIL birth_year
        fas1_sample_date :yymmdd10. nr_test_all nr_cyto nr_hpv
        nr_nscreen_test nr_screen_test eof_HSIL_date :yymmdd10.
        p_LSIL p_HSIL cancer LSIL_sur_time HSIL_sur_time
        eof_cancer :yymmdd10. can_sur_time pre_abn pre_LSIL pre_HSIL;
  format fas1_sample_date eof_HSIL_date eof_cancer yymmdd10.;
  datalines;
1  1 1 0 1955 2012-03-01 6 3 3 2 4 2020-01-01 0 1 0 5.1 7.8 2022-01-01 9.8 1 0 0
2  1 2 0 1954 2012-04-01 4 2 2 1 3 2021-06-01 0 0 0 6.0 9.2 2022-06-01 10.2 0 0 0
3  0 3 0 1956 2013-02-01 8 5 3 3 5 2019-05-01 1 0 0 6.3 6.3 2021-05-01 8.2 1 1 0
4  0 4 1 1957 2013-05-01 5 3 2 2 3 2018-11-01 0 1 0 4.5 5.5 2020-11-01 7.5 1 0 1
5  1 1 0 1955 2012-06-01 7 4 3 3 4 2022-02-01 0 0 1 7.7 9.9 2023-02-01 10.9 0 0 0
6  1 2 0 1953 2012-08-01 3 1 2 1 2 2020-09-01 1 1 0 3.2 8.1 2022-09-01 10.0 1 1 0
7  0 3 0 1956 2013-07-01 9 6 3 4 5 2021-03-01 0 0 0 8.6 8.6 2023-03-01 9.6 0 0 0
8  0 4 1 1958 2013-08-01 4 2 2 2 2 2019-01-01 0 1 0 5.4 5.4 2021-01-01 7.4 1 0 1
9  1 1 0 1954 2012-09-01 6 3 3 2 4 2023-11-01 1 0 1 9.2 11.2 2024-01-01 11.4 0 0 0
10 0 3 0 1957 2013-06-01 5 3 2 2 3 2020-05-01 0 1 0 6.4 7.9 2022-05-01 9.0 1 1 0
;
run;

data newcoh.analysis_1020;
  input person_id even group_n cancer can_sur_time;
  datalines;
1  1 1 0 9.8
2  1 2 0 10.2
3  0 3 1 5.2
4  0 4 0 7.5
5  1 1 0 10.9
6  1 2 0 10.0
7  0 3 0 9.6
8  0 4 1 6.1
9  1 1 0 11.4
10 0 3 0 9.0
;
run;
