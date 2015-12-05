function conn_batch_workshop_nyudataset_parallel(varargin)
% (same as conn_batch_workshop_nyudataset but running in parallel Grid Engine computer cluster)
%
% batch process the NYU_CSC_TestRetest dataset (published in Shehzad et al., 2009, The Resting Brain: Unconstrained yet Reliable. Cerebral Cortex. doi:10.1093/cercor/bhn256)
% 
% Steps:
% 1. Run conn_batch_workshop_nyudataset_parallel. The script will:
%       a) Download the entire dataset from: http://www.nitrc.org/projects/nyu_trt/ (6 NYU_TRT_session*.tar.gz files)
%       b) Decompress the NYU_TRT_session*.tar.gz files into NYU_TRT_session* folders
%          Decompress the *.nii.gz files
%       c) Preprocessing of the anatomical and functional volumes
%         (normalization & segmentation of anatomical volumes; realignment,
%         coregistration, normalization, outlier detection, and smooting of the 
%         functional volumes)
%       d) Estimate first-level seed-to-voxel connectivity maps for each of 
%         the default seeds (located in the conn/rois folder), separately 
%         for each subject and for each of the three test-retest sessions.
%
% Optionally, to download only a portion of the data, specify the desired data subsets (1a,1b,2a,2b,3a,3b) as additional arguments. For example:
%   conn_batch_workshop_nyudataset_parallel 1a;           % downloads and processes only 13-subjects one-session data 
%   conn_batch_workshop_nyudataset_parallel 1a 1b;        % downloads and processes only 25-subjects one-session data 
%   conn_batch_workshop_nyudataset_parallel 1a 2a 3a;     % downloads and processes only 13-subjects three-session data 
%       
%

OVERWRITE=false;    % skip downloading/uncompressing already-existing files/folders
DOWNLOADFILES=true; % set to false if already manually-downloaded the dataset (or a portion of it)
UNZIPFILES=true;    % set to false if already manually-unzipped the dataset
if ~nargin, data={'1a','1b','2a','2b','3a','3b'}; % define the subsets to be downloaded (all data by default) 
else        data=varargin;
end

%% DOWNLOAD *.tar.gz files
if DOWNLOADFILES
    for n=1:numel(data), 
        filename=['NYU_TRT_session',data{n},'.tar.gz'];
        if OVERWRITE||~exist(filename,'file')
            fprintf('Downloading %s (file %d/%d). This process may take several minutes. Please wait...\n',filename,n,numel(data));
            urlwrite(sprintf('http://www.nitrc.org/frs/download.php/%d/%s',1070+find(ismember({'1a','1b','2a','2b','3a','3b'},data{n})),filename),filename);
        end
    end
end
NSUBJECTS=0;
if any(ismember(data,{'1a','2a','3a'})), NSUBJECTS=NSUBJECTS+13; end
if any(ismember(data,{'1b','2b','3b'})), NSUBJECTS=NSUBJECTS+12; end

%% UNTAR .tar.gz files
if UNZIPFILES
    a=dir('NYU_TRT_session*.tar.gz');
    for n1=1:length(a),
        [a_path,a_name,a_ext]=fileparts(a(n1).name);[nill,a_name2,a_ext2]=fileparts(a_name);
        dirname=fullfile(a_path,a_name2);
        if ~isdir(dirname),
            disp(['extracting contents from file ',a(n1).name]);
            untar(a(n1).name,dirname);
        end
    end
    %% UNZIP .nii.gz files
    a=strvcat(conn_dir('lfo.nii.gz'),conn_dir('mprage_skullstripped.nii.gz'));
    for n1=1:size(a,1),
        [a_path,a_name,a_ext]=fileparts(a(n1,:));
        if isempty(dir(fullfile(a_path,a_name))),
            disp(['unzipping file ',a(n1,:)]);
            gunzip(deblank(a(n1,:)));
        end
    end
end

