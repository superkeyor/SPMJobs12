% This script is a template that can be used for a decoding analysis on 
% brain image data. It is for people who ran one deconvolution per run
% using AFNI and want to automatically extract the relevant images used for
% classification, as well as corresponding labels and decoding chunk numbers
% (e.g. run numbers). If you don't have this available, then use
% decoding_template_nobetas.m

% Set defaults
cfg = decoding_defaults;

% Set the analysis that should be performed (default is 'searchlight')
cfg.analysis = 'searchlight';
cfg.searchlight.radius = 3; % use searchlight of radius 3 (by default in voxels), see more details below

% Set the output directory where data will be saved, e.g. '/misc/data/mystudy'
cfg.results.dir = 

% Set the full path to the files where your coefficients for each run are stored e.g. 
% {'/misc/data/mystudy/results1+orig.BRIK','/misc/data/mystudy/results2+orig.BRIK',...}
beta_loc = 

% Set the filename of your brain mask (or your ROI masks as cell matrix) 
% for searchlight or wholebrain e.g. '/misc/data/mystudy/mask+orig.BRIK' OR 
% for ROI e.g. {'/misc/data/mystudy/roimask1+orig.BRIK', '/misc/data/mystudy/roimask2+orig.BRIK'}
% You can also use a mask file with multiple masks inside that are
% separated by different integer values (a "multi-mask")
%
% If you don't have a brain mask, use 3dAutomask or run
% cfg.files.mask = decoding_create_maskfile(cfg,beta_loc);
cfg.files.mask = 

% Set the label names to the regressor names which you want to use for 
% decoding, e.g. 'button left' and 'button right'
% don't remember the names? -> run display_regressor_names(beta_loc)
labelname1 = 
labelname2 = 

%% Set additional parameters
% Set additional parameters manually if you want (see decoding.m or
% decoding_defaults.m). Below some example parameters that you might want 
% to use a searchlight with radius 12 mm that is spherical:

% cfg.searchlight.unit = 'mm';
% cfg.searchlight.radius = 12; % if you use this, delete the other searchlight radius row at the top!
% cfg.searchlight.spherical = 1;
% cfg.verbose = 2; % you want all information to be printed on screen
% cfg.decoding.train.classification.model_parameters = '-s 0 -t 0 -c 1 -b 0 -q'; 
% cfg.results.output = {'accuracy_minus_chance','AUC_minus_chance'};

% Some other cool stuff
% Check out 
%   combine_designs(cfg, cfg2)
% if you like to combine multiple designs in one cfg.

%% Decide whether you want to see the searchlight/ROI/... during decoding
cfg.plot_selected_voxels = 500; % 0: no plotting, 1: every step, 2: every second step, 100: every hundredth step...

%% Add additional output measures if you like
% See help decoding_transform_results for possible measures

% cfg.results.output = {'accuracy_minus_chance', 'AUC'}; % 'accuracy_minus_chance' by default

% You can also use all methods that start with "transres_", e.g. use
%   cfg.results.output = {'SVM_pattern'};
% will use the function transres_SVM_pattern.m to get the pattern from 
% linear svm weights (see Haufe et al, 2015, Neuroimage)

%% Nothing needs to be changed below for a standard leave-one-run out cross
%% validation analysis.

% The following function extracts all beta names and corresponding run
% numbers from the SPM.mat
regressor_names = design_from_afni(beta_loc);

% Extract all information for the cfg.files structure (labels will be [1 -1] )
cfg = decoding_describe_data(cfg,{labelname1 labelname2},[1 -1],regressor_names,beta_loc);

% This creates the leave-one-run-out cross validation design:
cfg.design = make_design_cv(cfg); 

% Run decoding
results = decoding(cfg);