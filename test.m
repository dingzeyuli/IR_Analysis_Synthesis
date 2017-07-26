clear
close all

addpath('Tools')
[x, fs] = audioread('Audio/h021_Bedroom_102txts.wav');
%x = wgn( 10000, 1, 1);

H.h = x;
H.fs = fs;
H.Path = 'results/';
H.h_snps=H.h;
H2 = hPrp(H,[ ],4,[100 20e3],100,'jpg');
return

% 
% close all
% figure
% set(0,'DefaultFigureVisible','on');
%  
% plot(smooth(H2.krt(1:1600),100))

C = [];
fntsz=15;

D=[]; V=[];

%* == Compute kurtosis in 10ms windows ==
%** Find the numbr of points in a 2ms window and make sure it is an even number
window_time = 0.03;
Nbn=ceil(window_time*H.fs); 
if Nbn>length(H.h)*2;
    Nbn=length(H.h)/4;
end
Nbn=Nbn+rem(Nbn,2); 
%** Repeat the first and last 5ms sections
tmp=[H.h(1:Nbn/2); H.h; H.h(end-Nbn/2+1:end)]; 
%** Scroll through data points
krt=zeros(length(H.h),1); 
stndx=0; Nstp=1; 
while stndx<(length(tmp)/Nstp-Nbn); stndx=stndx+1; 
    sc=tmp((stndx-1)*Nstp+[1:Nbn]); 
    krt(stndx,:)=kurtosis(sc); 
end; 
H.krt=krt;

t = linspace(0,length(x)/fs, length(x));
figure
plot(t, smooth(krt,100))

