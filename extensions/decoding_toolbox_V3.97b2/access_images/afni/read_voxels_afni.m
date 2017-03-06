function varargout = read_voxels_afni(varargin)

%   read_voxels: 
%       inputs: header, coordinates (n x 3 (XYZ))
%       output: 1 x n vector of voxel values

hdr = varargin{1};
x = varargin{2}(:,1);
y = varargin{2}(:,2);
z = varargin{2}(:,3);


hdrname = varargin{1}.RootName;

opt = struct;
opt.Format = 'vector';
% convert xyz coordinates to indices
opt.Voxels = sub2ind(hdr.dim(1:3),x,y,z)';

if nargin > 2 % if it is more than 2 arguments, then there are sub bricks (i.e. 4D representation of data)
    
    % select frames to pick
    opt.Frames = varargin{3};
    
    [err,data,header,err_msg] = BrikLoad(hdrname,opt); %#ok<ASGLU>
    
else
    
    [err,data,header,err_msg] = BrikLoad(hdrname); %#ok<ASGLU>
    
end

if err
    disp('Problems reading BRIK files from header using AFNI')
    error(err_msg)
end

varargout{1} = data;