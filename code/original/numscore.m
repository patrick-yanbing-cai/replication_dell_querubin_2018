clear
clc
format long g

%% mod1a (MODEL-12 enemy military presence)

% Load Data
load('mod1a', 'mod1'); %vmb2 vb2 vb3 vb4 hmb1 hc4 mod1 yr
rawdata=[mod1{1}, mod1{2},mod1{3}, mod1{4}, mod1{5}, mod1{6}];
year=mod1{7}; mth=mod1{8}; score=mod1{9};  rg=mod1{10}; rctp=mod1{11}; index=mod1{12};
clear mod1

c1 = csvread('12_VMB02_cond.csv'); c2 = csvread('12_VQB02_cond.csv');
c3 = csvread('12_VQB03_cond.csv'); c4 = csvread('12_VQB04_cond.csv');
c5 = csvread('12_HMB01_cond.csv'); c6 = csvread('12_HQC04_cond.csv');

condprob=[c1;c2;c3;c4;c5;c6];

% Initialize priors
pp1=ones(length(score), 1); %set a uniform prior
pp1=pp1.*.2; pp2=pp1; pp3=pp1; pp4=pp1; pp5=pp1;

% apply Bayes rule

[dem1, dem2]=size(rawdata);	

cp_ctr=1; 
for j=1:dem2

	q=rawdata(:, j); %select the question of interest
	% Select non-missing observations for the variable j under consideration 
	pp1t=pp1(q~=999);pp2t=pp2(q~=999); pp3t=pp3(q~=999); 
	pp4t=pp4(q~=999); pp5t=pp5(q~=999); indext=index(q~=999); 
	qt=q(q~=999); 	
	resp_ctr=max(unique(qt)); % number of possible responses to the question 
	cp=condprob(cp_ctr: cp_ctr+resp_ctr-1, :);

	for i=1:resp_ctr
	    denom=pp1t(qt==i).*cp(i, 1)+pp2t(qt==i).*cp(i, 2)+pp3t(qt==i).*cp(i, 3)+pp4t(qt==i).*cp(i, 4)+pp5t(qt==i).*cp(i, 5);
	    pp1t(qt==i) = pp1t(qt==i).*cp(i, 1);  pp1t(qt==i) = pp1t(qt==i)./denom;
	    pp2t(qt==i) = pp2t(qt==i).*cp(i, 2); pp2t(qt==i) = pp2t(qt==i)./denom;
	    pp3t(qt==i) = pp3t(qt==i).*cp(i, 3); pp3t(qt==i) = pp3t(qt==i)./denom;
	    pp4t(qt==i) = pp4t(qt==i).*cp(i, 4); pp4t(qt==i) = pp4t(qt==i)./denom;
	    pp5t(qt==i) = pp5t(qt==i).*cp(i, 5); pp5t(qt==i) = pp5t(qt==i)./denom;
	end
	
	pp1(indext)=pp1t; pp2(indext)=pp2t; pp3(indext)=pp3t; 
	pp4(indext)=pp4t; pp5(indext)=pp5t;
	
	cp_ctr=cp_ctr+resp_ctr;
end

% Numerical score
num_score=pp1.*5+pp2.*4+pp3.*3+pp4.*2+pp5.*1;

num_score_round(num_score>=4.5)=5;  num_score_round(num_score>=3.5 & num_score<4.5)=4; 
num_score_round(num_score>=2.5 & num_score<3.5)=3; num_score_round(num_score>=1.5 & num_score<2.5)=2;
num_score_round(num_score<1.5)=1; num_score_round=num_score_round';

num_score_diff=num_score_round-score; match=unique(num_score_diff);
sharediff=zeros(length(num_score_diff), 1); sharediff(num_score_diff~=0)=1;  mean(sharediff)
 
data_all=[rawdata, num_score]; data_all = unique(data_all, 'rows');
csvwrite('mod1a_numscore.csv', data_all);


%% mod1b (MODEL-13 enemy military activity)

clear

% Load Data
load('mod1b', 'mod1'); %hmd1 hmb2 hmb3 hmb4 hmd1 hmd2 hmd5 vmb1 yr mth mod1b merge_h rectp counter
rawdata=[mod1{1}, mod1{2},mod1{3}, mod1{4}, mod1{5}, mod1{6},mod1{7}, mod1{8}];
year=mod1{9};
mth=mod1{10};
score=mod1{11}; 
rg=mod1{12};
rctp=mod1{13};
index=mod1{14};
clear mod1

c1 = csvread('13_HMB01_cond.csv'); c2= csvread('13_HMB02_cond.csv'); c3 = csvread('13_HMB03_cond.csv');
c4 = csvread('13_HMB04_cond.csv'); c5 = csvread('13_HMD01_cond.csv'); c6 = csvread('13_HMD02_cond.csv');
c7 = csvread('13_HMD05_cond.csv'); c8 = csvread('13_VMB01_cond.csv');
condprob=[c1;c2;c3;c4;c5;c6;c7;c8];

% Initialize priors
pp1=ones(length(score), 1); %set a uniform prior
pp1=pp1.*.2; pp2=pp1; pp3=pp1; pp4=pp1; pp5=pp1;

% apply Bayes rule

[dem1, dem2]=size(rawdata);	

cp_ctr=1; 
for j=1:dem2

	q=rawdata(:, j); %select the question of interest
	% Select non-missing observations for the variable j under consideration 
	pp1t=pp1(q~=999);pp2t=pp2(q~=999); pp3t=pp3(q~=999); 
	pp4t=pp4(q~=999); pp5t=pp5(q~=999); indext=index(q~=999); 
	qt=q(q~=999); 	
	resp_ctr=max(unique(qt)); % number of possible responses to the question 
	cp=condprob(cp_ctr: cp_ctr+resp_ctr-1, :);

	for i=1:resp_ctr
	    denom=pp1t(qt==i).*cp(i, 1)+pp2t(qt==i).*cp(i, 2)+pp3t(qt==i).*cp(i, 3)+pp4t(qt==i).*cp(i, 4)+pp5t(qt==i).*cp(i, 5);
	    pp1t(qt==i) = pp1t(qt==i).*cp(i, 1);  pp1t(qt==i) = pp1t(qt==i)./denom;
	    pp2t(qt==i) = pp2t(qt==i).*cp(i, 2); pp2t(qt==i) = pp2t(qt==i)./denom;
	    pp3t(qt==i) = pp3t(qt==i).*cp(i, 3); pp3t(qt==i) = pp3t(qt==i)./denom;
	    pp4t(qt==i) = pp4t(qt==i).*cp(i, 4); pp4t(qt==i) = pp4t(qt==i)./denom;
	    pp5t(qt==i) = pp5t(qt==i).*cp(i, 5); pp5t(qt==i) = pp5t(qt==i)./denom;
	end
	
	pp1(indext)=pp1t; pp2(indext)=pp2t; pp3(indext)=pp3t; 
	pp4(indext)=pp4t; pp5(indext)=pp5t;
	
	cp_ctr=cp_ctr+resp_ctr;
end

% Numerical score
num_score=pp1.*5+pp2.*4+pp3.*3+pp4.*2+pp5.*1;

num_score_round(num_score>=4.5)=5;  num_score_round(num_score>=3.5 & num_score<4.5)=4; 
num_score_round(num_score>=2.5 & num_score<3.5)=3; num_score_round(num_score>=1.5 & num_score<2.5)=2;
num_score_round(num_score<1.5)=1; num_score_round=num_score_round';

num_score_diff=num_score_round-score; match=unique(num_score_diff);
sharediff=zeros(length(num_score_diff), 1); sharediff(num_score_diff~=0)=1;  mean(sharediff)
 
data_all=[rawdata, num_score]; data_all = unique(data_all, 'rows');
csvwrite('mod1b_numscore.csv', data_all);


%% mod1c (MODEL-13 enemy military activity)

clear

% Load Data
load('mod1c', 'mod1'); 
% hmc1 hmc2 hmd1 hmd2 hmd3 hmd4 hmd6 hmd7 hd5 hr5 vmb2 vmc2 vt6
rawdata=[mod1{1}, mod1{2},mod1{3}, mod1{4}, mod1{5}, mod1{6},mod1{7}, mod1{8}, mod1{9}, mod1{10},mod1{11}, mod1{12}, mod1{13}];
year=mod1{14};mth=mod1{15};score=mod1{16}; rg=mod1{17};rctp=mod1{18};index=mod1{19};
clear mod1

c1 = csvread('14_HMC01_cond.csv');c2 = csvread('14_HMC02_cond.csv');c3 = csvread('14_HMD01_cond.csv');
c4 = csvread('14_HMD02_cond.csv');c5 = csvread('14_HMD03_cond.csv');c6 = csvread('14_HMD04_cond.csv');
c7 = csvread('14_HMD06_cond.csv');c8 = csvread('14_HMD07_cond.csv');c9 = csvread('14_HQD05_cond.csv');
c10 = csvread('14_HQR05_cond.csv');c11 = csvread('14_VMB02_cond.csv');c12 = csvread('14_VMC02_cond.csv');
c13 = csvread('14_VQT06_cond.csv');
condprob=[c1;c2;c3;c4;c5;c6;c7;c8;c9;c10;c11;c12;c13];

% Initialize priors
pp1=ones(length(score), 1); %set a uniform prior
pp1=pp1.*.2; pp2=pp1; pp3=pp1; pp4=pp1; pp5=pp1;

% apply Bayes rule

[dem1, dem2]=size(rawdata);	

cp_ctr=1; 
for j=1:dem2

	q=rawdata(:, j); %select the question of interest
	% Select non-missing observations for the variable j under consideration 
	pp1t=pp1(q~=999);pp2t=pp2(q~=999); pp3t=pp3(q~=999); 
	pp4t=pp4(q~=999); pp5t=pp5(q~=999); indext=index(q~=999); 
	qt=q(q~=999); 	
	resp_ctr=max(unique(qt)); % number of possible responses to the question 
	cp=condprob(cp_ctr: cp_ctr+resp_ctr-1, :);

	for i=1:resp_ctr
	    denom=pp1t(qt==i).*cp(i, 1)+pp2t(qt==i).*cp(i, 2)+pp3t(qt==i).*cp(i, 3)+pp4t(qt==i).*cp(i, 4)+pp5t(qt==i).*cp(i, 5);
	    pp1t(qt==i) = pp1t(qt==i).*cp(i, 1);  pp1t(qt==i) = pp1t(qt==i)./denom;
	    pp2t(qt==i) = pp2t(qt==i).*cp(i, 2); pp2t(qt==i) = pp2t(qt==i)./denom;
	    pp3t(qt==i) = pp3t(qt==i).*cp(i, 3); pp3t(qt==i) = pp3t(qt==i)./denom;
	    pp4t(qt==i) = pp4t(qt==i).*cp(i, 4); pp4t(qt==i) = pp4t(qt==i)./denom;
	    pp5t(qt==i) = pp5t(qt==i).*cp(i, 5); pp5t(qt==i) = pp5t(qt==i)./denom;
	end
	
	pp1(indext)=pp1t; pp2(indext)=pp2t; pp3(indext)=pp3t; 
	pp4(indext)=pp4t; pp5(indext)=pp5t;
	
	cp_ctr=cp_ctr+resp_ctr;
