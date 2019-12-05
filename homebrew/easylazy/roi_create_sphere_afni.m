function result = main(mniCoordinate, radius, masterNiiPath)
% (masterNiiPath,radius,mniCoordinate)
% Description:
%       Uses afni 3dUndump to create roi
%       https://afni.nimh.nih.gov/pub/dist/doc/program_help/3dUndump.html
% Input:
%       mniCoordinate: [x, y, z] or a txt file with one mni per line (special input: 'atlas_power264.txt')
%       radius: radius in mm, eg, 5mm
%       masterNiiPath: nii file to get voxel size, dimention, coordination, etc from
% Output:
%       roi file
%       returns a cell representing the path to the generated roi file

if nargin<3
    masterNiiPath='mask.nii';
end

if ischar(mniCoordinate)
    coords = importdata(mniCoordinate);
else
        
header = cell(1,size(coords,1));
result = {};
for i = 1:size(coords,1)
    coord = coords(i,1:end);
    fileName = ['ROI_', sprintf('%03d',i), '_', ez.join('_',coord), '.nii'];

    % the last - is for stdin from echo
    cmd = ['echo ', ez.join(' ',coord),' | 3dUndump -master "', masterNiiPath, '" -srad ', num2str(radius), ' -prefix ', fileName, ' -'];
    [sta, res] = system(cmd);
    result = [result,fileName];

end % end for
result = [header;num2cell(result)];

end % end function