% output = transres_SVM_weights(decoding_out, chancelevel, cfg, data)
% 
% Calculates the weights in source space (primal problem), if a linear SVM 
% was used (otherwise no weights can be calculated for the primal problem).
% Use this function if you only want to plot weights and not more
% calculations, because then the decoding toolbox can automate this for
% you. If you need the bias term for calculations, use
% transres_SVM_weights_plusbias.
%
% To use it, use
%
%   cfg.results.output = {'SVM_weights'}
%
% OUTPUT
%   1x1 cell array of cell arrays for each output(step), with the weights
%   for each primal dimension as n_weightsx1 numeric output.
%   % for multiclass the output is a n_weights x n_comparisons matrix with
%   a column for each pair of comparisons (for 3 classes: class 1 vs. 2,
%   1 vs. 3, 2 vs. 3)
%
% See also transres_SVM_weights_plusbias, transres_SVM_pattern


% Martin, 2014-01-15
%
% UPDATE 
% Martin 2016-08-12: generalized to kernel method, results now returned in
%                    order of labels rather than order supplied (example: 1
%                    always comes before 2)
% Martin 2016-03-08: included case of multiclass classification (a
%                    lot faster than many pairwise classifications)

% TODO: re-implement Newton SVM:
%   weights.w = m.w;
%   weights.b = -m.gamma;

function output = transres_SVM_weights(decoding_out, chancelevel, cfg, data)

%% check that input data has not been changed without the user knowing it
check_datatrans(mfilename, cfg); 

%% check that the model was a linear SVM 
% only works for libsvm for the moment
if ~strcmpi(cfg.decoding.software,'libsvm')
    error('Can''t get primal weights for anything but libsvm at the moment');
end
% check that we indeed use a linear SVM
% get the current libsvm parameters
libsvm_options = cfg.decoding.train.(cfg.decoding.method).model_parameters;

% find '-t 0' in the current options (parameter for linear svm)
if isempty(strfind(libsvm_options, '-t 0'))
    if isempty(strfind(libsvm_options, '-t 4'))
    % if not check if it is a kernel method else throw error
    error(['Linear weights cannot be calculated, because the chosen classifier is not linear. ',...
        'Calculating linear weights for the primal problem using a non-linear classifier does not make sense. ',...
        'Either do not return weights as output or choose a linear classifier.'])
    else % if kernel method
        warningv('TRANSRES_SVM_WEIGHTS:LINEAR_KERNEL','Assuming linear kernel for weight reconstruction.')
    end
end

% Unpack model
model = [decoding_out.model];

%% implementation from libsvm website
% see http://www.csie.ntu.edu.tw/~cjlin/libsvm/faq.html#f804

n_models = length(model);
output{1} = cell(n_models,1);

