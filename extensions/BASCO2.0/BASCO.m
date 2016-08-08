function varargout = BASCO(varargin)
% BetA-Series COrrelation
% 1) ROI-based whole brain network analysis (ROI-ROI correlation)
% 2) seed based functional connectivity, i.e. ROI-voxel correlation (Rissmann)
% 3) voxel degree centrality maps

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @BASCO_OpeningFcn, ...
    'gui_OutputFcn',  @BASCO_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end
if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

function BASCO_OpeningFcn(hObject, ~, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);
spm('Defaults','fmri')
marsbar('on');
set(0, 'defaultTextInterpreter', 'none');

function varargout = BASCO_OutputFcn(hObject, ~, handles)
varargout{1}     = handles.output;
handles.NumJobs  = 0; % number of subjects
handles.maskfile = '';
handles.InfoText = '';
str='<HELP> : Load file containing analysis data or start => Model specification and estimation <= to load an analysis configuration file.';
handles.InfoText = WriteInfoBox(handles,str,false);
list1{1}='paired t-test';
list1{2}='two-sample t-test';
list1{3}='flexible factorial 2x2';
set(handles.popupmenulevel2,'String',list1);
list2{1}='Tools';
list2{2}='ROI mean beta-values (over trials and subjects)';
list2{3}='Estimate model for single ROI (one subject)';
list2{4}='Estimate model for single ROI (all subjects)';
list2{5}='Rename ROIs';
list2{6}='Reslice image';
list2{7}='Select subject(s)';
list2{8}='Assign number labelled ROI-file.';
list2{9}='Smooth maps';
list2{10}='Mean maps';
list2{11}='Check maps';
set(handles.popupmenumore,'String',list2);

list4{1}  = 'Network analysis';
list4{2}  = 'Network edges';
list4{3}  = 'Graph properties';
set(handles.popupmenu_nwana,'String',list4);

list3{1}='Product-moment correlation';
list3{2}='Spearman correlation coefficients';
list3{3}='arc-hyperbolic tangent transf.';
list3{4}='Pearson (outlier rejection)';
set(handles.popupmenucorrelation,'String',list3);
guidata(hObject, handles);

% info-box
function infobox_Callback(~, ~, ~)
function infobox_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function newstr = WriteInfoBox(handles,str,append)
disp(str);
oldstr = handles.InfoText;
if append==true
    newstr = sprintf('%s \n%s',str,oldstr);
else
    newstr = sprintf('%s',str);
end
set(handles.infobox,'String',newstr);
drawnow;

function pushbuttonopen_Callback(hObject, ~, handles)
% load analysis object from file
[file,path]=uigetfile('*.mat','MultiSelect','off');
str=sprintf('Reading file %s.',fullfile(path,file));
handles.InfoText = WriteInfoBox(handles,str,true);
load(fullfile(path,file));
handles.anaobj = anaobj;
handles.NumJobs = size(anaobj,2);
str=sprintf('<INFO> : Analysis object read from file: \n %s.',fullfile(path,file));
handles.InfoText = WriteInfoBox(handles,str,true);
handles.InfoText = WriteInfoBox(handles,sprintf('Number of subjects: %d',handles.NumJobs),true);
guidata(hObject, handles);

function pushbuttonsave_Callback(~, ~, handles)
% save analysis object to file
anaobj         = handles.anaobj;
[name, folder] = uiputfile('*','Select folder and enter file name.');
save(fullfile(folder,strcat(name,'.mat')),'anaobj'); % fix me!

function pushbuttonhelp_Callback(~, ~, ~)
web('http://www.nitrc.org/projects/basco');

function pushbuttoninfo_Callback(hObject, ~, handles)
if handles.NumJobs==0
    str='<INFO> : No analysis. Load analysis object or create new analysis with => Model specification and estimation <=.';
    handles.InfoText = WriteInfoBox(handles,str,true);
    return;
end
str=sprintf('Number of subjects: %d',handles.NumJobs);
handles.InfoText = WriteInfoBox(handles,str,true);
disp(handles.anaobj{1});
disp(handles.anaobj{1}.Ana{1});
guidata(hObject, handles);

function pushbuttonclose_Callback(~, ~, ~)
close all;

function popupmenucorrelation_Callback(hObject, ~, handles)
sel = get(hObject,'Value');
NumSubj = handles.NumJobs;
% correlation coefficients from 'corrcoef'
if sel==1
    for isubj=1:NumSubj
        BS = handles.anaobj{isubj}.Ana{1}.BetaSeries;
        [NWM, pNWM] = corrcoef(BS);
        NWM = NWM-eye(size(NWM,1));
        handles.anaobj{isubj}.Ana{1}.Matrix  = NWM;
        handles.anaobj{isubj}.Ana{1}.MatrixP = pNWM;
    end
    str='Calculated correlation coefficients from beta-series.';
    handles.InfoText = WriteInfoBox(handles,str,true);
end
% Spearman correlation coefficients
if sel==2
    handles.InfoText = WriteInfoBox(handles,'Calculating Spearman correlation coefficients from beta-series. Please wait.',true);
    for isubj=1:NumSubj
        BS          = handles.anaobj{isubj}.Ana{1}.BetaSeries;
        [NWM, pNWM] = corr(BS,'type','Spearman');
        NWM         = NWM-eye(size(NWM,1));
        handles.anaobj{isubj}.Ana{1}.Matrix  = NWM;
        handles.anaobj{isubj}.Ana{1}.MatrixP = pNWM;
    end
    handles.InfoText = WriteInfoBox(handles,'Calculated Spearman correlation coefficients from beta-series.',true);
end
% arc-hyperbolic tangent transformation
if sel==3
    for isubj=1:NumSubj
        handles.anaobj{isubj}.Ana{1}.Matrix = atanh(handles.anaobj{isubj}.Ana{1}.Matrix);
    end
    handles.InfoText = WriteInfoBox(handles,'Correlation matrices arc-hyperbolic tangent transformed.',true);
