function conn_batch(varargin)
% CONN BATCH batch functionality for connectivity toolbox
% 
% Defines experiment information and/or run processing steps programmatically
% 
% CONN_BATCH syntax:
% 
% 1) conn_batch(BATCH);
%    where BATCH is a structure (with fields defined in the section below)
%    e.g. 
%       clear BATCH;
%       BATCH.Setup.RT=2;
%       conn_batch(BATCH);
% 
% 2) conn_batch('fieldname1',fieldvalue1,'fieldname2',fieldvalue2,...) 
%    where 'fieldname*' are individual BATCH structure fields
%    e.g. 
%       conn_batch('Setup.RT',2); 
% 
% 3) conn_batch(batchfilename)
%    where batchfilename is a .mat file containing a batch structure
%    or a .m file containing a Matlab script
%    e.g.
%       conn_batch('mybatchfile.mat');
%
% note: in standalone releases use syntax (from system-prompt):
%     conn batch batchfilename    : runs a batch file (.m or .mat)
%     conn batch "matlabcommands" : runs one or several matlab commands 
%
%_________________________________________________________________________________________________________________________________________________
% 
% BATCH structure fields:
% 
%  filename          : conn_*.mat project file (defaults to currently open project)
%  parallel          : Parallelization options (defaults to local procesing / no parallelization)
%  subjects          : Subset of subjects to run processing steps or define parameters for (defaults to all subjects)
%  Setup             : Information/processes regarding experiment Setup and Preprocessing
%  Denoising         : Information/processes regarding Denoising step
%  Analysis          : Information/processes regarding first-level analyses
%  Results           : Information/processes regarding second-level analysis/results
% 
% 
% BATCH.parallel DEFINES PARALLELIZATION OPTIONS (applies to any Setup/Setup.preprocessing/Denoising/Analysis steps) %!
%  parallel            
% 
%    N               : Number of parallel jobs; 0 to run locally ([0])
%    profile         : (when parallel.N>0) Name of parallelization profile (defaults to profile marked as default in GUI.Tools.GridSettings) (the command "conn_jobmanager profiles" shows the list of available profiles, or use GUI Tools.GridSettings to add/edit profiles)
% 
% 
% BATCH.Setup DEFINES EXPERIMENT SETUP AND PERFORMS INITIAL DATA EXTRACTION AND/OR PREPROCESSING STEPS %!
%  Setup               
% 
%    isnew           : 1/0 is this a new conn project [0]
%    done            : 1/0: 0 defines fields only; 1 runs SETUP processing steps [0]
%    overwrite       : (for done=1) 1/0 overwrites target files if they exist [1]
% 
%    nsubjects       : Number of subjects
%    RT              : Repetition time (seconds) [2]
%    acquisitiontype : 1/0: Continuous acquisition of functional volumes [1] 
% 
%    functionals     : functionals{nsub}{nses} char array of functional volume files (for voxel-level analyses; see roifunctionals below) 
%    structurals     : structurals{nsub} char array of structural volume files 
%                      OR structurals{nsub}{nses} char array of anatomical session-specific volume files 
%    roifunctionals  : (for Setup.rois.roiextract>0) structure array identifying one or several additional functional datasets for ROI-level timeseries extraction (e.g. to specify the location of unsmoothed functional volumes, functional volumes coregistered to specific ROIs, etc.) (default roifunctionals.roiextract=2)
%       roiextract            : Source of functional data: 1: same as 'Setup.functionals' field; 2: same as 'Setup.functionals' field after removing leading 's' from filename; 3: other (same as 'Setup.functionals' field but using alternative filename-change rule; see roiextract_rule below and help conn_rulebasedfilename); 4: other (explicitly specify the functional volume files; see roiextract_functionals below) [2] 
%       roiextract_rule       : (for roiextract==3) regexprep(filename,roiextract_rule{2},roiextract_rule{3}) converts filenames in 'Setup.functionals' field to filenames that will be used when extracting BOLD signal ROI timeseries (if roiextract_rule{1}==2 filename is interpreted as a full path; if roiextract_rule{1}==1 filename is interpreted as only the file *name* -no file path, no file extension-)    
%       roiextract_functionals: (for roiextract==4) roiextract_functionals{nsub}{nses} char array of functional volume files
% 
%    add             : 1/0; use 0 (default) to define the full set of subjects in your experiment; use 1 to define an additional set of subjects (to be added to any already-existing subjects in your project) [0]
%                      When using add=1, the following fields are expected to contain the information for the new/added subjects *only*: Setup.functionals, Setup.structurals, Setup.roiextract_functionals, Setup.unwarp_functionals, Setup.spmfiles, Setup.masks.Grey/White/CSF, Setup.rois.files, Setup.conditions.onsets/durations, Setup.covariates.files
%                      When using Setup.add=1 in combination with Setup.done, Setup.preprocessing, Denoising.done, and/or Analysis.done only the new/added subjects will be processed
%                      When using Setup.add=1 the BATCH.subjects field is disregarded/overwritten to point to the new/added subjects only
%                      Setup.add cannot be used in combination with any of the Setup.rois.add, Setup.conditions.add, or Setup.covariates.add options within the same batch structure
% 
%    masks
%      Grey          : masks.Grey{nsub} char array of grey matter mask volume file [defaults to Grey mask extracted from structural volume] 
%      White         : masks.White{nsub} char array of white matter mask volume file [defaults to White mask extracted from structural volume] 
%      CSF           : masks.CSF{nsub} char array of CSF mask volume file [defaults to CSF mask extracted from structural volume] 
%                    : each of these fields can also be defined as a double cell array for session-specific files (e.g. mask.Grey{nsub}{nses} grey matter file for subject nsub and session nses)
%                    : each of these fields can also be defined as a structure with fields files/dimensions/etc. (same as 'Setup.rois' below).
%    rois
%      names         : rois.names{nroi} char array of ROI name [defaults to ROI filename]
%      files         : rois.files{nroi}{nsub}{nses} char array of roi file (rois.files{nroi}{nsub} char array of roi file, to use the same roi for all sessions; or rois.files{nroi} char array of roi file, to use the same roi for all subjects)
%      dimensions    : rois.dimensions{nroi} number of ROI dimensions - # temporal components to extract from ROI [1] (set to 1 to extract the average timeseries within ROI voxels; set to a number greater than 1 to extract additional PCA timeseries within ROI voxels; set to 0 to compute a weighted sum within ROI voxels (ROI mask values are interpreted as weights))
%      mask          : rois.mask(nroi) 1/0 to mask with grey matter voxels [0] 
%      regresscovariates: rois.regresscovariates(nroi) 1/0 to regress known first-level covariates before computing PCA decomposition of BOLD signal within ROI [1 if dimensions>1; 0 otherwise] 
%      roiextract    : rois.roiextract(nroi) index n to Setup.roifunctionals(n) identifying functional data coregistered to this ROI to extract BOLD timeseries from [1] (set to 0 to extract BOLD signal from Setup.functionals instead)
%      add           : 1/0; use 0 (default) to define the full set of ROIs to be used in your analyses; use 1 to define an additional set of ROIs (to be added to any already-existing ROIs in your project) [0]
%  
%    conditions
%      names         : conditions.names{ncondition} char array of condition name
%      onsets        : conditions.onsets{ncondition}{nsub}{nses} vector of condition onsets (in seconds)
%      durations     : conditions.durations{ncondition}{nsub}{nses} vector of condition durations (in seconds)
%      param         : conditions.param(ncondition) temporal modulation (0 for no temporal modulation; positive index to first-level covariate for other temporal interactions) 
%      filter        : conditions.filter{ncondition} temporal/frequency decomposition ([] for no decomposition; [low high] for fixed band-pass frequency filter; [N] for filter bank decompositoin with N frequency filters; [Duration Onsets] in seconds for sliding-window decomposition where Duration is a scalar and Onsets is a vector of two or more sliding-window onset values) 
%      missingdata   : 1/0 Allow subjects with missing condition data (empty onset/duration fields in *all* of the sessions) [0] 
%      add           : 1/0; use 0 (default) to define the full set of conditions to be used in your analyses; use 1 to define an additional set of conditions (to be added to any already-existing conditions in your project) [0]
%
%    covariates
%      names         : covariates.names{ncovariate} char array of covariate name
%      files         : covariates.files{ncovariate}{nsub}{nses} char array of covariate file 
%      add           : 1/0; use 0 (default) to define the full set of covariates to be used in your analyses; use 1 to define an additional set of covariates (to be added to any already-existing covariates in your project) [0]
%  
%    subjects
%      effect_names  : subjects.effect_names{neffect} char array of second-level effect name
%      effects       : subjects.effects{neffect} vector of size [nsubjects,1] defining second-level effects
%  
%    subjects
%      group_names  : subjects.group_names{ngroup} char array of second-level group name
%      groups       : subjects.group vector of size [nsubjects,1] (with values from 1 to ngroup) defining second-level groups
%  
%    analyses        : Vector of index to analysis types (1: ROI-to-ROI; 2: Seed-to-voxel; 3: Voxel-to-voxel; 4: Dynamic FC) Defaults to vector [1,2,3,4] (all analyses)
%    voxelmask       : Analysis mask (voxel-level analyses): 1: Explicit mask (brainmask.nii); 2: Implicit mask (subject-specific) [1] 
%    voxelmaskfile   : Explicit mask file (only when voxelmask=1) [fullfile(fileparts(which('spm')),'apriori','brainmask.nii')] 
%    voxelresolution : Analysis space (voxel-level analyses): 1: Volume-based template (SPM; default 2mm isotropic or same as explicit mask if specified); 2: Same as structurals; 3: Same as functionals; 4: Surface-based template (Freesurfer) [1] 
%    surfacesmoothing: (for voxelresolution=4) Smoothing level for surface-based analyses (number of discrete diffusion steps) [10]
%    analysisunits   : BOLD signal units: 1: PSC units (percent signal change); 2: raw units [1] 
%    outputfiles     : Optional output files (outputfiles(1): 1/0 creates confound beta-maps; outputfiles(2): 1/0 creates confound-corrected timeseries; outputfiles(3): 1/0 creates seed-to-voxel r-maps) ;outputfiles(4): 1/0 creates seed-to-voxel p-maps) ;outputfiles(5): 1/0 creates seed-to-voxel FDR-p-maps); outputfiles(6): 1/0 creates ROI-extraction REX files; [0,0,0,0,0,0] 
%    spmfiles        : Optionally, spmfiles{nsub} is a char array pointing to the 'SPM.mat' source file to extract Setup information from for each subject (use alternatively spmfiles{nsub}{nses} for session-specific SPM.mat files) 
%    spmfiles_options: (for Setup.spmfiles procedure) Cell array containing additional options to pass to conn_importspm when importing experiment info from spmfiles (see help conn_importspm)
%    unwarp_functionals: (for Setup.preprocessing.steps=='realign&unwarp&phasemap') unwarp_functionals{nsub}{nses} char array of Phase Map volumes (vdm* file) 
%    cwthreshold     : erosion options for WhiteMatter&CSF ROIs: cwthreshold(1): WhiteMatter threshold for noise aCompCor region; cwthreshold(2): WhiteMatter number of mask erosion steps; cwthreshold(3): CSF threshold for noise aCompCor region; cwthreshold(4): CSF number of mask erosion steps  ([.5 1 .5 1])
% 
%  
% BATCH.Setup.preprocessing PERFORMS DATA PREPROCESSING STEPS (realignment/slicetiming/coregistration/segmentation/normalization/smoothing) %!
%    preprocessing     
%      steps         : List of data preprocessing steps (cell array containing a subset of the following steps, in the desired order):
%                      steps={'default_mni','default_mniphase','default_ss','default_ssphase',...    % (default pipelines: default_mni (direct normalization for volume-based analyses, to MNI space); default_mniphase (indirect normalization for volume-based analyses, to MNI space, when phase-maps are available); default_ss (for surface-based analyses, in subject-space); default_ssphase (for surface-based analyses, in subject-space, when phase-maps are available)  
%                          'structural_manualorient','structural_segment','structural_normalize',... % (individual steps) 
%                          'structural_segment&normalize','functional_removescans','functional_manualorient',...
%                          'functional_slicetime','functional_realign','functional_realign&unwarp',...
%                          'functional_realign&unwarp&phasemap','functional_art','functional_coregister',...
%                          'functional_segment','functional_normalize','functional_segment&normalize','functional_smooth'};
%                      If steps is left empty or unset a gui will prompt the user to specify the desired preprocessing pipeline 
%                      note: 'default_mni' contains the steps: {'functional_realign&unwarp','functional_center','functional_slicetime','structural_center','structural_segment&normalize','functional_normalize','functional_art','functional_smooth'}
%   
%      voxelsize       : (normalization) target voxel size for resliced volumes (mm) [2]
%      boundingbox     : (normalization) target bounding box for resliced volumes (mm) [-90,-126,-72;90,90,108] 
%      fwhm            : (functional_smooth) Smoothing factor (mm) [8]
%      coregtomean     : (functional_coregister/segment/normalize) 1: use mean volume (computed during realignment); 0: use first volume  
%      applytofunctional: (structural_normalize) 1/0: apply structural-normalization transformation to functional volumes as well 
%      sliceorder      : (functional_slicetime) acquisition order (vector of indexes; 1=first slice in image; note: use cell array for subject-specific vectors)
%                       alternatively sliceorder may also be defined as one of the following strings: 'ascending','descending','interleaved (middle-top)','interleaved (bottom-up)','interleaved (top-down)','interleaved (Siemens)'  
%                       alternatively sliceorder may also be defined as a vector containing the acquisition time in milliseconds for each slice (e.g. for multi-band sequences) 
%      ta              : (functional_slicetime) acquisition time (TA) in seconds (used to determine slice times when sliceorder is defined by a vector of slice indexes; note: use vector for subject-specific values). Defaults to (1-1/nslices)*TR where nslices is the number of slices
%      art_thresholds  : (functional_art) ART thresholds for identifying outlier scans 
%                                            art_thresholds(1): threshold value for global-signal (z-value; default 9) 
%                                            art_thresholds(2): threshold value for subject-motion (mm; default 2) 
%                        additional options: art_thresholds(3): 1/0 global-signal threshold based on scan-to-scan changes in global-BOLD measure (default 1) 
%                                            art_thresholds(4): 1/0 subject-motion threshold based on scan-to-scan changes in subject-motion measure (default 1) 
%                                            art_thresholds(5): 1/0 subject-motion threhsold based on composite-movement measure (default 1) 
%                                            art_thresholds(6): 1/0 force interactive mode (ART gui) (default 0) 
%                                            art_thresholds(7): [only when art_threshold(5)=0] subject-motion threshold based on rotation measure 
%                                            art_thresholds(8): N number of initial scans to be flagged for removal (default 0)
%                            note: when art_threshold(5)=0, art_threshold(2) defines the threshold based on the translation measure, and art_threhsold(7) defines the threshold based on the rotation measure; otherwise art_threshold(2) defines the (single) threshold based on the composite-motion measure 
%                            note: the default art_thresholds(1:2) [9 2] values correspond to the "liberal" (99th percentile) settings, to use the "conservative" (95th percentile) settings use [3 .5] values instead
%                            note: art needs subject-motion files to estimate possible outliers. If a 'realignment' first-level covariate exists it will load the subject-motion parameters from that first-level covariate; otherwise it will look for a rp_*.txt file (SPM format) in the same folder as the functional data
%                                  subject-motion files can be in any of the following formats: a) *.txt file (SPM format; three translation parameters in mm followed by pitch/roll/yaw in radians); b) *.par (FSL format; three Euler angles in radians followed by translation parameters in mm); c) *.siemens.txt (Siemens MotionDetectionParameter.txt format); d) *.deg.txt (same as SPM format but rotations in degrees instead of radians)
%      removescans     : (functional_removescans) number of initial scans to remove
%      reorient        : (functional/structural_manualorient) 3x3 transformation matrix
%      template_structural: (structural_normalize SPM8 only) anatomical template file for approximate coregistration [spm/template/T1.nii]
%      template_functional: (functional_normalize SPM8 only) functional template file for normalization [spm/template/EPI.nii]
%      tpm_template    : (structural_segment, structural_segment&normalize in SPM8, and any segment/normalize option in SPM12) tissue probability map [spm/tpm/TPM.nii]
%      tpm_ngaus       : (structural_segment, structural_segment&normalize in SPM8&SPM12) number of gaussians for each tissue probability map
%  
%  
% BATCH.Denoising PERFORMS DENOISING STEPS (confound removal & filtering) %!
%  Denoising       
% 
%    done            : 1/0: 0 defines fields only; 1 runs DENOISING processing steps [0]
%    overwrite       : (for done=1) 1/0: overwrites target files if they exist [1]
%    filter          : vector with two elements specifying band pass filter: low-frequency & high-frequency cutoffs (Hz)
%    detrending      : 0/1/2/3: BOLD times-series polynomial detrending order (0: no detrending; 1: linear detrending; ... 3: cubic detrending) 
%    despiking       : 0/1/2: temporal despiking with a hyperbolic tangent squashing function (1:before regression; 2:after regression) [0] 
%    regbp           : 1/2: order of band-pass filtering step (1 = RegBP: regression followed by band-pass; 2 = Simult: simultaneous regression&band-pass) [1] 
%    confounds       : Cell array of confound names (alternatively see 'confounds.names' below)
% 
%    confounds       : alternatively confounds can be a structure with fields
%      names         : confounds.names{nconfound} char array of confound name (confound names can be: 'Grey Matter','White Matter','CSF',any ROI name, any covariate name, or 'Effect of *' where * represents any condition name])
%      dimensions    : confounds.dimensions{nconfound} number of confound dimensions [defaults to using all dimensions available for each confound variable]
%      deriv         : confounds.deriv{nconfound} numnber of derivatives for each dimension [0]
%  
%  
% BATCH.Analysis PERFORMS FIRST-LEVEL ANALYSES (ROI-to-ROI and seed-to-voxel) %!
%  Analysis            
% 
%    done            : 1/0: 0 defines fields only; 1 runs ANALYSIS processing steps [0]
%    overwrite       : (for done=1) 1/0: overwrites target files if they exist [1]
%    analysis_number : sequential index identifying each set of independent analyses [1] 
%                      (alternative a string identifying the analysis name)
%    measure         : connectivity measure used, 1 = 'correlation (bivariate)', 2 = 'correlation (semipartial)', 3 = 'regression (bivariate)', 4 = 'regression (multivariate)'; [1] 
%    weight          : within-condition weight, 1 = 'none', 2 = 'hrf', 3 = 'hanning'; [2] 
%    modulation      : temporal modulation, 0 = standard weighted GLM analyses; 1 = gPPI analyses of condition-specific temporal modulation factor, or a string for PPI analyses of other temporal modulation factor (same for all conditions; valid strings are ROI names and 1st-level covariate names)'; [0] 
%    conditions      : (for modulation==1 only) list of task condition names to be simultaneously entered in gPPI model (leave empty for default 'all existing conditions') [] 
%    type            : analysis type, 1 = 'ROI-to-ROI', 2 = 'Seed-to-Voxel', 3 = 'all'; [3] 
%    sources         : Cell array of sources names (seeds) (source names can be: any ROI name) (if this variable does not exist the toolbox will perform the analyses for all of the existing ROIs which are not defined as confounds in the Denoising step) 
% 
%    sources         : alternatively sources can be a structure with fields
%      names         : sources.names{nsource} char array of source names (seeds)
%      dimensions    : sources.dimensions{nsource} number of source dimensions [1]
%      deriv         : sources.deriv{nsource} number of derivatives for each dimension [0]
%      fbands        : sources.fbands{nsource} number of frequency bands for each dimension [1]
% 
% 
% BATCH.Analysis PERFORMS FIRST-LEVEL ANALYSES (voxel-to-voxel) %!
%  Analysis            
%
%    done            : 1/0: 0 defines fields only; 1 runs ANALYSIS processing steps [0]
%    overwrite       : (for done=1) 1/0: overwrites target files if they exist [1]
%    measures        : Cell array of voxel-to-voxel measure names (type 'conn_v2v measurenames' for a list of default measures) (if this variable does not exist the toolbox will perform the analyses for all of the default voxel-to-voxel measures) 
%  
%    measures        : alternatively voxel-to-voxel measures can be a structure with fields
%      names         : measures.names{nmeasure} char array of measure names (see 'conn_v2v measurenames' for a list of valid measure names)
%      factors       : (for group-PCA, group-ICA, group-MVPA) measures.factors{nmeasure} number of group-level components to estimate
%      kernelsupport : (for ILC, RCC) measures.kernelsupport{nmeasure} local support (FWHM mm) of smoothing kernel [8]
%      norm          : (for ILC,ICC,RCC,RSC) 0/1 normalize values to z-scores [1]
%      dimensions    : measures.dimensions{nmeasure} number of subject-level dimensions to retain (subject-level dimensionality reduction) [64]
%  
%  
% BATCH.Results PERFORMS SECOND-LEVEL ANALYSES (ROI-to-ROI and Seed-to-Voxel analyses) %!
%  Results             
% 
%    done            : 1/0: 0 defines fields only; 1 runs processing steps [0]
%    overwrite       : (for done=1) 1/0: overwrites target files if they exist [1]
%    analysis_number : sequential indexes identifying each set of independent analysis [1]
%                      (alternative a string identifying the analysis name)
%    foldername      : folder to store the results
% 
%    between_subjects
%      effect_names  : cell array of second-level effect names
%      contrast      : contrast vector (same size as effect_names)
%  
%    between_conditions [defaults to multiple analyses, one per condition]
%      effect_names  : cell array of condition names (as in Setup.conditions.names)
%      contrast      : contrast vector (same size as effect_names)
%  
%    between_sources    [defaults to multiple analyses, one per source]
%      effect_names  : cell array of source names (as in Analysis.regressors, typically appended with _1_1; generally they are appended with _N_M -where N is an index ranging from 1 to 1+derivative order, and M is an index ranging from 1 to the number of dimensions specified for each ROI; for example ROINAME_2_3 corresponds to the first derivative of the third PCA component extracted from the roi ROINAME) 
%      contrast      : contrast vector (same size as effect_names)
%  
%  
% BATCH.Results PERFORMS SECOND-LEVEL ANALYSES (Voxel-to-Voxel analyses) %!
%  Results             
% 
%    done            : 1/0: 0 defines fields only; 1 performs processing steps [0]
%    overwrite       : (for done=1) 1/0: overwrites target files if they exist [1]
%    foldername      : folder to store the results
%  
%    between_subjects
%      effect_names  : cell array of second-level effect names
%      contrast      : contrast vector (same size as effect_names)
%  
%    between_conditions [defaults to multiple analyses, one per condition]
%      effect_names  : cell array of condition names (as in Setup.conditions.names)
%      contrast      : contrast vector (same size as effect_names)
%  
%    between_measures [defaults to multiple analyses, one per measure]
%      effect_names  : cell array of measure names (as in Analysis.measures) 
%      contrast      : contrast vector (same size as effect_names)
%  
%_________________________________________________________________________________________________________________________________________________
% 
% See 
%   conn_batch_workshop_nyu.m 
%   conn_batch_workshop_nyu_parallel.m 
%   conn_batch_humanconnectomeproject.m 
% for additional information and examples of use.
% 

