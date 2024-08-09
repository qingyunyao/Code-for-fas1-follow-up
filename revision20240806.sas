/*flow chart*/
data dereg;
set newcoh.analysis_0205;
keep person_id group dereg dereg_date dereg_rea eof_cancer;
run;

proc freq data=dereg;
table group*dereg_rea group*dereg/nopercent norow nocol;
run;

data pre_his;
set newcoh.analysis_0205;
run;

data pre_his;
set pre_his;
if pre_cyto=. and pre_hpv=. and pad_sev=. then pre_his=0;
run;

proc freq data=pre_his;
tables pre_his/missing;
run;

data without_his;
set pre_his;
where pre_his=0;
run;

proc summary data=without_his;
var p_HSIL HSIL_sur_time cancer can_sur_time;
output out=without_ir sum()=/autoname;
class even group_n;
run;


/*log-rank compare positive group*/
data HSIL;
set newcoh.analysis_0205;
keep person_id p_HSIL even group HSIL_sur_time negative;
rename p_HSIL=HSIL;
where pre_pad_HSIL=0;
run;
data HSIL;
set HSIL;
if negative=''  then positive=group;
run;
data cancer;
set newcoh.analysis_0205;
keep person_id cancer even group can_sur_time negative;
run;
data cancer;
set cancer;
if negative=''  then positive=group;
run;
ods exclude ProductLimitEstimates;
proc lifetest data=HSIL nelson conftype=asinsqrt
plot=(survival hazard loglogs logsurv);
time HSIL_sur_time*HSIL(0);
strata positive/test=all;
title 'survival analysis for HSIL between positive groups';
ods output ProductLimitEstimates=hsil_pos_censor;
run;
title '';
/*
log rank 0.9501
wilcoxon 0.7504*/

ods exclude ProductLimitEstimates;
proc lifetest data=cancer nelson conftype=asinsqrt
plot=(survival hazard loglogs logsurv);
time can_sur_time*cancer(0);
strata positive/test=all;
title 'survival analysis for ICC between positive groups';
run;
title '';
/*
log rank 0.3022
wilcoxon 0.3022*/
/*dataset for sensitive analysis*/
data sensitive_240808;/*exclude 254 women without any screening history before baseline screening*/
set newcoh.analysis_0205;
if pad_sev=. and pre_cyto=. and pre_hpv=. then delete;
run;

data newcoh.sensitive_exclude_nohis_240808;
set sensitive_240808;
run;
