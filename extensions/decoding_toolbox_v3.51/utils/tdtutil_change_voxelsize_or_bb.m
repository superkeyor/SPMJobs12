% this script changes the voxel size and keeps the bounding box of images
% (you can change the bounding box easily too)
%
% it creates all result files in a new directory
%
% this can be use for all images, including T1 etc.
%
% For the special case that you want to change the resolution of beta
% images in a SPM.mat directory, use the slightly more powerful
% tdtutil_change_voxelsize_or_bb_of_betas_and_reduce_SPM script

source_dir = 'C:\tdt\example_data\sub01_ROI';
imgs = dir(fullfile(source_dir, 'v1.img')); % take out loop below if all images have the same Bounding box and voxel size and uncomment spm_select

for im_ind = 1:length(imgs)
    
    curr_img = imgs(im_ind).name;
    
    %% Settings
    target_resolution = [2 2 3];
    source_reference_image = fullfile(source_dir, curr_img); % where to get original voxelsize and BB from
    source_files = source_reference_image; % use spm_select('Fplist', source_dir, '[img|nii]$'); % change all images
    target_dir = source_dir % [source_dir sprintf('_%gx%gx%gmm', target_resolution)];
    s = mkdir(target_dir);
    
    %% Load default image to get current voxelsize and BB, and change what you like
    
    ref_hdr = spm_vol(source_reference_image);
    [BB, def_vx] = spm_get_bbox(ref_hdr);
    vx = target_resolution; % new voxel size
    info_str = sprintf('CHANGED voxel size from %gx%gx%g to %gx%gx%g, KEEPING bounding bounding box as it was {%g %g %g;%g %g %g) in reference image %s', def_vx, vx, BB, source_reference_image);
    display(info_str)
    
    %% change resolution
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
    %% Step 2: Add %% Add RESOLUTION_CHANGED.txt as marker and copy stripped
    display('Step 2: Add %% Add RESOLUTION_CHANGED.txt as marker and copy stripped')
    % version of SPM.mat (SPM_reduced.mat) which is enough to decode
    
    f = fopen(fullfile(target_dir, ['w' curr_img 'RESOLUTION_CHANGED.txt']), 'w+');
    fwrite(f, [info_str char(10)]);
    fwrite(f, ['Sourcedir: ' source_dir char(10)]);
    fwrite(f, ['Targetdir: ' target_dir char(10)]);
    fwrite(f, datestr(now));
    fclose(f);
    
end