function decoding_out = similarity_test(labels_test,data_test,cfg,model)

if isstruct(data_test), error('This method requires training vectors in data_test directly. Probably a kernel was passed method is use. This method does not support kernel methods'), end

switch lower(cfg.decoding.method)
    
    case 'classification'
        if isfield(cfg.design,'train_eq_test') && cfg.design.train_eq_test == 1
            dist =  pattern_similarity_fast(model.vectors_train,cfg.decoding.train.classification.model_parameters);
        else
            % we are just ignoring the test data and assume the training data to also represent the test data
            dist =  pattern_similarity(model.vectors_train,data_test,cfg.decoding.train.classification.model_parameters);
        end
    case 'classification_kernel'
        error('cfg.decoding.method = ''classification_kernel''. Similarity calculations currently don''t work with passed kernels. Although it would make sense as it represents the G-matrix for the linear kernel (Diedrichsen et al., 2011), most people would not understand this.')
        
    case 'regression'
        error('similarity_test currently cannot be used for a regression analysis.')
        
end

decoding_out.predicted_labels = [];
decoding_out.true_labels = [];
decoding_out.decision_values = [];
decoding_out.model = [];
decoding_out.opt = dist; % return correlation matrix

