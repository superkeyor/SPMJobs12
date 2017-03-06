function varargout = write_image_afni(varargin)

%   write_image:
%       inputs: header, volume (X x Y x Z)
%       output: written header (normally not needed)

% This code includes parts from the CoSMoMVPA package from the function
% cosmo_map2fmri.m which is licensed under the Expat license:
%
% Copyright (c) 2013-2016 Nikolaas N. Oosterhof
%               2013      Andrew C. Connolly
%               2013-2016 CoSMoMVPA contributors (see AUTHOR file)
% 
% For details on copyright notice, open this file in an editor.

% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.
% 

% Set header first (we get orientations and everything from the previous header)

hdr = struct;
hdr.SCENE_DATA = [0 11 1];
hdr.TYPESTRING = '3DIM_HEAD_FUNC';
hdr.BRICK_TYPES = 3; % store in float format
hdr.BRICK_STATS = [];                 % ... and thus need no stats
hdr.BRICK_FLOAT_FACS = [];            % ... or multipliers
hdr.DATASET_RANK = [3 1];      % 1 refers to 1 volume
hdr.DATASET_DIMENSIONS = varargin{1}.DATASET_DIMENSIONS(1:3); % get this from the original header
hdr.ORIENT_SPECIFIC = varargin{1}.ORIENT_SPECIFIC; % and this
hdr.DELTA = varargin{1}.DELTA; % and this
hdr.ORIGIN = varargin{1}.ORIGIN; % and this one too
hdr.SCALE = 0;
hdr.NOTES_COUNT = 0;
hdr.WARP_TYPE = [0 0];
hdr.FileFormat = 'BRIK';

[unused, unused, endian_ness] = computer();
hdr.BYTEORDER_STRING = sprintf('%sSB_FIRST', endian_ness);

set_empty = {'BRICK_LABS','BRICK_KEYWORDS',...
    'BRICK_STATS','BRICK_FLOAT_FACS',...
    'BRICK_STATAUX','STAT_AUX'};
for k = 1:numel(set_empty)
    fn = set_empty{k};
    hdr.(fn) = [];
end

% Set options for writing

hdr.RootName = varargin{1}.fname;
data = varargin{2}; % get the data

afniopt = struct();
afniopt.Prefix = varargin{1}.fname; %the second input argument
afniopt.OverWrite = 'y';
afniopt.NoCheck = 0;
afniopt.AppendHistory = false;
afniopt.verbose = 0;
afniopt.Scale = 0;
afniopt.AdjustHeader = 'no';

fname = varargin{1}.fname;

if isempty(regexp(fname,'(+orig$|+orig.HEAD$|+orig.BRIK$|+orig.BRIK.gz$|+tlrc$|+tlrc.HEAD$|+tlrc.BRIK$|+tlrc.BRIK.gz$)','once'))
    if isfield(varargin{1},'suffix')
        [fp,fn,fext] = fileparts(fname);
        fname = fullfile(fp,[fn varargin{1}.suffix fext]);
    end
end
    
if ~isempty(regexp(fname, '(+orig$|+orig.HEAD$|+orig.BRIK$|+orig.BRIK.gz$)', 'once'))
    hdr.SCENE_DATA(1) = 0;
    afniopt.View = '+orig';
elseif ~isempty(regexp(fname, '(+tlrc$|+tlrc.HEAD$|+tlrc.BRIK$|+tlrc.BRIK.gz$)', 'once'))
    hdr.SCENE_DATA(1) = 2;
    afniopt.View = '+tlrc';
else
    error('File name or format to be written is not +orig or +tlrc (filename: , . Required for writing AFNI files. Unsupported scene data (this is a field in the BRIK header) for %s', varargin{1}.fname);
end

% Finally (or at last?), write it out
[err, ErrMessage] = WriteBrik(data, hdr, afniopt);
if err
    error(ErrMessage);
end

varargout{1} = hdr;