end

% Numerical score
num_score=pp1.*5+pp2.*4+pp3.*3+pp4.*2+pp5.*1;

num_score_round(num_score>=4.5)=5;  num_score_round(num_score>=3.5 & num_score<4.5)=4; 
num_score_round(num_score>=2.5 & num_score<3.5)=3; num_score_round(num_score>=1.5 & num_score<2.5)=2;
num_score_round(num_score<1.5)=1; num_score_round=num_score_round';

num_score_diff=num_score_round-score; match=unique(num_score_diff);
sharediff=zeros(length(num_score_diff), 1); sharediff(num_score_diff~=0)=1;  mean(sharediff)
 
data_all=[rawdata, num_score]; data_all = unique(data_all, 'rows');
csvwrite('mod1c_numscore.csv', data_all);

%% mod1d (MODEL-13 enemy military activity)

clear 

% Load Raw Data
% hmd7 hc1 hc2 hc3 hc4 hc5 he2 vc1 vc2 vc3 vc4 vc5 vc6
load('mod1d', 'mod1'); 
rawdata=[mod1{1}, mod1{2},mod1{3}, mod1{4}, mod1{5}, mod1{6},mod1{7}, mod1{8}, mod1{9}, mod1{10},mod1{11}, mod1{12}, mod1{13}];
year=mod1{14}; mth=mod1{15}; score=mod1{16}; rg=mod1{17}; rctp=mod1{18}; index=mod1{19};
clear mod1

% Load conditional probability data
c1 = csvread('15_HMD07_cond.csv'); c2 = csvread('15_HQC01_cond.csv'); c3 = csvread('15_HQC02_cond.csv');
c4 = csvread('15_HQC03_cond.csv'); c5 = csvread('15_HQC04_cond.csv'); c6 = csvread('15_HQC05_cond.csv');
c7 = csvread('15_HQE02_cond.csv'); c8 = csvread('15_VQC01_cond.csv'); c9 = csvread('15_VQC02_cond.csv');
c10 = csvread('15_VQC03_cond.csv'); c11 = csvread('15_VQC04_cond.csv'); c12 = csvread('15_VQC05_cond.csv');
c13 = csvread('15_VQC06_cond.csv');
condprob=[c1;c2;c3;c4;c5;c6;c7;c8;c9;c10;c11;c12;c13];

% Initialize priors
pp1=ones(length(score), 1); %set a uniform prior
pp1=pp1.*.2; pp2=pp1; pp3=pp1; pp4=pp1; pp5=pp1;

% apply Bayes rule

[dem1, dem2]=size(rawdata);	

cp_ctr=1; 
for j=1:dem2

	q=rawdata(:, j); %select the question of interest
	% Select non-missing observations for the variable j under consideration 
	pp1t=pp1(q~=999);pp2t=pp2(q~=999); pp3t=pp3(q~=999); 
	pp4t=pp4(q~=999); pp5t=pp5(q~=999); indext=index(q~=999); 
	qt=q(q~=999); 	
	resp_ctr=max(unique(qt)); % number of possible responses to the question 
	cp=condprob(cp_ctr: cp_ctr+resp_ctr-1, :);

	for i=1:resp_ctr
	    denom=pp1t(qt==i).*cp(i, 1)+pp2t(qt==i).*cp(i, 2)+pp3t(qt==i).*cp(i, 3)+pp4t(qt==i).*cp(i, 4)+pp5t(qt==i).*cp(i, 5);
	    pp1t(qt==i) = pp1t(qt==i).*cp(i, 1);  pp1t(qt==i) = pp1t(qt==i)./denom;
	    pp2t(qt==i) = pp2t(qt==i).*cp(i, 2); pp2t(qt==i) = pp2t(qt==i)./denom;
	    pp3t(qt==i) = pp3t(qt==i).*cp(i, 3); pp3t(qt==i) = pp3t(qt==i)./denom;
	    pp4t(qt==i) = pp4t(qt==i).*cp(i, 4); pp4t(qt==i) = pp4t(qt==i)./denom;
	    pp5t(qt==i) = pp5t(qt==i).*cp(i, 5); pp5t(qt==i) = pp5t(qt==i)./denom;
	end
	
	pp1(indext)=pp1t; pp2(indext)=pp2t; pp3(indext)=pp3t; 
	pp4(indext)=pp4t; pp5(indext)=pp5t;
	
	cp_ctr=cp_ctr+resp_ctr;
end

% Numerical score
num_score=pp1.*5+pp2.*4+pp3.*3+pp4.*2+pp5.*1;

num_score_round(num_score>=4.5)=5;  num_score_round(num_score>=3.5 & num_score<4.5)=4; 
num_score_round(num_score>=2.5 & num_score<3.5)=3; num_score_round(num_score>=1.5 & num_score<2.5)=2;
num_score_round(num_score<1.5)=1; num_score_round=num_score_round';

num_score_diff=num_score_round-score; match=unique(num_score_diff);
sharediff=zeros(length(num_score_diff), 1); sharediff(num_score_diff~=0)=1;  mean(sharediff)
 
data_all=[rawdata, num_score]; data_all = unique(data_all, 'rows');
csvwrite('mod1d_numscore.csv', data_all);


%% mod1e (MODEL-13 enemy military activity)

clear 

% Load Data
load('mod1e', 'mod1'); 
% hmc3 hmd3 hmd4 hmd5 hc2 hc3 vmc1 vmc2
rawdata=[mod1{1}, mod1{2},mod1{3}, mod1{4}, mod1{5}, mod1{6},mod1{7}, mod1{8}];
year=mod1{9}; mth=mod1{10}; score=mod1{11}; rg=mod1{12}; rctp=mod1{13}; index=mod1{14};
clear mod1

% Load conditional probability data
c1 = csvread('16_HMC03_cond.csv'); c2 = csvread('16_HMD03_cond.csv'); c3 = csvread('16_HMD04_cond.csv');
c4 = csvread('16_HMD05_cond.csv'); c5 = csvread('16_HQC02_cond.csv'); c6 = csvread('16_HQC03_cond.csv');
c7 = csvread('16_VMC01_cond.csv'); c8 = csvread('16_VMC02_cond.csv');
condprob=[c1;c2;c3;c4;c5;c6;c7;c8];

% Initialize priors
pp1=ones(length(score), 1); %set a uniform prior
pp1=pp1.*.2; pp2=pp1; pp3=pp1; pp4=pp1; pp5=pp1;

% apply Bayes rule

[dem1, dem2]=size(rawdata);	

cp_ctr=1; 
for j=1:dem2

	q=rawdata(:, j); %select the question of interest
	% Select non-missing observations for the variable j under consideration 
	pp1t=pp1(q~=999);pp2t=pp2(q~=999); pp3t=pp3(q~=999); 
	pp4t=pp4(q~=999); pp5t=pp5(q~=999); indext=index(q~=999); 
	qt=q(q~=999); 	
	resp_ctr=max(unique(qt)); % number of possible responses to the question 
	cp=condprob(cp_ctr: cp_ctr+resp_ctr-1, :);

	for i=1:resp_ctr
	    denom=pp1t(qt==i).*cp(i, 1)+pp2t(qt==i).*cp(i, 2)+pp3t(qt==i).*cp(i, 3)+pp4t(qt==i).*cp(i, 4)+pp5t(qt==i).*cp(i, 5);
	    pp1t(qt==i) = pp1t(qt==i).*cp(i, 1);  pp1t(qt==i) = pp1t(qt==i)./denom;
	    pp2t(qt==i) = pp2t(qt==i).*cp(i, 2); pp2t(qt==i) = pp2t(qt==i)./denom;
	    pp3t(qt==i) = pp3t(qt==i).*cp(i, 3); pp3t(qt==i) = pp3t(qt==i)./denom;
	    pp4t(qt==i) = pp4t(qt==i).*cp(i, 4); pp4t(qt==i) = pp4t(qt==i)./denom;
	    pp5t(qt==i) = pp5t(qt==i).*cp(i, 5); pp5t(qt==i) = pp5t(qt==i)./denom;
	end
	
	pp1(indext)=pp1t; pp2(indext)=pp2t; pp3(indext)=pp3t; 
	pp4(indext)=pp4t; pp5(indext)=pp5t;
	
	cp_ctr=cp_ctr+resp_ctr;
end

% Numerical score
num_score=pp1.*5+pp2.*4+pp3.*3+pp4.*2+pp5.*1;

num_score_round(num_score>=4.5)=5;  num_score_round(num_score>=3.5 & num_score<4.5)=4; 
num_score_round(num_score>=2.5 & num_score<3.5)=3; num_score_round(num_score>=1.5 & num_score<2.5)=2;
num_score_round(num_score<1.5)=1; num_score_round=num_score_round';

num_score_diff=num_score_round-score; match=unique(num_score_diff);
sharediff=zeros(length(num_score_diff), 1); sharediff(num_score_diff~=0)=1;  mean(sharediff)
 
data_all=[rawdata, num_score]; data_all = unique(data_all, 'rows');
csvwrite('mod1e_numscore.csv', data_all);


%% MOD1F 1971 (=MODEL-17 law enforcement)

clear 

% Load Data
load('mod1f71', 'mod1'); 
rawdata=[mod1{1}, mod1{2},mod1{3}, mod1{4}, mod1{5}, mod1{6},mod1{7}, mod1{8}, mod1{9}];
year=mod1{10}; mth=mod1{11}; score=mod1{12}; rg=mod1{13}; rctp=mod1{14}; index=mod1{15};
clear mod1

%conditional probs
c1 = csvread('17_HQD01_cond.csv'); c2 = csvread('17_HQD02_cond.csv'); c3 = csvread('17_HQD03_cond.csv');
c4 = csvread('17_HQD04_cond.csv'); c5 = csvread('17_VQD01_cond.csv'); c6 = csvread('17_VQD02_cond.csv');
c7 = csvread('17_VQD04_cond.csv'); c8 = csvread('17_VQD05_cond.csv'); c9 = csvread('17_VQD06_cond.csv');
condprob=[c1;c2;c3;c4;c5;c6;c7;c8;c9];

% Initialize priors
pp1=ones(length(score), 1); %set a uniform prior
pp1=pp1.*.2; pp2=pp1; pp3=pp1; pp4=pp1; pp5=pp1;

% apply Bayes rule

[dem1, dem2]=size(rawdata);	

