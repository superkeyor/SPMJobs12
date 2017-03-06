% function [data,scaleparams] = decoding_scale_data(cfg,data,scaleparams,residuals)
%
% Function to perform data scaling on training or on test data. There are
% two ways in which scaling can be performed: Using the data itself to
% estimate scaling, or using external data (e.g. a covariance matrix from
% residuals).
%
% The function currently supports only row scaling, i.e. scaling
% across samples, or scaling using the full variance/covariance matrix. To
% preserve full independence of training and test data, one
% approach is to perform scaling on training data and later apply
% these parameters to test data (estimation = 'across').
%
% However, in general there is no reason to assume that a simple scaling of 
% data can carry any category-specific information from training to test 
% set, so scaling can under normal circumstance be performed using all data
% samples, which is more stable (recommended; estimation = 'all').
%
% To prevent dividing by 0 if input data has no variance, i.e. all input
% data in one dimension/voxel are the same:
%   'min0max1': will set max = min+1
%          'z': will set std = 1
%
% Input variables:
%    cfg                 : struct containing configuration information
%    cfg.scale.method    : 'z', 'min0max1', 'cov', 'none'. Defines type of scaling.
%    cfg.scale.estimation: 'all', 'across', 'separate', or 'none'. When all
%                          is selected, the scaling parameter are estimated
%                          and applied to all data. When across is
%                          selected, the scaling parameters are estimated
%                          in each step on the training data only, and are
%                          then applied to both training and test data
%                          separately (slower). When separate is estimated,
%                          then scaling is done for each chunk (e.g. run)
%                          separately. Remark: Because no class information
%                          is used to estimate the scaling parameters, we
%                          currently believe that this does not lead to any
%                          "double dipping" if the goal is to measure
%                          information content of the current data set, not
%                          to build a general classifier. However, it is
%                          the responsibility of the user to ensure
%                          independence of training and test data.
%   cfg.scale.shrinkage:   field required for cfg.scale.method = 'cov'
%                          which will do shrinkage based on residuals.
%                          Options include 'none', 'pinv', 'lw'
%                          (Ledoit-Wolf, spherizes), 'lw2' (Ledoit-Wolf,
%                          retain variances), 'oas' (Oracle approximating
%                          shrinkage, Chen et al., spherizes) (if you want
%                          to use your own shrinkage, see explanation in
%                          ldatrain), requires 
%    [cfg.scale.cutoff]  : optional input for outlier reduction, 1x2 vector
%                         ([lower bound upper bound])
%    data                : contains samples to be scaled
%    [scaleparams]       : possibly needed for action 'test', generated from
%                         action 'train', can be passed as empty
%    [residuals]         : required when cfg.scale.shrinkage is used.
%                         Usually extracted from opt.residuals
%
% Output:
%    data         : samples on which scaling had been performed
%    [scaleparams]: when needed scaling parameters for action 'test'
%
% Martin H. 2010/05/12
%
% See also DECODING, DECODING_DEFAULTS, DECODING_FEATURE_SELECTION,
% DECODING_PARAMETER_SELECTION, DECODING_FEATURE_TRANSFORMATION

% History:
% Martin H.: Introduced method 'separate' and possibility to do cov-scaling
% Kai: removed bug that min0max1 did not work when min==max
% restructured Martin H. 2010/07/25

function [data,scaleparams] = decoding_scale_data(cfg,data,scaleparams,residuals)

% if no scaling is wanted, return to invoking function
if strcmp(cfg.scale.method,'none')
    scaleparams = []; % do nothing
    return
end

% Check for incompletely specified options
if ~isfield(cfg.scale,'shrinkage'), cfg.scale.shrinkage = 'none'; end
if xor(~strcmpi(cfg.scale.shrinkage,'none'),strcmpi(cfg.scale.method,'cov'))
    error('cfg.scale.method = ''%s'', but cfg.scale.shrinkage = ''%s''. Please either set cfg.scale.method = ''cov'' or set cfg.scale.shrinkage = ''none''.',cfg.scale.method,cfg.scale.shrinkage)