%$

global CONN_x;

if nargin==1&&~ischar(varargin{1}), batch=varargin{1}; %batch(BATCH) syntax
elseif nargin==1&&ischar(varargin{1}), 
    if ~isempty(regexp(varargin{1},'\.mat$'))
        data=load(varargin{1},'-mat'); tnames=fieldnames(data); batch=data.(tnames{1}); %batch(batchfilename.mat) syntax
    elseif ~isempty(regexp(varargin{1},'\.m$')) %batch(batchfilename.m) syntax
        conn_batch_eval(varargin{1});
        return;
    else %batch(Matlabcommand) syntax
        evalin('base',varargin{1});
        return;
    end
else %batch(fieldname,fieldvalue,...) syntax
    batch=[];
    for n=1:2:nargin-1
        str=regexp(varargin{n},'\.','split');
        batch=setfield(batch,str{:},varargin{n+1});
    end
end
if iscell(batch),%batch({BATCH1, BATCH2...}) syntax
    for nbatch=1:numel(batch),conn_batch(batch{nbatch});end
    return;
elseif numel(batch)>1, %batch([BATCH1 BATCH2]) syntax
    for nbatch=1:numel(batch),conn_batch(batch(nbatch));end
    return;
end

%% NEW step
if isfield(batch,'New'), % obsolete functionality / for backwards compatibility only
    if isfield(batch,'parallel')&&isfield(batch.parallel,'N')&&batch.parallel.N>0, error('BATCH.New option is not compatible with parallel processing. Please use the newer BATCH.Setup.preprocessing fields instead'); return; end
    disp('This option may become obsolete in future releases. Please transition your BATCH.New scripts to use BATCH.Setup.preprocessing instead'); 
    OPTIONS=struct('RT',2,'FWHM',8,'VOX',2,'CONN_DISPLAY',0,'STRUCTURAL_TEMPLATE',fullfile(fileparts(which('spm')),'templates','T1.nii'),'FUNCTIONAL_TEMPLATE',fullfile(fileparts(which('spm')),'templates','EPI.nii'),'SO',[],'UNWARP',[]);
    if isempty(dir(OPTIONS.FUNCTIONAL_TEMPLATE)), OPTIONS.FUNCTIONAL_TEMPLATE=fullfile(fileparts(which('spm')),'toolbox','OldNorm','EPI.nii'); end
    if isempty(dir(OPTIONS.STRUCTURAL_TEMPLATE)), OPTIONS.STRUCTURAL_TEMPLATE=fullfile(fileparts(which('spm')),'toolbox','OldNorm','T1.nii'); end
    if isfield(batch,'filename')&&~isempty(batch.filename),OPTIONS.CONN_NAME=batch.filename; end
    if isfield(batch.New,'center')&&~isempty(batch.New.center),OPTIONS.CENTER=batch.New.center;end
    if isfield(batch.New,'reorient')&&~isempty(batch.New.reorient),OPTIONS.REORIENT=batch.New.reorient;end
    if isfield(batch.New,'RT')&&~isempty(batch.New.RT),OPTIONS.RT=batch.New.RT;end; 
    if isfield(batch.New,'fwhm')&&~isempty(batch.New.fwhm),OPTIONS.FWHM=batch.New.fwhm;end
    if isfield(batch.New,'FWHM')&&~isempty(batch.New.FWHM),OPTIONS.FWHM=batch.New.FWHM;end
    if isfield(batch.New,'VOX')&&~isempty(batch.New.VOX),OPTIONS.VOX=batch.New.VOX;end
    if isfield(batch.New,'sliceorder')&&~isempty(batch.New.sliceorder),OPTIONS.SO=batch.New.sliceorder;end
    if isfield(batch.New,'unwarp')&&~isempty(batch.New.unwarp),OPTIONS.UNWARP=batch.New.unwarp;end
    if isfield(batch.New,'removescans')&&~isempty(batch.New.removescans),OPTIONS.removescans=batch.New.removescans;end
    if isfield(batch.New,'coregtomean')&&~isempty(batch.New.coregtomean),OPTIONS.coregtomean=batch.New.coregtomean;end
    if isfield(batch.New,'applytofunctional')&&~isempty(batch.New.applytofunctional),OPTIONS.applytofunctional=batch.New.applytofunctional;end
    if isfield(batch.New,'art_thresholds')&&~isempty(batch.New.art_thresholds),OPTIONS.art_thresholds=batch.New.art_thresholds;end
    if isfield(batch.New,'steps')&&~isempty(batch.New.steps),OPTIONS.STEPS=batch.New.steps;end
    if isfield(batch.New,'template_structural')&&~isempty(batch.New.template_structural),OPTIONS.STRUCTURAL_TEMPLATE=batch.New.template_structural;end
    if isfield(batch.New,'template_functional')&&~isempty(batch.New.template_functional),OPTIONS.FUNCTIONAL_TEMPLATE=batch.New.template_functional;end
    if isfield(batch.New,'tpm_template'),OPTIONS.tpm_template=batch.New.tpm_template;end
    if isfield(batch.New,'tpm_ngaus'),OPTIONS.tpm_ngaus=batch.New.tpm_ngaus;end
    if isfield(batch.New,'functionals')&&~isempty(batch.New.functionals),
        OPTIONS.FUNCTIONAL_FILES=batch.New.functionals;
    end
    if isfield(batch.New,'structurals')&&~isempty(batch.New.structurals),
        OPTIONS.STRUCTURAL_FILES=batch.New.structurals;
    end
    conn_setup_wizard(OPTIONS);
