function main(ResMSPath)
%DESCRIPTION:
%    3dFWHMx + 3dClustSim
%
% USAGE:
%    (ResMSPath)
%
% INPUT:
%     ResMSPath: default={'ResMS.nii'}, cell str of paths
%
% OUTPUT:
%     put generated files in auto-created folder clustsim
%     printout results NN3_2-sided
%     if NN3_2-sided result exists in the folder, only printout
    try, if strcmp(ResMSPath,'-h'), ez.showhelp(); return; end; end
    ez.setdefault({'ResMSPath', {'ResMS.nii'}});
    oldpwd = pwd;
    for i = 1:numel(ResMSPath)
        residual = ResMSPath{i};
        ez.cd(ez.splitpath(ez.abspath(residual))); 
        ez.mkdir('clustsim',0);
        ez.cd('clustsim');

        if ~ez.exists('3dClustSim.NN3_2sided.1D')
            cmd = '3dcalc -a ../ResMS.nii -expr ''sqrt(a)'' -prefix sqrt_ResMS.nii';
            ez.execute(cmd,0);
            cmd = '3dFWHMx -mask ../mask.nii -input sqrt_ResMS.nii';
            [status,result] = ez.execute(cmd,0);
            result = strsplit(result,'\n');
            result = result{7};
            result = ez.trim(result); result = strsplit(result,' ');
            ez.print(sprintf('3dFWHMx: %s',strjoin(result)));
            cmd = sprintf('3dClustSim -mask ../mask.nii  -acf %s %s %s -iter 10000 -nodec -prefix 3dClustSim',result{1},result{2},result{3});
            ez.execute(cmd,0);
        end 
        
        lines = ez.readlines('3dClustSim.NN3_2sided.1D');
        line = lines{end-3}; line = ez.trim(line); line = strsplit(line,' ');
        ez.pprint(sprintf('0.05 <-- pthr = %s, k = %s', regexprep(line{1},'0*$',''), line{3}));
    end
    ez.cd(oldpwd);
end