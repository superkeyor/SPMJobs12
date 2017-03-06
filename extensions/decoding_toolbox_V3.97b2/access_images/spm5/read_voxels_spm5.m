function varargout = read_voxels_spm5(varargin)

%   read_voxels: 
%       inputs: header, coordinates (n x 3 (XYZ))
%       output: 1 x n vector of voxel values

if nargin >= 3
    error('Third input for subvolumes provided. SPM5 cannot deal with 4D data. Please change cfg.software')
end

hdr = varargin{1};
x = varargin{2}(:,1);
y = varargin{2}(:,2);
z = varargin{2}(:,3);

varargout{1} = spm_sample_vol(hdr,x,y,z,0);