end

PAR_CMD={};
PAR_ARG={};

%% SETUP step
if isfield(batch,'Setup'),
    if isfield(batch,'filename'),
        if (isfield(batch.Setup,'isnew')&&batch.Setup.isnew)||isempty(dir(batch.filename)),
            conn('init');                   % initializes CONN_x structure
            CONN_x.filename=batch.filename;
            if conn_existfile(CONN_x.filename), conn_jobmanager('cleardmat'); end
        else
            CONN_x.filename=batch.filename;
            CONN_x.gui=0;
            conn load;                      % loads existing conn_* project
            CONN_x.gui=1;
        end
    end
    
    if ~isfield(batch.Setup,'overwrite'),batch.Setup.overwrite='Yes';end
    if isscalar(batch.Setup.overwrite)&&~isstruct(batch.Setup.overwrite)&&ismember(double(batch.Setup.overwrite),[1 89 121]), batch.Setup.overwrite='Yes'; end
    if isfield(batch.Setup,'add')&&batch.Setup.add, 
        SUBJECTS=CONN_x.Setup.nsubjects+(1:batch.Setup.nsubjects); 
        CONN_x.Setup.nsubjects=conn_merge(CONN_x.Setup.nsubjects,CONN_x.Setup.nsubjects+batch.Setup.nsubjects); 
    else
        if isfield(batch.Setup,'nsubjects')&&~isempty(batch.Setup.nsubjects),
            if batch.Setup.nsubjects~=CONN_x.Setup.nsubjects, CONN_x.Setup.nsubjects=conn_merge(CONN_x.Setup.nsubjects,batch.Setup.nsubjects); end
        end
        if isfield(batch,'subjects'), SUBJECTS=batch.subjects; 
        else SUBJECTS=1:CONN_x.Setup.nsubjects;
        end
    end
    if isfield(batch.Setup,'spmfiles')&&~isempty(batch.Setup.spmfiles),
        CONN_x.gui=struct('overwrite',batch.Setup.overwrite);
        if isfield(batch.Setup,'spmfiles_options')&&~isempty(batch.Setup.spmfiles_options),args=batch.Setup.spmfiles_options; 
        else args={};
        end
        conn_importspm(batch.Setup.spmfiles,args{:},'subjects',SUBJECTS);
        CONN_x.gui=1;
    end
    if isfield(batch.Setup,'RT')&&~isempty(batch.Setup.RT),CONN_x.Setup.RT(SUBJECTS)=batch.Setup.RT;end
    if isfield(batch.Setup,'acquisitiontype')&&~isempty(batch.Setup.acquisitiontype),
        CONN_x.Setup.acquisitiontype=1+(batch.Setup.acquisitiontype~=1);
    end
    if isfield(batch.Setup,'analyses'),
        CONN_x.Setup.steps=accumarray(batch.Setup.analyses(:),1,[4,1])';
    end
    if isfield(batch.Setup,'voxelmask')&&~isempty(batch.Setup.voxelmask),
        CONN_x.Setup.analysismask=batch.Setup.voxelmask;
    end
    if isfield(batch.Setup,'voxelmaskfile')&&~isempty(batch.Setup.voxelmaskfile),
        CONN_x.Setup.explicitmask=conn_file(batch.Setup.voxelmaskfile);
    end
    if isfield(batch.Setup,'voxelresolution')&&~isempty(batch.Setup.voxelresolution),
        CONN_x.Setup.spatialresolution=batch.Setup.voxelresolution;
    end
    if isfield(batch.Setup,'analysisunits')&&~isempty(batch.Setup.analysisunits),
        CONN_x.Setup.analysisunits=batch.Setup.analysisunits;
    end
    if isfield(batch.Setup,'outputfiles'),
        CONN_x.Setup.outputfiles=batch.Setup.outputfiles;
    end
    if isfield(batch.Setup,'surfacesmoothing'),
        CONN_x.Setup.surfacesmoothing=batch.Setup.surfacesmoothing;
    end
    if isfield(batch.Setup,'functionals')&&~isempty(batch.Setup.functionals),
        for isub=1:numel(SUBJECTS),
            nsub=SUBJECTS(isub);
            CONN_x.Setup.nsessions(nsub)=length(batch.Setup.functionals{isub});
            for nses=1:CONN_x.Setup.nsessions(nsub),
                [CONN_x.Setup.functional{nsub}{nses},V]=conn_file(batch.Setup.functionals{isub}{nses});
                CONN_x.Setup.nscans{nsub}{nses}=prod(size(V));
            end
        end
    end
    if isfield(batch.Setup,'roiextract'), batch.Setup.roifunctionals.roiextract=batch.Setup.roiextract; end
    if isfield(batch.Setup,'roiextract_rule'), batch.Setup.roifunctionals.roiextract_rule=batch.Setup.roiextract_rule; end
    if isfield(batch.Setup,'roiextract_functionals'), batch.Setup.roifunctionals.roiextract_functionals=batch.Setup.roiextract_functionals; end
    if isfield(batch.Setup,'roifunctionals')
        for nalt=1:numel(batch.Setup.roifunctionals)
            if isfield(batch.Setup.roifunctionals(nalt),'roiextract')
                CONN_x.Setup.roifunctional(nalt).roiextract=batch.Setup.roifunctionals(nalt).roiextract;
            end
            if isfield(batch.Setup.roifunctionals(nalt),'roiextract_rule')
                CONN_x.Setup.roifunctional(nalt).roiextract_rule=batch.Setup.roifunctionals(nalt).roiextract_rule;
            end
            if isfield(batch.Setup.roifunctionals(nalt),'roiextract_functionals')
                for isub=1:numel(SUBJECTS),
                    nsub=SUBJECTS(isub);
                    %CONN_x.Setup.nsessions(nsub)=length(batch.Setup.roiextract_functionals{nsub});
                    for nses=1:CONN_x.Setup.nsessions(nsub),
                        [CONN_x.Setup.roifunctional(nalt).roiextract_functional{nsub}{nses},V]=conn_file(batch.Setup.roifunctionals(nalt).roiextract_functionals{isub}{nses});
                        %CONN_x.Setup.nscans{nsub}{nses}=prod(size(V));
                    end
                end
            end
        end
    end
    if isfield(batch.Setup,'unwarp_functionals')
        for isub=1:numel(SUBJECTS),
            nsub=SUBJECTS(isub);
            %CONN_x.Setup.nsessions(nsub)=length(batch.Setup.unwarp_functionals{nsub});
            for nses=1:CONN_x.Setup.nsessions(nsub),
                [CONN_x.Setup.unwarp_functional{nsub}{nses},V]=conn_file(batch.Setup.unwarp_functionals{isub}{nses});
                %CONN_x.Setup.nscans{nsub}{nses}=prod(size(V));
            end
        end
    end
    if isfield(batch.Setup,'cwthreshold')
        CONN_x.Setup.cwthreshold(1:numel(batch.Setup.cwthreshold))=batch.Setup.cwthreshold;
    end
    if isfield(batch.Setup,'structurals')&&~isempty(batch.Setup.structurals),
        CONN_x.Setup.structural_sessionspecific=0; 
        for isub=1:numel(SUBJECTS),
            nsub=SUBJECTS(isub);
            temp=batch.Setup.structurals{isub};
            if ischar(temp), temp={temp}; end
            if numel(temp)>1, CONN_x.Setup.structural_sessionspecific=1; end
            for nses=1:CONN_x.Setup.nsessions(nsub),
                CONN_x.Setup.structural{nsub}{nses}=conn_file(temp{min(numel(temp),nses)});
            end
        end
    end
    if isfield(batch.Setup,'masks'),
        masks={'Grey','White','CSF'};
        for nmask=1:length(masks),
            if isfield(batch.Setup.masks,masks{nmask})&&~isempty(batch.Setup.masks.(masks{nmask})),
                if ~isstruct(batch.Setup.masks.(masks{nmask})),
                    if isequal(SUBJECTS,1:CONN_x.Setup.nsubjects)
                        subjectspecific=0;
                        sessionspecific=0;
                    else
                        subjectspecific=CONN_x.Setup.rois.subjectspecific(nmask);
                        sessionspecific=CONN_x.Setup.rois.sessionspecific(nmask);
                    end
                    temp1=batch.Setup.masks.(masks{nmask});
                    if ischar(temp1), temp1={temp1}; end
                    if numel(temp1)>1||CONN_x.Setup.nsubjects==1, subjectspecific=1; end
                    for isub=1:numel(SUBJECTS),
                        nsub=SUBJECTS(isub);
                        temp2=temp1{min(numel(temp1),isub)};
                        if ischar(temp2), temp2={temp2}; end
                        if numel(temp2)>1, sessionspecific=1; end
                        for nses=1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsub))
                            CONN_x.Setup.rois.files{nsub}{nmask}{nses}=conn_file(temp2{min(numel(temp2),nses)});
                        end
                    end
                    CONN_x.Setup.rois.subjectspecific(nmask)=subjectspecific;
                    CONN_x.Setup.rois.sessionspecific(nmask)=sessionspecific;
                else,
                    if isequal(SUBJECTS,1:CONN_x.Setup.nsubjects)
                        subjectspecific=0;
                        sessionspecific=0;
                    else
                        subjectspecific=CONN_x.Setup.rois.subjectspecific(nmask);
                        sessionspecific=CONN_x.Setup.rois.sessionspecific(nmask);
                    end
                    temp1=batch.Setup.masks.(masks{nmask}).files;
                    if ischar(temp1), temp1={temp1}; end
                    if numel(temp1)>1||CONN_x.Setup.nsubjects==1, subjectspecific=1; end
                    for isub=1:numel(SUBJECTS),
                        nsub=SUBJECTS(isub);
                        temp2=temp1{min(numel(temp1),isub)};
                        if ischar(temp2), temp2={temp2}; end
                        if numel(temp2)>1, sessionspecific=1; end
                        for nses=1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsub))
                            CONN_x.Setup.rois.files{nsub}{nmask}{nses}=conn_file(temp2{min(numel(temp2),nses)});
                        end
                    end
                    if isfield(batch.Setup.masks.(masks{nmask}),'dimensions'), CONN_x.Setup.rois.dimensions{nmask}=batch.Setup.masks.(masks{nmask}).dimensions; end
                    if isfield(batch.Setup.masks.(masks{nmask}),'regresscovariates'), CONN_x.Setup.rois.regresscovariates(nmask)=batch.Setup.masks.(masks{nmask}).regresscovariates; end
                    if isfield(batch.Setup.masks.(masks{nmask}),'roiextract'), CONN_x.Setup.rois.unsmoothedvolumes(nmask)=batch.Setup.masks.(masks{nmask}).roiextract; end
                    CONN_x.Setup.rois.subjectspecific(nmask)=subjectspecific;
                    CONN_x.Setup.rois.sessionspecific(nmask)=sessionspecific;
                end;
            end
        end
    end
