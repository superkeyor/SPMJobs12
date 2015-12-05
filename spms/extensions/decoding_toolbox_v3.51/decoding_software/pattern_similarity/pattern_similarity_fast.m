% function sim = pattern_similarity_fast(x,method,param)
%
% This function calculates pattern similarity for the desired similarity
% metric (e.g. 'pearson' for pearson correlation or 'cov' for covariance).
% This function is slightly faster than the more general version
% pattern_similarity, because it assumes that similarity calculations are
% done on the data themselves, not between two sets of data.
% Importantly, it returns a similarity metric or a dissimilarity metric,
% depending on the type of output (a correlation is a similarity metric and
% is returned as is, a Euclidean distance is a dissimilarity metric). The
% function has some dependencies with functions in the folder 'general'.
%
% INPUT:
%   x: NxP matrix of data (P features, N samples)
%   method: method for similarity metric, implemented methods include:
%       - 'gmatrix' or 'gma': X'*X, commonly used in pattern component
%           modeling, can be used to construct Euclidean distance
%       - 'euclidean' or 'euc':  Euclidean distance
%       - 'Pearson', 'pea' or 'cor': Pearson correlation similarity
%       - 'zcorr' or 'zco': Fisher-z-transformed correlation similarity
%       - 'Kendall' or 'ken': Kendall's tau rank correlation similarity
%       - 'Spearman' or 'spe': Spearman's rho rank correlation similarity
%       - 'covariance' or 'cov': Sample covariance (divides by n-1)
%       if you want to use your own method, simply pass a string with the
%           function name (has to be on the path!)
% 	[param]: optional parameter(s) for similarity metric
%
% The output is a similarity matrix (e.g. correlation matrix) across all
% pair-wise comparisons.
%
% 2015/04/14 Martin Hebart

function sim = pattern_similarity_fast(x,method,param)

n_vox = size(x,2);

% p = ~exist('param','var');

switch lower(method(1:3))
    
    case 'gma'
        
        sim = x*x';
        
    case 'cve'
        
        error(['Method ''cve'' (or ''cveuclidean2'') doesn''t make sense ',...
            'when training equals test data (design.train_eq_test == 1). ',...
            'Please use ''euc'' instead or choose a method where training ',...
            'is not equal to test data.'])
        
    case 'euc'
        
        sim = euclidean(x);
        
    case 'cor'
        
        sim = correlmat(x');

    case 'zco'
        
        % most extreme correlation value allowed is ~0.9999999958
        sim = atanh(min(max(correlmat(x'),-10),10));        
        
    case 'pea'
        
        sim = correlmat(x');
        
    case 'spe'
        
        sim = corr(x','type','spearman');
        
    case 'ken'
        
        sim = corr(x','type','kendall');
        
    case 'cov'
        
        sim = covq(x');
        
    otherwise
        
        error('Unknown or incorrectly used method %s for cfg.decoding.software = ''pattern_similarity'' Check field cfg.decoding.train.classification.model_parameters',method)
        
end



if n_vox == 1 % unusual case in which only one voxel is present (if only one voxel is present, sometimes a similarity metric is not possible)
    
    if any(strcmpi(method,{'cor','pea','spe','ken','cov'}))
        warningv('PATTERN_SIMILARITY:ONEVOXEL','Searchlight or ROI with only one voxel (may happen at borders of mask). With the current settings no similarity measure possible, setting all values to NaN!')
    end
end