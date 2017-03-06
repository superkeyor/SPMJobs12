function varargout = get_filenames_spm2(varargin)

%   get_filenames:
%       inputs: file path (1 x n string), possible filenames with wildcards (e.g. *.img or rf*.img)
%       output: filenames as n x m char array (n = number of files)

if nargin >= 2 && strfind(varargin{2},'REGEXP:') == 1
    error('Input to file names to find specified as regular expression. SPM2 cannot deal with regular expressions.')
end

varargout{1} = spm_get('Files',varargin{1},varargin{2});