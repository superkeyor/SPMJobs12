function result = main(crl,verbose,folder)
% Input:
%       crl: {coordinates1, radius1, label1;
%             coordinates2, radius2, label2}
%            xyz = coordinates in mm (rows are ROIs) eg, [2,-3,4]
%            radius = 'sphere' radius of ROI in mm (>0)
%            label = corresponds to each ROI 'leftROI'
%       verbose = 0/1, if true, print out roi info and display roi, default true
%       folder, path to folder where ROI files will be saved, default pwd
% Output:
%       MNI_label_5mmsphere_x_y_z_roi.mat (nii export could be tricky, because of voxel size)
%             Base space (default) is MNI: 2x2x2
%             From image: choose an image to copy over the info (size, dim)
%             ROI native: from ROI file info itself
%       the full path to the generated ROI mat file(s), if more than one file, a cell; otherwise a str
% Note:
%       Uses marsbar functions to generate .mat ROI
%             nii: save nii first to print some info, then delete the nii to avoid confusion
%       If marsbar path not in searchpath, auto add them internally first.

% modified from http://akiraoconnor.org/2010/08/18/marsbar-script-save-spheres-as-both-img-and-mat-files/

if isempty(which('marsbar'))
    ez.print('addpath marsbar...')
    extsPath = ez.joinpath(ez.parentdir(ez.parentdir(ez.csd())), 'extensions');
    thePath = ez.lsd(extsPath,'^marsbar');
    thePath = ez.joinpath(extsPath,thePath{1});
    addpath(thePath,'-end');
end

xyz = cell2mat(crl(:,1));
radius = cell2mat(crl(:,2));
labels = crl(:,3);

if ischar(labels), labels = cellstr(labels); end
if nargin<2, verbose = 1; end
if nargin<3, folder = pwd; else ez.mkdir(folder); end

result = cell(size(xyz,1),1);

for i = 1:size(xyz,1)
% sphere_center is specified as the centre of the sphere in mm in MNI space
sphere_center = xyz(i,1:3);
sphere_radius = radius(i);
sphere_roi = maroi_sphere(struct('centre', sphere_center, 'radius', sphere_radius));
sphere_label = ['MNI_' labels{i}, '_', num2str(sphere_radius) 'mmsphere'  '_' num2str(round(xyz(i,1))) '_' num2str(round(xyz(i,2))) '_' num2str(round(xyz(i,3))), '_roi'];
sphere_roi = label(sphere_roi, sphere_label);

% save ROI as MarsBaR ROI file
saveroi(sphere_roi, fullfile(folder,sprintf('%s.mat', sphere_label)));
% Save as image--tricky, see function help at the top of this file
% save nii first to print some info, then delete the nii to avoid confusion
save_as_image(sphere_roi, fullfile(folder,sprintf('%s.nii', sphere_label)));

fprintf('ROI file created: %s\n\n', sphere_label);

if verbose
% output some useful info of the generated image
outname = fullfile(folder,sprintf('%s.nii', sphere_label));
hdr_out = spm_vol(outname);
type_out = spm_type(hdr_out.dt(1));
values_out = spm_read_vols(hdr_out);
n_out = length(find(values_out ~= 0)); % how many non-zero voxels, ie the masked voxels of the ROI
unique_values_out = unique(spm_read_vols(hdr_out));
dim_out = hdr_out.dim;
Z = spm_imatrix(hdr_out.mat);
voxsize = Z(7:9);
description_out = hdr_out.descrip;

fprintf('note: UINT allows only positive values and 0;\n');
fprintf('if negative included, select INT;\n');
fprintf('single=float32, double=float64 also allow negative values\n\n');

fprintf('Data type: %s\n',type_out);
if length(unique_values_out) < 10
    fprintf('Unique values: %s\n',mat2str(unique_values_out));
else
    fprintf('Unique values: %d in total, showing first 10... %s\n', length(unique_values_out), mat2str(unique_values_out(1:10)))
end

fprintf('Min value: %s\n',num2str(min(unique_values_out)));
fprintf('Max value: %s\n',num2str(max(unique_values_out)));

fprintf('Non-zero voxels #: %d\n', n_out);
fprintf('Dimension: %s\n',mat2str(dim_out));
fprintf('Voxel size: %s\n',mat2str(abs(voxsize)));
fprintf('Description: %s\n',description_out);
end % end if

% remove nii
ez.rm(outname);

result{i,1} = fullfile(folder,sprintf('%s.mat', sphere_label));
ez.pprint('========================================================================\n');
end % end for

if verbose,
    spmpath = fileparts(which('spm'));
    mars_display_roi('display',char(result),fullfile(spmpath,'canonical','avg152T1.nii'));
end % end if

% output a text list of generated rois
ROIs = cellstr(spm_select('List',folder,['^MNI_.*mmsphere_.*_roi.mat']));
ROIs = strrep(ROIs,'MNI_','');
ROIs = regexprep(ROIs,'_\d{1,2}mmsphere_-?\d{1,2}_-?\d{1,2}_-?\d{1,2}_roi\.mat$','');
ez.cell2csv(fullfile(folder,'ALLROINAMES.txt'),ROIs);

if length(result)==1, result=result{1}; end
end % end function