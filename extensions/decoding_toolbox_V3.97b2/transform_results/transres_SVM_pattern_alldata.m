% output = transres_SVM_pattern_alldata(decoding_out, chancelevel, cfg, data)
%
% Calculates the pattern according to Haufe et al (2014), Neuroimage. This
% is done by first getting the weights in source space (primal problem), if
% a linear SVM was used (for non-linear methods no weights can be
% calculated for the primal problem). It assumes that all data can be used
% to calculate the pattern and for many classes is a lot faster than the
% version that calculates the pattern for each pair, plus it will be more
% accurate when the noise is the same for all classes, but will be
% inaccurate if noise varies.
%
% The bias term is not needed for this.
% To use it, use
%
%   cfg.results.output = {'SVM_pattern'}
%
% Caution: This function uses cfg.design, so it needs a design and assumes
% you are in the main analysis (and not in e.g. feature_selection). It
% further assumes that all input models are related to their decoding step
% (i.e. model{1} is from iteration 1, etc.)
%
% OUTPUT
%   1x1 cell array of cell arrays for each output(step), with the pattern
%   as a 1xn_features numeric output.
%
% Martin, 2016-08-31

function output = transres_SVM_pattern_alldata(decoding_out, chancelevel, cfg, data)

%% check that input data has not been changed without the user knowing it
check_datatrans(mfilename, cfg);

%% Get weights (implementation from libsvm website)

w = transres_SVM_weights(decoding_out, chancelevel, cfg, data);

% Unpack model
model = [decoding_out.model];

n_models = length(model);
output{1} = cell(n_models,1);
for i_model = 1:n_models
    
    weights = w{1}{i_model};
    
    %% Get pattern
    
    data_train = data;
    [n_samples, n_dim] = size(data_train);
    
    inv_scale_param = 1./var(data_train*weights); % since the cov gives us a scalar, we can use var, and this does the scaling for each pattern
    
    % get covariance matrix first (it doesn't change)
    if n_dim^2<10^7
        data_cov = cov(data_train);
        pattern_unscaled = data_cov*weights;
    else
        % else do row by row (not much slower, even if we chunk it no dramatic speed-up)
        warningv('TRANSRES_SVM_PATTERN_ALLDATA:pattern_calculation_slow','Pattern is very large, so its estimation will be very slow (up to minutes)!')
        
        fprintf(repmat(' ',1,20))
        backstr = repmat('\b',1,20);
        for i = 1:n_dim % now calculate columnwise
            if i == 1 || ~mod(i,round(n_dim/50)) || i == n_dim
                fprintf([backstr '%03.0f percent finished'],100*i/n_dim)
            end
            data_train(:,i) = data_train(:,i) - mean(data_train(:,i)); % remove mean columnwise
            data_cov = (data_train(:,i)'*data_train)/(n_samples-1);
            pattern_unscaled(i,:) = data_cov * weights;
        end
        
        fprintf('\ndone.\n')
        
    end
    
    if exist('bsxfun','builtin')
        pattern = bsxfun(@times,pattern_unscaled,inv_scale_param);
    else
        pattern = pattern_unscaled .* repmat(inv_scale_param,n_dim,1);
    end
    
    output{1}{i_model} = pattern;
end



