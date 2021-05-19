%let path=C:\Users\path-to-folder;

/*Data SUBSET 1*/
libname model "&path\MaxDS Reg Tree\residue as predictor";

%let subset=1;
%let ds_th=30;

%macro rtree(subset=, ds_th=);
data snb (keep= dataset maxdisM maxdisM_predictor DSB DSB_pred);
	set model.PARTITION_&subset;
	if maxdisM < &ds_th then DSB=0;
	else if maxdisM >= &ds_th then DSB=1;
	if maxdisM_predictor < &ds_th then DSB_pred=0;
	else if maxdisM_predictor >= &ds_th then DSB_pred=1;
run;

/*Determine the accuracy of prediction for training dataset*/
ods pdf file= "&path\MaxDS Reg Tree\MaxDS &ds_th th Reg tree_&subset..pdf";
/*
title1'prediction accuracy of Rtree TRAINING DATA';
proc freq data=snb(where=(dataset=1));
	table DSB*DSB_pred /out=cellcounts;
run;

data cellcounts;
	set cellcounts;
	Match=0;
	if DSB=DSB_pred then Match=1;
run;

title2'percent correct classification by training dataset';
proc means data=cellcounts mean;
	freq count;
	var Match;
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
*/
/*Prediction accuracy for test data set*/
title1'prediction accuracy of Rtree TEST DATA';
proc freq data=snb(where=(dataset=3));
	table DSB*DSB_pred /out=cellcounts;
run;

data cellcounts;
	set cellcounts;
	Match=0;
	if DSB=DSB_pred then Match=1;
run;

title2'percent correct classification by test dataset';
proc means data=cellcounts mean;
	freq count;
	var Match;
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
%mend rtree;

%rtree(subset=1, ds_th=30);
%rtree(subset=2, ds_th=30);
%rtree(subset=3, ds_th=30);
%rtree(subset=4, ds_th=30);
%rtree(subset=5, ds_th=30);
%rtree(subset=6, ds_th=30);
%rtree(subset=7, ds_th=30);
%rtree(subset=8, ds_th=30);
%rtree(subset=9, ds_th=30);
%rtree(subset=10, ds_th=30);
%rtree(subset=11, ds_th=30);
%rtree(subset=12, ds_th=30);
%rtree(subset=13, ds_th=30);
%rtree(subset=14, ds_th=30);
%rtree(subset=15, ds_th=30);

/*KAPPA STATISTIC*/

%macro kappa(ds_th=,subset=);
data snb (keep= dataset maxdisM maxdisM_predictor DSB DSB_pred);
	set model.PARTITION_&subset;
	if maxdisM < &ds_th then DSB=0;
	else if maxdisM >= &ds_th then DSB=1;
	if maxdisM_predictor < &ds_th then DSB_pred=0;
	else if maxdisM_predictor >= &ds_th then DSB_pred=1;
run;

title1'prediction accuracy of Rtree TEST DATA';
proc freq data=snb(where=(dataset=3));
	table DSB*DSB_pred /out=cellcounts;
run;

data kappa;
	set cellcounts;
	total+count;
	if DSB=DSB_pred then oa+(percent/100);
	if DSB=0 then ea1+count;
	if DSB_pred=0 then ea2+count;
	if DSB=1 then ea3+count;
	if DSB_pred=1 then ea4+count;
	if DSB=1 and DSB_pred=1 then ea=((ea1*ea2)+(ea3+ea4))/(total**2);
	kappa=(oa-ea)/(1-ea);
run;

title2 "kappa statistic for partition_&subset";
proc print data=kappa (firstobs =4);
var oa ea kappa;
run;
%mend;

ods pdf file="&path\kappa statistic for CART models.pdf";
%kappa(subset=1, ds_th=30);
%kappa(subset=2, ds_th=30);
%kappa(subset=3, ds_th=30);
%kappa(subset=4, ds_th=30);
%kappa(subset=5, ds_th=30);
%kappa(subset=6, ds_th=30);
%kappa(subset=7, ds_th=30);
%kappa(subset=8, ds_th=30);
%kappa(subset=9, ds_th=30);
%kappa(subset=10, ds_th=30);
%kappa(subset=11, ds_th=30);
%kappa(subset=12, ds_th=30);
%kappa(subset=13, ds_th=30);
%kappa(subset=14, ds_th=30);
%kappa(subset=15, ds_th=30);
ods pdf close;