cp_ctr=1; 
for j=1:dem2

	q=rawdata(:, j); %select the question of interest
	% Select non-missing observations for the variable j under consideration 
	pp1t=pp1(q~=999);pp2t=pp2(q~=999); pp3t=pp3(q~=999); 
	pp4t=pp4(q~=999); pp5t=pp5(q~=999); indext=index(q~=999); 
	qt=q(q~=999); 	
	resp_ctr=max(unique(qt)); % number of possible responses to the question 
	cp=condprob(cp_ctr: cp_ctr+resp_ctr-1, :);

	for i=1:resp_ctr
	    denom=pp1t(qt==i).*cp(i, 1)+pp2t(qt==i).*cp(i, 2)+pp3t(qt==i).*cp(i, 3)+pp4t(qt==i).*cp(i, 4)+pp5t(qt==i).*cp(i, 5);
	    pp1t(qt==i) = pp1t(qt==i).*cp(i, 1);  pp1t(qt==i) = pp1t(qt==i)./denom;
	    pp2t(qt==i) = pp2t(qt==i).*cp(i, 2); pp2t(qt==i) = pp2t(qt==i)./denom;
	    pp3t(qt==i) = pp3t(qt==i).*cp(i, 3); pp3t(qt==i) = pp3t(qt==i)./denom;
	    pp4t(qt==i) = pp4t(qt==i).*cp(i, 4); pp4t(qt==i) = pp4t(qt==i)./denom;
	    pp5t(qt==i) = pp5t(qt==i).*cp(i, 5); pp5t(qt==i) = pp5t(qt==i)./denom;
	end
	
	pp1(indext)=pp1t; pp2(indext)=pp2t; pp3(indext)=pp3t; 
	pp4(indext)=pp4t; pp5(indext)=pp5t;
	
	cp_ctr=cp_ctr+resp_ctr;
end

% Numerical score
num_score=pp1.*5+pp2.*4+pp3.*3+pp4.*2+pp5.*1;

num_score_round(num_score>=4.5)=5;  num_score_round(num_score>=3.5 & num_score<4.5)=4; 
num_score_round(num_score>=2.5 & num_score<3.5)=3; num_score_round(num_score>=1.5 & num_score<2.5)=2;
num_score_round(num_score<1.5)=1; num_score_round=num_score_round';

num_score_diff=num_score_round-score; match=unique(num_score_diff);
sharediff=zeros(length(num_score_diff), 1); sharediff(num_score_diff~=0)=1;  mean(sharediff)
 
data_all=[rawdata, num_score]; data_all = unique(data_all, 'rows');
csvwrite('mod1f71_numscore.csv', data_all);

%% MOD1F 1970 (=MODEL-17 law enforcement)

clear 

% Load Data
load('mod1f70', 'mod1'); 
rawdata=[mod1{1}, mod1{2},mod1{3}, mod1{4}, mod1{5}, mod1{6},mod1{7}, mod1{8}, mod1{9}, mod1{10}];
year=mod1{11}; mth=mod1{12}; score=mod1{13}; rg=mod1{14}; rctp=mod1{15}; index=mod1{16};
clear mod1

%conditional probs
c1 = csvread('17_HQD01_cond.csv'); c2 = csvread('17_HQD02_cond.csv'); c3 = csvread('17_HQD03_cond.csv');
c4 = csvread('17_HQD04_cond.csv'); c5 = csvread('17_HQE03_cond.csv');
c6 = csvread('17_VQD01_cond.csv'); c7 = csvread('17_VQD02_cond.csv');
c8 = csvread('17_VQD04_cond.csv'); c9 = csvread('17_VQD05_cond.csv'); c10 = csvread('17_VQD06_cond.csv');
condprob=[c1;c2;c3;c4;c5;c6;c7;c8;c9;c10];

% Initialize priors
pp1=ones(length(score), 1); %set a uniform prior
pp1=pp1.*.2; pp2=pp1; pp3=pp1; pp4=pp1; pp5=pp1;

% apply Bayes rule

[dem1, dem2]=size(rawdata);	

cp_ctr=1; 
for j=1:dem2

	q=rawdata(:, j); %select the question of interest
	% Select non-missing observations for the variable j under consideration 
	pp1t=pp1(q~=999);pp2t=pp2(q~=999); pp3t=pp3(q~=999); 
	pp4t=pp4(q~=999); pp5t=pp5(q~=999); indext=index(q~=999); 
	qt=q(q~=999); 	
	resp_ctr=max(unique(qt)); % number of possible responses to the question 
	cp=condprob(cp_ctr: cp_ctr+resp_ctr-1, :);

	for i=1:resp_ctr
	    denom=pp1t(qt==i).*cp(i, 1)+pp2t(qt==i).*cp(i, 2)+pp3t(qt==i).*cp(i, 3)+pp4t(qt==i).*cp(i, 4)+pp5t(qt==i).*cp(i, 5);
	    pp1t(qt==i) = pp1t(qt==i).*cp(i, 1);  pp1t(qt==i) = pp1t(qt==i)./denom;
	    pp2t(qt==i) = pp2t(qt==i).*cp(i, 2); pp2t(qt==i) = pp2t(qt==i)./denom;
	    pp3t(qt==i) = pp3t(qt==i).*cp(i, 3); pp3t(qt==i) = pp3t(qt==i)./denom;
	    pp4t(qt==i) = pp4t(qt==i).*cp(i, 4); pp4t(qt==i) = pp4t(qt==i)./denom;
	    pp5t(qt==i) = pp5t(qt==i).*cp(i, 5); pp5t(qt==i) = pp5t(qt==i)./denom;
	end
	
	pp1(indext)=pp1t; pp2(indext)=pp2t; pp3(indext)=pp3t; 
	pp4(indext)=pp4t; pp5(indext)=pp5t;
	
	cp_ctr=cp_ctr+resp_ctr;
end

% Numerical score
num_score=pp1.*5+pp2.*4+pp3.*3+pp4.*2+pp5.*1;

num_score_round(num_score>=4.5)=5;  num_score_round(num_score>=3.5 & num_score<4.5)=4; 
num_score_round(num_score>=2.5 & num_score<3.5)=3; num_score_round(num_score>=1.5 & num_score<2.5)=2;
num_score_round(num_score<1.5)=1; num_score_round=num_score_round';

num_score_diff=num_score_round-score; match=unique(num_score_diff);
sharediff=zeros(length(num_score_diff), 1); sharediff(num_score_diff~=0)=1;  mean(sharediff)
 
data_all=[rawdata, num_score]; data_all = unique(data_all, 'rows');
csvwrite('mod1f70_numscore.csv', data_all);

%% MOD1G

clear 

% Load Data
load('mod1g', 'mod1'); 
rawdata=[mod1{1}, mod1{2},mod1{3}];
year=mod1{4}; mth=mod1{5}; score=mod1{6}; rg=mod1{7}; rctp=mod1{8}; index=mod1{9};
clear mod1
c1 = csvread('18_HMC04_cond.csv'); c2 = csvread('18_HQC06_cond.csv'); c3 = csvread('18_HQC07_cond.csv');
condprob=[c1;c2;c3];

% Initialize priors
pp1=ones(length(score), 1); %set a uniform prior
pp1=pp1.*.2; pp2=pp1; pp3=pp1; pp4=pp1; pp5=pp1;

% apply Bayes rule

[dem1, dem2]=size(rawdata);	

cp_ctr=1; 
for j=1:dem2

	q=rawdata(:, j); %select the question of interest
	% Select non-missing observations for the variable j under consideration 
	pp1t=pp1(q~=999);pp2t=pp2(q~=999); pp3t=pp3(q~=999); 
	pp4t=pp4(q~=999); pp5t=pp5(q~=999); indext=index(q~=999); 
	qt=q(q~=999); 	
	resp_ctr=max(unique(qt)); % number of possible responses to the question 
	cp=condprob(cp_ctr: cp_ctr+resp_ctr-1, :);

	for i=1:resp_ctr
	    denom=pp1t(qt==i).*cp(i, 1)+pp2t(qt==i).*cp(i, 2)+pp3t(qt==i).*cp(i, 3)+pp4t(qt==i).*cp(i, 4)+pp5t(qt==i).*cp(i, 5);
	    pp1t(qt==i) = pp1t(qt==i).*cp(i, 1);  pp1t(qt==i) = pp1t(qt==i)./denom;
	    pp2t(qt==i) = pp2t(qt==i).*cp(i, 2); pp2t(qt==i) = pp2t(qt==i)./denom;
	    pp3t(qt==i) = pp3t(qt==i).*cp(i, 3); pp3t(qt==i) = pp3t(qt==i)./denom;
	    pp4t(qt==i) = pp4t(qt==i).*cp(i, 4); pp4t(qt==i) = pp4t(qt==i)./denom;
	    pp5t(qt==i) = pp5t(qt==i).*cp(i, 5); pp5t(qt==i) = pp5t(qt==i)./denom;
	end
	
	pp1(indext)=pp1t; pp2(indext)=pp2t; pp3(indext)=pp3t; 
	pp4(indext)=pp4t; pp5(indext)=pp5t;
	
	cp_ctr=cp_ctr+resp_ctr;
end

% Numerical score
num_score=pp1.*5+pp2.*4+pp3.*3+pp4.*2+pp5.*1;

num_score_round(num_score>=4.5)=5;  num_score_round(num_score>=3.5 & num_score<4.5)=4; 
num_score_round(num_score>=2.5 & num_score<3.5)=3; num_score_round(num_score>=1.5 & num_score<2.5)=2;
num_score_round(num_score<1.5)=1; num_score_round=num_score_round';

num_score_diff=num_score_round-score; match=unique(num_score_diff);
sharediff=zeros(length(num_score_diff), 1); sharediff(num_score_diff~=0)=1;  mean(sharediff)
 
data_all=[rawdata, num_score]; data_all = unique(data_all, 'rows');
csvwrite('mod1g_numscore.csv', data_all);

%% MOD1H 1971
clear 

% Load Data
load('mod1h71', 'mod1'); 
rawdata=[mod1{1}, mod1{2},mod1{3}, mod1{4}, mod1{5}, mod1{6},mod1{7}];
year=mod1{8}; mth=mod1{9}; score=mod1{10}; rg=mod1{11}; rctp=mod1{12}; index=mod1{13};
clear mod1
c1 = csvread('19_HQB01_cond.csv'); c2 = csvread('19_HQB02_cond.csv'); c3 = csvread('19_HQB03_cond.csv');
c4 = csvread('19_HQF01_cond.csv'); c5 = csvread('19_HQF02_cond.csv'); c6 = csvread('19_VQB01_cond.csv');
c7 = csvread('19_VQB05_cond.csv'); 
condprob=[c1;c2;c3;c4;c5;c6;c7];

% Initialize priors
pp1=ones(length(score), 1); %set a uniform prior
pp1=pp1.*.2; pp2=pp1; pp3=pp1; pp4=pp1; pp5=pp1;

% apply Bayes rule

[dem1, dem2]=size(rawdata);	

