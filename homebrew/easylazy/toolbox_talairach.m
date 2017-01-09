% bspmview, type 'help bspmview' to see help

function varargout = main(varargin)
    extsPath = ez.joinpath(ez.parentdir(ez.parentdir(ez.csd())), 'extensions');
    thePath = ez.lsd(extsPath,'Talairach');
    thePath = ez.joinpath(extsPath,thePath{1});
    cmd = sprintf(['java -jar %s &'],ez.joinpath(thePath,'talairach.jar'));
    [sts, res] = system(cmd);
end