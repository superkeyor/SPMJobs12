function mask_name = decoding_create_maskfile(cfg,data_location)

% This function will create a mask file to be used for the data provided,
% named mask.nii, mask.img, mask+orig.BRIK, mask+tlrc.BRIK (depending on
% the software used), in the location of data_location or - when it is not
% a directory - in the path of the first file passed. It will return the
% location of the file written. 
%
% NB: If you want to use functional data for writing a mask, you can
% certainly pass it using cfg.mask.fileselect. You can pass it in wildcard
% format (e.g. 'rf*.nii') or as a regular expression with 'REGEXP:...'
% (e.g. 'REGEXP:func[0-9]+orig.BRIK').
% NB2: If a mask file already exists at that location and
% cfg.mask.overwrite = 0, the function will throw a warning. 

% Martin Hebart 06/30/2016

% TODO: the automatic approach may be using too much data for creating a
% mask (at least with AFNI)

dispv(1,'Creating mask file...')

% convert location to cell if required
if ~iscell(data_location)
    data_location = num2cell(data_location,2);
end

% basic check
if length(data_location)>1 && any(cellfun(@isdir,data_location))
    error('decoding_create_maskfile was passed multiple files for input, where 1 or more were directories. Currently, we can only deal with one directory or multiple files, not a combination of the two.')
end

% Run depending on software we use
if strfind(lower(cfg.software),'spm')
    
    mask_name = decoding_create_maskfile_spm(cfg,data_location);

elseif strfind(lower(cfg.software),'afni')
      
    mask_name = decoding_create_maskfile_afni(cfg,data_location);
        
else
        
    error('decoding_create_maskfile is currently only supporting SPM and AFNI as software.')
        
end
    
%% THIS IS FOR SPM
function mask_name = decoding_create_maskfile_spm(cfg,data_location)

% if this is fulfilled, we are dealing with a path
if length(data_location) == 1 && isdir(data_location{1})

    % we go through all options from top to bottom
    fnames = [];

    % (a) find all images with a specified selection criterion
    if isfield(cfg,'mask') && isfield(cfg.mask,'fileselect')
        fnames = get_filenames(cfg.software, data_location{1}, cfg.mask.fileselect);
        if isempty(fnames)
            warningv('DECODING_CREATE_MASKFILE_SPM:no_file_found','Could not find any files with selection %s in path %s. Falling back to trying to load beta images from path.',data_location{1},cfg.mask.fileselect)
        end
    end
    % (b) if there is nothing try if it is beta images
    if isempty(fnames)
        fnames = get_filenames(cfg.software, data_location{1}, 'REGEXP:beta_.*\.(nii|img)$');
    end
    % (c) then try loading any nifti or img file
    if isempty(fnames)
        warningv('DECODING_CREATE_MASKFILE_SPM:no_file_found2','Could not find any beta images. Falling back to loading all volumes found at path!')
        fnames = get_filenames(cfg.software, data_location{1}, '.*\.(nii|img)$');
    end
    % (d) then throw error if still not possible
    if isempty(fnames)
        error('Cannot load any files in %s, neither nii/img images with selection nor beta images nor any img/nii files. Cannot create a mask file.',data_location{1})
    end
    
% if it is not a path, it is files, simply pass them
else
    fnames = data_location;
end

if ischar(fnames)
    fnames = num2cell(fnames,2);
end

% check if nii or img mask already exists at that location
fpath = fileparts(fnames{1});
if exist(fullfile(fpath,'mask.nii'),'file') || exist(fullfile(fpath,'mask.img'),'file')
    if isfield(cfg,'mask') && isfield(cfg.mask,'overwrite') && cfg.mask.overwrite
        % do nothing
    else
        warningv('DECODING_CREATE_MASKFILE:OVERWRITING','Overwriting existing mask file in %s',fpath)
    end
end


% get headers
for i_name = 1:length(fnames)
    
    curr_hdr = read_header(cfg.software,fnames{i_name});
    
    if ~exist('hdr','var')
        hdr = curr_hdr;
        continue
    end
    
    hdr(end+1:end+size(curr_hdr),1) = curr_hdr; % this deals with potentially 4D data
    
end

% get orientation matrices
mat = reshape(horzcat(hdr.mat),4,4,numel([hdr.mat])/16);

% check if their orientation is the same
mat_diff = diff(reshape(mat,16,numel(mat)/16),[],2);
tolerance = 32*eps(max(mat(:)));
if any(mat_diff(:) > tolerance)
    if isfield(cfg,'mask') && isfield(cfg.mask,'imagerotation_unequal') && strcmpi(cfg.files.imagerotation_unequal,'ok')
        warningv('DECODING_CREATE_MASKFILE:TRANSFORMMATRIX_DIFFERENT','Rotation & translation matrix of at least two images used for creating mask file is different.\n You selected cfg.files.imagerotation_unequal = ''ok'', i.e. they can differ beyond rounding errors!\n The final results may not be interpretable!!',fname)
    else
        error('Rotation & translation matrix of at least to images used for creating mask file is different.\n The .mat entry defines rotation & translation of the image.\n That some differ means that at least one has been rotated.\n Please use reslicing (e.g. from SPM) to have all images in the same position or IF YOU KNOW WHAT YOU ARE DOING set cfg.files.imagerotation_unequal = ''ok''!')
    end
