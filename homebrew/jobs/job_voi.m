% (conditions, ROIs, together);
% 
% author = jerryzhujian9@gmail.com
% date: Fri, May 13 2016, 04:47:12 PM EDT(-0400)

ez.clean();

conditions = {'comp_e','nc_e','comp_mce','nc_mce'};
% conditions = {'comp_e'};
ROIs = {'APFC_L','APFC_R','DLPFC_L','DLPFC_R','DStriatum_L','DStriatum_R'};
conditionsPath = ez.pwd;
ROIPath = ez.whichdir('roisdummy.m');
together = 1;

spm('fmri');

startTime = ez.moment();
cd(conditionsPath);
for n = 1:ez.len(conditions)
    condition = conditions{n};
    conditionPath = ez.joinpath(conditionsPath,condition);

    for m = 1:ez.len(ROIs)
        ROI = ROIs{m};
        load('mod_voi.mat');

        % loop contrasts
        load(ez.joinpath(conditionPath,'SPM.mat'));
        for p = 1:ez.len(SPM.xCon)
            matlabbatch{1}.spm.util.voi.spmmat = {ez.joinpath(conditionPath,'SPM.mat')};
            matlabbatch{1}.spm.util.voi.name = SPM.xCon(p).name;
            matlabbatch{1}.spm.util.voi.roi{1}.spm.contrast = p;
            matlabbatch{1}.spm.util.voi.roi{2}.mask.image = {ez.joinpath(ROIPath,[ROI,'.nii,1'])};
    
            cd(conditionPath);
            save(['voi_' SPM.xCon(p).name '__'  ROI '_job.mat'], 'matlabbatch');

            ez.rm(['voi_' SPM.xCon(p).name '__'  ROI '.txt']);
            diary(['voi_' SPM.xCon(p).name '__'  ROI '.txt']);
            ez.print(['Processing ' SPM.xCon(p).name '__'  ROI ' ...']);
            if together
                try
                    spm_jobman('run',matlabbatch);
                    drawnow; % let the figure finish drawing and get ready before continuing the script
                    spm_figure('GetWin','Graphics');
                    ez.export(['voi_' SPM.xCon(p).name '__'  ROI '.pdf']);
                    ez.rn(['VOI_' SPM.xCon(p).name '.mat'], ['voi_' SPM.xCon(p).name '__'  ROI '.mat']);
                catch
                    ez.pprint(['No value extracted from ' SPM.xCon(p).name '__'  ROI],'red');
                end
            end
            diary off;
        end
        clear matlabbatch;
    end

    ez.pprint('****************************************'); % pretty colorful print
end
cd(conditionsPath);
ez.pprint('Done!');
finishTime = ez.moment();
%------------- END OF CODE --------------