function decoding_out = correlation_classifier_test(labels_test,data_test,cfg,model)

%

% History:
% 2016-08-09: Removed bug that true_labels were set to be labels_test
% rather than unique(labels_test) which is also how correlation_classifier
% deals with this

if isstruct(data_test), error('This method requires training vectors in data_test directly. Probably a kernel was passed. This method does not support kernel methods.'), end

switch lower(cfg.decoding.method)
    
    case 'classification'
        [predicted_labels,decision_values,opt] =  correlation_classifier(labels_test,data_test,model);
        
    case 'classification_kernel'
        % Develop: If you implement this, adapt error at the beginning
        error('correlation_classifier_test doesn''t work with passed kernels at the moment - please use libsvm or another method instead.')
        
    case 'regression'
        error('correlation_classifier_test cannot be used for a regression analysis - please use libsvm or another method instead.')
        
end

decoding_out.predicted_labels = predicted_labels;
decoding_out.true_labels = uniqueq(labels_test); % this sorts test labels in the same way as the correlation_classifier would sort them
decoding_out.decision_values = decision_values;
decoding_out.model = model;
decoding_out.opt = opt.r; % return correlation matrix

