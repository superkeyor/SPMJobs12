% This demo shows how to apply prevalence inference as statistics. It 
% takes the test data from  Cichy, Chen & Haynes (NeuroImage 2011; used 
% with permission) that were used as demo in the prevalence inference paper 
% (Allefeld et al 2016) and can be downloaded from the github page below. 
% Further explanations about the analysis in the paper below.
%
% For how to use TDT data or your own data, see 
%   demo_prevalenceInference_TDTdata.m
%   demo_prevalenceInference_provide_own_data.m
% or the github page: https://github.com/allefeld/prevalence-permutation
%
% To run the script, DOWNLOAD the INPUT DATA Cichy2011 here:
%   https://github.com/allefeld/cichy-2011-category-smoothedaccuracy
% Unzip it, and adapt the input path below accordingly.
% 
% If you like, you can compare the results of this script (with the same 
% paramters and the same seed) to the results provided at
% https://sites.google.com/site/tdtdecodingtoolbox/home/download/
%         demo_prevalenceInference_Cichy11_results.zip
% Add the path to the content of this zip file below.
%
% Please CITE prevalence analysis as: 
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

P2 = 200000; % number of 2nd level permutations, should be put to something like 1e6 or 1e7 for a real analysis
rng(42);

warning(['In this demo, we use an unrealistic low number of second level permutations (P2=' int2str(P2) '). ', ...
    'You should clearly increase that for a real analysis. ', ...
    'You should also remove the randomization seed that we set above.', ...
    'See prevalenceCore.m and the paper.'])
str = input('If you have understood the above warning, type ''yes'': ','s');
if strcmpi(str,'yes') || strcmpi(str,'y')
    % do nothing
else
    disp('Quitting demo...')
    return
end

%% Load data

% Path to "cichy-2011-category-smoothedaccuracy", that contains the
% accuracy maps that were used as demo in Allefeld et al, 2016 as
% subdirectories.

datadir = 'cichy-2011-category-smoothedaccuracy';
if ~exist(datadir, 'dir')
    error('Could not find directory %s, please check if that is where you put the data. If you don''t have them, download them from https://github.com/allefeld/prevalence-permutation/releases.', datadir);
end

% collect input image filenames (The first image is always the unpermuted one)
N = 12;
P1 = 16;
inputfilenamePatttern = '%02d/sa_C0002_P%04d.nii.gz';
inputimages = cell(N, P1);
for k = 1 : N
    for i = 1 : P1
        inputimages{k, i} = fullfile(datadir, sprintf(inputfilenamePatttern, k, i));
    end
end

%% Define where to save the results
resultdir = fullfile(datadir, 'prevalence_results_cichy11');
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

%% Compare results to uploaded results

%% Compare resulted .nii files to provide files, if these exist

% Set directory to existing result files, see below for the download link
compare_dir = ''; % e.g. TDT/testdata/demo_prevalenceInference_Cichy11_results_compare
if isempty(compare_dir)
    display('If you want to compare the results, please set compare_dir above to the directory that contains the data')
    display('You can download the result files here: https://sites.google.com/site/tdtdecodingtoolbox/home/download/demo_prevalenceInference_Cichy11_results.zip')
    break
end

display(['Comparing new files to ' compare_dir])
compare_files = dir(fullfile(compare_dir, '*.nii'));

if isempty(compare_files)
    error('No *.nii files found in %s, please check', compare_dir)
end

for c_ind = 1:length(compare_files)
    c1_file = fullfile(compare_dir, compare_files(c_ind).name);
    c2_file = fullfile(resultdir, compare_files(c_ind).name);
    display(['Comparing ' compare_files(c_ind).name])
    [all_same,diff_vol,diff_ind,maxabs_diff] = compare_volumes({c1_file, c2_file});
    if ~all_same
        warning('Found some differences (maximal absolute diff = %g) between %s and %s, please check', maxabs_diff, c1_file, c2_file)
    end
end

display('All done')

% The checksums here are different to the checksums produced by 
% prevalenceTest.m from the github page because we write a slightly 
% different header, and thus the chechsums are completely different.
