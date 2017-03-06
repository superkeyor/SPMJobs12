% function sim = pattern_similarity(x,y,method,param)
%
% This function calculates pattern similarity for the desired similarity
% metric (e.g. 'pearson' for pearson correlation or 'cov' for covariance).
% Importantly, it returns a similarity metric or a dissimilarity metric,
% depending on the type of output (a correlation is a similarity metric and
% is returned as is, a Euclidean distance is a dissimilarity metric). The
% function has some dependencies with functions in the folder 'general'.
%
% INPUT:
%   x: NxP matrix of data (P features, N samples)
%   y: NxP matrix of other (or even the same) data that should be compared to
%   method: method for similarity metric, implemented methods include:
%       - 'gmatrix' or 'gma': X'*Y, commonly used in pattern component
%           modeling, can be used to construct Euclidean distance
%       - 'cveuclidean2' or 'cve': will calculate the cross-validated
%           version of the squared Euclidean distance between X and Y
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

function sim = pattern_similarity(x,y,method,param)

n_vox = size(x,2);

% p = ~exist('param','var');

switch lower(method(1:3))
    
    case 'gma'
        
        sim = x*y'; % internally, many inputs are the other way around!
        
    case 'euc'
        
        sim = euclidean2(x,y);
        
    case 'cve'
        
        sim = cveuclidean2(x,y);
        
    case 'cor'
        
        sim = correlmat(x',y');
        
    case 'zco'
        
        % most extreme correlation value allowed is ~0.9999999958
        sim = atanh(min(max(correlmat(x',y'),-10),10));            
        
    case 'pea'
        
        sim = correlmat(x',y');
        
    case 'spe'
        
        sim = corr(x',y','type','spearman');
        
    case 'ken'
        
        sim = corr(x',y','type','kendall');
        
    case 'cov'
        
        sim = cov2(x',y');
        
    otherwise
        
        error('Unknown or incorrectly used method %s for cfg.decoding.software = ''pattern_similarity'' Check field cfg.decoding.train.classification.model_parameters',method)
        
end



if n_vox == 1 % unusual case in which only one voxel is present (if only one voxel is present, sometimes a similarity metric is not possible)
    
    if any(strcmpi(method,{'cor','pea','spe','ken','cov'}))
        warningv('PATTERN_SIMILARITY:ONEVOXEL','Searchlight or ROI with only one voxel (may happen at borders of mask). With the current settings no similarity measure possible, setting all values to NaN!')
    end
end