end
% outlier rejection
if sel==4
    zthr = 4.0; % z-thresjhold for outlier rejection
    for isubj=1:NumSubj
        bs     = handles.anaobj{isubj}.Ana{1}.BetaSeries; % (trials,rois)
        NWMpre = corrcoef(bs);
        NWMpre = NWMpre-eye(size(NWMpre,1));
        ztrbs  = (bs-repmat(mean(bs),size(bs,1),1))./repmat(std(bs),size(bs,1),1);
        ztrmax = abs(min(ztrbs'));
        inidx  = find(ztrmax<zthr);
        fprintf('Subject %d ===> rejected outlier (%.2f) : %d (%d) \n',isubj,zthr,size(bs,1)-length(inidx),size(bs,1));
        [NWM, pNWM] = corrcoef(bs(inidx,:));
        NWM         = NWM-eye(size(NWM,1));
        handles.anaobj{isubj}.Ana{1}.Matrix  = atanh(NWM);
        handles.anaobj{isubj}.Ana{1}.MatrixP = pNWM;
    end
    str='Calculated correlation coefficients from beta-series (outlier rejection; Fisher-z transformed).';
    handles.InfoText = WriteInfoBox(handles,str,true);
end
guidata(hObject, handles);

function popupmenucorrelation_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%              Model specification and estimation                     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function pushbuttonmodelspecest_Callback(hObject, ~, handles)

str = sprintf('Running model specification and estimation ...');
handles.InfoText = WriteInfoBox(handles,str,true);

% load configuration file
[file,path] = uigetfile('*.m','MultiSelect','off');
str=sprintf('Loading file %s.',fullfile(path,file));
handles.InfoText = WriteInfoBox(handles,str,true);
run(fullfile(path,file));

NumSubj = AnaDef.NumSubjects;
handles.InfoText = WriteInfoBox(handles,sprintf('Number of subjects: %d',NumSubj),true);
ImgType = AnaDef.Img;
Img4D   = AnaDef.Img4D;

if AnaDef.ROIAnalysis==true % retrieve ROIs
    if strcmp(AnaDef.ROIDir,'')==true
        AnaDef.ROIDir = uigetdir(BaseDirectory);
    end
    ROIFile  = cellstr(spm_select('FPList',AnaDef.ROIDir,['^' AnaDef.ROIPrefix '.*.mat']));
    ROINum   = size(ROIFile,1);
    if ROINum==0
        handles.InfoText = WriteInfoBox(handles,'ROIs not found.',true);
        guidata(hObject, handles);
        return;
    end
    try
        fid = fopen(fullfile(AnaDef.ROINames));
    catch
        handles.InfoText = WriteInfoBox(handles,'File containing ROI names not found.',true);
        guidata(hObject, handles);
        return;
    end
    scnames = textscan(fid,'%s');
    thenames = char(scnames{1});
    if length(thenames)~=ROINum
        handles.InfoText = WriteInfoBox(handles,'Check number of ROIs in txt-file.',true);
        guidata(hObject, handles);
        return;
    end
end
handles.InfoText = WriteInfoBox(handles,sprintf('Output directory: %s',AnaDef.OutDir),true);
fprintf('Units for SPM design: %s \n',AnaDef.units);

for isubj=1:NumSubj % loop over subjects  %%%%%%%%%%%%%%%%%%%%%
    % store information analysis-object
    handles.anaobj{isubj}.Ana{1}.AnaDef                    = AnaDef.Subj{isubj};
    handles.anaobj{isubj}.Ana{1}.AnaDef.OutDir             = AnaDef.OutDir;
    handles.anaobj{isubj}.Ana{1}.AnaDef.Prefix             = AnaDef.Prefix;
    handles.anaobj{isubj}.Ana{1}.AnaDef.Cond               = AnaDef.Cond;
    handles.anaobj{isubj}.Ana{1}.AnaDef.NumCond            = AnaDef.NumCond;
    handles.anaobj{isubj}.Ana{1}.AnaDef.RT                 = AnaDef.RT;
    handles.anaobj{isubj}.Ana{1}.AnaDef.fmri_t             = AnaDef.fmri_t;
    handles.anaobj{isubj}.Ana{1}.AnaDef.fmri_t0            = AnaDef.fmri_t0;
    handles.anaobj{isubj}.Ana{1}.AnaDef.OnsetModifier      = AnaDef.OnsetModifier;
    handles.anaobj{isubj}.Ana{1}.AnaDef.units              = AnaDef.units;
    handles.anaobj{isubj}.Ana{1}.AnaDef.HRFDERIVS          = AnaDef.HRFDERIVS;
    handles.anaobj{isubj}.Ana{1}.AnaDef.ROIAnalysis        = AnaDef.ROIAnalysis;        % ROI or voxel level model estimation
    handles.anaobj{isubj}.Ana{1}.AnaDef.ROIDir             = AnaDef.ROIDir;
    handles.anaobj{isubj}.Ana{1}.AnaDef.ROISummaryFunction = AnaDef.ROISummaryFunction; % 'mean' or 'median'
    handles.anaobj{isubj}.AnaCurrent                       = 1;
    handles.anaobj{isubj}.Ana{1}.AnaDef.NumRissman         = 0;
    %
    str=sprintf('====>> Processing subject %d <<====',isubj);
    handles.InfoText = WriteInfoBox(handles,str,true);
    data_path  = AnaDef.Subj{isubj}.DataPath; % path to data
    outdirname = AnaDef.OutDir;
    clear('matlabbatch');
    % model specification
    matlabbatch{1}.spm.util.md.basedir = cellstr(data_path);
    matlabbatch{1}.spm.util.md.name    = outdirname;
    matlabbatch{2}.spm.stats.fmri_spec.dir            = cellstr(fullfile(data_path,outdirname));
    matlabbatch{2}.spm.stats.fmri_spec.timing.units   = AnaDef.units;
    matlabbatch{2}.spm.stats.fmri_spec.timing.RT      = AnaDef.RT;
    matlabbatch{2}.spm.stats.fmri_spec.timing.fmri_t  = AnaDef.fmri_t;
    matlabbatch{2}.spm.stats.fmri_spec.timing.fmri_t0 = AnaDef.fmri_t0;
    NumRuns    = AnaDef.Subj{isubj}.NumRuns;
    regcounter = 0;
    
    for irun=1:NumRuns % loop over runs
        % run directory
        rundir     = fullfile(data_path,AnaDef.Subj{isubj}.RunDirs{irun});
        fprintf('Directory run %d: %s \n',irun,rundir);
        % read run specific onsets
        onsetfile  = fullfile(rundir,AnaDef.Subj{isubj}.Onsets{irun});
        fprintf('Onsets: %s \n',onsetfile);
        onsets     = dlmread(onsetfile); % read onsets
        handles.anaobj{isubj}.Ana{1}.AnaDef.OnsetsMat{irun} = onsets;
        % onsets
        onsets = onsets-AnaDef.OnsetModifier; % modify onsets (scans omitted)
        %
        % model specification
        %
        disp('Functional data:');
        if Img4D
            file4D = dir(fullfile(rundir,[AnaDef.Prefix '*.' AnaDef.Img]));
            files  = spm_select('ExtFPList',rundir, file4D.name ,Inf);
        else
            files  = spm_select('FPList',rundir, ['^' AnaDef.Prefix '*.*\.' AnaDef.Img ]);
        end
        if isempty(files)
            handles.InfoText = WriteInfoBox(handles,'Functional data not found. Check path and file name.',true);
            return;
        end
        disp(files(1,:));
        matlabbatch{2}.spm.stats.fmri_spec.sess(irun).scans = cellstr(files);
        counter  = 0;
        for icond=1:AnaDef.NumCond % loop over conditions
            NumOnsets = nnz(onsets(icond,2:end))+1;
            fprintf('Condition %d: %d trials \n',icond,NumOnsets);
            for ionsets=1:1:NumOnsets % loop over individual trials of given condition
                trialonset = onsets(icond,ionsets);
                if isnan(trialonset) || trialonset<0
                    disp('Onset NaN or <0! Bailing out ...');
                    return;
                end
                counter=counter+1;
                matlabbatch{2}.spm.stats.fmri_spec.sess(irun).cond(counter).name     = sprintf('%s%d',AnaDef.Cond{icond},ionsets);
                matlabbatch{2}.spm.stats.fmri_spec.sess(irun).cond(counter).onset    = trialonset;
                matlabbatch{2}.spm.stats.fmri_spec.sess(irun).cond(counter).duration = AnaDef.Subj{isubj}.Duration(icond);
                matlabbatch{2}.spm.stats.fmri_spec.sess(irun).cond(counter).tmod     = 0;
                matlabbatch{2}.spm.stats.fmri_spec.sess(irun).cond(counter).pmod     = struct('name', {}, 'param', {}, 'poly', {});
                % store information on regressors and the corresponding condition
                regcounter=regcounter+1;
                handles.anaobj{isubj}.Ana{1}.AnaDef.RegCond.Run{irun}.Cond{icond}(ionsets) = regcounter;
                if AnaDef.HRFDERIVS(1)==1 && AnaDef.HRFDERIVS(2)==0
                    regcounter=regcounter+1;
                end
            end % end loop over onsets
        end % end loop over conditions
        
        %
        % motion regressors
        %
        listmot   = spm_select('FPList',fullfile(data_path,AnaDef.Subj{isubj}.RunDirs{irun}), ['^rp_*.*\.txt']);
        sclistmot = strtrim(listmot(1,:));
        handles.anaobj{isubj}.RealignmentParameters{irun} = dlmread(sclistmot); % store motion regressors
        disp('Realignment parameters:');
        disp(sclistmot);
        fprintf('%d x %d\n',size(handles.anaobj{isubj}.RealignmentParameters{irun}));
        %
        % add global mean as regressor
        %
        % brain mask
        maskpath    = fileparts(mfilename('fullpath'));
        maskpath    = fullfile(maskpath,'masks');
        roipath     = maskpath;
        brainmask   = 'brainmask_roi.mat';
        roifiles    = [ '' ];
        roifiles{1} = brainmask;
        % retrieve time course
        handles.InfoText = WriteInfoBox(handles,sprintf('Retrieving global time course for run %d ...',irun),true);
        TC{irun} = GetRawTimeCourses(files,roipath,roifiles);
        handles.anaobj{isubj}.GlobalMean{irun} = TC{irun}; % store global mean time course for each run
        filereg = sprintf('%s.globalmean.dat',sclistmot);
        dlmwrite(filereg,[handles.anaobj{isubj}.RealignmentParameters{irun} TC{irun}]);
        
        matlabbatch{2}.spm.stats.fmri_spec.sess(irun).multi = {''};
        matlabbatch{2}.spm.stats.fmri_spec.sess(irun).regress = struct('name', {}, 'val', {});
        
        if AnaDef.GlobalMeanReg==true && AnaDef.MotionReg==true
            matlabbatch{2}.spm.stats.fmri_spec.sess(irun).multi_reg = cellstr(filereg);
            regcounter = regcounter+7; % increase regressor-counter
        end
        if AnaDef.GlobalMeanReg==false && AnaDef.MotionReg==true
            matlabbatch{2}.spm.stats.fmri_spec.sess(irun).multi_reg = cellstr(sclistmot);
            regcounter = regcounter+6; % increase regressor-counter
        end
        
        % configure HP filter
        matlabbatch{2}.spm.stats.fmri_spec.sess(irun).hpf = 128;
        
    end % end loop over runs
    
    % book-keeping: which regressor belongs to certain condition
    for icond=1:AnaDef.NumCond
        tmpvec = [];
        for irun=1:NumRuns
            tmpvec = [ tmpvec handles.anaobj{isubj}.Ana{1}.AnaDef.RegCond.Run{irun}.Cond{icond} ];
        end
        handles.anaobj{isubj}.Ana{1}.AnaDef.RegCondVec{icond} = tmpvec;
        fprintf('Regressors: condition %d : \n',icond);
        tmpvec
    end
    
    matlabbatch{2}.spm.stats.fmri_spec.fact             = struct('name', {}, 'levels', {});
    matlabbatch{2}.spm.stats.fmri_spec.bases.hrf.derivs = AnaDef.HRFDERIVS;
    matlabbatch{2}.spm.stats.fmri_spec.volt             = 1;
    matlabbatch{2}.spm.stats.fmri_spec.global           = 'None';
    matlabbatch{2}.spm.stats.fmri_spec.mask             = {''};
    matlabbatch{2}.spm.stats.fmri_spec.cvi              = 'AR(1)';
    
    %
    % model estimation (voxel)
    %
    if AnaDef.VoxelAnalysis==true % voxel-betaseries
        matlabbatch{3}.spm.stats.fmri_est.spmmat(1) = cfg_dep;
        matlabbatch{3}.spm.stats.fmri_est.spmmat(1).tname = 'Select SPM.mat';
        matlabbatch{3}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(1).name = 'filter';
        matlabbatch{3}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(1).value = 'mat';
        matlabbatch{3}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(2).name = 'strtype';
        matlabbatch{3}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(2).value = 'e';
        matlabbatch{3}.spm.stats.fmri_est.spmmat(1).sname = 'fMRI model specification: SPM.mat File';
        matlabbatch{3}.spm.stats.fmri_est.spmmat(1).src_exbranch = substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1});
        matlabbatch{3}.spm.stats.fmri_est.spmmat(1).src_output = substruct('.','spmmat');
        matlabbatch{3}.spm.stats.fmri_est.method.Classical = 1;
    end
    
    % run SPM job
    spm('defaults', 'FMRI');
    spm_jobman('initcfg')
    %spm_jobman('serial', jobs, '', inputs{:});
    %spm_jobman('interactive',matlabbatch); % open a GUI containing all the setup
    spm_jobman('run',matlabbatch);          % execute the batch
    
    %
    % ROI-based model estimation (estimate model on mean ROI time courses)
    %
    if AnaDef.ROIAnalysis==true
        h = waitbar(0,'','Name','Estimation ROI level ...');
        clear('bmat','b','E');
        for iROI=1:ROINum % loop over ROIs
            if ishandle(h)
                waitbar(iROI/ROINum,h,[num2str(round(100*iROI/ROINum)) '%']);
            end
            SPMfile = fullfile(data_path,outdirname,'SPM.mat');
            str=sprintf('Retrieving design for subject %d from SPM file: %s',isubj,SPMfile);
            handles.InfoText = WriteInfoBox(handles,str,true);
            D = mardo(SPMfile); % Marsbar design object
            R = maroi(ROIFile{iROI}); % Marsbar ROI object
            str=sprintf('Retrieving data from ROI %d using summary function %s ...',iROI,AnaDef.ROISummaryFunction);
            handles.InfoText = WriteInfoBox(handles,str,true);
            Y = get_marsy(R,D,AnaDef.ROISummaryFunction); % put data into marsbar data object
            E = estimate(D,Y); % estimate model based on ROI summary
            b = betas(E); % retrieve estimated beta-values
            bmat(:,iROI) = b; % matrix of beta-values: (rows: beta-values,columns: ROI)
        end % end loop over ROIs
        handles.anaobj{isubj}.Ana{1}.BetaSeries  = bmat;
        try
            close(h);
        end
        
        % store information in analysis object
        handles.anaobj{isubj}.Ana{1}.Configure.ROI.Path        = AnaDef.ROIDir;
        handles.anaobj{isubj}.Ana{1}.Configure.ROI.Num         = ROINum;
        handles.anaobj{isubj}.Ana{1}.Configure.ROI.File        = ROIFile;
        handles.anaobj{isubj}.AnaCurrent                       = 1;
        handles.anaobj{isubj}.AnaNum                           = 1;
        handles.anaobj{isubj}.Ana{1}.Configure.UseSPMDesign    = false;
        handles.anaobj{isubj}.Ana{1}.Configure.datapath        = data_path;
        handles.anaobj{isubj}.Ana{1}.Configure.SamplingRate    = handles.anaobj{isubj}.Ana{1}.AnaDef.RT;
        handles.anaobj{isubj}.Ana{1}.Configure.OmitVolumes     = 0;
        handles.anaobj{isubj}.Ana{1}.Label                     = 'ROI-beta-series analysis';
        handles.anaobj{isubj}.Ana{1}.Cut                       = -1.0;
        handles.anaobj{isubj}.Ana{1}.Configure.ROI.Names       = cellstr(thenames);
        
    end % end ROI analysis
    
    % load design
    data_path  = handles.anaobj{isubj}.Ana{1}.AnaDef.DataPath;
    outdirname = handles.anaobj{isubj}.Ana{1}.AnaDef.OutDir;
    spmfile    = 'SPM.mat';
    spmpath    = fullfile(data_path,outdirname);
    load(fullfile(spmpath,spmfile));
    X = [SPM.xX.X]; % (runs,regressors)
    handles.anaobj{isubj}.Ana{1}.AnaDef.X=X; % store design matrix
    
