function [ok,matlabbatch,outputfiles,job_id]=conn_setup_preproc(STEPS,varargin)
% CONN_SETUP_PREPROC
% Runs individual preprocessing steps
%
% conn_setup_preproc(STEPS)
% runs preprocessing pipeline, where STEPS is either one of the following strings:
%     'default_mni','default_mniphase','default_ss','default_ssphase'
% or a cell array containing one or several of the following individual steps:
%     'structural_manualorient','structural_center','structural_segment','structural_normalize',...
%     'structural_segment&normalize',...
%     'functional_removescans','functional_manualorient','functional_center',...
%     'functional_slicetime','functional_realign','functional_realign&unwarp',...
%     'functional_realign&unwarp&phasemap','functional_art','functional_coregister',...
%     'functional_segment','functional_normalize','functional_segment&normalize','functional_smooth'
%
% conn_setup_preproc(STEPS,'param1_name',param1_value,'param2_name',param2_value,...)
% defines non-default values for parameters specific to each individual step (see help conn_batch for additional details)
% Valid parameter names for individual steps are:
%       functional_removescans: 'removescans'
%       functional_manualorient: 'reorient'
%       functional_realign*|coregister|segment*|normalize: 'coregtomean'
%       functional_realign&unwarp&phasemap: 'unwarp'
%       functional_slicetime: 'sliceorder'
%       functional_art: 'art_thresholds'
%       functional_smooth: 'fwhm'
%       structural_segment: 'tpm_template','tpm_ngaus'
%       structural normalize: 'applytofunctional','voxelsize','boundingbox','functional_template','structural_template','tpm_template','tpm_ngaus'
%       General fields: 'subjects','doimport','usespm8methods',
%       GUI fields: 'dogui','multiplesteps'
%


global CONN_x CONN_gui;
PREFERSPM8OVERSPM12=false; 
if isdeployed, spmver12=true;
else spmver12=str2double(regexp(spm('ver'),'SPM(\d+)','tokens','once'))>=12;
end
if isfield(CONN_gui,'font_offset'),font_offset=CONN_gui.font_offset; else font_offset=0; end
options=varargin;
steps={'default_mni','default_mniphase','default_ss','default_ssphase',...
    'structural_manualorient','structural_center','structural_segment','structural_normalize',...
    'structural_segment&normalize','functional_removescans','functional_manualorient','functional_center',...
    'functional_slicetime','functional_realign','functional_realign&unwarp',...
    'functional_realign&unwarp&phasemap','functional_art','functional_coregister',...
    'functional_segment','functional_normalize','functional_segment&normalize','functional_smooth'};
steps_names={'<HTML><b>default preprocessing pipeline</b> for volume-based analyses (direct normalization to MNI-space)</HTML>','<HTML><b>preprocessing pipeline</b> for volume-based analyses (indirect normalization to MNI-space) when PhaseMaps are available</HTML>','<HTML><b>preprocessing pipeline</b> for surface-based analyses (in subject-space)</HTML>','<HTML><b>preprocessing pipeline</b> for surface-based analyses (in subject-space) when PhaseMaps are available</HTML>',...
    'structural Manual orientation','structural Center to (0,0,0) coordinates','structural Segmentation','structural Normalization',...
    'structural Segmentation & Normalization', 'functional Removal of initial scans','functional Manual orientation','functional Center to (0,0,0) coordinates',...
    'functional Slice-timing correction','functional Realignment','functional Realignment & unwarp',...
    'functional Realignment & unwarp & phase correction','functional Outlier detection (ART-based scrubbing)','functional Coregistration to structural',...
    'functional Segmentation','functional Normalization','functional Segmentation & Normalization','functional Smoothing'};
steps_descr={{'INPUT: structural&functional volumes','OUTPUT (all in MNI-space): skull-stripped normalized structural volume, Gray/White/CSF normalized masks, realigned slice-time corrected normalized smoothed functional volumes, subject movement ''realignment'' and ''scrubbing'' 1st-level covariate'},{'INPUT: structural&functional&VDM volumes','OUTPUT (all in MNI-space): skull-stripped normalized structural volume, Gray/White/CSF normalized masks, realigned&unwarp slice-time corrected normalized smoothed functional volumes, subject movement ''realignment'' and ''scrubbing'' 1st-level covariate'},{'INPUT: structural&functional volumes','OUTPUT (all in subject-space): skull-stripped structural volume, Gray/White/CSF masks, realigned slice-time corrected coregistered functional volumes, subject movement ''realignment'' and ''scrubbing'' 1st-level covariate'},{'INPUT: structural&functional&VDM volumes','OUTPUT (all in subject-space): skull-stripped structural volume, Gray/White/CSF masks, realigned&unwarp slice-time corrected coregistered functional volumes, subject movement ''realignment'' and ''scrubbing'' 1st-level covariate'},...
    {'INPUT: structural volume','OUTPUT: structural volume (same files re-oriented, not resliced)'}, {'INPUT: structural volume','OUTPUT: structural volume (same files translated, not resliced)'}, {'INPUT: structural volume','OUTPUT: skull-stripped structural volume, Gray/White/CSF masks (in same space as structural)'},{'INPUT: structural volume; optional coregistered functional volumes','OUTPUT: skull-stripped normalized structural volume; optional normalized functional volumes (all in MNI space)'},...
    {'INPUT: structural volume; optional coregistered functional volumes','OUTPUT: skull-stripped normalized structural volume, normalized Gray/White/CSF masks; optional normalized functional volumes (all in MNI space)'},{'INPUT: functional volumes','OUTPUT: subset of functional volumes'},{'INPUT: functional volumes','OUTPUT: functional volumes (same files re-oriented, not resliced)'},{'INPUT: functional volumes','OUTPUT: functional volumes (same files translated, not resliced)'}, ...
    {'INPUT: functional volumes','OUTPUT: slice-timing corrected functional volumes'},{'INPUT: functional volumes','OUTPUT: realigned functional volumes, subject movement ''realignment'' 1st-level covariate'},{'INPUT: functional volumes','OUTPUT: realigned&unwarp functional volumes, subject movement ''realignment'' 1st-level covariate'},...
    {'INPUT: functional volumes & VDM maps','OUTPUT: realigned&unwarp functional volumes, subject movement ''realignment'' 1st-level covariate'},{'INPUT: functional volumes, realignment parameters','OUTPUT: outlier scans 1st-level covariate'},{'INPUT: structural and mean functional volume (or first functional)','OUTPUT: functional volumes (all functional volumes are coregistered but not resliced)'},...
    {'INPUT: mean functional volume (or first functional)','OUTPUT: Gray/White/CSF masks (in same space as functional volume)'},{'INPUT: mean functional volume (or first functional)','OUTPUT: normalized functional volumes'},{'INPUT: mean functional volume (or first functional)','OUTPUT: normalized functional volumes, normalized Gray/White/CSF masks '},{'INPUT: functional volumes','OUTPUT: smoothed functional volumes'}};
steps_index=num2cell(1:numel(steps));
steps_index{1}=4+[11 8 9 2 5 16 13 18]; % This defines the steps included in defaultMNI
steps_index{2}=4+[12 8 9 2 14 5 13 18];    % This defines the steps included in defaultMNIphase
steps_index{3}=4+[11 9 14 3 13];    % This defines the steps included in defaultSS
steps_index{4}=4+[12 9 14 3 13];    % This defines the steps included in defaultSSphase
dogui=false;
nsubjects=1:CONN_x.Setup.nsubjects;
doimport=true;
typeselect='';
multiplesteps=false;
voxelsize=2;
boundingbox=[-90,-126,-72;90,90,108]; % default bounding-box
fwhm=[];
sliceorder=[];
unwarp=[];
removescans=[];
reorient=[];
coregtomean=true;
applytofunctional=false;
tpm_template=[];
tpm_ngaus=[];
art_thresholds=[];
art_global_thresholds=[9 3];
art_motion_thresholds=[2 .5];
art_global_threshold=art_global_thresholds(1); % default art scan-to-scan global signal z-value thresholds
art_motion_threshold=art_motion_thresholds(1); % default art scan-to-scan composite motion mm thresholds
art_use_diff_motion=1;
art_use_diff_global=1;
art_use_norms=1;
art_force_interactive=0;
art_drop_flag=0;
parallel_profile=[];
parallel_N=0;
functional_template=fullfile(fileparts(which('spm')),'templates','EPI.nii');
if isempty(dir(functional_template)), functional_template=fullfile(fileparts(which('spm')),'toolbox','OldNorm','EPI.nii'); end
structural_template=fullfile(fileparts(which('spm')),'templates','T1.nii');
if isempty(dir(structural_template)), structural_template=fullfile(fileparts(which('spm')),'toolbox','OldNorm','T1.nii'); end
selectedstep=1;
if ~isempty(STEPS)&&(ischar(STEPS)||(iscell(STEPS)&&numel(STEPS)==1))
    STEPS=char(STEPS);
    switch(STEPS)
        case 'default_mni',      STEPS=steps(steps_index{1}); selectedstep=1;
        case 'default_mniphase', STEPS=steps(steps_index{2}); applytofunctional=true; selectedstep=2;
        case 'default_ss',       STEPS=steps(steps_index{3}); selectedstep=3;
        case 'default_ssphase',  STEPS=steps(steps_index{4}); selectedstep=4;
        otherwise, STEPS=cellstr(STEPS);
    end
end
ok=0;
for n1=1:2:numel(options)-1,
    switch(lower(options{n1}))
        case 'select',
            typeselect=lower(options{n1+1});
        case 'multiplesteps',
            multiplesteps=options{n1+1};
        case 'fwhm',
            fwhm=options{n1+1};
        case 'sliceorder',
            sliceorder=options{n1+1};
        case 'unwarp',
            unwarp=options{n1+1}; % note: deprecated over CONN_x.Setup.unwarp_functional field
        case 'removescans',
            removescans=options{n1+1};
        case 'applytofunctional',
            applytofunctional=options{n1+1};
        case 'coregtomean',
            coregtomean=options{n1+1};
        case 'reorient',
            reorient=options{n1+1};
        case 'art_thresholds',
            art_thresholds=options{n1+1};
        case 'subjects',
            nsubjects=options{n1+1};
        case 'voxelsize',
            voxelsize=options{n1+1};
        case 'boundingbox',
            boundingbox=options{n1+1};
        case 'doimport',
            doimport=options{n1+1};
        case 'dogui',
            dogui=options{n1+1};
        case {'functional_template','template_functional'}
            functional_template=char(options{n1+1});
        case {'structural_template','template_structural'}
            structural_template=char(options{n1+1});
        case 'usespm8methods',
            PREFERSPM8OVERSPM12=options{n1+1};
        case 'tpm_template', 
            tpm_template=options{n1+1};
        case 'tpm_ngaus', 
            tpm_ngaus=options{n1+1};
        case 'parallel_profile'
            parallel_profile=options{n1+1};
        case 'parallel_N'
            parallel_N=options{n1+1};
        otherwise
            error(['unrecognized option ',options{n1}]);
    end
end
if isfield(CONN_x,'pobj')&&isstruct(CONN_x.pobj)&&isfield(CONN_x.pobj,'subjects'), nsubjects=CONN_x.pobj.subjects; end % this field overwrites user-defined options

