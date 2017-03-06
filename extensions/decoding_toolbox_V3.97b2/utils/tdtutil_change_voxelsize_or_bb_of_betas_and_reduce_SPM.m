% this script changes the voxel size and keeps the bounding box of images
% (you can change the bounding box easily too).
%
% it creates all result files in a new directory
%
% this version is especially tailored if you like to reduce the file size
% of beta estimates from SPM and use it for TDT later.
%
% use tdtutil_change_voxelsize_or_bb if you want to change images without
% renaming the changed images and copying the SPM mat
%
% it also creates a small version of the SPM mat (if any exists), so that
% the TDT can work with it

%% Settings
target_resolution = [-2 2 2];
source_dir = 'C:\tdt\example_data\sub01_struct';
source_reference_image = fullfile(source_dir, 'sstruct01-14-001.img'); % where to get original voxelsize and BB from
source_files = spm_select('Fplist', source_dir, '[img|nii]$'); % change all images
target_dir = [source_dir sprintf('_%gx%gx%gmm', target_resolution)];
% s = mkdir(target_dir);

%% Load default image to get current voxelsize and BB, and change what you like

ref_hdr = spm_vol(source_reference_image);
[BB, def_vx] = spm_get_bbox(ref_hdr);
vx = target_resolution; % new voxel size
info_str = sprintf('CHANGED voxel size from %gx%gx%g to %gx%gx%g, KEEPING bounding bounding box as it was {%g %g %g;%g %g %g) in reference image %s',def_vx, vx, BB, source_reference_image);
display(info_str)

%% Step 1: change resolution
display('Step 1: change resolution (and maybe bounding box)')
% init spm
spm_jobman('initcfg')

clear matlabbatch
matlabbatch{1}.spm.util.defs.comp{1}.idbbvox.vox = vx;
matlabbatch{1}.spm.util.defs.comp{1}.idbbvox.bb = BB;
matlabbatch{1}.spm.util.defs.fnames = cellstr(source_files);
matlabbatch{1}.spm.util.defs.savedir.saveusr = {target_dir};
matlabbatch{1}.spm.util.defs.interp = 1; % 0: nearest neighbour, 1: Trilinear, i: i-th Degree B-spline

spm_jobman('run', matlabbatch)

%% Step 2: Remove initial w
display('Step 2: Remove w from all changed files')
cwd = pwd;
% go to directory to avoid having full path
cd(target_dir);

wfiles = dir('w*.*');
for w_ind = 1:length(wfiles)
    movefile(wfiles(w_ind).name, wfiles(w_ind).name(2:end));
end
% go back
cd(cwd);

%% Step 3: Add %% Add RESOLUTION_CHANGED.txt as marker and copy stripped
display('Step 3: Add %% Add RESOLUTION_CHANGED.txt as marker and copy stripped')
% version of SPM.mat (SPM_reduced.mat) which is enough to decode

f = fopen(fullfile(target_dir, 'RESOLUTION_CHANGED.txt'), 'w+');
fwrite(f, [info_str char(10)]);
fwrite(f, ['Sourcedir: ' source_dir char(10)]);
fwrite(f, ['Targetdir: ' target_dir char(10)]);
fwrite(f, datestr(now));
fclose(f);

try
    display('Trying to c copy a very small version of the original SPM mat to the target directory')
    org_SPM = load(fullfile(source_dir, 'SPM.mat'));
    reduce_SPM_filesize(org_SPM.SPM, fullfile(target_dir, 'reduced_SPM.mat'))
catch
    display('Could not reduce SPM.mat from source directory, maybe doesnt exist');
end
