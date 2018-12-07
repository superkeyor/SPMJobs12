function result = main(img)
% img: hdr, or nii file 
% returns a matrix representing numbers stored in the image
% calls SPM functions
% differnt from the result with nii_tool('img',file)--do not know why

result = spm_read_vols(spm_vol(img));

end % end func