%* == IR_Analysis.m == 
%** Analyzes the IRs extracted by IR_Extract.m
%** This makes use of the following functions:
%*** - hExtrct.m	: extracts the IR time series
%*** - hPrp.m 	: measures the properties of the IR time series
%*** - GtMtDt.m	: Reads metadata about recording from a textfile

%* == Preamble ==
clear all; close all; clc
path(path,'Tools')

%* == Specify Inputs == 
Input_file='Input_IR_example';        Sb_fs=4e2; % Frequency of subband envelopes in Hz
%Input_file='Input_IR_Survey_2_OM';  Sb_fs=4e2; % Frequency of subband envelopes in Hz
Input_file='Input_IR_ControlION';  Sb_fs=4e2; % Frequency of subband envelopes in Hz
Input_file='Input_IR_Control';  Sb_fs=4e2; % Frequency of subband envelopes in Hz
Input_file='Input_ACvsBth';  Sb_fs=4e2; % Frequency of subband envelopes in Hz
Input_file='Input_Spkr';
Input_file='Input_SpkrTst'; Sb_fs=4e2; 
%Input_file='Input_ShrtvsLng';  Sb_fs=4e2; % Frequency of subband envelopes in Hz
%Input_file='Input_IRSurvey_NatStats'; Sb_fs=4e2;
%Input_file='Input_ObjIRs';      Sb_fs=1e3; 
%Input_file='Input_ObjIRs_Ext';      Sb_fs=1e3; 
%Input_file='Input_BrdDrps';      Sb_fs=1e3; 
eval(sprintf('[Rpth,Cpth,Mt]=%s;',Input_file));

%** = Number of cochlear subbands for analysis =
Nbnds=[4];
%** = Frequency limits in Hz =
flm=[50 20e3];
% Overwrite calibration files (Do this if hPrp or any paths have been changed)
OvrWrtCAL=1;
%** filetype
ftp='jpg';
%ftp='epsc';

%* == Calibrate Apparatus ==
%** search for calibration files 
C=[];
if ~isempty(Cpth); clear C
    %==> Gather a structure of paths
    Dh=[];
    for jc=1:length(Cpth);
        tDh=dir([Cpth(jc).Pth '/*.wav']);
        for jj=1:length(tDh);
            %==> save path stems
            tDh(jj).PthStm=Cpth(jc).Pth;  
        end
        Dh=[Dh; tDh];
    end
    %==> scroll through paths and load 
    ccnt=0;
    for jc=1:length(Dh);
        tDh=dir(sprintf('%s/%s/ch*',Dh(jc).PthStm,Dh(jc).name(1:end-4)));
        for jch=1:length(tDh);
            ccnt=ccnt+1;
            load(sprintf('%s/%s/ch%d/H.mat',Dh(jc).PthStm,Dh(jc).name(1:end-4),jch));
            %====> Check to see if the IR is already analyzed
            if (exist(sprintf('%s/H_%03dbnds.mat',H.Path,Nbnds))==2&&OvrWrtCAL==0);
                load(sprintf('%s/H_%03dbnds.mat',H.Path,Nbnds));
            else
                H=hPrp(H,[],Nbnds,flm,Sb_fs,ftp);
                save(sprintf('%s/H_%03dbnds.mat',H.Path,Nbnds),'H');
                h=H.h;
                MaxAmp=max(abs(h));
                h=h/MaxAmp*(1-1e-6);
                h=[zeros(ceil(H.fs/5),1); h; zeros(ceil(H.fs/2),1)];
                audiowrite(sprintf('%s/h_denoised_%03d.wav',H.Path,Nbnds),h,H.fs,'BitsPerSample',24); 
            end
            %===> coallate a structure 
            C(ccnt)=H;
        end
    end
    % Integrate the multiple measurements into direct and volume integrated signals, for each recording channel
    for jch=1:max([C.Channel])
        tC=C(find([C.Channel]==jch));
        fprintf('Integrating Calibration measurements into an omnidirectional IR: channel %d\n',jch)
        [tV]=IntDrctTrnsFn(tC); 
        tV=hPrp(tV,[],Nbnds,flm,Sb_fs,ftp);
        H=tV;
        save(sprintf('%s/H_%03dbnds.mat',H.Path,Nbnds),'H');
        h=H.h;
        MaxAmp=max(abs(h));
        h=h/MaxAmp*(1-1e-6);
        h=[zeros(ceil(H.fs/5),1); h; zeros(ceil(H.fs/2),1)];
        audiowrite(sprintf('%s/h_denoised_%03d.wav',H.Path,Nbnds),h,H.fs,'BitsPerSample',24); 
        fprintf('Saved to %s\n',H.Path);
        C(length(C)+1)=H;
    end

