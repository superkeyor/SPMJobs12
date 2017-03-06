function varargout = read_image_afni(varargin)

%   read_image:
%       input: 
%           header (struct variable generated with read_header)
%           volume range (optional, starting to count at 1)
%       output: image in neurological space (left = left, view from top)

hdrname = varargin{1}.RootName;

if nargin > 1 % if it is multiple arguments, then there are 
    
    opt = struct;
    opt.Frames = varargin{2};
    
    [err,data,header,err_msg] = BrikLoad(hdrname,opt);
    
else
    
    [err,data,header,err_msg] = BrikLoad(hdrname);
    
end

if err
    disp('Problems reading BRIK files from header using AFNI')
    error(err_msg)
end

varargout{1} = data;