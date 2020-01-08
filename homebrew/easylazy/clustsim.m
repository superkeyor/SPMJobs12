function varargout=main(seclvlPath,mode)
%DESCRIPTION:
%    3dFWHMx + 3dClustSim
%
% USAGE:
%    (seclvlPath)
%
% INPUT:
%     seclvlPath: default={pwd}, cell str of paths to second level results folder (containing mask.nii, ResMS.nii, Res_0001.nii)
%                 or, a single path 'path/to/sth' (internally convert to {'path/to/sth'})
%     mode: default=0, 0=run & read or read, 1=only try to read, never run, 2=force to run & read
%           by read, I mean read 3dClustSim.NN2_2sided.1D
%
% OUTPUT:
%     put generated files in auto-created folder clustsim
%     printout results NN2_2-sided
%     if NN2_2-sided result exists in the folder, only printout
%
% NOTE:
%     According to my own test, the square root approach seems to give bigger
%     smoothness compared with run 3dFWHMx on each residual file and simply
%     take the average across all of your subjects (this requires SPM > Stats
%     > Model Estimation > Write residuals > Yes). The averaged values got
%     this way are very close to those from values if the analysis was done in
%     AFNI directly. This function first try invidual approach if Res_000x.nii
%     exists, otherwise fall back to square root approach.
%     
%     Also according to Bob https://afni.nimh.nih.gov/afni/community/board/read.php?1,152281,152319#msg-152319
%     If you analyze the statistics sub-brick(s), the ACF will be biased by the presence -- you hope! --
%     of activations. One option would be to compute the 3 ACF parameters for each subject's residuals
%     (errts) time series dataset, then take the mean or median of each of these, and use those 3 values
%     in the 3dClustSim -acf run.
    k=NaN;
    try, if strcmp(seclvlPath,'-h'), ez.showhelp(); return; end; end
    ez.setdefault({'seclvlPath', {pwd}
                   'mode', 0});
    if ~iscell(seclvlPath), seclvlPath = {seclvlPath}; end
    oldpwd = pwd;
    for i = 1:numel(seclvlPath)
        if mode~=1, ez.print(sprintf('\nProcessing %d of %d ...', i, numel(seclvlPath))); end
        residual = ez.jp(seclvlPath{i},'ResMS.nii');
        if ~ez.exists(residual), continue; end
        ez.cd(ez.splitpath(ez.abspath(residual))); 
        if mode==2, ez.rm('clustsim'); end
        if mode~=1, ez.mkdir('clustsim',0); end
        if exist('clustsim','dir'), ez.cd('clustsim'); end

        % spm by default uses 18 (edge) for clustering, see help spm_clusters and help spm_bwlabel
        % this corresponding to NN2 in afni
        if (~ez.exists('3dClustSim.NN2_2sided.1D')) && mode~=1
            if ~ez.exists('../Res_0001.nii')
                % square root approach. the values might be larger 
                cmd = '3dcalc -a ../ResMS.nii -expr ''sqrt(a)'' -prefix sqrt_ResMS.nii';
                ez.execute(cmd,0);
                % or 3dFWHMx -mask ../mask.nii -input sqrt_ResMS.nii -overwrite
                % but it will affect the parsing of ez.execute() echo result 
                cmd = '3dFWHMx -mask ../mask.nii -input sqrt_ResMS.nii -acf NULL';
                [status,result] = ez.execute(cmd,0);
                result = strsplit(result,'\n');
                result = result{end-1};
                result = ez.trim(result); result = strsplit(result,' ');
                ez.print(sprintf('3dFWHMx (sqrt root): %s',strjoin(result)));
                cmd = sprintf('3dClustSim -mask ../mask.nii  -acf %s %s %s -iter 10000 -nodec -prefix 3dClustSim',result{1},result{2},result{3});
                ez.execute(cmd);
            else
                % single subject approach: SPM > Stats > Model Estimation > Write residuals > Yes
                resniis = ez.ls('../', 'Res_\d{4}.nii');
                as=[];bs=[];cs=[];FWHMxs=[];
                for j = 1:numel(resniis)
                    resnii = resniis{j};
                    cmd = sprintf('3dFWHMx -mask ../mask.nii -input %s -acf NULL', resnii);
                    [status,result] = ez.execute(cmd,0);
                    result = strsplit(result,'\n');
                    result = result{end-1};
                    result = ez.trim(result); result = strsplit(result,' ');
                    as=[as, str2num(result{1})]; bs=[bs, str2num(result{2})]; cs=[cs, str2num(result{3})]; FWHMxs=[FWHMxs, str2num(result{4})];
                end
                % nanmedian is a bit smaller than nanmean in some cases, so use median
                ez.print(sprintf('3dFWHMx (averaged): %s',mat2str([nanmedian(as), nanmedian(bs), nanmedian(cs), nanmedian(FWHMxs)])));
                T = [nanmedian(as), nanmedian(bs), nanmedian(cs), nanmedian(FWHMxs); NaN, NaN, NaN, NaN; as', bs', cs', FWHMxs']; 
                T = array2table(T, 'VariableNames', {'a', 'b', 'c', 'FWHMx'});
                ez.savex(T,'FWHMx.xlsx');
                cmd = sprintf('3dClustSim -mask ../mask.nii  -acf %f %f %f -iter 10000 -nodec -prefix 3dClustSim',nanmedian(as), nanmedian(bs), nanmedian(cs));
                ez.execute(cmd);
            end 
        end % end 3dClustSim
        
        if ez.exists('3dClustSim.NN2_2sided.1D')
            lines = ez.readlines('3dClustSim.NN2_2sided.1D');
            line = lines{end-3}; line = ez.trim(line); line = strsplit(line,' ');
            ez.pprint(sprintf('0.05 <-- pthr = %s, k = %s', regexprep(line{1},'0*$',''), line{3}));
            k=line{3};
        end 

        ez.cd(oldpwd);
    end % end for
    if mode~=1, ez.print('Done!'); end
    if nargout>0
        varargout{1} = k;
    end
end