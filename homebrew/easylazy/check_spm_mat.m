function varargout = main(arg,showMatrix)
    % % check design matrix
    % SPM:
    % 1) main() search base workspace for SPM
    % 2) main() when search fails, pop up window to select
    % 3) main('path/to/SPM.mat')
    % 
    % showMatrix: 0(default)/1, show design matrix

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

    if nargin<2, showMatrix=false; end
    if showMatrix
    spm_DesRep('DesRepUI',SPM);
    filenames = reshape(cellstr(SPM.xY.P),size(SPM.xY.VY));
    spm_DesRep('DesMtx',SPM.xX,filenames,SPM.xsDes);
    end

    ez.print(sprintf('Regressors:'));
    nregr = length(SPM.xX.name);
    for iregr = 1:nregr
        name = SPM.xX.name{iregr};
        ez.print(sprintf('%d\t{%s}',iregr,name));
    end

    ez.print(sprintf('\nContrasts:'));
    ncon = length(SPM.xCon);
    for icon = 1:ncon
        name = SPM.xCon(icon).name;
        stat = SPM.xCon(icon).STAT;
        con = mat2str(SPM.xCon(icon).c);
        ez.print(sprintf('%d\t{%s}\t%s\t\t\t\t\t%s',icon,stat,name,con));
    end

    ez.print(sprintf('\nImages#:'));
    ez.print(sprintf('%d',SPM.nscan));
end




