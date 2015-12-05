% function output = transres_rsa_beta(decoding_out, chancelevel, varargin)
% 
% Calculate a GLM using cfg.files.components.matrix as regressors and
% decoding_out(cfg.design.components.index) as data. The resulting betas are
% returned as output. For multiple calculations, these are faster when the
% inverse of cfg.design.components.matrix exists as field
% cfg.design.components.matrixinv.
% PLEASE NOTE: it would be advisable to include a constant regressor if the
% individual effects are required and a general similarity / dissimilarity
% above 0 is assumed. Please make sure that this baseline regressor is not
% linearly dependent on other regressors.
%
% Martin Hebart, 2015-04-16

function output = transres_rsa_beta(decoding_out, chancelevel, varargin)

% varargin{1} is cfg

try
    output = {varargin{1}.design.components.matrixinv * decoding_out.opt(varargin{1}.design.components.index)};
catch % if the inverse doesn''t exist
    output = {pinv(varargin{1}.design.components.matrix) * decoding_out.opt(varargin{1}.design.components.index)};
end