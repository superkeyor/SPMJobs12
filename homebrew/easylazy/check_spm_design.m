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
            spm_DesRep;
            return;
        end
    else
        if strfind(arg,'.mat')
            load(arg);
        end
    end
    spm_DesRep('DesRepUI',SPM);
    filenames = reshape(cellstr(SPM.xY.P),size(SPM.xY.VY));
    spm_DesRep('DesMtx',SPM.xX,filenames,SPM.xsDes);
end




