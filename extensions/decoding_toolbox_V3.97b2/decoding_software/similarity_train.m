function model = similarity_train(labels_train,data_train,cfg)

% This function passes the data for calculations of similarity carried out
% in similarity_test.

switch lower(cfg.decoding.method)
    
    case 'classification'
        % do nothing except return an data and labels as model
        model.vectors_train = data_train;
        model.labels_train = labels_train;
        model.chunk_train = cfg.files.chunk;
        
    case 'classification_kernel'
        error('cfg.decoding.method = ''classification_kernel''. Similarity calculations currently don''t work with passed kernels. Although it would make sense as it represents the G-matrix for the linear kernel (Diedrichsen et al., 2011), most people would not understand this.')
        
    otherwise
        error(...
           ['The "similarity" decoding software (cfg.decoding.software = ''similarity'') ', ...
           'only takes cfg.decoding.method = ''classification'' or ''classification_kernel'', to avoid confusions. ', ...
           'The currently set method is ''cfg.decoding.method = %s'' ', ...
           'for cfg.decoding.software = %s. ', ...
           'Please change.'],...
            cfg.decoding.method, cfg.decoding.software)
end