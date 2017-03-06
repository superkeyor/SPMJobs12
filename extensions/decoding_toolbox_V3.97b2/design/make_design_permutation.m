% function [designs, all_perms] = make_design_permutation(cfg,n_perms_select,combine)
%
% This function creates designs for a number of label permutations carried
% out at the decoding level for a full permutation test, but importantly
% allowing to keep data from different decoding chunks (e.g. runs)
% separate. If all data are exchangeable, a full permutation test can be 
% run setting cfg.permute.exchangeable = 1;
%
% Instead of generating the designs from an existing design, the
% designs are created from scratch. To use the same decoding scheme
% as in the non-permuted data, the name of the original design creation
% function must be provided  (e.g. make_design_cv.m). If no such function
% was used, you may want to create one first to recreate the
% design creation steps for the permutations (otherwise this function would
% not have sufficient information to create the permuted designs).
% Alternatively, use 'make_design_cv' and use the second output of this
% function 'all_perms' for the label permutations.
%
% In many cases, the number of permutations is limited, i.e. an exhaustive
% permutation test can be performed. To improve numerical precision, the
% function first selects a set of unique permutations within each chunk
% from all possible permutations (which may nevertheless have the same
% label combination, i.e. they are unique in the ordering of labels, not in
% the result of the permutation). Later, the permutations are then combined
% across chunks and possibly only a subset is selected. Picking unique
% permutations allows for faster convergence of p-values.
%
% For two-class classification, the labels can be used symmetrically. For
% that reason, the actual possible number of permutations may be half of
% those expected. (there are special cases where the number is even
% smaller, but it would be difficult to account for them all). The function
% may remove this symmetry if it is computationally feasible which may
% reduce the number of possible permutations and speed up processing. 
%
% Using multiple sets is not supported, because permutations can be
% calculated separately for each set and then combined using combine_designs.
%
% If data has a xclass variable, permutations are done within each unique 
% xclass x chunk combination.
%
% INPUT:
%   cfg: configuration struct variable that was used for the original
%     decoding analysis. In fact, mainly the contents of cfg.files are
%     needed which can be created automatically or manually
%     (see decoding_tutorial.m). In addition, the field
%     cfg.design.function.name is needed which contains the name of the
%     design creation function.
%   n_perms_select: Number of permutations that should be created. If
%       n_perms_select exceeds the number of possible permutations, then
%       the maximum number of permutations will be created. If
%       n_perms_select is not provided or empty, the function displays the
%       number of available permutations and terminates with empty output.
%       Can either be an integer number or the string 'all', in which case
%       all available permutations will be selected (please check the
%       number in advance, though!)
%   combine (optional input): 1 or 0. If selected, the designs are combined
%       into one large design where each iteration is treated as a
%       different set. This has the advantage of in total preventing the
%       need to reload all data for each permutation and also that
%       identical training data does not need to be re-trained. The
%       disadvantage is that for large data sets it can run out-of-memory 
%       faster. Also, it may be difficult to parallelize if you run
%       analyses on a cluster. For regular output (e.g. accuracy) and 1000
%       searchlight permutations, it should work well.
%
%   IMPORTANT NOTE: The inputs n_perms_select and combine can also be
%       passed as fields of cfg, in the form of
%       cfg.permute.n_perms_select
%       and
%       cfg.permute.combine
%   This has the advantage that the function can in principle also be
%   passed for design creation purposes (although it is unclear when this
%   is useful, since this function requires the field
%   cfg.design.function.name to be different than make_design_permutation)
%
%   ADDITIONAL FIELD: cfg.permute.exchangeable (default: 0) if non-zero,
%       assuming exchangeable data and permuting all labels
%
% OUTPUT:
%   design: 1xn cell matrix of permutation designs that are created by
%       this function. These can be filled into the cfg by setting
%       cfg.design = design{k} where k is the index of the requested
%       design.
%   all_perms (optional): n_samples x n_permutations matrix of permuted
%       labels that respect the dependencies assumed in the data
%
% Example (running all permutations separately)
%   cfg = decoding_describe_data(cfg,{labelname1 labelname2},[1 -1],regressor_names,beta_loc); % see decoding tutorial for details
%   cfg = rmfield(cfg,'design'); % this is needed if you previously used cfg.
%   cfg.design.function.name = 'make_design_cv';
%   n_perms = 1000;  % pick a reasonable number, the function might compute less if less are available
%    combine = 0;
%   designs = make_design_permutation(cfg,n_perms,combine);
%   for i_perm = 1:n_perms
%       cfg.design = designs{i_perm};
%       cfg.results.dir = ['C:\yourresults\perm' sprintf('%04d',i_perm)];
%       decoding(cfg); % run permutation
%   end
%
% Example (running all permutations in one)
%   cfg = rmfield(cfg,'design'); % this is needed if you previously used cfg.
%   cfg.design.function.name = 'make_design_cv';
%   cfg.permute.n_perms_select = 'all';
%   cfg.permute.combine = 1;
%   cfg.design = make_design_permutation(cfg);
%   decoding(cfg);
%
% Example for leave-one-out CV where all samples are independent
%   cfg.design.function.name = 'make_design_cv';
%   cfg.permute.n_perms_select = 1000;
%   cfg.permute.exchangeable = 1; % no within-chunk dependencies
%   cfg.permute.combine = 1;
%   cfg.design = make_design_permutation(cfg);
%   decoding(cfg);
%

