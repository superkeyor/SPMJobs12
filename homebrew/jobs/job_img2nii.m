% (hdr,del)
%       hdr: path to hdr, a cell of many hdrs, or a str to a single hdr
%            hdr could be 3d or 4d
%       del: 1/0 (default 0), delete original hdr/img
% converts hdr/img files to nii.
% uses nii_tool from:
% https://www.mathworks.com/matlabcentral/fileexchange/42997-dicom-to-nifti-converter--nifti-tool-and-viewer

function main(hdr,del)
if nargin < 2, del = 0; end
% single string input
if ~iscell(hdr), hdr = cellstr(hdr); end
% simply replace with plural
hdrs = hdr;
for jjj = 1:ez.len(hdrs)
    hdr = hdrs{jjj};
    nii = nii_tool('load', hdr);
    [pathstr, filename] = ez.splitpath(hdr);
    outname = ez.joinpath(pathstr,[filename '.nii']);
    nii_tool('save', nii, outname);

    % delete original hdr/img
    if del 
        ez.rm(ez.joinpath(pathstr,[filename '.hdr']));
        ez.rm(ez.joinpath(pathstr,[filename '.img']));
    end
end
end % end of my func
