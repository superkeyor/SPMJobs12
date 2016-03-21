% Find anatomical location of a list of mni coordinates
% example: 
% [oneline, cellarray]=mni([20 6 10; 30 9 12])
% [oneline, cellarray]=mni([20 6 10])
% also: check out Neurosynth (http://neurosynth.org)

% wrapper of http://www.alivelearn.net/?p=1456 

function varargout = main(varargin)
    [varargout{1:nargout}] = cuixuFindStructure(varargin{:}); 
end