***********************************
***********************************
**   Final CART model 10 splits ***
***********************************;
%let ds_th=30;
data final (keep= dataset maxdisM maxdisM_predictor DSB DSB_pred);
	set model.final_cart2;
	if maxdisM < &ds_th then DSB=0;
	else if maxdisM >= &ds_th then DSB=1;
	if maxdisM_predictor < &ds_th then DSB_pred=0;
	else if maxdisM_predictor >= &ds_th then DSB_pred=1;
run;

ods pdf file="&path\prediction accu and roc curve final CART model 10 splits corr.pdf";

/*Prediction accuracy for final CART model*/
title1'prediction accuracy final CART model';

proc reg data=final;
	model maxdisM=maxdisM_predictor;
run;

proc freq data=final;
	table DSB*DSB_pred /out=cellcounts;
run;

proc print data=cellcounts;run;

data cellcounts;
	set cellcounts;
	Match=0;
	if DSB=DSB_pred then Match=1;
run;

title2'percent correct classification by test dataset';
proc means data=cellcounts mean;
	freq count;
	var Match;
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

/*area under ROC curve*/
%macro roc(datain=,low_th=1,up_th=56,inc=1,
				obs_resp=,
				pred_resp=);
data roc;
	set &datain;
	do cutoff= &low_th to &up_th by &inc;
		if &obs_resp >= cutoff then obs_dis_cat=1;else obs_dis_cat=0;
		if &pred_resp >= cutoff then pred_dis_cat=1;else pred_dis_cat=0;
		output;
	end;
run;

proc sort data=roc;
	by cutoff;
run;

proc freq data=roc;
	by cutoff;
	table obs_dis_cat * pred_dis_cat /out=pcts1 outpct noprint;
run;

data truepos;
	set pcts1;
	if obs_dis_cat = 1 and pred_dis_cat = 1;
	tp_rate=pct_row/100;
	drop pct_row;
run;

data falsepos;
	set pcts1;
	if obs_dis_cat = 0 and pred_dis_cat = 1;
	fp_rate=pct_row/100;
	drop pct_row;
run;

data roc1;
	merge truepos falsepos;
	by cutoff;
	if tp_rate=. then tp_rate=0;
	if fp_rate=. then fp_rate=0;
run;

proc sgplot data=roc1;
	series x=fp_rate y=tp_rate /datalabel=cutoff;
run;
proc sgplot data=roc1;
	scatter x=fp_rate y=tp_rate /datalabel=cutoff;
run;

proc sort data=roc1;
	by fp_rate;
run;
data roc2;
	set roc1;
	segarea=((tp_rate+lag(tp_rate))/2)*(fp_rate-lag(fp_rate));
	if fp_rate=0 then segarea=.;
run;

proc means data=roc2 noprint;
	var segarea;
	output out=auc sum=auroc;
run;

title'area under roc';
proc print data=auc;
run;
title;

%mend;

title'ROC curve for final CART model';
%roc(datain=final,low_th=2,up_th=56,inc=1,
				obs_resp=maxdisM,
				pred_resp=maxdisM_predictor);
title;
ods pdf close;
/*Smooth the ROC curve and then calculate the area under the curve*/
data roc3;
	set roc1;
	if cutoff in (2,5,16,22,29,32,33,38,42);
run;

proc sgplot data=roc3;
	scatter x=fp_rate y=tp_rate/datalabel=cutoff;
	series x=fp_rate y=tp_rate;
run;

proc sort data=roc3;
	by fp_rate;
run;
data roc4;
	set roc3;
	segarea=((tp_rate+lag(tp_rate))/2)*(fp_rate-lag(fp_rate));
	if fp_rate=0 then segarea=.;
run;

proc means data=roc4 noprint;
	var segarea;
	output out=auc sum=auroc;
run;
proc print data=auc;run;


***********************************
***********************************
**   Final CART model 7 splits ***
***********************************;
%let ds_th=30;
data final (keep= dataset maxdisM maxdisM_predictor DSB DSB_pred);
	set model.final_cart3;
	if maxdisM < &ds_th then DSB=0;
	else if maxdisM >= &ds_th then DSB=1;
	if maxdisM_predictor < &ds_th then DSB_pred=0;
	else if maxdisM_predictor >= &ds_th then DSB_pred=1;
run;

ods pdf file="&path\prediction accu and roc curve final CART model 7 splits.pdf";

/*Prediction accuracy for final CART model*/
title1'prediction accuracy final CART model';

proc reg data=final;
	model maxdisM=maxdisM_predictor;
run;

proc freq data=final;
	table DSB*DSB_pred /out=cellcounts;
run;

proc print data=cellcounts;run;

data cellcounts;
	set cellcounts;
	Match=0;
	if DSB=DSB_pred then Match=1;
run;

