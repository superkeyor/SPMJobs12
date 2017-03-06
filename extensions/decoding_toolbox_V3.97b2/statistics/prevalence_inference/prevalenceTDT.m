% all_results = prevalenceTDT(inputfilenames, P2 = 1e6, outputfilename = 'prevalence', alpha = 0.05, decoding_measure)
%
% This function is adapted from the original prevalence.m function from 
%   https://github.com/allefeld/prevalence-permutation/
% to perform permutation-based prevalence inference with TDT.
%
% See the demo_prevalence*.m files for more information on how to use.
% prevalenceCore.m and especially the paper explain the meaning of the
% outputfiles.
%
% IN
%   inputfilenames: EITHER
%     Cell array of input with size subjects x permutations
%     The original unpermuted input should be in subjects x 1
%     The cell array can either contain 
%         1. .img/.nii filenames (cellstr)
%         2. .mat filenames (cellstr) from TDT that contain
%                 OR
%     Struct containing the fields
%       inputfilenames.a:    a is datamatrix with dimensions V x N x P1, 
%           (number of voxels x number of subjects x first level
%           permutations per subject).
%           Note that the original unpermuted result image should be passed
%           as P1=1 for each subject.
%       inputfilenames.mask: logical 1d/2d/3d/probably nd matrix with 
%           size(mask) of the original data. Inmask voxels are true. The 
%           number of entries is always larger or equal to V, because V is 
%           the number of inmask voxels (V = sum(mask(:)));  
%     	inputfilenames.vol:  struct with at least these fields: 
%              .vol.dim: 1xn vector dimension of original image
%              .vol.mat: 4x4 matrix with rotation and translation
%                        Will be set to eye(4) if not provided
% OPTIONAL
%   P2:               number of second-level permutations to perform
%   outputfilename:   output image filename start. Set to 'DONTWRITE' if 
%                     results should not be written. By default, results
%                     will be written to prevalence* in the current
%                     directory.
%   alpha:            significance level
%   decoding_measure: decoding measure that should be used to calculate the
%                     prevalenced statistic (e.g. 'accuracy_minus_chance'),
%                     for .mat files only. Only necessary if the mat file
%                     contains multiple decoding measures.
% OUT
%   Results will be written to files (see outputfilename above). For your 
%   convenience, the script checks if files can be written when starting, 
%   to avoid tears on your side). Outputfiles are:
%        one file for each result of prevalenceCore.m
%           _gamma0c.nii: the prevalence map (gamma0c)
%          _aTypical.nii: the median data value (e.g. accuracy) where the
%                          prevalence is higher than 50% (i.e. typical)
%              _pXXX.nii: p maps for different null hypotheses (see
%                         prevalenceCore.m)
%              _mask.nii: the mask that was used
%               _cfg.mat: all parameters necessary to restart the analysis.
%   The result is also returned as first argument all_results.
%   In addition, the struct contains:
%     all_results.vol = vol; % contains infos about the data, e.g.
%                            % transformation matrices, dimensions, roi 
%                            % names, etc.
%     all_results.prevalence_cfg: a struct that contains all parameters to
%                                 redo the analysis.
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
% Author: Kai, adapted from Code by Carsten Allefeld

% HIST:
%   2016/08/03: Version 1 for TDT based on Carstens function from  2016/08/02
%
% DISCLAIMER: This function is in beta stage. It seem to work as it should,
%   but has not been extensively tested by the public, thus use with care.


function all_results = prevalenceTDT(inputfilenames, P2, outputfilename, alpha, decoding_measure)

prevalence_version = 'prevalence TDT v1, 2016/08/03';
citation = [char(10) 'Please cite as:' char(10) ...
'Allefeld, C., Goergen, K., & Haynes, J.-D. (2016). Valid population' char(10) ...
'  inference for information-based imaging: From the second-level t-test to ' char(10) ...
'  prevalence inference. NeuroImage. ' char(10) ...
'  http://doi.org/10.1016/j.neuroimage.2016.07.040' char(10)];
date_started = datestr(now);

fprintf('\n*** prevalence ***\n\n')
disp(prevalence_version);
disp(['Started: ' date_started])
disp(citation);


%% Check input arguments
if ~exist('P2', 'var') || isempty(P2)
    P2 = 1e6;
end
if ~exist('outputfilename', 'var') || isempty(outputfilename)
    outputfilename = 'prevalence';
end
if ~exist('alpha', 'var') || isempty(alpha)
    alpha = 0.05;
end
if ~exist('decoding_measure', 'var')
    decoding_measure = '';
end
if ~exist('prevalence_cfg', 'var')
    prevalence_cfg = [];
end
%% Check output arguments
if nargout < 1 && strcmp(outputfilename, 'DONTWRITE')
    error('Files should not be written (outputfilename=''DONTWRITE'' but results are also not returned, aborting')
end

%% Check if we can write output files (otherwise better to abort here already)
if strcmp(outputfilename, 'DONTWRITE')
    disp('No outputfiles will be written because outputfilename = ''DONTWRITE''')
