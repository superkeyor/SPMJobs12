% function [results, cfg] = decoding_example_afni(decoding_type,labelname1,labelname2,beta_loc,output_dir,radius,cfg)
%
% We don't recommend using this for editing! Use decoding_template instead.
%
% This is a general function for two class classification with AFNI, using
% a linear SVM as implemented in the libsvm software, with accuracy images
% (for searchlight) or variables (for ROI or wholebrain) as output. All 
% variables that are not specified in the input will be set automatically 
% in the function.
% Important: Deconvolutions must have been completed for every run separately.
%
% INPUT:
% decoding_type: determines decoding method ('searchlight','ROI', or 'wholebrain')
% labelname1: name of first label (e.g. 'button left')
% labelname2: name of second label (e.g. 'button right')
% beta_loc: Multiple options:
%               (1) empty or path only: Will open a pop-up to select files containing deconvolutions for each run
%               (2) Cell array of file names containing deconvolutions for each run 
%               (3) Use an asterisk in the file path to select a subset of
%               files with similar names which are only different by one or
%               more numbers (e.g. '/misc/data/result*+orig.BRIK' for
%                   '/misc/data/result1+orig.BRIK','/misc/data/result2+orig.BRIK',
%                   etc.)
%
% OPTIONAL:
% output_dir: Where results should be saved (if they should be saved at all)  
% radius: for decoding_type 'searchlight', you may specify the radius of
%   the searchlight (in voxels).
% cfg: If a cfg is provided, these values will be used when starting the
%   example. However, all values that are specified by the other parameters
%   will overwrite this (use this e.g. if you want different than the 
%   standard default settings).
% ROI-files: If you want to specify ROI files, set 
%   cfg.files.mask = {'ROI1+orig.BRIK', 'ROI2+orig.BRIK'} % etc
%
% OUTPUT:
%   results: the results
%   cfg:     the cfg created in the example (can be use for decoding(cfg) )
%
% See also DECODING DECODING_EXAMPLE

% 2016/07/07 Martin H.

% History:
% MH 2016/07/09 Fixed small bug

function [results, cfg] = decoding_example_afni(decoding_type,labelname1,labelname2,beta_loc,output_dir,radius,cfg)

warningv('DECODING_EXAMPLE_AFNI:BETA_MODE','decoding_example_afni is still in beta mode, use with care...')

if ~exist('cfg', 'var')
    cfg = [];
else
    display('Using default arguments provided by cfg')
end

if ~exist('beta_loc','var'), beta_loc = ''; end
if ~exist('output_dir','var'), output_dir = ''; end

cfg = decoding_defaults(cfg);

cfg.testmode = 0;
cfg.analysis = decoding_type;
cfg.decoding.train.classification.model_parameters = '-s 0 -t 0 -c 1 -b 0 -q'; % linear classification
cfg.software = 'afni';

if ~isempty(output_dir)
    cfg.results.dir = output_dir;
else
    str1 = 'Written to file / brain image';
    str2 = 'Matlab variable in Workspace';
    switch questdlg('How would you like the output?', ...
            'Decoding Example', ...
            str1,str2,...
            str1)
        case str1
            mother_dir = uigetdir(pwd, 'Pick base directory for saving results (next step: create results directory here)');
            cfg.results.dir = fullfile(mother_dir,inputdlg(sprintf(...
                'Enter new directory name for saving results to as a subfolder to %s (leave empty if you have selected the correct directory already):',mother_dir),'Decoding Example',1));
        case str2
            cfg.results.write = 0;
    end
end

if ischar(beta_loc) % Convert to cell
    beta_loc = num2cell(beta_loc,2);
    if isempty(beta_loc), beta_loc{1} = ''; end
end

% Select deconvolution files using beta_loc
if isempty(beta_loc{1})
    
    % If no path or file provided
    [fname,fpath] = uigetfile('*.BRIK', 'Select deconvolution files for each run', 'Multiselect', 'on');
    if isnumeric(fname) && fname == 0, disp('Quitting decoding_example_afni.m ...'), return, end


elseif isdir(beta_loc{1})
    
    % if it is a directory, cd to that directory for faster selection and then back
    cwd = pwd; cd(beta_loc{1})
    [fname,fpath] = uigetfile('*.BRIK', ...
        'Select deconvolution files for each run', 'Multiselect', 'on');
    cd(cwd)
    if isnumeric(fname) && fname == 0, disp('Quitting decoding_example_afni.m ...'), return, end
    
    
elseif exist(beta_loc{1},'file')
    
    % if it is one or more files
    beta_loc = cellfun(@strtrim,beta_loc,'uniformoutput',0);
    fname = cellfun(@dir,beta_loc);
    fpath = fileparts(beta_loc{1});
    
    
elseif length(beta_loc) == 1 && any(strfind(beta_loc{1},'*'))
    
    % if the asterisk method is used, this can deal with a lot of possible ways of entering data
    [fpath,fn,fext] = fileparts(beta_loc{1});
    if ~isdir(fpath), error('Path %s not found.',fpath); end
    ffn = [fn fext];
    ffn = wildcard2regexp(ffn);
    ffn = strrep(ffn,'.*','\d.*');
    fname = get_filenames(cfg.software,fpath,['REGEXP:' ffn]);
    if isempty(fname), error('No files with wildcard search %s%s found in %s.',fn,fext,fpath), end
    fname = num2cell(fname,2);
    % Remove filepath and rejoin fname and fext
    [fp,fname,fext] = cellfun(@fileparts,fname,'uniformoutput',0);
    fname = arrayfun(@(i) [fname{i} strtrim(fext{i})],1:length(fname),'uniformoutput',0)';

