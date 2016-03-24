% Find anatomical location of a list of mni coordinates
% example: 
% ([20 6 10; 30 9 12])
% ([20 6 10])
%  [20 6 10]
% returns nothing
% also: check out Neurosynth (http://neurosynth.org)

% wrapper of http://www.alivelearn.net/?p=1456 

function main(varargin)
    % if  [20 6 10]
    if iscellstr(varargin); varargin = {str2num(varargin{:})}; end;
    
    % [oneline, cellarray]=cuixuFindStructure([20 6 10; 30 9 12])
    % [oneline, cellarray]=cuixuFindStructure([20 6 10])
    oneline = cuixuFindStructure(varargin{:});
    
    for i = 1:length(oneline)
        disp(' ----------------------------');
        % varargin{1} is the passed matrix
        disp(varargin{1}(i,:));
        disp(oneline{i});
    end
    
end