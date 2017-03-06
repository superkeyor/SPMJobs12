% This example script runs a decoding analysis on the example data that can
% be downloaded from the TDT webpage. It performs searchlight decoding
% between left and right button presses using a 2-fold cross-validation
% scheme in which splits the data in even and odd session.
%
% The extracted data is assumed in 
%   'C:\TDT' (windows) or '/TDT' (mac, linux). 
% Thus, the full path to the data is assumed to be windows:
%    C:\TDT\sub01_firstlevel_reducedResolution\sub01_GLM_3x3x3mm
%       (slighlty downsampled data)
%  or 
%    C:\TDT\sub01_firstlevel\sub01_GLM 
%       (higher quality data)
%
% If you put the data somewhere else, the script will ask you for the path.
%
% The results will be written in a result directory in the directory where
% the data is.
%
% This version takes assumes you use SPM, because the example data has been 
% processed with SPM.
%
% You can change cfg.analysis = 'searchlight' to either 'ROI' or
% 'wholebrain' and see how it works. The output of this script can be used
% for demo9_permutation_analysis.
%
% Happy decoding!
%
% Kai 2016/07/24

%% Check that SPM and TDT are available on the path
if isempty(which('SPM')), error('Please add SPM to the path and restart'), end
if isempty(which('decoding_defaults')), error('Please add TDT to the path and restart'), end
decoding_defaults; % add all important directories to the path

%% Locate data directory
% In you script, this part looks like 
%   beta_loc = '/path_to_datadirectory'
% Here it is only longer because its a demo

if ispc, databasedir = 'C:\TDT'; else databasedir = '/TDT'; end
check_subdirs = {'sub01_firstlevel_reducedResolution/sub01_GLM_3x3x3mm'; 'sub01_firstlevel/sub01_GLM'};
for c_ind = 1:length(check_subdirs)
    d = fullfile(databasedir, check_subdirs{c_ind});
    if exist(d, 'dir')
        beta_loc = d;
        break
    end
end
if isempty(beta_loc)
    beta_loc = uigetdir('', 'Select the sub01_GLM* directory from the demo data (inside sub01_firstlevel*)');
end

% Check that data is really in that directory
try
    c = design_from_spm(beta_loc);
catch
    error('Seems %s is not the correct directory with the demo data, because it does not contain any SPM or *_SPM.mat. Please check and restart the script', beta_loc)
end
expected_first_regressor = 'color';
if ~strcmp(c{1}, expected_first_regressor)
    error('The directory %s contains SPM data, but it does not seem to contain the demo data, because the first regressor is "%s" and not "%s" as expected. Please check and restart the script', beta_loc, c{1}, expected_first_regressor)
end
dispv(1, 'Located demodata in %s, starting analysis', beta_loc);

%% First, set the defaults and define the analysis you want to perform
cfg = decoding_defaults;
cfg.testmode = 0;
if cfg.testmode, display('Testmode'), keyboard, end

% Enter which analysis method you like
% The standard decoding method is searchlight, but we should still enter 
% it to be on the safe side.
cfg.analysis = 'searchlight'; % 'searchlight', 'wholebrain', 'ROI' (if ROI, set one or multiple ROI images as mask files below instead of the mask)

% Specify where the results should be saved
cfg.results.dir = fullfile(beta_loc, 'results', 'motion_up_vs_down', cfg.analysis); % e.g. /TDT/data_loc/results/searchlight
cfg.results.overwrite = 1;

%% Second, get the file names, labels and run number of each brain image
% file to use for decoding.

% For example, you might have 6 runs and two categories. That should give 
% you 12 images, one per run and category. Each image has an associated 
% filename, run number and label (= category). With that information, you
% can for example do a leave-one-run-out cross validation.

% There are two ways to get the information we need, depending on what you 
% have done previously. The first way is easier.

% === Automatic Creation === 
% a) If you generated all parameter estimates (beta images) in SPM and were 
% using only one model for all runs (i.e. have only one SPM.mat file), use
% the following block.

% Specify the directory to your SPM.mat and all related beta images:
% beta_loc = '/path_to_exampledata'; 
% display regressors are in that directory
display_regressor_names(beta_loc);
% Specify the label names that you gave your regressors of interest in the 
% SPM analysis (e.g. 'button left' and 'button right').
% Case sensitive!
labelname1 = ['up'];
labelname2 = ['down'];

%% Set brain mask or or ROIs
% Also set the path to the brain mask(s) (e.g.  created by SPM: mask.img). 
% Alternatively, you can specify (multiple) ROI masks as a cell or string 
% matrix) if you want to perform a ROI analysis, e.g. 
%   cfg.files.mask = fullfile('ROIdir', {'ROI1.img', 'ROI2.img'})
% Example data ROI files (here functionally defined V1 & MT, w indicates normalized image)
if strcmp(cfg.analysis, 'ROI')
    if exist(fullfile(beta_loc, '..', 'sub01_ROI_3x3x3mm'), 'dir')
        cfg.files.mask = fullfile(beta_loc, '..', 'sub01_ROI_3x3x3mm', {'wv1.img', 'wmt_both.img'}); % reduce data
    elseif exist(fullfile(beta_loc, '..', 'sub01_ROI'), 'dir')
        cfg.files.mask = fullfile(beta_loc, '..', 'sub01_ROI', {'wv1.img', 'wmt_both.img'}); % reduce data
    else
        cfg.files.mask = uigetfile('', 'Could not automatically find ROI folder, please select which ROIs to use');
    end
else
    cfg.files.mask = fullfile(beta_loc, 'mask.img');
end