else
    
    % else throw an error
    error('File in %s doesn''t exist.',beta_loc{1})
end

% Add file separator to end of fpath
if fpath(end) ~= filesep
    fpath(end+1) = filesep;
end

% convert to struct
if iscell(fname)
    for i_cell = 1:length(fname)
        fname_(i_cell,1).name = fname{i_cell}; %#ok<AGROW>
    end
    fname = fname_;
end

% fill beta_loc if required
if isempty(beta_loc{1}) || isdir(beta_loc{1}) || any(strfind(beta_loc{1},'*'))
    beta_loc = [repmat(fpath,length(fname),1) vertcat(char(fname.name))];
    beta_loc = num2cell(beta_loc,2);
end


% Now toggle between options
switch lower(decoding_type)
    
    case 'searchlight'
        
        if ~exist('radius','var') || isempty(radius)
            warning('Variable ''radius'' wasn''t specified. Using default value %d',cfg.searchlight.radius); %#ok<WNTAG>
        else
            cfg.searchlight.radius = radius;
        end
        cfg.searchlight.unit = 'voxels';
        
        % Get brainmask (see subfunction at bottom)
        cfg.files.mask = get_brainmask(cfg,fpath,fname);
        
        % cfg.plot_selected_voxels = 100; % activate to plot searchlights
        
    case 'roi'
        
        if isfield(cfg, 'files') && isfield(cfg.files, 'mask') && ~isempty(cfg.files.mask)
            display('Using provided mask as ROIs')
        else % show file picker to select ROIs
            cwd = pwd;
            cd(fpath)
            [fnames,fpath] = uigetfile('*.BRIK', 'Select your ROI masks', 'Multiselect', 'on');
            cd(cwd)
            
            if ~iscell(fnames)
                if fnames ~= 0
                    cfg.files.mask = fullfile(fpath,fnames);
                else
                    error('No file was selected')
                end
            else
                if ~strcmp(fpath(1,end),filesep), fpath = [fpath filesep]; end
                cfg.files.mask = [repmat(fpath,2,1) vertcat(char(fnames{:}))];
            end
        end
        
        cfg.plot_selected_voxels = 1;
        
    case 'wholebrain'
        
        [fp,fn,suffix,ext] = tdt_fileparts(fname(1).name); %#ok<ASGLU>
        
        % Get brainmask (see subfunction at bottom)
        cfg.files.mask = get_brainmask(cfg,fpath,fname);
        
end

if exist('output_dir','var') && ~isempty(output_dir)
    cfg.results.dir = output_dir;
end

% get regressor names
regressor_names = design_from_afni(beta_loc);
    
% extract regressors with labelname1 and labelname2, including run number
% make sure that labels 1 and 2 are uniquely assigned
cfg = decoding_describe_data(cfg,{labelname1 labelname2},[-1 1],regressor_names,beta_loc);

% assign these values to the standard matrix and create the matrix
cfg.design = make_design_cv(cfg);

% cfg.results.output = {'AUC_minus_chance'}; % activate for alternative output

% run results = decoding(cfg)
[results, cfg] = decoding(cfg);



%% Subfunction

function maskfname = get_brainmask(cfg,fpath,fname) % Use mask in data path as brain mask
 
% Check if mask has been passed
if isfield(cfg,'files') && isfield(cfg.files,'mask') && exist(cfg.files.mask,'file')
    maskfname = cfg.files.mask;
    fprintf('Using mask provided with cfg.files.mask:\n%s\n',cfg.files.mask)
    return
end

% See if simple mask exists
[fp,fn,suffix,ext] = tdt_fileparts(fname(1).name); %#ok<ASGLU>
maskfname = fullfile(fpath,['mask' suffix ext]);
        
if exist(maskfname,'file')
    fprintf('Using mask found in data directory:\n%s\n',maskfname)
    return
end

% Ask for mask or create one
q = questdlg('Do you have a brain mask or would you like to create one automatically?','Decoding Example','Locate existing','Create new','Create new');
switch lower(q)
    case 'create new'
        % This will select only those files specified
        for i = 1:length(fname), fname(i).nameinv = fname(i).name(end:-1:1); end
        c = char(fname.name);
        c_ = char(fname.nameinv);
        d = find(any(diff(c)));
        d_ = find(any(diff(c_)));
        cfg.mask.fileselect = [c(1,1:d(1)-1) '.*' c_(1,d_(1)-1:-1:1)];
        maskfname = decoding_create_maskfile(cfg,fpath);
    case 'locate existing'
        cwd = pwd;
        cd(fpath) % search in fpath
        maskfname = uigetfile('*.BRIK', 'Select your mask file');
        cd(cwd) % go back
    otherwise
        disp('Quitting decoding_example_afni.m ...'), return
end