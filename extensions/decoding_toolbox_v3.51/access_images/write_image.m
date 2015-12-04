function varargout = write_image(software,varargin)

% function varargout = write_image(software,varargin)
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
% to write a volume to 'test.img' using a similar file to get a header
%
%   % create random data (for example only) and get cfg (if you dont have
%   % it yet)
%   volume = randn(64, 64, 32); 
%   cfg = decoding_defaults; % if not already there
%   
%   % get a header (the best way is to load it from a file that is similar
%   % to what you want to write, otherwise see "HELP SPM_VOL" for details)
%   % the similar file includes voxel size in standard space, alignment, 
%   % datatype, etc.
%   hdr = read_header(cfg.software, 'similar_file.img')
%
%   % update infos and write
%   hdr.fname = 'test.img';
%   hdr.dim = size(volume);
%   vol = read_image(cfg.software, hdr);

check_software(software);
fname = [mfilename '_' lower(software)];
varargout{1} = feval(fname,varargin{:});