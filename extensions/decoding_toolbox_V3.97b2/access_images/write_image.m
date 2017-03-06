function varargout = write_image(software,varargin)

% Typical call
% 
%    function hdr = write_image(cfg.software, hdr, volume)
%
% or in general
%   function varargout = write_image(software,varargin)
% Write image using the software specified by software (typically
% cfg.software from decoding_defaults)
%
%  IN
%     software: String with software to read header in cfg.software (e.g. 'SPM8')
%     varargin: header, volume
%       header (SPM format or as in read_header for this software), volume (X x Y x Z)
%   OUT
%     output: written header (normally not needed)
%
% EXAMPLE 
% To write a volume to 'test.img' using a similar file as source for a header
%
%   % create random data (for example only) and get cfg (if you dont have
%   % it yet)
%   volume = randn(64, 64, 32); 
%   cfg = decoding_defaults; % if not already there
%   
%   % Get a header. The best way is to load it from a file that is similar
%   % to what you want to write: It should have the same voxel size, the 
    % same images size, the same location in standard space, the same 
%   % datatype, etc. For SPM, see "help spm_vol" for details about header options.
%   hdr = read_header(cfg.software, 'similar_file.img')
%
%   % update infos and write
%   hdr.fname = 'test.img';
%   hdr.descrip = 'This image contains important information';
%   write_image(cfg.software, hdr, volume);

check_software(software);
fname = [mfilename '_' lower(software)];
varargout{1} = feval(fname,varargin{:});