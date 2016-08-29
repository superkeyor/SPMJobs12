function outname = main(xyz,radius,labels,verbose)
% Input:
%       xyz = coordinates in mm (rows are ROIs) eg, [2,-3,4;-20,30,40]
%       radius = 'Sphere' radius of ROI, a single value for all xyz
%       labels = corresponds to each ROI nx1 {'leftROI';'rightROI'}
%                default ''
%       verbose = 0/1, if true, print out roi info and display roi, default true
% Output:
%       ROI_Sphere8_2_-3_4_label.nii/.mat or ROI_Sphere8_2-_3_4.nii/.mat in the pwd
%       the full path to the (last) generated ROI mat file
% Note:
%       Uses marsbar functions to generate .mat and .nii ROI
%       If marsbar path not in searchpath, auto add them internally first.

% modified from http://akiraoconnor.org/2010/08/18/marsbar-script-save-spheres-as-both-img-and-mat-files/

if isempty(which('marsbar'))
    ez.print('addpath marsbar...')
    extsPath = ez.joinpath(ez.parentdir(ez.parentdir(ez.csd())), 'extensions');
    thePath = ez.lsd(extsPath,'^marsbar');
    thePath = ez.joinpath(extsPath,thePath{1});
    addpath(thePath);
end

if nargin<3, labels = repmat({''},size(xyz,1),1); end
if ischar(labels), labels = cellstr(labels); end
if nargin<4, verbose = 1; end

for i = 1:size(xyz,1)
% sphere_center is specified as the centre of the sphere in mm in MNI space
sphere_center = xyz(i,1:3);
sphere_radius = radius;
sphere_roi = maroi_sphere(struct('centre', sphere_center, ...
    'radius', sphere_radius));
if isempty(labels{i})
    sphere_label = ['ROI_Sphere' num2str(sphere_radius) '_' num2str(round(xyz(i,1))) '_' num2str(round(xyz(i,2))) '_' num2str(round(xyz(i,3)))];
else
    sphere_label = ['ROI_Sphere' num2str(sphere_radius) '_' num2str(round(xyz(i,1))) '_' num2str(round(xyz(i,2))) '_' num2str(round(xyz(i,3))) '_' labels{i}];
end
sphere_roi = label(sphere_roi, sphere_label);

% save ROI as MarsBaR ROI file
saveroi(sphere_roi, fullfile(sprintf('%s.mat', ...
    sphere_label)));
% Save as image
save_as_image(sphere_roi, fullfile(sprintf('%s.nii', ...
    sphere_label)));

fprintf('ROI file created: %s\n\n', sphere_label);

if verbose
% output some useful info of the generated image
outname = fullfile(sprintf('%s.nii', ...
    sphere_label));
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

outname = fullfile(sprintf('%s.mat', ...
    sphere_label));
spmpath = fileparts(which('spm'));
mars_display_roi('display',outname,fullfile(spmpath,'canonical','avg152T1.nii'));

end % end if
outname = fullfile(sprintf('%s.mat', ...
    sphere_label));
ez.pprint('========================================================================\n');
end % end for

end % end function