% function [res,run_number] = residuals_from_spm(SPM,masks,Y)
% 
% Function to extract residuals from an SPM.mat in case they have not been
% returned by SPM. You don't need SPM for that function to work.
% However, AR(1) is not carried out!
% INPUT:
%   SPM: Full path of SPM.mat containing relevant information to files or
%       loaded SPM structure
%   masks: Can be one of two things:
%       (a) Full path to mask images specifying which data should be
%           loaded. Format would be string for one mask or cell array for
%           multiple.
%       (b) extracted mask volumes in numeric format.
%       (c) Empty if Y is supplied in 2D (see below)
%       Data will later be extracted as the overlap of all masknames (this
%       is also the internal format used in The Decoding Toolbox. With
%       indexing the data is internally back-referenced to each mask).
%   Y (optional): Data can be loaded externally. It is assumed that this
%       data has been masked already. Dimensions are n_volumes x n_voxels.
%       It is assumed that data has not been high-pass filtered.
%
% OUTPUT:
%   res: residuals as 2D matrix
%   run_number: one run number per volume indicating which run the volume
%       belongs to
%
% Example call:
% [misc.residuals,cfg.files.residuals.chunk] = residuals_from_spm('SPM.mat','mask.nii');

% by Martin Hebart 15/07/20

function [res,run_number] = residuals_from_spm(SPM,masks,Y)

disp('Making residuals...')

%% load SPM.mat
SPMpath = fileparts(SPM);
if ~isstruct(SPM)
    fprintf('     Loading SPM.mat from %s\n',SPM)
    load(SPM)
end

xX = SPM.xX;

%% Get run number for each image
n_runs = length(SPM.nscan);
run_number = zeros(n_runs,1);
scan_ind = cumsum([1 SPM.nscan]);
for i_run = 1:n_runs
    run_number(scan_ind(i_run):scan_ind(i_run+1)-1) = i_run;
end

%% See if variable masks can be loaded automatically
if ~exist('masks','var')
    masks = fullfile(fileparts(SPMpath),'mask.nii');
    if ~exist(masks,'file')
        masks = fullfile(fileparts(SPMpath),'mask.img');
        if ~exist(masks,'file')
            error('Input variable ''masks'' was not passed, but could not be loaded automatically. Please specify location of mask.')
        end
    end
end

%% load mask(s)

if ~isempty(masks)
    
    settings = decoding_defaults;
    
    if ~isnumeric(masks) 
        settings.files.mask = masks;
        fprintf('     ');
        masks = load_mask(settings);
    end
    
    sz = size(masks);
    mask_index = find(masks);
    maskXYZ = zeros(length(mask_index),3);
    [maskXYZ(:,1),maskXYZ(:,2),maskXYZ(:,3)] = ind2sub(sz,mask_index);
end

%% Load data
if ~exist('Y','var')
    fprintf('     Loading data...\n')
    
    if ~exist('maskXYZ','var')
        error('Neither passed data nor masks. Unclear which voxels to load. Pass at least masks')
    end
    
    Y = zeros(length(SPM.xY.VY),length(mask_index));
    for i_vol = 1:length(SPM.xY.VY)
        Y(i_vol,:) = read_voxels(settings.software,SPM.xY.VY(i_vol),maskXYZ);
    end
end

disp('     Scaling, high-pass filtering, and estimating residuals...')
%% Global scaling
Y = bsxfun(@times,Y,SPM.xGX.gSF);

%% High-pass filtering
K = xX.K;
for s = 1:length(K)
    y = Y(K(s).row,:);
    Y(K(s).row,:) = y - K(s).X0*(K(s).X0'*y);
end

%% Get residuals
r = xX.xKXs.rk;
res = Y - xX.xKXs.u(:,1:r)*(xX.xKXs.u(:,1:r)'*Y);

disp('done.')

