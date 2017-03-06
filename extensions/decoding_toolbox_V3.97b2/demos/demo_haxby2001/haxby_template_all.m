% This script performs multi-class searchlight decoding for the Haxby 2001
% dataset.
%
% The data is available free at http://dev.pymvpa.org/datadb/haxby2001.html
% and can be downloaded there. Accept their Terms of Use if you like to use 
% the dataset.
%
% This script hase been created by just filling out the decoding_template.m 
% provided with the TDT.
%
% To run it:
%   0. DOWNLOAD the dataset
%       See http://dx.doi.org/10.1126/science.1063736
%   1. ADAPT the paths below to 
%       - TDT (if not in your path anyway)
%       - SPM (if not in your path anyway)
%       - The Haxby Dataset
%   2. Create beta images (1st level in SPM) using 
%       run_all_sbjs_haxby_level1 in this script (adapt pathes there as
%       well)
%   3. Do decoding using
%       results = haxby_template_all(1); % 1: subject 1, change if you like
%
% Author: Kai

function results = haxby_template_all(sbj)

% directory that contains original Haxby dataset files from DOI: http://dx.doi.org/10.1126/science.1063736
base_dir = fullfile('z:', 'kai', 'haxby01'); 

%% Set defaults
cfg = decoding_defaults;
% Set the analysis that should be performed (default is 'searchlight')
cfg.analysis = 'searchlight';
% cfg.testmode = 1; % use if you just want a quick test, calculates 1 SL
% directory for current subject
sbj_dir = fullfile(base_dir, ['subj' num2str(sbj)]);

% Set the filepath where your SPM.mat and all related betas are, e.g. 'c:\exp\glm\model_button'
beta_loc = fullfile(sbj_dir, 'level1', 'all_runwise');

% Set the output directory where data will be saved, e.g. 'c:\exp\results\buttonpress'
cfg.results.dir = fullfile(sbj_dir, 'decoding', 'newtest', 'runwise_all_classes', 'all_classes');

% Set the filename of your brain mask (or your ROI masks as cell matrix) 
% for searchlight or wholebrain e.g. 'c:\exp\glm\model_button\mask.img' OR 
% for ROI e.g. {'c:\exp\roi\roimaskleft.img', 'c:\exp\roi\roimaskright.img'}
cfg.files.mask = fullfile(beta_loc, 'mask.nii')

% Set the label names to the regressor names which you want to use for 
% decoding, e.g. 'button left' and 'button right'
labelnames = {
        'face';
        'cat';
        'house';
        'chair';
        'scissors';
        'shoe'
        'bottle';
        'scrambledpix';
        };
% Set additional parameters manually if you want (see decoding.m or
% decoding_defaults.m). Below some example parameters that you might want 
% to use:

% cfg.searchlight.unit = 'mm';
% cfg.searchlight.radius = 12; % this will yield a searchlight radius of 12mm.
% cfg.searchlight.spherical = 1;
% cfg.verbose = 2; % you want all information to be printed on screen
% cfg.decoding.train.classification.model_parameters = '-s 0 -t 0 -c 1 -b 0 -q'; 
% cfg.results.output = {'accuracy_minus_chance','AUC_minus_chance'};

% Some other cool stuff
% Check out 
%   combine_designs(cfg, cfg2)
% if you like to combine multiple designs in one cfg.

% Decide whether you want to see the searchlight/ROI/... during decoding
cfg.plot_selected_voxels = 100; % 0: no plotting, 1: every step, 2: every second step, 100: every hundredth step...

% Add additional output measures if you like
% cfg.results.output = {'accuracy_minus_chance', 'AUC'}

%% Nothing needs to be changed below for a standard leave-one-run out cross
%% validation analysis.

% The following function extracts all beta names and corresponding run
% numbers from the SPM.mat
regressor_names = design_from_spm(beta_loc);

% Extract all information for the cfg.files structure (labels will be [1 -1] )
cfg = decoding_describe_data(cfg,labelnames,1:length(labelnames),regressor_names,beta_loc);

%% This creates the leave-one-run-out cross validation design:
cfg.design = make_design_cv(cfg); 

%% Run decoding
results = decoding(cfg);