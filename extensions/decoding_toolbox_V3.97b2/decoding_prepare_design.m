% This function call is deprecated.
%
% Because this function does not prepare a decoding, but describes the
% data, it is now called decoding_describe_data.m. 
% Otherwise nothing changed.
%
% For convenience this function calls decoding_describe_data() for you.
%
% See also DECODING_DESCRIBE_DATA

% function cfg = decoding_prepare_design(cfg,labelnames,labels,regressor_names,beta_loc,xclass)

function cfg = decoding_prepare_design(varargin)

warning('DECODING_PREPARE_DESIGN:deprecated', 'decoding_prepare_design() is deprecated because the name was misleading.\nIt is going to be removed in future versions of the toolbox. Please use decoding_describe_data() instead.')

cfg = decoding_describe_data(varargin{:});