end

% then load volumes
for i_hdr = length(hdr):-1:1 % if we reverse, we don't need to preallocate
    
    vol(:,:,:,i_hdr) = read_image(cfg.software,hdr(i_hdr));
    
end

% we use a heuristic (similar to SPM): create a mean volume and find where it is larger than 0.6x itself
mask_vol = mean(vol,4) > 0.6 * mean(vol(~isnan(vol)));

% now write
mask_hdr = hdr(1);

[fpath,fn,fext] = fileparts(mask_hdr.fname); %#ok<ASGLU>
mask_hdr.fname = fullfile(fpath,['mask' fext]);
mask_hdr.dt = [2 0]; % make binary mask
mask_hdr.descrip = ['brain mask created with ' num2str(mfilename) ' on' datestr(now)];

write_image(cfg.software,mask_hdr,mask_vol);

mask_name = mask_hdr.fname;

dispv(1,['Written to ' mask_name])



%% THIS IS FOR AFNI
function mask_name = decoding_create_maskfile_afni(cfg,data_location)

% if this is fulfilled, we are dealing with a path
if length(data_location) == 1 && isdir(data_location{1})

    % we go through all options from top to bottom
    fnames = [];

    % (a) find all images with a specified selection criterion
    if isfield(cfg,'mask') && isfield(cfg.mask,'fileselect') && ~isempty(cfg.mask.fileselect)
        fnames = get_filenames(cfg.software, data_location{1}, cfg.mask.fileselect);
        if isempty(fnames)
            warningv('DECODING_CREATE_MASKFILE_AFNI:no_file_found','Could not find any files with selection %s in path %s. Falling back to trying to load all volumes found at path.',data_location{1},cfg.mask.fileselect)
        end
    end
    % (b) then try loading any BRIK file
    if isempty(fnames)
        fnames = get_filenames(cfg.software, data_location{1}, 'REGEXP:.*\.BRIK$');
    end
    % (c) then throw error if still not possible
    if isempty(fnames)
        error('Cannot load any files in %s, neither BRIK files with selection nor any other BRIK files. Cannot create a mask file.',data_location{1})
    end
    
% if it is not a path, it is files, simply pass them
else
    fnames = data_location;
end

if ischar(fnames)
    fnames = num2cell(fnames,2);
end

% check if BRIK mask already exists at that location
fpath = fileparts(fnames{1});
mask_candidates = {'mask+orig.BRIK','mask+tlrc.BRIK'};
for ii = 1:length(mask_candidates)
    if exist(fullfile(fpath,mask_candidates{ii}),'file')
        if isfield(cfg,'mask') && isfield(cfg.mask,'overwrite') && cfg.mask.overwrite
            % do nothing
        else
            warningv('DECODING_CREATE_MASKFILE:OVERWRITING','Overwriting existing mask file in %s',fpath)
        end
    end
end


% get headers
for i_name = 1:length(fnames)
    
    curr_hdr = read_header(cfg.software,fnames{i_name});
    
    if ~exist('hdr','var')
        hdr = curr_hdr;
        continue
    end
    
    hdr(end+1,1) = curr_hdr; %#ok<AGROW>
    
end

% figure out how many volumes we are dealing with in total
n_vol = sum(arrayfun(@(i) hdr(i).dim(4),1:length(hdr)));

% TODO: introduce check that all have the same dimensions

sz = [hdr(1).dim(1:3) n_vol];
vol = zeros(sz);

% then load volumes
ct = 0; % init
for i_hdr = 1:length(hdr) % first loop over headers
    
    volind = ct+1:(ct+hdr(i_hdr).dim(4));
    ct = ct+hdr(i_hdr).dim(4); % update
    % in each header, extract volumes
    vol(:,:,:,volind) = read_image(cfg.software,hdr(i_hdr));
    
end

% we use a heuristic (similar to SPM): create a median volume, from that median volume pick all values larger than 0.6x the median of that volume
mask_vol = mean(vol,4) ~= 0;

% now write
mask_hdr = hdr(1);

% figure out if +orig or _tlrc
% first try with SCENE_DATA
try
    if mask_hdr.SCENE_DATA == 0
        suffix = {'+orig'};
    elseif mask_hdr.SCENE_DATA == 1
        suffix = {'+tlrc'};
    else
        error('jumping to catch');
    end
catch
    [fpath,fn] = fileparts(mask_hdr.RootName); %#ok<ASGLU>
    suffix = regexp(fn,'+(orig|tlrc)','match');
end

if ~any(cellfun(@isempty,strfind({'+orig','+tlrc'},suffix{1}))) % if none of them ends with +orig or +tlrc
    error('Suffix for file to be written is %s. Only +orig or +tlrc currently allowed...',suffix{1})
end

[fpath,fn,fext] = fileparts(mask_hdr.fname); %#ok<ASGLU>
newfname = ['mask' suffix{1}];
mask_hdr.RootName = fullfile(fpath,newfname);
mask_hdr.fname = fullfile(fpath,[newfname '.BRIK']); % it will automatically be renamed to mask+orig.BRIK or mask+tlrc.BRIK depending on the suffix provided in the header

write_image(cfg.software,mask_hdr,mask_vol);

mask_name = mask_hdr.fname;

dispv(1,['Written to ' mask_name])