end % end loop over subjects   %%%%%%%%%%%%%%%%%%%

handles.NumJobs  = NumSubj;
handles.InfoText = WriteInfoBox(handles,'... model specification and estimation done.',true);

% save analysis object
anaobj = handles.anaobj;
if isfield(AnaDef,'Outfile') && strcmp(AnaDef.Outfile,'')==false
    try
        save(AnaDef.Outfile,'anaobj');
    catch
        handles.InfoText = WriteInfoBox(handles,'Error saving data. Select folder and enter file name.',true);
        [name, folder] = uiputfile('*','Select folder and enter file name.');
        save(fullfile(folder,strcat(name,'.mat')),'anaobj');
    end
else
    handles.InfoText = WriteInfoBox(handles,'Save data: Select folder and enter file name.',true);
    [name, folder] = uiputfile('*','Select folder and enter file name.');
    save(fullfile(folder,strcat(name,'.mat')),'anaobj');
end

handles.InfoText = WriteInfoBox(handles,'File saved.',true);
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                     ROI-ROI correlation                             %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function pushbuttonextractroibetaseries_Callback(hObject, eventdata, handles)
%
% extract beta-series for a set of ROIs (voxel mean)
%
handles.InfoText = WriteInfoBox(handles,'Extracting ROI beta-series ...',true);
BaseDirectory  = pwd;
[ROIFile, sts] = spm_select([Inf],'mat','Select ROIs (Marsbar format).');
if ~sts
    handles.InfoText = WriteInfoBox(handles,'No ROIs selected.',true);
    guidata(hObject, handles);
    return;
