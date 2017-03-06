% This demo shows how to apply prevalence inference as statistics to a toy
% dataset. This example shows you what you minimally have to do to PROVIDE 
% YOUR OWN DATA (i.e. if you do not want to use TDT or images). Find 
% further explanations about the analysis in the paper below.
% 
% Alternatively, consider taking the corre code from github directly:
%   https://github.com/allefeld/prevalence-permutation
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
%   Carsten Allefeld. 2016/08/02


%% Check that SPM and TDT are available on the path

if isempty(which('SPM')), error('Please add SPM to the path and restart'), end
if isempty(which('decoding_defaults')), error('Please add TDT to the path and restart'), end
decoding_defaults; % add all important directories to the path

%% Inputdata

% Provide the data as struct
inputdata = [];

% Provide data description as .vol
inputimages.vol.dim = [12 10 4]; % dimension of individual image (probaly larger in real data)
inputimages.vol.mat = eye(4); % 4x4 affine transformation matrix mapping from voxel coordinates to real world coordinatestransformation and rotation matrix (see e.g. spm_vol)

% Provide mask as .mask where the data was in the original volume (1d/2d/3d/or probably nd)
inputimages.mask = false(inputimages.vol.dim); % initialize volume with all false
inputimages.mask(:) = true; % set true were data was - in this demo, we set everything to true

% Provide data matrix as .a

% here we construct a datamatrix with random data, you will use real data,
% of course

% Dimension of datamatrix V x N x P1
V = sum(inputimages.mask(:)); % V is the number of voxels (or dimensions) that should be tested, must be the same like the number of trues in the mask (exception: ROI analysis: There you can set one mask per ROI and use mask as a cell, e.g. mask{roi_ind} = mask;
N = 15; % number of individual subjects that you have (or units of indipendent measurements) 
P1 = 17; % number of "first-level" permutations you have for each subject (at the moment, the code expects the same number for all subjects)

% Create the datamatrix
a = nan([V, N, P1]); %init
for sbj_ind = 1:N
    for perm_level1_ind = 1:P1
        % the first permutation P1=1 is the unpermuted real results, the rest 
        % are results from permutated analyses
        if perm_level1_ind == 1
           fprintf('Setting results of original/unpermuted analysis for subject %i at a(%i, %i)\n', sbj_ind, sbj_ind, perm_level1_ind);
        else
           fprintf('Setting results or permuted analysis for subject %i at a(%i, %i)\n', sbj_ind, sbj_ind, perm_level1_ind);
        end
        a(:, sbj_ind, perm_level1_ind) = randn(1, V); % here you choose your real/permuted data of course, put it as a 1xV vector at that position
    end
end

% and finally we put the data to the struct
inputimages.a = a;


%% Define where to save the results (optional)
% In principle, we are ready to go, but it's often nice to save your data
% at a suitable place, so define it
resultfiles = fullfile('prevalenceDemoOwnData', 'prevalence'); % all files will start with that, so resultfiles should contain folder + start of filename as best practice

%% Do the analysis
% Run prevalence analysis, explanation below
prevalenceTDT(inputimages, [], resultfiles);

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
disp(['Results saved as ' resultfiles '*.nii'])