cp_ctr=1; 
for j=1:dem2

	q=rawdata(:, j); %select the question of interest
	% Select non-missing observations for the variable j under consideration 
	pp1t=pp1(q~=999);pp2t=pp2(q~=999); pp3t=pp3(q~=999); 
	pp4t=pp4(q~=999); pp5t=pp5(q~=999); indext=index(q~=999); 
	qt=q(q~=999); 	
	resp_ctr=max(unique(qt)); % number of possible responses to the question 
	cp=condprob(cp_ctr: cp_ctr+resp_ctr-1, :);

	for i=1:resp_ctr
	    denom=pp1t(qt==i).*cp(i, 1)+pp2t(qt==i).*cp(i, 2)+pp3t(qt==i).*cp(i, 3)+pp4t(qt==i).*cp(i, 4)+pp5t(qt==i).*cp(i, 5);
	    pp1t(qt==i) = pp1t(qt==i).*cp(i, 1);  pp1t(qt==i) = pp1t(qt==i)./denom;
	    pp2t(qt==i) = pp2t(qt==i).*cp(i, 2); pp2t(qt==i) = pp2t(qt==i)./denom;
	    pp3t(qt==i) = pp3t(qt==i).*cp(i, 3); pp3t(qt==i) = pp3t(qt==i)./denom;
	    pp4t(qt==i) = pp4t(qt==i).*cp(i, 4); pp4t(qt==i) = pp4t(qt==i)./denom;
	    pp5t(qt==i) = pp5t(qt==i).*cp(i, 5); pp5t(qt==i) = pp5t(qt==i)./denom;
	end
	
	pp1(indext)=pp1t; pp2(indext)=pp2t; pp3(indext)=pp3t; 
	pp4(indext)=pp4t; pp5(indext)=pp5t;
	
	cp_ctr=cp_ctr+resp_ctr;
end

% Numerical score
num_score=pp1.*5+pp2.*4+pp3.*3+pp4.*2+pp5.*1;

num_score_round(num_score>=4.5)=5;  num_score_round(num_score>=3.5 & num_score<4.5)=4; 
num_score_round(num_score>=2.5 & num_score<3.5)=3; num_score_round(num_score>=1.5 & num_score<2.5)=2;
num_score_round(num_score<1.5)=1; num_score_round=num_score_round';

num_score_diff=num_score_round-score; match=unique(num_score_diff);
sharediff=zeros(length(num_score_diff), 1); sharediff(num_score_diff~=0)=1;  mean(sharediff)
 
data_all=[rawdata, num_score]; data_all = unique(data_all, 'rows');
csvwrite('mod1h71_numscore.csv', data_all);

%% MOD1H 1970
clear 

% Load Data
load('mod1h70', 'mod1'); 
rawdata=[mod1{1}, mod1{2},mod1{3}, mod1{4}, mod1{5}, mod1{6},mod1{7}, mod1{8}];
year=mod1{9}; mth=mod1{10}; score=mod1{11}; rg=mod1{12}; rctp=mod1{13}; index=mod1{14};
clear mod1
c1 = csvread('19_HQB01_cond.csv'); c2 = csvread('19_HQB02_cond.csv'); c3 = csvread('19_HQB03_cond.csv');
c4 = csvread('19_HQE03_cond.csv');
c5 = csvread('19_HQF01_cond.csv'); c6 = csvread('19_HQF02_cond.csv'); c7 = csvread('19_VQB01_cond.csv');
c8 = csvread('19_VQB05_cond.csv'); 
condprob=[c1;c2;c3;c4;c5;c6;c7;c8];

% Initialize priors
pp1=ones(length(score), 1); %set a uniform prior
pp1=pp1.*.2; pp2=pp1; pp3=pp1; pp4=pp1; pp5=pp1;

% apply Bayes rule

[dem1, dem2]=size(rawdata);	

cp_ctr=1; 
for j=1:dem2

	q=rawdata(:, j); %select the question of interest
	% Select non-missing observations for the variable j under consideration 
	pp1t=pp1(q~=999);pp2t=pp2(q~=999); pp3t=pp3(q~=999); 
	pp4t=pp4(q~=999); pp5t=pp5(q~=999); indext=index(q~=999); 
	qt=q(q~=999); 	
	resp_ctr=max(unique(qt)); % number of possible responses to the question 
	cp=condprob(cp_ctr: cp_ctr+resp_ctr-1, :);

	for i=1:resp_ctr
	    denom=pp1t(qt==i).*cp(i, 1)+pp2t(qt==i).*cp(i, 2)+pp3t(qt==i).*cp(i, 3)+pp4t(qt==i).*cp(i, 4)+pp5t(qt==i).*cp(i, 5);
	    pp1t(qt==i) = pp1t(qt==i).*cp(i, 1);  pp1t(qt==i) = pp1t(qt==i)./denom;
	    pp2t(qt==i) = pp2t(qt==i).*cp(i, 2); pp2t(qt==i) = pp2t(qt==i)./denom;
	    pp3t(qt==i) = pp3t(qt==i).*cp(i, 3); pp3t(qt==i) = pp3t(qt==i)./denom;
	    pp4t(qt==i) = pp4t(qt==i).*cp(i, 4); pp4t(qt==i) = pp4t(qt==i)./denom;
	    pp5t(qt==i) = pp5t(qt==i).*cp(i, 5); pp5t(qt==i) = pp5t(qt==i)./denom;
	end
	
	pp1(indext)=pp1t; pp2(indext)=pp2t; pp3(indext)=pp3t; 
	pp4(indext)=pp4t; pp5(indext)=pp5t;
	
	cp_ctr=cp_ctr+resp_ctr;
end

% Numerical score
num_score=pp1.*5+pp2.*4+pp3.*3+pp4.*2+pp5.*1;

num_score_round(num_score>=4.5)=5;  num_score_round(num_score>=3.5 & num_score<4.5)=4; 
num_score_round(num_score>=2.5 & num_score<3.5)=3; num_score_round(num_score>=1.5 & num_score<2.5)=2;
num_score_round(num_score<1.5)=1; num_score_round=num_score_round';

num_score_diff=num_score_round-score; match=unique(num_score_diff);
sharediff=zeros(length(num_score_diff), 1); sharediff(num_score_diff~=0)=1;  mean(sharediff)
 
data_all=[rawdata, num_score]; data_all = unique(data_all, 'rows');
csvwrite('mod1h70_numscore.csv', data_all);

%% MOD1I
clear 

% Load Data
load('mod1i', 'mod1'); 
rawdata=[mod1{1}, mod1{2},mod1{3}, mod1{4}, mod1{5}, mod1{6}];
year=mod1{7}; mth=mod1{8}; score=mod1{9}; rg=mod1{10}; rctp=mod1{11}; index=mod1{12};
clear mod1
c1 = csvread('20_HMB05_cond.csv'); c2 = csvread('20_HMB06_cond.csv'); c3 = csvread('20_HMB07_cond.csv');
c4 = csvread('20_HMB08_cond.csv'); c5 = csvread('20_HQB01_cond.csv'); c6 = csvread('20_VQB01_cond.csv');
condprob=[c1;c2;c3;c4;c5;c6];

% Initialize priors
pp1=ones(length(score), 1); %set a uniform prior
pp1=pp1.*.2; pp2=pp1; pp3=pp1; pp4=pp1; pp5=pp1;

% apply Bayes rule

[dem1, dem2]=size(rawdata);	

cp_ctr=1; 
for j=1:dem2

	q=rawdata(:, j); %select the question of interest
	% Select non-missing observations for the variable j under consideration 
	pp1t=pp1(q~=999);pp2t=pp2(q~=999); pp3t=pp3(q~=999); 
	pp4t=pp4(q~=999); pp5t=pp5(q~=999); indext=index(q~=999); 
	qt=q(q~=999); 	
	resp_ctr=max(unique(qt)); % number of possible responses to the question 
	cp=condprob(cp_ctr: cp_ctr+resp_ctr-1, :);

	for i=1:resp_ctr
	    denom=pp1t(qt==i).*cp(i, 1)+pp2t(qt==i).*cp(i, 2)+pp3t(qt==i).*cp(i, 3)+pp4t(qt==i).*cp(i, 4)+pp5t(qt==i).*cp(i, 5);
	    pp1t(qt==i) = pp1t(qt==i).*cp(i, 1);  pp1t(qt==i) = pp1t(qt==i)./denom;
	    pp2t(qt==i) = pp2t(qt==i).*cp(i, 2); pp2t(qt==i) = pp2t(qt==i)./denom;
	    pp3t(qt==i) = pp3t(qt==i).*cp(i, 3); pp3t(qt==i) = pp3t(qt==i)./denom;
	    pp4t(qt==i) = pp4t(qt==i).*cp(i, 4); pp4t(qt==i) = pp4t(qt==i)./denom;
	    pp5t(qt==i) = pp5t(qt==i).*cp(i, 5); pp5t(qt==i) = pp5t(qt==i)./denom;
	end
	
	pp1(indext)=pp1t; pp2(indext)=pp2t; pp3(indext)=pp3t; 
	pp4(indext)=pp4t; pp5(indext)=pp5t;
	
	cp_ctr=cp_ctr+resp_ctr;
end

% Numerical score
num_score=pp1.*5+pp2.*4+pp3.*3+pp4.*2+pp5.*1;

num_score_round(num_score>=4.5)=5;  num_score_round(num_score>=3.5 & num_score<4.5)=4; 
num_score_round(num_score>=2.5 & num_score<3.5)=3; num_score_round(num_score>=1.5 & num_score<2.5)=2;
num_score_round(num_score<1.5)=1; num_score_round=num_score_round';

num_score_diff=num_score_round-score; match=unique(num_score_diff);
sharediff=zeros(length(num_score_diff), 1); sharediff(num_score_diff~=0)=1;  mean(sharediff)
 
data_all=[rawdata, num_score]; data_all = unique(data_all, 'rows');
csvwrite('mod1i_numscore.csv', data_all);

%% MOD1J 71
clear 

% Load Data
load('mod1j71', 'mod1'); 
rawdata=[mod1{1}, mod1{2},mod1{3}, mod1{4}, mod1{5}, mod1{6},mod1{7}, mod1{8}, mod1{9}, mod1{10},mod1{11}, mod1{12}, mod1{13}, mod1{14}, mod1{15}];
year=mod1{16}; mth=mod1{17}; score=mod1{18}; rg=mod1{19}; rctp=mod1{20}; index=mod1{21};
clear mod1
c1 = csvread('21_HQE01_cond.csv'); c2 = csvread('21_HQE02_cond.csv'); c3 = csvread('21_HQE04_cond.csv');
c4 = csvread('21_HQF05_cond.csv'); c5 = csvread('21_VQC05_cond.csv'); c6 = csvread('21_VQC06_cond.csv');
c7 = csvread('21_VQD02_cond.csv'); c8 = csvread('21_VQE01_cond.csv'); c9 = csvread('21_VQE02_cond.csv');
c10 = csvread('21_VQE03_cond.csv'); c11 = csvread('21_VQE04_cond.csv'); c12 = csvread('21_VQE05_cond.csv');
c13 = csvread('21_VQE07_cond.csv'); c14 = csvread('21_VQF05_cond.csv'); c15 = csvread('21_VQF06_cond.csv');
condprob=[c1;c2;c3;c4;c5;c6;c7;c8;c9;c10;c11;c12;c13; c14; c15];

% Initialize priors
pp1=ones(length(score), 1); %set a uniform prior
pp1=pp1.*.2; pp2=pp1; pp3=pp1; pp4=pp1; pp5=pp1;

% apply Bayes rule

[dem1, dem2]=size(rawdata);	

