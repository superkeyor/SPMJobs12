function varargout = main(varargin)
    % add extensions to path
    extsPath = ez.joinpath(ez.parentdir(ez.parentdir(ez.csd())), 'extensions');
    thePath = ez.lsd(extsPath,'conn');
    thePath = ez.joinpath(extsPath,thePath{1});
    % avoid weird functions from marsbar/spm folders, wfu
    addpath(genpath_exclude(thePath,{'^spm2$','^spm5$','^spm99$', '^spm_lite$'}));
    [varargout{1:nargout}] = conn(varargin{:}); 
end % end function