function varargout = main(varargin)
    % add extensions to path
    if isempty(which('BrikLoad'))  % a func randomly selected from afni_matlab
        ez.print('addpath afni_matlab...')
        extsPath = ez.joinpath(ez.parentdir(ez.parentdir(ez.csd())), 'extensions');
        thePath = ez.lsd(extsPath,'^afni_matlab');
        thePath = ez.joinpath(extsPath,thePath{1});
        addpath(thePath,'-end');
    end
end % end function