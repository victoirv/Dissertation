function [xnew, corr, ca, cb] = IR(t,x,f,numxcoef,numfcoef,lag)
%Usage: [xnew, corr, ca, cb] = IRm(t,x,f,numxcoef,numfcoef)
%Where ca are the x coefficients, cb the f coefficients
%Allows for a matrix of impulses
%***Important: Assumes more data points than impulses***%

if (nargin < 5) || (nargin > 6)
    disp('Usage: [xnew, corr, ca, cb] = IRm(t,x,f,numxcoef,numfcoef)');
    disp('Where ca are the x coefficients, cb the f coefficients');
    disp('***Important: Assumes more data points than impulses***');
    error('');
end
if nargin == 5
    lag=0;
end

predstart=max(numxcoef+lag+1,numfcoef);

xstart=predstart-numxcoef-lag;
fstart=predstart-numfcoef+1;


len=floor(length(t)-predstart);
m=max(numxcoef,numfcoef-1);
numimpulses=min(size(f));
    
A=zeros(len,numxcoef+numfcoef*numimpulses+1);

%Must add +i-1 to shift column start point
for i=1:numxcoef
   A(1:len,i)=x(xstart+i-1:xstart+i-1+len-1); 
end
for i=1:numfcoef
    for j=1:numimpulses
        A(1:len,i+numxcoef+(j-1)*numfcoef)=f(fstart+i-1:fstart+i-1+len-1,j);
    end
end
A(:,end)=1;

b=x(predstart:predstart+len-1);
A=[A(1:end,:) b];

for a=1:(numxcoef+numfcoef+1)
    A(isnan(A(:,a)),:)=[];
end
b=A(:,end);
A=A(:,1:end-1);


coef=A(1:end,:)\b;

ca=coef(1:numxcoef);
cb=coef(numxcoef+1:end-1);
cc=coef(end);
ca';
cb';


if numxcoef<numfcoef
    m=m+1;
end

xtemp=x;
ftemp=f;
%{
xtemp(isnan(f))=NaN;
ftemp(isnan(x))=NaN;
xtemp=xtemp(~isnan(xtemp));
ftemp=ftemp(~isnan(ftemp));


xtemp(isnan(f))=NaN;
%ftemp(isnan(x))=0;
xtemp(isnan(x))=NaN;
ftemp(isnan(f))=NaN;
%xtemp=xtemp(xtemp~=0);
%ftemp=ftemp(ftemp~=0);
%}


xnew=zeros(length(x),1);
xnew(1:m)=xtemp(1:m);

%Anywhere f is nan, don't predict, just copy data
iter=1:(length(f));
%{
xnew(isnan(f))=x(isnan(f));
cutout=1:length(f);
cutout(isnan(f))=NaN;
for i=1:m+1
    cutout(circshift(isnan(f),[0 i]))=NaN;
end

iter=iter(~isnan(cutout)); %Don't predict using NaNs 
%}
iter=iter(iter>=m+1); %Don't use copied variables

for i=iter
    %xnew(i)=(xnew(i-numxcoef:1:i-1)'*ca)+(ftemp(i-numfcoef+1:1:i)'*cb)+cc;
    xnew(i)=(xtemp(i-numxcoef:1:i-1)'*ca)+(reshape(ftemp(i-numfcoef+1:1:i,:),1,[])*cb)+cc;
end

xnew(isnan(f))=NaN;

%Calculate correlation here to save program from needing to strip NaNs
skip=(isnan(xnew) | isnan(xtemp));
corr=corrcoef(xnew(~skip),xtemp(~skip)); %Ignore first added bit
corr=corr(1,2);