%     if isfield(batch.Setup,'masks')&&isfield(batch.Setup.masks,'Grey')&&~isempty(batch.Setup.masks.Grey),for nsub=1:CONN_x.Setup.nsubjects,CONN_x.Setup.rois.files{nsub}{1}=conn_file(batch.Setup.masks.Grey{nsub});end; end
%     if isfield(batch.Setup,'masks')&&isfield(batch.Setup.masks,'White')&&~isempty(batch.Setup.masks.White),for nsub=1:CONN_x.Setup.nsubjects,CONN_x.Setup.rois.files{nsub}{2}=conn_file(batch.Setup.masks.White{nsub});end; end
%     if isfield(batch.Setup,'masks')&&isfield(batch.Setup.masks,'CSF')&&~isempty(batch.Setup.masks.CSF),for nsub=1:CONN_x.Setup.nsubjects,CONN_x.Setup.rois.files{nsub}{3}=conn_file(batch.Setup.masks.CSF{nsub});end; end
    if isfield(batch.Setup,'rois'),%&&~isempty(batch.Setup.rois),
        if ~isstruct(batch.Setup.rois), 
            temp=batch.Setup.rois;
            batch.Setup.rois=struct;
            batch.Setup.rois.files=temp;
            for n1=1:length(temp), ttemp=temp{n1}; while iscell(ttemp), ttemp=ttemp{1}; end; [nill,name,nameext]=fileparts(ttemp); batch.Setup.rois.names{n1}=name;end; 
        end
        if isfield(batch.Setup.rois,'add')&&batch.Setup.rois.add, 
            if isfield(batch.Setup,'isnew')&&batch.Setup.isnew, conn importrois; end
            n0=length(CONN_x.Setup.rois.names)-1;
        else n0=3;
        end
        for n1=1:length(batch.Setup.rois.files),
            if isequal(SUBJECTS,1:CONN_x.Setup.nsubjects)
                subjectspecific=0;
                sessionspecific=0;
            else
                subjectspecific=CONN_x.Setup.rois.subjectspecific(n0+n1);
                sessionspecific=CONN_x.Setup.rois.sessionspecific(n0+n1);
            end
            temp1=batch.Setup.rois.files{n1};
            if ischar(temp1), temp1={temp1}; end
            if numel(temp1)>1||CONN_x.Setup.nsubjects==1, subjectspecific=1; end
            for isub=1:numel(SUBJECTS),
                nsub=SUBJECTS(isub);
                temp2=temp1{min(numel(temp1),isub)};
                if ischar(temp2), temp2={temp2}; end
                if numel(temp2)>1, sessionspecific=1; end
                for nses=1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsub))
                    [nill,name,nameext]=fileparts(temp2{min(numel(temp2),nses)});
                    %[V,str,icon]=conn_getinfo(batch.Setup.rois.files{n1}{nsub});
                    %CONN_x.Setup.rois.files{nsub}{n0+n1}={batch.Setup.rois.files{n1}{nsub},str,icon};
                    CONN_x.Setup.rois.files{nsub}{n0+n1}{nses}=conn_file(temp2{min(numel(temp2),nses)});
                end
            end
            if ~isfield(batch.Setup.rois,'names')||length(batch.Setup.rois.names)<n1||isempty(batch.Setup.rois.names{n1}), batch.Setup.rois.names{n1}=name; end
            if ~isfield(batch.Setup.rois,'dimensions')||length(batch.Setup.rois.dimensions)<n1||isempty(batch.Setup.rois.dimensions{n1}), batch.Setup.rois.dimensions{n1}=1; end
            if ~isfield(batch.Setup.rois,'mask')||length(batch.Setup.rois.mask)<n1, batch.Setup.rois.mask(n1)=0; end
            if ~isfield(batch.Setup.rois,'multiplelabels')||length(batch.Setup.rois.multiplelabels)<n1, batch.Setup.rois.multiplelabels(n1)=(strcmp(nameext,'.img')|strcmp(nameext,'.nii')|strcmp(nameext,'.mgz'))&(~isempty(dir(conn_prepend('',CONN_x.Setup.rois.files{1}{n0+n1}{1}{1},'.txt')))|~isempty(dir(conn_prepend('',CONN_x.Setup.rois.files{1}{n0+n1}{1}{1},'.csv')))|~isempty(dir(conn_prepend('',CONN_x.Setup.rois.files{1}{n0+n1}{1}{1},'.xls')))); end
            if ~isfield(batch.Setup.rois,'regresscovariates')||length(batch.Setup.rois.regresscovariates)<n1, batch.Setup.rois.regresscovariates(n1)=double(batch.Setup.rois.dimensions{n1}>1); end
            if ~isfield(batch.Setup.rois,'roiextract')||length(batch.Setup.rois.roiextract)<n1, batch.Setup.rois.roiextract(n1)=1; end
            CONN_x.Setup.rois.names{n0+n1}=batch.Setup.rois.names{n1}; CONN_x.Setup.rois.names{n0+n1+1}=' ';
            CONN_x.Setup.rois.dimensions{n0+n1}=batch.Setup.rois.dimensions{n1};
            CONN_x.Setup.rois.mask(n0+n1)=batch.Setup.rois.mask(n1);
            CONN_x.Setup.rois.subjectspecific(n0+n1)=subjectspecific;
            CONN_x.Setup.rois.sessionspecific(n0+n1)=sessionspecific;
            CONN_x.Setup.rois.multiplelabels(n0+n1)=batch.Setup.rois.multiplelabels(n1);
            CONN_x.Setup.rois.regresscovariates(n0+n1)=batch.Setup.rois.regresscovariates(n1);
            CONN_x.Setup.rois.unsmoothedvolumes(n0+n1)=batch.Setup.rois.roiextract(n1);
        end
        for nsub=1:CONN_x.Setup.nsubjects,% disregards other existing rois
            CONN_x.Setup.rois.files{nsub}=CONN_x.Setup.rois.files{nsub}(1:n0+length(batch.Setup.rois.files)); 
        end
        CONN_x.Setup.rois.names=CONN_x.Setup.rois.names(1:n0+length(batch.Setup.rois.files)+1);
        CONN_x.Setup.rois.names{end}=' ';
        CONN_x.Setup.rois.dimensions=CONN_x.Setup.rois.dimensions(1:n0+length(batch.Setup.rois.files));
        CONN_x.Setup.rois.mask=CONN_x.Setup.rois.mask(1:n0+length(batch.Setup.rois.files));
        CONN_x.Setup.rois.subjectspecific=CONN_x.Setup.rois.subjectspecific(1:n0+length(batch.Setup.rois.files));
        CONN_x.Setup.rois.sessionspecific=CONN_x.Setup.rois.sessionspecific(1:n0+length(batch.Setup.rois.files));
        CONN_x.Setup.rois.multiplelabels=CONN_x.Setup.rois.multiplelabels(1:n0+length(batch.Setup.rois.files));
        CONN_x.Setup.rois.regresscovariates=CONN_x.Setup.rois.regresscovariates(1:n0+length(batch.Setup.rois.files));
        CONN_x.Setup.rois.unsmoothedvolumes=CONN_x.Setup.rois.unsmoothedvolumes(1:n0+length(batch.Setup.rois.files));
    elseif isfield(batch.Setup,'isnew')&&batch.Setup.isnew,
        conn importrois;
    end

    if isfield(batch.Setup,'conditions')&&~isempty(batch.Setup.conditions)&&isfield(batch.Setup.conditions,'names'),
        if isfield(batch.Setup.conditions,'add')&&batch.Setup.conditions.add, nl0=numel(CONN_x.Setup.conditions.names)-1; 
        else nl0=0;
        end
        nconditions=numel(batch.Setup.conditions.names);
        CONN_x.Setup.conditions.names(nl0+(1:nconditions+1))={batch.Setup.conditions.names{:},' '};
        for isub=1:numel(SUBJECTS),
            nsub=SUBJECTS(isub);
            for nconditions=1:length(batch.Setup.conditions.names),
                for nses=1:CONN_x.Setup.nsessions(nsub),
                    if isfield(batch.Setup.conditions,'onsets')
                        CONN_x.Setup.conditions.values{nsub}{nl0+nconditions}{nses}={batch.Setup.conditions.onsets{nconditions}{isub}{nses},batch.Setup.conditions.durations{nconditions}{isub}{nses}};
                    else
                        CONN_x.Setup.conditions.values{nsub}{nl0+nconditions}{nses}={0,inf};
                    end
                end
            end
        end
        if isfield(batch.Setup.conditions,'param')
            CONN_x.Setup.conditions.param(nl0+(1:nconditions))=batch.Setup.conditions.param;
        else
            CONN_x.Setup.conditions.param(nl0+(1:nconditions))=zeros(1,nconditions);
        end
        if isfield(batch.Setup.conditions,'filter')
            CONN_x.Setup.conditions.filter(nl0+(1:nconditions))=batch.Setup.conditions.filter;
        else
            CONN_x.Setup.conditions.filter(nl0+(1:nconditions))=cell(1,nconditions);
        end
    end
    if isfield(batch.Setup,'conditions')&&isfield(batch.Setup.conditions,'missingdata'), CONN_x.Setup.conditions.missingdata=batch.Setup.conditions.missingdata; end
    
    if isfield(batch.Setup,'covariates')&&~isempty(batch.Setup.covariates),
        if isfield(batch.Setup.covariates,'add')&&batch.Setup.covariates.add, nl0=numel(CONN_x.Setup.l1covariates.names)-1; 
        else nl0=0;
        end
        ncovariates=numel(batch.Setup.covariates.names);
        CONN_x.Setup.l1covariates.names(nl0+(1:ncovariates+1))={batch.Setup.covariates.names{:},' '};
        for isub=1:numel(SUBJECTS),
            nsub=SUBJECTS(isub);
            for nl1covariates=1:length(batch.Setup.covariates.files),
                for nses=1:CONN_x.Setup.nsessions(nsub),
                    CONN_x.Setup.l1covariates.files{nsub}{nl0+nl1covariates}{nses}=conn_file(batch.Setup.covariates.files{nl1covariates}{isub}{nses});
                end
            end
        end
    end
    if isfield(batch.Setup,'subjects')&&~isempty(batch.Setup.subjects),
        CONN_x.Setup.l2covariates.names={' '};
        CONN_x.Setup.l2covariates.values=repmat({{}},[CONN_x.Setup.nsubjects,1]);
        if isfield(batch.Setup.subjects,'group_names')&&~isempty(batch.Setup.subjects.group_names),
            for ngroup=1:length(batch.Setup.subjects.group_names),
                idx=strmatch(batch.Setup.subjects.group_names{ngroup},CONN_x.Setup.l2covariates.names,'exact');
                if isempty(idx),
                    nl2covariates=length(CONN_x.Setup.l2covariates.names);
                    CONN_x.Setup.l2covariates.names{nl2covariates}=batch.Setup.subjects.group_names{ngroup};
                    CONN_x.Setup.l2covariates.names{nl2covariates+1}=' ';
                else, nl2covariates=idx;end
                for nsub=1:CONN_x.Setup.nsubjects,
                    CONN_x.Setup.l2covariates.values{nsub}{nl2covariates}=(batch.Setup.subjects.groups(nsub)==ngroup);
                end
            end
        end
        if isfield(batch.Setup.subjects,'effect_names')&&~isempty(batch.Setup.subjects.effect_names),
            for neffect=1:length(batch.Setup.subjects.effect_names),
                idx=strmatch(batch.Setup.subjects.effect_names{neffect},CONN_x.Setup.l2covariates.names,'exact');
                if isempty(idx),
                    nl2covariates=length(CONN_x.Setup.l2covariates.names);
                    CONN_x.Setup.l2covariates.names{nl2covariates}=batch.Setup.subjects.effect_names{neffect};
                    CONN_x.Setup.l2covariates.names{nl2covariates+1}=' ';
                else, nl2covariates=idx;end
                for nsub=1:CONN_x.Setup.nsubjects,
                    CONN_x.Setup.l2covariates.values{nsub}{nl2covariates}=batch.Setup.subjects.effects{neffect}(nsub);
                end
            end
        end
    end
    
    if isfield(batch.Setup,'preprocessing'),
        OPTIONS={'dogui',0,'fwhm',8,'art_thresholds',[9 2]};
        steps=batch.Setup.preprocessing.steps;
        batch.Setup.preprocessing=rmfield(batch.Setup.preprocessing,'steps');
        options=fieldnames(batch.Setup.preprocessing);
        for n=1:numel(options)
            OPTIONS=[OPTIONS {options{n}, batch.Setup.preprocessing.(options{n})}];
        end
        if isfield(batch,'parallel')&&isfield(batch.parallel,'N')&&batch.parallel.N>0, 
            PAR_CMD{end+1}='setup_preprocessing'; PAR_ARG{end+1}={[],steps,OPTIONS{:}};
        else
            conn_process('setup_preprocessing',steps,'subjects',SUBJECTS,OPTIONS{:});
            CONN_x.gui=1;
            conn save;
        end
        %conn_setup_preproc(steps,OPTIONS{:});
    end
    
    if isfield(batch.Setup,'done')&&batch.Setup.done,
        conn save;
        if ~isfield(batch.Setup,'overwrite'), batch.Setup.overwrite='Yes'; end
        if isscalar(batch.Setup.overwrite)&&~isstruct(batch.Setup.overwrite)&&ismember(double(batch.Setup.overwrite),[1 89 121]), batch.Setup.overwrite='Yes'; end
        CONN_x.gui=struct('overwrite',batch.Setup.overwrite,'subjects',SUBJECTS);
        if isfield(batch,'parallel')&&isfield(batch.parallel,'N')&&batch.parallel.N>0, 
            PAR_CMD{end+1}='Setup'; PAR_ARG{end+1}={CONN_x.gui};
        else
            conn_process Setup;
            CONN_x.gui=1;
            conn save;
        end
    else,
        if isfield(batch,'filename'),
            conn save;
        end
    end
