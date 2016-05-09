function main(nii)
% Print some useful information abnii an nii image
% USAGE: (nii) 1nii = 1 volume, not 4D

hdr_nii = spm_vol(nii);
type_nii = spm_type(hdr_nii.dt(1));
values_nii = unique(spm_read_vols(hdr_nii));
dim_nii = hdr_nii.dim;
description_nii = hdr_nii.descrip;

fprintf('Input image:\n');
fprintf('Data type: %s\n',type_nii);
    fprintf('\t(note: UINT allows only positive values and 0;\n');
    fprintf('\tif negative included, select INT;\n');
    fprintf('\tsingle=float32, double=float64 also allow negative values)\n');
fprintf('Unique values: %s\n',mat2str(values_nii));
fprintf('Dimension: %s\n',mat2str(dim_nii));
fprintf('Description: %s\n',description_nii);

end % end func