cp_ctr=1; 
for j=1:dem2

	q=rawdata(:, j); %select the question of interest
	% Select non-missing observations for the variable j under consideration 
	pp1t=pp1(q~=999);pp2t=pp2(q~=999); pp3t=pp3(q~=999); 
	pp4t=pp4(q~=999); pp5t=pp5(q~=999); indext=index(q~=999); 
	qt=q(q~=999); 	
	resp_ctr=max(unique(qt)); % number of possible responses to the question 
	cp=condprob(cp_ctr: cp_ctr+resp_ctr-1, :);

	for i=1:resp_ctr
	    denom=pp1t(qt==i).*cp(i, 1)+pp2t(qt==i).*cp(i, 2)+pp3t(qt==i).*cp(i, 3)+pp4t(qt==i).*cp(i, 4)+pp5t(qt==i).*cp(i, 5);
	    pp1t(qt==i) = pp1t(qt==i).*cp(i, 1);  pp1t(qt==i) = pp1t(qt==i)./denom;
	    pp2t(qt==i) = pp2t(qt==i).*cp(i, 2); pp2t(qt==i) = pp2t(qt==i)./denom;
	    pp3t(qt==i) = pp3t(qt==i).*cp(i, 3); pp3t(qt==i) = pp3t(qt==i)./denom;
	    pp4t(qt==i) = pp4t(qt==i).*cp(i, 4); pp4t(qt==i) = pp4t(qt==i)./denom;
	    pp5t(qt==i) = pp5t(qt==i).*cp(i, 5); pp5t(qt==i) = pp5t(qt==i)./denom;
	end
	
	pp1(indext)=pp1t; pp2(indext)=pp2t; pp3(indext)=pp3t; 
	pp4(indext)=pp4t; pp5(indext)=pp5t;
	
	cp_ctr=cp_ctr+resp_ctr;
end

% Numerical score
num_score=pp1.*5+pp2.*4+pp3.*3+pp4.*2+pp5.*1;

num_score_round(num_score>=4.5)=5;  num_score_round(num_score>=3.5 & num_score<4.5)=4; 
num_score_round(num_score>=2.5 & num_score<3.5)=3; num_score_round(num_score>=1.5 & num_score<2.5)=2;
num_score_round(num_score<1.5)=1; num_score_round=num_score_round';

num_score_diff=num_score_round-score; match=unique(num_score_diff);
sharediff=zeros(length(num_score_diff), 1); sharediff(num_score_diff~=0)=1;  mean(sharediff)
 
data_all=[rawdata, num_score]; data_all = unique(data_all, 'rows');
csvwrite('mod1j_numscore71.csv', data_all);

%% MOD1J 70
clear 

% Load Data
load('mod1j70', 'mod1'); 
rawdata=[mod1{1}, mod1{2},mod1{3}, mod1{4}, mod1{5}, mod1{6},mod1{7}, mod1{8}, mod1{9}, mod1{10},mod1{11}, mod1{12}, mod1{13}, mod1{14}, mod1{15}, mod1{16}, mod1{17}];
year=mod1{18}; mth=mod1{19}; score=mod1{20}; rg=mod1{21}; rctp=mod1{22}; index=mod1{23};
clear mod1
c1 = csvread('21_HQE01_cond.csv'); c2 = csvread('21_HQE02_cond.csv'); 
c3 = csvread('21_HQE03_cond.csv');c4 = csvread('21_HQE04_cond.csv');
c5 = csvread('21_HQF05_cond.csv'); c6 = csvread('21_VQC05_cond.csv'); c7 = csvread('21_VQC06_cond.csv');
c8 = csvread('21_VQD02_cond.csv'); c9 = csvread('21_VQE01_cond.csv'); c10 = csvread('21_VQE02_cond.csv');
c11 = csvread('21_VQE03_cond.csv'); c12 = csvread('21_VQE04_cond.csv'); c13 = csvread('21_VQE05_cond.csv');
c14 = csvread('21_VQE07_cond.csv'); c15 = csvread('21_VQF05_cond.csv'); c16 = csvread('21_VQF06_cond.csv');
c17 = csvread('21_HQE05_cond.csv');
condprob=[c1;c2;c3;c4;c5;c6;c7;c8;c9;c10;c11;c12;c13; c14; c15;c16; c17];

% Initialize priors
pp1=ones(length(score), 1); %set a uniform prior
pp1=pp1.*.2; pp2=pp1; pp3=pp1; pp4=pp1; pp5=pp1;

% apply Bayes rule

[dem1, dem2]=size(rawdata);	

cp_ctr=1; 
for j=1:dem2

	q=rawdata(:, j); %select the question of interest
	% Select non-missing observations for the variable j under consideration 
	pp1t=pp1(q~=999);pp2t=pp2(q~=999); pp3t=pp3(q~=999); 
	pp4t=pp4(q~=999); pp5t=pp5(q~=999); indext=index(q~=999); 
	qt=q(q~=999); 	
	resp_ctr=max(unique(qt)); % number of possible responses to the question 
	cp=condprob(cp_ctr: cp_ctr+resp_ctr-1, :);

	for i=1:resp_ctr
	    denom=pp1t(qt==i).*cp(i, 1)+pp2t(qt==i).*cp(i, 2)+pp3t(qt==i).*cp(i, 3)+pp4t(qt==i).*cp(i, 4)+pp5t(qt==i).*cp(i, 5);
	    pp1t(qt==i) = pp1t(qt==i).*cp(i, 1);  pp1t(qt==i) = pp1t(qt==i)./denom;
	    pp2t(qt==i) = pp2t(qt==i).*cp(i, 2); pp2t(qt==i) = pp2t(qt==i)./denom;
	    pp3t(qt==i) = pp3t(qt==i).*cp(i, 3); pp3t(qt==i) = pp3t(qt==i)./denom;
	    pp4t(qt==i) = pp4t(qt==i).*cp(i, 4); pp4t(qt==i) = pp4t(qt==i)./denom;
	    pp5t(qt==i) = pp5t(qt==i).*cp(i, 5); pp5t(qt==i) = pp5t(qt==i)./denom;
	end
	
	pp1(indext)=pp1t; pp2(indext)=pp2t; pp3(indext)=pp3t; 
	pp4(indext)=pp4t; pp5(indext)=pp5t;
	
	cp_ctr=cp_ctr+resp_ctr;
end

% Numerical score
num_score=pp1.*5+pp2.*4+pp3.*3+pp4.*2+pp5.*1;

num_score_round(num_score>=4.5)=5;  num_score_round(num_score>=3.5 & num_score<4.5)=4; 
num_score_round(num_score>=2.5 & num_score<3.5)=3; num_score_round(num_score>=1.5 & num_score<2.5)=2;
num_score_round(num_score<1.5)=1; num_score_round=num_score_round';

num_score_diff=num_score_round-score; match=unique(num_score_diff);
sharediff=zeros(length(num_score_diff), 1); sharediff(num_score_diff~=0)=1;  mean(sharediff)
 
data_all=[rawdata, num_score]; data_all = unique(data_all, 'rows');
csvwrite('mod1j_numscore70.csv', data_all);
							
%% MOD1K
clear 

% Load Data
load('mod1k', 'mod1'); 
rawdata=[mod1{1}, mod1{2},mod1{3}, mod1{4}, mod1{5}, mod1{6},mod1{7}, mod1{8}];
year=mod1{9}; mth=mod1{10}; score=mod1{11}; rg=mod1{12}; rctp=mod1{13}; index=mod1{14};
clear mod1
c1 = csvread('22_HQC06_cond.csv'); c2 = csvread('22_HQF04_cond.csv'); c3 = csvread('22_HQF05_cond.csv');
c4 = csvread('22_HQF06_cond.csv'); c5 = csvread('22_HQN02_cond.csv'); c6 = csvread('22_VQF05_cond.csv');
c7 = csvread('22_VQF06_cond.csv'); c8 = csvread('22_VQF07_cond.csv'); 
condprob=[c1;c2;c3;c4;c5;c6;c7;c8];

% Initialize priors
pp1=ones(length(score), 1); %set a uniform prior
pp1=pp1.*.2; pp2=pp1; pp3=pp1; pp4=pp1; pp5=pp1;

% apply Bayes rule

[dem1, dem2]=size(rawdata);	

cp_ctr=1; 
for j=1:dem2

	q=rawdata(:, j); %select the question of interest
	% Select non-missing observations for the variable j under consideration 
	pp1t=pp1(q~=999);pp2t=pp2(q~=999); pp3t=pp3(q~=999); 
	pp4t=pp4(q~=999); pp5t=pp5(q~=999); indext=index(q~=999); 
	qt=q(q~=999); 	
	resp_ctr=max(unique(qt)); % number of possible responses to the question 
	cp=condprob(cp_ctr: cp_ctr+resp_ctr-1, :);

	for i=1:resp_ctr
	    denom=pp1t(qt==i).*cp(i, 1)+pp2t(qt==i).*cp(i, 2)+pp3t(qt==i).*cp(i, 3)+pp4t(qt==i).*cp(i, 4)+pp5t(qt==i).*cp(i, 5);
	    pp1t(qt==i) = pp1t(qt==i).*cp(i, 1);  pp1t(qt==i) = pp1t(qt==i)./denom;
	    pp2t(qt==i) = pp2t(qt==i).*cp(i, 2); pp2t(qt==i) = pp2t(qt==i)./denom;
	    pp3t(qt==i) = pp3t(qt==i).*cp(i, 3); pp3t(qt==i) = pp3t(qt==i)./denom;
	    pp4t(qt==i) = pp4t(qt==i).*cp(i, 4); pp4t(qt==i) = pp4t(qt==i)./denom;
	    pp5t(qt==i) = pp5t(qt==i).*cp(i, 5); pp5t(qt==i) = pp5t(qt==i)./denom;
	end
	
	pp1(indext)=pp1t; pp2(indext)=pp2t; pp3(indext)=pp3t; 
	pp4(indext)=pp4t; pp5(indext)=pp5t;
	
	cp_ctr=cp_ctr+resp_ctr;
end

% Numerical score
num_score=pp1.*5+pp2.*4+pp3.*3+pp4.*2+pp5.*1;

num_score_round(num_score>=4.5)=5;  num_score_round(num_score>=3.5 & num_score<4.5)=4; 
num_score_round(num_score>=2.5 & num_score<3.5)=3; num_score_round(num_score>=1.5 & num_score<2.5)=2;
num_score_round(num_score<1.5)=1; num_score_round=num_score_round';

num_score_diff=num_score_round-score; match=unique(num_score_diff);
sharediff=zeros(length(num_score_diff), 1); sharediff(num_score_diff~=0)=1;  mean(sharediff)
 
data_all=[rawdata, num_score]; data_all = unique(data_all, 'rows');
csvwrite('mod1k_numscore.csv', data_all);

%% MOD1L
clear 

% Load Data
load('mod1l', 'mod1'); 
rawdata=[mod1{1}, mod1{2},mod1{3}, mod1{4}, mod1{5}, mod1{6},mod1{7}];
year=mod1{8}; mth=mod1{9}; score=mod1{10}; rg=mod1{11}; rctp=mod1{12}; index=mod1{13};
clear mod1
c1 = csvread('23_HQG01_cond.csv'); c2 = csvread('23_HQG02_cond.csv'); c3 = csvread('23_HQG03_cond.csv');
c4 = csvread('23_HQG04_cond.csv'); c5 = csvread('23_VQG01_cond.csv'); c6 = csvread('23_VQG02_cond.csv');
c7 = csvread('23_VQG03_cond.csv'); 
condprob=[c1;c2;c3;c4;c5;c6;c7];