end
ROINum = size(ROIFile,1);
handles.InfoText = WriteInfoBox(handles,sprintf('Selected %d ROIs.',ROINum),true);

% get ROI names from txt-file
[ROINames, sts] = spm_select([1],'mat','Select txt-file containing ROI names.');
if ~sts
    for i=1:ROINum
        thenames{i}=['ROI_' num2str(i)];
    end
else
    fid = fopen(fullfile(ROINames));
    scnames  = textscan(fid,'%s');
    thenames = cellstr(char(scnames{1}));
end
if length(thenames)~=ROINum
    handles.InfoText = WriteInfoBox(handles,'Number of ROIs do not match.',true);
    guidata(hObject, handles);
    return;
end
% c.o.m. of ROIs
for iroi=1:ROINum
    load(strtrim(ROIFile(iroi,:)));
    compos(:,iroi) = c_o_m(roi);
end

for isubj=1:handles.NumJobs
    handles.InfoText = WriteInfoBox(handles,sprintf('Processing subject number %d ...',isubj),true);
    if isfield(handles.anaobj{isubj}.Ana{1},'Configure')==true
        if isfield(handles.anaobj{isubj}.Ana{1}.Configure.ROI,'Path')==true
            disp('Clearing previous ROI definition ...');
            handles.anaobj{isubj}.Ana{1}.Configure.ROI.Names = {};
            handles.anaobj{isubj}.Ana{1}.Configure.ROI.File  = {};
            handles.anaobj{isubj}.Ana{1}.Configure.ROI.Num   = 0;
            handles.anaobj{isubj}.Ana{1}.Configure.ROI.Path  = '';
        end
    end
    % store information in analysis object
    ROIPath = fileparts(ROIFile(1,:));
    handles.anaobj{isubj}.Ana{1}.Configure.ROI.Path        = ROIPath;
    handles.anaobj{isubj}.Ana{1}.Configure.ROI.Num         = ROINum;
    handles.anaobj{isubj}.Ana{1}.Configure.ROI.File        = cellstr(ROIFile);
    handles.anaobj{isubj}.Ana{1}.Configure.ROI.ROICOM      = compos;
    handles.anaobj{isubj}.Ana{1}.Configure.ROI.Names       =  thenames;
    handles.anaobj{isubj}.Ana{1}.Configure.ROI.ROIShortLabel = thenames;
    handles.anaobj{isubj}.AnaCurrent                       = 1;
    handles.anaobj{isubj}.AnaNum                           = 1;
    handles.anaobj{isubj}.Ana{1}.Configure.UseSPMDesign    = false;
    handles.anaobj{isubj}.Ana{1}.Configure.datapath        = fullfile(handles.anaobj{isubj}.Ana{1}.AnaDef.DataPath,handles.anaobj{isubj}.Ana{1}.AnaDef.OutDir);
    handles.anaobj{isubj}.Ana{1}.Configure.SamplingRate    = handles.anaobj{isubj}.Ana{1}.AnaDef.RT;
    handles.anaobj{isubj}.Ana{1}.Configure.OmitVolumes     = 0;
    handles.anaobj{isubj}.Ana{1}.Label                     = 'beta series analysis (voxel)';
    handles.anaobj{isubj}.Ana{1}.Cut                       = -1.0;
    handles.anaobj{isubj}.Ana{1}.Configure.ROI.Names = cellstr(thenames);
    
    % create list of files which contain the beta-values
    beta_path  = fullfile(handles.anaobj{isubj}.Ana{1}.AnaDef.DataPath,handles.anaobj{isubj}.Ana{1}.AnaDef.OutDir);
    DATA = spm_select('FPList',beta_path, ['^beta*.*\.img']);
    % retrieve beta values
    handles.InfoText = WriteInfoBox(handles,'Retrieving beta-values ...',true);
    
    rois = maroi('load_cell', ROIFile);             % make maroi ROI objects
    mY = get_marsy(rois{:}, DATA, 'mean','v');      % extract data into marsy data object
    bs = summary_data(mY);                          % get summary time course(s)
    handles.anaobj{isubj}.Ana{1}.BetaSeries  = bs;  % rows: beta-value and columns: ROIs
    numcols = size(bs,2);
    if numcols~=ROINum
        handles.InfoText = WriteInfoBox(handles,sprintf('Subject %d. Missing data (%d).',isub,numcols),true);
    end
    disp('... done.');
    % correlation matrix
    handles.InfoText = WriteInfoBox(handles,'Computing correlation matrix ...',true);
    [NWM, Pmat] = corrcoef(handles.anaobj{isubj}.Ana{1}.BetaSeries); % rows: time and columns: ROI
    handles.InfoText = WriteInfoBox(handles,'... done.',true);
    handles.anaobj{isubj}.Ana{1}.Matrix  = NWM;
    handles.anaobj{isubj}.Ana{1}.MatrixP = Pmat;
end % end loop over subjects
handles.InfoText = WriteInfoBox(handles,'Extracted beta-series.',true);
guidata(hObject, handles);

function pushbuttoninspectroibetaseries_Callback(hObject, eventdata, handles)
try
    NWM = handles.anaobj{1}.Ana{1}.Matrix;
catch
    handles.InfoText = WriteInfoBox(handles,'Compute correlation matrix first.',true);
    guidata(hObject, handles);
    return;
end
InspectROIBetaSeries(handles.anaobj);

function pushbuttoncorrelationmatrix_Callback(hObject, eventdata, handles)
try
    NWM = handles.anaobj{1}.Ana{1}.Matrix;
catch
    handles.InfoText = WriteInfoBox(handles,'Compute correlation matrix first.',true);
    guidata(hObject, handles);
    return;
end
InspectCorrMatrix(handles.anaobj);

function pushbuttonselectconditions_Callback(hObject, eventdata, handles)
prompt    = { 'Select condition' };
dlg_title = 'Select condition';
num_lines = 1;
def       = { '1' };
answer    = inputdlg(prompt,dlg_title,num_lines,def);
thecond   = str2num(answer{1});
NumCond   = size(thecond,2);
hrfderivs = handles.anaobj{1}.Ana{1}.AnaDef.HRFDERIVS; % regressors for temporal derivatives?
if isfield(handles.anaobj{1}.Ana{1},'BetaSeriesFull')==true
    handles.InfoText = WriteInfoBox(handles,'Reverting previous selection of beta-series.',true);
    for isubj=1:handles.NumJobs % loop over subjects
        handles.anaobj{isubj}.Ana{1}.BetaSeries = handles.anaobj{isubj}.Ana{1}.BetaSeriesFull; % restore beta-series
        size(handles.anaobj{isubj}.Ana{1}.BetaSeries)
    end
    handles.InfoText = WriteInfoBox(handles,'... done.',true);
end

for isubj=1:handles.NumJobs % loop over subjects
    % backup of all beta-values
    handles.anaobj{isubj}.Ana{1}.BetaSeriesFull     = handles.anaobj{isubj}.Ana{1}.BetaSeries;
    % beta-series selected
    handles.anaobj{isubj}.Ana{1}.BetaSeriesSel      = true;
    % store which conditions were selected
    handles.anaobj{isubj}.Ana{1}.SelectedConditions = thecond;
    %
    theindices = Condition2Indices(handles.anaobj{isubj},thecond);
    handles.anaobj{isubj}.Ana{1}.ConditionIndices = theindices; % store indices
    theindices
    clear('bs','newbs');
    bs=handles.anaobj{isubj}.Ana{1}.BetaSeries;
    for inode=1:size(bs,2)
        newbs(:,inode) = CondSelBS(handles.anaobj{isubj},thecond,bs(:,inode));
    end
    
    clear(sprintf('handles.anaobj{%d}.Ana{1}.BetaSeries',isubj));
    handles.anaobj{isubj}.Ana{1}.BetaSeries = newbs;
    % correlation matrix
    [NWM, Pmat ] = corrcoef(handles.anaobj{isubj}.Ana{1}.BetaSeries); % rows: time and columns: ROI
    NWM = NWM-eye(size(NWM,1));
    handles.anaobj{isubj}.Ana{1}.Matrix  = NWM;
    handles.anaobj{isubj}.Ana{1}.MatrixP = Pmat;