% in case classical classification is used
if strcmpi(cfg.decoding.method, 'classification')
    
    for i_model = 1:n_models
        m = model(i_model);
        
        % get model labels
        labelorder = m.Label;
        issort = issorted(labelorder);
        
        n_label = length(labelorder);
        
        if n_label == 2
            % simple case for binary classification
            weights = m.SVs' * m.sv_coef;
            % if the labelorder is the wrong way around, invert sign of weights
            if labelorder(1) < labelorder(2)
                output{1}{i_model} = weights;
            else
                output{1}{i_model} = -weights;
            end
            
        else
            % more complex case for multiclass classification, see above for instructions
            % (coding this efficiently was not easy, feel free to improve):
            % http://www.csie.ntu.edu.tw/~cjlin/libsvm/faq.html#f804
            
            % we need to know which rows of SVs and of sv_coef belong to which
            % label, this is determined by the number of support vectors per label
            csum = cumsum(m.nSV);
            % the following provides us with a range for each
            rangeind = [[1; csum(1:end-1)+1] csum];
            
            % we get the relevant subscripts and convert them to indices, it
            % will give us the indices that signal the same pair, e.g. the indices
            % for (1,2) and (2,1) or for (31,5) and (5,31) -> the missing
            % diagonal would make this difficult for indexing
            [a,b] = meshgrid(1:n_label,1:n_label);
            c = tril(true(n_label),-1); % this is our logical index selecting the lower triangular matrix
            d = [a(c) b(c)];
            % This line is like ind2sub, but leaves out the diagonals to get indices
            ind = d(:,[2 1]) + (d-1)*n_label - [d(:,1) d(:,2)-1];
            
            % we assign all entries of sv_coef an index that we use to find relevant entries later
            mask = zeros(size(m.sv_coef,1),1);
            for i_label = 1:n_label
                mask(rangeind(i_label,1):rangeind(i_label,2)) = (i_label-1)*(n_label-1)+1;
            end
            mask = bsxfun(@plus,mask,0:n_label-2);
            
            % Since we want to re-sort the results, we need to find the
            % original order
            % If the true label1 is larger than true label2, then invert
            % (because the smaller label should always be first)
            if ~issort
                e = labelorder(d);
                sign_vector = 2*double( e(:,2) > e(:,1) ) -1;
                [trash,sort_vector] = sortrows( [min(e,[],2) max(e,[],2)]); % just sorting is not enough, they also need to be put in the correct order
            end
            
            % init
            weights = zeros(size(m.SVs,2),n_label*(n_label-1)/2);
            ct = 0;
            
            m.SVs = full(m.SVs); % this speeds everything up
            for i_label = 1:n_label
                for j_label = i_label+1:n_label
                    ct = ct+1; % increase counter
                    % index needs to be sorted, should always be the case if entered this way (I checked it)
                    rind = [rangeind(i_label,1):rangeind(i_label,2) rangeind(j_label,1):rangeind(j_label,2)];
                    % need to index separately to maintain order
                    coef = [m.sv_coef(mask==ind(ct,1)); m.sv_coef(mask==ind(ct,2))];
                    % carry out calculation as done on libsvm website
                    weights(:,ct) = m.SVs(rind,:)'*coef;
                end
            end
            
            if issort
                output{1}{i_model} = weights;
            else
                output{1}{i_model} = bsxfun(@times,weights(:,sort_vector),sign_vector');
            end
            
        end
        
    end
    
    
elseif strcmpi(cfg.decoding.method, 'classification_kernel')
    
    for i_model = 1:n_models
        m = model(i_model);
        
        data_train = data(cfg.design.train(:, i_model) > 0, :);
        
        % get model labels
        labelorder = m.Label;
        issort = issorted(labelorder);
        
        n_label = length(labelorder);
        
        
        if n_label == 2
            % simple case for binary classification
            weights = data_train(m.sv_indices,:)' * m.sv_coef;
            % if the labelorder is the wrong way around, invert sign of weights
            if labelorder(1) < labelorder(2)
                output{1}{i_model} = weights;
            else
                output{1}{i_model} = -weights;
            end
            
        else
            % more complex case for multiclass classification, see above for instructions
            % (coding this efficiently was not easy, feel free to improve):
            % http://www.csie.ntu.edu.tw/~cjlin/libsvm/faq.html#f804
            
            % we need to know which rows of SVs and of sv_coef belong to which
            % label, this is determined by the number of support vectors per label
            csum = cumsum(m.nSV);
            % the following provides us with a range for each
            rangeind = [[1; csum(1:end-1)+1] csum];
            
            % we get the relevant subscripts and convert them to indices, it
            % will give us the indices that signal the same pair, e.g. the indices
            % for (1,2) and (2,1) or for (31,5) and (5,31) -> the missing
            % diagonal would make this difficult for indexing
            [a,b] = meshgrid(1:n_label,1:n_label);
            c = tril(true(n_label),-1); % this is our logical index selecting the lower triangular matrix
            d = [a(c) b(c)];
            % This line is like ind2sub, but leaves out the diagonals to get indices
            ind = d(:,[2 1]) + (d-1)*n_label - [d(:,1) d(:,2)-1];
            
            % we assign all entries of sv_coef an index that we use to find relevant entries later
            mask = zeros(size(m.sv_coef,1),1);
            for i_label = 1:n_label
                mask(rangeind(i_label,1):rangeind(i_label,2)) = (i_label-1)*(n_label-1)+1;
            end
            mask = bsxfun(@plus,mask,0:n_label-2);
            
            % Since we want to re-sort the results, we need to find the
            % original order
            % If the true label1 is larger than true label2, then invert
            % (because the smaller label should always be first)
            if ~issort
                e = labelorder(d);
                sign_vector = 2*double( e(:,2) > e(:,1) ) -1;
                [trash,sort_vector] = sortrows( [min(e,[],2) max(e,[],2)]); % just sorting is not enough, they also need to be put in the correct order
            end
            
            % init
            weights = zeros(size(data_train,2),n_label*(n_label-1)/2);
            ct = 0;
            
            m.SVs = full(m.SVs); % this speeds everything up
            for i_label = 1:n_label
                for j_label = i_label+1:n_label
                    ct = ct+1; % increase counter
                    % index needs to be sorted, should always be the case if entered this way (I checked it)
                    rind = [rangeind(i_label,1):rangeind(i_label,2) rangeind(j_label,1):rangeind(j_label,2)];
                    % need to index separately to maintain order
                    coef = [m.sv_coef(mask==ind(ct,1)); m.sv_coef(mask==ind(ct,2))];
                    % carry out calculation as done on libsvm website
                    weights(:,ct) = data_train(m.sv_indices(rind,:),:)' * coef;
                end
            end
            
            if issort
                output{1}{i_model} = weights;
            else
                output{1}{i_model} = bsxfun(@times,weights(:,sort_vector),sign_vector');
            end
            
        end
        
    end
    
    
else
    error('Method %s not implemented for cfg.decoding.method = %s.',mfilename,cfg.decoding.method)
end

% %% old version
% The old version works for smaller problems, but not for e.g. wholebrain
% decoding. So I replaced it by a one that should always work. It might
% become interesting trying the code below for linear kernels though
% (although it might actually be too slow).
% % get the size of the current primal source space
% [nSVs, primal_dim] = size(model(1).SVs);
% 
% % init a matrix that contains orthogonal + 1 entries
% X = [eye(primal_dim); ones(1, primal_dim)];
% % generate labels (values are unimportant, we are interested in decision_values only)
% labels = ones(size(X, 1), 1);
%     
% % "reverse-engineer" the model for each step
% for i_model = 1:length(model)
% 
%     m = model(i_model);
%     
%     % get the predictions from this model
%     switch lower(cfg.decoding.method)
%         case 'classification'
%             [predicted, acc, decision_values] = svmpredict(labels,X,m,cfg.decoding.test.classification.model_parameters);
%         case 'regression'
%             [predicted, acc, decision_values] = svmpredict(labels,X,m,cfg.decoding.test.regression.model_parameters);
%     end
%         
%     % calculate w and b
%     %  using
%     % Y = w' X + b --> Y = [wb]' [X1] --> Y / [X1] = [wb]'
%     % with X = eye(size(...))
% 
%     wb = decision_values' / [X, ones(size(decision_values))]';
% 
%     w = wb(1:end-1);
%     b = wb(end);
% 
%     weights.w = w;
%     weights.b = b;
%     
%     output.weights{i_model} = weights;
%     
% end