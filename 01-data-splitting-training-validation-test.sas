/*Data Import*/

%let path=C:\Users\path-to-folder;

libname model excel path="&path\SNB model data standardized lati and longi.xlsx";

data snb (drop=DH audpcM mindisM YieldM testwtM tkwm testwtse residuese seedinf_mean dataset DHO);
	set model.'_SNB1$'n;
	if cultivar='Branson' then hostres=6;
	else if cultivar='SS8641' then hostres=4;
	else if cultivar='USG3438' then hostres=4;
run;

libname model clear;

%let ds_th =30;
data snb1;
	set snb;
	hostresq=hostres*hostres;
	latitudeq=slati*slati; 
	longitudeq=slongi*slongi;
	residueq=residuem*residuem;
	pcrlati=pcr*slati; pcrlongi=pcr*slongi; pcrresid=pcr*residuem; pcrhostr=pcr*hostres;
	tilllati=tillR*slati; tilllongi=tillR*slongi; tillresid=tillR*residuem;tillhostr=tillR*hostres;
	reshostr=residuem*hostres;
	if maxdisM < &ds_th then DSB=0;
	else if maxdisM >= &ds_th then DSB=1;
run;


%macro datasplit(data=,train=,testsplit=,partition=);
proc surveyselect data=&data samprate=&train out=training outall
	method=srs noprint;
run;

data model70 (drop=selected) model30 (drop=selected);
	set training;
	if selected=1 then output model70;
	else output model30;
run;

proc surveyselect data=model30 samprate=&testsplit out=test outall
	method=srs noprint;
run;

data model20 (drop=selected) model10 (drop=selected);
	set test;
	if selected=1 then output model20;
	else output model10;
run;

data model70;
	set model70;
	dataset=1;
run;
data model20;
	set model20;
	dataset=2;
run;
data model10;
	set model10;
	dataset=3;
run;

data &partition;
	set model70 model20 model10;
run;

/*Export the &partition data for JMP*/
proc export data=&partition
	outfile="&path\SNB maxdis model &partition..xlsx"
	dbms=excel label replace;
	newfile=yes;
run;
%mend datasplit;

%datasplit(data=snb1,train=0.7,testsplit=0.67,partition=partition_1);
%datasplit(data=snb1,train=0.7,testsplit=0.67,partition=partition_2);
%datasplit(data=snb1,train=0.7,testsplit=0.67,partition=partition_3);
%datasplit(data=snb1,train=0.7,testsplit=0.67,partition=partition_4);
%datasplit(data=snb1,train=0.7,testsplit=0.67,partition=partition_5);
%datasplit(data=snb1,train=0.7,testsplit=0.67,partition=partition_6);
%datasplit(data=snb1,train=0.7,testsplit=0.67,partition=partition_7);
%datasplit(data=snb1,train=0.7,testsplit=0.67,partition=partition_8);
%datasplit(data=snb1,train=0.7,testsplit=0.67,partition=partition_9);
%datasplit(data=snb1,train=0.7,testsplit=0.67,partition=partition_10);
%datasplit(data=snb1,train=0.7,testsplit=0.67,partition=partition_11);
%datasplit(data=snb1,train=0.7,testsplit=0.67,partition=partition_12);
%datasplit(data=snb1,train=0.7,testsplit=0.67,partition=partition_13);
%datasplit(data=snb1,train=0.7,testsplit=0.67,partition=partition_14);
%datasplit(data=snb1,train=0.7,testsplit=0.67,partition=partition_15);
