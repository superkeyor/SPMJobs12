function main(images, xyz)
% A visual check of image registration quality.
%
% usage: (images, xyz)
% images: cell array of image paths (max = 24)
% xyz = [x y z], optional
%     when specified xyz, will also auto add/show single subject T1 MNI image at the end

% FORMAT spm_check_registration
% FORMAT spm_check_registration(images, captions)
% Orthogonal views of one or more images are displayed. Clicking in
% any image moves the centre of the orthogonal views. Images are
% shown in orientations relative to that of the first selected image.
% The first specified image is shown at the top-left, and the last at
% the bottom right. The fastest increment is in the left-to-right
% direction (the same as you are reading this).
%__________________________________________________________________________
% Copyright (C) 1997-2011 Wellcome Trust Centre for Neuroimaging

% John Ashburner
% $Id: spm_check_registration.m 4330 2011-05-23 18:04:16Z ged $
if ~nargin
    [images, sts] = spm_select([1 15],'image','Select images');
    if ~sts, return; end
end

if exist('xyz', 'var')
    showMNIT1 = 1;
else
    showMNIT1 = 0;
end

if showMNIT1
    spmDir = fileparts(which('spm'));
    T1 = [spmDir filesep 'canonical' filesep 'single_subj_T1.nii'];
    images = vertcat(images{:},{T1}); 
end

if length(images) > 24, error('Only 24 (max) images allowed.'); end

if ischar(images), images = cellstr(images); end % deal with batch call passed parameter

captions = cellfun(@num2str, num2cell(1:length(images)), 'Unif', false);
for i = 1:length(captions)
    file = images{i};
    [filePath fileName fileExt] = ez.splitpath(file);
    if length(captions) == 1
        captions{i} = [fileName fileExt];
    else
        captions{i} = sprintf(['(' num2str(i) ')' '\n' fileName fileExt]);
    end
end

if iscell(images{1}), images = spm_vol(vertcat(images{:})); end

spm_figure('GetWin','Graphics');
spm_figure('Clear','Graphics');
spm_orthviews('Reset');
mn = length(images);
n  = round(mn^0.4);
m  = ceil(mn/n);
w  = 1/n;
h  = 1/m;
ds = (w+h)*0.02;
for ij=1:mn
    i = 1-h*(floor((ij-1)/n)+1);
    j = w*rem(ij-1,n);
    handle = spm_orthviews('Image', images{ij},...
        [j+ds/2 i+ds/2 w-ds h-ds]);
    if ij==1, spm_orthviews('Space'); end
    spm_orthviews('AddContext',handle);
    if ~isempty(captions)
        captions = cellstr(captions);
        mn = numel(captions);
        if ij <= mn
            spm_orthviews('Caption', ij, captions{ij}, 'FontSize', 9, 'FontName', 'Arial');
        end
    end
end

if exist('xyz', 'var')
    spm_orthviews('Reposition', xyz);
else
    spm_orthviews('Reposition',[0 0 0]);
end