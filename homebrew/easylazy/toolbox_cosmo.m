function varargout = main(varargin)
    % add extensions to path
    if isempty(which('cosmo_set_path'))
        extsPath = ez.joinpath(ez.parentdir(ez.parentdir(ez.csd())), 'extensions');
        thePath = ez.lsd(extsPath,'^CoSMoMVPA');
        thePath = ez.joinpath(extsPath,thePath{1});

        theFile = ez.joinpath(thePath,'mvpa','cosmo_set_path.m');
        run(theFile);
        % addpath(thePath,'-end');
    end
    % [varargout{1:nargout}] = cosmo_wtf(varargin{:}); 

    ez.print('CoSMoMVPA path successfully added.');
    cfg = ez.joinpath(ez.parentdir(ez.whichdir('cosmo_set_path')),'examples','cosmo_wizard_set_config.m');
    ez.print('Run the following command (either one) to config input/output directory for tutorial data if needed:');
    ez.print(['run ' cfg]);
    ez.print('edit ~/.cosmomvpa.cfg');
end % end function