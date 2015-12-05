% function fig_handle = display_volume(vol, mode, title_str, fig_handle,  cfg)
%
% Show all slices of a volume in a new figure. Slices are along the 3rd
% dimension of the input volume (z-direction).
%
% IN
%   vol: 3d matrix or name of 3d image (2d will also work, then it plots one slice)
% OPTIONAL
%   title_str is optional (dimensions will be added behind title)
%   fig_handle: If provided, everything will be plotted in this figure (will
%       overwrite whatever the figure contained before)
%   mode: 'subplots' (default) or 'plain' (plain will create one image containing all 
%       slices, subplots many subplots)
%   cfg: cfg containing cfg.software to use as reading (will call 
%       decoding_defaults if not provided)
%
% Examples: 
%   With direct 3d matrix as input (pointless random data)
%       fig_handle = display_volume(randn(64, 64, 32), '', 'Testtitle') % '' will use default: subplots
%   or with filename as input
%       display_volume('C:\tdt\result_decoding_example\res_accuracy_minus_chance.img')
%   or in plain mode
%       display_volume('C:\tdt\result_decoding_example\res_accuracy_minus_chance.img', 'plain')
% Kai, 2015/08/20

function fig_handle = display_volume(vol,  mode, title_str, fig_handle,cfg)

%% Check input
if ischar(vol)
    fname = vol;
    clear vol;
    % Add loading data from file here, if you like
    display(['Reading image ' fname])
    if ~exist('cfg', 'var')
        cfg = decoding_defaults;
    end
    hdr = read_header(cfg.software, fname);
    vol = read_image(cfg.software, hdr);
    % use filename as title
    title_str = fname;
    % could also take only filename, but full path seems helpful
    % [p, fn, ext] = fileparts(fname);
    % title_str = [fn, ext sprintf('\n')];
end

%% Get dimension of data
sz = size(vol);
if length(sz) < 3
    warning('The data is not 3D, trying to plot it anyway (as one slice)');
    sz(end+1:3) = 1; % fill up to 3 dimensions
elseif length(sz) > 3
    error('The function only displays 1 3d volume at the moment')
end
    
%% Set defaults
if ~exist('title_str', 'var') || isempty(title_str)
    title_str = sprintf('3d volume (%ix%ix%i)', sz);
else
    title_str = [title_str sprintf(' (%ix%ix%i)', sz)];
end
    
if ~exist('mode', 'var') || isempty(mode)
    mode = 'subplots';
end
%% Plot
factor = sz(2)/sz(1);
nRows = round(sqrt(sz(3))*factor);
nColumns = ceil(sz(3)/nRows);
% get data scaling
clim = [min(vol(:)) max(vol(:))];
title_str = [title_str sprintf('. Datarange [%g, %g]. ', clim)];

% create figure or use passed one
if ~exist('fig_handle', 'var')
    fig_handle = figure('name', title_str, 'Position', [84   241   870   694]);
else
    figure(fig_handle);
    set(gcf, 'name', title_str);
end

colormap('bone');

% plot (as subplots)
switch mode
    case 'subplots'
        for i = 1:sz(3)
            subplot(nRows, nColumns, i);
            imagesc(vol(:,:,i), clim);
            % add scaling to last plot (sorry, last plot)
            title(['z=' int2str(i)])
            set(gca, 'xticklabel', [])
            set(gca, 'yticklabel', [])
        end
    case 'plain'
        imagesc(transform_vol(vol)); % use martins tranform vol function
        set(gca, 'xticklabel', [])
        set(gca, 'yticklabel', [])
    otherwise
        error('Unkown mode %s', mode)
end

%% add a colorbar to last plot
colorbar('Location', 'East'); % use last subplot from loop as peer

% add title
title_str = [title_str char(10) 'Data from volume only, ignoring affine transformation (in hdr.mat).'];
switch mode
    case 'subplots'
        try
            t = suptitle(title_str);
        catch
            % try to put it in the middle
            subplot(nRows, nColumns, ceil(nColumns/2));
            t = title(title_str);
        end
    otherwise
            t = title(title_str);
end
set(t, 'Interpreter', 'None')

%% Help function: newvol = tranform_vol(vol) for plain mode
% function newvol = transform_vol(vol)
%
% Used by display_volume.m to display a given volume (see there).
%
% function to create 2d matrix from 3d matrix with all slices put next to
% each other

function newvol = transform_vol(vol)

% Todo: Make sure that image is 3D.

sz = size(vol);

factor = sz(2)/sz(1);
nRows = round(sqrt(sz(3))*factor);
nColumns = ceil(sz(3)/nRows);

newvol = zeros(sz(1)*nRows,sz(2)*nColumns);

counterRow = 0;
counterColumn = 1;

slicetemplate = newvol;
slicetemplate(1:numel(slicetemplate)) = 1:numel(slicetemplate);
sliceindices = slicetemplate(1:sz(1),1:sz(2))-1;

for i = 1:sz(3)
    if counterRow == nRows
        counterRow = 0;
        counterColumn = counterColumn + 1;
    end
    counterRow = counterRow + 1;
    currindices = sliceindices+slicetemplate((counterRow-1)*sz(1)+1,(counterColumn-1)*sz(2)+1);
    newvol(currindices) = vol(:,:,i);
end