% function design = make_design_rsa(cfg)
%
% Function to generate design matrix for representational similarity
% analysis, pattern simlarity analysis, or pattern component modeling. This
% is the most general version where all data is used for training and
% testing, i.e. without cross-validation. If cfg.files.components.index and
% cfg.files.components.matrix are passed, then the chosen similarity metric
% can be compared to the contents of these matrices using the appropriate
% results transformation functions. These matrices can be used for
% classical representational similarity analysis or pattern component
% modeling. If cfg.files.components.get_inv = 1, then additionally the field
% cfg.files.components.matrixinv is calculated. This can be used to
% speed-up calculations of pattern components.
% IMPORTANT: The field cfg.design.nonindependence is set to 'ok'. This is
% because all data are used as training and test data. This means if you run
% into non-independence problems, TDT will NOT warn you.
%
% IN
%   cfg.files.label: a vector, one label number for each file in
%       cfg.files.name . For pattern component models, these numbers are
%       meaningless, so they don't need to be passed and in that case are
%       filled with random numbers.
%   [cfg.files.components.index]: a matrix of 0s and 1s indicating the locations to
%       be used (must be symmetric across the diagonal or empty in either
%       the upper or lower triangular matrix)
%   [cfg.files.components.matrix]: an nx1 cell array of matrices each representing
%       a pattern component.
%   [cfg.files.components.get_inv]: 1 or 0, will return the inverse of the
%       entries of cfg.files.components.matrix if selected.
%
% OUT
%   design.label: matrix with one column for each CV step, containing a
%       label for each image used for decoding (a replication of the vector
%       cfg.files.label across CV steps), mostly meaningless for pattern
%       component models
%   design.train: binary matrix with one column for each CV step, containing
%       a 1 for each image used for training in this CV step and 0 for all
%       images not used
%   design.test: same as in design.train, but this time for all test images
%   design.set: 1xn vector, describing the set number of each CV step
%   [design.components.index]: index of entries of covariance matrix used
%   [design.components.subscript]: x and y coordinates of entries
%   [design.components.matrix]: mxn matrix where each column represents a
%       components and each row an entry in that component (n is length of
%       index)
%   [design.components.matrixinv]: nxm matrix (inverse of matrix)
%   design.function: Information about function used to create design
%
% 2015/04/15 Martin Hebart

function design = make_design_rsa(cfg)

%% fill classical fields 

if isfield(cfg.files,'components')
    szcomp = size(cfg.files.components.index);
    if szcomp(2) == 1 % if it is a vector, it represents a real index
        szcomp = size(cfg.files.components.matrix{1});
        if max(cfg.files.components.index)>prod(szcomp)
            error('cfg.files.components.index was provided as a vector of indices. At least one index is out of range for cfg.files.components.matrix{1}. Please check.')
        end
    end
    
    szlabel = szcomp(1);
else
    try
        szlabel = length(cfg.files.name);
    catch
        error('Neither cfg.files.components.index was provided nor cfg.files.name. Unclear how long label vector should be. Please specify!')
    end
end

% automatically fill cfg.files.label if not provided
if isfield(cfg,'files') && isfield(cfg.files,'label')
    % check if size matches to cfg.files.components.index
    if szlabel ~= length(cfg.files.label)
        error('Length of label vector must match to width and height of cfg.files.components.index / the number of entries in cfg.files.name')
    end
else
    cfg.files.label = ones(szlabel,1);
    cfg.files.label(floor(szlabel/2):end) = -1;
end

% fill all other fields
design.function.name = mfilename;
design.function.ver = 'v20150416';
design.label = cfg.files.label;
design.train = ones(size(cfg.files.label));
design.test = ones(size(cfg.files.label));
design.set = 1;
design.nonindependence = 'ok';
design.train_eq_test = 1; % new field, avoids warning for nonindependence

if ~isfield(cfg.files,'components')
    return
end

%% run checks

if szcomp(1)~=szcomp(2)
    error('cfg.files.components.index must be a square matrix')
end

if ~iscell(cfg.files.components.matrix)
    error('cfg.files.components.matrix must be a nx1 cell array')
end

n_cells = numel(cfg.files.components.matrix);
isuppercell = false(n_cells,1);
islowercell = false(n_cells,1);
issymmcell  = false(n_cells,1);
for i_cell = 1:n_cells
    curr_cell = cfg.files.components.matrix{i_cell};
    if ~isequal(size(curr_cell),szcomp)
        error('cfg.files.components.matrix{%i} does not match to cfg.files.components.index',i_cell)
    end
    isuppercell(i_cell) = isequal(curr_cell,triu(curr_cell));
    islowercell(i_cell) = isequal(curr_cell,tril(curr_cell));
    issymmcell(i_cell) = isequal(curr_cell,curr_cell');
    if ~issymmcell(i_cell) && ~islowercell(i_cell) && ~isuppercell(i_cell)
        error('cfg.files.components.matrix{%i} must be a symmetric, an upper triangular, or a lower triangular matrix.',i_cell)
    end
end

%% create design.components.index

if isvector(cfg.files.components.index)
    indmat = zeros(szcomp);
    indmat(cfg.files.components.index) = 1;
    cfg.files.components.index = indmat;
end
% check if full matrix (otherwise return all indices)
isupper = istriu(cfg.files.components.index); % when there are no in the lower, it is an upper matrix
islower = istril(cfg.files.components.index); % when there are no in the upper, it is an lower matrix


if isupper
    if any(islowercell)
        error('At least one cell was provided as a lower triangular cell, but the matrices are upper triangular.')
    end
    if ~all(isuppercell) && ~all(issymmcell)
        error('There is a mixture of upper and symmetric cells. Please make them uniform.')
    end
end

if islower
    if any(isuppercell)
        error('At least one cell was provided as an upper triangular cell, but the matrices are lower triangular.')
    end
    if ~all(islowercell) && ~all(issymmcell)
        error('There is a mixture of lower and symmetric cells. Please make them uniform.')
    end
end

if ~isupper && ~islower
    % check if the matrix is symmetric
    if ~issymmetric(cfg.files.components.index)
        error('Full matrix was passed, but not symmetric, so cannot be used as pattern component matrix.')
    else
        % if it is, pass the indices in the lower triangular matrix
        cfg.files.components.index(logical(triu(cfg.files.components.index,1))) = 0;
    end
elseif isupper && islower
    error('cfg.files.components.index was passed as an empty matrix!')
end
% otherwise it is either an upper or lower, so we can keep it as it is.
design.components.index = find(cfg.files.components.index);


for i_cell = 1:n_cells
    design.components.matrix(:,i_cell) = cfg.files.components.matrix{i_cell}(design.components.index);
end

[design.components.subscript(:,1),design.components.subscript(:,2)] = ind2sub(szcomp,design.components.index);

if isfield(cfg.files.components,'get_inv') && cfg.files.components.get_inv
    design.components.matrixinv = pinv(design.components.matrix);
end

