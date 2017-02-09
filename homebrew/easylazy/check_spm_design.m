function varargout = main(arg)
    % % check design matrix
    % SPM:
    % 1) main() search base workspace for SPM
    % 2) main() when search fails, pop up window to select
    % 3) main('path/to/SPM.mat')

    if nargin<1
        try
            SPM = evalin('base', 'SPM');
        catch
            [spmmatfile, sts] = spm_select(1,'^SPM\.mat$','Select SPM.mat');
            if ~sts, varargout = {[]}; return; end
            swd = spm_file(spmmatfile,'fpath');
            load(fullfile(swd,'SPM.mat'));
            SPM.swd = swd;
            ez.print(fullfile(swd,'SPM.mat'));
        end
    else
        if strfind(arg,'.mat')
            load(arg);
        end
    end
    spm_DesRep('DesRepUI',SPM);
    filenames = reshape(cellstr(SPM.xY.P),size(SPM.xY.VY));
    spm_DesRep('DesMtx',SPM.xX,filenames,SPM.xsDes);

    nregr = length(SPM.xX.name);
    for iregr = 1:nregr
        name = SPM.xX.name{iregr};
        ez.print(sprintf('%d\t{%s}',iregr,name));
    end
end




