function result = main(roiMatPath,space,verbose,folder)
% Description:
%       Uses marsbar functions to export .mat ROI into nii formats
%       If marsbar path not in searchpath, auto add them internally first.
% Input:
%       roiMatPath: path to marbar .mat ROIs, str or cell of str
%       space: exported nii space, three choices
%              1) 'mni', default, the so-called "base space"
%              2) from image (by passing a path of an image file), eg. './beta_0001.nii,1'
%                 recommended! voxel size/dim could be diff, eg 2x2x2 [79 95 68]
%              3) 'roi' whatever the mat roi's space, the so-called "native"
%       verbose = 0/1, if true, print out roi info and generate xlsx summary, default true
%       folder, path to folder where ROI files will be saved, default pwd
% Output:
%       .nii files
%       the full path to the generated ROI nii file(s), if more than one file, a cell; otherwise a str
%       an xlsx file (if verbose=1) with all ROI names and non-zero voxel numbers in folder

if (isempty(which('marsbar'))||isempty(which('spm_get')))
    ez.print('addpath marsbar...')
    extsPath = ez.joinpath(ez.parentdir(ez.parentdir(ez.csd())), 'extensions');
    thePath = ez.lsd(extsPath,'^marsbar');
    thePath = ez.joinpath(extsPath,thePath{1});
    addpath(thePath,'-end');
    % additional path that would be added by marsbar
    addpath(ez.joinpath(thePath,'spm5'),'-end');
end

if ischar(roiMatPath), roiMatPath = cellstr(roiMatPath); end
if nargin<2, space = 'mni'; end
if nargin<3, verbose = 1; end
if nargin<4, folder = pwd; else ez.mkdir(folder); end

result = cell(length(roiMatPath),1);

% code modified from marsbar.m around line 676
%=======================================================================
% writes ROI as image 
%=======================================================================
% marsbar('roi_as_image')
%-----------------------------------------------------------------------
switch char(space)
    case 'mni'
        sp = maroi('classdata', 'spacebase');
    case 'roi'
        sp = [];
    otherwise
        sp = mars_space(space);
end

xlsx = ez.header({'roi','non_zero_voxels'});
for i = 1:length(roiMatPath)
    roi = roiMatPath{i};
    [pn fn ext] = fileparts(roi);
    roi = maroi('load', roi); 

    fname = ez.joinpath(folder,[fn,'.nii']);
    save_as_image(roi, fname, sp);
    fprintf('---------------------------------------------------------\n');
    fprintf('Saved ROI as %s\n',fname);

    if verbose
        % output some useful info of the exported nii image
        fprintf('\nExported nii image info:\n');
        hdr_out = spm_vol(fname);
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
        xlsx = ez.append(xlsx, {fn, n_out});
        fprintf('---------------------------------------------------------\n');
    end % end if

    result{i,1} = fname;

end % end for

if length(result)==1, result=result{1}; end
if height(xlsx)>0, ez.savex(xlsx,ez.joinpath(folder,'ROI_Summary.xlsx'))
end % end func