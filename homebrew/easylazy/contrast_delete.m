function varargout = main(arg)
    % delete last contrast in SPM.mat and remove corresponding con_00xx and spmT/F_00xx files
    % arg: [optional] path to SPM.mat
    % returns nothing but permanently saves/changes SPM.mat on disk and in base workspace
    
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

    % last con
    ncon = length(SPM.xCon);
    % prepare
    swd = SPM.swd;
    conFile = ez.joinpath(swd, SPM.xCon(ncon).Vcon.fname);
    statFile = ez.joinpath(swd, SPM.xCon(ncon).Vspm.fname);
    name = SPM.xCon(ncon).name;
    stat = SPM.xCon(ncon).STAT;
    con = mat2str(SPM.xCon(ncon).c);

    % modify SPM.mat
    SPM.xCon(ncon) = [];
    assignin('base','SPM',SPM);
    save(ez.joinpath(swd,'SPM.mat'),'SPM');

    % delete files
    ez.rm(conFile);
    ez.rm(statFile);

    % done
    ez.print(sprintf('removed contrast %d\t{%s}\t%s\t\t\t\t\t%s',ncon,stat,name,con));
end




