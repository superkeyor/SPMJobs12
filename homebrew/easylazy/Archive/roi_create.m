function outname = main(xyz,radius,labels)
% Input:
%       xyz = coordinates (rows are ROIs) eg, [2,3,4;20,30,40]
%       radius = 'Sphere' radius of ROI
%       labels = corresponds to each ROI nx1 {'leftROI';'rightROI'}
%                default ''
% Output:
%       ROI_Sphere8_2_3_4_label.nii or ROI_Sphere8_2_3_4 in the pwd
%       the full path to the (last) generated ROI file
% note: may use marsbar or wfu_pickatlas instead


% Uses code authored by:
% Dr. Robert Welsh (SimpleROIBuilder.m)
% Drs. Donald McLaren & Aaron Schultz (peak_nii.m)

% -------------- Copyright (C) 2014 --------------
%	Author: Bob Spunt
%	Affilitation: Caltech
%	Email: spunt@caltech.edu
%
%	$Revision Date: Aug_12_2014

roi.shape = 'Sphere';
roi.size = radius;

if nargin<3, labels = repmat({''},size(xyz,1),1); end
% EPI located in the same folder as this script
ref = which('EPITEMPLATE.nii'); 
if ischar(labels), labels = cellstr(labels); end
refhdr = spm_vol(ref);
roihdr = refhdr;
roihdr.pinfo = [1;0;0];
roipath  = pwd;
[R,C,P]  = ndgrid(1:refhdr.dim(1),1:refhdr.dim(2),1:refhdr.dim(3));
RCP      = [R(:)';C(:)';P(:)'];
clear R C P
RCP(4,:) = 1;
XYZmm    = refhdr.mat(1:3,:)*RCP;   
Q        = ones(1,size(XYZmm,2));
nroi = size(xyz,1);
for i = 1:nroi
    
    mm = xyz(i,:)';
    cROI = zeros(roihdr.dim);
    cHDR = roihdr;
    if isempty(labels{i})
        roidescrip = ['ROI_' roi.shape num2str(roi.size) '_' num2str(round(xyz(i,1))) '_' num2str(round(xyz(i,2))) '_' num2str(round(xyz(i,3)))];
    else
        roidescrip = ['ROI_' roi.shape num2str(roi.size) '_' num2str(round(xyz(i,1))) '_' num2str(round(xyz(i,2))) '_' num2str(round(xyz(i,3))) '_' labels{i}];
    end
    cHDR.fname = [roipath filesep roidescrip '.nii'];
    cHDR.descrip = roidescrip;
    switch roi.shape
        case 'Sphere'
        j = find(sum((XYZmm - mm*Q).^2) <= roi.size^2);
        case 'Box'
        j = find(all(abs(XYZmm - mm*Q) <= [roi.size roi.size roi.size]'*Q/2));
    end
    cROI(j) = 1;
    outname = cHDR.fname; 
    spm_write_vol(cHDR,cROI);
    fprintf('\nROI file created: %s\n', [roidescrip '.nii']);

    % output some useful info of the generated image
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
    fprintf('Dimension: %s\n',mat2str(dim_out));
    fprintf('Voxel size: %s\n',mat2str(abs(voxsize)));
    fprintf('Description: %s\n',description_out);

    if iscell(outname), outname = char(outname); end
    spm_image('Display', outname); 

    ez.pprint('========================================================================\n');

end
