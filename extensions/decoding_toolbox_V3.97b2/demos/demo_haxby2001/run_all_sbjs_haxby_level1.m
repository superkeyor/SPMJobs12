% run all level1 runwise all classes

% add path to this script
addpath('/home/kai/haxby01_scripts_etc/scripts');
% add path to spm
addpath('/analysis/kai/spm/spm12b');
spm fmri
%%
runjob = 1
%%
for sbj = 1:6
    clear matlabbatch
    
    % get design
    matlabbatch = level1_ruwise_all_classes(sbj, 0);
    
    % estimate
    matlabbatch{2}.spm.stats.fmri_est.spmmat = {fullfile(matlabbatch{1}.spm.stats.fmri_spec.dir{1}, 'SPM.mat')};
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    
    % run both
    if runjob
        % go to directory of that subject
        cd(matlabbatch{1}.spm.stats.fmri_spec.dir{1})
        spm_jobman('run', matlabbatch)
    end
end