title2'percent correct classification by test dataset';
proc means data=cellcounts mean;
	freq count;
	var Match;
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

/*area under ROC curve*/
%macro roc(datain=,low_th=1,up_th=56,inc=1,
				obs_resp=,
				pred_resp=);
data roc;
	set &datain;
	do cutoff= &low_th to &up_th by &inc;
		if &obs_resp >= cutoff then obs_dis_cat=1;else obs_dis_cat=0;
		if &pred_resp >= cutoff then pred_dis_cat=1;else pred_dis_cat=0;
		output;
	end;
run;

proc sort data=roc;
	by cutoff;
run;

proc freq data=roc;
	by cutoff;
	table obs_dis_cat * pred_dis_cat /out=pcts1 outpct noprint;
run;

data truepos;
	set pcts1;
	if obs_dis_cat = 1 and pred_dis_cat = 1;
	tp_rate=pct_row/100;
	drop pct_row;
run;

data falsepos;
	set pcts1;
	if obs_dis_cat = 0 and pred_dis_cat = 1;
	fp_rate=pct_row/100;
	drop pct_row;
run;

data roc1;
	merge truepos falsepos;
	by cutoff;
	if tp_rate=. then tp_rate=0;
	if fp_rate=. then fp_rate=0;
run;

proc sgplot data=roc1;
	series x=fp_rate y=tp_rate /datalabel=cutoff;
run;
proc sgplot data=roc1;
	scatter x=fp_rate y=tp_rate /datalabel=cutoff;
run;

proc sort data=roc1;
	by fp_rate;
run;
data roc2;
	set roc1;
	segarea=((tp_rate+lag(tp_rate))/2)*(fp_rate-lag(fp_rate));
	if fp_rate=0 then segarea=.;
run;

proc means data=roc2 noprint;
	var segarea;
	output out=auc sum=auroc;
run;

title'area under roc';
proc print data=auc;
run;
title;

%mend;

title'ROC curve for final CART model';
%roc(datain=final,low_th=2,up_th=56,inc=1,
				obs_resp=maxdisM,
				pred_resp=maxdisM_predictor);
title;
ods pdf close;
/*Smooth the ROC curve and then calculate the area under the curve*/
data roc3;
	set roc1;
	if cutoff in (2,15,17,22,26,32);
run;

proc sgplot data=roc3;
	scatter x=fp_rate y=tp_rate/datalabel=cutoff;
	series x=fp_rate y=tp_rate;
run;

proc sort data=roc3;
	by fp_rate;
run;
data roc4;
	set roc3;
	segarea=((tp_rate+lag(tp_rate))/2)*(fp_rate-lag(fp_rate));
	if fp_rate=0 then segarea=.;
run;

proc means data=roc4 noprint;
	var segarea;
	output out=auc sum=auroc;
run;
proc print data=auc;run;


/*multiple split options for final cart model*/

%let ds_th=30;
data final (keep= dataset maxdisM DSB P_24_splits P_24_splits_B
									  P_20_splits P_20_splits_B
									  P_15_splits P_15_splits_B
									  P_10_splits P_10_splits_B
									  P_6_splits P_6_splits_B);

	set model.final_cart_multi_split;
	if maxdisM < &ds_th then DSB=0;
	else if maxdisM >= &ds_th then DSB=1;
	if P_24_splits < &ds_th then P_24_splits_B=0;
	else if P_24_splits >= &ds_th then P_24_splits_B=1;

	if P_20_splits < &ds_th then P_20_splits_B=0;
	else if P_20_splits >= &ds_th then P_20_splits_B=1;

		if P_15_splits < &ds_th then P_15_splits_B=0;
	else if P_15_splits >= &ds_th then P_15_splits_B=1;

		if P_10_splits < &ds_th then P_10_splits_B=0;
	else if P_10_splits >= &ds_th then P_10_splits_B=1;

		if P_6_splits < &ds_th then P_6_splits_B=0;
	else if P_6_splits >= &ds_th then P_6_splits_B=1;
run;

ods pdf file="&path\final cart model 6 splits.pdf";
title1'prediction accuracy final CART model';

%let maxdisM_predictor= P_6_splits;
%let DSB_pred= P_6_splits_B;
proc reg data=final;
	model maxdisM=&maxdisM_predictor;
run;

proc freq data=final;
	table DSB*&DSB_pred /out=cellcounts;
run;

proc print data=cellcounts;run;

data cellcounts;
	set cellcounts;
	Match=0;
	if DSB=&DSB_pred then Match=1;
run;

title2'percent correct classification by test dataset';
proc means data=cellcounts mean;
	freq count;
	var Match;
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