end % end loop over subjects

handles.InfoText = WriteInfoBox(handles,sprintf('Selection performed: %s',answer{1}),true);
guidata(hObject, handles);

function theindices = Condition2Indices(anaobj,thecond)
theindices = [];
NumCond    = length(thecond);
for icond=1:NumCond
    theindices = [theindices anaobj.Ana{1}.AnaDef.RegCondVec{thecond(icond)}];
end

function newbs = CondSelBS(anaobj,thecond,bs)
hrfderivs  = anaobj.Ana{1}.AnaDef.HRFDERIVS; % regressors for temporal derivatives?
theindices = Condition2Indices(anaobj,thecond);
if hrfderivs(1)==0 && hrfderivs(2)==0
    newbs = bs(theindices);
end
if hrfderivs(1)==1 && hrfderivs(2)==0
    X = anaobj.Ana{1}.AnaDef.X; % design (runs,regressors)
    for itrial=1:length(theindices)
        idx   = theindices(itrial);
        beta1 = bs(idx);
        beta2 = bs(idx+1);
        newbs(itrial) = sign(beta1)*sqrt(beta1^2+beta2^2);
    end
end
if hrfderivs(1)==1 && hrfderivs(2)==1 % fix me!
    X = anaobj.Ana{1}.AnaDef.X; % design (runs,regressors)
    for itrial=1:length(theindices)
        idx   = theindices(itrial);
        beta1 = bs(idx);
        beta2 = bs(idx+1);
        newbs(itrial) = sign(beta1)*sqrt(beta1^2+beta2^2);
    end
end

function popupmenu_nwana_Callback(hObject, eventdata, handles)
selected = get(hObject,'Value');
switch selected
    case 2
        [Files, sts] = spm_select([2],'mat','Select two files containing the analyses objects.');
        if ~sts
            disp('Select two files.');
            return;
        end
        load(strtrim(Files(1,:)));
        ana{1}=anaobj;
        load(strtrim(Files(2,:)));
        ana{2}=anaobj;
        leg{1}='A';
        leg{2}='B';
        GrAnaEdge(ana,leg);
        guidata(hObject, handles);
    case 3
        disp('Not yet implemented.');
        guidata(hObject, handles);

end % end switch
function popupmenu_nwana_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function popupmenumore_Callback(hObject, eventdata, handles)
selected = get(hObject,'Value');
switch selected
    case 2
        handles = basco_meanbetavalues(handles);
        guidata(hObject, handles);
    case 3
        basco_univariateroi();
    case 4
        basco_checkestimation(handles);
    case 5 % rename nodes/ROIs
        [file, path]    = uigetfile('*.txt');
        fid             = fopen(fullfile(path,file));
        importeddata    = textscan(fid,'%s');
        NumSubj = handles.NumJobs;
        for isubj=1:NumSubj
            NumNodes = size(importeddata{1},1);
            for inode=1:1:NumNodes
                handles.anaobj{isubj}.Ana{1}.Configure.ROI.Names{inode} = char(importeddata{1}(inode,:));
                fprintf('%d -> %s \n',inode,handles.anaobj{isubj}.Ana{1}.Configure.ROI.Names{inode});
            end % end loop over nodes
        end % end loop over subjects
    case 6 % reslice image (gray matter mask)
        matlabbatch{1}.spm.spatial.coreg.write.ref = '<UNDEFINED>';
        matlabbatch{1}.spm.spatial.coreg.write.source = '<UNDEFINED>';
        matlabbatch{1}.spm.spatial.coreg.write.roptions.interp = 1;
        matlabbatch{1}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
        matlabbatch{1}.spm.spatial.coreg.write.roptions.mask = 0;
        matlabbatch{1}.spm.spatial.coreg.write.roptions.prefix = 'r';
        spm('defaults', 'FMRI');
        spm_jobman('initcfg')
        spm_jobman('interactive',matlabbatch);
    case 7
        prompt = {'Select subjects.'};
        dlg_title = 'Select subjects';
        num_lines = 1;
        def = {sprintf('1:%d',length(handles.anaobj))};
        answer = inputdlg(prompt,dlg_title,num_lines,def);
        idx = str2num(answer{1});
        cnt=0;
        for i=idx
            cnt=cnt+1;
            newanaobj{cnt} = handles.anaobj{i};
            fprintf('%d : Selected subject %d ...\n',cnt,i);
        end
        clear('handles.anaobj');
        handles.anaobj = newanaobj;
        handles.NumJobs = length(handles.anaobj);
        handles.InfoText = WriteInfoBox(handles,sprintf('Selected %d subjects.\n',handles.NumJobs),true);
        guidata(hObject, handles);
    case 8
        ROIS = spm_select([1],'image','Select number labelled ROI file.');
        NumSubj = handles.NumJobs;
        % loop over subjects
        for isubj=1:NumSubj
            handles.anaobj{isubj}.Ana{1}.Configure.ROI.ROIFILE = ROIS;
        end % end loop over subjects
        guidata(hObject, handles);
    case 9
        disp('Smooth data.');
        tmppath = pwd;
        cd(fullfile(handles.anaobj{1}.Ana{1}.AnaDef.DataPath,handles.anaobj{1}.Ana{1}.AnaDef.OutDir));
        [fname1,path] = uigetfile('*.nii','Select map.','MultiSelect','off');
        cd(tmppath);
        NumSubj   = handles.NumJobs;
        thefiles  = cell(1,NumSubj);
        for isubj=1:NumSubj % loop over subjects
            data_path  = handles.anaobj{isubj}.Ana{1}.AnaDef.DataPath;
            outdirname = handles.anaobj{isubj}.Ana{1}.AnaDef.OutDir;
            thefiles{isubj} = fullfile(data_path,outdirname,fname1);
        end % end loop over subjects
        matlabbatch{1}.spm.spatial.smooth.data   = thefiles;
        matlabbatch{1}.spm.spatial.smooth.fwhm   = [8 8 8];
        matlabbatch{1}.spm.spatial.smooth.dtype  = 0;
        matlabbatch{1}.spm.spatial.smooth.im     = 1;
        matlabbatch{1}.spm.spatial.smooth.prefix = 's';
        spm('defaults', 'FMRI');
        spm_jobman('initcfg')
        spm_jobman('interactive',matlabbatch);
    case 10
        
    case 11
        basco_checkmaps(handles);
end % end switch

function popupmenumore_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                    Seed-ROI-VOXEL correlation                       %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function pushbuttonseedroi_Callback(hObject, eventdata, handles)
% select ROI
[roifile,roipath] = uigetfile('*.mat','Select seed ROI (marsbar .mat)','MultiSelect','off');
str=sprintf('Selected seed-ROI: %s. \nNow enter name for ROI.',fullfile(roipath,roifile));
handles.InfoText = WriteInfoBox(handles,str,true);
handles.SeedROI  = fullfile(roipath,roifile);
prompt    = { 'ROI name' };
dlg_title = 'ROI name';
num_lines = 1;
def       = { strrep(roifile,'.mat','') };
answer    = inputdlg(prompt,dlg_title,num_lines,def);
handles.SeedROIName = answer{1};
str=sprintf('Name: %s. \nNow you want to specify a condition and calculate the correlation map.',handles.SeedROIName);
handles.InfoText = WriteInfoBox(handles,str,true);
guidata(hObject, handles);

