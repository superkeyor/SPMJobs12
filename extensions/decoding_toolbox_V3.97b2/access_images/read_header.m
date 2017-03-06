function varargout = read_header(software,filename,varargin)
% function varargout = read_header(software,filename,varargin)
%   IN
%     software: String with software to read header in cfg.software (e.g. 'SPM8')
%     filename: name of volume (full path , 1 x n string)
%     varargin: Any additional things that should be passed to
%         read_header
%   OUT
%     output: header of volume so that read_image() can read the volume
%         The format of the header should be SPM style.
%
% EXAMPLE 
% to read the files 'test.img' and 'test.hdr':
%
%   cfg = decoding_defaults;
%   hdr = read_header(cfg.software, 'test.img');
%   vol = read_image(cfg.software, hdr);

% History:
% 2017-02-05: replaced strsplit with regexp for downward compatibility

%           TODO: Add which header-fields are important, how they are built
%                   and what they mean


if ndims(filename) ~= 2 || ~any(size(filename)==1) %#ok<ISMAT>
    error('read_header only works when passing individual file names.')
end

filename = regexp(filename,',','split');
filename = filename{1}; % remove everything after a potential comma (we read all headers)
filename = strtrim(filename); % remove trailing whitespaces

if ~exist(filename, 'file')
    error('File %s does not exist', filename)
end
check_software(software);
fname = [mfilename '_' lower(software)];
varargout{1} = feval(fname,filename,varargin{:});