% Martin Hebart, 2013/08/31

% Version History:
%   MH (2016/09/12):
%   - Enabled use of designs without within-chunk dependence (i.e.
%     exchangeable data under the null, with setting
%     cfg.permute.exchangeable)
%   - Removed bug that disallowed designs with extremely many possible
%     permutations
%   - Removed bug that would remove symmetric permutations in too many
%     cases (if not all chunks contained all labels)
%   - Provide optional output all_perms if not using any design creation
%     function, but just requiring permuted labels
%   KG (2016/06/21):
%   - Added compatibility for designs with multiple xclasses and multiple
%     chunks, e.g. for xclasses cv. Permutations were before done for each
%     chunk ignoring that different xclasses are for this purpose multiple
%     chunks (because permutations must be done for each chunk for each 
%     xclasses independently).
%   MH (2014/10/26):
%   - Removed bug in npermk and improved use
%   MH (2014/08/21):
%   - Removed bug that prevented the use of this function for simple
%   leave-one-pair out
%   MH (2014/08/04):
%   - Allowed passing chunks with a lot of samples
%   - Enabled combination of designs
%   - Added option to run only subset of permutations
%   - Replaced unique permutations by all permutations (otherwise biases
%       are possible)

% TODO: also for more than two labels a symmetry might exist (e.g. when
% interchanging label 1 with label 2, and label 2 with label 3 etc.). This
% reduces the number of possible permutations, but is not implemented, yet.
%

function [design, all_perms] = make_design_permutation(cfg,n_perms_select,combine)

fn = 'make_design_permutation';
fv = 'v20160912';

design = [];
% if there are more than max_n_perms possible combinations, only sample some of them.
max_n_perms = 10^8; % (this is probably how much should be ok with memory)
max_n_perms_chunk = 10000; % more permutations per chunk probably don't make sense

if isfield(cfg,'design') && isfield(cfg.design,'set') && length(unique(cfg.design.set)) > 1
    error('Only designs with one set variable (cfg.design.set) are allowed (see help!) If you already created the permutation design previously, please call cfg = rmfield(cfg,''design''); and set the other fields again.')
end

try
    if strcmpi(cfg.design.function.name,'make_design_permutation')
        error('cfg.design.function.name shouldn''t be ''make_design_permutation'', but in fact any other existing function that serves as basis for permutations. See help make_design_permutation for details.')
    end
catch
    error('Non-existent field ''cfg.design.function.name''. Need an official design creation function (e.g. ''make_design_cv'', see help make_design_permutation for details)')
end

if ~exist('combine','var')
    try % check if field has been passed
        combine = cfg.permute.combine;
    catch
        combine = 0;
    end
end

try
    cfg.permute.exchangeable;
catch
    cfg.permute.exchangeable = 0; % assume chunks are not independent
end

warningv('MAKE_DESIGN_PERMUTATION:beta_stage','This function is still in beta modus. Execute with necessary care!')

if nargin > 1
    dispv(1,'Creating permutation designs...')
