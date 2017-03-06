function varargout = read_image_spm12(varargin)

%   read_image:
%       input: header (struct variable generated with read_header)
%       output: image in neurological space (left = left, view from top)

hdr = varargin{1};

if nargin >= 2 % if subvolumes in 4D file should be selected
    if any(varargin{2}>size(hdr))
        error('Some volume index to be selected exceeds the available number of headers provided in the 4D header file. Please check.')
    end
    hdr = hdr(varargin{2});
else
    if length(hdr)>1
        error('More than one header provided without a volume selection index. Unclear which image to pick from.')
    end
end

varargout{1} = spm_read_vols(hdr);