% Initialize priors
pp1=ones(length(score), 1); %set a uniform prior
pp1=pp1.*.2; pp2=pp1; pp3=pp1; pp4=pp1; pp5=pp1;

% apply Bayes rule

[dem1, dem2]=size(rawdata);	

cp_ctr=1; 
for j=1:dem2

	q=rawdata(:, j); %select the question of interest
	% Select non-missing observations for the variable j under consideration 
	pp1t=pp1(q~=999);pp2t=pp2(q~=999); pp3t=pp3(q~=999); 
	pp4t=pp4(q~=999); pp5t=pp5(q~=999); indext=index(q~=999); 
	qt=q(q~=999); 	
	resp_ctr=max(unique(qt)); % number of possible responses to the question 
	cp=condprob(cp_ctr: cp_ctr+resp_ctr-1, :);

	for i=1:resp_ctr
	    denom=pp1t(qt==i).*cp(i, 1)+pp2t(qt==i).*cp(i, 2)+pp3t(qt==i).*cp(i, 3)+pp4t(qt==i).*cp(i, 4)+pp5t(qt==i).*cp(i, 5);
	    pp1t(qt==i) = pp1t(qt==i).*cp(i, 1);  pp1t(qt==i) = pp1t(qt==i)./denom;
	    pp2t(qt==i) = pp2t(qt==i).*cp(i, 2); pp2t(qt==i) = pp2t(qt==i)./denom;
	    pp3t(qt==i) = pp3t(qt==i).*cp(i, 3); pp3t(qt==i) = pp3t(qt==i)./denom;
	    pp4t(qt==i) = pp4t(qt==i).*cp(i, 4); pp4t(qt==i) = pp4t(qt==i)./denom;
	    pp5t(qt==i) = pp5t(qt==i).*cp(i, 5); pp5t(qt==i) = pp5t(qt==i)./denom;
	end
	
	pp1(indext)=pp1t; pp2(indext)=pp2t; pp3(indext)=pp3t; 
	pp4(indext)=pp4t; pp5(indext)=pp5t;
	
	cp_ctr=cp_ctr+resp_ctr;
end

% Numerical score
num_score=pp1.*5+pp2.*4+pp3.*3+pp4.*2+pp5.*1;

num_score_round(num_score>=4.5)=5;  num_score_round(num_score>=3.5 & num_score<4.5)=4; 
num_score_round(num_score>=2.5 & num_score<3.5)=3; num_score_round(num_score>=1.5 & num_score<2.5)=2;
num_score_round(num_score<1.5)=1; num_score_round=num_score_round';

num_score_diff=num_score_round-score; match=unique(num_score_diff);
sharediff=zeros(length(num_score_diff), 1); sharediff(num_score_diff~=0)=1;  mean(sharediff)
 
data_all=[rawdata, num_score]; data_all = unique(data_all, 'rows');
csvwrite('mod1l_numscore.csv', data_all);
					
%% MOD1M
clear 

% Load Data
load('mod1m', 'mod1'); 
rawdata=[mod1{1}, mod1{2},mod1{3}, mod1{4}, mod1{5}, mod1{6},mod1{7}, mod1{8}, mod1{9}, mod1{10},mod1{11}, mod1{12}, mod1{13}, mod1{14}];
year=mod1{15}; mth=mod1{16}; score=mod1{17}; rg=mod1{18}; rctp=mod1{19}; index=mod1{20};
clear mod1
c1 = csvread('24_HQB01_cond.csv'); c2 = csvread('24_HQB03_cond.csv'); c3 = csvread('24_HQC06_cond.csv');
c4 = csvread('24_HQF01_cond.csv'); c5 = csvread('24_HQF02_cond.csv'); c6 = csvread('24_HQF03_cond.csv');
c7 = csvread('24_HQF06_cond.csv'); c8 = csvread('24_HQG04_cond.csv'); c9 = csvread('24_HQN02_cond.csv');
c10 = csvread('24_VQB01_cond.csv'); c11 = csvread('24_VQF01_cond.csv'); c12 = csvread('24_VQF02_cond.csv');
c13 = csvread('24_VQF03_cond.csv'); c14 = csvread('24_VQF04_cond.csv');
condprob=[c1;c2;c3;c4;c5;c6;c7;c8;c9;c10;c11;c12;c13; c14];

% Initialize priors
pp1=ones(length(score), 1); %set a uniform prior
pp1=pp1.*.2; pp2=pp1; pp3=pp1; pp4=pp1; pp5=pp1;

% apply Bayes rule

[dem1, dem2]=size(rawdata);	

cp_ctr=1; 
for j=1:dem2

	q=rawdata(:, j); %select the question of interest
	% Select non-missing observations for the variable j under consideration 
	pp1t=pp1(q~=999);pp2t=pp2(q~=999); pp3t=pp3(q~=999); 
	pp4t=pp4(q~=999); pp5t=pp5(q~=999); indext=index(q~=999); 
	qt=q(q~=999); 	
	resp_ctr=max(unique(qt)); % number of possible responses to the question 
	cp=condprob(cp_ctr: cp_ctr+resp_ctr-1, :);

	for i=1:resp_ctr
	    denom=pp1t(qt==i).*cp(i, 1)+pp2t(qt==i).*cp(i, 2)+pp3t(qt==i).*cp(i, 3)+pp4t(qt==i).*cp(i, 4)+pp5t(qt==i).*cp(i, 5);
	    pp1t(qt==i) = pp1t(qt==i).*cp(i, 1);  pp1t(qt==i) = pp1t(qt==i)./denom;
	    pp2t(qt==i) = pp2t(qt==i).*cp(i, 2); pp2t(qt==i) = pp2t(qt==i)./denom;
	    pp3t(qt==i) = pp3t(qt==i).*cp(i, 3); pp3t(qt==i) = pp3t(qt==i)./denom;
	    pp4t(qt==i) = pp4t(qt==i).*cp(i, 4); pp4t(qt==i) = pp4t(qt==i)./denom;
	    pp5t(qt==i) = pp5t(qt==i).*cp(i, 5); pp5t(qt==i) = pp5t(qt==i)./denom;
	end
	
	pp1(indext)=pp1t; pp2(indext)=pp2t; pp3(indext)=pp3t; 
	pp4(indext)=pp4t; pp5(indext)=pp5t;
	
	cp_ctr=cp_ctr+resp_ctr;
end

% Numerical score
num_score=pp1.*5+pp2.*4+pp3.*3+pp4.*2+pp5.*1;

num_score_round(num_score>=4.5)=5;  num_score_round(num_score>=3.5 & num_score<4.5)=4; 
num_score_round(num_score>=2.5 & num_score<3.5)=3; num_score_round(num_score>=1.5 & num_score<2.5)=2;
num_score_round(num_score<1.5)=1; num_score_round=num_score_round';

num_score_diff=num_score_round-score; match=unique(num_score_diff);
sharediff=zeros(length(num_score_diff), 1); sharediff(num_score_diff~=0)=1;  mean(sharediff)
 
data_all=[rawdata, num_score]; data_all = unique(data_all, 'rows');
csvwrite('mod1m_numscore.csv', data_all);
									
%% MOD1N
clear 

% Load Data
load('mod1n', 'mod1'); 
rawdata=[mod1{1}, mod1{2},mod1{3}, mod1{4}, mod1{5}, mod1{6}];
year=mod1{7}; mth=mod1{8}; score=mod1{9}; rg=mod1{10}; rctp=mod1{11}; index=mod1{12};
clear mod1
c1 = csvread('25_HQP01_cond.csv'); c2 = csvread('25_HQP02_cond.csv'); c3 = csvread('25_VQP01_cond.csv');
c4 = csvread('25_VQP02_cond.csv'); c5 = csvread('25_VQP03_cond.csv'); c6 = csvread('25_VQP04_cond.csv');
condprob=[c1;c2;c3;c4;c5;c6];

% Initialize priors
pp1=ones(length(score), 1); %set a uniform prior
pp1=pp1.*.2; pp2=pp1; pp3=pp1; pp4=pp1; pp5=pp1;

% apply Bayes rule

[dem1, dem2]=size(rawdata);	

cp_ctr=1; 
for j=1:dem2

	q=rawdata(:, j); %select the question of interest
	% Select non-missing observations for the variable j under consideration 
	pp1t=pp1(q~=999);pp2t=pp2(q~=999); pp3t=pp3(q~=999); 
	pp4t=pp4(q~=999); pp5t=pp5(q~=999); indext=index(q~=999); 
	qt=q(q~=999); 	
	resp_ctr=max(unique(qt)); % number of possible responses to the question 
	cp=condprob(cp_ctr: cp_ctr+resp_ctr-1, :);

	for i=1:resp_ctr
	    denom=pp1t(qt==i).*cp(i, 1)+pp2t(qt==i).*cp(i, 2)+pp3t(qt==i).*cp(i, 3)+pp4t(qt==i).*cp(i, 4)+pp5t(qt==i).*cp(i, 5);
	    pp1t(qt==i) = pp1t(qt==i).*cp(i, 1);  pp1t(qt==i) = pp1t(qt==i)./denom;
	    pp2t(qt==i) = pp2t(qt==i).*cp(i, 2); pp2t(qt==i) = pp2t(qt==i)./denom;
	    pp3t(qt==i) = pp3t(qt==i).*cp(i, 3); pp3t(qt==i) = pp3t(qt==i)./denom;
	    pp4t(qt==i) = pp4t(qt==i).*cp(i, 4); pp4t(qt==i) = pp4t(qt==i)./denom;
	    pp5t(qt==i) = pp5t(qt==i).*cp(i, 5); pp5t(qt==i) = pp5t(qt==i)./denom;
	end
	
	pp1(indext)=pp1t; pp2(indext)=pp2t; pp3(indext)=pp3t; 
	pp4(indext)=pp4t; pp5(indext)=pp5t;
	
	cp_ctr=cp_ctr+resp_ctr;
end

% Numerical score
num_score=pp1.*5+pp2.*4+pp3.*3+pp4.*2+pp5.*1;

num_score_round(num_score>=4.5)=5;  num_score_round(num_score>=3.5 & num_score<4.5)=4; 
num_score_round(num_score>=2.5 & num_score<3.5)=3; num_score_round(num_score>=1.5 & num_score<2.5)=2;
num_score_round(num_score<1.5)=1; num_score_round=num_score_round';

num_score_diff=num_score_round-score; match=unique(num_score_diff);
sharediff=zeros(length(num_score_diff), 1); sharediff(num_score_diff~=0)=1;  mean(sharediff)
 
data_all=[rawdata, num_score]; data_all = unique(data_all, 'rows');
csvwrite('mod1n_numscore.csv', data_all);

%% MOD1O
clear 

