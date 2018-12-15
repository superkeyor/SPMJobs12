function main(nii)
% Print some useful information about an nii image and display
% USAGE: (nii) 1nii = 1 volume, not 4D

outname = nii;

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
fprintf('Dimension (product contains voxels outside brain): %s\n',mat2str(dim_out));
fprintf('Voxel size: %s\n',mat2str(abs(voxsize)));
fprintf('Description: %s\n',description_out);

if iscell(outname), outname = char(outname); end
spm_image('Display', outname); 

ez.pprint('========================================================================\n');
end % end func