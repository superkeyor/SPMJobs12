% output = transres_ninputdim(decoding_out, chancelevel, cfg, data, varargin)
% 
% This function returns the number of input dimensions (e.g. voxels of a
% searchlight or ROI) from the last decoding.
%
% To use it, use
%
%   cfg.results.output = {'ninputdim'}
%
% The number is retrieved from the dimensionality of the input data.
%
% Kai, 2016-12-22

function output = transres_ninputdim(decoding_out, chancelevel, cfg, data, varargin)

% get number of input dimensions from input data
[nsamples, ndim] = size(data);
output = ndim;

