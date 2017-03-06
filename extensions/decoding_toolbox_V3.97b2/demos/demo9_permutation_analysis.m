%% Demo how to create a permutation design
%
% This demo shows how to calculate a permutation analysis.
%
% For this, we need the cfg of the normal design.
% This can 
% - either be created new (not shown below, see e.g. the decoding_tutorial)
% - or loaded from the cfg.mat of an already calculated analysis (thats
%   what we do here)
%
% Data that fits to this script can be computed with
% demo8_demodata_decoding_tutorial_motion_direction.m.m
%
% Kai, 2016/07/25
 
%% Check that SPM and TDT are available on the path
if isempty(which('SPM')), error('Please add SPM to the path and restart'), end
if isempty(which('decoding_defaults')), error('Please add TDT to the path and restart'), end
decoding_defaults; % add all important directories to the path

%% Load cfg from a analysis that has been performed
% alterantively you can setup a cfg here. Its not necessary to run the cfg.
% You might change 'searchlight' to 'ROI' or 'wholebrain' if you compute
% that with demo8_decoding_tutorial_motion_up_down
cfg_file = '/TDT/sub01_firstlevel_reducedResolution/sub01_GLM_3x3x3mm/results/motion_up_vs_down/searchlight/res_cfg.mat';
display(['Loading ' cfg_file]);
load(cfg_file, 'cfg');
org_cfg = cfg; % keeping the unpermuted cfg to copy parameters below
%% Create cfg with permuted sets
% see also "help makde_design_permutation" on how to do this otherwise
cfg = org_cfg; % initialize new cfg like the original

cfg = rmfield(cfg,'design'); % this is needed if you previously used cfg.
cfg.design.function = org_cfg.design.function;

cfg.results = rmfield(cfg.results, 'resultsname'); % the name should be generated later
cfg.results.dir = fullfile(cfg.results.dir, 'perm'); % change directory
cfg.results.overwrite = 1; % should not overwrite results (change if you whish to do so)

if strcmp(cfg.analysis, 'searchlight')
    cfg.plot_selected_voxels = 1000; % show SL every 1000' steps
end

n_perms = 10;  % 10 chosen for demo only, normally you should pick large 
               % number here, e.g. 1000 or more
               % the function might return less designs if less
               % permutations are possible
combine = 0;   % see make_design_permutations how you can run all analysis in one go, might be faster but takes more memory
designs = make_design_permutation(cfg,n_perms,combine);

%% Run all permutations in a loop
% With small tricks to make it run faster (reusing design figure, loading 
% data once using passed_data), renaming the design figure, and to display
% the current permutation number in the title of the design figure)

cfg.fighandles.plot_design = figure(); % open one figure for all designs
passed_data = []; % avoid loading the same data multiple times by looping it
for i_perm = 1:n_perms
    dispv(1, 'Permutation %i/%i', i_perm, n_perms)
    
    cfg.design = designs{i_perm};
    cfg.results.filestart = ['perm' sprintf('%04d',i_perm)];
    
    set(cfg.fighandles.plot_design, 'name', sprintf('Permutation %i/%i', i_perm, n_perms)); % to know where we are
    if ~strcmp(cfg.analysis, 'searchlight') && i_perm > 1
        cfg.plot_selected_voxels = 0; % switch off after the first time, drawing takes some time
    end
    
    % do the decoding for this permutation
    [results, final_cfg, passed_data] = decoding(cfg, passed_data); % run permutation
    
    % rename  design figures to start with the current permutation number
    designfiles = dir(fullfile(cfg.results.dir, 'design.*'));
    for design_ind = 1:length(designfiles)
        movefile(fullfile(cfg.results.dir, designfiles(design_ind).name), ...
                    fullfile(cfg.results.dir, [cfg.results.filestart '_' designfiles(design_ind).name]));
    end
end

%% Use results to calculate statistic
display('A function to use the premuted results to create p-values is currently missing here.')
display('If you have permutation maps from multiple subjects, see prevalence_inference.m')
display('Permutation analyses finished')
