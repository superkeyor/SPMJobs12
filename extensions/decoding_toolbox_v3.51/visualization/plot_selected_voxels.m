% fighdl = plot_selected_voxels(position_index,sz,brain_data,mask_index,border_images, fighdl, cfg)
%
% This function plots a given voxelselection (e.g. searchlight, ROI), and
% can in addition show a 2d projection of an image.
%
% Example usages:
%   plot_selected_voxels(position_index,sz)
%       Plot currently selected voxels only (no background image)
%   plot_selected_voxels(position_index,sz,brain_data,mask_index)
%       Plot searchlight + background
%   plot_selected_voxels(...,border_images)    
%       Additionally select how the 2d border image should look like
%       
%
% PARAMETER
%   position_index: vector 1xn with indices of voxels in sz space
%   sz: 1x3 vector: dimensions of original images
% OPTIONAL (to add background image)
%   brain_data: 1xBD vector with values of an input image 
%       (e.g. the first brain image), serves as background
%   mask_index: 1xBD vector specifying the position of each value in 
%       brain_data in the sz-dimensional space
%   border_image: specify type of background image. Possible value:
%       'projection', 'slices', 'projection+slices' (default), []: default
%   fighdl: Handle to a figure that should be plotted to. By default, the
%       current axis will be used. fighdl = nan prevent clearing.
%       Remark: Plotting will happen in the background, and the previously 
%           current axis will be activated in the end again
%   cfg: The full decoding cfg. Current fields in use:
%     cfg.plot_selected_voxels_writerObj: A writerObject, e.g. to store
%       the current figure to a 
%           VIDEO. 
%       For this, pass a new and started VideoWriter. 
%       Example code for video:
%           % create a video writer object and add it to the cfg
%           cfg.plot_selected_voxels = 1;
%           cfg.plot_selected_voxels_writerObj = VideoWriter('plot_selected_voxels.avi'); % see HELP VideoWriter
%           open(cfg.plot_selected_voxels_writerObj);
%           % do the decoding
%           decoding(cfg);
%           % CLOSE the object after use
%           close(cfg.plot_selected_voxels_writerObj);
%   cfg.dont_clear_fig = 1 to keep the figure (e.g. to use a subplot)

% Martin Hebart, Kai Goergen, 2013/05/27

% History: 
%   Kai: 2015/11/05: using a persitant variable if function is repeatedly 
%       called without figure handle, avoids overwritting previous figures
%       and avoids also poping up new figures each time when called
%   Kai: 2015/10/15: Corrected plotting projects, now works with any
%       dimensions (before only when x and y were equal)
%   Kai: 2015/08/15: Added Video storing option (or other objectWriter)
%   Martin: 2014/01/26: Speed-up of 30% by drawing only voxels that are
%       visible
%   Kai: Removed the small bug that the projections where not shown
%       properly. Also moved coordinate system by -.5 in each direction, so 
%       the center of each voxel is now labeled

% Possible IMPROVEMENTS:
% Adjust size of each axis to get "real" shape of ROI, not distorted along
% the smaller/longer axis
%
% Keep figure and projections of brain. Redraw only on separate handles the
% patch and the searchlight/ROI projections.
%
% Speed-Up - Ideas for searchlights: 
%   - only update the SL, i.e. remove voxels that are not there any longer, 
%       and add voxels that are new
%   - do not draw projections over and over, but only once
%       but of course plot searchlight
%   -- somewhere on the way there: save projections

function fighdl = plot_selected_voxels(position_index,sz,brain_data,mask_index,border_images, fighdl,cfg)

% check that the correct arguments are provided
if exist('brain_data', 'var')
    if ~exist('mask_index', 'var')
        error('brain_data is provided, but mask_index not. Both arguments must be provided')
    end
end

if ~exist('cfg', 'var')
    cfg = [];
end

%% set focus silently
if exist('fighdl', 'var') && ~isempty(fighdl)
    previous_fig = gcf;
else
    previous_fig = -1; % mark that fighdl has not been passed
    % check the function opened a figure before, if so, try to use it
    persistent created_fighdl % fallback function, so that function does not popup new figures if called repeatedly with no figure handles
    if isempty(created_fighdl)
        created_fighdl = -1; % will create a new figure
    end
    fighdl = created_fighdl;
end

%% select the ROI figure for plotting
try
    set(0,'CurrentFigure',fighdl)
