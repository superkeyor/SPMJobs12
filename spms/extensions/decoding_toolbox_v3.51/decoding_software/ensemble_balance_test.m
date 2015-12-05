function decoding_out = ensemble_balance_test(labels_test,data_test,cfg,model)

switch lower(cfg.decoding.method)

    case 'classification'
        [predicted_labels, decision_values, opt] = ens_bal_te(labels_test,data_test,model,cfg); %#ok<*ASGLU>
        
    case 'classification_kernel'
        [predicted_labels, decision_values, opt] = ens_bal_te(labels_test,data_test,model,cfg);
        
    case 'regression'
        [predicted_labels, decision_values, opt] = ens_bal_te(labels_test,data_test,model,cfg);
        
end

decoding_out.predicted_labels = predicted_labels;
decoding_out.true_labels = labels_test;
decoding_out.decision_values = decision_values;
decoding_out.model = model;
decoding_out.opt = opt;