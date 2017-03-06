% This demo shows how to apply prevalence inference as statistics. It 
% takes SPM images (.nii or .img) or TDT .mat result as input (works for 
% searchlight, ROI or wholebrain analysis). Further explanations about the 
% analysis in the paper below.
%
% For data in a different format, see 
%    demo_prevalenceInference_provide_own_data.m
% For the data analysis from the paper, see 
%    demo_prevalenceInference_Cichy2011.m
%
% Please CITE as: 
%   Allefeld, C., Goergen, K., & Haynes, J.-D. (2016). 
%       Valid population inference for information-based imaging: From the 
%       second-level t-test to prevalence inference. NeuroImage. 
%       http://doi.org/10.1016/j.neuroimage.2016.07.040
%
% A longer, more didactic, previous version of the manuscript exists here:   
%   Allefeld, C., Goergen, K., & Haynes, J.-D. (2015). http://arxiv.org/abs/1512.00810
%
% Author: Demos and adaption to TDT by Kai, original prevalence code by 
%   Carsten Allefeld. 2016/08/03


%% Check that SPM and TDT are available on the path

if isempty(which('SPM')), error('Please add SPM to the path and restart'), end
if isempty(which('decoding_defaults')), error('Please add TDT to the path and restart'), end
decoding_defaults; % add all important directories to the path

%% Settings

P2 = 20000; % number of 2nd level permutations, should be put to something like 1e6 or 1e7 for a real analysis

%% Inputdata

% The analysis needs permutation data for multiple subjects as input.
%
% The data needs to be provided in the variable inputimages, which is a
% cell of dimension subjects x permutations. The original unpermuted input 
% for each subject should be provided as first entry for each subject, i.e. 
% as subjects x 1. The cell array can either contain file names with full
% path as
%    1. .img/.nii filenames (cellstr)
%    2. .mat filenames (cellstr) from TDT that contain
% or
%    3. directly 3d data as struct (see help prevalence or 
%         demo_prevalenceInference_provide_own_data.m)
%
% You can use
%    make_design_permutation()
% to create permutations for each subject in TDT (see e.g. demo8 and demo9)
% or you can download searchlight, wholebrain and ROI example data here:
%    https://sites.google.com/site/tdtdecodingtoolbox/home/download
% and then demo_prevalenceInference_TDTdata_demodata.zip.

%% Load data
% Here, we load some example images for each of 10 subjects
n_sbjs = 10;
decoding_measure = 'accuracy_minus_chance';

% folder that contains the original image directly and the permuted images
% in a "perm" subfolder (or set datadir manually below)
datadir = fullfile('/TDT/prevalence_example_data/motion_up_vs_down/searchlight');
if ~exist(datadir, 'dir'), error('Could not find directory %s, please check if that is where you put the data. If you don''t have them, download them from the TDT website.', datadir); end


% directories and file masks for unpermuted and permuted images
orig_inputdir = {};
orig_inputdir(1:n_sbjs,1) = {datadir};
orig_filemask(1:n_sbjs,1) = {['res_' decoding_measure '.mat']}; % regular expression, for more see help spm_select
%                                                      From  help spm_select:
%                                                      e.g. DCM*.mat files should have a typ of '^DCM.*\.mat$'
perm_inputdir = {};
perm_inputdir(1:n_sbjs,1) = {fullfile(datadir, 'perm')};
perm_filemask = {};
perm_filemask(1:n_sbjs,1) = {['^perm.*_' decoding_measure '\.mat$']}; % 

inputimages = {};
for sbj = 1:n_sbjs   
    % get the original unpermuted result image as first image (required by the package)
    orig_image = cellstr(spm_select('FPList',orig_inputdir{sbj},orig_filemask{sbj}));
    if length(orig_image) ~= 1
        error('There should be exactly 1 unpermuted input file for %s, but we found %i, please check', orig_image, length(orig_image))
    elseif isempty(orig_image{1})
        error('No file found for %s %s, please check', orig_inputdir{sbj}, orig_filemask{sbj}, length(orig_image))
    end
    inputimages(sbj, 1) = orig_image;
    
    % put permuted images afterwards
    permuted_images = cellstr(spm_select('FPList',perm_inputdir{sbj},perm_filemask{sbj}));
    if length(permuted_images) == 1 && isempty(permuted_images{1})
        error('  No permuted images found for sbj %i with %s %s', sbj, perm_inputdir{sbj},perm_filemask{sbj});
    else
        fprintf('  Found %i permuted images for sbj %i\n', length(permuted_images), sbj);
    end
    
    inputimages(sbj, 2:length(permuted_images)+1) = permuted_images;
end

warning(['In this demo, we use the same images for all "sbjs". ' ...
    'In a real analysis the data should of course be different for every subj! ' ...
    'We also use a unrealistic low number of second level permutations (P2=' int2str(P2) '). ', ...
    'You should clearly increase that for a real analysis. See prevalenceCore.m and the paper.'])
str = input('If you have understood the above warning, type ''yes'': ','s');
if strcmpi(str,'yes') || strcmpi(str,'y')
    % do nothing
else
    disp('Quitting demo...')
    return
end

%% Define where to save the results
resultdir = fullfile(orig_inputdir{1}, 'prevalenceDemo');
mkdir(resultdir);
resultfilenames = fullfile(resultdir, 'prevalence');
disp(['Writing result to ' resultfilenames '*.*']);

%% Do the analysis
% The call will start the processing. As the function says, calculation can
% be stopped any time by closing the Figure that pops up. The result at 
% this moment in time will be saved as image and/or returned.

% run prevalence analysis
prevalenceTDT(inputimages, P2, resultfilenames);

% The function returns images with the resuilts. See prevalenceCore.m for
% information about the output files.
%
% If you really wish not to write the result images to disk, use
% all_results = prevalence(inputimages, [], 'DONTWRITE');
%
% For all further options, see help prevalence.m
%
% Enjoy!

disp('Prevalence analysis finished.')
disp(['Results in: ' resultfilenames])
