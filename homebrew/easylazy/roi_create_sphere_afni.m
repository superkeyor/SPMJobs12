function result = main(mniCoordinate, radius, masterNiiPath)
% (masterNiiPath,radius,mniCoordinate)
% Description:
%       Uses afni 3dUndump to create roi
%       https://afni.nimh.nih.gov/pub/dist/doc/program_help/3dUndump.html
% Input:
%       mniCoordinate: [x, y, z], [1,2,3; 3,4,5]
%           or a txt file with one mni per line (special input: 'atlas_power264.txt')
%       radius: radius in mm, eg, 5mm
%       masterNiiPath: nii file to get voxel size, dimention, coordination, etc from
%           if not provided, use mask.nii in pwd
% Output:
%       roi files saved to pwd
%       returns a cell representing the path to the generated roi file

if nargin<3
    masterNiiPath='mask.nii';
end

if ischar(mniCoordinate)
    coords = importdata(mniCoordinate);
else
    coords = mniCoordinate;
end

result = cell(size(coords,1),1);
for i = 1:size(coords,1)
    coord = coords(i,1:end);
    fileName = ['ROI_', sprintf('%03d',i), '_r', num2str(radius), '_', ez.join('_',coord), '.nii'];
    ez.rm(fileName);

    % from file:
    % 1D file format:
    % 3 2 1 5
    % x y z [optional value for voxels within roi] [optional fifth value for radius]
    % 3dUndump -srad 7.5 -master func_slim+tlrc -prefix clust_spheres -xyz Clust_PeakXYZ.1D

    % from echo:
    % echo "32 -5 -22" | 3dUndump -srad 8 -orient LPI -prefix roi -master sample.nii -xyz -
    %     # (X, Y, and Z coordinates of sphere) (Radius of Sphere, in mm)
    %     # -orient specifies the coordinate system that xyz refers to.  if -orient not provided, infer from -master.  if -master provided, the generated file still has the same orientation as master, regardless of the -orient passed.
    %     # note the - after -xyz (to indicate stdin will be used for input)
    %     # by default, mask file is FIM (functional intensity map) format, unless the -master
    % dataset is an anat type.
    cmd = ['echo "', ez.join(' ',coord),'" | 3dUndump -master "', masterNiiPath, '" -srad ', num2str(radius), ' -prefix ', fileName, ' -xyz -'];
    [sta, res] = system(cmd, '-echo');
    ez.print('');
    result{i} = fileName;

end % end for

disp(result);

end % end function