else
    if isfield(batch,'subjects'), SUBJECTS=batch.subjects;
    else SUBJECTS=1:CONN_x.Setup.nsubjects;
    end
end

%% DENOISING step
if isfield(batch,'Preprocessing')&&~isfield(batch,'Denoising'),batch.Denoising=batch.Preprocessing; end
if isfield(batch,'Denoising'),
    if isfield(batch,'filename'),
        CONN_x.filename=batch.filename;
        CONN_x.gui=0;
        conn load;                      % loads existing conn_* project
        CONN_x.gui=1;
    end
    if isfield(batch.Denoising,'filter')&&~isempty(batch.Denoising.filter),
        CONN_x.Preproc.filter=batch.Denoising.filter;          % frequency filter (band-pass values, in Hz)
    end
    if isfield(batch.Denoising,'detrending')&&~isempty(batch.Denoising.detrending),
        CONN_x.Preproc.detrending=batch.Denoising.detrending;          
    end
    if isfield(batch.Denoising,'despiking')&&~isempty(batch.Denoising.despiking),
        CONN_x.Preproc.despiking=batch.Denoising.despiking;          
    end
    if isfield(batch.Denoising,'regbp')&&~isempty(batch.Denoising.regbp),
        CONN_x.Preproc.regbp=batch.Denoising.regbp;          
    end
    if isfield(batch.Denoising,'confounds')&&~isempty(batch.Denoising.confounds),
        CONN_x.Preproc.confounds.names=batch.Denoising.confounds.names;
        if isfield(batch.Denoising.confounds,'dimensions')&&~isempty(batch.Denoising.confounds.dimensions), CONN_x.Preproc.confounds.dimensions=batch.Denoising.confounds.dimensions; else, CONN_x.Preproc.confounds.dimensions={}; end
        if isfield(batch.Denoising.confounds,'deriv')&&~isempty(batch.Denoising.confounds.deriv), CONN_x.Preproc.confounds.deriv=batch.Denoising.confounds.deriv; else, CONN_x.Preproc.confounds.deriv={}; end
    end
    
    if isfield(batch.Denoising,'done')&&batch.Denoising.done,
        conn save;
        if ~isfield(batch.Denoising,'overwrite'), batch.Denoising.overwrite='Yes'; end
        if isscalar(batch.Denoising.overwrite)&&~isstruct(batch.Denoising.overwrite)&&ismember(double(batch.Denoising.overwrite),[1 89 121]), batch.Denoising.overwrite='Yes'; end
        CONN_x.gui=struct('overwrite',batch.Denoising.overwrite,'subjects',SUBJECTS);
        if isfield(batch,'parallel')&&isfield(batch.parallel,'N')&&batch.parallel.N>0, 
            PAR_CMD{end+1}='Denoising'; PAR_ARG{end+1}={CONN_x.gui};
        else
            conn_process Denoising;
            CONN_x.gui=1;
            conn save;
        end
    else
        if isfield(batch.Denoising,'confounds')&&~isempty(batch.Denoising.confounds), conn_process setup_updatedenoising; end
        if isfield(batch,'filename'),
            conn save;
        end
    end