% Load Data
load('mod1o', 'mod1');
rawdata=[mod1{1}, mod1{2},mod1{3}, mod1{4}, mod1{5}, mod1{6},mod1{7}, mod1{8}];
year=mod1{9}; mth=mod1{10}; score=mod1{11}; rg=mod1{12}; rctp=mod1{13}; index=mod1{14};
clear mod1
c1 = csvread('26_HQR01_cond.csv'); c2 = csvread('26_HQR02_cond.csv'); c3 = csvread('26_HQR03_cond.csv');
c4 = csvread('26_HQR04_cond.csv'); c5 = csvread('26_HQR05_cond.csv'); c6 = csvread('26_VQR01_cond.csv');
c7 = csvread('26_VQR02_cond.csv'); c8 = csvread('26_VQR03_cond.csv'); 
condprob=[c1;c2;c3;c4;c5;c6;c7;c8];

% Initialize priors
pp1=ones(length(score), 1); %set a uniform prior
pp1=pp1.*.2; pp2=pp1; pp3=pp1; pp4=pp1; pp5=pp1;

% apply Bayes rule

[dem1, dem2]=size(rawdata);	

cp_ctr=1; 
for j=1:dem2

	q=rawdata(:, j); %select the question of interest
	% Select non-missing observations for the variable j under consideration 
	pp1t=pp1(q~=999);pp2t=pp2(q~=999); pp3t=pp3(q~=999); 
	pp4t=pp4(q~=999); pp5t=pp5(q~=999); indext=index(q~=999); 
	qt=q(q~=999); 	
	resp_ctr=max(unique(qt)); % number of possible responses to the question 
	cp=condprob(cp_ctr: cp_ctr+resp_ctr-1, :);

	for i=1:resp_ctr
	    denom=pp1t(qt==i).*cp(i, 1)+pp2t(qt==i).*cp(i, 2)+pp3t(qt==i).*cp(i, 3)+pp4t(qt==i).*cp(i, 4)+pp5t(qt==i).*cp(i, 5);
	    pp1t(qt==i) = pp1t(qt==i).*cp(i, 1);  pp1t(qt==i) = pp1t(qt==i)./denom;
	    pp2t(qt==i) = pp2t(qt==i).*cp(i, 2); pp2t(qt==i) = pp2t(qt==i)./denom;
	    pp3t(qt==i) = pp3t(qt==i).*cp(i, 3); pp3t(qt==i) = pp3t(qt==i)./denom;
	    pp4t(qt==i) = pp4t(qt==i).*cp(i, 4); pp4t(qt==i) = pp4t(qt==i)./denom;
	    pp5t(qt==i) = pp5t(qt==i).*cp(i, 5); pp5t(qt==i) = pp5t(qt==i)./denom;
	end
	
	pp1(indext)=pp1t; pp2(indext)=pp2t; pp3(indext)=pp3t; 
	pp4(indext)=pp4t; pp5(indext)=pp5t;
	
	cp_ctr=cp_ctr+resp_ctr;
end

% Numerical score
num_score=pp1.*5+pp2.*4+pp3.*3+pp4.*2+pp5.*1;

num_score_round(num_score>=4.5)=5;  num_score_round(num_score>=3.5 & num_score<4.5)=4; 
num_score_round(num_score>=2.5 & num_score<3.5)=3; num_score_round(num_score>=1.5 & num_score<2.5)=2;
num_score_round(num_score<1.5)=1; num_score_round=num_score_round';

num_score_diff=num_score_round-score; match=unique(num_score_diff);
sharediff=zeros(length(num_score_diff), 1); sharediff(num_score_diff~=0)=1;  mean(sharediff)
 
data_all=[rawdata, num_score]; data_all = unique(data_all, 'rows');
csvwrite('mod1o_numscore.csv', data_all);

%% MOD1P
clear 

% Load Data
load('mod1p', 'mod1');
rawdata=[mod1{1}, mod1{2},mod1{3}, mod1{4}, mod1{5}];
year=mod1{6}; mth=mod1{7}; score=mod1{8}; rg=mod1{9}; rctp=mod1{10}; index=mod1{11};
clear mod1

c1 = csvread('27_HQS01_cond.csv'); c2 = csvread('27_HQS02_cond.csv'); c3 = csvread('27_HQS03_cond.csv');
c4 = csvread('27_HQS04_cond.csv'); c5 = csvread('27_HQS05_cond.csv'); 
condprob=[c1;c2;c3;c4;c5];

% Initialize priors
pp1=ones(length(score), 1); %set a uniform prior
pp1=pp1.*.2; pp2=pp1; pp3=pp1; pp4=pp1; pp5=pp1;

% apply Bayes rule

[dem1, dem2]=size(rawdata);	

cp_ctr=1; 
for j=1:dem2

	q=rawdata(:, j); %select the question of interest
	% Select non-missing observations for the variable j under consideration 
	pp1t=pp1(q~=999);pp2t=pp2(q~=999); pp3t=pp3(q~=999); 
	pp4t=pp4(q~=999); pp5t=pp5(q~=999); indext=index(q~=999); 
	qt=q(q~=999); 	
	resp_ctr=max(unique(qt)); % number of possible responses to the question 
	cp=condprob(cp_ctr: cp_ctr+resp_ctr-1, :);

	for i=1:resp_ctr
	    denom=pp1t(qt==i).*cp(i, 1)+pp2t(qt==i).*cp(i, 2)+pp3t(qt==i).*cp(i, 3)+pp4t(qt==i).*cp(i, 4)+pp5t(qt==i).*cp(i, 5);
	    pp1t(qt==i) = pp1t(qt==i).*cp(i, 1);  pp1t(qt==i) = pp1t(qt==i)./denom;
	    pp2t(qt==i) = pp2t(qt==i).*cp(i, 2); pp2t(qt==i) = pp2t(qt==i)./denom;
	    pp3t(qt==i) = pp3t(qt==i).*cp(i, 3); pp3t(qt==i) = pp3t(qt==i)./denom;
	    pp4t(qt==i) = pp4t(qt==i).*cp(i, 4); pp4t(qt==i) = pp4t(qt==i)./denom;
	    pp5t(qt==i) = pp5t(qt==i).*cp(i, 5); pp5t(qt==i) = pp5t(qt==i)./denom;
	end
	
	pp1(indext)=pp1t; pp2(indext)=pp2t; pp3(indext)=pp3t; 
	pp4(indext)=pp4t; pp5(indext)=pp5t;
	
	cp_ctr=cp_ctr+resp_ctr;
end

% Numerical score
num_score=pp1.*5+pp2.*4+pp3.*3+pp4.*2+pp5.*1;

num_score_round(num_score>=4.5)=5;  num_score_round(num_score>=3.5 & num_score<4.5)=4; 
num_score_round(num_score>=2.5 & num_score<3.5)=3; num_score_round(num_score>=1.5 & num_score<2.5)=2;
num_score_round(num_score<1.5)=1; num_score_round=num_score_round';

num_score_diff=num_score_round-score; match=unique(num_score_diff);
sharediff=zeros(length(num_score_diff), 1); sharediff(num_score_diff~=0)=1;  mean(sharediff)
 
data_all=[rawdata, num_score]; data_all = unique(data_all, 'rows');
csvwrite('mod1p_numscore.csv', data_all);

%% MOD1Q 71
clear 

% Load Data
load('mod1q71', 'mod1');
rawdata=[mod1{1}, mod1{2},mod1{3}, mod1{4}, mod1{5}, mod1{6},mod1{7}];
year=mod1{8}; mth=mod1{9}; score=mod1{10}; rg=mod1{11}; rctp=mod1{12}; index=mod1{13};
clear mod1
c1 = csvread('28_HQN01_cond.csv'); c2 = csvread('28_HQN02_cond.csv'); c3 = csvread('28_VQN01_cond.csv');
c4 = csvread('28_VQN02_cond.csv'); c5 = csvread('28_VQN03_cond.csv'); c6 = csvread('28_VQN04_cond.csv');
c7 = csvread('28_VQN05_cond.csv'); 
condprob=[c1;c2;c3;c4;c5;c6;c7];

% Initialize priors
pp1=ones(length(score), 1); %set a uniform prior
pp1=pp1.*.2; pp2=pp1; pp3=pp1; pp4=pp1; pp5=pp1;

% apply Bayes rule

[dem1, dem2]=size(rawdata);	

cp_ctr=1; 
for j=1:dem2
    
	q=rawdata(:, j); %select the question of interest
	% Select non-missing observations for the variable j under consideration 
	pp1t=pp1(q~=999);pp2t=pp2(q~=999); pp3t=pp3(q~=999); 
	pp4t=pp4(q~=999); pp5t=pp5(q~=999); indext=index(q~=999); 
	qt=q(q~=999); 	  
    
	resp_ctr=max(unique(qt)); % number of possible responses to the question 
	cp=condprob(cp_ctr: cp_ctr+resp_ctr-1, :);

	for i=1:resp_ctr
	    denom=pp1t(qt==i).*cp(i, 1)+pp2t(qt==i).*cp(i, 2)+pp3t(qt==i).*cp(i, 3)+pp4t(qt==i).*cp(i, 4)+pp5t(qt==i).*cp(i, 5);
	    pp1t(qt==i) = pp1t(qt==i).*cp(i, 1);  pp1t(qt==i) = pp1t(qt==i)./denom;
	    pp2t(qt==i) = pp2t(qt==i).*cp(i, 2); pp2t(qt==i) = pp2t(qt==i)./denom;
	    pp3t(qt==i) = pp3t(qt==i).*cp(i, 3); pp3t(qt==i) = pp3t(qt==i)./denom;
	    pp4t(qt==i) = pp4t(qt==i).*cp(i, 4); pp4t(qt==i) = pp4t(qt==i)./denom;
	    pp5t(qt==i) = pp5t(qt==i).*cp(i, 5); pp5t(qt==i) = pp5t(qt==i)./denom;
	end
	
	pp1(indext)=pp1t; pp2(indext)=pp2t; pp3(indext)=pp3t; 
	pp4(indext)=pp4t; pp5(indext)=pp5t;
	
	cp_ctr=cp_ctr+resp_ctr;
end

% Numerical score
num_score=pp1.*5+pp2.*4+pp3.*3+pp4.*2+pp5.*1;

num_score_round(num_score>=4.5)=5;  num_score_round(num_score>=3.5 & num_score<4.5)=4; 
num_score_round(num_score>=2.5 & num_score<3.5)=3; num_score_round(num_score>=1.5 & num_score<2.5)=2;
num_score_round(num_score<1.5)=1; num_score_round=num_score_round';

num_score_diff=num_score_round-score; match=unique(num_score_diff);
sharediff=zeros(length(num_score_diff), 1); sharediff(num_score_diff~=0)=1;  mean(sharediff)
 
data_all=[rawdata, num_score]; data_all = unique(data_all, 'rows');
csvwrite('mod1q_numscore71.csv', data_all);

%% MOD1Q 70
clear 

% Load Data
load('mod1q70', 'mod1');
rawdata=[mod1{1}, mod1{2},mod1{3}, mod1{4}, mod1{5}, mod1{6},mod1{7}, mod1{8}];
year=mod1{9}; mth=mod1{10}; score=mod1{11}; rg=mod1{12}; rctp=mod1{13}; index=mod1{14};
clear mod1

