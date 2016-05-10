function varargout = main(varargin)
    % add extensions to path
    if isempty(which('wfu_pickatlas'))
        extsPath = ez.joinpath(ez.parentdir(ez.parentdir(ez.csd())), 'extensions');
        thePath = ez.lsd(extsPath,'WFU_PickAtlas');
        addpath(ez.joinpath(extsPath,thePath{1},'wfu_pickatlas'));
        addpath(ez.joinpath(extsPath,thePath{1},'wfu_results'));
        addpath(ez.joinpath(extsPath,thePath{1},'wfu_tbx_common'));
    end
    % addpath(genpath(thePath));
    % addpath(genpath_exclude(thePath,{'^spm2$','^spm5$','^spm99$', '^spm_lite$'})); % avoid weird functions from marsbar/spm folders, wfu
    [varargout{1:nargout}] = wfu_pickatlas(varargin{:}); 
end % end function