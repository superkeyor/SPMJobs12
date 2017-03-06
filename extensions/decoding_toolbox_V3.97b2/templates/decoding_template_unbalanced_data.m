% This script is the default template, but with a modification that allows
% running analyses with unbalanced data. Multiple solutions are presented
% at the end of this script.
% Same as the standard template, this is for people who have betas
% available from an SPM.mat and want to automatically extract the relevant
% images used for classification, as well as corresponding labels and
% decoding chunk numbers (e.g. run numbers). If you don't have this
% available, then only use the parts specific to unbalanced data and for
% the rest use decoding_template_nobetas.m

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

%% HOW CAN WE DEAL WITH UNBALANCED DATA?
% There are multiple options
% 1. Supersampling: Sample test data repeatedly until the two sets are
% balanced again. Example: 30x class1, 70x class2, upsample class1 to 210
% and class2 to 210 (or upsample class1 to 70 with a slight bias towards
% some samples)
% PRO: uses all data
% CONs: may take longer, does not work properly for most classifiers
% -> currently not implemented in TDT
%
% 2. AUC_minus_chance: Bias-free method for results, provides information
% about classes irrespective of a preference for one class
% PROs: uses all data, fast
% CON: cannot always be used
% Implementation: 
% cfg.results.output = {'AUC_minus_chance'};
% cfg.design.unbalanced_data = 'ok';
%
% 3. Repeated subsampling: Subsample the more frequent class repeatedly,
% run multiple classification iterations and average results
% PROs: works also for true prediction cases, quite common approach
% CONs: slow, uses only subset of data on each iteration
% Implementation:
% n_boot = 500; % number of repetitions, fewer might also be ok
% balance_test = 0; % if test data is not balanced, this is ok, but you need to use balanced_accuracy in that case
% cfg.design = make_design_boot_cv(cfg,n_boot,balance_test); % this is the correct function for multiple chunks, for only one use make_design_boot
% cfg.results.output = {'balanced_accuracy_minus_chance'};
%
% 4. Balance ensemble approach: Subsample the more frequent class
% repeatedly, run multiple classification iterations and predict all labels
% for each of classifiers. Use combined decision values to create a
% majority vote of all classifiers for one final prediction
% PRO: uses all data, better performance than repeated subsampling
% CON: may become slow
% Implementation:
% cfg.design.unbalanced_data = 'ok';
% cfg.decoding.software = 'ensemble_balance';
% cfgd = decoding_defaults; % to use default values
% cfg.decoding.train.classification_kernel.model_parameters.software = 'libsvm';
% cfg.decoding.train.classification_kernel.model_parameters.n_iter = 100;
% cfg.decoding.train.classification_kernel.model_parameters.model_parameters = cfgd.decoding.train.classification_kernel.model_parameters;
% cfg.decoding.test.classification_kernel.model_parameters.model_parameters = cfgd.decoding.test.classification_kernel.model_parameters;
% cfg.results.output = {'balanced_accuracy_minus_chance'};

% Run decoding
results = decoding(cfg);