% create seed-based FC map
function pushbuttonrissman_Callback(hObject, eventdata, handles)
spm('Defaults','fMRI');
spm_jobman('initcfg');
marsbar('on');
if ~exist(handles.maskfile,'file')
    handles.InfoText = WriteInfoBox(handles,'Please select mask first.',true);
    guidata(hObject, handles);
    return;
end
% correlate seed-ROI beta-series to voxel beta-series
seedroifile = handles.SeedROI;
thecond     = str2num(get(handles.editconditionrissman,'String'));

NumSubj     = handles.NumJobs;
str         = sprintf('Number of subjects: %d ',NumSubj);
handles.InfoText = WriteInfoBox(handles,str,true);
str = sprintf('Correlate beta-series for condition(s): %s',num2str(thecond));
handles.InfoText = WriteInfoBox(handles,str,true);

for isubj=1:NumSubj % loop over subjects
    theidx = Condition2Indices(handles.anaobj{isubj},thecond); % indices in beta-series for chosen condition(s)
    tic
    % retrieve location of files from analysis object
    data_path  = handles.anaobj{isubj}.Ana{1}.AnaDef.DataPath;
    outdirname = handles.anaobj{isubj}.Ana{1}.AnaDef.OutDir;
    % get design
    SPMfile    = fullfile(data_path,outdirname,'SPM.mat');
    str=sprintf('Retrieving design for subject %d from SPM file: %s',isubj,SPMfile);
    handles.InfoText = WriteInfoBox(handles,str,true);
    % estimate model on ROI
    ROISummaryFunction = handles.anaobj{isubj}.Ana{1}.AnaDef.ROISummaryFunction;
    str=sprintf('Retrieving seed-ROI beta-series for subject %d (summary function: %s).',isubj,ROISummaryFunction);
    handles.InfoText = WriteInfoBox(handles,str,true);
    roibs = GetROIBetaSeries(SPMfile,seedroifile,ROISummaryFunction); % estimate model (from design in SPM-file) for seed-ROI
    % path to beta-files
    beta_path = fullfile(data_path,outdirname);
    BETAFILES = spm_select('FPList',beta_path, '^beta*.*\.img'); % get all beta-files
    if isempty(BETAFILES)
       BETAFILES = spm_select('FPList',beta_path, '^beta*.*\.nii');
    end
    fprintf('Number of beta-files (regressors): %d\n',size(BETAFILES,1));
    % get voxel timeseries within mask
    clear('y','vXYZ');
    handles.InfoText = WriteInfoBox(handles,'Extracting voxel timeseries ...',true);
    roi = maroi(handles.maskfile);
    roi = spm_hold(roi,0);
    [y, ~, vXYZ] = getdata(roi,BETAFILES,'l');
    % y    : (time,voxel) voxel timeseries
    % vXYZ : (xyz,voxel)  voxel position
    NumPts = size(y,1);
    NumVox = size(y,2);
    str=sprintf('Number of voxels: %d',NumVox);
    handles.InfoText = WriteInfoBox(handles,str,true);
    str=sprintf('Number of time points: %d',NumPts);
    handles.InfoText = WriteInfoBox(handles,str,true);
    str='Calculating functional connectivity map.';
    handles.InfoText = WriteInfoBox(handles,str,true);
    % create correlation map
    Aall   = [roibs y];
    A      = Aall(theidx,:); % select trials
    An     = bsxfun(@minus,A,mean(A,1));
    An     = bsxfun(@times,An,1./sqrt(sum(An.*An,1)));
    tsmat  = repmat(An(:,1),1,NumVox+1);
    C      = sum(tsmat.*An,1);
    fcvec  = C(2:NumVox+1);
    fcvec  = atanh(fcvec);
    % save correlation map to file
    outvol   = spm_vol(BETAFILES(1,:));
    corrmap  = zeros(outvol.dim(1),outvol.dim(2),outvol.dim(3));
    zcorrmap = zeros(outvol.dim(1),outvol.dim(2),outvol.dim(3));
    themean  = mean(fcvec(~isnan(fcvec)));
    thestd   = std(fcvec(~isnan(fcvec)));
    for ivox=1:NumVox % loop over voxels
        corrmap(vXYZ(1,ivox),vXYZ(2,ivox),vXYZ(3,ivox))  = fcvec(ivox);
        zcorrmap(vXYZ(1,ivox),vXYZ(2,ivox),vXYZ(3,ivox)) = atanh(fcvec(ivox)); % Fisher-z transformation of correlation coefficients
    end
    outvol.fname   = fullfile(data_path,outdirname,sprintf('fcmap_%s_%s.nii',handles.SeedROIName,strrep(num2str(thecond),' ','_')));
    spm_write_vol(outvol,corrmap);
    % write z-transformed map
    outvol.fname = fullfile(data_path,outdirname,sprintf('zfcmap_%s_%s.nii',handles.SeedROIName,strrep(num2str(thecond),' ','_')));
    spm_write_vol(outvol,zcorrmap);
    toc
end % end loop over subjects
handles.InfoText = WriteInfoBox(handles,'Seed-based connectivity analysis completed. Proceed to => Level 2 analysis <=.',true);
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function editconditionrissman_Callback(~, ~, ~)
function editconditionrissman_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pushbuttonseedroiinfo_Callback(~, ~, handles)
seedroifile = handles.SeedROI;
t1path      = fullfile(fileparts(which('spm')),'canonical');
t1file      = 'avg152T1.nii';
mars_display_roi('display',seedroifile,fullfile(t1path,t1file));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function bs = GetROIBetaSeries(SPMfile,ROIfile,ROISummaryFunction)
% get ROI beta series: estimate model based on ROI summary
D  = mardo(SPMfile); % Marsbar design object
R  = maroi(ROIfile); % Marsbar ROI object
fprintf('Retrieving data from ROI %s using summary function %s ... \n',ROIfile,ROISummaryFunction);
Y  = get_marsy(R,D,ROISummaryFunction); % put data into marsbar data object
E  = estimate(D,Y); % estimate model based on ROI summary
bs = betas(E); % retrieve estimated beta-values

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pushbuttonroibetaseries_Callback(hObject, ~, handles)
% plot beta-series for seed-ROI
NumSubj = handles.NumJobs;
str = sprintf('Please select subject (%d) and summary function (mean or median).',NumSubj);
set(handles.infobox,'String',str);
drawnow;
prompt    = { 'Select subject' , 'Summary function' };
dlg_title = 'Configure';
num_lines = 1;
def       = { '1' , 'mean' };
answer    = inputdlg(prompt,dlg_title,num_lines,def);
isubj     = str2num(answer{1});
SumFunc   = answer{2};
ROIfile = handles.SeedROI;
thecond = str2num(get(handles.editconditionrissman,'String'));
str = sprintf('Beta-series for selected seed-ROI and the condition(s): %s (subject %d)',num2str(thecond),isubj);
set(handles.infobox,'String',str);
drawnow;
[voxelbs]            = EstimateModelOnROI(handles,isubj,ROIfile,SumFunc,thecond);
[seedroimeanbs_cond] = MeanROIBetaSeries(handles,isubj,ROIfile,thecond);
figure('Name','');
plot([1:1:length(voxelbs)],voxelbs,'b-+',[1:1:length(seedroimeanbs_cond)],seedroimeanbs_cond,'r-+');
xlabel('trial');
ylabel('beta-value');
title('beta-series seed-ROI (model estimated on ROI level)');
legend('estimated on ROI level','estimated on voxel level (mean)');
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pushbuttonlevel2analysis_Callback(~, ~, handles)
% SPM level 2 analysis of correlation maps:
% paired t-test, two-sample t-test or 2x2 flexible factorial
thetest = get(handles.popupmenulevel2,'Value'); % test to perform
spm('Defaults','fMRI');
spm_jobman('initcfg');

