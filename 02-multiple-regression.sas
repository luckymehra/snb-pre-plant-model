%let path=C:\Users\path-to-folder;

%macro mreg(ds_th=, subset=);
libname model excel path="&path\SNB maxdis model partition_&subset..xlsx";

data snb;
	set model."PARTITION_&subset$"n;
run;

libname model clear;
data snb1;
	set snb;
	if maxdisM < &ds_th then DSB=0;
	else if maxdisM >= &ds_th then DSB=1;
run;

ods pdf file= "&path\MR Backward\MaxDS &ds_th th MR quad_&subset..pdf";

proc glmselect data=snb1 plots=all;
	partition roleVar=dataset(train='1' validate='2' test='3');
	model maxdisM = residuem hostres slati slongi seedtrtR seedrtR
					residueq hostresq latitudeq longitudeq
					/*residuem|hostres|slati|slongi|seedtrtR|seedrtR @2 */
					/ selection=backward (choose=validate stop=validate maxstep=26);
	output out=pred;
run;

data pred1;
	set pred;
	if p_maxdisM < &ds_th then DSB_pred=0;
	else if p_maxdisM >= &ds_th then DSB_pred=1;
run;

title1'prediction accuracy of multiple regression TEST DATA';
proc reg data=pred1 (where=(dataset=3));
	model maxdisM= p_maxdisM;
run;

proc freq data=pred1 (where=(dataset=3));
	table DSB*DSB_pred /out=cellcounts;
run;

data cellcounts;
	set cellcounts;
	match=0;
	if DSB=DSB_pred then match=1;
run;

title2'percent correct classification by test dataset';
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

%mend mreg;

%mreg(ds_th=30, subset=1);
%mreg(ds_th=30, subset=2);
%mreg(ds_th=30, subset=3);
%mreg(ds_th=30, subset=4);
%mreg(ds_th=30, subset=5);
%mreg(ds_th=30, subset=6);
%mreg(ds_th=30, subset=7);
%mreg(ds_th=30, subset=8);
%mreg(ds_th=30, subset=9);
%mreg(ds_th=30, subset=10);
%mreg(ds_th=30, subset=11);
%mreg(ds_th=30, subset=12);
%mreg(ds_th=30, subset=13);
%mreg(ds_th=30, subset=14);
%mreg(ds_th=30, subset=15);

/*final model using complete dataset*/

%let subset=1;
%let ds_th=30;
libname model excel path="&path\SNB maxdis model partition_&subset..xlsx";

data snb;
	set model."PARTITION_&subset$"n;
run;

libname model clear;

*Print minimum and maximum latitude/longitude;
proc means data=snb;
	var longitude latitude;
run;

data snb1;
	set snb;
	pcrlati_till=pcrlati*tillr; longitudeq_till=longitudeq*tillr; residueq_till=residueq*tillr;
	if maxdisM < &ds_th then DSB=0;
	else if maxdisM >= &ds_th then DSB=1;
run;


* Apply VARCLUS to orignial 8 variables +;

proc varclus data=snb1 maxeigen=0.9 short;
	var longitude latitude residueM hostres seedtrtR seedrtR tillR PCR;
run;

proc corr data=snb1 spearman nosimple;
	var longitude latitude residueM hostres seedtrtR seedrtR tillR PCR;
	with maxdisM;
run;

*try residue;
proc glmselect data=snb1;
	model maxdisM = latitude longitude residueM  hostres seedtrtR seedrtR
					latitude*latitude longitude*longitude residueM*residueM hostres*hostres
					seedtrtR*longitude seedtrtR*residueM seedtrtR*hostres
					seedrtR*longitude seedrtR*residueM seedrtR*hostres
					seedtrtR*latitude 
					seedrtR*latitude /selection=lasso (choose=adjrsq sle=0.1 sls=0.1 stop=sl);
run;
*R2 is 0.33;

*try pcr or tillr;
%let try1=pcr;
%let try2=tillR;
proc glmselect data=snb1;
	model maxdisM = latitude longitude &try1  /*&try2*/ hostres seedtrtR seedrtR
					latitude*latitude longitude*longitude hostres*hostres
					seedtrtR*longitude seedtrtR*hostres seedtrtR*latitude 
					seedrtR*longitude seedrtR*hostres seedrtR*latitude
					longitude*&try1 hostres*&try1 latitude*&try1
					/*longitude*&try2 hostres*&try2 latitude*&try2*/
					 /selection=backward;
run;
* with tillR R2 is 0.33, with pcr the R2 is 0.41;

proc reg data=snb1;
	model maxdisM = slati slongi longitudeq pcr hostres
					pcrlati pcrhostr/vif;
run;
*try the above model and check its classification accuracy;




proc glmselect data=snb1 plot=criterionpanel;
	model maxdisM= residueM residueq hostres hostresq slati slongi latitudeq longitudeq tillR PCR seedtrtR
					seedrtR pcrlati pcrlongi pcrresid pcrhostr tilllati tilllongi tillresid tillhostr reshostr 
					   /selection=stepwise;
run;

proc reg data=snb1 plot=criterionpanel;
	model maxdisM= residueM residueq hostres hostresq slati slongi latitudeq longitudeq tillR PCR seedtrtR
					seedrtR pcrlati pcrlongi pcrresid pcrhostr tilllati tilllongi tillresid tillhostr reshostr
					pcrlati_till longitudeq_till residueq_till
					/selection=stepwise;