end

% Set scaling parameters
if ~exist('scaleparams','var') || isempty(scaleparams)
    switch lower(cfg.scale.method)
        case 'min0max1'
            scaleparams.samples_min = min(data,[],1);
            scaleparams.samples_max = max(data,[],1);
            min_eq_max = scaleparams.samples_min==scaleparams.samples_max; % check if in any dimension min == max
            scaleparams.samples_max(min_eq_max) = scaleparams.samples_min(min_eq_max) + 1; % prevents divide by 0, if min == max
        case 'z'
            scaleparams.samples_mean = mean(data);
            scaleparams.samples_std = std(data);
            scaleparams.samples_std(scaleparams.samples_std==0) = 1; % prevents divide by 0, if no std exists
        case 'cov'
            lambda = []; % init
            switch lower(cfg.scale.shrinkage)
                case 'none'
                    sigma = eye(size(residuals,1));
                case 'pinv'
                    sigma = pinv(residuals);
                case 'lw'
                    [sigma,lambda] = covshrink_lw(residuals);
                case 'lw2'
                    [sigma,lambda] = covshrink_lw2(residuals);
                case 'oas'
                    [sigma,lambda] = covshrink_oas(residuals);
                otherwise
                    fhandle = str2func(['@(x) covshrink_' cfg.scale.shrinkage '(x)']);
                    try
                        [sigma,lambda] = fhandle(residuals);
                    catch %#ok<CTCH>
                        disp(lasterr) %#ok<LERR>
                        error('Error trying scaling method ''cov'' with shrinkage method covshrink_%s. Either function is not on path, it is not used correctly, or it has errors.',cfg.scale.shrinkage)
                    end
            end
            scaleparams.samples_sigma = sigma;
            scaleparams.sample_lambda = lambda;
            
        otherwise
            error(['Unknown scaling method ' cfg.scale.method ', please check'])
    end
end



% Scale data
if exist('bsxfun','builtin') % New method for Matlab 7.4+ (fast)
    
    switch lower(cfg.scale.method)
        case 'min0max1'
            data = bsxfun(@minus, data, scaleparams.samples_min);
            data = bsxfun(@rdivide, data, scaleparams.samples_max - scaleparams.samples_min);
        case 'z'
            data = bsxfun(@minus, data, scaleparams.samples_mean);
            data = bsxfun(@rdivide, data, scaleparams.samples_std);
        case 'cov'
%             data = data*sigma^(-1/2);
              % the alternative method below is actually faster
              [E,D] = eig(sigma);
              data = data*E*diag(1./real(sqrt(diag(D))))*E';
    end
    
else % Old method for < Matlab 7.4 (slow)
    
    % TODO: replace repmat by ones(size(data,1),1) --> faster
    
    switch lower(cfg.scale.method)
        case 'min0max1'
            minmat = repmat(scaleparams.samples_min,size(data,1),1);
            maxmat = repmat(scaleparams.samples_max,size(data,1),1);
            data = (data - minmat)./(maxmat - minmat);
        case 'z'
            meanmat = repmat(scaleparams.samples_mean,size(data,1),1);
            stdmat = repmat(scaleparams.samples_std,size(data,1),1);
            data = (data - meanmat) ./ stdmat;
        case 'cov'
%             data = data*sigma^(-1/2);
            % the alternative method below is actually faster
            [E,D] = eig(sigma);
            data = data*E*diag(1./real(sqrt(diag(D))))*E';            
    end
    
end

% Remove outliers (default cutoff: [-Inf Inf])
data(data<cfg.scale.cutoff(1)) = cfg.scale.cutoff(1);
data(data>cfg.scale.cutoff(2)) = cfg.scale.cutoff(2);