%
% paired t-test (between conditions)
%
if thetest==1
    tmppath = pwd;
    cd(fullfile(handles.anaobj{1}.Ana{1}.AnaDef.DataPath,handles.anaobj{1}.Ana{1}.AnaDef.OutDir));
    file = uigetfile({'*.nii';'*.img'},'Select two maps.','MultiSelect','on');
    cd(tmppath);
    thedir = uigetdir('Select output directory');
    fname1 = file{1};
    fname2 = file{2};
    cd(thedir);
    NumSubj = handles.NumJobs;
    thefiles1=cell(1,NumSubj);
    thefiles2=cell(1,NumSubj);
    for isubj=1:NumSubj % loop over subjects
        data_path  = handles.anaobj{isubj}.Ana{1}.AnaDef.DataPath;
        outdirname = handles.anaobj{isubj}.Ana{1}.AnaDef.OutDir;
        thefiles1{isubj} = fullfile(data_path,outdirname,fname1);
        thefiles2{isubj} = fullfile(data_path,outdirname,fname2);
    end % end loop over subjects
    
    matlabbatch{1}.spm.stats.factorial_design.dir = {thedir};
    for isubj=1:NumSubj
        matlabbatch{1}.spm.stats.factorial_design.des.pt.pair(isubj).scans = { thefiles1{isubj} ; thefiles2{isubj} };
    end
    matlabbatch{1}.spm.stats.factorial_design.des.pt.gmsca = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.pt.ancova = 0;
    matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
    matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
end

%
% two-sample t-test (between groups)
%
if thetest==2
    [file,anapath] = uigetfile('*.mat','Select two files','MultiSelect','on');
    thedir = uigetdir('Select output directory');
    load(fullfile(anapath,file{1}))
    NumSubj1  = length(anaobj);
    thefiles1 = cell(1,NumSubj1);
    cd(fullfile(anaobj{1}.Ana{1}.AnaDef.DataPath,anaobj{1}.Ana{1}.AnaDef.OutDir));
    [fname,path] = uigetfile({'*.img';'*.nii'},'Select correlation/degree map','MultiSelect','off');
    for isubj=1:NumSubj1 % loop over subjects
        data_path  = anaobj{isubj}.Ana{1}.AnaDef.DataPath;
        outdirname = anaobj{isubj}.Ana{1}.AnaDef.OutDir;
        thefiles1{isubj} = fullfile(data_path,outdirname,fname);
    end % end loop over subjects
    load(fullfile(anapath,file{2}));
    NumSubj2  = length(anaobj);
    thefiles2 = cell(1,NumSubj2);
    for isubj=1:NumSubj2 % loop over subjects
        data_path  = anaobj{isubj}.Ana{1}.AnaDef.DataPath;
        outdirname = anaobj{isubj}.Ana{1}.AnaDef.OutDir;
        thefiles2{isubj} = fullfile(data_path,outdirname,fname);
    end % end loop over subjects
    cd(thedir);
    matlabbatch{1}.spm.stats.factorial_design.dir = {thedir};
    matlabbatch{1}.spm.stats.factorial_design.des.t2.scans1 = cellstr(thefiles1);
    matlabbatch{1}.spm.stats.factorial_design.des.t2.scans2 = cellstr(thefiles2);
    matlabbatch{1}.spm.stats.factorial_design.des.t2.dept = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.t2.variance = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.t2.gmsca = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.t2.ancova = 0;
    matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
    matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
end

%
% flexible factorial
%
if thetest==3
    disp('Flexible factorial: Subject and 2 factors.');
    prompt    = { 'Factor A' , 'Factor B' };
    dlg_title = 'Configure level 2 analysis (flexible factorial)';
    num_lines = 1;
    def       = { 'A' , 'B' };
    answer    = inputdlg(prompt,dlg_title,num_lines,def);
    tmppath = pwd;
    cd(fullfile(handles.anaobj{1}.Ana{1}.AnaDef.DataPath,handles.anaobj{1}.Ana{1}.AnaDef.OutDir));
    [fname1] = uigetfile({'*.nii';'*.img'},'Select connectivity/degree map: A1 B1','MultiSelect','off');
    [fname2] = uigetfile({'*.nii';'*.img'},'Select connectivity/degree map: A1 B2','MultiSelect','off');
    [fname3] = uigetfile({'*.nii';'*.img'},'Select connectivity/degree map: A2 B1','MultiSelect','off');
    [fname4] = uigetfile({'*.nii';'*.img'},'Select connectivity/degree map: A2 B2','MultiSelect','off');
    cd(tmppath);
    thedir = uigetdir('Select output directory');
    cd(thedir);
    NumSubj = handles.NumJobs;
    thefiles1=cell(1,NumSubj);
    thefiles2=cell(1,NumSubj);
    thefiles3=cell(1,NumSubj);
    thefiles4=cell(1,NumSubj);
    for isubj=1:NumSubj % loop over subjects
        data_path  = handles.anaobj{isubj}.Ana{1}.AnaDef.DataPath;
        outdirname = handles.anaobj{isubj}.Ana{1}.AnaDef.OutDir;
        %delete(fullfile(data_path,outdirname,'*vox*'));
        thefiles1{isubj} = fullfile(data_path,outdirname,fname1);
        thefiles2{isubj} = fullfile(data_path,outdirname,fname2);
        thefiles3{isubj} = fullfile(data_path,outdirname,fname3);
        thefiles4{isubj} = fullfile(data_path,outdirname,fname4);
    end % end loop over subjects
    matlabbatch{1}.spm.stats.factorial_design.dir = cellstr(thedir);
    % factors
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).name = 'Subject';
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).dept = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).variance = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).gmsca = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).ancova = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).name = answer{1};
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).dept = 1;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).variance = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).gmsca = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).ancova = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).name = answer{2};
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).dept = 1;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).variance = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).gmsca = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).ancova = 0;
    for i=1:NumSubj % add subjects to analysis
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(i).scans = { thefiles1{i} ; thefiles2{i} ; thefiles3{i} ; thefiles4{i} };
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(i).conds = [1 1
            1 2
            2 1
            2 2];
    end
    % main effects and interactions
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{1}.fmain.fnum = 2;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{2}.fmain.fnum = 3;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{3}.inter.fnums = [2 ; 3];
    matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
    matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
end % end flexible factorial

%
% estimation
%
matlabbatch{2}.spm.stats.fmri_est.spmmat = {fullfile(thedir,'SPM.mat')};
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
spm('defaults', 'FMRI');
spm_jobman('interactive',matlabbatch);  % open a GUI containing all the setup

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function popupmenulevel2_Callback(~, ~, ~)
function popupmenulevel2_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popupmenurissmancorrelation_Callback(~, ~, ~)
function popupmenurissmancorrelation_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                          Preprocessing                              %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [voxelbs_cond] = EstimateModelOnROI(handles,isubj,ROIfile,ROISummaryFunction,thecond)
% estimate model on ROI (for selected condition)
data_path  = handles.anaobj{isubj}.Ana{1}.AnaDef.DataPath;
outdirname = handles.anaobj{isubj}.Ana{1}.AnaDef.OutDir;
thecond    = str2num(get(handles.editconditionrissman,'String'));
SPMfile    = fullfile(data_path,outdirname,'SPM.mat');
fprintf('Retrieving design for subject %d from SPM file: %s \n',isubj,SPMfile);
bs = GetROIBetaSeries(SPMfile,ROIfile,ROISummaryFunction);
str = sprintf('Number of beta-values: %d',length(bs));
handles.InfoText = WriteInfoBox(handles,str,true);
voxelbs_cond = CondSelBS(handles.anaobj{isubj},thecond,bs);

function [seedroimeanbs_selcond] = MeanROIBetaSeries(handles,isubj,ROIfile,thecond)
% mean ROI beta-series
% create list of files which contain the beta-values
beta_path = fullfile(handles.anaobj{isubj}.Ana{1}.AnaDef.DataPath,handles.anaobj{isubj}.Ana{1}.AnaDef.OutDir)
DATA = spm_select('FPList',beta_path,'^beta*.*\.img');
if isempty(DATA)
  DATA = spm_select('FPList',beta_path,'^beta*.*\.nii');