else
    fprintf('Testing if output files can be written...\n');
    [fdir, fname, fext] = fileparts(outputfilename);
    if ~exist(fdir, 'dir'), [s, m] = mkdir(fdir); end
    save([outputfilename '_test.mat'], 'date_started'); % test if we can save something, here the start date
    delete([outputfilename '_test.mat']);
end
%% load and prepare accuracies
if iscellstr(inputfilenames)
    if exist('decoding_measure', 'var')
        [a, mask, vol] = prevalence_loaddata(inputfilenames, decoding_measure);
    else
        
    end
elseif isstruct(inputfilenames)
    disp('Data seem loaded already, using fields from provided struct without checking anything');
    a = inputfilenames.a; % a is datamatrix with dimensions V x N x P1, see below
    mask = inputfilenames.mask; % logical 1d/2d/3d matrix with size(mask) of the original image. Inmask voxels are true, outmask voxels are false. The numer of entries is always larger or equal to V, because V is the number of inmask voxels (V = sum(mask(:)));  
    vol = inputfilenames.vol; % .volneeds to contain at least these fields: 
            % .vol.dim: 1x3 vector dimension of original image, empty if not provided
            % .vol.mat: 4x4 matrix with rotation and translation, empty if not provided
end


%% generate second-level permutations

[results, params] = prevalenceCore(a, P2, alpha);

%% gather and save parameters
% save filenames or info that data has been passed directly
try
    prevalence_cfg.params = params;
    if iscellstr(inputfilenames)
        prevalence_cfg.inputfilenames = inputfilenames;
    else
        prevalence_cfg.inputfilenames = sprintf('No filenames have been provided, but a data matrix directly (size data matrix a [V x N x P1]: [%s], size mask: [%s]. See prevalence_cfg.dbstack(2) which function provided the data.', num2str(size(a)), num2str(size(mask)));
    end
    prevalence_cfg.dbstack = dbstack; % caller functions
    prevalence_cfg.datestr_started = datestr(date_started);
    prevalence_cfg.datestr_finished = datestr(now);
    prevalence_cfg.outputfilename = outputfilename;
    if exist('decoding_measure', 'var'), prevalence_cfg.decoding_measure = decoding_measure; end
    
    % write to file
    if ~strcmp(outputfilename, 'DONTWRITE')
        prevalence_cfg_file = [outputfilename '_cfg.mat'];
        disp(['Saving parameters to  ' prevalence_cfg_file]);
        save(prevalence_cfg_file, 'prevalence_cfg');
    end
catch e
    try e.getReport, end %#ok<TRYNC>
    keyboard
    warning('prevalence:writing_config_failed', 'Could not write config file for prevalence, please check why.')
end

%% save results to disk
if strcmp(outputfilename, 'DONTWRITE')
    disp('Skip writing outputfiles because outputfilename = ''DONTWRITE''')
else
    % set a default transformation matrix in case we have non
    if ~exist('vol', 'var') || ~isfield(vol, 'mat') || isempty(vol.mat)
        % check if the tranformation matrix has been provided as trans_mat
        if exist('trans_mat', 'var')
            vol.mat = trans_mat;
        else
            warning('The transformation matrix has not been stored in the file. The transformation matrix is set to the identity, which is most likely wrong.')
            vol.mat = eye(4); % default
            if strcmp(inputformat, 'mat')
                vol.mat(eye(4)==1) = [currmat.results.datainfo.voxelsize, 1]; % we are nice and at least have the right voxels size
            end
            disp(vol.mat)
        end
    end
    
    % Check if ROI analysis or normal analys
    if iscell(mask)
        
        % ROI analysis, write each ROI separately
        for m_ind = 1:length(mask)
            if isfield(vol, 'roi_names')
                curr_outputfilename = [outputfilename '_' vol.roi_names{m_ind}]; % add ROI name to image
            else
                curr_outputfilename = [outputfilename '_mask' int2str(m_ind)]; % add mask number to image
            end
            prevalence_savedata_to_images(curr_outputfilename, mask{1}, vol, results, m_ind); % save value of current ROI to all voxels of the current ROI
        end
    else
        
        % normal anlysis, write all fields to one image
        prevalence_savedata_to_images(outputfilename, mask, vol, results);
    end
end

%% Write params as extra txt/mat file
try
    params_txtfile = [outputfilename '_params.txt'];
    disp(['Trying to write parameters to text file ' params_txtfile ])
    writetable(struct2table(params), params_txtfile); % works from matlab 2013b
catch
    warning('Writing parameters to txt file failed, maybe because matlab is too old (should work from 2013b). Use the parameters from the .mat file')
end

%% Return data 
if nargout >= 1
    all_results = results;
    all_results.prevalence_cfg = prevalence_cfg; % contains params    
    all_results.vol = vol; % will contain e.g. transformation mat and other things
    all_results.info = {'Prevalence result, see ';
                        citation;
                        prevalence_version;
                        datestr(now);
                        'gamma0:   prevalence map';
                        'aTypical: typical map';
                        'mask:     original volume, use to reconstruct data, e.g. as data = nan(size(all_results.mask)); data(all_results.mask) = all_results.typical;';
                        };
end
%% Done
disp(prevalence_version);
disp(citation);
disp('Prevalence done')