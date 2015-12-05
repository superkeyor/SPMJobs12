%---------------------------------------------------
% F-value calculation
function F = fvalue(varargin)

% This function runs several one factor ANOVAs in parallel.
% It is a great lot faster than the function provided by Matlab
% and may save considerable time depending on the number of necessary
% F-value calculations. Also, it does not require the statistics toolbox.
%
% Two or more matrices are the input, each column representing one F-test,
% each row representing a dataset (e.g. column: voxels, rows: steps)

% In its current formulation it cannot deal with differently
% sized matrices (n ~= m).

c = [];
k = nargin; % number of groups
DFm = k-1;
DFr = -nargin; % sum of all sizes minus number of groups

% init
matrix = cell(nargin,1);
meanmatrix = cell(nargin,1);
diffmatrix = cell(nargin,1);
meanmatrixmat = cell(nargin,1);

for i = 1:nargin
    matrix{i} = varargin{i};
    c = [c; matrix{i}]; %#ok<AGROW>
    DFr = DFr + size(matrix{i},1);
    meanmatrix{i} = mean(matrix{i});
end

n = size(matrix{i},1);

grandmean = mean(c);

SSm = zeros(size(grandmean));
for i = 1:nargin
    SSm = SSm + (meanmatrix{i}-grandmean).^2;
end
SSm = n * SSm;

SSr = zeros(size(meanmatrix{1}));
for i = 1:nargin
    if exist('bsxfun','builtin') % bsxfun exists only for Matlab 7.4+
        diffmatrix{i} = bsxfun(@minus,matrix{i},meanmatrix{i});
    else
        meanmatrixmat{i} =  repmat(meanmatrix{i},size(matrix{i},1),1);
        diffmatrix{i} = matrix{i}-meanmatrixmat{i};
    end
    SSr = SSr+sum(diffmatrix{i}.^2);
end

Mm = SSm./DFm;
Mr = SSr./DFr;

F = Mm./Mr;