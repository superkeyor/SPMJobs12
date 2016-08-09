function varargout = main(varargin)
    % add extensions to path
    % requires marsbar
    if isempty(which('adjacency_plot_und'))  % a func randomly selected from BCT
        ez.print('addpath brain connectivity toolbox...')
        extsPath = ez.joinpath(ez.parentdir(ez.parentdir(ez.csd())), 'extensions');
        thePath = ez.lsd(extsPath,'^BCT');
        thePath = ez.joinpath(extsPath,thePath{1});
        addpath(thePath);
    end
    
    if isempty(which('marsbar'))
        ez.print('addpath marsbar...')
        extsPath = ez.joinpath(ez.parentdir(ez.parentdir(ez.csd())), 'extensions');
        thePath = ez.lsd(extsPath,'^marsbar');
        thePath = ez.joinpath(extsPath,thePath{1});
        addpath(thePath);
    end

    if isempty(which('BASCO'))
        extsPath = ez.joinpath(ez.parentdir(ez.parentdir(ez.csd())), 'extensions');
        thePath = ez.lsd(extsPath,'^BASCO');
        thePath = ez.joinpath(extsPath,thePath{1});
        addpath(thePath);
    end
    % addpath(genpath(thePath));
    % addpath(genpath_exclude(thePath,{'^spm2$','^spm5$','^spm99$', '^spm_lite$'})); % avoid weird functions from marsbar/spm folders, wfu
    [varargout{1:nargout}] = BASCO(varargin{:}); 
end % end function