%% Get information from SPM
% The following function extracts all beta names and corresponding run
% numbers from the SPM.mat (and adds 'bin 1' to 'bin m', if a FIR design 
% was used)
regressor_names = design_from_spm(beta_loc);

% Now with the names of the labels, we can extract the filenames and the 
% run numbers of each label. The labels will be -1 and 1.
% Important: You have to make sure to get the label names correct and that
% they have been uniquely assigned, so please check them in regressor_names
cfg = decoding_describe_data(cfg,{labelname1 labelname2},[-1 1],regressor_names,beta_loc);
%
% Other examples:
% For a cross classification, it would look something like this:
% cfg = decoding_describe_data(cfg,{labelname1classA labelname1classB labelname2classA labelname2classB},[1 -1 1 -1],regressor_names,beta_loc,[1 1 2 2]);
%
% Or for SVR with a linear relationship like this:
% cfg = decoding_describe_data(cfg,{labelname1 labelname2 labelname3 labelname4},[-1.5 -0.5 0.5 1.5],regressor_names,beta_loc);

% === Manual Creation ===
% Alternatively, you can also manually prepare the files field.
% For this, you have to load all images and labels you want to use 
% separately, e.g. with spm_select. This is not part of this example, but 
% if you do it later, you should end up with the following fields:
%   cfg.files.name: a 1xn cell array of file names
%   cfg.files.chunk: a 1xn vector of run numbers
%   cfg.files.label: a 1xn vector of labels (for decoding, you can choose 
%       any two numbers as class labels)

%% Third, create your design for the decoding analysis

% In a design, there are several matrices, one for training, one for test,
% and one for the labels that are used (there is also a set vector which we
% don't need right now). In each matrix, a column represents one decoding 
% step (e.g. cross-validation run) while a row represents one sample (i.e.
% brain image). The decoding analysis will later iterate over the columns 
% of this design matrix. For example, you might start off with training on 
% the first 5 runs and leaving out the 6th run. Then the columns of the 
% design matrix will look as follows (we also add the run numbers and file
% names to make it clearer):
% cfg.design.train cfg.design.test cfg.design.label cfg.files.chunk  cfg.files.name
%        1                0              -1               1         ..\beta_0001.img
%        1                0               1               1         ..\beta_0002.img
%        1                0              -1               2         ..\beta_0009.img 
%        1                0               1               2         ..\beta_0010.img 
%        1                0              -1               3         ..\beta_0017.img 
%        1                0               1               3         ..\beta_0018.img 
%        1                0              -1               4         ..\beta_0025.img 
%        1                0               1               4         ..\beta_0026.img 
%        1                0              -1               5         ..\beta_0033.img 
%        1                0               1               5         ..\beta_0034.img 
%        0                1              -1               6         ..\beta_0041.img 
%        0                1               1               6         ..\beta_0042.img 

% Again, a design can be created automatically (with a design function) or
% manually. If you use a design more often, then it makes sense to create
% your own design function.
%
% If you are a bit confused what the three matrices (train, test & label)
% mean, have a look at them in cfg.design after you executed the next step.
% This should make it easier to understand.

% === Automatic Creation ===
% We change the chunk variable to get a split half design, using all uneven 
% runs as training set and all even runs as validation set in the first
% fold, and vice versa in the second fold
cfg.files.chunk = 2 - mod(cfg.files.chunk, 2); % this will change all uneven chunk values to 1, and all even values to 2
cfg.design = make_design_cv(cfg); % creating a cv design with the updated chunks

% This creates the leave-one-run-out cross validation design:
% cfg.design = make_design_cv(cfg);

% === Automatic Creation - alternative ===
% Alternatively, you can create the design during runtim of the decoding 
% function, by specifying the following parameter:
% cfg.design.function.name = 'make_design_cv';
% For the current example, this is not helpful, because you can already
% create the design now. However, you might run into cases in which you
% can't create the design at this stage (e.g. if your design depends on the
% outcome of some previous runs, and then this function will become handy.

% === Manual Creation ===
% After having explained the structure of the design file above, it should
% be easy to create the structure yourself. You can then check it by visual
% inspection. Dependencies between training and test set will be checked
% automatically in the main function.

% if you want to see your design matrix, use
plot_design(cfg); % as figure
display_design(cfg); % as text in console

%% Fourth, set additional parameters manually

% This is an optional step. For example, you want to set the searchlight 
% radius and you have non-isotropic voxels (e.g. 3x3x3.75mm), but want the
% searchlight to be spherical in real space.

% Searchlight-specific parameters
cfg.searchlight.unit = 'mm'; % without this line, the default is to use voxels
cfg.searchlight.radius = 12; % this will yield a searchlight radius of 12mm.
cfg.searchlight.spherical = 0; % do not care if the searchlight is spherical (default)

% Other parameters of interest:
% The verbose level allows you to determine how much output you want to see
% on the console while the program is running (0: no output, 1: normal 
% output, 2: high output).
cfg.verbose = 1;

% parameters for libsvm (linear SV classification, cost = 1, no screen output)
% cfg.decoding.train.classification.model_parameters = '-s 0 -t 0 -c 1 -b 0 -q'; 

% Get different outputs
cfg.results.output = {'accuracy_minus_chance'}; % here you can add other measures, e.g. 'predicted_labels' if you want to get the precited label for each input data point. See decoding_transform_results for more.
if strcmp(cfg.analysis, 'searchlight')
    cfg.plot_selected_voxels = 100; % Show the searchlight at every 100' steps to not waste much time with drawing
else
    cfg.plot_selected_voxels = 1; % Show every steps
end

%% Fifth, run the decoding analysis

% Fingers crossed it will not generate any error messages ;)
[results, cfg] = decoding(cfg);
