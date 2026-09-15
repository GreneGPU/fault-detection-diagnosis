clc
clear all

load Training.mat;
X1 =T1;
xmean=mean(X1); xstd= std(X1);
X1= (X1-xmean(ones(10372,1),:))./xstd(ones(10372,1),:);

[U1,S1,V1]=svd((1/sqrt(10372-1))*X1);
%%
P1=V1(:,1:2);
P=V1(:,1:2);
T=X1*P;
Sa1=S1(1:2,1:2);
syms t1 t2
M=[t1 t2]*((Sa1)^(-2))*[t1;t2]
f=finv(0.95,2,10372-2)
Ta2=((2*(10372-1))*(10372+1))/(10372*(10372-2))*f

y1=[0.1217 0.1171 0.1000 0.1027 0.0991 0.0171 0.0306 0.0210 0.5019 -0.2470 0.8252 0.0619 19.9571800200000	976.566284200000	998.839416500000	18.9431190500000	18.9746208200000	17.8366203300000	34.5466499300000	20.7245693200000	43.1301193200000	28.0068397500000	2.05999994300000	0.0146442294000000];
y1=(y1-xmean)./xstd
y1=y1';
t=P'*y1

%%y1=[69 0 0 6 6.8 28];
%%y1=(y1-xmean)./xstd
%%y1=y1';
%%t=P'*y1

%%t3=t(1,:)
%%t4=t(2,:)
%%t5=((1847259174595035*t3^2)/4503599627370496 + (5694791486213201*t4^2)/9007199254740992)
%%if(((1847259174595035*t3^2)/4503599627370496 + (5694791486213201*t4^2)/9007199254740992)<=Ta2)
    %%{fprintf('no fault')};
%%else {fprintf('fault')};
%%end
   
%% T2
t1=t(1);
t2=t(2);
Mvalue=subs(M);
T=vpa(Mvalue)
T_2_threshold =Ta2;

%% Q
Sigma = diag(S1);
ca= 1.96;
sig= Sigma;
sig_truncated=sig(2+1:6);
theta1=sum(sig_truncated.^1);
theta2=sum(sig_truncated.^2);
theta3=sum(sig_truncated.^3);
h0=1-(2*theta1*theta3)/(3*theta2^2);
Q_treshold=theta1*((h0*ca*sqrt(2*theta2))/theta1+1+(theta2*h0*(h0-1))/(theta1^2))^(1/h0);

r=y1'*(eye(size(P*P'))-P*P');
Q=r*r'
Q_treshold

%Plot Data
figure;
plot()



