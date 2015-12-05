
path0='f:\ydrive\data\fmri\dost\';
convert_dicom(path0);

path1='c:\zdrive\mit\susan\connectivity\data\dost\';
dos(['xcopy ',path0,'*.nii ',path1,' /v /s']);
