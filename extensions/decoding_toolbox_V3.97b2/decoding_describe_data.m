% function cfg = decoding_describe_data(cfg,labelnames,labels,regressor_names,beta_loc,xclass)
%
% This functions creates the link between the file names of regressors
% (e.g. beta_0001.img) and its corresponding label name (e.g. button press),
% label number (e.g. -1 or 1) and decoding step number (e.g. run 1). These
% inputs are needed to create a design matrix with all make_design
% functions. Wildcards (*) can be used to include all files matching a part
% of the string (e.g. '*name*' will include all regressor names that contain
% the string 'name', and 'name*' only those regressor names starting with
% 'name').
% If you want to use all conditions and assign labels and run numbers
% automatically, then set labelnames = [] and labels = []. In that case
% each unique regressor name will receive a unique label (-1 and 1 for two
% classes, and 1 to n for n classes), excluding regressors with names R1,
% R2, etc. (e.g. motion regressors or other additional regressors) and
% those with names "SPM constant". Please note that in the automatic case
% you would need to manually add the field xclass if you want to do
% cross-decoding.
%
% INPUT:
%   cfg: configuration file (see decoding.m)
%   labelnames: 1xn cell array, containing all label names used in the SPM
%       design matrix. These are the regressor names that are entered in the
%       first-level analysis and which should serve as basis for the decoding.
%       The wildcard '*' is allowed, e.g. in 't*p'.
%       You can also pass a regular expression (see doc regexp). For this,
%       start the labelname with 'regexp:'. Example:
%           labelnames{1} = 'regexp:^cond1 bin[(1)(2)]$'
%               will find all regressors matching '^cond1 bin[(1)(2)]$'
%
%   labels: 1xn vector containing the label for each labelname, e.g. [-1;1]
%   regressor_names: 2xn or 3xn cell array, containing information about
%       input files.
%       regressor_names is created by the function design_from_spm.
%       It contains for each file in cfg.files (same order):
%           regressor_names(1,:) - Class name from SPM, and bin_ number, if
%               a FIR model or temporal and / or dispersion derivatives
%               were used.
%           regressor_names(2,:) - Run/Session number of regressor.
%           regressor_names(3,:) [OPTIONAL] - Full name of SPM regressor
%   beta_loc: Directory where images are stored that are used for decoding
%       (e.g. beta_0001.img)
%   xclass (optional): Useful for simple cross classification. Assigns
%       separate numbers to each label. The cross classification will go from
%       class 1 to class 2. For classification, an example could look like this:
%       labelnames = {'traininglabelAX','traininglabelBX','testlabelAY','testlabelBY'};
%       labels = [1 -1 1 -1];
%       xclass = [1 1 2 2];
%       In this case, you classify A vs. B (e.g. face vs. house) and want
%       to generalize (cross-classify) from X to Y (e.g. from stimulus left to
%       right). Because you classify A vs. B, your labels will be 1 -1 1 -1
%       (if you want to classify X vs. Y, then they would be 1 1 -1 -1).
%       The vector xclass is just used to keep the cross-classification
%       samples separate.
%
% OUTPUT:
%   Full usable cfg, including all missing entries of cfg from cfg.defaults
%   and especially information about the input files:
%         cfg.files.name: name of each file
%         cfg.files.chunk: run/session number of each file; can be used to
%           keep runs separate for later cross-validation in decoding
%         cfg.files.label: label for each file
%         cfg.files.set: set number for each file
%         cfg.files.xclass: cross-class information for each file (only
%           necessary for cross-class decoding)
%         cfg.files.descr: short text description of the file, normally the
%           regressor names from SPM (more or less)
%
%
% by Martin Hebart 11/06/12
%
% SEE ALSO DESIGN_FROM_SPM

% Update Martin 16/07/05
%   Made compatible with AFNI
%   Renamed beta_dir to beta_loc
% Update Martin 15/04/16
%   Introduced possibility to pass neither label names nor labels and
%   automatically create the corresponding entries for cfg.files.
% Update Kai 13/09/19
%   Introduced the possitility to use regexp directly, when string starts
%   with 'regexp:'
% Update Martin 13/06/12
%   Introduced possibility to use wildcards
% Update Kai, 13/04/16
%   Added files.descr, normally full SPM regressor name
% MH: added cross classification and help file: 11/09/05


