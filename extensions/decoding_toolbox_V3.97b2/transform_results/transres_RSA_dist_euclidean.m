function output = transres_RSA_dist_euclidean(decoding_out,chancelevel,cfg,data)

% function output = transres_RSA_dist_euclidean(decoding_out,chancelevel,cfg,data)
% 
% Calculates the euclidean distance between all datapoints of the full 
% datamatrix.
%
% 2013 Martin H.

warningv('TRANSRES_RSA_DIST_CORR:DEPREC',...
    ['The use of this function is deprecated and it will be removed ',...
     'in future versions of the toolbox. Please use ',...
     'cfg.decoding.software = ''similarity'', ',...
     'cfg.decoding.train.classification.model_parameters = ''euc'', ',...
     'and cfg.results.output = ''other'' to return Euclidean distances.'])

SS = sum(data.*data,2);
output = {sqrt(bsxfun(@plus,SS,SS')-(2*data)*data')};