end

%% Handle multiple xclass values

if isfield(cfg.files, 'xclass') && length(unique(cfg.files.xclass)) > 1
    % If decoding is performed for different xclasses, permutations are
    % allowed within each chunk for each xclass. 
    % To compute this, this is the same as if we had different chunks for 
    % different xclasses. Thus, we change the chunk vector here to have one 
    % chunk per unique xclass x chunk combination. The original chunk 
    % vector is restored before creating new designs, because it is only 
    % needed to create the permuted labels.
    n_xclass = length(unique(cfg.files.xclass));
    warningv('make_design_permutation:xclass', 'make_design_permutation: The xclass variable contains more than one value (%i xclasses). Permuting labels within each unique chunk x xclass combination independently. Please remove the xclass variable if you do not use a xclass design. For details, see explanation in %s', n_xclass, mfilename);
%     if ~exist('org_chunk', 'var') % only if we did not already store it before
        org_chunk = cfg.files.chunk;
%     end
    % The easiest way to get unique labels is just to put the xclass
    % infront of the chunk, potentially adding 0s. As an extreme example:
    % xclass 15 for chunk 100 would be 15100, or for chunk 1 (if 100
    % chunks exist) 15001.
    % To make sure we do not run into problems with negativ chunks, we set
    % the smallest chunk value to 1
    xclass_chunks = cfg.files.chunk;
    xclass_chunks = xclass_chunks - min(xclass_chunks) + 1;
    % get number of digits we need for the chunks (e.g. 3 if the max chunk
    % value is >= 10
    next_chunk_power = 10 ^ floor(log(max(xclass_chunks)));
    % get unique value for each combination
    xclass_chunks = (cfg.files.xclass * next_chunk_power) + xclass_chunks;
    % and finally we use this as chunk for this function
    cfg.files.chunk = xclass_chunks;
end

orig_chunk = cfg.files.chunk; % store this for when we actually write the designs
% In this case run permutations as if there was only one chunk (overwriting the above setting)
if cfg.permute.exchangeable
    cfg.files.chunk = ones(size(cfg.files.chunk));
end

%% Get values

all_chunks = unique(cfg.files.chunk);
all_labels = unique(cfg.files.label);
n_chunks = length(all_chunks);
n_perms_chunk = zeros(1,length(all_chunks));
n_chunk_labels = zeros(n_chunks,1);

%% First calculate how many permutations are possible

for i_chunk = 1:n_chunks
    
    curr_chunk = all_chunks(i_chunk);
    
    % Get labels of current chunk
    chunk_labels = cfg.files.label(cfg.files.chunk == curr_chunk);
% This deactivated code calculated only unique permutations (which would lead to wrong estimates if some repetitions are more frequent than others)
%     n_samples = length(chunk_labels);
%     unique_chunk_labels = unique(chunk_labels);
%     n_labels_chunk = length(unique_chunk_labels);
%     
%     % This function works with more labels than 2 (for which nchoosek would be used)
%     n_perms_chunk(i_chunk) = number_uniqueperms(chunk_labels,unique_chunk_labels,n_labels_chunk);
    n_perms_chunk(i_chunk) = factorial(length(chunk_labels));
    
    n_chunk_labels(i_chunk) = length(chunk_labels);

end

% The number of permutations is the product of all permutations
n_perms_orig = prod(n_perms_chunk);

if n_perms_orig <= 1
    error('With the current settings, there is only one possible permutation (probably you have one sample per chunk). This function by default assumes no exchangeable chunks. Possibly, you may want to assume that all data are exchangeable, i.e. set cfg.permute.exchangeable = 1;')
end

% If total number of labels is 2 and they are present in all chunks, then divide n_perms by 2 (because we could flip all labels)
if length(all_labels) == 2 && all(n_chunk_labels==2)
    n_perms = n_perms_orig/2;
else
    n_perms = n_perms_orig;
end

if ~exist('n_perms_select','var')
    try
        n_perms_select = cfg.permute.n_perms_select;
    catch %#ok<*CTCH>
        disp(['Number of possible permutations for input data: ' num2str(n_perms)])
        disp('Design not created, yet!')
        try design = cfg.design; end %#ok<TRYNC>
        return
    end
end

% Check if number of requested permutations exceeds number of possible permutations
if ischar(n_perms_select)
    if strcmpi(n_perms_select,'all')
        n_perms_select = n_perms;
    else
        error('Unknown string variable %s entered for the number of permutations!',n_perms_select)
    end
end

if n_perms < n_perms_select
    warningstr = sprintf('Number of requested permutations %.0f exceeds number of possible permutations %.0f. ',n_perms_select,n_perms);
    warningstr = [warningstr sprintf('Using maximum number of available permutations!')];
    warningv('MAKE_DESIGN_PERMUTATION:toomanyperms',warningstr);
    n_perms_select = n_perms;
end

if max_n_perms_chunk^n_chunks<n_perms_select
    warningstr = sprintf(['Number of selected permutations would be larger than the number of ',...
         'permutations that can be generated, due to the cut-off introduced to the ',...
         'maximum number of permutations per chunk (%5.0f). Adjusting the maximum number. ',...
         'If you want to escape this warning in the future, adapt the maximum number in the function.'],max_n_perms_chunk);
    warningv('MAKE_DESIGN_PERMUTATION:conflict_n_perms',warningstr);
    max_n_perms_chunk = ceil(n_perms_select^(1/n_chunks));
end


if n_perms <= max_n_perms
    
    % Now get all possible permutations within each chunk
    chunk_perms = cell(1,n_chunks);
    perm_indices = cell(1,length(all_chunks));
    
    for i_chunk = 1:n_chunks
        
        curr_chunk = all_chunks(i_chunk);
        chunk_labels = cfg.files.label(cfg.files.chunk == curr_chunk);
        chunk_perms{i_chunk} = perms(chunk_labels);
        % The code below calculates only the unique permutations
%         chunk_perms{i_chunk} = uniqueperms(chunk_labels);
        
        perm_indices{i_chunk} = 1:n_perms_chunk(i_chunk);

    end
    
    % Now combine permutations across chunks
    all_perms = zeros(n_perms_orig,length(cfg.files.label));
    
    % Get row indices of all combinations using ndgrid
    all_ind = cell(1,length(perm_indices));
    [all_ind{:}] = ndgrid(perm_indices{:});
    for i_chunk = 1:length(all_ind)
        all_ind{i_chunk} = all_ind{i_chunk}(:);
    end
    % rows are permutations, columns are chunks
    all_ind = cell2mat(all_ind);
    
    % Now fill all_perms by picking the appropriate row (in a for-loop)
    for i_chunk = 1:n_chunks
        curr_chunk = all_chunks(i_chunk);
        
        curr_row_ind = all_ind(:,i_chunk);
        curr_row = chunk_perms{i_chunk}(curr_row_ind,:);
        all_perms(:,cfg.files.chunk == curr_chunk) = curr_row;
    end
    
    % If two labels, then remove symmetry if it is worth it
    if length(all_labels) == 2 && all(n_chunk_labels==2) && size(all_perms,1) < 10000
        
        dispv(1,'Removing symmetric permutations (this may take a while depending on the number of iterations...)')
        
        original = all_perms;
        inverted = zeros(size(original));
        inverted(original==all_labels(1)) = all_labels(2);
        inverted(original==all_labels(2)) = all_labels(1);
        
        remove_ind = false(size(all_perms,1),1);
        for i_iter = 1:size(all_perms,1)
            if any(remove_ind==i_iter)
                continue
            end
            tmp = all(repmat(original(i_iter,:),size(all_perms(i_iter:end,:),1),1)==inverted(i_iter:end,:),2);
            tmp = [zeros(i_iter-1,1); tmp]; %#ok<AGROW>
            remove_ind = remove_ind|tmp;
        end
        
        all_perms(remove_ind,:) = [];
        
    end
    
    % Flip all_perms
    all_perms = all_perms';
    
    % Pick requested subset of number of permutations (if all are selected,
    % this is also fine)
    pick_ind = 1:n_perms;
    if n_perms_select < n_perms
        pick_ind = pick_ind(randperm(length(pick_ind)));
        pick_ind = pick_ind(1:n_perms_select);
        pick_ind = sort(pick_ind);
    end
    
else % in case that number of permutations is very large, calculate only a random subset
    
    % Get all possible permutations within each chunk if the number is not
    % too large (i.e. if in all chunks the number of permutations does not exceed max_n_perms_chunk)
    if all(n_perms_chunk<=max_n_perms_chunk)

        chunk_perms = cell(1,n_chunks);
        
        for i_chunk = 1:n_chunks
            
            curr_chunk = all_chunks(i_chunk);
            chunk_labels = cfg.files.label(cfg.files.chunk == curr_chunk);
            chunk_perms{i_chunk} = perms(chunk_labels);
        % The code below calculates only the unique permutations            
%             chunk_perms{i_chunk} = uniqueperms(chunk_labels);
            
        end
        
    else % otherwise calculate subset only
        
        % replace n_perms_chunk
        n_perms_chunk(:) = max_n_perms_chunk;
        
        chunk_perms = cell(1,n_chunks);
        
        for i_chunk = 1:n_chunks
            
            curr_chunk = all_chunks(i_chunk);
            chunk_labels = cfg.files.label(cfg.files.chunk == curr_chunk);

            if ~isinf(n_perms_orig)
                
                rp = randpermk(n_perms_orig,n_perms_chunk(i_chunk));
                
                % there will be numerical imprecision for any rp>10e15
                if all(rp<10^15)
                    % TODO: this is most often a lot slower, but is guaranteed to finish
                    p = permk(length(chunk_labels),rp(1:max_n_perms_chunk));
                else % this is much faster for small k, but may take forever for large length(k)
                    p = urandperm(length(chunk_labels),max_n_perms_chunk);
                end
                
            else % if there are so many unique permutations anyway, we can also just randomly sample
                
                [trash,p] = sort(rand(max_n_perms_chunk,length(chunk_labels)),2); %#ok<ASGLU>
                
            end
            
            chunk_perms{i_chunk} = chunk_labels(p);
        
        end
    end
    
    % Now combine permutations across chunks
    all_perms = zeros(n_perms_select,length(cfg.files.label));
    
    % Now fill all_perms by randomly sampling once from each chunk
    for i_perm = 1:n_perms_select
        for i_chunk = 1:n_chunks
            curr_chunk = all_chunks(i_chunk);
            curr_row = chunk_perms{i_chunk}(randi(n_perms_chunk(i_chunk)),:);
            all_perms(i_perm,cfg.files.chunk == curr_chunk) = curr_row;
        end
    end
    
    % Flip all_perms
    all_perms = all_perms';
    
end
   
%% Create new designs with permuted data

% restore the original before setting all chunks to 1
cfg.files.chunk = orig_chunk;

% Restore original chunk vector if it has been replaced for xclass before
if exist('org_chunk', 'var')
    dispv(2, 'make_design_permutation: Replacing cfg.files.chunk with original chunk labels.');
    cfg.files.chunk = org_chunk;
end

% And do it
fhandle = str2func(cfg.design.function.name);
design = cell(n_perms_select,1);

for i_perm = 1:n_perms_select
    if exist('pick_ind', 'var') % this is the case if few permutations are possible
        cfg.files.label = all_perms(:,pick_ind(i_perm));
    else
        cfg.files.label = all_perms(:,i_perm); % this is the case if many permutations are possible
    end
    design{i_perm} = feval(fhandle,cfg); % THIS IS WHERE THE DESIGN FUNCTION IS APPLIED
end
        
%% combine designs
        
if combine
    design_orig = cell2mat(design);
    n_steps_orig = size(design_orig(1).label,2);
    design = struct;
    design.function = design_orig(1).function;
    design.function.permutation.name = fn;
    design.function.permutation.ver = fv;
    design.label = horzcat(design_orig.label);
    design.set = kron(1:n_perms_select,ones(1,n_steps_orig)); % make multiple sets out of it
    design.train = horzcat(design_orig.train); 
    design.test = horzcat(design_orig.test);
    if isfield(cfg,'results') && isfield(cfg.results,'setwise') && cfg.results.setwise ~= 1
        warningv('MAKE_DESIGN_PERMUTATION:SETWISE','cfg.results.setwise = 0. Please make sure to set it to 1 before running the permutation design.')
    else
        disp('Combining designs. Please make sure cfg.results.setwise = 1 and remains that way before running the permutation design.')
    end
end

%% done
disp('done.')



%% Subfunctions
%-------------
function output = number_uniqueperms(chunk_labels,unique_chunk_labels,n_labels) %#ok<DEFNU>

n_samples_per_label = zeros(1,n_labels);
for i_label = 1:n_labels
    n_samples_per_label(i_label) = sum(chunk_labels == unique_chunk_labels(i_label));
end
n_samples_per_label = sort(n_samples_per_label);

% Updated this from Ged Ridgway's uperms function to prevent overflow
output = prod(n_samples_per_label(end)+1:sum(n_samples_per_label)) / prod(factorial(n_samples_per_label(1:end-1)));

%--------------
function output = uniqueperms(input)

input = input(:);
input_length = length(input);

unique_input = unique(input);
number_unique = length(unique_input);

if isempty(input)
    output = [];
elseif number_unique == 1
    output = input';
elseif input_length == number_unique
    output = perms(input);
else
    output = cell(number_unique,1);
    for i = 1:number_unique
        v = input;
        ind = find(v == unique_input(i),1,'first');
        v(ind) = [];
        temp = uniqueperms(v);
        output{i} = [repmat(unique_input(i),size(temp,1),1) temp];
    end
    output = cell2mat(output);
end

%--------------
function p = randpermk(n,k)

% randomly pick a subset of unique random numbers (the capability exists in
% later Matlab versions)

% The easiest case is if Matlab has the new randperm function
try %#ok<TRYNC>
    p = randperm(n,k);
    return
end

if k>10^8
    error(['Function allows a maximum of 10^8 picked numbers to prevent memory overflow. ',...
        'If you have more memory available, please change the maximum in the function.'])
end

% For small numbers, we can use the old randperm function
if n<=10^8
    p = randperm(n);
    p = p(1:k);
    return
end

if k>0.9*n
    warningv('RANDPERMK:runlonglargek','This function will run very long for so many iterations. Consider getting smaller k...')
end

% For large numbers, we cannot explicitly calculate all possible permutations, so we need an iterative method

p = uniqueq(ceil(n*rand(round(1.5*k),1))); % start off filling more than we need and later reducing the size if necessary
sz = size(p,1);

if sz>=k
    p = p(1:k);
    p = p(randperm(size(p,1)))';
    return
end

while sz < k
    p = uniqueq([p; ceil(n*rand(round(1.5*k),1))]);
    sz = size(p,1);
    if sz>=k
        p = p(1:k);
        p = p(randperm(size(p,1)))';
        return
    end
end
    

%--------------
function p = permk(n,k)

% TODO: in the future make the order the same as the output of perms, which
% would be ideal for comparability (i.e. rearrange things internally)

nk = length(k);
p = zeros(nk,n);
newind = zeros(n,1);

% maxp = factorial(n);
% 
% if any(k>maxp)
%     error('Number of available permutations: %.0f . k must be a subset of this number.',maxp)
% end

x = cell(n,1);
[x{:}] = ind2sub(n:-1:1,k); % for very large k, this can yield rounding errors
x{end} = ones(1,nk); % must be ones only

for j = 1:nk
    % here are the numbers we would like to distribute
    ind = (1:n)';
    % the first number picks from any of these, then the index is made smaller
    for i = 1:n
        newind(i) = ind(round(x{i}(j)));
        ind(ind==newind(i)) = []; % TODO: speed this loop up in the future
    end
    p(j,:) = newind;
end

%--------------
function p = urandperm(n,k)

% pick random subset k of unique permutations with length n (actually pick more to speed up process)

p = [];
sz = -inf;

while sz < k
    [ignore,q] = sort(rand(round(1.5*k),n),2); %#ok<ASGLU> % like randperm, but multiple times
    p = [p;q]; %#ok<AGROW>
    [ignore,ind] = unique(p,'rows','first');  %#ok<ASGLU> % get unique entries
    p = p(sort(ind),:); % re-sort everything not to get a bias (introduces bottleneck!)
    
    sz = size(p,1);
    
    if sz>=k
        t = randperm(k);
        p = p(t,:); % shuffle again
        p = p(1:k,:);
        return
    end
end