end

%% ANALYSIS step
if isfield(batch,'Analysis'),
    if isfield(batch,'filename'),
        CONN_x.filename=batch.filename;
        CONN_x.gui=0;
        conn load;                      % loads existing conn_* project
        CONN_x.gui=1;
    end
    if isfield(batch.Analysis,'sources')||~isfield(batch.Analysis,'measures'),
        if ~isfield(batch.Analysis,'analysis_number')||isempty(batch.Analysis.analysis_number),batch.Analysis.analysis_number=1; end
        if ~isfield(batch.Analysis,'modulation')||isempty(batch.Analysis.modulation),batch.Analysis.modulation=0; end
        if ~isfield(batch.Analysis,'measure')||isempty(batch.Analysis.measure),batch.Analysis.measure=1; end
        if ~isfield(batch.Analysis,'weight')||isempty(batch.Analysis.weight),batch.Analysis.weight=2; end
        if ~isfield(batch.Analysis,'type')||isempty(batch.Analysis.type),batch.Analysis.type=3; end
        if ~isfield(batch.Analysis,'conditions'),batch.Analysis.conditions=[]; end
        if ischar(batch.Analysis.analysis_number)
            ianalysis=strmatch(batch.Analysis.analysis_number,{CONN_x.Analyses.name},'exact');
            if isempty(ianalysis), 
                ianalysis=numel(CONN_x.Analyses)+1;
                CONN_x.Analyses(ianalysis)=CONN_x.Analyses(end);
                CONN_x.Analyses(ianalysis).name=batch.Analysis.analysis_number; 
            end
            batch.Analysis.analysis_number=ianalysis;
        end
        CONN_x.Analysis=batch.Analysis.analysis_number;
        CONN_x.Analyses(CONN_x.Analysis).modulation=batch.Analysis.modulation;
        CONN_x.Analyses(CONN_x.Analysis).measure=batch.Analysis.measure;
        CONN_x.Analyses(CONN_x.Analysis).weight=batch.Analysis.weight;
        CONN_x.Analyses(CONN_x.Analysis).type=batch.Analysis.type;
        CONN_x.Analyses(CONN_x.Analysis).conditions=batch.Analysis.conditions;
        if ~isfield(batch.Analysis,'sources')||isempty(batch.Analysis.sources),
            CONN_x.Analyses(CONN_x.Analysis).regressors.names={};
        elseif ~isstruct(batch.Analysis.sources),
            CONN_x.Analyses(CONN_x.Analysis).regressors.names=batch.Analysis.sources;
            CONN_x.Analyses(CONN_x.Analysis).regressors.dimensions=repmat({1},size(batch.Analysis.sources));
            CONN_x.Analyses(CONN_x.Analysis).regressors.deriv=repmat({0},size(batch.Analysis.sources));
            CONN_x.Analyses(CONN_x.Analysis).regressors.types=repmat({'roi'},size(batch.Analysis.sources));
            CONN_x.Analyses(CONN_x.Analysis).regressors.fbands=repmat({1},size(batch.Analysis.sources));
        else
            CONN_x.Analyses(CONN_x.Analysis).regressors.names=batch.Analysis.sources.names;
            CONN_x.Analyses(CONN_x.Analysis).regressors.dimensions=batch.Analysis.sources.dimensions;
            CONN_x.Analyses(CONN_x.Analysis).regressors.deriv=batch.Analysis.sources.deriv;
            CONN_x.Analyses(CONN_x.Analysis).regressors.types=repmat({'roi'},size(batch.Analysis.sources.names));
            if isfield(batch.Analysis.sources,'fbands')
                CONN_x.Analyses(CONN_x.Analysis).regressors.fbands=batch.Analysis.sources.fbands;
            else
                CONN_x.Analyses(CONN_x.Analysis).regressors.fbands=repmat({1},1,numel(batch.Analysis.sources.names));
            end
        end
    end
    if isfield(batch.Analysis,'measures')
        batch.Analysis.analysis_number=0;
        if isempty(batch.Analysis.measures),
            CONN_x.vvAnalyses.regressors.names={};
        elseif ~isstruct(batch.Analysis.measures),
            CONN_x.vvAnalyses.regressors.names=batch.Analysis.measures;
            CONN_x.vvAnalyses.regressors.measuretype=repmat({[]},size(batch.Analysis.measures));
            CONN_x.vvAnalyses.regressors.global=repmat({[]},size(batch.Analysis.measures));
            CONN_x.vvAnalyses.regressors.localsupport=repmat({[]},size(batch.Analysis.measures));
            CONN_x.vvAnalyses.regressors.deriv=repmat({[]},size(batch.Analysis.measures));
            CONN_x.vvAnalyses.regressors.norm=repmat({[]},size(batch.Analysis.measures));
            CONN_x.vvAnalyses.regressors.filename=repmat({''},size(batch.Analysis.measures));
            CONN_x.vvAnalyses.regressors.dimensions_in=repmat({[]},size(batch.Analysis.measures));
            CONN_x.vvAnalyses.regressors.dimensions_out=repmat({[]},size(batch.Analysis.measures));
        else
            if ~isfield(batch.Analysis.measures,'measureclass'),batch.Analysis.measures.measureclass=repmat({[]},size(batch.Analysis.measures.names)); end
            if ~isfield(batch.Analysis.measures,'type'),batch.Analysis.measures.type=repmat({[]},size(batch.Analysis.measures.names)); end
            if ~isfield(batch.Analysis.measures,'kernelsupport'),batch.Analysis.measures.kernelsupport=repmat({[]},size(batch.Analysis.measures.names)); end
            if ~isfield(batch.Analysis.measures,'kernelshape'),batch.Analysis.measures.kernelshape=repmat({[]},size(batch.Analysis.measures.names)); end
            if ~isfield(batch.Analysis.measures,'dimensions'),batch.Analysis.measures.dimensions=repmat({[]},size(batch.Analysis.measures.names)); end
            if ~isfield(batch.Analysis.measures,'factors'),batch.Analysis.measures.factors=repmat({[]},size(batch.Analysis.measures.names)); end
            if ~isfield(batch.Analysis.measures,'norm'),batch.Analysis.measures.norm=repmat({[]},size(batch.Analysis.measures.names)); end
            if ~isfield(batch.Analysis.measures,'dimensions_in'),batch.Analysis.measures.dimensions_in=batch.Analysis.measures.dimensions; end
            if ~isfield(batch.Analysis.measures,'dimensions_out'),batch.Analysis.measures.dimensions_out=batch.Analysis.measures.factors; end
            CONN_x.vvAnalyses.regressors.names=batch.Analysis.measures.names;
            CONN_x.vvAnalyses.regressors.measuretype=batch.Analysis.measures.measureclass;
            CONN_x.vvAnalyses.regressors.localsupport=batch.Analysis.measures.kernelsupport;
            CONN_x.vvAnalyses.regressors.global=batch.Analysis.measures.type;
            CONN_x.vvAnalyses.regressors.deriv=batch.Analysis.measures.kernelshape;
            CONN_x.vvAnalyses.regressors.norm=batch.Analysis.measures.norm;
            CONN_x.vvAnalyses.regressors.filename=repmat({''},size(batch.Analysis.measures.names));
            CONN_x.vvAnalyses.regressors.dimensions_in=batch.Analysis.measures.dimensions_in;
            CONN_x.vvAnalyses.regressors.dimensions_out=batch.Analysis.measures.dimensions_out;
        end
    end
    
    if isfield(batch.Analysis,'done')&&batch.Analysis.done,
        conn save;
        if ~isfield(batch.Analysis,'overwrite'), batch.Analysis.overwrite='Yes'; end
        if isscalar(batch.Analysis.overwrite)&&~isstruct(batch.Analysis.overwrite)&&ismember(double(batch.Analysis.overwrite),[1 89 121]), batch.Analysis.overwrite='Yes'; end
        CONN_x.gui=struct('overwrite',batch.Analysis.overwrite,'subjects',SUBJECTS);
        if isfield(batch,'parallel')&&isfield(batch.parallel,'N')&&batch.parallel.N>0, 
            PAR_CMD{end+1}='Analyses'; 
            if ~isfield(batch.Analysis,'analysis_number'), PAR_ARG{end+1}={CONN_x.gui}; 
            else PAR_ARG{end+1}={CONN_x.gui, batch.Analysis.analysis_number}; 
            end
        else
            if ~isfield(batch.Analysis,'analysis_number'), conn_process('Analyses');
            else conn_process('Analyses',batch.Analysis.analysis_number);
            end
            CONN_x.gui=1;
            conn save;
        end
    else
        if isfield(batch,'filename'),
            conn save;
        end
    end
