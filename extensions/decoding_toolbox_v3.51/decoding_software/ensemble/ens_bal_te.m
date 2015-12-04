% function [predicted_labels decision_values opt] = ens_bal_te(labels,data,model,cfg)
%
% Testing part of ensemble approach that is used for balancing data. All
% models that have been trained are combined and tested and decision values
% are averaged together for each sample to generate an overall vote (this
% is not identical to a majority vote, please adjust code if you prefer
% this or email us). 
%
% This currently only works with binary classification, but it should be
% possible to adapt easily for multiclass classification (contact the
% authors for help on doing so).
%
% INPUT (n = n_samples, p = n_features):
%   labels: nx1 vector of labels of test data
%   data:   pxn matrix of test data
%   model: struct variable with the following required field
%           .model which again is a struct with size n_iter (n_iter is set
%                  in cfg)
%   cfg: typical cfg filled out during preparation of classification
%
% OUTPUT:
%   predicted_labels
%   decision_values: Point on projected axis
%   opt: currently empty

function [predicted_labels, decision_values, opt] = ens_bal_te(labels_test,data_test,model,cfg)

try
    param = cfg.decoding.test.(cfg.decoding.method).model_parameters;
    n_iter_real = cfg.decoding.train.(cfg.decoding.method).model_parameters.n_iter;
    n_iter_present = length(model.model);
    classifier = str2func([cfg.decoding.train.(cfg.decoding.method).model_parameters.software '_test']);
    modelparam = param.model_parameters;
    ulabels = uniqueq(labels_test);
    
    % overwrite cfg internally for actual classifier
    cfg.decoding.test.(cfg.decoding.method).model_parameters = modelparam;
    
catch %#ok<CTCH>
    disp('Probably one of this was missing and caused the error below:')
    disp(['Required fields for ens_bal_te (assuming classification): \n',...
        'cfg.decoding.train.classification.model_parameters.n_iter\n',...
        'cfg.decoding.train.classification.model_parameters.software\n',...
        'cfg.decoding.test.classification.model_parameters.model_parameters\n'])
    rethrow(lasterror) %#ok<LERR>
end

% Externalize from loop to get size of variable
prev_model = model.model(1);
decoding_out = classifier(labels_test,data_test,cfg,prev_model);
curr_dv = zeros(length(decoding_out.decision_values),n_iter_real);
curr_dv(:,1) = decoding_out.decision_values;
for i_iter = 2:n_iter_present
    curr_model = model.model(i_iter);
    if isempty(curr_model.SVs)
        curr_dv(:,i_iter) = curr_dv(:,i_iter-1);
    elseif isequal(curr_model,prev_model)
        curr_dv(:,i_iter) = curr_dv(:,i_iter-1);
    else
        decoding_out = classifier(labels_test,data_test,cfg,model.model(i_iter));
        curr_dv(:,i_iter) = decoding_out.decision_values;
        prev_model = curr_model;
    end
end

% fill in missing values with last column that exists
if n_iter_real>n_iter_present
    % this is a faster version of repmat
    c = curr_dv(:,n_iter_present);
    curr_dv(:,n_iter_present+1:n_iter_real) = c(:,ones(1,n_iter_real-n_iter_present));
end

decision_values = mean(curr_dv,2);
predicted_labels(decision_values<0,1) = ulabels(1);
predicted_labels(decision_values>=0,1) = ulabels(2);

% currently, opt is not used, but we might change that if the classifier requires it
opt = [];