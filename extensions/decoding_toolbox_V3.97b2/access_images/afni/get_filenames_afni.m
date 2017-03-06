function varargout = get_filenames_afni(varargin)

%   get_filenames:
%       inputs: file path (1 x n string), possible filenames with wildcards (e.g. *.BRIK or mystudy*.BRIK)
%       output: filenames as n x m char array (n = number of files)

if nargin >= 2
    if strfind(varargin{2},'REGEXP:') == 1
        fname_regexp = varargin{2}(8:end);
    else
        fname_regexp = wildcard2regexp(varargin{2});
    end
else
    fname_regexp = '.*';
end

h = dir(varargin{1});
% exclude directories
h([h.isdir]) = [];
n_files = length(h);
fnames = cell(n_files,1);
keepind = false(n_files,1);
for i_file = 1:n_files
    keepind(i_file) = ~isempty(regexp(h(i_file).name,fname_regexp, 'once'));
    if keepind(i_file)
        fnames{i_file} = fullfile(varargin{1},h(i_file).name);
    end
end

varargout = {char(fnames(keepind))};