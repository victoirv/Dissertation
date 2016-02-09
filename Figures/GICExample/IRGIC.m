function IRGIC
numxcoef=1;
numfcoef=100;
advance=0; %How much future to use to predict the present

IN=load('FRD-1M.mat');

event=3;
switch event
    case 1
        eventname='Pleasant View Jun-July 2012';
        IN2=load(eventname);
        tstart=datenum(2012,07,14);
        tend=datenum(2012,07,19);
        
    case 2
        eventname='Pleasant View Aug-Oct 2012';
        IN2=load(eventname);
        tstart=datenum(2012,09,02);
        tend=datenum(2012,09,08);
        
    case 3
        eventname='Pleasant View Nov-Dec 2012';
        IN2=load(eventname);
        tstart=datenum(2012,11,12);
        tend=datenum(2012,11,16);
end



t=IN.TMAG;
D=IN.MAG(:,2);
H=IN.MAG(:,1);

D(t<tstart)=[];
H(t<tstart)=[];
t(t<tstart)=[];

D(t>tend)=[];
H(t>tend)=[];
t(t>tend)=[];

Bx=H.*cos(D./60.*(3.14159/180));
By=H.*sin(D./60.*(3.14159/180));

GIC=IN2.D;
GICT=IN2.T;

%Remove below -20

GIC(GICT<tstart)=[];
GICT(GICT<tstart)=[];
GIC(GICT>tend)=[];
GICT(GICT>tend)=[];

GICT(GIC<-20)=[];
GIC(GIC<-20)=[];

sint=datenum(2012,11,12,22,00,00);
eint=datenum(2012,11,12,24,30,00);
sint=datenum(2012,11,13,22,00,00);
eint=datenum(2012,11,14,14,00,00);


GICint=GIC(GICT>sint & GICT<eint);
Bxint=Bx(t>sint & t<eint);
GICTint=GICT(GICT>sint & GICT<eint);
tint=t(t>sint & t<eint);

GICintint=interp1(GICTint,GICint,tint,'nearest');

[vals,is]=xcorr(GICintint,Bxint);
[m,index]=max(vals);
is(index)

GIC=interp1(GICT,GIC,t,'nearest');


[xnew3, corr3, ca, cb]=IR(t,GIC,[Bx,By],numxcoef,numfcoef);

BigFont=18;
BigLine=1.5;


figure
plot((0:(24.5-22)*60)./60+22,GIC(22*60:24.5*60),'LineWidth',BigLine)
hold on
plot((0:(24.5-22)*60)./60+22,xnew3(22*60:24.5*60),'r','LineWidth',BigLine)
ylabel('GIC [A]','FontSize',BigFont)
xlabel('Hours since 2012-11-12 00:00:00','FontSize',BigFont)
set(gca,'FontSize',BigFont);
grid
print('GIC1.eps', '-depsc2', '-r600')
print('GIC1.png', '-dpng', '-r600')


testnum=250;

%Takes a while to run, just save it
if(exist('lagdat.mat','file'))
    load('lagdat.mat')
else
    lagcorr=1:testnum;
    for i=1:testnum
        [~, corr4]=IR(t,GIC,[Bx,By],1,numfcoef,i-1);
        lagcorr(i)=corr4;
    end
    save('lagdat','lagcorr');
end


figure
plot(lagcorr,'LineWidth',BigLine)
xlabel('Lag in minutes','FontSize',BigFont)
ylabel('Correlation','FontSize',BigFont)
grid
hold on
plot(1:testnum,zeros(1,testnum),'r+','LineWidth',BigLine)
set(gca,'FontSize',BigFont);
print('GIClags.eps', '-depsc2', '-r600')
print('GIClags.png', '-dpng', '-r600')
close all


%{
figure
one=plot(0:testnum-1,lagcorr,'r.-','LineWidth',BigLine);
hold on
two=plot(0:testnum-1,lagcorr2,'b.-','LineWidth',BigLine);
legend([one,two],'1 response coef','10 response coef')
ylabel('Correlation Coefficient','FontSize',BigFont)
xlabel('Number of lags','FontSize',BigFont)
title(eventname,'FontSize',BigFont);
set(gca,'FontSize',BigFont);
print('GIClags.eps', '-deps', '-r600')
print('GIClags.png', '-dpng', '-r600')
%}
