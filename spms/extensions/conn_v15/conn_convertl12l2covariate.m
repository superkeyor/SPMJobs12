function conn_convertl12l2covariate(varargin)
global CONN_x CONN_gui;
if ~isfield(CONN_gui,'font_offset'), CONN_gui.font_offset=0; end

filepath=CONN_x.folders.data;
filename=fullfile(filepath,['COND_Subject',num2str(1,'%03d'),'_Session',num2str(1,'%03d'),'.mat']);
if isempty(dir(filename)), uiwait(warndlg(['Not ready to compute aggregate measures yet. Please run Setup step first (minimally: conn_process setup_conditions)'],'')); return; end

if nargin<1||isempty(varargin{1}), return; end
ncovariates=varargin;
if iscell(ncovariates)
    if ischar(ncovariates{1})
        [ok,ncovariates]=ismember(ncovariates,CONN_x.Setup.l1covariates.names(1:end-1)); 
    else
        ncovariates=cell2mat(ncovariates);
    end
end
ncovariates0=length(CONN_x.Setup.l1covariates.names);
ncovariates=setdiff(ncovariates,[0 ncovariates0]);
nconditions=numel(CONN_x.Setup.conditions.names)-1;
X=repmat({},CONN_x.Setup.nsubjects,numel(ncovariates));
ndims=nan(CONN_x.Setup.nsubjects,numel(ncovariates));
equaldims=true(CONN_x.Setup.nsubjects,numel(ncovariates));
measures={ 'average',   @(x,w,dim)sum(x.*w,dim)./max(eps,sum(w,dim));
           'sum',       @(x,w,dim)sum(x.*(w>0),dim);
           'std',       @(x,w,dim)sqrt(max(0,sum(x.^2.*w,dim)./max(eps,sum(w,dim))-(sum(x.*w,dim)./max(eps,sum(w,dim))).^2));
           'min',       @(x,w,dim)rem(min(x+(w<=0).*1e20,[],dim),1e20);
           'max',       @(x,w,dim)rem(max(x-(w<=0).*1e20,[],dim),1e20);
           'min(abs)',	@(x,w,dim)rem(min(abs(x)+(w<=0).*1e20,[],dim),1e20);
           'max(abs)',	@(x,w,dim)rem(max(abs(x)-(w<=0).*1e20,[],dim),1e20)};

thfig=dialog('units','norm','position',[.3,.4,.4,.3],'windowstyle','normal','name',['Aggregate 1st-level covariate ',sprintf('%s ',CONN_x.Setup.l1covariates.names{ncovariates})],'color','w','resize','on');
uicontrol(thfig,'style','text','units','norm','position',[.1,.82,.8,.08],'string','Measure:','horizontalalignment','left','backgroundcolor','w','fontsize',9+CONN_gui.font_offset,'fontweight','bold');
ht1=uicontrol(thfig,'style','popupmenu','units','norm','position',[.1,.74,.8,.08],'string',measures(:,1),'fontsize',8+CONN_gui.font_offset,'horizontalalignment','left','tooltipstring','Define how to aggregate first-level covariate across scans/sessions/dimensions');
uicontrol(thfig,'style','text','units','norm','position',[.1,.61,.8,.08],'string','Conditions:','horizontalalignment','left','backgroundcolor','w','fontsize',9+CONN_gui.font_offset,'fontweight','bold');
ht2=uicontrol(thfig,'style','listbox','units','norm','position',[.1,.25,.8,.36],'max',2,'string',CONN_x.Setup.conditions.names(1:end-1),'fontsize',8+CONN_gui.font_offset,'horizontalalignment','left','tooltipstring','Compute aggregated measures for each of the selected conditions');
uicontrol(thfig,'style','pushbutton','string','Ok','units','norm','position',[.1,.025,.38,.15],'callback','uiresume','fontsize',8+CONN_gui.font_offset,'tooltipstring','Compute aggregated measures and import them as new 2nd-level covariates');
uicontrol(thfig,'style','pushbutton','string','Cancel','units','norm','position',[.51,.025,.38,.15],'callback','delete(gcbf)','fontsize',8+CONN_gui.font_offset);
uiwait(thfig);
ok=ishandle(thfig);
if ok,
    newmeasure=get(ht1,'value');
    nconditions=get(ht2,'value');
    delete(thfig);
    f=measures{newmeasure,2};
    measurename=measures{newmeasure,1};

    Z=cell(numel(nconditions),numel(ncovariates));
    ht=conn_timedwaitbar(0,'Loading covariate/condition info. Please wait...');
    for nsub=1:CONN_x.Setup.nsubjects
        nsess=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub));
        Y=cell(numel(nconditions),numel(ncovariates));
        W=cell(numel(nconditions),numel(ncovariates));
        for nses=1:nsess
            filename=fullfile(filepath,['COND_Subject',num2str(nsub,'%03d'),'_Session',num2str(nses,'%03d'),'.mat']);
            if isempty(dir(filename)), disp(['Not ready. Please run Setup step first (minimally: conn_process setup_conditions)']); return; end
            load(filename,'samples','weights','names');
            if ~isequal(CONN_x.Setup.conditions.names(1:end-1),names), error(['Incorrect conditions in file ',filename1,'. Please re-run Setup step first (minimally: conn_process setup_conditions)']); end
            for icondition=1:numel(nconditions)
                for icovariate=1:numel(ncovariates)
                    nl1covariate=ncovariates(icovariate);
                    if ~isempty(CONN_x.Setup.l1covariates.files{nsub}{nl1covariate}{nses}{3})
                        w=weights{nconditions(icondition)}{1};
                        x=CONN_x.Setup.l1covariates.files{nsub}{nl1covariate}{nses}{3};
                        y=x(samples{nconditions(icondition)},:);
                        if size(y,2)>1, 
                            w=repmat(w,size(y,2),1);
                            y=y(:); 
                        end
                        Y{icondition,icovariate}=cat(1,Y{icondition,icovariate},y);
                        W{icondition,icovariate}=cat(1,W{icondition,icovariate},w);
                    end
                end
            end
        end
        for icondition=1:numel(nconditions)
            for icovariate=1:numel(ncovariates)
                temp=f(Y{icondition,icovariate},W{icondition,icovariate},1);
                if ~isempty(temp), Z{icondition,icovariate}(nsub)=temp; else  Z{icondition,icovariate}(nsub)=0; end
            end
        end
        conn_timedwaitbar(nsub/CONN_x.Setup.nsubjects,ht);
    end
    close(ht);
    names=cell(numel(nconditions),numel(ncovariates));
    for icondition=1:numel(nconditions)
        for icovariate=1:numel(ncovariates)
            names{icondition,icovariate}=sprintf('%s %s at %s',measurename,CONN_x.Setup.l1covariates.names{ncovariates(icovariate)},CONN_x.Setup.conditions.names{nconditions(icondition)});
        end
    end
    conn_importl2covariate(names(:),Z(:));
end

        