run;



/*final model with residue as predictor (no previous crop and no tillage as predictors*/
ods pdf file="&path\MaxDS prediction using whole dataset.pdf";
proc reg data=snb1 plots=all;
	model maxdisM = slongi longitudeq residueM hostres
					;
	output out=pred p=p_maxdisM;
run;
data pred1;
	set pred;
	if p_maxdisM < &ds_th then DSB_pred=0;
	else if p_maxdisM >= &ds_th then DSB_pred=1;
run;

title1'prediction accuracy of multiple regression';
proc reg data=pred1;
	model maxdisM= p_maxdisM;
run;


proc freq data=pred1;
	table DSB*DSB_pred /out=cellcounts;
run;

proc print data=cellcounts;run;

title2'percent correct classification';
data cellcounts;
	set cellcounts;
	match=0;
	if DSB=DSB_pred then match=1;
run;
proc means data=cellcounts mean;
	freq count;
	var match;
run;

title2'sensitivity (% or true positives) of model';
data cellcounts1;
	set cellcounts;
	if DSB=1;
run;

proc means data=cellcounts1 mean;
	freq count;
	var match;
run;

title2'specificity (% or true negatives) of model';
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
/*
proc sort data=pred;
	by DSB;
run;

proc univariate data=pred normal plots;
	by DSB;
	var maxdisM;
run;

Proc means data=pred mean std;
	class DSB;
	var maxdisM;
run;*/


************************************
************************************
**         ROC Calculatiion      ***
make sure that work.pred is there before running the below program;
************************************;
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

ods pdf file="&path\roc curve for final MR model.pdf";
title'ROC curve for MR model';
%roc(datain=pred,low_th=2,up_th=56,inc=1,
				obs_resp=maxdisM,
				pred_resp=p_maxdisM);
title;
ods pdf close;

/*Smooth the ROC curve and then calculate the area under the curve*/
proc means data=roc1 mean n nmiss median;
	var tp_rate;
run;

data roc3;
	set roc1;
	if cutoff in (5,8,10,19,20,23,27,28,31,33,39,41,43);
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


************************************
************************************
**         Profit vs. Cut-off      *
************************************;
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

data trueneg;
	set pcts1;
	if obs_dis_cat=0 and pred_dis_cat=0;
	TN=count;
	TNP=percent;
	drop count percent;
run;
data truepos;
	set pcts1;
	if obs_dis_cat = 1 and pred_dis_cat = 1;
	TP=count;
	TPP=percent;
	drop count percent;
run;

data falsepos;
	set pcts1;
	if obs_dis_cat = 0 and pred_dis_cat = 1;
	FP=count;
	FPP=percent;
	drop count percent;
run;

data falseneg;
	set pcts1;
	if obs_dis_cat=1 and pred_dis_cat=0;
	FN=count;
	FNP=percent;
	drop count percent;
run;


data roc1;
	merge trueneg truepos falsepos falseneg;
	by cutoff;
	keep cutoff TN FP FN TP TNP FPP FNP TPP;
	if TN=. then do;TN=0;TNP=0;end;
	if FP=. then do;FP=0;FPP=0;end;
	if FN=. then do;FN=0;FNP=0;end;
	If TP=. then do;TP=0;TPP=0;end;
run;

data roc2;
	set roc1;
	Profit_1s=0*TN - 11*FP - 30*FN + 19*TP;
	Profit_2s=0*TN - 22*FP - 30*FN + 8*TP;
run;
/*

data roc21;
	set roc1;
	Profit_1s=((0*TNP*431) - (11*FPP*431) - (30*FNP*431) + (19*TPP*431))/100;
	Profit_2s=((0*TNP*431) - (22*FPP*431) - (30*FNP*431) + (8*TPP*431))/100;
run;

data roc22;
	set roc1(where=(cutoff=30) drop=TN TP FP FN);
	do i=10 to 2010 by 10;
		NoOfCases=i;
		Profit_1s=((0*TNP*i) - (11*FPP*i) - (30*FNP*i) + (19*TPP*i))/100;
		Profit_2s=((0*TNP*i) - (22*FPP*i) - (30*FNP*i) + (8*TPP*i))/100;
		output;
	end;
run;
*/
%let spray_cost=11;
%let yl_value=15;
data roc2;
	set roc1;
	Profit_1s=0*TN - &spray_cost *FP - &yl_value *FN + (&yl_value - &spray_cost )*TP;
	Profit_2s=0*TN - &spray_cost *FP*2 - &yl_value *FN + (&yl_value - (&spray_cost *2))*TP;
run;
ods pdf file="&path\Profit vs. cutoff 5 percent YL.pdf";
title'One-Spray profit vs. Cut-off';
proc sgplot data=roc2;
	scatter x=cutoff y=Profit_1s /datalabel=cutoff;
	series x=cutoff y=Profit_1s;
	refline 0/axis=y;
run;
title;

title'Two-Spray profit vs. Cut-off';
proc sgplot data=roc2;
	scatter x=cutoff y=Profit_2s /datalabel=cutoff;
	series x=cutoff y=Profit_2s;
	refline 0/axis=y;
run;
title;
ods pdf close;
