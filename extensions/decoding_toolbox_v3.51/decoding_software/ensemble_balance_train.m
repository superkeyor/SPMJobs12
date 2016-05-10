function model = ensemble_balance_train(labels_train,data_train,cfg)

switch lower(cfg.decoding.method)

    case 'classification'
        model = ens_bal_tr(labels_train,data_train,cfg);
                
    case 'classification_kernel'
        model = ens_bal_tr(labels_train,data_train,cfg);
        
    case 'regression'
        model = ens_bal_tr(labels_train,data_train,cfg);
        
    otherwise
        error('Unknown decoding method %s for cfg.decoding.software = %s',...
            cfg.decoding.method, cfg.decoding.software)
end