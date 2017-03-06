% function [cfg,data_train_trans,data_test_trans,score] = transfeat_PCA(cfg,data_train,data_test)
%
% no help available, please check code

% Update: 2016-08-25: Removed call of princomp, because direct call is faster

function [cfg,data_train_trans,data_test_trans,score] = transfeat_PCA(cfg,data_train,data_test)


% existpca = exist('pca.m','file');
% 
% if existpca || exist('princomp.m','file')
%     
%     if existpca % this function just does additional calculations such as inverting the sign of some components and coefficients
%         [PC_coeff,data_train_trans,score] = pca(data_train,'algorithm','eig','economy',1);
%     else
%         [PC_coeff,data_train_trans,score] = princomp(data_train,'econ'); %#ok<PRINCOMP>
%     end
%     
%     score = (1/sum(score)) * score; % variance in percent
%     data_test_trans = data_test * PC_coeff;
%     [n_samp,n_feat] = size(data_train);
%     if n_samp<=n_feat % TODO: check if it should be < or <=
%         data_train_trans(:,end+1:n_feat) = 0;
%         data_test_trans(:,end+1:n_feat) = 0;
%         score(end+1:n_feat) = 0;
%     end
%     
% else

[PC_coeff,PC_cov] = eig(cov(data_train));
score = diag(PC_cov); % PC variance
score = (1/sum(score)) * score; % variance in percent
data_train_trans = data_train * PC_coeff;
data_test_trans = data_test * PC_coeff;

% end



% OLD CODE THAT WE LEAVE HERE (THE TRANSFORMATION IS NOT CORRECT AND
% EIG IS DEFINITELY CORRECT)
% 
% [n_samp,n_feat] = size(data_train);
% if n_samp < n_feat % if we have less samples than features use SVD
%     
%     [U,PC_cov,PC_coeff] = svd(data_train);
%     score =  diag(PC_cov);
%     score = (1/sum(score)) * score; % variance in percent
%     data_train_trans = data_train * PC_coeff;
%     data_test_trans = data_test * PC_coeff;
% 
% else % else use EIG
