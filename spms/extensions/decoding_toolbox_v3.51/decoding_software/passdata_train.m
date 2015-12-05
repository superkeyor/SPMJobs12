function model = passdata_train(labels_train,data_train,cfg)

% This function pretty much does nothing.
% It serves for the case in which you only want measures about the data
% (e.g. get the number of voxels ("dimension") of the searchlight/ROI or
% the covariance matrix or the like.
%
% Also set 
%   cfg.decoding.method = ''passdata''
% or
%   cfg.decoding.method = ''passdata_kernel''
% to avoid confusion.

switch lower(cfg.decoding.method)
    
    case {'passdata', 'none'} % none is old, kept for backward compatibility
        % do nothing except return an data and labels as model
        model.vectors_train = data_train;
        model.labels_train = labels_train;
        model.chunk_train = cfg.files.chunk;
        
    case {'passdata_kernel', 'none_kernel'} % none is old, kept for backward compatibility
        % do nothing except return an data and labels as model
        model.kernel_train = data_train;
        model.labels_train = labels_train; 
        model.chunk_train = cfg.files.chunk;
        
    otherwise
        error(...
           ['The "pass_data" (former "none") decoding software (cfg.decoding.software = ''passdata'') ', ...
           'only takes cfg.decoding.method = ''passdata'' or ''passdata_kernel'', to avoid confusions. ', ...
           'The currently set method is cfg.decoding.method = %s ', ...
           'for cfg.decoding.software = %s. ', ...
           'Please change.'],...
            cfg.decoding.method, cfg.decoding.software)
end