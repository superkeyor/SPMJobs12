function varargout = read_voxels_spm8(varargin)

%   read_voxels: 
%       inputs: header, coordinates (n x 3 (XYZ))
%       output: 1 x n vector of voxel values

hdr = varargin{1};
x = varargin{2}(:,1);
y = varargin{2}(:,2);
z = varargin{2}(:,3);

if nargin >= 3 % if subvolumes in 4D file should be selected
    if any(varargin{3} > length(hdr))
        error('Some volume index to be selected exceeds the available number of headers provided in the 4D header file. Please check.')
    end
    hdr = hdr(varargin{3});
else
    if length(hdr)>1
        error('More than one header provided without a volume selection index. Unclear which image to pick from.')
    end
end

varargout{1} = spm_sample_vol(hdr,x,y,z,0);