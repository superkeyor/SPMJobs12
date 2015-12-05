% Create block regressors to calculate betas for each condition for the
% HAXBY 2001 dataset 
%
% Kai, 2014/09/08

% note: subj 5, run 9 (=chunk 8) has only rest condition, so we throw this out

%% very basics
function matlabbatch = level1_ruwise_all_classes(sbj, runjob)

if ~exist('runjob', 'var')
    runjob = 0;
end

%% 
design_name = 'all_runwise';

basedir = '/analysis/kai/haxby01'; % expecting all subject folders here, e.g. subj1/bold.nii + /label.nii;
sbjdir = fullfile(basedir, ['subj' int2str(sbj)]);

%% check that lfiles exists
if ~exist(sbjdir, 'dir')
    error('Directory %s does not exist, please check', sbjdir)
else
    display(sprintf('Using %s', sbjdir))
end


boldfile = fullfile(sbjdir, 'bold.nii'); % expecting 4d nii file
if ~exist(boldfile, 'file'); 
    error('Could not find %s', boldfile)
end

%% read files labels from labels.txt

% the file contains one label for each image
labels_file = fopen(fullfile(sbjdir, 'labels.txt'));
% read first line
l_header = textscan(labels_file, '%s %s', 1);
% read rest
l_data = textscan(labels_file, '%s %f');
% close file again
fclose(labels_file);

%% check that what we read is what we expected and save important info
if ~strcmp(l_header{1}{1}, 'labels') || ~strcmp(l_header{2}{1}, 'chunks')
    error('Wrong header in labels.txt, expected "labels chunks" but got "%s %s"', l_header{1}{1}, l_header{2}{1})
end

if isequal(size(l_data), [1, 2]) && isequal(size(l_data{1}), [1452, 1]) && isequal(size(l_data{2}), [1452, 1])
    display('Data from labels.txt read successfully')
else
    error('Size of read data in labels.txt not as expected')
end
    
%% get block onsets + duration

% categories sorted as described in original paper
% rest taken out, because we dont want an extra regressor for it
categories = {
    'face';    
    'cat';
    'house';
    'chair';
    'scissors';
    'shoe'
    'bottle';
    'scrambledpix';
    % 'rest'; % here, we don't use an extra regressor for rest
    };

%% Start preparing spm mat

%-----------------------------------------------------------------------
% Job saved on 08-Sep-2014 12:01:42 by cfg_util (rev $Rev: 5797 $)
% spm SPM - SPM12b (6080)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
clear matlabbatch

target_dir = fullfile(sbjdir, 'level1', design_name);
if ~exist(target_dir, 'dir')
    mkdir(target_dir)
end

matlabbatch{1}.spm.stats.fmri_spec.dir = {target_dir}; % target directory
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'scans';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 2.5;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;

%% separate into sessions
sess = [];
for sess_ind = 1:12
    % get current images
    curr_img_numbers = [1:121]' + (sess_ind-1)*121;
    % check that this agrees with the chunk label (l_data{2})
    curr_chunk_img_numbers = find(l_data{2} == sess_ind - 1);
    
    if ~isequal(curr_img_numbers, curr_chunk_img_numbers)
        error('Chunk numbers are not as expected, please check')
    end
    
    %% add as images to use
    % add images
    for scan_ind = 1:length(curr_chunk_img_numbers)
        sess(sess_ind).scans{scan_ind} = [boldfile ',', num2str(curr_chunk_img_numbers(scan_ind))];
    end
    % right orientation
    sess(sess_ind).scans = sess(sess_ind).scans(:);
    
    %% Get condition for the current sessino
    curr_conditions = l_data{1}(curr_chunk_img_numbers);
    
    % in each session, specify onset and duration of each condition
    for cond_ind = 1:length(categories)
        curr_cat = categories{cond_ind};
        sess(sess_ind).cond(cond_ind).name = curr_cat;
        
        % find category in condition of current session
        curr_cat_imgs = strcmp(curr_conditions, curr_cat);
        
        % find onset & offset
        % also: if the first image is already the category, add it as onset as
        % well, else add 0 (i.e. simply add the first entry of
        % curr_cat_imgs)
        on_off_sets = [curr_cat_imgs(1); diff(curr_cat_imgs)]; % onsets are 1, offsets are -1
        % also: if the last entry belongs to the image, add a -1 there (simply take the last one *-1)
        % first make sure that the last image is not detected as an onsets
        % (otherwise that's kind of annoying, because then it's on and
        % offset at the same time)
        if on_off_sets(end) == 1
            warning('Last image is on and offset at the same time, thats annoying. Leaving it as it is')
        else
            on_off_sets(end) = curr_cat_imgs(end) * -1;
        end
        
        onsets = find(on_off_sets == 1);
        offsets = find(on_off_sets == -1);
        if on_off_sets(end) == 1
            % also adding the same as offset, so duration for this will be
            % set to 0
            offsets(end+1) = onsets(end);
        end
        if length(onsets) ~= length(offsets)
            error('Different amount of onsets and offsets found, please check')
        end
        
        % set onsets + durations (in TR units)
        sess(sess_ind).cond(cond_ind).onset = (onsets - 1); % is this really the image index in volumes?
        sess(sess_ind).cond(cond_ind).duration = (offsets - onsets);
        
        % other parameters for cond
        sess(sess_ind).cond(cond_ind).tmod = 0;
        sess(sess_ind).cond(cond_ind).pmod = struct('name', {}, 'param', {}, 'poly', {});
        sess(sess_ind).cond(cond_ind).orth = 1;
        
    end
    
    % other parameter for session
    sess(sess_ind).multi = {''};
    sess(sess_ind).regress = struct('name', {}, 'val', {});
	sess(sess_ind).multi_reg = {''};
	sess(sess_ind).hpf = 128;
end

matlabbatch{1}.spm.stats.fmri_spec.sess = sess;

% other paramters
matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
matlabbatch{1}.spm.stats.fmri_spec.mask = {''}; % would be cool to have the mask implicit
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';

%% remove run 9 for subj 5 because:
% "note: subj 5, run 9 (=chunk 8) has only rest condition"

if sbj == 5
    display('Removing Session 9 for subj 5, because this only has rest as condition')
    
    % make sure that really everything is empty here
    sess9 = matlabbatch{1}.spm.stats.fmri_spec.sess(9);
    for cond_ind = 1:length(sess9.cond)
        if ~isempty(sess9.cond(cond_ind).onset)
            error('expected an empty regressor for subj 5, session 9, but onset contains entries for condition %s. If this is the rest condition, please decide if you want to remove it or not (most likely yes). Otherwise this is strange')
        end
    end
    
    matlabbatch{1}.spm.stats.fmri_spec.sess = matlabbatch{1}.spm.stats.fmri_spec.sess([1:8, 10:end]);
end
   
%% run matlabbatch
if runjob
    % add path to spm
    addpath('/analysis/kai/spm/spm12b');
    % start
    spm fmri
    % run
    spm_jobman('run', matlabbatch)
end