catch %#ok<CTCH>
    disp(lasterr)
    warningv('plot_selected_voxels:could_not_get_figure', 'Could not select previous figure handle, maybe figure has been closed. Creating a new one!')
    fighdl = figure('name', ['Online ROI, showing 1/' num2str(cfg.plot_selected_voxels) ' steps (cfg.plot_selected_voxels=0 for more speed)']);
    if exist('created_fighdl', 'var')
        created_fighdl = fighdl; % remember change
    end
end
%%
% position_index: indices of all voxel positions
% sz: size of volume (optional)

vertex_matrix = [0 0 0
1 0 0
1 1 0
0 1 0
0 0 1
1 0 1
1 1 1
0 1 1];
faces_matrix = [1 2 6 5
2 3 7 6
3 4 8 7
4 1 5 8
1 2 3 4
5 6 7 8];


[P(:,1) P(:,2) P(:,3)] = ind2sub(sz,position_index);
n_vox = size(P,1);

% TODO: Check if we are dealing with one or several connected components

% BEGINNING OF CHECK (doesn't work properly for rois, so deactivated)
% % Check if voxel is visible and remove voxels that are not
% removeind = false(n_vox,1);
% for i = 1:n_vox
%     Pdiff = bsxfun(@minus,P(i,:),P);
%     keepind = sum(abs(Pdiff),2)>1;
%     if sum(keepind)<6 % if there are less than six imminent neighbors
%         removeind(i) = true; % remove
%     end
% end
% 
% P(removeind,:) = [];
% n_vox = size(P,1);
% position_index(removeind) = [];
% END OF CHECK

large_vertex_matrix = zeros(n_vox* size(vertex_matrix,1), size(vertex_matrix,2));
large_faces_matrix = zeros(n_vox * size(faces_matrix,1), size(faces_matrix,2));

for i = 1:n_vox
    xpos = (i-1)*8 + (1:8);
%     large_vertex_matrix(xpos,:) = bsxfun(@plus,vertex_matrix,[M.X(position_index(i)) M.Y(position_index(i)) M.Z(position_index(i))]);
    large_vertex_matrix(xpos,:) = bsxfun(@plus,vertex_matrix,P(i,:))-.5;    
    xpos = (i-1)*6 + (1:6);
    large_faces_matrix(xpos,:) = faces_matrix + (i-1)*8;
end

% Tried to speed-up by clearing only the child, but didn't speed-up
% Ideally, load only the values that patch loads and replace them
if ~isfield(cfg, 'dont_clear_fig') || ~cfg.dont_clear_fig 
    clf(fighdl)
end

patch('Vertices',large_vertex_matrix,'Faces',large_faces_matrix,...
'FaceVertexCData',ones(8*n_vox,1) * [.9 .2 .4],'FaceColor','interp',...
'EdgeColor',[0.2 0.2 0.2]);

set(gca,'XLim',[0.5 sz(1)+0.5],...
        'Ylim',[0.5 sz(2)+0.5],...
        'Zlim',[0.5 sz(3)+0.5],...
        'XLimMode','manual',...
        'YLimMode','manual',...
        'ZLimMode','manual',...
        'view',[-37.5,30]);
    
% axis([1 sz(1)+1 1 sz(2)+1 1 sz(3)+1]-.5)
set(gca, 'XTick', [1, sz(1)])
set(gca, 'YTick', [1, sz(2)])
set(gca, 'ZTick', [1, sz(3)])

%% Plot brain on x,y,z plane, if provided
try
    if exist('brain_data', 'var') && ~isempty(brain_data)
        if ~exist('mask_index', 'var')
            error('brain_data is provided, but mask_index not. Both arguments must be provided')
        end

        % replace possible nans by 0
        brain_data(isnan(brain_data)) = 0;

        % normalize gray values for plotting
        diff_braindata = max(brain_data(:))-min(brain_data(:));
        if diff_braindata == 0
            % no difference, just set upper limit to see mask voxels
            if brain_data(1) > .6
                brain_data(:) = .6;
            end
        else
            % normalize
            brain_data = (brain_data-min(brain_data(:)))/diff_braindata;
        end

        % put brain into a full volume (at the moment, we only have the masked
        % brain)
        brain = zeros(sz);
        brain(mask_index) = brain_data*0.9+0.1; % *.9 + .1 serves to differentiate between inmask and outmask voxels

        % % TODO: only project outer voxels 
        %

        if ~exist('border_image', 'var') || isempty(border_image)
            border_images = 'projection+slices'; % choose if you want to project slice (e.g. the middle) or the projection
        end
        % check that value is valid
        if ~(strcmp(border_images, 'projection') || strcmp(border_images, 'projection+slices') || strcmp(border_images, 'slices'))
            error('Unkown projection method for border_images, please check')
        end

        if strcmp(border_images, 'projection') || strcmp(border_images, 'projection+slices')
            z_projection = sum(brain, 3)';
            x_projection = squeeze(sum(brain, 2))';
            y_projection = squeeze(sum(brain, 1))';   

            % normalize colours between 0 / 1
            min_value = min([z_projection(:); x_projection(:); y_projection(:)]);
            max_value = max([z_projection(:); x_projection(:); y_projection(:)]);
            z_projection = (z_projection-min_value)/(max_value-min_value);
            x_projection = (x_projection-min_value)/(max_value-min_value);
            y_projection = (y_projection-min_value)/(max_value-min_value);

            z_background = z_projection;
            x_background = x_projection;
            y_background = y_projection;
        end

        if strcmp(border_images, 'slices') || strcmp(border_images, 'projection+slices')
            z_slice = brain(:,:,round(sz(3)/2))';
            x_slice = squeeze(brain(:,round(sz(2)/2),:))';
            y_slice = squeeze(brain(round(sz(1)/2),:,:))';
            % no normalization needed, is already normalized above
        end


        if strcmp(border_images, 'projection+slices')
            z_background(z_slice>0) = z_slice(z_slice>0);
            x_background(x_slice>0) = x_slice(x_slice>0);
            y_background(y_slice>0) = y_slice(y_slice>0);
        elseif strcmp(border_images, 'slices')
            z_background = z_slice;
            x_background = x_slice;
            y_background = y_slice;
        end

        % add projection of searchlight onto image
        sl_3d = zeros(size(brain));
        sl_3d(position_index) = 1;
        % add projection to slices
        z_sl_projection = sum(sl_3d, 3) > 0;
        z_background(z_sl_projection') = 1;
        x_sl_projection = squeeze(sum(sl_3d, 2) > 0);
        x_background(x_sl_projection') = 1;
        y_sl_projection = squeeze(sum(sl_3d, 1) > 0);
        y_background(y_sl_projection') = 1;

        % REMARK: When plotting the background image using surface, we need to
        % plot x and y from 1:sz(1)+1, because surface(x,y,z)  plot the value z 
        % to the square x..x+1, y..y+1. 
        % This create 8! elements for x and y, but these values only define the
        % BOUNDARY, and these are 1 more than the containing data.
        edgeCol = 'none';
        % x and y are flipped
        [x,y] = meshgrid(1:sz(1)+1,1:sz(2)+1); x=x-.5; y=y-.5;
        surface(x,y,ones(size(x))-.5,z_background, 'EdgeColor', edgeCol); 
        [x,z] = meshgrid(1:sz(2)+1,1:sz(3)+1); x=x-.5; z=z-.5;
        surface(sz(1)*ones(size(x)),x,z,y_background, 'EdgeColor', edgeCol);
        [y,z] = meshgrid(1:sz(1)+1,1:sz(3)+1); y=y-.5; z=z-.5;
        surface(y,sz(2)*ones(size(y)),z,x_background, 'EdgeColor', edgeCol);
        % set colormap to gray for current axes only
        try
            colormap(gca, 'gray');
        catch % probably for older versions of matlab
            colormap('gray');
        end
    end
catch e
    e
    warningv('plot_selected_voxels:drawing_backgroundbrain_failed', 'Drawing backgroundbrain failed, continue nonetheless');
end

%% draw image
drawnow;

%% Store to video (or any given writer, if passed)
% in all calls, add frame
if isfield(cfg, 'plot_selected_voxels_writerObj') && ~isempty(cfg.plot_selected_voxels_writerObj)
    try
        dispv(1, 'plot_selected_voxels: Adding figure to video. Remember to close video at the end with "close(cfg.plot_selected_voxels_writerObj)"')
        writeVideo(cfg.plot_selected_voxels_writerObj, getframe);
    catch ME
        ME
        cfg.plot_selected_voxels_writerObj
        warningv('plot_selected_voxels:writerObj_failed', 'A writerObj to save the current figure was passed to plot_selected_voxels in cfg.plot_selected_voxels_writerObj, but failed. This is probably because the object was not initialized or opened correctly. See "help videowriter"')
    end
end

%% set figurehandle back to what it was before
if previous_fig ~= -1  % fighdl not passed
    set(0,'CurrentFigure',previous_fig) % set figurehandle back to previous axis
end