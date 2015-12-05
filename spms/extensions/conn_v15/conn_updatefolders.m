function conn_x=conn_updatefolders(conn_x)

% backward compatibility check of CONN_x structure
if nargin<1,
    global CONN_x;
    if ~isfield(CONN_x,'opt'), CONN_x.opt=[]; end
    if ~isfield(CONN_x.opt,'fmt1'), CONN_x.opt.fmt1='%d'; end
    if ~isfield(CONN_x,'pobj'), CONN_x.pobj=conn_projectmanager('null'); end
    [path,name,ext]=fileparts(CONN_x.filename);if isempty(path),path=pwd;end
    if ~isfield(CONN_x,'folders'),CONN_x.folders=struct('rois',[],'data',[],'preprocessing',[],'firstlevel',[],'secondlevel',[]);end
    if CONN_x.pobj.holdsdata
        CONN_x.folders.rois=fullfile(fileparts(which(mfilename)),'rois');
        CONN_x.folders.data=fullfile(path,name,'data'); [ok,nill]=mkdir(path,name);[ok,nill]=mkdir(fullfile(path,name),'data');
        CONN_x.folders.preprocessing=fullfile(path,name,'results','preprocessing'); [ok,nill]=mkdir(path,name);[ok,nill]=mkdir(fullfile(path,name),'results'); [ok,nill]=mkdir(fullfile(path,name,'results'),'preprocessing');
        CONN_x.folders.firstlevel=fullfile(path,name,'results','firstlevel'); [ok,nill]=mkdir(path,name);[ok,nill]=mkdir(fullfile(path,name),'results'); [ok,nill]=mkdir(fullfile(path,name,'results'),'firstlevel');
        CONN_x.folders.secondlevel=fullfile(path,name,'results','secondlevel'); [ok,nill]=mkdir(path,name);[ok,nill]=mkdir(fullfile(path,name),'results'); [ok,nill]=mkdir(fullfile(path,name,'results'),'secondlevel');
    end
    if ~isfield(CONN_x.Setup,'steps'), CONN_x.Setup.steps=[1,1,0,0]; end 
    if numel(CONN_x.Setup.steps)~=4, CONN_x.Setup.steps=[CONN_x.Setup.steps(1:min(numel(CONN_x.Setup.steps),4)) zeros(1,max(0,4-numel(CONN_x.Setup.steps)))]; end
    if ~isfield(CONN_x.Setup,'spatialresolution'), CONN_x.Setup.spatialresolution=2; end    
    if ~isfield(CONN_x.Setup,'outputfiles'), CONN_x.Setup.outputfiles=[0,0,0,0,0,0]; end
    if numel(CONN_x.Setup.outputfiles)<6, CONN_x.Setup.outputfiles=[CONN_x.Setup.outputfiles,zeros(1,6-numel(CONN_x.Setup.outputfiles))]; end
    if ~isfield(CONN_x.Setup,'analysismask'), CONN_x.Setup.analysismask=1; end    
    if ~isfield(CONN_x.Setup,'analysisunits'), CONN_x.Setup.analysisunits=1; end    
    if ~isfield(CONN_x.Setup,'explicitmask'), CONN_x.Setup.explicitmask=fullfile(fileparts(which(mfilename)),'utils','surf','mask.volume.brainmask.nii'); end
    if ~isempty(CONN_x.Setup.explicitmask)&&ischar(CONN_x.Setup.explicitmask)
        try, CONN_x.Setup.explicitmask=conn_file(CONN_x.Setup.explicitmask);
        catch, CONN_x.Setup.explicitmask={CONN_x.Setup.explicitmask, [], []};
        end
    end
    if ~isfield(CONN_x.Setup,'roiextract'), CONN_x.Setup.roiextract=2; end
    if ~isfield(CONN_x.Setup,'roiextract_rule'), CONN_x.Setup.roiextract_rule={}; end
    if ~isfield(CONN_x.Setup,'roiextract_functional'), CONN_x.Setup.roiextract_functional={}; end
    if ~isfield(CONN_x.Setup,'unwarp_functional'), CONN_x.Setup.unwarp_functional={}; end
    if ~isfield(CONN_x.Setup,'cwthreshold'), CONN_x.Setup.cwthreshold=[.5 1]; end
    if ~isfield(CONN_x.Setup,'acquisitiontype'), 
        if isfield(CONN_x.Setup,'sparseacquisition'), CONN_x.Setup.acquisitiontype=1+(CONN_x.Setup.sparseacquisition>0);
        else CONN_x.Setup.acquisitiontype=1; end
    end    
    if ~isfield(CONN_x.Setup,'surfacesmoothing'), CONN_x.Setup.surfacesmoothing=50; end
    if ~isfield(CONN_x.Setup.conditions,'param'), CONN_x.Setup.conditions.param=zeros(1,numel(CONN_x.Setup.conditions.names)-1); end
    if ~isfield(CONN_x.Setup.conditions,'filter'), CONN_x.Setup.conditions.filter=cell(1,numel(CONN_x.Setup.conditions.names)-1); end
    if ~isfield(CONN_x.Setup.conditions,'allnames'),CONN_x.Setup.conditions.allnames=CONN_x.Setup.conditions.names(1:end-1); end
    if ~isfield(CONN_x.Setup.conditions,'missingdata'),CONN_x.Setup.conditions.missingdata=0; end
    if ~isfield(CONN_x.Setup.rois,'unsmoothedvolumes'), CONN_x.Setup.rois.unsmoothedvolumes=ones(1,numel(CONN_x.Setup.rois.dimensions)); end
    if ~isfield(CONN_x.Setup.rois,'sessionspecific'),
        CONN_x.Setup.rois.sessionspecific=zeros(1,numel(CONN_x.Setup.rois.names)-1);
        for nsub=1:CONN_x.Setup.nsubjects
            for nroi=1:numel(CONN_x.Setup.rois.names)-1
                CONN_x.Setup.rois.files{nsub}{nroi}=repmat({CONN_x.Setup.rois.files{nsub}{nroi}},[1,CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsub))]);
            end
        end
    end
    if ~isfield(CONN_x.Setup.rois,'subjectspecific'),
        CONN_x.Setup.rois.subjectspecific=zeros(1,numel(CONN_x.Setup.rois.names)-1);
        for nroi=1:numel(CONN_x.Setup.rois.names)-1
            temp=CONN_x.Setup.rois.files{1}{nroi}{1};
            for nsub=1:CONN_x.Setup.nsubjects
                for nses=1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsub))
                    if ~isequal(CONN_x.Setup.rois.files{nsub}{nroi}{nses},temp), CONN_x.Setup.rois.subjectspecific(nroi)=1; break; end
                end
            end
        end
    end
    if ~isfield(CONN_x.Setup,'structural_sessionspecific'),
        CONN_x.Setup.structural_sessionspecific=0;
        for nsub=1:CONN_x.Setup.nsubjects
            CONN_x.Setup.structural{nsub}=repmat({CONN_x.Setup.structural{nsub}},[1,CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsub))]);
        end
    end
    if ~isfield(CONN_x.Preproc,'regbp'), CONN_x.Preproc.regbp=1; end
    if ~isfield(CONN_x.Preproc,'despiking'), CONN_x.Preproc.despiking=0; end
    if ~isfield(CONN_x.Preproc,'detrending'), CONN_x.Preproc.detrending=0; end
    if ~isfield(CONN_x,'Analysis'), CONN_x.Analysis=1; end
    for ianalysis=1:numel(CONN_x.Analyses)
        if ~isfield(CONN_x.Analyses(ianalysis),'name'),CONN_x.Analyses(ianalysis).name=['ANALYSIS_',num2str(ianalysis,'%02d')]; end
        if ~isfield(CONN_x.Analyses(ianalysis),'sourcenames'),CONN_x.Analyses(ianalysis).sourcenames={}; end
        if ~isfield(CONN_x.Analyses(ianalysis),'modulation')||isempty(CONN_x.Analyses(ianalysis).modulation),CONN_x.Analyses(ianalysis).modulation=0; end
        if ~isfield(CONN_x.Analyses(ianalysis),'measure')||isempty(CONN_x.Analyses(ianalysis).measure),CONN_x.Analyses(ianalysis).measure=1; end
        if ~isfield(CONN_x.Analyses(ianalysis),'weight')||isempty(CONN_x.Analyses(ianalysis).weight),CONN_x.Analyses(ianalysis).weight=2; end
        if ~isfield(CONN_x.Analyses(ianalysis),'type')||isempty(CONN_x.Analyses(ianalysis).type),CONN_x.Analyses(ianalysis).type=3; end
        if ~isfield(CONN_x.Analyses(ianalysis),'conditions'),CONN_x.Analyses(ianalysis).conditions={''}; end
        if ~isempty(CONN_x.Analyses(ianalysis).variables)&&isstruct(CONN_x.Analyses(ianalysis).variables)&&~isfield(CONN_x.Analyses(ianalysis).variables,'fbands'), CONN_x.Analyses(ianalysis).variables.fbands=repmat({1},size(CONN_x.Analyses(ianalysis).variables.names)); end
        if ~isempty(CONN_x.Analyses(ianalysis).regressors)&&isstruct(CONN_x.Analyses(ianalysis).regressors)&&~isfield(CONN_x.Analyses(ianalysis).regressors,'fbands'), CONN_x.Analyses(ianalysis).regressors.fbands=repmat({1},size(CONN_x.Analyses(ianalysis).regressors.names)); end
    end    
    if ~isfield(CONN_x,'vvAnalyses'), CONN_x.vvAnalyses=struct('measurenames',{{}},'variables', struct('names',{{}},'localsupport',{{}},'deriv',{{}},'exponent',{{}},'norm',{{}},'dimensions_in',{{}},'dimensions_out',{{}}),'regressors', struct('names',{{}},'localsupport',{{}},'deriv',{{}},'exponent',{{}},'norm',{{}},'dimensions_in',{{}},'dimensions_out',{{}})); end
    if isfield(CONN_x.vvAnalyses,'variables')&&~isfield(CONN_x.vvAnalyses.variables,'norm'), CONN_x.vvAnalyses.variables.norm=repmat({1},1,numel(CONN_x.vvAnalyses.variables.names)); end
    if isfield(CONN_x.vvAnalyses,'regressors')&&~isfield(CONN_x.vvAnalyses.regressors,'norm'), CONN_x.vvAnalyses.regressors.norm=repmat({1},1,numel(CONN_x.vvAnalyses.regressors.names)); end
    if ~isfield(CONN_x,'dynAnalyses'), CONN_x.dynAnalyses=struct('regressors', struct('names',{{}}),'variables', struct('names',{{}}),'Ncomponents',[4],'condition',[1],'filter',[],'output',[1 1 0]); end
    if ~isfield(CONN_x.dynAnalyses,'condition')||isempty(CONN_x.dynAnalyses.condition), CONN_x.dynAnalyses.condition=1; end
    if ~isfield(CONN_x,'Results')||~isfield(CONN_x.Results,'saved')||isempty(CONN_x.Results.saved), CONN_x.Results.saved=struct('names',{{}},'labels',{{}},'nsubjecteffects',{{}},'csubjecteffects',{{}},'nconditions',{{}},'cconditions',{{}}); end
    if ~isfield(CONN_x.Results.saved,'names'), CONN_x.Results.saved.names={}; end
    if ~isfield(CONN_x.Results.saved,'labels'), CONN_x.Results.saved.labels={}; end
    if ~isfield(CONN_x.Results.saved,'nsubjecteffects'), CONN_x.Results.saved.nsubjecteffects={}; end
    if ~isfield(CONN_x.Results.saved,'csubjecteffects'), CONN_x.Results.saved.csubjecteffects={}; end
    if ~isfield(CONN_x.Results.saved,'nconditions'), CONN_x.Results.saved.nconditions={}; end
    if ~isfield(CONN_x.Results.saved,'cconditions'), CONN_x.Results.saved.cconditions={}; end
    for ianalysis=1:length(CONN_x.Analyses), 
        if ~exist(fullfile(CONN_x.folders.firstlevel,CONN_x.Analyses(ianalysis).name),'dir'), [ok,nill]=mkdir(CONN_x.folders.firstlevel,CONN_x.Analyses(ianalysis).name); end; 
        filesourcenames=fullfile(CONN_x.folders.firstlevel,CONN_x.Analyses(ianalysis).name,'_list_sources.mat');
        filesourcenames=conn_projectmanager('projectfile',filesourcenames,CONN_x.pobj,'.mat');
        if ~isempty(dir(filesourcenames)),
            load(filesourcenames,'sourcenames');
            if numel(sourcenames)>=numel(CONN_x.Analyses(ianalysis).sourcenames), %~isempty(sourcenames)
                if ~isequal(CONN_x.Analyses(ianalysis).sourcenames,sourcenames), fprintf('warning: mismatch list_sources info. Using automatic recovery from %s\n',filesourcenames); end
                CONN_x.Analyses(ianalysis).sourcenames=sourcenames;
            end
        end
    end
    filemeasurenames=fullfile(CONN_x.folders.firstlevel,'_list_measures.mat');
    filemeasurenames=conn_projectmanager('projectfile',filemeasurenames,CONN_x.pobj,'.mat');
    if ~isempty(dir(filemeasurenames)),
        load(filemeasurenames,'measurenames');
        if numel(measurenames)>=numel(CONN_x.vvAnalyses.measurenames), %~isempty(measurenames)
            if ~isequal(CONN_x.vvAnalyses.measurenames,measurenames), fprintf('warning: mismatch list_measures info. Using automatic recovery from %s\n',filemeasurenames); end
            CONN_x.vvAnalyses.measurenames=measurenames;
        end
    end
    fileconditionnames=fullfile(CONN_x.folders.preprocessing,'_list_conditions.mat');
    fileconditionnames=conn_projectmanager('projectfile',fileconditionnames,CONN_x.pobj,'.mat');
    if ~isempty(dir(fileconditionnames)),
        load(fileconditionnames,'allnames');
        if numel(allnames)>=numel(CONN_x.Setup.conditions.allnames), %~isempty(allnames)
            if ~isequal(CONN_x.Setup.conditions.allnames,allnames), fprintf('warning: mismatch list_conditions info. Using automatic recovery from %s\n',fileconditionnames); end
            CONN_x.Setup.conditions.allnames=allnames;
        end
    end
    fileresultsnames=fullfile(CONN_x.folders.secondlevel,'_list_results.mat');
    if ~isempty(dir(fileresultsnames)),
        load(fileresultsnames,'results');
        if ~isequal(CONN_x.Results.saved,results), fprintf('warning: mismatch list_results info. Using automatic recovery from %s\n',fileresultsnames); end
        if ~isempty(results)
            CONN_x.Results.saved=results;
        end
    end

