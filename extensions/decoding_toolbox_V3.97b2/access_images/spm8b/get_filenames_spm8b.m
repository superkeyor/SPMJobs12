function varargout = get_filenames_spm8b(varargin)

%   get_filenames:
%       inputs: file path (1 x n string), possible filenames with wildcards (e.g. *.img or rf*.img)
%       output: filenames as n x m char array (n = number of files)

if nargin >= 2 && strncmp(varargin{2},'REGEXP:',7)
    fname_regexp = varargin{2}(8:end);
else
    fname_regexp = wildcard2regexp(varargin{2});
end

varargout{1} = char(spm_select('Fplist',varargin{1},fname_regexp));