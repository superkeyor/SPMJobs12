function convert_dicom(path0,dirfilter,filefilter);
% CONVERT_DICOM wrap-around dicom2nii (http://www.sph.sc.edu/comd/rorden/mricron/dcm2nii.html)
%
% convert_dicom(PATHNAME);
% Recursive search through directories starting from the directory PATHNAME looking for files 
% of the form ???????? (with numeric characters) and invoquing dicom2nii to convert the files 
% found to nifti format
%
% convert_dicom(pathname,dirfilter,filefilter);
% Uses file filter DIRFILTER to initially filter files (default '*.')
% and the filter FILEFILTER to determine a possible file match (default inline('length(x)==8&&all(x>=''0''&x<=''9'')') )
%

if nargin<2, dirfilter='*.'; end
if nargin<3, filefilter=inline('length(x)==8&&all(x>=''0''&x<=''9'')'); end

dircallback=@mcallback;
dirs(path0,dirfilter,filefilter,dircallback,[]);

function mcallback(pathname);
txt=['dcm2nii -a y -d n -g n -i n -e n ',pathname];
disp(txt);
ok=dos(txt);