%	%** save plots of calibration information
    close all
    fcnt=0;
    %*** Plot direct vs volume spectra
    fcnt=fcnt+1;
    figure(fcnt);
    PltCAL_Spc(C);
    OtPth=GtPthStm(GtPthStm(C(1).Path));
    title([OtPth ': CAL Spectra']);
    saveas(gcf,sprintf('%s/CAL_Spc',OtPth),'jpg');

    fprintf('Calibration plots saved\n')
end % if ~isempty(Dc)
clear H 

%* == Extract IRs == 
%** load IRs
Dh=[];
for jr=1:length(Rpth);
    tDh=dir([Rpth(jr).Pth '/*.wav']);
    for jj=1:length(tDh);
        %==> save path stems
        tDh(jj).PthStm=Rpth(jr).Pth;  
    end
    Dh=[Dh; tDh];
end
%** Scroll through them
hcnt=0;
for jh=1:length(Dh);
    tDh=dir(sprintf('%s/%s/ch*',Dh(jh).PthStm,Dh(jh).name(1:end-4)));
    for jch=1:length(tDh);
        hcnt=hcnt+1;
        load(sprintf('%s/%s/ch%d/H.mat',Dh(jh).PthStm,Dh(jh).name(1:end-4),jch));
        %*** => Analyze
        H=hPrp(H,C,Nbnds,flm,Sb_fs,ftp);
        save(sprintf('%s/H_%03dbnds.mat',H.Path,Nbnds),'H');
        fprintf('Data saved to %s_%dBnds\n',H.Path,Nbnds);   
        %*** => Make synthetic IRs
        hSynth(H);
        %*** => save plots of IR information
        %*** => save audio
        h=H.h;
        MaxAmp=max(abs(h));
        h=h/MaxAmp*(1-1e-6);
        h=[zeros(ceil(H.fs/5),1); h; zeros(ceil(H.fs/2),1)];
        % compute a tail only time series
        t=H.tl;
        t=t/MaxAmp*(1-1e-6);
        t=[zeros(ceil(H.fs/5),1); t; zeros(ceil(H.fs/2),1)];
        if ~isempty(H.CalibrationFiles)
            audiowrite(sprintf('%s/h_cal_%03d.wav',H.Path,Nbnds),h,H.fs,'BitsPerSample',24);
            audiowrite(sprintf('%s/h_tl_cal_%03d.wav',H.Path,Nbnds),t,H.fs,'BitsPerSample',24);
            for jsnp=1:size(H.h_snps,2);
                h=H.h_snps(:,jsnp);
                MaxAmp=max(abs(h));
                h=h/MaxAmp*(1-1e-6);
                h=[zeros(ceil(H.fs/5),1); h; zeros(ceil(H.fs/2),1)];
                audiowrite(sprintf('%s/h_snp%03d_cal_%03dbnds.wav',H.Path,jsnp,Nbnds),h,H.fs,'BitsPerSample',24);
                t=H.tl_snps(:,jsnp);
                t=t/MaxAmp*(1-1e-6);
                t=[zeros(ceil(H.fs/5),1); t; zeros(ceil(H.fs/2),1)];
                audiowrite(sprintf('%s/h_tl_snp%03d_cal_%03dbnds.wav',H.Path,jsnp,Nbnds),t,H.fs,'BitsPerSample',24);
            end
        else 
            audiowrite(sprintf('%s/h_denoised_%03d.wav',H.Path,Nbnds),h,H.fs,'BitsPerSample',24); 
        end
    end
end
fprintf('%d IRs analyzed\n',length(Dh));

%* == Save details about CPU run time

