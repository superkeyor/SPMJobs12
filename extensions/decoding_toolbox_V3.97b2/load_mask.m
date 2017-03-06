% function [mask_vol,mask_hdr,sz,mask_vol_each] = load_mask(cfg)
%
% Subfunction for decoding.m
% This function loads one or several masks from cfg.files.mask in which the
% decoding analysis should be performed (e.g. a brain mask for a
% whole-brain or searchlight analysis or a small volume for a region of
% interest analysis).
%
% Martin Hebart, 2011/01/10 
%
% See also DECODING_LOAD_DATA

% 15/07/03: introduced possibility to supply multiple masks in one mask volume
% HISTORY:
% % KAI: 2016/03/11: Added adding translation mat to cfg.datainfo.mat, also
%   checking that mats from different masks agree

function [mask_vol,mask_hdr,sz,mask_vol_each] = load_mask(cfg)

%% Read mask(s)
mask_names = cfg.files.mask;
if ischar(mask_names) % to deal with different types of input
    mask_names = num2cell(mask_names,2);
end
n_masks = numel(mask_names);

dispv(1,'Loading mask(s):');

% load header to get dimensionality
mask_fname = mask_names{1};
mask_hdr = read_header(cfg.software,mask_fname);
sz = mask_hdr.dim(1:3);
mask_vol_each = zeros([sz n_masks]);
mat = mask_hdr.mat;

for i_mask = 1:n_masks
    fname = mask_names{i_mask};
    hdr = read_header(cfg.software,fname); % get headers of mask
    % Check dimension
    if ~isequal(hdr.dim(1:3), sz)
        error('Dimension of mask file %s \n is different from dimension of mask file %s, please check!', fname,mask_fname)
    end
    
    % also check orientation & rotation
    mat_diff = abs(hdr.mat(:)-mat(:));
    tolerance = 32*eps(max(hdr.mat(:),mat(:)));
    if any(mat_diff > tolerance) % like isequal, but allows for rounding errors
        if isfield(cfg,'files') && isfield(cfg.files,'imagerotation_unequal') && strcmpi(cfg.files.imagerotation_unequal,'ok')
            warningv('DECODING_LOAD_DATA:TRANSFORMMATRIX_DIFFERENT','Rotation & translation matrix of the mask in file \n %s \n is different from matrix of the first mask file \n%s \n You selected cfg.files.imagerotation_unequal = ''ok'', i.e. they can differ beyond rounding errors!\n The final results may not be interpretable!!', fname, mask_fname)
            keyboard
        else
            error('Transformation matrix of mask file %s \n is different from dimension of mask file %s, please check!', fname, mask_fname)
        end
    end
    mask_vol_each(:,:,:,i_mask) = read_image(cfg.software,hdr); % get mask
    dispv(1,'%s',fname)
end

%% Check if a multi-mask was supplied (i.e. one volume with multiple non-overlapping ROI masks)
% if the values are not all 0, 1, and NaN, it might be a multi-mask
tmp = unique(mask_vol_each(:));
if ~all(tmp==1|tmp==0|isnan(tmp))
    % if we have only one mask file
    if n_masks == 1
        % get overall mask
        mask_vol = read_image(cfg.software,hdr);
        % get unique values
        mask_num = unique(mask_vol(:));
        mask_num(isnan(mask_num)|mask_num==0) = []; % remove 0 and NaN
        % if all are integer values, we have a multi-mask and can overwrite the existing mask
        if all(~mod(mask_num,1)) 
            n_masks = length(mask_num);
            dispv(1,'Reading multi-mask with %i different masks.',n_masks)
            mask_vol_each = zeros([sz n_masks]);
            for i_mask = 1:n_masks
                mask_vol_each(:,:,:,i_mask) = mask_vol==mask_num(i_mask);
            end
        else % if a mask with non-binary values has been supplied, throw warning
            warningv('LOAD_MASK:multipleValuesInMask','At least one mask contained values other than 0 and 1. Possibly check if the mask files have been selected correctly. Setting all non-zero values to 1. To avoid this warning, convert masks to 0 and 1 values only.')
        end
    else % if multiple masks with non-binary values have been supplied, throw warning
        warningv('LOAD_MASK:multipleValuesInMask','At least one mask contained values other than 0 and 1. Possibly check if the mask files have been selected correctly. Multiple multi-masks are not allowed. Setting all non-zero values to 1. To avoid this warning, convert masks to 0 and 1 values only.')
    end
end

%% Convert to logical
mask_vol_each(isnan(mask_vol_each)) = 0;
mask_vol_each = logical(mask_vol_each);

% Combine masks
mask_vol = any(mask_vol_each,4);