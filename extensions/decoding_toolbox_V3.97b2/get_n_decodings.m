% function [n_decodings,decoding_subindex] = get_n_decodings(cfg,mask_index,mask_index_each,sz)
%
% This is a subfunction of The Decoding Toolbox. It determines number of 
% times a full classification is performed (e.g. number of searchlights or 
% number of ROIs).
%
% Martin Hebart & Kai G?rgen, 2013

function [n_decodings,decoding_subindex] = get_n_decodings(cfg,mask_index,mask_index_each,sz)

if strcmpi(cfg.analysis,'searchlight')
    if ~isfield(cfg.searchlight,'subset') || isempty(cfg.searchlight.subset)
        % use all voxels
        n_decodings = length(mask_index); % number of voxels
        decoding_subindex = 1:n_decodings;
    else
        dispv(1,'Using only a subset of searchlights!')
        % check if all subset voxels make sense and convert to standard form here 
        
        subset_sz = size(cfg.searchlight.subset);

        % Check if dimensions of subset is correct
        % We either take coordinates as nx3 vector or indices as nx1
        
        % Check for common mistakes and try to correct (or warn if
        % critical)
        
        % First, check the two critical cases (1, 3) and (3,1), here only
        % warnings
        if subset_sz(1) == 1 && subset_sz(2) == 3
            warningv('GET_N_DECODINGS:searchlight_subset_wrong_or_ambiguous_orientation', 'Dimension of cfg.searchlight.subset is 1x3. This is interpreted as 1 coordinate value, not as 3 voxel indices. Transpose cfg.searchlight.subset if this is wrong.')
        elseif subset_sz(1) == 3 && subset_sz(2) == 1
            warningv('GET_N_DECODINGS:searchlight_subset_wrong_or_ambiguous_orientation', 'Dimension of cfg.searchlight.subset is 3x1. This is interpreted as 3 voxel indices, not as 1 coordinate value. Transpose cfg.searchlight.subset if this is wrong.')
        % next check if it could be the attempt to pass 1 coordinate with 2
        % dimensions (i.e. without z pretty unlikely), if so, warn and and 
        % flip
        elseif subset_sz(1) == 1 && subset_sz(2) == 2
            % if we only get two values in 1x2, also take as 2 indices, but warn
            warningv('GET_N_DECODINGS:searchlight_subset_wrong_or_ambiguous_orientation', 'cfg.searchlight.subset includes only 2 values but. Assuming these are 2 indices in wrong orientation, not 1 coordinate. If you want to use this as coordinate, add a 3rd coordinate here, transposing it.')
            cfg.searchlight.subset = cfg.searchlight.subset';
        % then check for the standard case: a row vector instead of a colum
        % vector (as you get from 1:n). If so, flip
        elseif subset_sz(1) == 1 && subset_sz(2) > 3
            % Common errors: subset provided as row vector instead of colum
            % vector, if so, flip it.
            % flip if more than 4 entries of row vector
            warningv('GET_N_DECODINGS:searchlight_subset_wrong_or_ambiguous_orientation', 'cfg.searchlight.subset seems to include single voxel locations but in wrong orientation, transposing it')
            cfg.searchlight.subset = cfg.searchlight.subset';
        end
        
        % after correcting errors, check that they are ok now
        subset_sz = size(cfg.searchlight.subset); % update dimensions again
        if length(subset_sz) ~= 2
            error('cfg.searchlight.subset should have dimensions nx1 (for voxel indices) or nx3 (for coordinates), but has more than 2 dimensions (namely %i), please check', length(subset_sz));
        elseif subset_sz(2) == 3
            dispv(2, 'cfg.searchlight.subset provided as nx3 coordinates, with size [%i, %i]', subset_sz);
        elseif subset_sz(2) == 1
            dispv(2, 'cfg.searchlight.subset provided as nx1 voxel indices, with size [%i, %i]', subset_sz);
        else
            error('cfg.searchlight.subset should have dimensions nx1 (for voxel indices) or nx3 (for coordinates), but is neither (dimensions are [%i, %i])', subset_sz);
        end
        
        % if provided as vector
        if subset_sz(2)==1
            decoding_subindex = cfg.searchlight.subset;
            if any(decoding_subindex>length(mask_index))
                warning('Some indices in cfg.searchlight.subset are larger than the number of decodings (which are %i). Removing all larger values!',length(mask_index))
                decoding_subindex(decoding_subindex>length(mask_index)) = [];
                if isempty(decoding_subindex)
                error('All values removed! None of the provided input indices are actually part of the mask!')
                end
            end

        % if provided as matrix
        elseif any(subset_sz==3)

            % Check if all provided voxels have realistic values
            for i_dim = 1:3
                if any(cfg.searchlight.subset(:,i_dim)>sz(i_dim)) || any(cfg.searchlight.subset(:,i_dim)<=0)
                    error('Some provided voxel coordinates in cfg.searchlight.subset are smaller than zero or larger than the size of the volume. Please make sure to use only voxel indices and not mm coordinates!')
                end
            end

            subset_index = sub2ind(sz,cfg.searchlight.subset(:,1),cfg.searchlight.subset(:,2),cfg.searchlight.subset(:,3));
            [ignore,decoding_subindex] = intersect(mask_index,subset_index); %#ok<ASGLU>
            if isempty(decoding_subindex)
                error('None of the provided subset of searchlights lie within the mask. Please check the accuracy of your input to cfg.searchligh.subset!')
            end
            if length(decoding_subindex) < length(subset_index)
                warning('Some of the provided subset of searchlights lie outside of the mask. These values are masked anyway. Results may be affected!')
            end
        else
            cfg.searchlight.subset
            error('No idea how to handel this cfg.searchlight.subset. Actually, this should never occur, because we checked above that cfg.searchlight.subset either has nx1 or a nx3. No idea how we could reach this error then.')
        end

        n_decodings = length(decoding_subindex);
    end


elseif strcmpi(cfg.analysis,'roi')
    n_decodings = length(mask_index_each); % number of ROI masks
    decoding_subindex = 1:n_decodings;
    
elseif strcmpi(cfg.analysis,'wholebrain')
    n_decodings = 1; % there can only be one brain
    decoding_subindex = 1:n_decodings;

else
    error('Function ''get_n_decodings'' does not know how to get n_decodings for cfg.analysis = %s', cfg.analysis)
end