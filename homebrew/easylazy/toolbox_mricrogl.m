% launch mricron

function varargout = main(varargin)
    if isempty(which('mricrogldummy'))
        extsPath = ez.joinpath(ez.parentdir(ez.parentdir(ez.csd())), 'extensions');
        thePath = ez.lsd(extsPath,'^MRIcroGL');
        thePath = ez.joinpath(extsPath,thePath{1});
        addpath(thePath);
    end
    !open -n -a MRIcroGL
end