end

% parallel submission
if isfield(batch,'parallel')&&isfield(batch.parallel,'N')&&batch.parallel.N>0,
    conn save;
    if isfield(batch.parallel,'profile'), conn_jobmanager('setprofile',batch.parallel.profile); end
    info=conn_jobmanager('submit',PAR_CMD,SUBJECTS,batch.parallel.N,PAR_ARG);
    if ~isfield(batch.parallel,'immediatereturn')||~batch.parallel.immediatereturn, conn_jobmanager('waitfor',info); end
end

%% RESULTS step
if isfield(batch,'Results'),
    if isfield(batch,'filename'),
        CONN_x.filename=batch.filename;
        CONN_x.gui=0;
        conn load;                      % loads existing conn_* project
        CONN_x.gui=1;
    end
    if isfield(batch.Results,'between_measures'), batch.Results.analysis_number=0; end
    if ~isfield(batch.Results,'analysis_number')||isempty(batch.Results.analysis_number), batch.Results.analysis_number=1; end
    if ischar(batch.Results.analysis_number)
        ianalysis=strmatch(batch.Results.analysis_number,{CONN_x.Analyses.name},'exact');
        if isempty(ianalysis), error('unrecognized analysis %s',batch.Results.analysis_number); end
        batch.Results.analysis_number=ianalysis;
    end
    if batch.Results.analysis_number>0, CONN_x.Analysis=batch.Results.analysis_number; end
    if isfield(batch.Results,'foldername'),CONN_x.Results.foldername=batch.Results.foldername;else CONN_x.Results.foldername=''; end

    if isfield(batch.Results,'between_subjects')&&~isempty(batch.Results.between_subjects),
        for neffect=1:length(batch.Results.between_subjects.effect_names),
            idx=strmatch(batch.Results.between_subjects.effect_names{neffect},CONN_x.Setup.l2covariates.names,'exact');
            if isempty(idx),
                nl2covariates=length(CONN_x.Setup.l2covariates.names);
                CONN_x.Setup.l2covariates.names{nl2covariates}=batch.Results.between_subjects.effect_names{neffect};
                CONN_x.Setup.l2covariates.names{nl2covariates+1}=' ';
                for nsub=1:CONN_x.Setup.nsubjects,
                    CONN_x.Setup.l2covariates.values{nsub}{nl2covariates}=batch.Results.between_subjects.effects{neffect}(nsub);
                end
            end
        end
        CONN_x.Results.xX.nsubjecteffects=zeros(1,length(batch.Results.between_subjects.effect_names));
        for neffect=1:length(batch.Results.between_subjects.effect_names),
            idx=strmatch(batch.Results.between_subjects.effect_names{neffect},CONN_x.Setup.l2covariates.names,'exact');
            if isempty(idx), error(['unknown subject effect ',batch.Results.between_subjects.effect_names{neffect}]); return;
            else, CONN_x.Results.xX.nsubjecteffects(neffect)=idx(1); end
        end
        CONN_x.Results.xX.csubjecteffects=batch.Results.between_subjects.contrast;
        
        if ~isfield(batch.Results,'between_conditions')||isempty(batch.Results.between_conditions),
            clear batchtemp;
            if isfield(batch,'filename'), batchtemp.filename=batch.filename; else, batchtemp.filename=CONN_x.filename; end
            batchtemp.Results=batch.Results;
            for ncondition=1:length(CONN_x.Setup.conditions.names)-1,
                batchtemp.Results.between_conditions.effect_names={CONN_x.Setup.conditions.names{ncondition}};
                batchtemp.Results.between_conditions.contrast=[1];
                conn_batch(batchtemp);
            end
        else
            CONN_x.Results.xX.nconditions=zeros(1,length(batch.Results.between_conditions.effect_names));
            for neffect=1:length(batch.Results.between_conditions.effect_names),
                idx=strmatch(batch.Results.between_conditions.effect_names{neffect},CONN_x.Setup.conditions.names,'exact');
                if isempty(idx), error(['unknown condition ',batch.Results.between_conditions.effect_names{neffect}]); return;
                else, CONN_x.Results.xX.nconditions(neffect)=idx(1); end
            end
            CONN_x.Results.xX.cconditions=batch.Results.between_conditions.contrast;
            
            if isfield(batch.Results,'done')&&batch.Results.done&&batch.Results.analysis_number>0&&any(CONN_x.Analyses(CONN_x.Analysis).type==[1,3]),
                CONN_x.gui=struct('overwrite','Yes');
                conn_process('results_roi');
                CONN_x.gui=1;
                CONN_x.Results.foldername=[];
                conn save;
            end
            
            if batch.Results.analysis_number>0&&any(CONN_x.Analyses(CONN_x.Analysis).type==[2,3]) && (~isfield(batch.Results,'between_sources')||isempty(batch.Results.between_sources)),
                clear batchtemp;
                if isfield(batch,'filename'), batchtemp.filename=batch.filename; else, batchtemp.filename=CONN_x.filename; end
                batchtemp.Results=batch.Results;
                for nsource=1:length(CONN_x.Analyses(CONN_x.Analysis).sources),
                    batchtemp.Results.between_sources.effect_names={CONN_x.Analyses(CONN_x.Analysis).sources{nsource}};
                    batchtemp.Results.between_sources.contrast=[1];
                    conn_batch(batchtemp);
                end
            elseif batch.Results.analysis_number==0 && (~isfield(batch.Results,'between_measures')||isempty(batch.Results.between_measures)),
                clear batchtemp;
                if isfield(batch,'filename'), batchtemp.filename=batch.filename; else, batchtemp.filename=CONN_x.filename; end
                batchtemp.Results=batch.Results;
                for nmeasure=1:length(CONN_x.vvAnalyses.regressors.names),
                    batchtemp.Results.between_measures.effect_names={CONN_x.vvAnalyses.regressors.names{nmeasure}};
                    batchtemp.Results.between_measures.contrast=[1];
                    conn_batch(batchtemp);
                end
            elseif isfield(batch.Results,'between_sources')&&batch.Results.analysis_number>0&&any(CONN_x.Analyses(CONN_x.Analysis).type==[2,3]),
                CONN_x.Results.xX.nsources=zeros(1,length(batch.Results.between_sources.effect_names));
                for neffect=1:length(batch.Results.between_sources.effect_names),
                    idx=strmatch(batch.Results.between_sources.effect_names{neffect},CONN_x.Analyses(CONN_x.Analysis).sources,'exact');
                    if isempty(idx), error(['unknown source ',batch.Results.between_sources.effect_names{neffect}]); return;
                    else, CONN_x.Results.xX.nsources(neffect)=idx(1); end
                end
                CONN_x.Results.xX.csources=batch.Results.between_sources.contrast;
                conn save;
                
                if isfield(batch.Results,'done')&&batch.Results.done,
                    CONN_x.gui=struct('overwrite','Yes');
                    conn_process('results_voxel','dosingle','seed-to-voxel');
                    CONN_x.gui=1;
                    CONN_x.Results.foldername=[];
                    conn save;
                end
            elseif isfield(batch.Results,'between_measures')&&batch.Results.analysis_number==0
                CONN_x.Results.xX.nmeasures=zeros(1,length(batch.Results.between_measures.effect_names));
                for neffect=1:length(batch.Results.between_measures.effect_names),
                    idx=strmatch(batch.Results.between_measures.effect_names{neffect},CONN_x.vvAnalyses.regressors.names,'exact');
                    if isempty(idx), error(['unknown measure ',batch.Results.between_measures.effect_names{neffect}]); return;
                    else, CONN_x.Results.xX.nmeasures(neffect)=idx(1); end
                end
                CONN_x.Results.xX.cmeasures=batch.Results.between_measures.contrast;
                conn save;
                
                if isfield(batch.Results,'done')&&batch.Results.done,
                    CONN_x.gui=struct('overwrite','Yes');
                    conn_process('results_voxel','dosingle','voxel-to-voxel');
                    CONN_x.gui=1;
                    CONN_x.Results.foldername=[];
                    conn save;
                end
            end
        end
    end
end

end

function conn_batch_eval(filename)
str=fileread(filename);
str=regexprep(str,'\s*function .*?\n(.*?)(end[\s\n]*)?$','$1');
evalin('base',str);
end