end
% retrieve beta values
handles.InfoText = WriteInfoBox(handles,'Retrieving beta-values for voxels in selected ROI.',true);
rois = maroi('load_cell', ROIfile);           % make maroi ROI objects
mY = get_marsy(rois{:}, DATA, 'mean');        % extract data into marsy data object
seedroimeanbs = summary_data(mY);             % get summary time course(s)
seedroimeanbs_selcond = CondSelBS(handles.anaobj{isubj},thecond,seedroimeanbs);

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%                 Voxel Degree Centrality/Strength                   %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function pushbuttonvoxeldegree_Callback(hObject, eventdata, handles)
% create condition specific voxel degree/strength map
handles.InfoText = WriteInfoBox(handles,'Configure analysis.',true);
prompt    = { 'absolute threshold' , 'Select condition(s)' , 'ID' , 'Mask','Fast'};
dlg_title = 'Configure analysis';
num_lines = 1;
def       = { '0.25' , '1' , 'test' , '1' , '0'};
answer    = inputdlg(prompt,dlg_title,num_lines,def);
th        = str2num(answer{1});
thecondv  = str2num(answer{2});
idstr     = answer{3};
use_mask  = str2num(answer{4});
fastpro   = str2num(answer{5});

NumSubj = handles.NumJobs;
str=sprintf('Number of subjects: %d ',NumSubj);
handles.InfoText = WriteInfoBox(handles,str,true);
hrfderivs = handles.anaobj{1}.Ana{1}.AnaDef.HRFDERIVS; % regressors for temporal derivatives?

if use_mask==1
    maskfile                = spm_select(1,'image','Select mask (nifti image).');
    handles.InfoText        = WriteInfoBox(handles,'Mask selected.',true);
    maskvol                 = spm_vol(maskfile);
    maskimg                 = spm_read_vols(maskvol);
    [mx,my,mz]              = size(maskimg);
    maskvec                 = reshape(maskimg,mx*my*mz,1);
    imask                   = find(maskvec);
    str                     = sprintf('Number of voxels within mask: %d ',size(imask,1));
    handles.InfoText        = WriteInfoBox(handles,str,true);
    maskvec(find(~maskvec)) = nan;
end

for jcond=1:length(thecondv)
    thecond = thecondv(jcond);
    
    str=sprintf('===> Condition %d <===',thecond);
    handles.InfoText = WriteInfoBox(handles,str,true);
    
    for isubj=1:NumSubj % loop over subjects
        %
        % retrieve location of files from analysis object
        str=sprintf('===> Subject %d <===',isubj);
        handles.InfoText = WriteInfoBox(handles,str,true);
        data_path  = handles.anaobj{isubj}.Ana{1}.AnaDef.DataPath;
        outdirname = handles.anaobj{isubj}.Ana{1}.AnaDef.OutDir;
        
        %
        % path to beta-files
        beta_path  = fullfile(data_path,outdirname);
        BETAFILES  = spm_select('FPList',beta_path, ['^beta*.*\.img']); % get all beta-files
        if isempty(BETAFILES)
           BETAFILES = spm_select('FPList',beta_path, ['^beta*.*\.nii']);
        end
        str = sprintf('Correlate beta-series for condition(s): %s',num2str(thecond));
        handles.InfoText = WriteInfoBox(handles,str,true);
        fprintf('Number of beta-files (regressors): %d \n',size(BETAFILES,1));
        X = handles.anaobj{isubj}.Ana{1}.AnaDef.X; % design (runs,regressors)
        NumReg = size(X,2);
        if NumReg~=size(BETAFILES,1)
            disp('Number of beta-files and number of regressors in design matrix do not match!');
            return;
        end
        
        disp('Loading beta-files ...');
        for idx=1:NumReg
            betavol{idx}       = spm_vol(BETAFILES(idx,:));
            betaimg(:,:,:,idx) = spm_read_vols(betavol{idx});
            [Vx, Vy, Vz, beta] = size(betaimg); % number of voxels in x, y and z direction
        end
        Nvox = Vx*Vy*Vz;
        str = sprintf('%s \nVoxel dimensions (beta-images): %d %d %d %d',str,Vx,Vy,Vz,beta);
        handles.InfoText = WriteInfoBox(handles,str,true);
        mat = reshape(betaimg,Vx*Vy*Vz,beta); % reshape to matrix (voxel,beta)
        
        if use_mask==1
            try
                summat = sum(mat,2)+maskvec;
            catch
                handles.InfoText = WriteInfoBox(handles,'Mask not in the same space as the beta-files. Resample mask.',true);
                return;
            end
            idat   = find(~isnan(summat));
            str=sprintf('Number of voxels within mask and with data: %d ',size(idat,1));
            handles.InfoText = WriteInfoBox(handles,str,true);
        else
            idat   = find(~isnan(sum(mat,2)));
            str=sprintf('Number of voxels with data: %d ',size(idat,1));
            handles.InfoText = WriteInfoBox(handles,str,true);
        end
        ibeta = Condition2Indices(handles.anaobj{isubj},thecond);
        if hrfderivs(1)==0 && hrfderivs(2)==0
            datmat = mat(idat,ibeta);
        end
        % temporal derivatives
            % Estimating the "amplitude" of the effects at each voxel = sign(V1).*sqrt(V1.^2+V2.^2)
            % where V1 is the canonical effect contrast volume, and V2 is the temporal derivative
            % effect contrast volume. [Calhoun (2004)]        
        if hrfderivs(1)==1 && hrfderivs(2)==0
            datmatA = mat(idat,ibeta);
            datmatB = mat(idat,ibeta+1);
            datmat = sign(datmatA).*sqrt(datmatA.^2+datmatB.^2);
        end
        if hrfderivs(1)==1 && hrfderivs(2)==1
            datmatA = mat(idat,ibeta);
            datmatB = mat(idat,ibeta+1);
            datmatC = mat(idat,ibeta+2);
            datmat = sign(datmatA).*sqrt(datmatA.^2+datmatB.^2+datmatC.^2);
        end

        [degvec_idat, strvec_idat] = FastDeg(datmat',th,fastpro);
         
        %
        % degree
        degvec        = nan(1,Vx*Vy*Vz);
        degvec(idat)  = degvec_idat;
        voxdegmap     = reshape(degvec,[Vx Vy Vz]);
        outvol = betavol{1};
        outvol.fname = fullfile(data_path,outdirname,sprintf('voxdegmap_%s_%.2f_%s.nii',idstr,th,strrep(num2str(thecond),' ','_')));
        spm_write_vol(outvol,voxdegmap);
        %
        % z-transformed degree map
        outvol.fname = fullfile(data_path,outdirname,sprintf('zvoxdegmap_%s_%.2f_%s.nii',idstr,th,strrep(num2str(thecond),' ','_')));
        zdegmap = (voxdegmap-nanmean(voxdegmap(:)))/nanstd(voxdegmap(:));
        zdegmap(find(isnan(voxdegmap)))=nan;
        spm_write_vol(outvol,zdegmap);
        %
        % strength
        strvec        = nan(1,Vx*Vy*Vz);
        strvec(idat)  = strvec_idat;
        voxstrmap     = reshape(strvec,[Vx Vy Vz]);
        outvol = betavol{1};
        outvol.fname = fullfile(data_path,outdirname,sprintf('voxstrmap_%s_%.2f_%s.nii',idstr,th,strrep(num2str(thecond),' ','_')));
        spm_write_vol(outvol,voxstrmap);     
        fprintf('Wrote image(s) (%d voxels). \n',Nvox);
        
    end % loop over subjects
end % loop over conditions

handles.InfoText = WriteInfoBox(handles,'Voxel degree/strength maps created. Proceed to => Level 2 analysis <=.',true);
guidata(hObject, handles);

function pushbutton_rissmannmask_Callback(hObject, eventdata, handles)
handles.maskfile = spm_select(1,'mat','Select mask (Marsbar).');
handles.InfoText = WriteInfoBox(handles,'Mask selected.',true);
guidata(hObject, handles);
