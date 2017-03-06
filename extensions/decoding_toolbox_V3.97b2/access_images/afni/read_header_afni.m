function varargout = read_header_afni(varargin)

%   read_header: 
%       input: name of volume (full path , 1 x n string)
%       output: header of BRIK

% TODO: how to deal with oblique images? (i.e. realigned but not resliced)

try
    [err,hdr] = BrikInfo(varargin{:});
    if err
        error('Could not read header %s, please check screen for error messages or whether file exists.', varargin{1});
    end
catch %#ok<CTCH>
    disp(lasterr)
    error(['Cannot read header, probably due to incompatibility ',...
        'between image format and analysis software used or ',...
        'because image does not exist.'])
end

% add non-AFNI fields for better compatibility
hdr.fname = [hdr.RootName '.BRIK'];
hdr.mat = getafnimat(hdr);
hdr.dim = hdr.DATASET_DIMENSIONS(1:3);
hdr.dim(4) = hdr.DATASET_RANK(2); % number of subbricks
if hdr.SCENE_DATA(1) == 0
    hdr.suffix = '+orig';
elseif hdr.SCENE_DATA(1) == 1
    hdr.suffix = '+tlrc';
else
    error('Unsupported format for reading files in hdr.SCENE_DATA(1) = %i',hdr.SCENE_DATA(1))
end

varargout{1} = hdr;

function mat = getafnimat(hdr)

mat0 = [0 0 0;
        1 0 0;
        0 1 0;
        0 0 1];

[err,e] = AFNI_Index2XYZcontinuous(mat0,hdr,'LPI'); % LPI (left posterior inferior) is a typical coordinate code for e.g. SPM

if err
    error('Trouble reading from header using AFNI_Index2XYZcontinuous...')
end

a = e(2,:)-e(1,:);
b = e(3,:)-e(1,:);
c = e(4,:)-e(1,:);

% AFNI counts from 0, change to SPM standard (counting from 1) for creating orientation matrix
mat = [e(2,:)-e(1,:) 0;
       e(3,:)-e(1,:) 0;
       e(4,:)-e(1,:) 0;
       (5*e(1,:))-sum(e,1) 1]';