c1 = csvread('28_HQN01_cond.csv'); c2 = csvread('28_HQN02_cond.csv'); 
c3 = csvread('28_VQE06_cond.csv'); c4 = csvread('28_VQN01_cond.csv');
c5 = csvread('28_VQN02_cond.csv'); c6 = csvread('28_VQN03_cond.csv'); c7 = csvread('28_VQN04_cond.csv');
c8 = csvread('28_VQN05_cond.csv'); 

condprob=[c1;c2;c3;c4;c5;c6;c7;c8];

% Initialize priors
pp1=ones(length(score), 1); %set a uniform prior
pp1=pp1.*.2; pp2=pp1; pp3=pp1; pp4=pp1; pp5=pp1;

% apply Bayes rule

[dem1, dem2]=size(rawdata);	

cp_ctr=1; 
for j=1:dem2
    j
    
	q=rawdata(:, j); %select the question of interest
	% Select non-missing observations for the variable j under consideration 
	pp1t=pp1(q~=999);pp2t=pp2(q~=999); pp3t=pp3(q~=999); 
	pp4t=pp4(q~=999); pp5t=pp5(q~=999); indext=index(q~=999); 
	qt=q(q~=999); 	  
    
	resp_ctr=max(unique(qt)); % number of possible responses to the question 
	cp=condprob(cp_ctr: cp_ctr+resp_ctr-1, :);

	for i=1:resp_ctr
	    denom=pp1t(qt==i).*cp(i, 1)+pp2t(qt==i).*cp(i, 2)+pp3t(qt==i).*cp(i, 3)+pp4t(qt==i).*cp(i, 4)+pp5t(qt==i).*cp(i, 5);
	    pp1t(qt==i) = pp1t(qt==i).*cp(i, 1);  pp1t(qt==i) = pp1t(qt==i)./denom;
	    pp2t(qt==i) = pp2t(qt==i).*cp(i, 2); pp2t(qt==i) = pp2t(qt==i)./denom;
	    pp3t(qt==i) = pp3t(qt==i).*cp(i, 3); pp3t(qt==i) = pp3t(qt==i)./denom;
	    pp4t(qt==i) = pp4t(qt==i).*cp(i, 4); pp4t(qt==i) = pp4t(qt==i)./denom;
	    pp5t(qt==i) = pp5t(qt==i).*cp(i, 5); pp5t(qt==i) = pp5t(qt==i)./denom;
	end
	
	pp1(indext)=pp1t; pp2(indext)=pp2t; pp3(indext)=pp3t; 
	pp4(indext)=pp4t; pp5(indext)=pp5t;
	
	cp_ctr=cp_ctr+resp_ctr;
end

% Numerical score
num_score=pp1.*5+pp2.*4+pp3.*3+pp4.*2+pp5.*1;

num_score_round(num_score>=4.5)=5;  num_score_round(num_score>=3.5 & num_score<4.5)=4; 
num_score_round(num_score>=2.5 & num_score<3.5)=3; num_score_round(num_score>=1.5 & num_score<2.5)=2;
num_score_round(num_score<1.5)=1; num_score_round=num_score_round';

num_score_diff=num_score_round-score; match=unique(num_score_diff);
sharediff=zeros(length(num_score_diff), 1); sharediff(num_score_diff~=0)=1;  mean(sharediff)
 
data_all=[rawdata, num_score]; data_all = unique(data_all, 'rows');
csvwrite('mod1q_numscore70.csv', data_all);

%% MOD1R
clear 

% Load Data
load('mod1r', 'mod1'); 
rawdata=[mod1{1}, mod1{2},mod1{3}, mod1{4}, mod1{5}, mod1{6},mod1{7}, mod1{8}, mod1{9}, mod1{10},mod1{11}, mod1{12}];
year=mod1{13}; mth=mod1{14}; score=mod1{15}; rg=mod1{16}; rctp=mod1{17}; index=mod1{18};
clear mod1
c1 = csvread('29_HQB02_cond.csv'); c2 = csvread('29_HQG03_cond.csv'); c3 = csvread('29_HQL01_cond.csv');
c4 = csvread('29_HQL02_cond.csv'); c5 = csvread('29_HQL03_cond.csv'); c6 = csvread('29_HQS01_cond.csv');
c7 = csvread('29_VQB05_cond.csv'); c8 = csvread('29_VQE07_cond.csv'); c9 = csvread('29_VQL01_cond.csv');
c10 = csvread('29_VQL02_cond.csv'); c11 = csvread('29_VQL03_cond.csv'); c12 = csvread('29_VQT06_cond.csv');										
condprob=[c1;c2;c3;c4;c5;c6;c7;c8;c9;c10;c11;c12];

% Initialize priors
pp1=ones(length(score), 1); %set a uniform prior
pp1=pp1.*.2; pp2=pp1; pp3=pp1; pp4=pp1; pp5=pp1;

% apply Bayes rule

[dem1, dem2]=size(rawdata);	

cp_ctr=1; 
for j=1:dem2

	q=rawdata(:, j); %select the question of interest
	% Select non-missing observations for the variable j under consideration 
	pp1t=pp1(q~=999);pp2t=pp2(q~=999); pp3t=pp3(q~=999); 
	pp4t=pp4(q~=999); pp5t=pp5(q~=999); indext=index(q~=999); 
	qt=q(q~=999); 	
	resp_ctr=max(unique(qt)); % number of possible responses to the question 
	cp=condprob(cp_ctr: cp_ctr+resp_ctr-1, :);

	for i=1:resp_ctr
	    denom=pp1t(qt==i).*cp(i, 1)+pp2t(qt==i).*cp(i, 2)+pp3t(qt==i).*cp(i, 3)+pp4t(qt==i).*cp(i, 4)+pp5t(qt==i).*cp(i, 5);
	    pp1t(qt==i) = pp1t(qt==i).*cp(i, 1);  pp1t(qt==i) = pp1t(qt==i)./denom;
	    pp2t(qt==i) = pp2t(qt==i).*cp(i, 2); pp2t(qt==i) = pp2t(qt==i)./denom;
	    pp3t(qt==i) = pp3t(qt==i).*cp(i, 3); pp3t(qt==i) = pp3t(qt==i)./denom;
	    pp4t(qt==i) = pp4t(qt==i).*cp(i, 4); pp4t(qt==i) = pp4t(qt==i)./denom;
	    pp5t(qt==i) = pp5t(qt==i).*cp(i, 5); pp5t(qt==i) = pp5t(qt==i)./denom;
	end
	
	pp1(indext)=pp1t; pp2(indext)=pp2t; pp3(indext)=pp3t; 
	pp4(indext)=pp4t; pp5(indext)=pp5t;
	
	cp_ctr=cp_ctr+resp_ctr;
end

% Numerical score
num_score=pp1.*5+pp2.*4+pp3.*3+pp4.*2+pp5.*1;

num_score_round(num_score>=4.5)=5;  num_score_round(num_score>=3.5 & num_score<4.5)=4; 
num_score_round(num_score>=2.5 & num_score<3.5)=3; num_score_round(num_score>=1.5 & num_score<2.5)=2;
num_score_round(num_score<1.5)=1; num_score_round=num_score_round';

num_score_diff=num_score_round-score; match=unique(num_score_diff);
sharediff=zeros(length(num_score_diff), 1); sharediff(num_score_diff~=0)=1;  mean(sharediff)
 
data_all=[rawdata, num_score]; data_all = unique(data_all, 'rows');
csvwrite('mod1r_numscore.csv', data_all);
	
%% MOD1S
clear 

% Load Data
load('mod1s', 'mod1');
rawdata=[mod1{1}, mod1{2},mod1{3}, mod1{4}, mod1{5}, mod1{6}];
year=mod1{7}; mth=mod1{8}; score=mod1{9}; rg=mod1{10}; rctp=mod1{11}; index=mod1{12};
clear mod1

c1 = csvread('30_VQT01_cond.csv'); c2 = csvread('30_VQT02_cond.csv'); c3 = csvread('30_VQT03_cond.csv');
c4 = csvread('30_VQT04_cond.csv'); c5 = csvread('30_VQT05_cond.csv'); c6 = csvread('30_VQT06_cond.csv');
condprob=[c1;c2;c3;c4;c5;c6];

% Initialize priors
pp1=ones(length(score), 1); %set a uniform prior
pp1=pp1.*.2; pp2=pp1; pp3=pp1; pp4=pp1; pp5=pp1;

% apply Bayes rule

[dem1, dem2]=size(rawdata);	

cp_ctr=1; 
for j=1:dem2

	q=rawdata(:, j); %select the question of interest
	% Select non-missing observations for the variable j under consideration 
	pp1t=pp1(q~=999);pp2t=pp2(q~=999); pp3t=pp3(q~=999); 
	pp4t=pp4(q~=999); pp5t=pp5(q~=999); indext=index(q~=999); 
	qt=q(q~=999); 	
	resp_ctr=max(unique(qt)); % number of possible responses to the question 
	cp=condprob(cp_ctr: cp_ctr+resp_ctr-1, :);

	for i=1:resp_ctr
	    denom=pp1t(qt==i).*cp(i, 1)+pp2t(qt==i).*cp(i, 2)+pp3t(qt==i).*cp(i, 3)+pp4t(qt==i).*cp(i, 4)+pp5t(qt==i).*cp(i, 5);
	    pp1t(qt==i) = pp1t(qt==i).*cp(i, 1);  pp1t(qt==i) = pp1t(qt==i)./denom;
	    pp2t(qt==i) = pp2t(qt==i).*cp(i, 2); pp2t(qt==i) = pp2t(qt==i)./denom;
	    pp3t(qt==i) = pp3t(qt==i).*cp(i, 3); pp3t(qt==i) = pp3t(qt==i)./denom;
	    pp4t(qt==i) = pp4t(qt==i).*cp(i, 4); pp4t(qt==i) = pp4t(qt==i)./denom;
	    pp5t(qt==i) = pp5t(qt==i).*cp(i, 5); pp5t(qt==i) = pp5t(qt==i)./denom;
	end
	
	pp1(indext)=pp1t; pp2(indext)=pp2t; pp3(indext)=pp3t; 
	pp4(indext)=pp4t; pp5(indext)=pp5t;
	
	cp_ctr=cp_ctr+resp_ctr;
end

% Numerical score
num_score=pp1.*5+pp2.*4+pp3.*3+pp4.*2+pp5.*1;

num_score_round(num_score>=4.5)=5;  num_score_round(num_score>=3.5 & num_score<4.5)=4; 
num_score_round(num_score>=2.5 & num_score<3.5)=3; num_score_round(num_score>=1.5 & num_score<2.5)=2;
num_score_round(num_score<1.5)=1; num_score_round=num_score_round';

num_score_diff=num_score_round-score; match=unique(num_score_diff);
sharediff=zeros(length(num_score_diff), 1); sharediff(num_score_diff~=0)=1;  mean(sharediff)
 
data_all=[rawdata, num_score]; data_all = unique(data_all, 'rows');
csvwrite('mod1s_numscore.csv', data_all);
					
    

    
