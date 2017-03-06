function varargout = read_image_spm5(varargin)

%   read_image:
%       input: header (struct variable generated with read_header)
%       output: image in neurological space (left = left, view from top)

if nargin >= 2
    error('Second input for subvolumes provided. SPM2 cannot deal with 4D data. Please change cfg.software')
end

varargout{1} = spm_read_vols(varargin{:});