% function regressor_names = design_from_afni(brik_files,save_on)
% 
% This function will extract the relevant information for the current
% decoding from an AFNI BRIK file that contains multiple coefficient maps
% with different names. This information is the names and location of the
% coefficient files and the corresponding run number. It will save
% regressor_names.mat to the path of the first BRIK file.
%
% INPUT:
% brik_files: The names of all BRIK files to use. One is sufficient if all
%   BRIKs are guaranteed to have the same structure (i.e. same name and
%   order of all subbricks). Else this function will test that they are
%   actually the same. If a path name is passed, all BRIK files in that
%   path will be used in alphabetical order, assuming they correspond to the different runs.
% save_on (optional, default = 1): Should regressor names be saved or not.
%
% OUTPUT:
% regressor_names: a 3-by-n cell matrix.
% regressor_names(1, :) -  shortened names of the BRIK files
% regressor_names(2, :) - experimental run/session of each regressors
% regressor_names(3, :) - full name of the AFNI BRIK files
%
% by Martin Hebart 2016/06/30
%
% See also DESIGN_FROM_SPM DECODING_DESCRIBE_DATA

% History:
% 2017-02-05: replaced strsplit with regexp for downward compatibility

function regressor_names = design_from_afni(brik_files,save_on)

if ~exist('save_on','var'), save_on = 1; end

% convert to cell if char
if ischar(brik_files)
    brik_files = {brik_files};
end

% check if brik_files is a path, if so, get all brik_files in that path
if isdir(brik_files{1})
    brik_files = get_filenames(cfg.software,brik_files{1},'.*\.BRIK');
    brik_files = num2cell(brik_files,2); % convert string to cell
    brik_files = cellfun(@strtrim,brik_files,'uniformoutput',false); % remove training spaces in each cell
end
    
% get directory of first brik
brik1_dir = fileparts(brik_files{1});
regressor_file = fullfile(brik1_dir,'regressor_names.mat');

% check if they all exist (excluding trailing whitespaces)
brik_files = cellfun(@strtrim,brik_files,'uniformoutput',0);
brik_existing = cellfun(@exist,brik_files);
if ~all(brik_existing)
    % display the ones that don't exist
    disp('Non-existent BRIK files:')
    disp(brik_files(~brik_existing))
    error('Some BRIK files that have been specified and that were passed to design_from_afni do not exist, please check!')
end

n_brik = length(brik_files);

% Code below deactivated, because multiple deconvolutions in one path
% possible and thus unclear which files were used (difficult to solve this
% with a cell output)

% % Check for existence of regressor_names
% if exist(regressor_file,'file')
%     % Check also if date of regressor names is younger than that of the briks
%     d = arrayfun(@(i_brik) dir(brik_files{i_brik}),1:n_brik);
%     brik_date = max([d.datenum]); % get the youngest of all briks
%     d = dir(regressor_file);
%     regressor_date = d.datenum;
%     if regressor_date>brik_date
%         load(regressor_file)
%         return; % no need to recompute regressor names
%     end
% end

% Now load all headers of the BRIK files (treat each one as a run)
hdr = read_header('afni',brik_files{1});
labels_concat = hdr.BRICK_LABS;
labels = regexp(labels_concat,'~','split');
if isempty(labels{end}), labels(end) = []; end % remove empty
% Check if all have the same labels
for i_brik = 2:n_brik
    hdr = read_header('afni',brik_files{i_brik});
    labels_concat = hdr.BRICK_LABS;
    labels_ = regexp(labels_concat,'~','split');
    if ~isequal(labels,labels_)
        disp('Problem occurred!')
        disp('Labels of run 1:')
        disp(labels)
        disp(['Labels of run ' num2str(i_brik) ':'])
        disp(labels_)
        warning('DESIGN_FROM_AFNI:MISMATCH_LABELS','There is a mismatch in the label names between runs. This does not have to be a problem, but may be.')
    end
end
        
regressors = repmat(labels,1,n_brik);

% Row 1: regressor names, row 2: run numbers, row 3: original regressor names as in BRIK file
regressor_names = cell(3,length(regressors));

% Set run numbers
regressor_names(2,:) = num2cell(kron(1:n_brik,ones(1,length(labels))));
% Set original regressor names
regressor_names(3,:) = repmat(labels,1,n_brik);

% Number of basis function (e.g. for HRF all are 0, for FIR from 0 to n-1 [we convert counting to Matlab format 1:n])
bf_numbers = NaN(1,length(labels)); 

ct = 0;
while 1 % keep looping until no more hits
    % get bf number
    searchstr = ['#' num2str(ct) '_'];
    f = strfind(labels,searchstr);
    f_ind = ~cellfun(@isempty,f);
    if ~any(f_ind), break, end
    labels = strrep(labels,[searchstr 'Coef'],''); % remove '#0_Coef' from labels
    labels = strrep(labels,searchstr(1:end-1),''); % remove '#0' from all remaining labels
    bf_numbers(f_ind) = ct+1; % the basis function index for Matlab is always one larger
    ct = ct+1; % increase counter
end

% increase for repetition
bf_numbers = repmat(bf_numbers,1,n_brik);

% Set names
regressor_names(1,:) = repmat(labels,1,n_brik);


% Check if all basis functions are the same, if not include string 'bin 1' etc. after each name
bf = bf_numbers(~isnan(bf_numbers));
unique_bf = unique(bf);
if length(unique_bf) > 1
    for i = 1:length(regressors)
        if ~isnan(bf_numbers(i))
            regressor_names{1,i} = [regressor_names{1,i} ' bin ' num2str(bf_numbers(i))];
        end
    end
end

if save_on
    % save to get regressors quicker
    save(regressor_file,'regressor_names')
end