else
    if ~isfield(conn_x,'opt'), conn_x.opt=[]; end
    if ~isfield(conn_x.opt,'fmt1'), conn_x.opt.fmt1='%d'; end
    if ~isfield(conn_x,'pobj'), conn_x.pobj=conn_projectmanager('null'); end
    [path,name,ext]=fileparts(conn_x.filename);if isempty(path),path=pwd;end
    if ~isfield(conn_x,'folders'),conn_x.folders=struct('rois',[],'data',[],'preprocessing',[],'firstlevel',[],'secondlevel',[]);end
    if conn_x.pobj.holdsdata
        conn_x.folders.rois=fullfile(fileparts(which(mfilename)),'rois');
        conn_x.folders.data=fullfile(path,name,'data'); [ok,nill]=mkdir(path,name);[ok,nill]=mkdir(fullfile(path,name),'data');
        conn_x.folders.preprocessing=fullfile(path,name,'results','preprocessing'); [ok,nill]=mkdir(path,name);[ok,nill]=mkdir(fullfile(path,name),'results'); [ok,nill]=mkdir(fullfile(path,name,'results'),'preprocessing');
        conn_x.folders.firstlevel=fullfile(path,name,'results','firstlevel'); [ok,nill]=mkdir(path,name);[ok,nill]=mkdir(fullfile(path,name),'results'); [ok,nill]=mkdir(fullfile(path,name,'results'),'firstlevel');
        conn_x.folders.secondlevel=fullfile(path,name,'results','secondlevel'); [ok,nill]=mkdir(path,name);[ok,nill]=mkdir(fullfile(path,name),'results'); [ok,nill]=mkdir(fullfile(path,name,'results'),'secondlevel');
    end
    if ~isfield(conn_x.Setup,'steps'), conn_x.Setup.steps=[1,1,0,0]; end
    if numel(conn_x.Setup.steps)~=4, conn_x.Setup.steps=[conn_x.Setup.steps(1:min(numel(conn_x.Setup.steps),4)) zeros(1,max(0,4-numel(conn_x.Setup.steps)))]; end
    if ~isfield(conn_x.Setup,'spatialresolution'), conn_x.Setup.spatialresolution=2; end
    if ~isfield(conn_x.Setup,'outputfiles'), conn_x.Setup.outputfiles=[0,0,0,0,0,0]; end
    if numel(conn_x.Setup.outputfiles)<6, conn_x.Setup.outputfiles=[conn_x.Setup.outputfiles,zeros(1,6-numel(conn_x.Setup.outputfiles))]; end
    if ~isfield(conn_x.Setup,'analysismask'), conn_x.Setup.analysismask=1; end    
    if ~isfield(conn_x.Setup,'analysisunits'), conn_x.Setup.analysisunits=1; end    
    if ~isfield(conn_x.Setup,'explicitmask'), conn_x.Setup.explicitmask=fullfile(fileparts(which(mfilename)),'utils','surf','mask.volume.brainmask.nii'); end
    if ~isempty(conn_x.Setup.explicitmask)&&ischar(conn_x.Setup.explicitmask)
        try, conn_x.Setup.explicitmask=conn_file(conn_x.Setup.explicitmask);
        catch, conn_x.Setup.explicitmask={conn_x.Setup.explicitmask, [], []};
        end
    end
    if ~isfield(conn_x.Setup,'roiextract'), conn_x.Setup.roiextract=2; end
    if ~isfield(conn_x.Setup,'roiextract_rule'), conn_x.Setup.roiextract_rule={}; end
    if ~isfield(conn_x.Setup,'roiextract_functional'), conn_x.Setup.roiextract_functional={}; end
    if ~isfield(conn_x.Setup,'unwarp_functional'), conn_x.Setup.unwarp_functional={}; end
    if ~isfield(conn_x.Setup,'cwthreshold'), conn_x.Setup.cwthreshold=[.5 1]; end
    if ~isfield(conn_x.Setup,'acquisitiontype'), 
        if isfield(conn_x.Setup,'sparseacquisition'), conn_x.Setup.acquisitiontype=1+(conn_x.Setup.sparseacquisition>0);
        else conn_x.Setup.acquisitiontype=1; end
    end    
    if ~isfield(conn_x.Setup,'surfacesmoothing'), conn_x.Setup.surfacesmoothing=50; end
    if ~isfield(conn_x.Setup.conditions,'param'), conn_x.Setup.conditions.param=zeros(1,numel(conn_x.Setup.conditions.names)-1); end
    if ~isfield(conn_x.Setup.conditions,'filter'), conn_x.Setup.conditions.filter=cell(1,numel(conn_x.Setup.conditions.names)-1); end
    if ~isfield(conn_x.Setup.conditions,'allnames'),conn_x.Setup.conditions.allnames=conn_x.Setup.conditions.names(1:end-1); end
    if ~isfield(conn_x.Setup.conditions,'missingdata'),conn_x.Setup.conditions.missingdata=0; end
    if ~isfield(conn_x.Setup.rois,'unsmoothedvolumes'), conn_x.Setup.rois.unsmoothedvolumes=ones(1,numel(conn_x.Setup.rois.dimensions)); end
    if ~isfield(conn_x.Setup.rois,'sessionspecific'),
        conn_x.Setup.rois.sessionspecific=zeros(1,numel(conn_x.Setup.rois.names)-1);
        for nsub=1:conn_x.Setup.nsubjects
            for nroi=1:numel(conn_x.Setup.rois.names)-1
                conn_x.Setup.rois.files{nsub}{nroi}=repmat({conn_x.Setup.rois.files{nsub}{nroi}},[1,conn_x.Setup.nsessions(min(numel(conn_x.Setup.nsessions),nsub))]);
            end
        end
    end
    if ~isfield(conn_x.Setup.rois,'subjectspecific'),
        conn_x.Setup.rois.subjectspecific=zeros(1,numel(conn_x.Setup.rois.names)-1);
        for nroi=1:numel(conn_x.Setup.rois.names)-1
            temp=conn_x.Setup.rois.files{1}{nroi}{1};
            for nsub=1:conn_x.Setup.nsubjects
                for nses=1:conn_x.Setup.nsessions(min(numel(conn_x.Setup.nsessions),nsub))
                    if ~isequal(conn_x.Setup.rois.files{nsub}{nroi}{nses},temp), conn_x.Setup.rois.subjectspecific(nroi)=1; break; end
                end
            end
        end
    end
    if ~isfield(conn_x.Setup,'structural_sessionspecific'),
        conn_x.Setup.structural_sessionspecific=0;
        for nsub=1:conn_x.Setup.nsubjects
            conn_x.Setup.structural{nsub}=repmat({conn_x.Setup.structural{nsub}},[1,conn_x.Setup.nsessions(min(numel(conn_x.Setup.nsessions),nsub))]);
        end
    end
    if ~isfield(conn_x.Preproc,'regbp'), conn_x.Preproc.regbp=1; end
    if ~isfield(conn_x.Preproc,'despiking'), conn_x.Preproc.despiking=0; end
    if ~isfield(conn_x.Preproc,'detrending'), conn_x.Preproc.detrending=0; end
    if ~isfield(conn_x,'Analysis'), conn_x.Analysis=1; end
    for ianalysis=1:numel(conn_x.Analyses)
        if ~isfield(conn_x.Analyses(ianalysis),'name'),conn_x.Analyses(ianalysis).name=['ANALYSIS_',num2str(ianalysis,'%02d')]; end
        if ~isfield(conn_x.Analyses(ianalysis),'sourcenames'),conn_x.Analyses(ianalysis).sourcenames={}; end
        if ~isfield(conn_x.Analyses(ianalysis),'modulation')||isempty(conn_x.Analyses(ianalysis).modulation),conn_x.Analyses(ianalysis).modulation=0; end
        if ~isfield(conn_x.Analyses(ianalysis),'measure'),conn_x.Analyses(ianalysis).measure=1; end
        if ~isfield(conn_x.Analyses(ianalysis),'weight'),conn_x.Analyses(ianalysis).weight=2; end
        if ~isfield(conn_x.Analyses(ianalysis),'type'),conn_x.Analyses(ianalysis).type=3; end
        if ~isfield(conn_x.Analyses(ianalysis),'conditions'),conn_x.Analyses(ianalysis).conditions={''}; end
        if ~isempty(conn_x.Analyses(ianalysis).variables)&&isstruct(conn_x.Analyses(ianalysis).variables)&&~isfield(conn_x.Analyses(ianalysis).variables,'fbands'), conn_x.Analyses(ianalysis).variables.fbands=repmat({1},size(conn_x.Analyses(ianalysis).variables.names)); end
        if ~isempty(conn_x.Analyses(ianalysis).regressors)&&isstruct(conn_x.Analyses(ianalysis).regressors)&&~isfield(conn_x.Analyses(ianalysis).regressors,'fbands'), conn_x.Analyses(ianalysis).regressors.fbands=repmat({1},size(conn_x.Analyses(ianalysis).regressors.names)); end
    end    
    if ~isfield(conn_x,'vvAnalyses'), conn_x.vvAnalyses=struct('measurenames',{{}},'variables', struct('names',{{}},'localsupport',{{}},'deriv',{{}},'exponent',{{}},'norm',{{}},'dimensions_in',{{}},'dimensions_out',{{}}),'regressors', struct('names',{{}},'localsupport',{{}},'deriv',{{}},'exponent',{{}},'norm',{{}},'dimensions_in',{{}},'dimensions_out',{{}})); end
    if isfield(conn_x.vvAnalyses,'variables')&&~isfield(conn_x.vvAnalyses.variables,'norm'), conn_x.vvAnalyses.variables.norm=repmat({1},1,numel(conn_x.vvAnalyses.variables.names)); end
    if isfield(conn_x.vvAnalyses,'regressors')&&~isfield(conn_x.vvAnalyses.regressors,'norm'), conn_x.vvAnalyses.regressors.norm=repmat({1},1,numel(conn_x.vvAnalyses.regressors.names)); end
    if ~isfield(conn_x,'dynAnalyses'), conn_x.dynAnalyses=struct('regressors', struct('names',{{}}),'variables', struct('names',{{}}),'Ncomponents',[4],'condition',[1],'filter',[],'output',[1 1 0]); end
    if ~isfield(conn_x.dynAnalyses,'condition')||isempty(conn_x.dynAnalyses.condition), conn_x.dynAnalyses.condition=1; end
    if ~isfield(conn_x,'Results')||~isfield(conn_x.Results,'saved')||isempty(conn_x.Results.saved), conn_x.Results.saved=struct('names',{{}},'labels',{{}},'nsubjecteffects',{{}},'csubjecteffects',{{}},'nconditions',{{}},'cconditions',{{}}); end
    if ~isfield(conn_x.Results.saved,'names'), conn_x.Results.saved.names={}; end
    if ~isfield(conn_x.Results.saved,'labels'), conn_x.Results.saved.labels={}; end
    if ~isfield(conn_x.Results.saved,'nsubjecteffects'), conn_x.Results.saved.nsubjecteffects={}; end
    if ~isfield(conn_x.Results.saved,'csubjecteffects'), conn_x.Results.saved.csubjecteffects={}; end
    if ~isfield(conn_x.Results.saved,'nconditions'), conn_x.Results.saved.nconditions={}; end
    if ~isfield(conn_x.Results.saved,'cconditions'), conn_x.Results.saved.cconditions={}; end
    for ianalysis=1:length(conn_x.Analyses), 
        if ~exist(fullfile(conn_x.folders.firstlevel,conn_x.Analyses(ianalysis).name),'dir'), [ok,nill]=mkdir(conn_x.folders.firstlevel,conn_x.Analyses(ianalysis).name); end; 
        filesourcenames=fullfile(conn_x.folders.firstlevel,conn_x.Analyses(ianalysis).name,'_list_sources.mat');
        filesourcenames=conn_projectmanager('projectfile',filesourcenames,conn_x.pobj,'.mat');
        if ~isempty(dir(filesourcenames)),
            load(filesourcenames,'sourcenames');
            if numel(sourcenames)>=numel(conn_x.Analyses(ianalysis).sourcenames), %~isempty(sourcenames)
                if ~isequal(conn_x.Analyses(ianalysis).sourcenames,sourcenames), fprintf('warning: mismatch list_sources info. Using automatic recovery from %s\n',filesourcenames); end
                conn_x.Analyses(ianalysis).sourcenames=sourcenames;
            end
        end
    end
    filemeasurenames=fullfile(conn_x.folders.firstlevel,'_list_measures.mat');
    filemeasurenames=conn_projectmanager('projectfile',filemeasurenames,conn_x.pobj,'.mat');
    if ~isempty(dir(filemeasurenames)),
        load(filemeasurenames,'measurenames');
        if numel(measurenames)>=numel(conn_x.vvAnalyses.measurenames), %~isempty(measurenames)
            if ~isequal(conn_x.vvAnalyses.measurenames,measurenames), fprintf('warning: mismatch list_measures info. Using automatic recovery from %s\n',filemeasurenames); end
            conn_x.vvAnalyses.measurenames=measurenames;
        end
    end
    fileconditionnames=fullfile(conn_x.folders.preprocessing,'_list_conditions.mat');
    fileconditionnames=conn_projectmanager('projectfile',fileconditionnames,conn_x.pobj,'.mat');
    if ~isempty(dir(fileconditionnames)),
        load(fileconditionnames,'allnames');
        if numel(allnames)>=numel(conn_x.Setup.conditions.allnames), %~isempty(allnames)
            if ~isequal(conn_x.Setup.conditions.allnames,allnames), fprintf('warning: mismatch list_conditions info. Using automatic recovery from %s\n',fileconditionnames); end
            conn_x.Setup.conditions.allnames=allnames;
        end
    end
    fileresultsnames=fullfile(conn_x.folders.secondlevel,'_list_results.mat');
    if ~isempty(dir(fileresultsnames)),
        load(fileresultsnames,'results');
        if ~isequal(conn_x.Results.saved,results), fprintf('warning: mismatch list_results info. Using automatic recovery from %s\n',fileresultsnames); end
        if ~isempty(results)
            conn_x.Results.saved=results;
        end
    end
end