function cfg = decoding_describe_data(cfg,labelnames,labels,regressor_names,beta_loc,xclass)

cfg2 = decoding_defaults(cfg); % adds path and gets some required settings (keep separate just in case we don't want to set all fields yet)

cfg.files.name = [];
cfg.files.chunk = [];
cfg.files.label = [];
cfg.files.set = [];
cfg.files.xclass = [];
cfg.files.descr = {}; % contains the regressor names from SPM (more or less)

labels_provided = ~(isempty(labelnames) && isempty(labels));

% check if beta_loc is a directory or a cellstr (in this case, assume it's the name of the input files directly)
if iscellstr(beta_loc)
    dispv(1, 'Data mapping: beta_loc is a cellstr, using these inputs directly for extracting betas.')
    beta_names = beta_loc;
% check if beta_loc is a file (in this case, assume it is a 4D volume containing all files)    
elseif exist(beta_loc,'file') == 2
    dispv(1, 'Data mapping: beta_loc is a file, assuming that it contains 4D volumes.');
    beta_names = {beta_loc};
% else is usual case    
elseif exist(beta_loc,'dir') == 7
    if strfind(lower(cfg2.software),'spm')
        if beta_loc(end) == filesep % prevents some stupid spm_select bug
            beta_loc = beta_loc(1:end-1);
            if beta_loc(end) == ':' % also because of spm_select bug
                error('At current, results cannot be saved in basic directories such as C:\')
            end
        end
        dispv(1, 'getting betas from %s', beta_loc)
        % get image and nii files (BRIK files are not saved as beta files)
        beta_names = get_filenames(cfg2.software,beta_loc,'beta*.img');
        beta_names = [beta_names; get_filenames(cfg2.software,beta_loc,'beta*.nii')];
        
        if isempty(beta_names)
            if isempty(beta_names)
                error('No img/nii-files starting with ''beta'' found in %s',beta_loc)
            end
        end
    else
        error(['Current setting for cfg.software = ''' cfg2.software '''. ' ...
               'This might be because TDT found neither SPM or AFNI_matlab on the path. ',...
               'Alternatively, you were passing a directory as variable ',...'
               'beta_loc, but that is currently only possible with SPM as ',...
               'decoding software (see cfg.software). If you are not using SPM, ',...
               'try passing file names as beta_loc directly or use passed_data ',...
               'as input to pass data directly to TDT (see ''help decoding'''])
    end
else
    error('Data mapping not possible: file or directory passed in variable ''beta_loc'' does not exist.')
end

if ~iscell(beta_names)
    beta_names = num2cell(beta_names,2);
end

%% For each entry in beta_names, check if it is a 4D image and if so expand beta names accordingly
beta_names_orig = beta_names;

beta_names = {}; % re-init

for i_beta = 1:length(beta_names_orig)
    hdr = read_header(cfg2.software,beta_names_orig{i_beta});
    n_subvol = numel(hdr); % this is testing the SPM standard (multiple headers)
    if n_subvol == 1 && length(hdr.dim) > 3 % this is testing the AFNI standard (one header)
        n_subvol = hdr.dim(4);
    end
    % TODO: for other standards, we might need to create separate mapping files (i.e. decoding_describe_data files)
    if n_subvol == 1
        beta_names(end+1,1) = beta_names_orig(i_beta);
    else
        % the following line repeats beta_names_orig{i_beta} and adds 1:n_subvol to each repetition (e.g. ',1' for the first ',2' for the second etc.)
        curr_beta_names = arrayfun(@(i_subvol) [beta_names_orig{i_beta} ',' num2str(i_subvol)] ,1:n_subvol,'uniformoutput',false);
        beta_names(end+1:end+length(curr_beta_names),1) = curr_beta_names;
    end
end
    


%% Typical case
if labels_provided

if length(labelnames) ~= length(labels)
    if length(labelnames)==1 && length(labelnames{1}) == length(labels)
        warningv('DECODING_DESCRIBE_DATA:CELL','Label names were passed as cells in a cell (e.g. {labelnames}), rather than just as a 1xn cell vector. Changing automatically!')
        labelnames = labelnames{1};
    else
        error('Label names have to be of equal size than label numbers!')
    end
end

n_inputs = length(labelnames);
orig_labelnames = labelnames;

for i_input = 1:n_inputs
    
    % check if current labelname starts with 'regexp:'
    if length(labelnames{i_input}) >= length('regexp:') && strcmp('regexp:', labelnames{i_input}(1:length('regexp:')))
        % only remove leading regexp
        labelnames{i_input}(1:length('regexp:')) = [];
    else
        % convert labelnames to regular expression
        labelnames{i_input} = wildcard2regexp(orig_labelnames{i_input});
    end
    
    % Apply regular expression
    ind = regexp(regressor_names(1,:),labelnames{i_input});
    try label_index = ~cellfun(@isempty,ind);
        % catch for users without cellfun
    catch, label_index = zeros(1,length(ind)); for i = 1:length(ind), label_index(i) = ~isempty(ind{i}); end %#ok<CTCH>
    end
    
    
    if ~any(label_index)
        error('Could not find any file associated with label ''%s''. Check input label names (case sensitive!)!',orig_labelnames{i_input})
    end
    cfg.files.name = [cfg.files.name; beta_names(label_index,:)];
    cfg.files.chunk = [cfg.files.chunk cell2mat(regressor_names(2,label_index))];
    cfg.files.label = [cfg.files.label repmat(labels(i_input),1,sum(label_index))];
    if exist('xclass','var')
        cfg.files.xclass = [cfg.files.xclass repmat(xclass(i_input),1,sum(label_index))];
    end
    % also add the regressor name of each of those
    if size(regressor_names, 1) == 3 % full name has been submitted, use this
        for curr_index = find(label_index)
            cfg.files.descr{end+1} = regressor_names{3,curr_index}; % maybe nicer, but not real SPM name: [regressor_names{1,curr_index} '_' int2str(regressor_names{2,curr_index})];
        end
    else
        % create a description that is similar to the original SPM name
        for curr_index = find(label_index)
            cfg.files.descr{end+1} = [regressor_names{1,curr_index} '_' int2str(regressor_names{2,curr_index})];
        end
    end
end

if ischar(cfg.files.name), cfg.files.name = num2cell(cfg.files.name,2); end
cfg.files.chunk = cfg.files.chunk';
cfg.files.label = cfg.files.label';
cfg.files.set = cfg.files.set';
cfg.files.xclass = cfg.files.xclass';

%% if no labels have been provided, automatically fill everything
else
    
    if exist('xclass','var') && ~isempty(xclass)
        error('Cannot deal with input variable xclass when no labels or label names have been provided (enter "help decoding_describe_data" for more details).')
    end        
    
    ind = regexp(regressor_names(1,:),'(^R\d+$|^SPM constant$)');
    try label_index = find(cellfun(@isempty,ind));
        % catch for users without cellfun
    catch, label_index = zeros(1,length(ind)); for i = 1:length(ind), label_index(i) = isempty(ind{i}); end, label_index = find(label_index); %#ok<CTCH>
    end
    
    cfg.files.name = beta_names(label_index,:);
    if ischar(cfg.files.name), cfg.files.name = num2cell(cfg.files.name,2); end
    cfg.files.chunk = [regressor_names{2,label_index}]';
    
    % Loop over all betas to figure out labels, but exclude nuisance regressors
    curr_label = 0;
    labels = zeros(size(cfg.files.chunk));
    orig_index = label_index;
    while 1
        
        if isempty(label_index)
            break
        else
            curr_label = curr_label + 1;
        end
        
        % find all regressors with the same label
        reg_ind = regexp(regressor_names(1,:),regressor_names(1,label_index(1)));
        try curr_ind = find(~cellfun(@isempty,reg_ind));
            % catch for users without cellfun
        catch, curr_ind = zeros(1,length(reg_ind)); for i = 1:length(curr_ind), curr_ind(i) = ~isempty(reg_ind{i}); end, curr_ind = find(curr_ind); %#ok<CTCH>
        end
        
        labels(curr_ind) = curr_label;
        
        % reduce index
        label_index = setdiff(label_index,curr_ind);
        
    end
    labels = labels(orig_index);
    if length(uniqueq(labels))==2
       labels(labels==1) = -1;
       labels(labels==2) =  1;
    end
    cfg.files.label = labels;
        
    % Set other fields
    cfg.files.set = cfg.files.set';
    cfg.files.xclass = cfg.files.xclass';
end 