if ~nargin||isempty(STEPS)||dogui,
    dogui=true;
    if ~isempty(typeselect)
        switch(typeselect)
            case 'structural', idx=find(cellfun('length',regexp(steps_names,'^structural')));
            case 'functional', idx=find(cellfun('length',regexp(steps_names,'^functional')));
            otherwise,         idx=1:numel(steps);
        end
        steps=steps(idx);
        steps_names=steps_names(idx);
        steps_descr=steps_descr(idx);
    end
    scalefig=1+multiplesteps;
    dlg.steps=steps;
    dlg.steps_names=steps_names;
    dlg.steps_descr=steps_descr;
    dlg.steps_index=steps_index;
    dlg.fig=figure('units','norm','position',[.2,.4,.35*scalefig,.5],'menubar','none','numbertitle','off','name','SPM data preprocessing step','color','w');
    if multiplesteps, 
        uicontrol('style','frame','units','norm','position',[.025,.6,.95,.375],'backgroundcolor','w','foregroundcolor',.75*[1 1 1],'fontsize',9+font_offset); 
        uicontrol('style','frame','units','norm','position',[.025,.025,.95,.55],'backgroundcolor','w','foregroundcolor',.75*[1 1 1],'fontsize',9+font_offset); 
    end
    uicontrol('style','text','units','norm','position',[.1,.9,.8,.05],'backgroundcolor','w','foregroundcolor','k','horizontalalignment','left','string','Data preprocessing steps:','fontweight','bold','fontsize',9+font_offset);
    dlg.m0=uicontrol('style','popupmenu','units','norm','position',[.1,.85,.8,.05],'string',steps_names,'value',selectedstep,'tooltipstring','Select a data preprocessing step','callback',@(varargin)conn_setup_preproc_update,'fontsize',9+font_offset);
    dlg.m1=uicontrol('style','checkbox','units','norm','position',[.1,.275,.8/scalefig,.05],'value',1,'string','Process all subjects','backgroundcolor','w','tooltipstring','Apply this preprocessing to all subjects in your curent CONN project','callback',@(varargin)conn_setup_preproc_update,'fontsize',9+font_offset);
    dlg.m2=uicontrol('style','popupmenu','units','norm','position',[.1,.35,.8/scalefig,.05],'value',1,'string',{'Run process and import results to CONN project','Run process only (do not import results)','Interactive SPM batch editor only (do not run process)'}','backgroundcolor','w','fontsize',9+font_offset);
    dlg.m3=uicontrol('style','checkbox','units','norm','position',[.1,.5,.8/scalefig,.05],'value',applytofunctional,'string','Apply structural deformation field to functional data as well','backgroundcolor','w','tooltipstring','Apply structural deformation field computed during structural normalization/segmentation step to coregistered functional data as well','visible','off','fontsize',9+font_offset);
    dlg.m4=uicontrol('style','checkbox','units','norm','position',[.1,.425,.8/scalefig,.05],'value',~coregtomean,'string','First functional volume as reference','backgroundcolor','w','tooltipstring','<HTML>Uses firts functional volume as reference in coregistration/normalization step <br/> - if unchecked coregistration/normalization uses mean-volume as reference instead<br/> - note: mean volume is created during realignment</HTML>','visible','off','fontsize',9+font_offset);
    dlg.m5=uicontrol('style','listbox','units','norm','position',[.1,.05,.4,.20],'max',2,'string',arrayfun(@(n)sprintf('Subject%d',n),1:CONN_x.Setup.nsubjects,'uni',0),'backgroundcolor','w','tooltipstring','Select subjects','visible','off','fontsize',9+font_offset);
    dlg.m6=uicontrol('style','text','units','norm','position',[.1,.625,.8,.175],'max',2,'string',steps_descr{selectedstep},'backgroundcolor','w','enable','inactive','horizontalalignment','left','fontsize',9+font_offset);
    [tstr,tidx]=conn_jobmanager('profiles');
    tstr=cellfun(@(x)sprintf('distributed processing: %s',x),tstr,'uni',0);
    tstr{tidx}=sprintf('<HTML><b>%s</b></HTML>',tstr{tidx});
    dlg.m9=uicontrol('style','popupmenu','units','norm','position',[.55,.12,.4,.05],'string',[{'local processing'} tstr],'value',1,'fontsize',8+CONN_gui.font_offset); 
    if multiplesteps, dlg.m11=uicontrol('style','pushbutton','units','norm','position',[.55,.04,.2,.07],'string','Start','tooltipstring','Accept changes and run preprocessing pipeline','callback','set(gcbf,''userdata'',0); uiresume(gcbf)','fontsize',9+font_offset);
    else              dlg.m11=uicontrol('style','pushbutton','units','norm','position',[.55,.04,.2,.07],'string','Start','tooltipstring','Accept changes and run data preprocessing step','callback','set(gcbf,''userdata'',0); uiresume(gcbf)','fontsize',9+font_offset);
    end
    dlg.m12=uicontrol('style','pushbutton','units','norm','position',[.75,.04,.2,.07],'string','Cancel','callback','delete(gcbf)','fontsize',9+font_offset);
    if multiplesteps
        set(dlg.m2,'visible','off');%'string',{'Run process and import results to CONN project'});
        set(dlg.m3,'position',get(dlg.m3,'position')-[0 .075 0 0]);
        set(dlg.m4,'position',get(dlg.m4,'position')-[0 .075 0 0]);
        set(dlg.fig,'name','SPM data preprocessing pipeline');
        uicontrol('style','text','units','norm','position',[.55,.5,.3,.05],'backgroundcolor','w','foregroundcolor','k','horizontalalignment','center','string','Data preprocessing pipeline:','fontweight','bold','fontsize',9+font_offset);
        dlg.m7=uicontrol('style','listbox','units','norm','position',[.55,.2,.3,.3],'max',2,'string',{},'backgroundcolor','w','tooltipstring','Define series of preprocessing steps','fontsize',9+font_offset,'callback','dlg=get(gcbo,''userdata''); str=get(gcbo,''string''); val=get(gcbo,''value''); if numel(val)==1, idx=find(strcmp(dlg.steps_names,str{val})); if numel(idx)==1, set(dlg.m0,''value'',idx); feval(get(dlg.m0,''callback'')); end; end');
        dlg.m8a=uicontrol('style','pushbutton','units','norm','position',[.86,.425,.1,.07],'string','Add','fontweight','bold','tooltipstring','Add data preprocessing step (above) to this list','callback','dlg=get(gcbo,''userdata''); ival=get(dlg.m0,''value''); val=dlg.steps_index{ival}; set(dlg.m7,''string'',cat(1,get(dlg.m7,''string''),dlg.steps_names(val)''));if ismember(ival,[1:2]), set(dlg.m3,''value'',ismember(ival,[2])); end; feval(get(dlg.m0,''callback''));','fontsize',9+font_offset);
        dlg.m8b=uicontrol('style','pushbutton','units','norm','position',[.86,.35,.1,.07],'string','Remove','tooltipstring','Removes selected preprocessing step from this list','callback','dlg=get(gcbo,''userdata''); str=get(dlg.m7,''string''); str=str(setdiff(1:numel(str),get(dlg.m7,''value''))); set(dlg.m7,''string'',str,''value'',[]); feval(get(dlg.m0,''callback'')); ','fontsize',9+font_offset);
        dlg.m8c=uicontrol('style','pushbutton','units','norm','position',[.86,.275,.1,.07],'string','Move up','tooltipstring','Moves selected preprocessing step up in this list','callback','dlg=get(gcbo,''userdata''); str=get(dlg.m7,''string''); val=get(dlg.m7,''value''); idx=1:numel(str); idx(val)=idx(val)-1.5; [nill,idx]=sort(idx); str=str(idx); set(dlg.m7,''string'',str,''value'',find(rem(nill,1)~=0));','fontsize',9+font_offset);
        dlg.m8d=uicontrol('style','pushbutton','units','norm','position',[.86,.2,.1,.07],'string','Move down','tooltipstring','Moves selected preprocessing step down this list','callback','dlg=get(gcbo,''userdata''); str=get(dlg.m7,''string''); val=get(dlg.m7,''value''); idx=1:numel(str); idx(val)=idx(val)+1.5; [nill,idx]=sort(idx); str=str(idx); set(dlg.m7,''string'',str,''value'',find(rem(nill,1)~=0));','fontsize',9+font_offset);
        set([dlg.m7 dlg.m8a dlg.m8b dlg.m8c dlg.m8d],'userdata',dlg);
    else dlg.m7=[];
    end
    set([dlg.m0 dlg.m1],'userdata',dlg);
    if ~isempty(STEPS)
        [tok,idx]=ismember(STEPS,steps);
        set(dlg.m7,'string',steps_names(idx(tok>0))');
    end
    conn_setup_preproc_update(dlg.m0);
    uiwait(dlg.fig);
    if ~ishandle(dlg.fig), return; end
    pressedok=get(dlg.fig,'userdata');
    if isempty(pressedok), return; end
    if multiplesteps
        STEPS=get(dlg.m7,'string');
        [tok,idx]=ismember(STEPS,steps_names);
        STEPS=steps(idx(tok>0));
    else
        STEPS=steps(get(dlg.m0,'value'));
    end
    %STEP_name=steps_names{get(dlg.m0,'value')};
    if any(ismember(STEPS,{'structural_segment&normalize','structural_normalize'})), applytofunctional=get(dlg.m3,'value'); end
    if any(ismember(STEPS,{'functional_coregister','functional_normalize','functional_segment','functional_segment&normalize'})), coregtomean=~get(dlg.m4,'value'); end
    if ~get(dlg.m1,'value'), nsubjects=get(dlg.m5,'value'); end
    dorun=get(dlg.m2,'value');
    doparallel=get(dlg.m9,'value');
    delete(dlg.fig);
    switch(dorun)
        case 1, STEPS=cellfun(@(x)['run_',x],STEPS,'uni',0); doimport=true;
        case 2, STEPS=cellfun(@(x)['run_',x],STEPS,'uni',0); doimport=false;
        case 3, STEPS=cellfun(@(x)['interactive_',x],STEPS,'uni',0); doimport=false;
        case 4, STEPS=cellfun(@(x)['update_',x],STEPS,'uni',0); doimport=true;
    end
    if doparallel>1
        parallel_profile=doparallel-1;
        answer=inputdlg('Number of parallel jobs?','',1,{num2str(numel(nsubjects))});
        if isempty(answer)||isempty(str2num(answer{1})), return; end
        parallel_N=str2num(answer{1});
    end
end

lSTEPS=regexprep(lower(STEPS),'^run_|^update_|^interactive_','');
if any(ismember('functional_smooth',lSTEPS))
    if isempty(fwhm)
        fwhm=inputdlg('Enter smoothing FWHM (in mm)','conn_setup_preproc',1,{num2str(8)});
        if isempty(fwhm), return; end
        fwhm=str2num(fwhm{1});
    end
end
if any(ismember('functional_slicetime',lSTEPS))
    sliceorder_select=[]; 
    if ischar(sliceorder), 
        [slok,sliceorder_select]=ismember(sliceorder,{'ascending','descending','interleaved (middle-top)','interleaved (bottom-up)','interleaved (top-down)','interleaved (Siemens)'});
        if ~slok, disp(sprintf('Warning: incorrect sliceorder name %s',sliceorder)); sliceorder_select=[]; end
        sliceorder=[];
    end
    if isempty(sliceorder)&&isempty(sliceorder_select)
        [sliceorder_select,tok] = listdlg('PromptString','Select slice order:','ListSize',[200 200],'SelectionMode','single','ListString',{'ascending','descending','interleaved (middle-top)','interleaved (bottom-up)','interleaved (top-down)','interleaved (Siemens)','manually define','do not know (skip slice timing correction)'});
        if isempty(sliceorder_select), return; end
        if sliceorder_select==8
            STEPS=STEPS(~ismember(lSTEPS,'functional_slicetime'));
        end
    end
else sliceorder_select=[];
end
if any(ismember('functional_removescans',lSTEPS))
    if isempty(removescans)
        removescans=inputdlg('Enter number of initial scans to remove','conn_setup_preproc',1,{num2str(0)});
        if isempty(removescans), return; end
        removescans=str2num(removescans{1});
    end
end
if any(ismember({'structural_manualorient','functional_manualorient'},lSTEPS))
    ntimes=sum(ismember(lSTEPS,{'structural_manualorient','functional_manualorient'}));
    if isempty(reorient)
        reorient={};
        opts={'translation to 0/0/0 coordinates',nan;
            '90 rotation around x-axis (x/y/z to x/-z/y)',[1 0 0;0 0 1;0 -1 0];
            '90 rotation around x-axis (x/y/z to x/z/-y)',[1 0 0;0 0 -1;0 1 0];
            '90 rotation around y-axis (x/y/z to -z/y/x)',[0 0 1;0 1 0;-1 0 0];
            '90 rotation around y-axis (x/y/z to z/y/-x)',[0 0 -1;0 1 0;1 0 0];
            '90 rotation around z-axis (x/y/z to y/-x/z)',[0 -1 0;1 0 0;0 0 1];
            '90 rotation around z-axis (x/y/z to -y/x/z)',[0 1 0;-1 0 0;0 0 1];
            '180 rotation around x-axis (x/y/z to x/-y/-z)',[1 0 0;0 -1 0;0 0 -1];
            '180 rotation around y-axis (x/y/z to -x/y/-z)',[-1 0 0;0 1 0;0 0 -1];
            '180 rotation around z-axis (x/y/z to -x/-y/z)',[-1 0 0;0 -1 0;0 0 1];
            'non-rigid reflection of x-axis (x/y/z/ to -x/y/z)', [-1 0 0;0 1 0;0 0 1];
            'non-rigid reflection of y-axis (x/y/z/ to x/-y/z)', [1 0 0;0 -1 0;0 0 1];
            'non-rigid reflection of z-axis (x/y/z/ to x/y/-z)', [1 0 0;0 1 0;0 0 -1]};
        for ntime=1:ntimes
            if ntimes>1 [treorient,tok] = listdlg('PromptString',sprintf('Select re-orientation transformation for STEP %d/%d:',ntime,ntimes),'ListSize',[300 200],'SelectionMode','single','ListString',opts(:,1));
            else [treorient,tok] = listdlg('PromptString','Select re-orientation transformation:','ListSize',[300 200],'SelectionMode','single','ListString',opts(:,1));
            end
            if isempty(treorient), return; end
            reorient{ntime}=opts{treorient,2};
        end
    end
end
if any(ismember('functional_art',lSTEPS))
    if isempty(art_thresholds)        
        thfig=figure('units','norm','position',[.4,.4,.3,.4],'color','w','name','Functional outlier detection settings','numbertitle','off','menubar','none');
        ht0=uicontrol('style','popupmenu','units','norm','position',[.05,.8,.9,.1],'string',{'Use liberal settings (99th percentiles in normative sample)','Use conservative settings (95th percentiles in normative sample)','Edit settings','Edit settings interactively (ART gui)'},'value',1);
        ht1a=uicontrol('style','text','units','norm','position',[.05,.7,.9,.05],'string','Global-signal z-value threshold','backgroundcolor','w');
        ht1=uicontrol('style','edit','units','norm','position',[.05,.6,.9,.1],'string',num2str(art_global_threshold));
        ht2a=uicontrol('style','text','units','norm','position',[.05,.5,.9,.05],'string','Subject-motion mm threshold','backgroundcolor','w');
        ht2=uicontrol('style','edit','units','norm','position',[.05,.4,.9,.1],'string',num2str(art_motion_threshold));
        ht3a=uicontrol('style','checkbox','units','norm','position',[.05,.3,.4,.05],'string','Use diff global','value',art_use_diff_global,'backgroundcolor','w','tooltipstring','Global-signal threshold based on scan-to-scan changes in global BOLD signal');
        ht3b=uicontrol('style','checkbox','units','norm','position',[.05,.25,.4,.05],'string','Use abs global','value',~art_use_diff_global,'backgroundcolor','w','tooltipstring','Global-signal threshold based on absolute global BOLD signal values');
        ht3c=uicontrol('style','checkbox','units','norm','position',[.05,.20,.4,.05],'string','Drop first scan(s)','value',art_drop_flag>0,'backgroundcolor','w','userdata',art_drop_flag,'tooltipstring','Flags first scan(s) in each session for removal');
        ht4a=uicontrol('style','checkbox','units','norm','position',[.55,.3,.4,.05],'string','Use diff motion','value',art_use_diff_motion,'backgroundcolor','w','tooltipstring','Subject-motion threshold based on scan-to-scan changes in motion parameters');
        ht4b=uicontrol('style','checkbox','units','norm','position',[.55,.25,.4,.05],'string','Use abs motion','value',~art_use_diff_motion,'backgroundcolor','w','tooltipstring','Subject-motion threshold based on absolute motion parameter values');
        ht5=uicontrol('style','checkbox','units','norm','position',[.55,.2,.9,.05],'string','Use comp motion','value',art_use_norms,'backgroundcolor','w','tooltipstring','Subject-motion threshold based on composite motion measure');
        uicontrol('style','pushbutton','string','OK','units','norm','position',[.1,.01,.38,.10],'callback','uiresume');
        uicontrol('style','pushbutton','string','Cancel','units','norm','position',[.51,.01,.38,.10],'callback','delete(gcbf)');
        set([ht1a ht1 ht2a ht2 ht3a ht4a ht3b ht3c ht4b ht5],'enable','off');
        set(ht0,'callback','h=get(gcbo,''userdata''); switch get(gcbo,''value''), case 1, set(h.handles,''enable'',''off''); set(h.handles(2),''string'',num2str(h.default{1}(1))); set(h.handles(4),''string'',num2str(h.default{2}(1))); set(h.handles([5:6 9]),''value'',1); set(h.handles(7:8),''value'',0); case 2, set(h.handles,''enable'',''off''); set(h.handles(2),''string'',num2str(h.default{1}(2))); set(h.handles(4),''string'',num2str(h.default{2}(2))); set(h.handles([5:6 9]),''value'',1); set(h.handles(7:8),''value'',0); case 3, set(h.handles,''enable'',''on''); case 4, set(h.handles,''enable'',''off''); end;','userdata',struct('handles',[ht1a ht1 ht2a ht2 ht3a ht4a ht3b ht3c ht4b ht5],'default',{{art_global_thresholds, art_motion_thresholds}}));
        %@(varargin)set([ht1a ht1 ht2a ht2 ht3a ht4a ht3b ht4b ht5],'enable',subsref({'on','off'},struct('type','{}','subs',{{1+(get(gcbo,'value')~=3)}}))));
        set(ht5,'callback','h=get(gcbo,''userdata''); temp=str2num(get(h.handles(4),''string'')); if get(gcbo,''value''), set(h.handles(3),''string'',''Subject-motion mm threshold''); temp=temp(1); else, set(h.handles(3),''string'',''Subject-motion translation/rotation thresholds [mm, rad]''); if numel(temp)<2, temp=[temp .02]; end; end; set(h.handles(4),''string'',mat2str(temp));','userdata',struct('handles',[ht1a ht1 ht2a ht2 ht3a ht4a ht3b ht3c ht4b ht5],'default',{{art_global_thresholds, art_motion_thresholds}}));
        set(ht3a,'callback',@(varargin)set(ht3b,'value',~get(gcbo,'value')));
        set(ht3b,'callback',@(varargin)set(ht3a,'value',~get(gcbo,'value')));
        set(ht3c,'callback','v=get(gcbo,''value''); if v, v=str2double(inputdlg({''Number of initial scans to remove''},'''',1,{num2str(get(gcbo,''userdata''))})); if isempty(v), v=0; end; end; set(gcbo,''value'',v>0); if v>0, set(gcbo,''userdata'',v); end');
        set(ht4a,'callback',@(varargin)set(ht4b,'value',~get(gcbo,'value')));
        set(ht4b,'callback',@(varargin)set(ht4a,'value',~get(gcbo,'value')));
        uiwait(thfig);
        if ~ishandle(thfig), return; end
        art_global_threshold=str2num(get(ht1,'string'));
        temp=str2num(get(ht2,'string'));
        art_motion_threshold=temp;
        art_use_diff_global=get(ht3a,'value');
        art_use_diff_motion=get(ht4a,'value');
        art_use_norms=get(ht5,'value');
        if get(ht3c,'value'), art_drop_flag=get(ht3c,'userdata'); else art_drop_flag=0; end
        art_force_interactive=get(ht0,'value')==4;
        delete(thfig);
        drawnow;

        %answ=inputdlg({'Enter scan-to-scan global signal z-value threshold','Enter scan-to-scan composite motion mm threshold'},'conn_setup_preproc',1,{num2str(art_global_threshold),num2str(art_motion_threshold)});
        %if isempty(answ), return; end
        %art_global_threshold=str2num(answ{1});
        %art_motion_threshold=str2num(answ{2});
    else
        art_global_threshold=art_thresholds(1);
        art_motion_threshold=art_thresholds(2);
        if numel(art_thresholds)>=3, art_use_diff_global=art_thresholds(3); end
        if numel(art_thresholds)>=4, art_use_diff_motion=art_thresholds(4); end
        if numel(art_thresholds)>=5, art_use_norms=art_thresholds(5); end
        if numel(art_thresholds)>=6, art_force_interactive=art_thresholds(6); end
        if numel(art_thresholds)>=7, art_motion_threshold(2)=art_thresholds(7); end
        if numel(art_thresholds)>=8, art_drop_flag=art_thresholds(8); end
    end
end

if parallel_N>0,
    if ~isempty(parallel_profile), conn_jobmanager('setprofile',parallel_profile); end
    Ns=numel(nsubjects);
    N=min(Ns,parallel_N);
    ns=Ns/N;
    Njobs=arrayfun(@(n)nsubjects(floor(ns*(n-1))+1:min(Ns,floor(ns*n))),1:N,'uni',0);
    conn save;
    info=conn_jobmanager('submit','setup_preprocessing',Njobs,[],...
        STEPS,...
        'fwhm',fwhm,'sliceorder',sliceorder,'unwarp',unwarp,'removescans',removescans,'applytofunctional',applytofunctional,...
        'coregtomean',coregtomean,'reorient',reorient,'art_thresholds',art_thresholds,'voxelsize',voxelsize,'boundingbox',boundingbox,...
        'doimport',doimport,'dogui',0,'functional_template',functional_template,'structural_template',structural_template,...
        'tpm_template',tpm_template,'tpm_ngaus',tpm_ngaus);
    [nill,finished]=conn_jobmanager('waitfor',info);
    if finished==2, ok=1+doimport;
    else ok=3;
    end
    return;
end

job_id={};

for iSTEP=1:numel(STEPS)
    matlabbatch={};
    outputfiles={};
    STEP=STEPS{iSTEP};
    idx=find(strcmpi(regexprep(lower(STEP),'^run_|^update_|^interactive_',''),steps));
    if ~isempty(idx), STEP_name=steps_names{idx(1)};
    else STEP_name='process';
    end
    ok=0;
    
    hmsg=[];
    if dogui, hmsg=conn_msgbox({['Preparing ',STEP_name],'Please wait...'},'');
    else disp(['Preparing ',STEP_name,'. Please wait...']);
    end
    switch(regexprep(lower(STEP),'^run_|^update_|^interactive_',''))
        case 'functional_removescans'
            for isubject=1:numel(nsubjects),
                nsubject=nsubjects(isubject);
                %matlabbatch{end+1}.removescans.data={};
                nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject));
                for nses=1:nsess
                    temp=cellstr(CONN_x.Setup.functional{nsubject}{nses}{1});
                    if numel(temp)==1, 
                        temp=cellstr(conn_expandframe(temp{1}));
                    end
                    %matlabbatch{end}.removescans.data{end+1}=temp;
                    outputfiles{isubject}{nses}=char(temp(max(0,removescans)+1:end+min(0,removescans)));
                end
            end

        case 'functional_manualorient'
        case 'structural_manualorient'
        case 'functional_center'
        case 'structural_center'
            
        case 'structural_segment'
            if ~PREFERSPM8OVERSPM12&&spmver12 %SPM12
                matlabbatch{end+1}.spm.spatial.preproc.channel.vols={};
                jsubject=0;
                for isubject=1:numel(nsubjects),
                    nsubject=nsubjects(isubject);
                    if CONN_x.Setup.structural_sessionspecific, nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject)); else nsess=1; end
                    for nses=1:nsess
                        jsubject=jsubject+1;
                        matlabbatch{end}.spm.spatial.preproc.channel.vols{jsubject}=CONN_x.Setup.structural{nsubject}{nses}{1};
                        outputfiles{isubject}{nses}{1}=CONN_x.Setup.structural{nsubject}{nses}{1};
                        outputfiles{isubject}{nses}{2}=conn_prepend('c1',CONN_x.Setup.structural{nsubject}{nses}{1},'.nii'); % note: fix SPM12 issue converting .img to .nii
                        outputfiles{isubject}{nses}{3}=conn_prepend('c2',CONN_x.Setup.structural{nsubject}{nses}{1},'.nii');
                        outputfiles{isubject}{nses}{4}=conn_prepend('c3',CONN_x.Setup.structural{nsubject}{nses}{1},'.nii');
                    end
                end
                if ~isempty(tpm_template), 
                    temp=cellstr(conn_expandframe(tpm_template));
                    if isempty(tpm_ngaus), tpm_ngaus=[1 1 2 3 4 2]; end % grey/white/CSF/bone/soft/air
                    for n=1:numel(temp)
                        matlabbatch{end}.spm.spatial.preproc.tissue(n)=struct('tpm',{temp(n)},'ngaus',tpm_ngaus(n),'native',[1 0],'warped',[0 0]);
                    end
                end
                matlabbatch{end}.spm.spatial.preproc.channel.vols=reshape(matlabbatch{end}.spm.spatial.preproc.channel.vols,[],1);
                matlabbatch{end}.spm.spatial.preproc.warp.write=[1 1];
            else % SPM8
                matlabbatch{end+1}.spm.spatial.preproc.data={};
                jsubject=0;
                for isubject=1:numel(nsubjects),
                    nsubject=nsubjects(isubject);
                    if CONN_x.Setup.structural_sessionspecific, nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject)); else nsess=1; end
                    for nses=1:nsess
                        jsubject=jsubject+1;
                        matlabbatch{end}.spm.spatial.preproc.data{jsubject}=CONN_x.Setup.structural{nsubject}{nses}{1};
                        outputfiles{isubject}{nses}{1}=CONN_x.Setup.structural{nsubject}{nses}{1};
                        outputfiles{isubject}{nses}{2}=conn_prepend('c1',CONN_x.Setup.structural{nsubject}{nses}{1});
                        outputfiles{isubject}{nses}{3}=conn_prepend('c2',CONN_x.Setup.structural{nsubject}{nses}{1});
                        outputfiles{isubject}{nses}{4}=conn_prepend('c3',CONN_x.Setup.structural{nsubject}{nses}{1});
                    end
                end
                if ~isempty(tpm_template), 
                    temp=cellstr(conn_expandframe(tpm_template));
                    if isempty(tpm_ngaus), tpm_ngaus=[2 2 2 4]; end % grey/white/CSF (+other implicit)
                    matlabbatch{end}.spm.spatial.preproc.opts.tpm=temp;
                    matlabbatch{end}.spm.spatial.preproc.opts.ngaus=ngaus(1:numel(temp)+1);
                end
                matlabbatch{end}.spm.spatial.preproc.roptions.bb=boundingbox;
                matlabbatch{end}.spm.spatial.preproc.output.GM=[0,0,1];
                matlabbatch{end}.spm.spatial.preproc.output.WM=[0,0,1];
                matlabbatch{end}.spm.spatial.preproc.output.CSF=[0,0,1];
            end
            jsubject=0;
            for isubject=1:numel(nsubjects),
                nsubject=nsubjects(isubject);
                if CONN_x.Setup.structural_sessionspecific, nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject)); else nsess=1; end
                for nses=1:nsess
                    jsubject=jsubject+1;
                    matlabbatch{end+1}.spm.util.imcalc.expression='(i2+i3+i4).*i1';
                    matlabbatch{end}.spm.util.imcalc.input=reshape(outputfiles{isubject}{nses}(1:4),[],1);
                    matlabbatch{end}.spm.util.imcalc.output=conn_prepend('c0',CONN_x.Setup.structural{nsubject}{nses}{1});
                    matlabbatch{end}.spm.util.imcalc.options.dtype=spm_type('float32');
                    outputfiles{isubject}{nses}{1}=conn_prepend('c0',CONN_x.Setup.structural{nsubject}{nses}{1});
                end
            end
            
        case 'structural_normalize'
            if 0, % deprecated in favor of explicit center step
                jsubject=0;
                for isubject=1:numel(nsubjects), % center first
                    nsubject=nsubjects(isubject);
                    if CONN_x.Setup.structural_sessionspecific, nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject)); else nsess=1; end
                    for nses=1:nsess
                        jsubject=jsubject+1;
                        temp0=CONN_x.Setup.structural{nsubject}{nses}{1};
                        temp=conn_prepend('c',temp0);
                        a=spm_vol(temp0);
                        b=spm_read_vols(a);
                        a.fname=temp;
                        a.mat(1:3,4)=-a.mat(1:3,1:3)*a.dim'/2;
                        spm_write_vol(a,b);
                        [CONN_x.Setup.structural{nsubject}{nses},V]=conn_file(temp);
                    end
                    if ~CONN_x.Setup.structural_sessionspecific, CONN_x.Setup.structural{nsubject}(2:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject)))=CONN_x.Setup.structural{nsubject}(1); end
                end
            end
            DOSPM12=~PREFERSPM8OVERSPM12&spmver12; %SPM12/SPM8
            if DOSPM12
                %note: structural_template disregarded (using tissue probability maps instead)
                matlabbatch{end+1}.spm.spatial.normalise.estwrite.woptions.bb=boundingbox;
                matlabbatch{end}.spm.spatial.normalise.estwrite.woptions.vox=voxelsize*[1 1 1];
                if ~isempty(tpm_template), matlabbatch{end}.spm.spatial.normalise.estwrite.eoptions.tpm=reshape(cellstr(tpm_template),[],1); end
            else
                %note: tissue probability maps disregarded (using structural template instead)
                matlabbatch{end+1}.spm.spatial.normalise.estwrite.roptions.bb=boundingbox;
                matlabbatch{end}.spm.spatial.normalise.estwrite.roptions.vox=voxelsize*[1 1 1];
                matlabbatch{end}.spm.spatial.normalise.estwrite.eoptions.template={structural_template};
            end
            jsubject=0;
            for isubject=1:numel(nsubjects), 
                nsubject=nsubjects(isubject);
                if CONN_x.Setup.structural_sessionspecific, nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject)); else nsess=1; end
                for nses=1:nsess
                    jsubject=jsubject+1;
                    if DOSPM12, matlabbatch{end}.spm.spatial.normalise.estwrite.subj(jsubject).vol={CONN_x.Setup.structural{nsubject}{nses}{1}};
                    else        matlabbatch{end}.spm.spatial.normalise.estwrite.subj(jsubject).source={CONN_x.Setup.structural{nsubject}{nses}{1}};
                    end
                    outputfiles{isubject}{nses}{1}=conn_prepend('w',CONN_x.Setup.structural{nsubject}{nses}{1});
                    matlabbatch{end}.spm.spatial.normalise.estwrite.subj(jsubject).resample={CONN_x.Setup.structural{nsubject}{nses}{1}};
                    if applytofunctional
                        if CONN_x.Setup.structural_sessionspecific, nsesstrue=nses; 
                        else nsesstrue=1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject));
                        end
                        for nsestrue=nsesstrue
                            temp=cellstr(CONN_x.Setup.functional{nsubject}{nsestrue}{1});
                            if coregtomean, % keeps mean image in same space in case it is required later
                                [xtemp,failed]=conn_setup_preproc_meanimage(temp{1});
                                if ~isempty(xtemp),
                                    xtemp={xtemp};
                                    matlabbatch{end}.spm.spatial.normalise.estwrite.subj(jsubject).resample=cat(1,matlabbatch{end}.spm.spatial.normalise.estwrite.subj(jsubject).resample,xtemp);
                                end
                            end
                            matlabbatch{end}.spm.spatial.normalise.estwrite.subj(jsubject).resample=cat(1,matlabbatch{end}.spm.spatial.normalise.estwrite.subj(jsubject).resample,temp);
                            outputfiles{isubject}{nsestrue}{5}=char(conn_prepend('w',temp));
                        end
                    end
                end
            end
            
        case 'structural_segment&normalize'
            if 0, % deprecated in favor of explicit center step
                jsubject=0;
                for isubject=1:numel(nsubjects), % center first
                    nsubject=nsubjects(isubject);
                    if CONN_x.Setup.structural_sessionspecific, nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject)); else nsess=1; end
                    for nses=1:nsess
                        jsubject=jsubject+1;
                        temp0=CONN_x.Setup.structural{nsubject}{nses}{1};
                        temp=conn_prepend('c',temp0);
                        a=spm_vol(temp0);
                        b=spm_read_vols(a);
                        a.fname=temp;
                        a.mat(1:3,4)=-a.mat(1:3,1:3)*a.dim'/2;
                        spm_write_vol(a,b);
                        [CONN_x.Setup.structural{nsubject}{nses},V]=conn_file(temp);
                    end
                    if ~CONN_x.Setup.structural_sessionspecific, CONN_x.Setup.structural{nsubject}(2:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject)))=CONN_x.Setup.structural{nsubject}(1); end
                end
            end
            DOSPM12=~PREFERSPM8OVERSPM12&spmver12; %SPM12/SPM8
            if DOSPM12, matlabbatch{end+1}.spm.spatial.preproc.channel.vols={};
            else  matlabbatch{end+1}.spm.spatial.preproc.data={};
            end
            jsubject=0;
            for isubject=1:numel(nsubjects),
                nsubject=nsubjects(isubject);
                if CONN_x.Setup.structural_sessionspecific, nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject)); else nsess=1; end
                for nses=1:nsess
                    jsubject=jsubject+1;
                    if DOSPM12,
                        matlabbatch{end}.spm.spatial.preproc.channel.vols{jsubject}=CONN_x.Setup.structural{nsubject}{nses}{1};
                        outputfiles{isubject}{nses}{1}=CONN_x.Setup.structural{nsubject}{nses}{1};
                        outputfiles{isubject}{nses}{2}=conn_prepend('c1',CONN_x.Setup.structural{nsubject}{nses}{1},'.nii'); % note: fix SPM12 issue converting .img to .nii
                        outputfiles{isubject}{nses}{3}=conn_prepend('c2',CONN_x.Setup.structural{nsubject}{nses}{1},'.nii');
                        outputfiles{isubject}{nses}{4}=conn_prepend('c3',CONN_x.Setup.structural{nsubject}{nses}{1},'.nii');
                        outputfiles{isubject}{nses}{5}=conn_prepend('y_',CONN_x.Setup.structural{nsubject}{nses}{1},'.nii');
                    else
                        matlabbatch{end}.spm.spatial.preproc.data{jsubject}=CONN_x.Setup.structural{nsubject}{nses}{1};
                        outputfiles{isubject}{nses}{1}=CONN_x.Setup.structural{nsubject}{nses}{1};
                        outputfiles{isubject}{nses}{2}=conn_prepend('c1',CONN_x.Setup.structural{nsubject}{nses}{1});
                        outputfiles{isubject}{nses}{3}=conn_prepend('c2',CONN_x.Setup.structural{nsubject}{nses}{1});
                        outputfiles{isubject}{nses}{4}=conn_prepend('c3',CONN_x.Setup.structural{nsubject}{nses}{1});
                        outputfiles{isubject}{nses}{5}=conn_prepend('',CONN_x.Setup.structural{nsubject}{nses}{1},'_seg_sn.mat');
                    end
                end
            end
            if DOSPM12
                if ~isempty(tpm_template), 
                    temp=cellstr(conn_expandframe(tpm_template));
                    if isempty(tpm_ngaus), tpm_ngaus=[1 1 2 3 4 2]; end % grey/white/CSF/bone/soft/air
                    for n=1:numel(temp)
                        matlabbatch{end}.spm.spatial.preproc.tissue(n)=struct('tpm',{temp(n)},'ngaus',tpm_ngaus(n),'native',[1 0],'warped',[0 0]);
                    end
                end
                matlabbatch{end}.spm.spatial.preproc.warp.write=[1 1];
                matlabbatch{end}.spm.spatial.preproc.channel.vols=reshape(matlabbatch{end}.spm.spatial.preproc.channel.vols,[],1);
                matlabbatch{end+1}.spm.spatial.normalise.write.woptions.bb=boundingbox;
                matlabbatch{end}.spm.spatial.normalise.write.woptions.vox=voxelsize*[1 1 1];
            else
                if ~isempty(tpm_template), 
                    temp=cellstr(conn_expandframe(tpm_template));
                    if isempty(tpm_ngaus), tpm_ngaus=[2 2 2 4]; end % grey/white/CSF (+other implicit)
                    matlabbatch{end}.spm.spatial.preproc.opts.tpm=temp;
                    matlabbatch{end}.spm.spatial.preproc.opts.ngaus=ngaus(1:numel(temp)+1);
                end
                matlabbatch{end}.spm.spatial.preproc.roptions.bb=boundingbox;
                matlabbatch{end}.spm.spatial.preproc.output.GM=[0,0,1];
                matlabbatch{end}.spm.spatial.preproc.output.WM=[0,0,1];
                matlabbatch{end}.spm.spatial.preproc.output.CSF=[0,0,1];
                matlabbatch{end+1}.spm.spatial.normalise.write.roptions.bb=boundingbox;
                matlabbatch{end}.spm.spatial.normalise.write.roptions.vox=voxelsize*[1 1 1];
            end
            jsubject=0;
            for isubject=1:numel(nsubjects),
                nsubject=nsubjects(isubject);
                if CONN_x.Setup.structural_sessionspecific, nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject)); else nsess=1; end
                for nses=1:nsess
                    jsubject=jsubject+1;
                    if DOSPM12, matlabbatch{end}.spm.spatial.normalise.write.subj(jsubject).def=outputfiles{isubject}{nses}(5);
                    else        matlabbatch{end}.spm.spatial.normalise.write.subj(jsubject).matname=outputfiles{isubject}{nses}(5);
                    end
                    matlabbatch{end}.spm.spatial.normalise.write.subj(jsubject).resample=outputfiles{isubject}{nses}(1:4)';
                    outputfiles{isubject}{nses}=outputfiles{isubject}{nses}(1:4);
                    if applytofunctional
                        if CONN_x.Setup.structural_sessionspecific, nsesstrue=nses; 
                        else nsesstrue=1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject));
                        end
                        for nsestrue=nsesstrue
                            temp=cellstr(CONN_x.Setup.functional{nsubject}{nsestrue}{1});
                            if coregtomean, % keeps mean image in same space in case it is required later
                                [xtemp,failed]=conn_setup_preproc_meanimage(temp{1});
                                if ~isempty(xtemp),
                                    xtemp={xtemp};
                                    matlabbatch{end}.spm.spatial.normalise.write.subj(jsubject).resample=cat(1,matlabbatch{end}.spm.spatial.normalise.write.subj(jsubject).resample,xtemp);
                                end
                            end
                            matlabbatch{end}.spm.spatial.normalise.write.subj(jsubject).resample=cat(1,matlabbatch{end}.spm.spatial.normalise.write.subj(jsubject).resample,temp);
                            outputfiles{isubject}{nsestrue}{5}=char(conn_prepend('w',temp));
                        end
                    end
                    outputfiles{isubject}{nses}{1}=conn_prepend('w',outputfiles{isubject}{nses}{1});
                    outputfiles{isubject}{nses}{2}=conn_prepend('w',outputfiles{isubject}{nses}{2});
                    outputfiles{isubject}{nses}{3}=conn_prepend('w',outputfiles{isubject}{nses}{3});
                    outputfiles{isubject}{nses}{4}=conn_prepend('w',outputfiles{isubject}{nses}{4});
                end
            end
            jsubject=0;
            for isubject=1:numel(nsubjects),
                nsubject=nsubjects(isubject);
                if CONN_x.Setup.structural_sessionspecific, nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject)); else nsess=1; end
                for nses=1:nsess
                    jsubject=jsubject+1;
                    matlabbatch{end+1}.spm.util.imcalc.expression='(i2+i3+i4).*i1';
                    matlabbatch{end}.spm.util.imcalc.input=reshape(outputfiles{isubject}{nses}(1:4),[],1);
                    matlabbatch{end}.spm.util.imcalc.output=conn_prepend('wc0',CONN_x.Setup.structural{nsubject}{nses}{1});
                    matlabbatch{end}.spm.util.imcalc.options.dtype=spm_type('float32');
                    outputfiles{isubject}{nses}{1}=conn_prepend('wc0',CONN_x.Setup.structural{nsubject}{nses}{1});
                end
            end
            
        case 'functional_slicetime'
            sliceorder_all=sliceorder;
            if ~iscell(sliceorder_all),sliceorder_all={sliceorder_all}; end
            for isubject=1:numel(nsubjects),
                matlabbatch{end+1}.spm.temporal.st.scans={};
                if isubject<=numel(sliceorder_all), sliceorder=sliceorder_all{min(numel(sliceorder_all),isubject)}; end
                nsubject=nsubjects(isubject);
                nslice=CONN_x.Setup.functional{nsubject}{1}{3}(1).dim(3);
                nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject));
                for nses=1:nsess
                    temp=cellstr(CONN_x.Setup.functional{nsubject}{nses}{1});
                    if numel(temp)==1, 
                        temp=cellstr(conn_expandframe(temp{1}));
                    end
                    matlabbatch{end}.spm.temporal.st.scans{end+1}=temp;
                    outputfiles{isubject}{nses}=char(conn_prepend('a',cellstr(CONN_x.Setup.functional{nsubject}{nses}{1})));
                end
                matlabbatch{end}.spm.temporal.st.tr=CONN_x.Setup.RT(min(numel(CONN_x.Setup.RT),nsubject));
                matlabbatch{end}.spm.temporal.st.nslices=nslice;
                matlabbatch{end}.spm.temporal.st.ta=CONN_x.Setup.RT(min(numel(CONN_x.Setup.RT),nsubject))*(1-1/nslice);
                while (numel(unique(sliceorder))~=nslice||max(sliceorder)~=nslice||min(sliceorder)~=1) && (numel(sliceorder)~=nslice||any(sliceorder<0|sliceorder>CONN_x.Setup.RT(min(numel(CONN_x.Setup.RT),nsubject))*1000))
                    if isempty(sliceorder_select)
                        if ~isempty(sliceorder),
                            uiwait(warndlg({['Subject ',num2str(nsubject),' Incorrectly defined slice order vector'],['It should be a resorting of the values between 1 and ',num2str(nslice)]},''));
                            sliceorder_select=[];
                        end
                        if isempty(sliceorder_select)
                            [sliceorder_select,tok] = listdlg('PromptString',['Select slice order (subject ',num2str(nsubject),'):'],'SelectionMode','single','ListString',{'ascending','descending','interleaved (middle-top)','interleaved (bottom-up)','interleaved (top-down)','interleaved (Siemens)','manually define'});
                        end
                        if isempty(sliceorder_select), return; end
                    end
                    switch(sliceorder_select)
                        case 1, sliceorder=1:nslice;        % ascending
                        case 2, sliceorder=nslice:-1:1;     % descending
                        case 3, sliceorder=round((nslice-(1:nslice))/2 + (rem((nslice-(1:nslice)),2) * (nslice - 1)/2)) + 1; % interleaved (middle-top)
                        case 4, sliceorder=[1:2:nslice 2:2:nslice]; % interleaved (bottom-up)
                        case 5, sliceorder=[nslice:-2:1, nslice-1:-2:1]; % interleaved (top-down)
                        case 6, sliceorder=[fliplr(nslice:-2:1) fliplr(nslice-1:-2:1)]; % interleaved (Siemens)
                        case 7, % manually define
                            sliceorder=1:nslice;
                            sliceorder=inputdlg(['Slice order? (enter slice indexes from z=1 -first slice in image- to z=',num2str(nslice),' -last slice- in the order they were acquired). Alternatively enter acquisition time of each slice in milliseconds (e.g. for multiband sequences)'],'conn_setup_preproc',1,{sprintf('%d ',sliceorder)});
                            if isempty(sliceorder), return;
                            else sliceorder=str2num(regexprep(sliceorder{1},'[a-zA-Z]+',num2str(nslice)));
                            end
                    end
                    if (numel(unique(sliceorder))~=nslice||max(sliceorder)~=nslice||min(sliceorder)~=1) && (numel(sliceorder)~=nslice||any(sliceorder<0|sliceorder>CONN_x.Setup.RT(min(numel(CONN_x.Setup.RT),nsubject))*1000)), sliceorder_select=[]; end
                end
                matlabbatch{end}.spm.temporal.st.so=sliceorder;
                if (numel(unique(sliceorder))~=nslice||max(sliceorder)~=nslice||min(sliceorder)~=1), matlabbatch{end}.spm.temporal.st.refslice=mean(sliceorder); % slice timing (ms)
                else matlabbatch{end}.spm.temporal.st.refslice=sliceorder(floor(nslice/2)); % slice order
                end
            end
            
        case 'functional_realign'
            for isubject=1:numel(nsubjects),
                nsubject=nsubjects(isubject);
                matlabbatch{end+1}.spm.spatial.realign.estwrite.data={};
                nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject));
                for nses=1:nsess
                    temp=cellstr(CONN_x.Setup.functional{nsubject}{nses}{1});
                    temp1=temp{1};
                    matlabbatch{end}.spm.spatial.realign.estwrite.data{end+1}=temp;
                    outputfiles{isubject}{nses}{1}=char(conn_prepend('r',temp));
                    outputfiles{isubject}{nses}{2}=conn_prepend('rp_',temp1,'.txt');
                end
                matlabbatch{end}.spm.spatial.realign.estwrite.eoptions.rtm=0;
                matlabbatch{end}.spm.spatial.realign.estwrite.roptions.which=[2,1];
            end

        case 'functional_realign&unwarp'
            for isubject=1:numel(nsubjects),
                nsubject=nsubjects(isubject);
                matlabbatch{end+1}.spm.spatial.realignunwarp.eoptions.rtm=0;
                nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject));
                for nses=1:nsess
                    temp=cellstr(CONN_x.Setup.functional{nsubject}{nses}{1});
                    if numel(temp)==1, ttemp=cellstr(conn_expandframe(temp{1})); else ttemp=temp; end
                    matlabbatch{end}.spm.spatial.realignunwarp.data(nses).scans=ttemp;
                    outputfiles{isubject}{nses}{1}=char(conn_prepend('u',temp));
                    outputfiles{isubject}{nses}{2}=conn_prepend('rp_',temp{1},'.txt');
                end
            end
            
        case 'functional_realign&unwarp&phasemap'
            for isubject=1:numel(nsubjects),
                nsubject=nsubjects(isubject);
                matlabbatch{end+1}.spm.spatial.realignunwarp.eoptions.rtm=0;
                nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject));
                for nses=1:nsess
                    temp=cellstr(CONN_x.Setup.functional{nsubject}{nses}{1});
                    if numel(temp)==1, ttemp=cellstr(conn_expandframe(temp{1})); else ttemp=temp; end
                    if ~isempty(unwarp)&&iscell(unwarp)&&numel(unwarp)>=isubject&&numel(unwarp{isubject})>=nses
                        tmfile=unwarp{isubject}{nses};
                    elseif numel(CONN_x.Setup.unwarp_functional)>=nsubject&&numel(CONN_x.Setup.unwarp_functional{nsubject})>=nses
                        tmpfile=CONN_x.Setup.unwarp_functional{nsubject}{nses}{1};
                    else
                        tmfile=conn_prepend('vdm',ttemp{1});
                        if ~conn_existfile(tmfile)
                            tmfile=dir(fullfile(fileparts(ttemp{1}),'vdm*'));
                            if numel(tmfile)==1, tmfile=fullfile(fileparts(ttemp{1}),tmfile(1).name); else tmfile=''; end
                        end
                    end
                    if isempty(tmfile), tmfile=spm_select(1,'^vdm.*',['SUBJECT ',num2str(nsubject),'SESSION ',num2str(nses),' Phase Map volume (vdm*)'],{tmfile},fileparts(ttemp{1})); end
                    if isempty(fmfile),return;end
                    matlabbatch{end}.spm.spatial.realignunwarp.data(nses).scans=ttemp;
                    matlabbatch{end}.spm.spatial.realignunwarp.data(nses).pmscan={tmfile};
                    outputfiles{isubject}{nses}{1}=char(conn_prepend('u',temp));
                    outputfiles{isubject}{nses}{2}=conn_prepend('rp_',temp{1},'.txt');
                end
            end
        
        case 'functional_art'
            icov=find(strcmp(CONN_x.Setup.l1covariates.names(1:end-1),'realignment'));
            for isubject=1:numel(nsubjects),
                nsubject=nsubjects(isubject);
                matlabbatch{end+1}.art.P={};
                matlabbatch{end}.art.M={};
                matlabbatch{end}.art.global_threshold=art_global_threshold;
                matlabbatch{end}.art.motion_threshold=art_motion_threshold;
                matlabbatch{end}.art.use_diff_motion=art_use_diff_motion;
                matlabbatch{end}.art.use_diff_global=art_use_diff_global;
                matlabbatch{end}.art.use_norms=art_use_norms;
                matlabbatch{end}.art.drop_flag=art_drop_flag;
                nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject));
                for nses=1:nsess
                    temp=cellstr(CONN_x.Setup.functional{nsubject}{nses}{1});
                    temp1=temp{1};
                    matlabbatch{end}.art.P{end+1}=char(temp);
                    if isempty(icov), 
                        for remov=0:10,if conn_existfile(conn_prepend('rp_',conn_prepend(-remov,temp1),'.txt')); break; end; end
                        if remov==10, errmsg=['Error preparing files for ART processing. No ''realignment'' covariate; alternative realignment parameters file ',conn_prepend('rp_',temp1,'.txt'),' not found']; disp(errmsg); error(errmsg); end
                        matlabbatch{end}.art.M{end+1}=conn_prepend('rp_',conn_prepend(-remov,temp1),'.txt');
                        matlabbatch{end}.art.motion_file_type=0;
                    else
                        matlabbatch{end}.art.M{end+1}=CONN_x.Setup.l1covariates.files{nsubject}{icov}{nses}{1};
                        [nill,fname,fext]=fileparts(matlabbatch{end}.art.M{end});
                        matlabbatch{end}.art.motion_file_type=0;
                        if isequal(lower(fext),'.par'), matlabbatch{end}.art.motion_file_type=1;
                        elseif isequal(lower(fext),'.txt')&&~isempty(regexp(lower(fname),'\.siemens$')), matlabbatch{end}.art.motion_file_type=2; 
                        elseif isequal(lower(fext),'.txt')&&~isempty(regexp(lower(fname),'\.deg$')), matlabbatch{end}.art.motion_file_type=3; 
                        end
                    end
                    outputfiles{isubject}{nses}=conn_prepend('art_regression_outliers_',temp1,'.mat');
                    if nses==1, matlabbatch{end}.art.output_dir=fileparts(temp1); end
                end
            end
            
        case 'functional_coregister'
            jsubject=0;
            for isubject=1:numel(nsubjects),
                nsubject=nsubjects(isubject);
                if CONN_x.Setup.structural_sessionspecific, nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject)); else nsess=1; end
                for nses=1:nsess
                    jsubject=jsubject+1;
                    temp=cellstr(CONN_x.Setup.functional{nsubject}{1}{1});
                    if numel(temp)==1, ttemp=cellstr(conn_expandframe(temp{1})); else ttemp=temp; end
                    if coregtomean,
                        [xtemp,failed]=conn_setup_preproc_meanimage(temp{1});
                        if isempty(xtemp),  errmsg=['Error preparing files for coregistration. Mean functional file ',failed,' not found']; disp(errmsg); error(errmsg); end
                        xtemp={xtemp};
                    else xtemp=ttemp(1);
                    end
                    matlabbatch{end+1}.spm.spatial.coreg.estimate.source=xtemp;
                    matlabbatch{end}.spm.spatial.coreg.estimate.ref=CONN_x.Setup.structural{nsubject}{nses}(1);
                    if coregtomean, matlabbatch{end}.spm.spatial.coreg.estimate.other=xtemp;
                    else matlabbatch{end}.spm.spatial.coreg.estimate.other={};
                    end
                    if CONN_x.Setup.structural_sessionspecific, nsesstrue=nses;
                    else nsesstrue=1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject));
                    end
                    for nsestrue=nsesstrue
                        temp=cellstr(CONN_x.Setup.functional{nsubject}{nsestrue}{1});
                        if numel(temp)==1, ttemp=cellstr(conn_expandframe(temp{1})); else ttemp=temp; end
                        matlabbatch{end}.spm.spatial.coreg.estimate.other=cat(1,matlabbatch{end}.spm.spatial.coreg.estimate.other,ttemp);
                    end
                end
            end
            
        case 'functional_segment'
            DOSPM12=~PREFERSPM8OVERSPM12&spmver12; %SPM12/SPM8
            if DOSPM12, matlabbatch{end+1}.spm.spatial.preproc.channel.vols={};
            else matlabbatch{end+1}.spm.spatial.preproc.data={};
            end
            for isubject=1:numel(nsubjects),
                nsubject=nsubjects(isubject);
                temp=cellstr(CONN_x.Setup.functional{nsubject}{1}{1});
                if numel(temp)==1, ttemp=cellstr(conn_expandframe(temp{1})); else ttemp=temp; end
                if coregtomean,
                    [xtemp,failed]=conn_setup_preproc_meanimage(temp{1});
                    if isempty(xtemp),  errmsg=['Error preparing files for normalization. Mean functional file ',failed,' not found']; disp(errmsg); error(errmsg); end
                    xtemp={xtemp};
                else xtemp=ttemp(1);
                end
                if DOSPM12, 
                    matlabbatch{end}.spm.spatial.preproc.channel.vols{isubject}=xtemp{1};
                    outputfiles{isubject}{1}=xtemp{1};
                    outputfiles{isubject}{2}=conn_prepend('c1',xtemp{1},'.nii'); % note: fix SPM12 issue converting .img to .nii
                    outputfiles{isubject}{3}=conn_prepend('c2',xtemp{1},'.nii');
                    outputfiles{isubject}{4}=conn_prepend('c3',xtemp{1},'.nii');
                else
                    matlabbatch{end}.spm.spatial.preproc.data{isubject}=xtemp{1};
                    outputfiles{isubject}{1}=xtemp{1};
                    outputfiles{isubject}{2}=conn_prepend('c1',xtemp{1});
                    outputfiles{isubject}{3}=conn_prepend('c2',xtemp{1});
                    outputfiles{isubject}{4}=conn_prepend('c3',xtemp{1});
                end
            end
            if DOSPM12, 
                if ~isempty(tpm_template), 
                    temp=cellstr(conn_expandframe(tpm_template));
                    if isempty(tpm_ngaus), tpm_ngaus=[1 1 2 3 4 2]; end % grey/white/CSF/bone/soft/air
                    for n=1:numel(temp)
                        matlabbatch{end}.spm.spatial.preproc.tissue(n)=struct('tpm',{temp(n)},'ngaus',tpm_ngaus(n),'native',[1 0],'warped',[0 0]);
                    end
                end
                matlabbatch{end}.spm.spatial.preproc.channel.vols=reshape(matlabbatch{end}.spm.spatial.preproc.channel.vols,[],1);
                matlabbatch{end}.spm.spatial.preproc.warp.write=[1 1];
            else 
                if ~isempty(tpm_template), 
                    temp=cellstr(conn_expandframe(tpm_template));
                    if isempty(tpm_ngaus), tpm_ngaus=[2 2 2 4]; end % grey/white/CSF (+other implicit)
                    matlabbatch{end}.spm.spatial.preproc.opts.tpm=temp;
                    matlabbatch{end}.spm.spatial.preproc.opts.ngaus=ngaus(1:numel(temp)+1);
                end
                matlabbatch{end}.spm.spatial.preproc.roptions.bb=boundingbox;
                matlabbatch{end}.spm.spatial.preproc.output.GM=[0,0,1];
                matlabbatch{end}.spm.spatial.preproc.output.WM=[0,0,1];
                matlabbatch{end}.spm.spatial.preproc.output.CSF=[0,0,1];
            end
            
        case 'functional_normalize'
            DOSPM12=~PREFERSPM8OVERSPM12&spmver12; %SPM12/SPM8
            if DOSPM12
                %note: functional_template disregarded (using tissue probability maps instead)
                matlabbatch{end+1}.spm.spatial.normalise.estwrite.woptions.bb=boundingbox;
                matlabbatch{end}.spm.spatial.normalise.estwrite.woptions.vox=voxelsize*[1 1 1];
                if ~isempty(tpm_template), matlabbatch{end}.spm.spatial.normalise.estwrite.eoptions.tpm=reshape(cellstr(tpm_template),[],1); end
            else
                %note: tissue probability maps disregarded (using functional_template instead)
                matlabbatch{end+1}.spm.spatial.normalise.estwrite.roptions.bb=boundingbox;
                matlabbatch{end}.spm.spatial.normalise.estwrite.roptions.vox=voxelsize*[1 1 1];
                matlabbatch{end}.spm.spatial.normalise.estwrite.eoptions.template={functional_template};
            end
            for isubject=1:numel(nsubjects),
                nsubject=nsubjects(isubject);
                temp=cellstr(CONN_x.Setup.functional{nsubject}{1}{1});
                if numel(temp)==1, ttemp=cellstr(conn_expandframe(temp{1})); else ttemp=temp; end
                if coregtomean,
                    [xtemp,failed]=conn_setup_preproc_meanimage(temp{1});
                    if isempty(xtemp),  errmsg=['Error preparing files for normalization. Mean functional file ',failed,' not found']; disp(errmsg); error(errmsg); end
                    xtemp={xtemp};
                else xtemp=ttemp(1);
                end
                if DOSPM12, matlabbatch{end}.spm.spatial.normalise.estwrite.subj(isubject).vol=xtemp;
                else        matlabbatch{end}.spm.spatial.normalise.estwrite.subj(isubject).source=xtemp;
                end
                nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject));
                if coregtomean, matlabbatch{end}.spm.spatial.normalise.estwrite.subj(isubject).resample=xtemp;
                else matlabbatch{end}.spm.spatial.normalise.estwrite.subj(isubject).resample={};
                end
                for nses=1:nsess
                    temp=cellstr(CONN_x.Setup.functional{nsubject}{nses}{1});
                    if numel(temp)==1, ttemp=cellstr(conn_expandframe(temp{1})); else ttemp=temp; end
                    matlabbatch{end}.spm.spatial.normalise.estwrite.subj(isubject).resample=cat(1,matlabbatch{end}.spm.spatial.normalise.estwrite.subj(isubject).resample,ttemp);
                    outputfiles{isubject}{nses}=char(conn_prepend('w',temp));
                end
            end
            
        case 'functional_segment&normalize'
            DOSPM12=~PREFERSPM8OVERSPM12&spmver12; %SPM12/SPM8
            if DOSPM12, matlabbatch{end+1}.spm.spatial.preproc.channel.vols={};
            else matlabbatch{end+1}.spm.spatial.preproc.data={};
            end
            for isubject=1:numel(nsubjects),
                nsubject=nsubjects(isubject);
                temp=cellstr(CONN_x.Setup.functional{nsubject}{1}{1});
                if numel(temp)==1, ttemp=cellstr(conn_expandframe(temp{1})); else ttemp=temp; end
                if coregtomean,
                    [xtemp,failed]=conn_setup_preproc_meanimage(temp{1});
                    if isempty(xtemp),  errmsg=['Error preparing files for normalization. Mean functional file ',failed,' not found']; disp(errmsg); error(errmsg); end
                    xtemp={xtemp};
                else xtemp=ttemp(1);
                end
                if DOSPM12, 
                    matlabbatch{end}.spm.spatial.preproc.channel.vols{isubject}=xtemp{1};
                    outputfiles{isubject}{1}=xtemp{1};
                    outputfiles{isubject}{2}=conn_prepend('c1',xtemp{1},'.nii'); % note: fix SPM12 issue converting .img to .nii
                    outputfiles{isubject}{3}=conn_prepend('c2',xtemp{1},'.nii');
                    outputfiles{isubject}{4}=conn_prepend('c3',xtemp{1},'.nii');
                    outputfiles{isubject}{5}=conn_prepend('y_',xtemp{1},'.nii');
                else
                    matlabbatch{end}.spm.spatial.preproc.data{isubject}=xtemp{1};
                    outputfiles{isubject}{1}=xtemp{1};
                    outputfiles{isubject}{2}=conn_prepend('c1',xtemp{1});
                    outputfiles{isubject}{3}=conn_prepend('c2',xtemp{1});
                    outputfiles{isubject}{4}=conn_prepend('c3',xtemp{1});
                    outputfiles{isubject}{5}=conn_prepend('y_',xtemp{1});
                end
            end
            if DOSPM12, 
                if ~isempty(tpm_template), 
                    temp=cellstr(conn_expandframe(tpm_template));
                    if isempty(tpm_ngaus), tpm_ngaus=[1 1 2 3 4 2]; end % grey/white/CSF/bone/soft/air
                    for n=1:numel(temp)
                        matlabbatch{end}.spm.spatial.preproc.tissue(n)=struct('tpm',{temp(n)},'ngaus',tpm_ngaus(n),'native',[1 0],'warped',[1 0]);
                    end
                end
                matlabbatch{end}.spm.spatial.preproc.channel.vols=reshape(matlabbatch{end}.spm.spatial.preproc.channel.vols,[],1);
                matlabbatch{end}.spm.spatial.preproc.warp.write=[1 1];
                matlabbatch{end+1}.spm.spatial.normalise.write.woptions.bb=boundingbox;
                matlabbatch{end}.spm.spatial.normalise.write.woptions.vox=voxelsize*[1 1 1];
            else 
                if ~isempty(tpm_template), 
                    temp=cellstr(conn_expandframe(tpm_template));
                    if isempty(tpm_ngaus), tpm_ngaus=[2 2 2 4]; end % grey/white/CSF (+other implicit)
                    matlabbatch{end}.spm.spatial.preproc.opts.tpm=temp;
                    matlabbatch{end}.spm.spatial.preproc.opts.ngaus=ngaus(1:numel(temp)+1);
                end
                matlabbatch{end}.spm.spatial.preproc.roptions.bb=boundingbox;
                matlabbatch{end}.spm.spatial.preproc.output.GM=[0,0,1];
                matlabbatch{end}.spm.spatial.preproc.output.WM=[0,0,1];
                matlabbatch{end}.spm.spatial.preproc.output.CSF=[0,0,1];
                matlabbatch{end+1}.spm.spatial.normalise.write.roptions.bb=boundingbox;
                matlabbatch{end}.spm.spatial.normalise.write.roptions.vox=voxelsize*[1 1 1];
            end
            for isubject=1:numel(nsubjects),
                nsubject=nsubjects(isubject);
                if DOSPM12, matlabbatch{end}.spm.spatial.normalise.write.subj(isubject).def=outputfiles{isubject}(5);
                else        matlabbatch{end}.spm.spatial.normalise.write.subj(isubject).matname={conn_prepend('',outputfiles{isubject}{1},'_seg_sn.mat')};
                end
                matlabbatch{end}.spm.spatial.normalise.write.subj(isubject).resample=outputfiles{isubject}(1:4)';
                outputfiles{isubject}=outputfiles{isubject}(1:4);
                
                nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject));
                for nses=1:nsess
                    temp=cellstr(CONN_x.Setup.functional{nsubject}{nses}{1});
                    if numel(temp)==1, ttemp=cellstr(conn_expandframe(temp{1})); else ttemp=temp; end
                    matlabbatch{end}.spm.spatial.normalise.write.subj(isubject).resample=cat(1,matlabbatch{end}.spm.spatial.normalise.write.subj(isubject).resample,ttemp);
                    outputfiles{isubject}{4+nses}=char(conn_prepend('w',temp));
                end
                outputfiles{isubject}{1}=conn_prepend('w',outputfiles{isubject}{1});
                outputfiles{isubject}{2}=conn_prepend('w',outputfiles{isubject}{2});
                outputfiles{isubject}{3}=conn_prepend('w',outputfiles{isubject}{3});
                outputfiles{isubject}{4}=conn_prepend('w',outputfiles{isubject}{4});
            end
            
        case 'functional_smooth'
            if isempty(fwhm)
                fwhm=inputdlg('Enter smoothing FWHM (in mm)','conn_setup_preproc',1,{num2str(8)});
                if isempty(fwhm), return; end
                fwhm=str2num(fwhm{1});
            end
            matlabbatch{end+1}.spm.spatial.smooth.fwhm=[1 1 1].*fwhm;
            matlabbatch{end}.spm.spatial.smooth.data={};
            for isubject=1:numel(nsubjects),
                nsubject=nsubjects(isubject);
                temp=cellstr(CONN_x.Setup.functional{nsubject}{1}{1});
                nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject));
                for nses=1:nsess
                    temp=cellstr(CONN_x.Setup.functional{nsubject}{nses}{1});
                    matlabbatch{end}.spm.spatial.smooth.data=cat(1,matlabbatch{end}.spm.spatial.smooth.data,temp);
                    outputfiles{isubject}{nses}=char(conn_prepend('s',temp));
                end
            end
            
        otherwise
            error(['unrecognized option ',STEP]);
    end
    
    if dogui&&ishandle(hmsg), delete(hmsg); end
    hmsg=[];
    if strncmp(lower(STEP),'interactive_',numel('interactive_'))
        doimport=false;
        if any(strcmpi(regexprep(lower(STEP),'^run_|^update_|^interactive_',''),{'functional_art'}))
            for n=1:numel(matlabbatch)
                conn_art('sess_file',matlabbatch{n}.art);
            end
        elseif any(strcmpi(regexprep(lower(STEP),'^run_|^update_|^interactive_',''),{'functional_removescans','functional_manualorient','structural_manualorient','functional_center','structural_center'}))
        else
            try
                spm_jobman('initcfg');
                job_id=spm_jobman('interactive',matlabbatch);
                % outputs=cfg_util('getAllOutputs', job_id)
            catch
                ok=-1;
            end
        end
    else %if strncmp(lower(STEP),'run_',numel('run_'))
        if dogui, hmsg=conn_msgbox({['Performing ',STEP_name],'Please wait...'},'');
        else disp(['Performing ',STEP_name,'. Please wait...']);
        end
        if any(strcmpi(regexprep(lower(STEP),'^run_|^interactive_',''),{'functional_art'}))
            for n=1:numel(matlabbatch)
                h=conn_art('sess_file',matlabbatch{n}.art);
                if strcmp(get(h,'name'),'art'), %close(h);
                elseif strcmp(get(gcf,'name'),'art'), h=gcf;%close(gcf);
                else h=findobj(0,'name','art'); %close(h); 
                end
                if art_force_interactive, uiwait(h); 
                else
                    try
                        if isfield(matlabbatch{n}.art,'output_dir')
                            figure(h);
                            conn_print(fullfile(matlabbatch{n}.art.output_dir,'art_screenshot.jpg'),'-nogui');
                        end
                        close(h);
                    end
                end
            end
        elseif any(strcmpi(regexprep(lower(STEP),'^run_|^update_|^interactive_',''),{'functional_removescans','functional_manualorient','structural_manualorient','structural_manualorient','functional_center','structural_center'}))
        elseif strncmp(lower(STEP),'update_',numel('update_'))
        else
            spm_jobman('initcfg');
            debugskip=false;
            if ~debugskip
                job_id=spm_jobman('run',matlabbatch);
            end
        end
        if dogui&&ishandle(hmsg), delete(hmsg);
        else disp(['Done ',STEP_name]);
        end
        ok=1;
    end
    if ishandle(hmsg), delete(hmsg); end
    
    if ok>=0&&doimport
        if dogui, hmsg=conn_msgbox({'Importing results to CONN project','Please wait...'},'');
        else disp(['Importing results to CONN project. Please wait...']);
        end
        switch(regexprep(lower(STEP),'^run_|^update_|^interactive_',''))
            case 'functional_removescans'
                for isubject=1:numel(nsubjects),
                    nsubject=nsubjects(isubject);
                    nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject));
                    for nses=1:numel(outputfiles{isubject})
                        [CONN_x.Setup.functional{nsubject}{nses},V]=conn_file(outputfiles{isubject}{nses});
                        CONN_x.Setup.nscans{nsubject}{nses}=numel(V);
                    end
                end
                
            case 'functional_manualorient'
                if iscell(reorient), treorient=reorient{1}; reorient=reorient(2:end); 
                else treorient=reorient; 
                end
                for isubject=1:numel(nsubjects),
                    nsubject=nsubjects(isubject);
                    nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject));
                    translation=[];
                    for nses=1:nsess
                        temp=cellstr(CONN_x.Setup.functional{nsubject}{nses}{1});
                        if numel(temp)==1,
                            temp=cellstr(conn_expandframe(temp{1}));
                        end
                        if coregtomean, % keeps mean image in same space in case it is required later
                            [xtemp,failed]=conn_setup_preproc_meanimage(temp{1});
                            if ~isempty(xtemp), temp=[{xtemp};temp]; end
                        end
                        M=cell(1,numel(temp));
                        for n=1:numel(temp)
                            M{n}=spm_get_space(temp{n});
                            if isnan(treorient)
                                if isempty(translation)
                                    translation=-M{n}(1:3,1:3)*CONN_x.Setup.functional{nsubject}{nses}{3}(1).dim'/2 - M{n}(1:3,4);
                                end
                                M{n}(1:3,4)=M{n}(1:3,4)+translation;
                            else
                                M{n}=[treorient zeros(3,1); zeros(1,3) 1]*M{n};
                            end
                        end
                        for n=1:numel(temp)
                            spm_get_space(temp{n},M{n});
                        end
                        [CONN_x.Setup.functional{nsubject}{nses},V]=conn_file(CONN_x.Setup.functional{nsubject}{nses}{1});
                    end
                end
                
            case 'structural_manualorient'
                if iscell(reorient), treorient=reorient{1}; reorient=reorient(2:end); 
                else treorient=reorient; 
                end
                jsubject=0;
                for isubject=1:numel(nsubjects),
                    nsubject=nsubjects(isubject);
                    if CONN_x.Setup.structural_sessionspecific, nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject)); else nsess=1; end
                    for nses=1:nsess
                        jsubject=jsubject+1;
                        temp=CONN_x.Setup.structural{nsubject}{nses}{1};
                        M=spm_get_space(temp);
                        if isnan(treorient)
                            M(1:3,4)=-M(1:3,1:3)*CONN_x.Setup.structural{nsubject}{nses}{3}(1).dim'/2;
                        else
                            M=[treorient zeros(3,1); zeros(1,3) 1]*M;
                        end
                        spm_get_space(temp,M);
                        [CONN_x.Setup.structural{nsubject}{nses},V]=conn_file(CONN_x.Setup.structural{nsubject}{nses}{1});
                    end
                    if ~CONN_x.Setup.structural_sessionspecific, CONN_x.Setup.structural{nsubject}(2:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject)))=CONN_x.Setup.structural{nsubject}(1); end
                end
                
            case 'functional_center'
                treorient=nan;
                for isubject=1:numel(nsubjects),
                    nsubject=nsubjects(isubject);
                    nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject));
                    translation=[];
                    for nses=1:nsess
                        temp=cellstr(CONN_x.Setup.functional{nsubject}{nses}{1});
                        if numel(temp)==1,
                            temp=cellstr(conn_expandframe(temp{1}));
                        end
                        if coregtomean, % keeps mean image in same space in case it is required later
                            [xtemp,failed]=conn_setup_preproc_meanimage(temp{1});
                            if ~isempty(xtemp), temp=[{xtemp};temp]; end
                        end
                        M=cell(1,numel(temp));
                        for n=1:numel(temp)
                            M{n}=spm_get_space(temp{n});
                            if isnan(treorient)
                                if isempty(translation)
                                    translation=-M{n}(1:3,1:3)*CONN_x.Setup.functional{nsubject}{nses}{3}(1).dim'/2 - M{n}(1:3,4);
                                end
                                M{n}(1:3,4)=M{n}(1:3,4)+translation;
                            else
                                M{n}=[treorient zeros(3,1); zeros(1,3) 1]*M{n};
                            end
                        end
                        for n=1:numel(temp)
                            spm_get_space(temp{n},M{n});
                        end
                        [CONN_x.Setup.functional{nsubject}{nses},V]=conn_file(CONN_x.Setup.functional{nsubject}{nses}{1});
                    end
                end
                
            case 'structural_center'
                treorient=nan;
                jsubject=0;
                for isubject=1:numel(nsubjects),
                    nsubject=nsubjects(isubject);
                    if CONN_x.Setup.structural_sessionspecific, nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject)); else nsess=1; end
                    for nses=1:nsess
                        jsubject=jsubject+1;
                        temp=CONN_x.Setup.structural{nsubject}{nses}{1};
                        M=spm_get_space(temp);
                        if isnan(treorient)
                            M(1:3,4)=-M(1:3,1:3)*CONN_x.Setup.structural{nsubject}{nses}{3}(1).dim'/2;
                        else
                            M=[treorient zeros(3,1); zeros(1,3) 1]*M;
                        end
                        spm_get_space(temp,M);
                        [CONN_x.Setup.structural{nsubject}{nses},V]=conn_file(CONN_x.Setup.structural{nsubject}{nses}{1});
                    end
                    if ~CONN_x.Setup.structural_sessionspecific, CONN_x.Setup.structural{nsubject}(2:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject)))=CONN_x.Setup.structural{nsubject}(1); end
                end
                
            case 'structural_segment'
                for isubject=1:numel(nsubjects),
                    nsubject=nsubjects(isubject);
                    nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject)); 
                    if CONN_x.Setup.structural_sessionspecific, nsesstemp=nsess; else nsesstemp=1; end
                    for nses=1:nsess
                        CONN_x.Setup.structural{nsubject}{nses}=conn_file(outputfiles{isubject}{min(nses,nsesstemp)}{1});
                        CONN_x.Setup.rois.files{nsubject}{1}{nses}=conn_file(outputfiles{isubject}{min(nses,nsesstemp)}{2});
                        CONN_x.Setup.rois.files{nsubject}{2}{nses}=conn_file(outputfiles{isubject}{min(nses,nsesstemp)}{3});
                        CONN_x.Setup.rois.files{nsubject}{3}{nses}=conn_file(outputfiles{isubject}{min(nses,nsesstemp)}{4});
                    end
                end
                
            case 'structural_segment&normalize'
                for isubject=1:numel(nsubjects),
                    nsubject=nsubjects(isubject);
                    nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject)); 
                    if CONN_x.Setup.structural_sessionspecific, nsesstemp=nsess; else nsesstemp=1; end
                    for nses=1:nsess
                        CONN_x.Setup.structural{nsubject}{nses}=conn_file(outputfiles{isubject}{min(nses,nsesstemp)}{1});
                        CONN_x.Setup.rois.files{nsubject}{1}{nses}=conn_file(outputfiles{isubject}{min(nses,nsesstemp)}{2});
                        CONN_x.Setup.rois.files{nsubject}{2}{nses}=conn_file(outputfiles{isubject}{min(nses,nsesstemp)}{3});
                        CONN_x.Setup.rois.files{nsubject}{3}{nses}=conn_file(outputfiles{isubject}{min(nses,nsesstemp)}{4});
                        if applytofunctional, CONN_x.Setup.functional{nsubject}{nses}=conn_file(outputfiles{isubject}{nses}{5}); end
                    end
                end

            case 'structural_normalize'
                for isubject=1:numel(nsubjects),
                    nsubject=nsubjects(isubject);
                    nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject)); 
                    if CONN_x.Setup.structural_sessionspecific, nsesstemp=nsess; else nsesstemp=1; end
                    for nses=1:nsess
                        CONN_x.Setup.structural{nsubject}{nses}=conn_file(outputfiles{isubject}{min(nses,nsesstemp)}{1});
                        if applytofunctional, CONN_x.Setup.functional{nsubject}{nses}=conn_file(outputfiles{isubject}{nses}{5}); end
                    end
                end
                
            case 'functional_segment'
                for isubject=1:numel(nsubjects),
                    nsubject=nsubjects(isubject);
                    nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject)); 
                    if CONN_x.Setup.structural_sessionspecific, nsesstemp=nsess; else nsesstemp=1; end
                    for nses=1:nsess
                        CONN_x.Setup.rois.files{nsubject}{1}{nses}=conn_file(outputfiles{isubject}{min(nses,nsesstemp)}{2});
                        CONN_x.Setup.rois.files{nsubject}{2}{nses}=conn_file(outputfiles{isubject}{min(nses,nsesstemp)}{3});
                        CONN_x.Setup.rois.files{nsubject}{3}{nses}=conn_file(outputfiles{isubject}{min(nses,nsesstemp)}{4});
                    end
                end
                
            case 'functional_segment&normalize'
                for isubject=1:numel(nsubjects),
                    nsubject=nsubjects(isubject);
                    nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject)); 
                    for nses=1:nsess
                        CONN_x.Setup.rois.files{nsubject}{1}{nses}=conn_file(outputfiles{isubject}{2});
                        CONN_x.Setup.rois.files{nsubject}{2}{nses}=conn_file(outputfiles{isubject}{3});
                        CONN_x.Setup.rois.files{nsubject}{3}{nses}=conn_file(outputfiles{isubject}{4});
                    end
                    for nses=1:numel(outputfiles{isubject})-4
                        CONN_x.Setup.functional{nsubject}{nses}=conn_file(outputfiles{isubject}{4+nses});
                    end
                end
                
            case {'functional_slicetime','functional_normalize','functional_smooth'}
                for isubject=1:numel(nsubjects),
                    nsubject=nsubjects(isubject);
                    nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject));
                    for nses=1:numel(outputfiles{isubject})
                        CONN_x.Setup.functional{nsubject}{nses}=conn_file(outputfiles{isubject}{nses});
                    end
                end
                
            case 'functional_art'
                icov=find(strcmp(CONN_x.Setup.l1covariates.names(1:end-1),'scrubbing'));
                if isempty(icov),
                    icov=numel(CONN_x.Setup.l1covariates.names);
                    CONN_x.Setup.l1covariates.names{icov}='scrubbing';
                    CONN_x.Setup.l1covariates.names{icov+1}=' ';
                end
                for isubject=1:numel(nsubjects),
                    nsubject=nsubjects(isubject);
                    nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject));
                    for nses=1:numel(outputfiles{isubject})
                        CONN_x.Setup.l1covariates.files{nsubject}{icov}{nses}=conn_file(outputfiles{isubject}{nses});
                    end
                end
                
            case {'functional_realign','functional_realign&unwarp','functional_realign&unwarp&phasemap'}
                icov=find(strcmp(CONN_x.Setup.l1covariates.names(1:end-1),'realignment'));
                if isempty(icov),
                    icov=numel(CONN_x.Setup.l1covariates.names);
                    CONN_x.Setup.l1covariates.names{icov}='realignment';
                    CONN_x.Setup.l1covariates.names{icov+1}=' ';
                end
                for isubject=1:numel(nsubjects),
                    nsubject=nsubjects(isubject);
                    nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject));
                    for nses=1:numel(outputfiles{isubject})
                        CONN_x.Setup.functional{nsubject}{nses}=conn_file(outputfiles{isubject}{nses}{1});
                        CONN_x.Setup.l1covariates.files{nsubject}{icov}{nses}=conn_file(outputfiles{isubject}{nses}{2});
                    end
                end
                
            case 'functional_coregister' % info written to same files header
                for isubject=1:numel(nsubjects),
                    nsubject=nsubjects(isubject);
                    nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject));
                    for nses=1:nsess
                        CONN_x.Setup.functional{nsubject}{nses}=conn_file(CONN_x.Setup.functional{nsubject}{nses}{1});
                    end
                end
        end
        if dogui&&ishandle(hmsg), delete(hmsg); end
        ok=2;
        conn save;
    end
    
    if ok<0, return; end
end
end


function conn_setup_preproc_update(hdl)
   if ~nargin, hdl=gcbo; end
   dlg=get(hdl,'userdata');
   val=get(dlg.m0,'value');
   str=get(dlg.m0,'string'); 
   %if any(ismember(cat(1,str(val),get(dlg.m7,'string')),{'structural Segmentation & Normalization','structural Normalization'})), 
   if any(ismember(str(val),{'structural Segmentation & Normalization','structural Normalization'})), 
       set(dlg.m3,'visible','on'); 
   else set(dlg.m3,'visible','off'); 
   end
   %if any(ismember(cat(1,str(val),get(dlg.m7,'string')),{'functional Coregistration to structural','functional Normalization','functional Segmentation & Normalization','functional Segmentation'})), 
   if any(ismember(str(val),{'functional Coregistration to structural','functional Normalization','functional Segmentation & Normalization','functional Segmentation'})), 
       set(dlg.m4,'visible','on'); 
   else set(dlg.m4,'visible','off'); 
   end; 
   set(dlg.m6,'string',dlg.steps_descr{val});
   if get(dlg.m1,'value'), set(dlg.m5,'visible','off'); 
   else set(dlg.m5,'visible','on'); 
   end
   if ~isempty(dlg.m7)&&isempty(get(dlg.m7,'string')), set(dlg.m11,'enable','off'); else set(dlg.m11,'enable','on'); end
end

function [fileout,filetested]=conn_setup_preproc_meanimage(filename)
% potential "mean" volume in register to functional data volume filename
[file_path,file_name,file_ext,file_num]=spm_fileparts(filename);
% [PREFIX r BASENAME] -> [PREFIX(minus 'a' or 's') mean BASENAME]
idx1=find(file_name=='r');
ok1=false(size(idx1));
str1=cell(size(idx1));
for n=1:numel(idx1), 
    str1{n}=fullfile(file_path,[regexprep(file_name(1:idx1(n)-1),'[as]','') 'mean' file_name(idx1(n)+1:end) file_ext]);
    if conn_existfile(str1{n}), ok1(n)=true; end
end
% [PREFIX u BASENAME] -> [PREFIX(minus 'a' or 's') meanu BASENAME]
idx2=find(file_name=='u');
ok2=false(size(idx2));
str2=cell(size(idx2));
for n=1:numel(idx2), 
    str2{n}=fullfile(file_path,[regexprep(file_name(1:idx2(n)-1),'[as]','') 'mean' file_name(idx2(n):end) file_ext]);
    if conn_existfile(str2{n}), ok2(n)=true; end 
end
i1=find(ok1,1);
i2=find(ok2,1);
min1=idx1(i1);
min2=idx2(i2);
if isempty(min1)&&isempty(min2),   fileout=[];
elseif isempty(min1),              fileout=str2{i2};
elseif isempty(min2),              fileout=str1{i1};
elseif min2<min1,                  fileout=str2{i2};
else                               fileout=str1{i1};
end
if isempty(str1)&&isempty(str2),   filetested=filename;
elseif isempty(str1),              filetested=str2{1};
elseif isempty(str2),              filetested=str1{1};
elseif idx2(1)<idx1(1),            filetested=str2{1};
else                               filetested=str1{1};
end
end



