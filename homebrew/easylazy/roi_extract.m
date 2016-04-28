function main(ROI,Images)
% routine to extract data for an arbitrary number of ROI and from an
% arbitrary number of images - the routine follows the pattern of spm_voi
%
% INPUT can be empty. if empty, the user is prompted
%       ROI: ROI images, a single str or a cell of str
%       Images: beta/con images/subjects to extract data from
%               or, a path to second-level SPM.mat
%               if not provided, try to get info from second-level SPM.mat in pwd 
%
% OUTPUT the file is saved to the drive - the variable name is ROIDATA
%        a structure (ROIDATA.roi) with length(ROI) roi fields (ie the number of ROI images in input)
%        .name
%        .n the number of voxels in the ROI
%        .ev ev is the 1st eigen value across voxels, obtained for each Images
%
% Note:
% 1) if there are NaN in the ROI area for an image/subject 
% the values will be replaced with the mean of other non-NaN for that image
% 2) ideally extract data from beta/con images
% though also possible from first level/raw/time-series images
%
%
% Cyril Pernet v1 19-02-2015
% ---------------------------
% Copyright SPM-UP toolbox


%% Inputs
if nargin == 0
    ROI = spm_select(Inf,'image','select ROI images');
    Images = spm_select(Inf,'image','select images to extract data from');
elseif nargin == 1
    ROI = ROI;
    load('SPM.mat');
    Images = SPM.xY.P;
elseif nargin == 2
    ROI = ROI;
    % if Images is path to 'SPM.mat'
    if strfind(Images,'SPM.mat')
        load('SPM.mat')
        Images = SPM.xY.P;
    else
        Images = Images;
    end
else
    error('no or 2 arguments (ROI and Images) are needed, input error')    
end
% convert to char array -Jerry
ROI = char(ROI);
Images = char(Images);

%% check size compatibility 
ROI = spm_vol(ROI);
if ~spm_check_orientations(ROI)
    error('some ROI images have different dimensions')
end

Images = spm_vol(Images);
if ~spm_check_orientations(Images)
    error('some of the images to read have different dimensions')
end

%% meta-info
ROIs = spm_read_vols(ROI); % load each ROI and make a large matrix 
ROIs = ROIs > 0; % make sure it's binary
[xx,yy,zz,nroi]=size(ROIs);

x = Images(1).dim(1);
y = Images(1).dim(2);
z = Images(1).dim(3);
nimage = size(Images,1);
if x~= xx || y~= yy || z~= zz
    error('images to read data from and ROI images don''t have the same dimensions')
end
clear xx yy zz

%% compute

for r=1:nroi
    [~,ROIDATA.roi(r).name] = spm_fileparts(ROI(r).fname);
    fprintf('getting data for %s ... \n',ROIDATA.roi(r).name)
    
    % find voxels of the ROIs
    [X,Y,Z] = ind2sub([x y z],find(squeeze(ROIs(:,:,:,r))));
    ROIDATA.roi(r).n = length(X);
    
    % get the data (nb images * nb voxel in ROIs)
    data = spm_get_data(Images,[X Y Z]');

    % change NaN to mean
    location = find(isnan(mean(data,2)));
    for l=1:length(location)
        data(location(l),isnan(data(location(l),:))) = nanmean(data(location(l),:));
    end
    
    % compute the eigen value
    [m,n]   = size(data);
    if m > n
        [v,s,v] = svd(data'*data);
        s       = diag(s);
        v       = v(:,1);
        u       = data*v/sqrt(s(1));
    else
        [u,s,u] = svd(data*data');
        s       = diag(s);
        u       = u(:,1);
        v       = data'*u/sqrt(s(1));
    end
    d       = sign(sum(v));
    u       = u*d;
    v       = v*d;
    ROIDATA.roi(r).ev = u*sqrt(s(1)/n);
end

% save
newname = spm_input('save as',1,'s');
newdir = uigetdir(pwd,['choose directory to save ' newname '.mat']);
save([newdir filesep newname '.mat'],'ROIDATA')