%% FIND functional/structural files
cwd=pwd;
FUNCTIONAL_FILE=cellstr(conn_dir('lfo.nii'));
STRUCTURAL_FILE=cellstr(conn_dir('mprage_skullstripped.nii'));
if rem(length(FUNCTIONAL_FILE),NSUBJECTS),error('mismatch number of functional files %n', length(FUNCTIONAL_FILE));end
if rem(length(STRUCTURAL_FILE),NSUBJECTS),error('mismatch number of anatomical files %n', length(FUNCTIONAL_FILE));end
nsessions=length(FUNCTIONAL_FILE)/NSUBJECTS;
FUNCTIONAL_FILE=reshape(FUNCTIONAL_FILE,[NSUBJECTS,nsessions]);
STRUCTURAL_FILE={STRUCTURAL_FILE{1:NSUBJECTS}};
disp([num2str(size(FUNCTIONAL_FILE,1)),' subjects']);
disp([num2str(size(FUNCTIONAL_FILE,2)),' sessions']);
TR=2; % Repetition time = 2 seconds

%% Prepares batch structure
clear batch;
batch.filename=fullfile(cwd,'conn_NYU.mat');            % New conn_*.mat experiment name
batch.parallel.N=NSUBJECTS;                             % One process per subject (uses default Grid-settings profile)

%% SETUP & PREPROCESSING step (using default values for most parameters, see help conn_batch to define non-default values)
% CONN Setup                                            % Default options (uses all ROIs in conn/rois/ directory); see conn_batch for additional options 
% CONN Setup.preprocessing                               (realignment/coregistration/segmentation/normalization/smoothing)
batch.Setup.isnew=1;
batch.Setup.nsubjects=NSUBJECTS;
batch.Setup.RT=TR;                                        % TR (seconds)
batch.Setup.functionals=repmat({{}},[NSUBJECTS,1]);       % Point to functional volumes for each subject/session
for nsub=1:NSUBJECTS,for nses=1:nsessions,batch.Setup.functionals{nsub}{nses}{1}=FUNCTIONAL_FILE{nsub,nses}; end; end %note: each subject's data is defined by three sessions and one single (4d) file per session
batch.Setup.structurals=STRUCTURAL_FILE;                  % Point to anatomical volumes for each subject
nconditions=nsessions;                                  % treats each session as a different condition (comment the following three lines and lines 84-86 below if you do not wish to analyze between-session differences)
if nconditions==1
    batch.Setup.conditions.names={'rest'};
    for ncond=1,for nsub=1:NSUBJECTS,for nses=1:nsessions,              batch.Setup.conditions.onsets{ncond}{nsub}{nses}=0; batch.Setup.conditions.durations{ncond}{nsub}{nses}=inf;end;end;end     % rest condition (all sessions)
else
    batch.Setup.conditions.names=[{'rest'}, arrayfun(@(n)sprintf('Session%d',n),1:nconditions,'uni',0)];
    for ncond=1,for nsub=1:NSUBJECTS,for nses=1:nsessions,              batch.Setup.conditions.onsets{ncond}{nsub}{nses}=0; batch.Setup.conditions.durations{ncond}{nsub}{nses}=inf;end;end;end     % rest condition (all sessions)
    for ncond=1:nconditions,for nsub=1:NSUBJECTS,for nses=1:nsessions,  batch.Setup.conditions.onsets{1+ncond}{nsub}{nses}=[];batch.Setup.conditions.durations{1+ncond}{nsub}{nses}=[]; end;end;end
    for ncond=1:nconditions,for nsub=1:NSUBJECTS,for nses=ncond,        batch.Setup.conditions.onsets{1+ncond}{nsub}{nses}=0; batch.Setup.conditions.durations{1+ncond}{nsub}{nses}=inf;end;end;end % session-specific conditions
end
batch.Setup.preprocessing.steps='default_mni';
batch.Setup.preprocessing.sliceorder='interleaved (Siemens)';
batch.Setup.done=1;
batch.Setup.overwrite='Yes';                            


%% DENOISING step
% CONN Denoising                                    % Default options (uses White Matter+CSF+realignment+conditions as confound regressors); see conn_batch for additional options 
batch.Denoising.filter=[0.01, 0.1];                 % frequency filter (band-pass values, in Hz)
batch.Denoising.done=1;
batch.Denoising.overwrite='Yes';


%% FIRST-LEVEL ANALYSIS step
% CONN Analysis                                     % Default options (uses all ROIs in conn/rois/ as connectivity sources); see conn_batch for additional options 
batch.Analysis.done=1;
batch.Analysis.overwrite='Yes';

%% Run all analyses
conn_batch(batch);

%% CONN Display
% launches conn gui to explore results
conn
conn('load',fullfile(cwd,'conn_NYU.mat'));
conn gui_results

