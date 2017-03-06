% This script is the default template, but with a modification that allows
% balancing confounds. The two main approaches for controlling for
% confounds are balancing confounds (by subsampling, supersampling,
% or weighted classification) or analyzing data separately for each
% confound. The approach in this file is subsampling using an ensemble
% approach that has the advantage of using all data in one classification
% step, rather than combining multiple weak classification analyses
% together.
% Same as the standard template, this is for people who have betas
% available from an SPM.mat and want to automatically extract the relevant
% images used for classification, as well as corresponding labels and
% decoding chunk numbers (e.g. run numbers). If you don't want this,
% combine the relevant parts of this script with decoding_template_nobetas.

% Set defaults
cfg = decoding_defaults;

% Set the analysis that should be performed (default is 'searchlight')
cfg.analysis = 'searchlight';
cfg.searchlight.radius = 3; % use searchlight of radius 3 (by default in voxels), see more details below

% Set the output directory where data will be saved, e.g. 'c:\exp\results\buttonpress'
cfg.results.dir = 

% Set the filepath where your SPM.mat and all related betas are, e.g. 'c:\exp\glm\model_button'
beta_loc = 

% Set the filename of your brain mask (or your ROI masks as cell matrix) 
% for searchlight or wholebrain e.g. 'c:\exp\glm\model_button\mask.img' OR 
% for ROI e.g. {'c:\exp\roi\roimaskleft.img', 'c:\exp\roi\roimaskright.img'}
% You can also use a mask file with multiple masks inside that are
% separated by different integer values (a "multi-mask")
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
cfg.plot_selected_voxels = 0; % 0: no plotting, 1: every step, 2: every second step, 100: every hundredth step...
cfg.plot_design = 0;

%% Add additional output measures if you like
% See help decoding_transform_results for possible measures

% cfg.results.output = {'accuracy_minus_chance', 'AUC'}; % 'accuracy_minus_chance' by default

% You can also use all methods that start with "transres_", e.g. use
%   cfg.results.output = {'SVM_pattern'};
% will use the function transres_SVM_pattern.m to get the pattern from 
% linear svm weights (see Haufe et al, 2015, Neuroimage)

%% Below reflects the default for a standard leave-one-run-out crossvalidation analysis

% The following function extracts all beta names and corresponding run
% numbers from the SPM.mat
regressor_names = design_from_spm(beta_loc);

% Extract all information for the cfg.files structure (labels will be [1 -1] )
cfg = decoding_describe_data(cfg,{labelname1 labelname2},[1 -1],regressor_names,beta_loc);

% This creates the leave-one-run-out cross validation design:
cfg.design = make_design_cv(cfg); 

%% HOW WE DEAL WITH CONFOUNDS BY BALANCING AND ENSEMBLE CLASSIFICATION

% add a nx1 vector to index the confound. Must be a categorical variable,
% otherwise control by subsampling is not possible. For continuous
% variables binning is an option
cfg.files.confound = 

% These settings are an example and should be self-explanatory
cfg.design.unbalanced_data = 'ok';
cfg.decoding.software = 'ensemble_balance';
cfgd = decoding_defaults; % to use default values
cfg.decoding.train.classification_kernel.model_parameters.software = 'libsvm';
cfg.decoding.train.classification_kernel.model_parameters.n_iter = 100;
cfg.decoding.train.classification_kernel.model_parameters.model_parameters = cfgd.decoding.train.classification_kernel.model_parameters;
cfg.decoding.test.classification_kernel.model_parameters.model_parameters = cfgd.decoding.test.classification_kernel.model_parameters;
cfg.results.output = {'balanced_accuracy_minus_chance'};

% Run decoding
results = decoding(cfg);