%let path=C:\Users\Lucky\NCSU Google Drive\Experiments\2013-2014\2013-14 data\MaxDis logistic versus multiple reg\MaxDS MR and CART\MaxDS random forests;

%macro rf(ds_th=30, subset=1);
libname rf excel path="&path\RF pred test_&subset..xlsx";

data snb;
	set rf.'Sheet1$'n;
	drop F1;
run;

libname rf clear;
data snb1;
	set snb;
	if obs_dis < &ds_th then DSB=0;
	else DSB=1;
	if pred_dis < &ds_th then DSB_pred=0;
	else DSB_pred=1;
run;

ods pdf file= "&path\MaxDS &ds_th th RF_&subset..pdf";

title1'prediction accuracy of RF on TEST DATA';
proc reg data=snb1;
	model obs_dis= pred_dis;
run;

proc freq data=snb1;
	table DSB*DSB_pred /out=cellcounts;
run;

data cellcounts;
	set cellcounts;
	match=0;
	if DSB=DSB_pred then match=1;
run;

title2'percent correct classification of test dataset';
proc means data=cellcounts mean;
	freq count;
	var match;
run;

title2'sensitivity (% or true positives)';
data cellcounts1;
	set cellcounts;
	if DSB=1;
run;
proc means data=cellcounts1 mean;
	freq count;
	var match;
run;

title2'specificity (% or true negatives)';
data cellcounts2;
	set cellcounts;
	if DSB=0;
run;
proc means data=cellcounts2 mean;
	freq count;
	var match;
run;
title;

ods pdf close;

%mend rf;

%rf(ds_th=30, subset=1);
%rf(ds_th=30, subset=2);
%rf(ds_th=30, subset=3);
%rf(ds_th=30, subset=4);
%rf(ds_th=30, subset=5);
%rf(ds_th=30, subset=6);
%rf(ds_th=30, subset=7);
%rf(ds_th=30, subset=8);
%rf(ds_th=30, subset=9);
%rf(ds_th=30, subset=10);
%rf(ds_th=30, subset=11);
%rf(ds_th=30, subset=12);
%rf(ds_th=30, subset=13);
%rf(ds_th=30, subset=14);
%rf(ds_th=30, subset=15);



