function main(nii)
% Print some useful information abnii an nii image
% USAGE: (nii) 1nii = 1 volume, not 4D

outname = nii;

hdr_out = spm_vol(outname);
type_out = spm_type(hdr_out.dt(1));
values_out = spm_read_vols(hdr_out);
n_out = length(find(values_out ~= 0)); % how many non-zero voxels, ie the masked voxels of the ROI
unique_values_out = unique(spm_read_vols(hdr_out));
dim_out = hdr_out.dim;
description_out = hdr_out.descrip;

fprintf('Data type: %s\n',type_out);
    fprintf('\t(note: UINT allows only positive values and 0;\n');
    fprintf('\tif negative included, select INT;\n');
    fprintf('\tsingle=float32, double=float64 also allow negative values)\n');
fprintf('Unique values: %s\n',mat2str(unique_values_out));
fprintf('Non-zero voxels #: %d\n', n_out);
fprintf('Dimension: %s\n',mat2str(dim_out));
fprintf('Description: %s\n',description_out);

end % end func