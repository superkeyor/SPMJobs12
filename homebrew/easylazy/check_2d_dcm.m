function [info, Y] = main(dcm)
% [info, Y] = main(dcm)    
% Print some useful information about a dicom file, show the dcm file, return Y matrix representing the dicom
% 1dcm = 1 slice
% requires image processing toolbox

info = dicominfo(dcm);
Y = dicomread(info);
figure;imshow(Y,[]);
% imcontrast;

end % end func