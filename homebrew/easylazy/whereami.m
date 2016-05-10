% Find anatomical location of a list of mni coordinates
% example: 
% ([20 6 10; 30 9 12])
% ([20 6 10])
% command line: [20 6 10]
% returns nothing

% also: check out Neurosynth (http://neurosynth.org)
% wrapper of http://www.alivelearn.net/?p=1456 

function main(varargin)
    % if  [20 6 10]
    if iscellstr(varargin); varargin = {str2num(varargin{:})}; end;
    
    % [oneline, cellarray]=cuixuFindStructure([20 6 10; 30 9 12])
    % [oneline, cellarray]=cuixuFindStructure([20 6 10])
    if isempty(which('cuixuFindStructure'))
        extsPath = ez.joinpath(ez.parentdir(ez.parentdir(ez.csd())), 'extensions');
        thePath = ez.lsd(extsPath,'^xjview');
        thePath = ez.joinpath(extsPath,thePath{1});
        addpath(thePath);
    end
    oneline = cuixuFindStructure(varargin{:});
    
    for i = 1:length(oneline)
        disp(' ----------------------------');
        % varargin{1} is the passed matrix
        disp(varargin{1}(i,:));
        disp(oneline{i});

        url = sprintf('http://neurosynth.org/locations/%d_%d_%d/',varargin{1}(i,1),varargin{1}(i,2),varargin{1}(i,3));
        disp(sprintf('\n <a href="%s">%s</a>\n',url,url));
    end
    
end