% bspmview, type 'help bspmview' to see help

function varargout = main(varargin)
    % ez.clean();
    if isempty(which('bspmview'))
        extsPath = ez.joinpath(ez.parentdir(ez.parentdir(ez.csd())), 'extensions');
        thePath = ez.lsd(extsPath,'bspmview');
        thePath = ez.joinpath(extsPath,thePath{1});
        addpath(thePath,'-end');
    end
    [varargout{1:nargout}] = bspmview(varargin{:}); 
end