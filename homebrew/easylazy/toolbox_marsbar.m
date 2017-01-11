function varargout = main(varargin)
    % add extensions to path
    if (isempty(which('marsbar'))||isempty(which('spm_get')))
        ez.print('addpath marsbar...')
        extsPath = ez.joinpath(ez.parentdir(ez.parentdir(ez.csd())), 'extensions');
        thePath = ez.lsd(extsPath,'^marsbar');
        thePath = ez.joinpath(extsPath,thePath{1});
        addpath(thePath,'-end');
        % additional path that would be added by marsbar
        addpath(ez.joinpath(thePath,'spm5'),'-end');
    end
    % addpath(genpath(thePath));
    % addpath(genpath_exclude(thePath,{'^spm2$','^spm5$','^spm99$', '^spm_lite$'})); % avoid weird functions from marsbar/spm folders, wfu
    [varargout{1:nargout}] = marsbar(varargin{:}); 
end % end function