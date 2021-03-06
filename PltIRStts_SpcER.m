function PltIRStts_SpcER(Dh,PltPrm,V);

% preallocate one data point for each class for the legend
MkLgnd(V,Dh,PltPrm)

for jj=1:length(V);
    % collate all IRs that have this particular label
    tH=[]; 
    for jh=1:length(Dh);
        eval(sprintf('if strcmp(Dh(jh).%s,V(jj).name); load(''%s/%s''); tH=[tH H]; end;',PltPrm,Dh(jh).PthStm,Dh(jh).name));
    end
    % specify the ordinates and abscissa
    ff=H.Attck(3).ff/1e3; mplt=zeros(length(ff),length(tH));
    for jh=1:length(tH);
        mplt(:,jh)=10*log10(tH(jh).Attck(3).Spc);
    end
    plt=median(mplt,2);
    err=std(mplt,[],2);
    % spooth for plot
    plt=medfilt1(plt,2);
    err=medfilt1(err,2);
    % plot
    hp=plot(plt,ff,['-']); hold on
    set(hp,'linewidth',1,'markersize',6);
    set(hp,'color',V(jj).cmp);
    [mx,mxndx]=max(plt);
    hp=text(mx+0.1,ff(mxndx),1.001,V(jj).name); 
    set(hp,'color',V(jj).cmp);
    hp=plot(plt+err,ff,':'); hold on
    set(hp,'color',V(jj).cmp);
    hp=plot(plt-err,ff,':'); hold on
    set(hp,'color',V(jj).cmp);
end; hold off 
axis tight; xlm=get(gca,'xlim'); ylm=get(gca,'ylim');
%set(gca,'xlim',[0.5*xlm(1) 1.2*xlm(2)]);
set(gca,'yscale','log');
set(gca,'ylim',[50 20e3]/1e3);
xlabel('Power (dB)')
ylabel('Frequency (kHz)')
title(PltPrm)
