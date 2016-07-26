function info = main(dcm)
% Print some useful information about a dicom file, show the dcm file
% USAGE: (dcm) 1dcm = 1 slice
% requires image processing toolbox

info = dicominfo(dcm);
Y = dicomread(info);
figure;imshow(Y);
% imcontrast;

end % end func