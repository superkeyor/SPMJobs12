function varargout = read_image(software,varargin)

% function varargout = read_image(software,varargin)
%   IN
%     software: String with software to read header in cfg.software (e.g. 'SPM8')
%     varargin: header (struct variable generated with read_header) and
%       potentially more
%
%   OUT
%       image as 3D volume image in neurological space (left = left, view from top)
%
% EXAMPLE 
% to read the files 'test.img' and 'test.hdr':
%
%   cfg = decoding_defaults;
%   hdr = read_header(cfg.software, 'test.img');
%   vol = read_image(cfg.software, hdr);



check_software(software);
fname = [mfilename '_' lower(software)];
varargout{1} = feval(fname,varargin{:});