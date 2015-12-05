function ok=conn_dynexplore
global CONN_x CONN_gui;

if ~isfield(CONN_gui,'font_offset'), font_offset=0; else font_offset=CONN_gui.font_offset; end
if ~isfield(CONN_gui,'backgroundcolor'), backgroundcolor=[0 0 0]; else backgroundcolor=CONN_gui.backgroundcolor; end
filepathresults=CONN_x.folders.preprocessing;
load(fullfile(filepathresults,'dyn_Base.mat'),'B','H','B0','H0','IDX_subject','IDX_session','ROInames','names');
if ~exist('ROInames','var'), uiwait(errordlg('Sorry, this option is not available until the first-level dynamic FC analyses have been re-run','')); return; end
B0=permute(B0,[3 1 2]);
B=permute(B,[3 1 2]);
IDX_scan=ones(size(IDX_session));
temp=find(IDX_subject(max(1,0:numel(IDX_subject)-1))~=IDX_subject|IDX_session(max(1,0:numel(IDX_session)-1))~=IDX_session);
IDX_scan(temp)=1-diff([1;temp]);
IDX_scan=cumsum(IDX_scan);
ROInamesDisplay=regexprep(ROInames,'^atlas\.','');
ROInamesDisplay2=regexprep(ROInames,'^atlas\.|\([^\(\)]+\)','');
varB=sqrt(max(0,conn_bsxfun(@times,mean(H.^2,1)',abs(B).^2)));
[Bhf_values,Bhf_order]=sort(varB,1,'descend');
try
    if 0
        x=conn_bsxfun(@times,cat(1,.0*B0,B),sqrt(mean(cat(2,H0,H).^2,1))');
        x=reshape(x,[],size(B,3));
        nx=sum(x.^2,1);
        y=sqrt(max(0,conn_bsxfun(@plus,nx,nx')-2*(x'*x)));
        y=y(tril(ones(size(y,1)),-1)>0)';
        z=conn_statslinkage(y,'av');
        [nill,nill,idxorder]=conn_statsdendrogram(z,0);
    else
        load(fullfile(fileparts(which('conn')),'connROIorder.mat'),'ROIconfiguration');
        [ok,idx1]=ismember(ROInames,ROIconfiguration.names2);
        ok=find(ok);
        z=angle(ROIconfiguration.xy2(idx1(ok),:)*[1;1i]).';
        [nill,idx2]=sort(z);
        idxorder=[ok(idx2), setdiff(1:numel(ROInames), ok)];
    end
catch
    idxorder=1:numel(ROInames);
end

B0(:,1:size(B0,2)+1:end)=nan;
boffset=[0 0 0 0];
conn_menu('frame',boffset+[.44 .5 .16 .4],'');
ht2=conn_menu('listbox',boffset+[.45 .71 .14 .14],'Dynamic factors',names,'<HTML>Select factor(s) for display <br/> - <i>Factor scores</i> will display only the selected factors <br/> - <i>ROI-to-ROI connectivity</i> will display only the contribution of the selected factors on the estimated dynamic ROI-to-ROI connectivity values</HTML>',@(varargin)conn_dynexplore_update([0 0 1 0]));
ht1=conn_menu('listbox',boffset+[.45 .515 .14 .14],'Subjects',arrayfun(@(n)sprintf('Subject %d',n),1:CONN_x.Setup.nsubjects,'uni',0),'Select subject(s) for display',@(varargin)conn_dynexplore_update);
ht3=conn_menu('slider',boffset+[.20 .05 .40 .05],'Time',1,'<HTML>Select time point</HTML>',@(varargin)conn_dynexplore_update);
addlistener(ht3, 'ContinuousValueChange',@(varargin)conn_dynexplore_update); 
set(ht3,'visible','off');
conn_menumanager('onregion',ht3,1,boffset+[.20 .05 .40 .40]);
ht4=conn_menu('popup',boffset+[.70 .825 .20 .05],'',{'ROI-to-ROI connectivity matrix (dynamic)','Static vs. Dynamic connectivity'},'<HTML>Select connectivity display</HTML>',@(varargin)conn_dynexplore_update);
ht5=conn_menu('pushbutton',boffset+[.75 .075 .10 .05],'','Play','<HTML>Display dynamic connectivity over time</HTML>',@(varargin)conn_dynexplore_play);
%conn_menumanager('onregion',ht5,1,boffset+[.65 .05 .3 .775]);
set(ht1,'max',2,'value',1);
set(ht2,'max',2,'value',1:numel(names));
set(ht4,'value',1);
set(ht5,'interruptible','on','userdata',0);

%cmap=[[flipud(gray(128))*diag([0 0 1]);(gray(128))*diag([1 0 0])].^1; gray(256); CONN_gui.backgroundcolor];
cmap=[jet(256); gray(256); CONN_gui.backgroundcolor];
hfig=gcf;
handleplot=[];
handleimag=[];
handleload=[];
handlescor=[];
c0=[]; c=[]; idxlock=[1,2,0]; 
conn_dynexplore_update;
%conn_dynexplore_play;

    function conn_dynexplore_update(doreset)
        if nargin<1, doreset=[0 0 0 0]; end
        nsub=get(ht1,'value');
        nfac=get(ht2,'value');
        nt=round(get(ht3,'value'));
        dtype=get(ht4,'value');
        itime=find(ismember(IDX_subject,nsub));
        Nt=numel(itime);
        Nf=size(B,1);
        ntold=nt; nt=max(1,min(Nt, nt));
        set(ht3,'min',1,'max',Nt,'sliderstep',1/Nt*[1 2]);
        if nt~=ntold, set(ht3,'value',nt); end
        ntime=itime(nt);

        %disp(idxlock);
        c0=reshape(H0(ntime,:)*B0(:,:),size(B0,2),size(B0,3));
        c=reshape(H(ntime,nfac)*B(nfac,:),size(B,2),size(B,3));
        %c0(1:size(c0,1)+1:end)=nan;
        
        if doreset(1)||isempty(handleplot)||any(~ishandle(handleplot))
            delete(handleplot(ishandle(handleplot)));
            h1=axes('units','norm','position',[.65 .15 .30 .675]);
            h2=plot(c0(idxorder,idxorder),c0(idxorder,idxorder)+c(idxorder,idxorder),'.',[-2 2 nan -2 2 nan 0 0],[-2 2 nan 0 0 nan -2 2],'k','markersize',6);
            hold on; h4=plot(0,0,'wo','visible','off','markersize',12); hold off;
            h3=uicontrol('units','norm','position',[.65 .1 .0001 .0001],'style','text','fontsize',7+CONN_gui.font_offset,'foregroundcolor','k','backgroundcolor','w','visible','off','horizontalalignment','left'); 
            axis equal tight;
            conn_menumanager('onregion',h3,1,[.65 .15 .30 .675],h1,@conn_dynexplore_mtnplot);
            set(h1,'xlim',[-2 2],'ylim',[-2 2],'color',CONN_gui.backgroundcolor,'xcolor',CONN_gui.backgroundcolor,'ycolor',CONN_gui.backgroundcolor,'xtick',[],'ytick',[]);
            set([h2(:)' h1 h4],'buttondownfcn',@conn_dynexplore_buttonpress);
            h1a=xlabel('Static connectivity'); set(h1a,'fontsize',CONN_gui.font_offset+8,'color',.1*[1 1 1]+.8*(.5>mean(CONN_gui.backgroundcolor)));
            h1b=ylabel('Dynamic connectivity'); set(h1b,'fontsize',CONN_gui.font_offset+8,'color',.1*[1 1 1]+.8*(.5>mean(CONN_gui.backgroundcolor)));
            handleplot=[h2(:)' h1a h1b h1 h4 h3];
        end
        if doreset(2)||isempty(handleimag)||any(~ishandle(handleimag))
            delete(handleimag(ishandle(handleimag)));
            h1=axes('units','norm','position',[.65 .15 .3 .675],'color',CONN_gui.backgroundcolor);
            h2=image(ind2rgb(max(1,min(256, round(128.5+127*(c0(idxorder,idxorder)+c(idxorder,idxorder))))),cmap));
            hold on; h4=plot(0,0,'ko','visible','off','markersize',12); hold off;
            h3=uicontrol('units','norm','position',[.65 .1 .0001 .0001],'style','text','fontsize',7+CONN_gui.font_offset,'foregroundcolor','k','backgroundcolor','w','visible','off','horizontalalignment','left'); 
            %h3=text(0,0,1,''); set(h3,'visible','off','backgroundcolor','w','color','k','fontsize',CONN_gui.font_offset+7);
            axis equal tight;
            conn_menumanager('onregion',h3,1,[.65 .15 .3 .675],h1,@conn_dynexplore_mtnimag);
            set(h1,'color',CONN_gui.backgroundcolor,'xcolor',CONN_gui.backgroundcolor,'ycolor',CONN_gui.backgroundcolor,'xtick',[],'ytick',[],'ydir','normal');
            set([h2 h1 h4],'buttondownfcn',@conn_dynexplore_buttonpress);
            %h=title({'Connectivity matrix','(total: static + dynamic)'}); set(h,'fontsize',CONN_gui.font_offset+8,'color',.1*[1 1 1]+.8*(.5>mean(CONN_gui.backgroundcolor)));
            handleimag=[h2 h1 h4 h3];
        end
        if doreset(3)||isempty(handleload)||any(~ishandle(handleload))
            delete(handleload(ishandle(handleload)));
            h1=axes('units','norm','position',[.20 .5 .2 .4],'color',CONN_gui.backgroundcolor);
            temp=permute(B(:,end:-1:1,:),[2 3 1]);
            temp=temp/max(abs(temp(:)));
            temp(:,:,setdiff(1:Nf,nfac))=temp(:,:,setdiff(1:Nf,nfac))+2;
            s1=max(1,floor(sqrt(Nf))); s2=ceil(Nf/s1); 
            temp=cat(3,temp,nan([size(temp,1),size(temp,2),s1*s2-size(temp,3)]));
            temp=reshape(temp,[size(temp,1),size(temp,2),s1,s2]);
            temp=cat(1, nan(size(temp).*[0 1 1 1]+[4 0 0 0]), temp, nan(size(temp).*[0 1 1 1]+[4 0 0 0]));
            temp=cat(2, nan(size(temp).*[1 0 1 1]+[0 4 0 0]), temp, nan(size(temp).*[1 0 1 1]+[0 4 0 0]));
            temp=reshape(permute(temp,[1 3 2 4]),[size(temp,1)*s1, size(temp,2)*s2]);
            h2=image(ind2rgb(max(1,min(size(cmap,1), round(128.5+127*temp))),cmap));
            axis equal;
            set(h1,'color',CONN_gui.backgroundcolor,'xcolor',CONN_gui.backgroundcolor,'ycolor',CONN_gui.backgroundcolor,'xtick',[],'ytick',[],'ydir','reverse');
            hold on; h2a=text(get(gca,'xlim')*[1.05;-.05],mean(get(gca,'ylim')),{'Factor','loadings'},'color',.1*[1 1 1]+.8*(.5>mean(CONN_gui.backgroundcolor)),'horizontalalignment','right','fontsize',CONN_gui.font_offset+8); hold off;
            %h=ylabel('Factor loadings'); set(h,'fontsize',CONN_gui.font_offset+8,'color',.1*[1 1 1]+.8*(.5>mean(CONN_gui.backgroundcolor)));
            handleload=[h2 h1];
        end
        if doreset(4)||isempty(handlescor)||any(~ishandle(handlescor))
            delete(handlescor(ishandle(handlescor)));
            h1=axes('units','norm','position',[.20 .15 .40 .30]);
            h2=plot(repmat((1:Nt)',1,Nf),H(itime,:),'-',1:Nt,zeros(1,Nt),'w-',[0 size(H,1)+1 nan 0 size(H,1)+1],[0 0 nan -2 -2],'k-',[0 0],[-4 2],'w:');
            set(h2(end),'color',.1*[1 1 1]+.8*(.5>mean(CONN_gui.backgroundcolor)));
            set(h2(Nf+1),'linewidth',2,'color',.1*[1 1 1]+.8*(.5>mean(CONN_gui.backgroundcolor)));
            axis tight;
            hold on; h3=text(0,1.6,'','horizontalalignment','left','color',.1*[1 1 1]+.8*(.5>mean(CONN_gui.backgroundcolor)),'fontsize',CONN_gui.font_offset+7); hold off;
            hold on; h4=text(0,1.6-2,'','interpreter','tex','horizontalalignment','right','color',.1*[1 1 1]+.8*(.5>mean(CONN_gui.backgroundcolor)),'fontsize',CONN_gui.font_offset+7); hold off;
            set(h1,'xlim',[0 Nt+1],'ylim',[-3.5 1.5],'color',CONN_gui.backgroundcolor,'xcolor',CONN_gui.backgroundcolor,'ycolor',CONN_gui.backgroundcolor,'xtick',[],'ytick',[]);
            h=xlabel('Time / scans'); set(h,'fontsize',CONN_gui.font_offset+8,'color',.1*[1 1 1]+.8*(.5>mean(CONN_gui.backgroundcolor)));
            hold on; h2a=text(get(gca,'xlim')*[1.025;-.025],0,{'Factor','scores'},'color',.1*[1 1 1]+.8*(.5>mean(CONN_gui.backgroundcolor)),'horizontalalignment','right','fontsize',CONN_gui.font_offset+8); 
            h2b=text(get(gca,'xlim')*[1.025;-.025],-2,{'ROI-to-ROI','connectivity','(dynamic)^(^*^)'},'interpreter','tex','color',.1*[1 1 1]+.8*(.5>mean(CONN_gui.backgroundcolor)),'horizontalalignment','right','fontsize',CONN_gui.font_offset+8); hold off;
            handlescor=[h2(:)' h3 h4 h1];
        end
        if dtype==1, set(handleplot,'visible','off'); set(handleimag(1:end-1),'visible','on'); 
        else         set(handleplot(1:end-1),'visible','on'); set(handleimag,'visible','off'); 
        end
        temp=max(-2,min(2,c0(idxorder,idxorder)+c(idxorder,idxorder))); %temp(1:size(temp,1)+1:end)=nan;
        temp0=c0(idxorder,idxorder); 
        for n=1:size(temp,2), set(handleplot(n),'xdata',temp0(:,n),'ydata',temp(:,n)); end
        set(handleplot(end-1),'xdata',c0(idxlock(1),idxlock(2)),'ydata',c0(idxlock(1),idxlock(2))+c(idxlock(1),idxlock(2)));
        set(handleimag(end-1),'xdata',find(idxorder==idxlock(2),1),'ydata',find(idxorder==idxlock(1),1));
        temp=ind2rgb(max(1,min(256, round(128.5+127*(c0(idxorder,idxorder)+c(idxorder,idxorder))))),cmap);
        set(handleimag(1),'cdata',temp);
        for n=1:Nf, if any(nfac==n), set(handlescor(n),'xdata',1:Nt,'ydata',H(itime,n)); else set(handlescor(n),'xdata',1:Nt,'ydata',nan(1,Nt)); end; end
        tempr=H0(itime,:)*B0(:,idxlock(1),idxlock(2))+H(itime,nfac)*B(nfac,idxlock(1),idxlock(2));
        set(handlescor(Nf+1),'xdata',1:Nt,'ydata',-2+tempr);
        set(handlescor(Nf+3),'xdata',nt+[0 0]); 
        set(handlescor(end-2),'position',[nt 1.6 0],'string',sprintf('Subject %d Session %d Scan %d',IDX_subject(ntime),IDX_session(ntime),IDX_scan(ntime))); 
        hext=get(handlescor(end-2),'extent'); hext=hext(end-1:end); set(handlescor(end-2),'position',[min(Nt,nt+hext(1))-hext(1) 1.6 0]); 
        set(handlescor(end-1),'position',[Nt -1.5-2 0],'string',sprintf('^(^*^) Connectivity between %s and %s',ROInamesDisplay2{idxlock(1:2)})); 
        set(handlescor(end),'xlim',[0 Nt+1]);
    end

    function conn_dynexplore_mtnimag(varargin)
        pos0=get(hfig,'currentpoint');
        if ~idxlock(3)
            pos=get(handleimag(end-2),'currentpoint');
            pos=pos(1,1:2);
        else pos=[find(idxorder==idxlock(2),1) find(idxorder==idxlock(1),1)];
        end
        if all(pos>0&pos<numel(ROInames)),
            pos=max(1,min(numel(ROInames), round(pos)));
            hf=arrayfun(@(a,b)sprintf(' Factor %d (%.3f)',a,b),Bhf_order(1:min(size(B,1),3),idxorder(pos(1)),idxorder(pos(2))),Bhf_values(1:min(size(B,1),3),idxorder(pos(1)),idxorder(pos(2))),'uni',0)';
            set(handleimag(end),'units','pixels','string',[{'Connectivity between:'} ROInamesDisplay(idxorder(pos)) {' ','Highest factor loadings:'} hf]);
            hext=get(handleimag(end),'extent'); hext=hext(end-1:end);
            set(handleimag(end),'position',[pos0(1:2)+[10 -hext(2)-10] hext]);
            set(handleimag(end-1),'xdata',pos(1),'ydata',pos(2),'visible','on');
            idxlock(1:2)=[idxorder(pos(2)) idxorder(pos(1))];
            conn_dynexplore_update;
            %set(handleimag(end),'units','pixels','position',[pos0(1:2)+[-2 -2] 5 5],'tooltipstring',conn_cell2html(ROInamesDisplay(pos)));
            %set(handleimag(end),'units','pixels','position',[pos0(1:2)+[-150 10] 300 40],'string',ROInamesDisplay(pos));
            %try, uistack(handleimag(end),'top'); end
            %set(handleimag(end),'position',[pos+.05*numel(ROInames) 1],'string',ROInamesDisplay(pos));
        end
    end
    function conn_dynexplore_mtnplot(varargin)
        pos0=get(hfig,'currentpoint');
        if ~idxlock(3)
            pos=get(handleplot(end-2),'currentpoint');
            pos=pos(1,1:2);
        else pos=[c0(idxlock(1),idxlock(2)) c0(idxlock(1),idxlock(2))+c(idxlock(1),idxlock(2))];
        end
        [nill1,idx1]=min((c0-pos(1)).^2+(c+c0-pos(2)).^2,[],1);
        [nill2,idx2]=min(nill1,[],2);
        idx1=idx1(idx2);
        if nill2<.25^2,
            pos=max(1,min(numel(ROInames), [idx2 idx1]));
            hf=arrayfun(@(a,b)sprintf(' Factor %d (%.3f)',a,b),Bhf_order(1:min(size(B,1),3),pos(1),pos(2)),Bhf_values(1:min(size(B,1),3),pos(1),pos(2)),'uni',0)';
            set(handleplot(end),'units','pixels','string',[{'Connectivity between:'} ROInamesDisplay(pos) {' ','Highest factor loadings:'} hf]);
            hext=get(handleplot(end),'extent'); hext=hext(end-1:end);
            set(handleplot(end),'position',[pos0(1:2)+[10 -hext(2)-10] hext]);
            set(handleplot(end-1),'xdata',c0(idx1,idx2),'ydata',c0(idx1,idx2)+c(idx1,idx2),'visible','on');
            idxlock(1:2)=[idx1 idx2];
            conn_dynexplore_update;
        end
    end
    function conn_dynexplore_buttonpress(varargin)
        idxlock(3)=~idxlock(3);
    end
    function conn_dynexplore_play(varargin)
        state=get(ht5,'userdata');
        if state
            set(ht5,'string','Play','userdata',0);
        else
            nsub=get(ht1,'value');
            nt=round(get(ht3,'value'));
            itime=find(ismember(IDX_subject,nsub));
            Nt=numel(itime);
            ntold=nt; nt=max(1,min(Nt, nt));
            set(ht3,'min',1,'max',Nt,'sliderstep',1/Nt*[1 2]);
            if nt~=ntold, set(ht3,'value',nt); end
            set(ht5,'string','Stop','userdata',1);
            for n1=nt:Nt
                set(ht3,'value',n1);
                conn_dynexplore_update;
                drawnow;
                pause(.02);
                if ~ishandle(ht5), return; end
                state=get(ht5,'userdata');
                if ~state, break; end
            end
            if n1==Nt, set(ht3,'value',1); end
            set(ht5,'string','Play','userdata',0);
            conn_dynexplore_update;
        end
    end
end

