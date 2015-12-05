% function misc = decoding_load_misc(cfg, passed_data, misc)
% 
% Function to load miscellaneous data from files for decoding.m such as
% residuals from a general linear model. If they have been passed already
% using misc as input, this function is skipped.
% At the moment, we only allow getting residuals. For later versions, this
% code might be generalized depending on demand.
% Additional remark: the output misc is not added to passed_data because of
% file size and because it is separate from the core classification
% analysis. This may change in future versions.
%
% INPUT
%   cfg: Struct that specifies which data should be loaded. This is
%       specified in cfg.files.(fieldname).name (example: cfg.files.residuals.name)
%       additionally for later use it can be required to add a chunk number
%       to each entry, using cfg.files.(fieldname).chunk
%   passed_data: Structure passed_data after it has been processed by
%       decoding_load_data
% OUTPUT:
%   misc: Data returned in format misc.(fieldname) (e.g. misc.residuals)
%
% See also DECODING_LOAD_DATA

% Martin Hebart 2015/07/21

% TODO: check if feature dimensionality of residuals is the same as of data
% (dim 2?)

function misc = decoding_load_misc(cfg, passed_data, misc)

% activate and add methods if we need more methods
% field_names = {'residuals'}; % new methods should be added here

if ~exist('misc','var')
    misc = [];
end

if ~isempty(misc)
    if isnumeric(misc), error('Content of misc needs to be passed as struct, e.g. misc.residuals = ...'), end
    if isfield(misc,'residuals') && ~(isfield(cfg.files,'residuals') && isfield(cfg.files.residuals,'chunk')), error('Missing field cfg.files.residuals.chunk for using misc.residuals'), end
end

if ~isfield(cfg.files,'residuals')
    return
end

% Most checks have been carried out by decoding_load_data, so they are not
% repeated here. Other checks are carried out.
if isfield(cfg.files,'residuals') && isstruct(misc) && isfield(misc,'residuals')
    dispv(1,'Using residuals passed with variable ''misc'' rather than loading them again.')
    
    % Check if size matches
    masklength = length(passed_data.mask_index);
    if masklength ~= size(misc.residuals,2)
        error('Length of mask_index (%i) does not fit to dimension 2 of residuals (%ix%i). Maybe caused by different masks or by NaNs. Load misc with proper mask or use cfg settings for loading.',...
            masklength,size(misc.residuals,1),size(misc.residuals,2))
    end
    
    return
end

dispv(1,'decoding_load_misc is still in beta stage. Use with care!')

if ~isfield(cfg.files.residuals,'name')
    error('misc was not passed, but file names cannot be read (missing field cfg.files.residuals.name). Either pass misc directly or specify the path of the file names to load.')
end

if ischar(cfg.files.residuals.name)
    cfg.files.residuals.name = num2cell(cfg.files.residuals.name,2);
    warningv('DECODING_LOAD_MISC:FileNamesStringNotCell','File names for residuals provided as string, not as cell matrix. Converting to cell...')
end

mask_index = passed_data.mask_index;
sz = passed_data.dim(1:3); % get dimensions of data

%% Load residuals

dispv(1,'Loading residuals from files')

% prepare loading
n_files = length(cfg.files.residuals.name);
misc.residuals = zeros(n_files, length(mask_index)); % init data
[x,y,z] = ind2sub(sz,mask_index); % list of x/y/z coordinates for all voxels in mask (needed for read_voxels)

% load residuals files
for file_ind = 1:n_files

    fname = cfg.files.residuals.name{file_ind};

    dispv(2,'  Loading file %i: %s', file_ind, fname)
    data_hdr = read_header(cfg.software,fname); % get header of image

    % check dimension
    if exist('sz','var')
        if ~isequal(data_hdr.dim(1:3), sz)
            error('Dimension of image in file %s \n is different from dimension of the mask file(s)/the first data image file, please check!', fname)
        end
    else
        sz = data_hdr.dim(1:3); % this is the first time we check the dimensions, so let's save it for the next images
    end

    % check that translation & rotation matrices of this image roughly equals the
    % previous ones (otherwise the images would be rotated differently,
    % which we can't handle)
    if exist('mat','var')
        mat_diff = abs(data_hdr.mat(:)-mat(:));
        tolerance = 32*eps(max(data_hdr.mat(:),mat(:)));
        if any(mat_diff > tolerance) % like isequal, but allows for rounding errors
            if isfield(cfg,'files') && isfield(cfg.files,'imagerotation_unequal') && strcmpi(cfg.files.imagerotation_unequal,'ok')
                warningv('DECODING_LOAD_MISC:TRANSFORMMATRIX_DIFFERENT','Rotation & translation matrix of image in file \n %s \n is different from matrix of the mask file(s)/the first data image file.\n You selected cfg.files.imagerotation_unequal = ''ok'', i.e. they can differ beyond rounding errors!\n The final results may not be interpretable!!',fname)
            else
                error('Rotation & translation matrix of image in file \n %s \n is different from rotation & translation matrix of the mask file(s)/the first data image file.\n The .mat entry defines rotation & translation of the image.\n That both differ means that at least one of both has been rotated.\n Please use reslicing (e.g. from SPM) to have all images in the same position or IF YOU KNOW WHAT YOU ARE DOING set cfg.files.imagerotation_unequal = ''ok''!', fname)
            end
        end
    else
        if isfield(data_hdr, 'mat')
            mat = data_hdr.mat; % this is the first time we check the dimensions, so let's save it for the next images
        end
    end

    misc.residuals(file_ind, :) = read_voxels(cfg.software,data_hdr,[x y z]); % get in-mask voxels of image
end


%% Check if data contains any NaNs 
% (may happen e.g. with ROI masks generated independently and sampling 
% occurs from outside of the decoding volume).
nan_index = isnan(sum(misc.residuals,1)); % find voxels where any image contains NaN
if any(nan_index(:))
    misc.residuals = misc.residuals(:,~nan_index); % reduce misc.residuals
    if strcmpi(cfg.files.mask,'all voxels')
        warningv('DECODING_LOAD_MISC:nansRemoved',['Residuals contain %i NaNs. \n ',...
            'The mask was set to all voxels. Residuals containing NaNs ',...
            'are masked, because they cannot be used.'],sum(nan_index))
    else
        warningv('DECODING_LOAD_MISC:nansPresent',['Residuals contain %i NaNs. \n ',...
            'There might be problems with the definition of data files or ',...
            'mask file or you may have chosen masks that do not fully overlap '...
            'with data. \n Parts of masks are non-overlapping with data. NaNs are masked...'],sum(nan_index))
    end
end