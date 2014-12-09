%% spmbatch(varargin)
%
% Description:
%
%   Creates and runs SPM5 or SPM8 jobs for multiple subjects. This is done
%   by replacing the paths of all specified files in a template-job 
%   you have to set up for one subject (template-subject) using SPM's
%   job-manager. This works for 1st-level jobs (single subject), where
%   you want to do the same steps for every subject, but not for 2nd-
%   level jobs.
% 
%   Important: Your directory and filename(!) structure must be the same 
%   for the template-subject and all other subjects. So don't include 
%   e.g. subject names in your filenames. If need be, use a batch renaming
%   tool to adjust your filenames. Here's an example of a valid fMRI
%   directory and file structure (try dicom2nifti to get such a 
%   structure):
% 
%   - fMRI_study
%     - subj_1
%       - anatomy
%         - anatomy.nii   
%       - functional
%         - run_001
%           - vol_001.nii
%           - vol_002.nii
%           - ...
%         - run_002
%           - vol_001.nii
%           - vol_002.nii
%           - ...
%     - subj_2
%       - anatomy
%         - anatomy.nii 
%       - functional
%         - run_001
%           - vol_001.nii
%           - vol_002.nii
%           - ...
%         - run_002
%           - vol_001.nii
%           - vol_002.nii
%           - ...
%      - subj_n
%
%   For a quick start proceed as follows:
%   1. Make sure the directory containing spmbatch.m is added to your 
%      Matlab path (Use File->Set Path->Add Folder).
%   2. Create a job (template-job) for one subject (e.g. subj_1) using 
%      SPM's job-manager.
%   3. Type spmbatch in Matlab and hit enter.
%   4. In the browser, select the template-job you have created before.
%   5. Select the subject directory your template-job refers to. (In the
%      above example you would browse to the fMRI_study directory on the
%      left side of the browser and select the subj_1 directory on the 
%      right side).
%   6. Select all subject directories you want the template-job to be
%      applied to. (In the above example you would browse to the fMRI_study 
%      directory on the left side of the browser and select subj_1 to subj_n 
%      on the right side). spmbatch will now create SPM-jobs for your 
%      subjects (subj_1 to subj_n) and run them immediately.
%   
%   If you lack certain images for certain subjects (e.g. you don't have
%   all runs for some subjects) or you need to make slight modifications
%   for every subject (e.g. different onset-times for fmri-model), you 
%   can run spmbatch('run', 'no') to create jobs for those subjects anyway 
%   and then adjust the created jobs manually. Afterwards, use SPM's 
%   util->execute batch jobs to run all your jobs at a single blow.
%
% Optional Arguments:
%
%   Arguments need to be specified as strings in the following way: 
%   spmbatch('parameter', 'value', 'parameter', 'value', ... )
%
%   'run':              Specify whether jobs should be run after 
%                       having been created (values: 'yes', 'no'; 
%                       default: 'yes').
%   'template_job':     Filename of the template-job. (optional, can be 
%                       selected using the SPM file-selector).
%   'find_str':         Directory name of the subject referred to by the
%                       template-job. If you have set up the template-job 
%                       for c:\fMRI_study\subj_1, enter 'subj_1' (that's not 
%                       the whole path, just the parent directory). 
%                       The script will then replace all paths in the template 
%                       job containing 'subj_1' with the new subject's paths. 
%                       (optional, can be selected using the SPM file-
%                       selector). 
%                       In expression mode (see below), 'find_str' is a string 
%                       of any kind you want to have replaced.
%   'replace_str':      String or cell array of strings containing the subject 
%                       paths you wish to create jobs for. Enter e.g. 
%                       {'c:\fMRI_study\subj_1'; 'c:\fMRI_study\subj_2'}. 
%                       (optional, can be selected using the SPM file-
%                       selector).
%                       In expression mode (see below), 'replace_str' are the 
%                       strings you want the 'find_str' to be replaced by. 
%                       For every string specified, a separate job is
%                       created (one specified string will usually be enough).
%   'mode':             Default 'standard': spmbatch will interpret 'find_str'                     
%                       as a template-subject directory and 'replace_str'
%                       as subject directories to which the job should be
%                       applied to. This will work platform independently,
%                       since file separators will be adjusted ( \ <-> / ).
%                       So you can e.g. run jobs in Windows which were created 
%                       in Linux and vice versa.
%                       'expression': This will do an ordinary replacement
%                       of the 'find_str' by one or more 'replace_str'.
%                       Note that only strings are searched, but not e.g.
%                       numbers.
%   'list':             Specify 'yes' if you want spmbatch to list all
%                       replacements in the Matlab command window.
%                       Default: 'no'.
%
% Examples:
%
%   - Call spmbatch in Matlab using the SPM file-selector to specify the arguments:
%     >> spmbatch
%   - Make spmbatch print all path-adjustments on the Matlab command window:
%     >> spmbatch('list', 'yes');
%   - Replace all .nii files specified in a job by .img files:
%     >> spmbatch('run', 'no', 'mode', 'expression', 'list', 'yes', ...
%                  'template_job', 'c:\fMRI_study\templ_subj_1.mat', ...
%                  'find_str', '.nii', 'replace_str', '.img');
%   - Call spmbatch without file-selectors using a template-job created for 
%     c:\fMRI_study\subj_1. This will run jobs for two subjects:
%     >> spmbatch('template_job', 'c:\fMRI_study\templ_subj_1.mat', ...
%                  'find_str', 'subj_1', ...
%                  'replace_str', {'c:\fMRI_study\subj_1', 'c:\fMRI_study\subj_2'});
%        (You can omit the '...' and write everything in one line.)
%
% Note:
%
%   - spmbatch depends on SPM functions, so SPM must be added to your
%     matlab path: File -> Set Path... -> add with subfolders. Make sure SPM 
%     is properly updated (download latest updates from SPM homepage).
%   - spmbatch has been tested on WinXP and Linux with Matlab 7.0, 7.1
%     7.2, and 7.5. Other platforms (e.g.) MacOSX should work as well. Using
%     older Matlab versions than 7.0 may work, but is not recommended.
%     SPM5 and SPM8b are supported currently.
%   - Don't run template-jobs created with SPM5 using SPM8 and vice versa.
%   - If you change the directory structure of your study (e.g. move the data
%     to another server), you can still use the same template-jobs, because 
%     spmbatch ignores the full path (see parameter 'find_str'). 
%     You can also use spmbatch to adjust the paths in your template-jobs to 
%     the new location of your study, if you like.
%   - spmbatch allows for cross-platform use of template-jobs: it is possible 
%     to run e.g. template-jobs created with Windows on a Linux machine, since 
%     the file separators and the study-directory are replaced.
%   - It is advisable to use spmbatch('run', 'no', 'list', 'yes') and inspect 
%     one of the created jobs with the SPM job-manager before running them in 
%     order to make sure all paths are adjusted properly. 
%   - SPM halts when encountering an existing spm.mat file and asks if you
%     want to overwrite it. Make sure you have deleted all spm.mat files from
%     former processing if you want no interruptions while running spmbatch.
%   - If you do e.g. model estimation, you can set up a check registration job  
%     in the template to see if your data is ok. You may want to look at the 
%     mask (mask.img) the contrast image (con*.img) and the image of
%     residual variance (ResMS.img). When running spmbatch, a
%     postcript file (checkreg.ps, in the same directory as template_job) 
%     is created with all the check registration displays. 
%     You have to keep track of the order your jobs are created/processed 
%     on your own (see job-filenames), because SPM doesn't print file 
%     information for check reg. Also note that the template-job doing
%     checkreg shouldn't contain any other job modules after checkreg
%     which overwrite the SPM graphics window, because the graphics window
%     is only printed when the whole job has been run. 
%     checkreg.ps is in black and white to save space (3 times smaller).
%   - Please contact me (Adrian Imfeld) for feedback or bug-reporting.
%   - Distribute spmbatch as you please, but please do not distribute
%     modified versions of spmbatch.
%
% Author:
%
%   (c) 22-Feb-2007 Adrian Imfeld 
%   contact: neurotools@aimfeld.ch
%   web: www.aimfeld.ch/neurotools/neurotools.html
%
% Last updated:
%
%   06-Okt-2010, Adrian Imfeld 
% 
% Version:
%
%   spmbatch v3.3
%
% Version History
%
%   - v3.3: Bugfix: directories (e.g. for "make directory" module) are now
%           properly replaced
%   - v3.2: Bugfix, if subject directory names where e.g. just a number, 
%           being also present later in the path, the string matching 
%           returned a wrong subject directory position.
%   - v3.1: Warnings made compatible with SPM8
%   - v3.0: spm5batch renamed to spmbatch
%   - v2.4b: Support for SPM8b added (may work for future SPM8)
%   - v2.3: Bugfix by requiring the complete path passed to the 'find_str'
%           argument instead of only the template subject directory name.
%           This version was never released because of disadvantages of
%           requiring the whole path (study dir changes, platform changes
%           etc.)
%   - v2.2: Bugfix, find/replace-algorithm does not change file names
%           anymore.
%   - v2.1: Bugfix, structs with length>1 are now processed correctly.
%   - v2.0: Major revision, introducing a recursive search-algorithm. This
%           adds support for any toolboxes.
%   - v1.6: First release on SPM homepage (15-Sep-2007).

function spmbatch(varargin)

version_str = 'v3.3';
SPM_Version = []; % SPM5 or SPM8 (SPM8b gets mapped to SPM8)
job_root = []; % SPM5: 'jobs', SPM8: 'matlabbatch' (root field of SPM job)
global has_checkreg; % for output checkreg.ps
has_checkreg = false;

% Read SPM defaults 
% (prevents Warning: Can't get default Analyze orientation - assuming flipped)
spm_defaults
global defaults
global replacement_cnt; % replacement counter for recursive function

% Display start message
time_message(sprintf('Running spmbatch %s (SPM8 compatible)', version_str));

%%  SPM version check
if exist('spm','file') && ~isempty(spm('Ver', 'spm', true))
    [a, b] = spm('Ver', 'spm', true); % 'SPM5' returned as a, 'SPM8b' returned as b ...
    if strcmp(a, 'SPM5')
        SPM_Version = 'SPM5';
    elseif ~isempty(strfind(b, 'SPM8')) % matches SPM8*
        SPM_Version = 'SPM8';
    else
        error('Wrong SPM version! Required: SPM5, SPM8b, or SPM8');
    end
else
    error('\nThe SPM path is not added to the Matlab search path!');
end 

%% Assign default variable values
run = 'yes'; % values: 'yes', 'no'
template_job = [];
find_str = [];
replace_str = [];
mode = 'standard'; % values: 'standard', 'expression'
list = 'no'; % values: 'yes', 'no'

%% Override variables values by arguments
if mod(length(varargin), 2) ~= 0
    error('Wrong number of input arguments! required: spmbatch(''parameter name'', ''value'', ...)');
end

for n=1:2:length(varargin)
    if strcmp(varargin(n), 'run') 
        if strcmp(varargin(n+1), 'yes') || strcmp(varargin(n+1), 'no')
            run = char(varargin(n+1));
        else
            error('Invalid argument for parameter ''run''.');
        end
    elseif strcmp(varargin(n), 'template_job')
        template_job = char(varargin(n+1));
    elseif strcmp(varargin(n), 'find_str')
        find_str = char(varargin(n+1));
    elseif strcmp(varargin(n), 'replace_str')
        replace_str = varargin{n+1};
        if ischar(replace_str)
            replace_str = {replace_str};
        end
        if ~iscell(replace_str)
            error('Value for ''replace_str'' must be a cell array of strings.')
        end
    elseif strcmp(varargin(n), 'mode')
        if strcmp(varargin(n+1), 'standard') || strcmp(varargin(n+1), 'expression')
            mode = char(varargin(n+1));
        else
            error('Invalid argument for parameter ''mode''.');
        end
    elseif strcmp(varargin(n), 'list')
        if strcmp(varargin(n+1), 'yes') || strcmp(varargin(n+1), 'no')
            list = char(varargin(n+1));
        else
            error('Invalid argument for parameter ''list''.');
        end
    else
        error('Unknown parameter ''%s'', please check spelling.', char(varargin(n)));
    end
end

% Get job template file
if isempty(template_job)
	template_job = spm_select(1,'^*\.mat$','Select spm job template file');
end
if ~exist(template_job, 'file')
	error('Job file %s not found.', template_job);
end

% Load job template, create variable job_root
disp(sprintf('\nLoading template job ''%s'' ...', template_job));
tmpl = load(template_job);
% jobs: SPM5, mattlabbatch: SPM8
if strcmp(SPM_Version, 'SPM5') && isfield(tmpl, 'jobs') 
    job_root = 'jobs';
elseif strcmp(SPM_Version, 'SPM8') && isfield(tmpl, 'matlabbatch') 
    job_root = 'matlabbatch';
else
    error('Invalid %s job template file: %s', SPM_Version, template_job);
end

% Get template subject directory
if strcmp(mode, 'standard') 
    if isempty(find_str)
        find_str = remove_trailing_sep(spm_select(1, 'dir', 'Select template subject directory'));
        if ~exist(find_str, 'dir')
            error('Template subject directory not specified.');
        end
    end
    
    % get last directory name only, e.g. c:\path\subj1 -> subj1
    find_str = get_last_dir(find_str);
    
    % check if subjects specified
    if isempty(replace_str)
        replace_str = spm_select(Inf, 'dir', 'Select subject directories');
    end
    if isempty(replace_str)
        error('No subject directories specified.')
    else    
        replace_str = checkcelldirs(replace_str); % Also does remove_trailing
    end
elseif strcmp(mode, 'expression')
    if isempty(find_str) || isempty(replace_str)
        error('In expression mode, you have to specify ''find_str'' and ''replace_str''.')
    end
end



% Array containing filenames of created jobs for every subject.
jobfiles = {};

% loop over subjects
for i=1:length(replace_str)
    
    disp(sprintf('\nCreating job for ''%s'' ...', replace_str{i}));
    
    % create jobs from template
    replacement_cnt = 0;
    
    jobs = recursive_scan(tmpl.(job_root), find_str, replace_str{i}, mode, list, job_root);
    
    disp(sprintf('\nNumber of replacements: %d', replacement_cnt));
    
    % save job
    [path file] = fileparts(template_job);
    spmbatch_jobs_dir = fullfile(path, 'spmbatch_jobs');
    if ~exist(spmbatch_jobs_dir, 'dir') && ~mkdir(spmbatch_jobs_dir)
        spmbatch_jobs_dir = cd;
    end
    if strcmp(mode, 'standard')
        jobfn = fullfile(spmbatch_jobs_dir, sprintf('%03d_%s_%s_job.mat', length(jobfiles)+1, ...
                         get_last_dir(replace_str{i}), file));
    else
        jobfn = fullfile(spmbatch_jobs_dir, sprintf('expr_%03d_%s_job.mat', length(jobfiles)+1, file));
    end
	
    jobfiles = [jobfiles, {jobfn}];
    % Trick to create root variable 'jobs' for SPM5 or 'matlabbatch' for
    % SPM8. SPM5: jobs = jobs; SPM8: matlabbatch = jobs;
    eval([job_root ' = jobs;']);
    save(jobfn, job_root);
	disp(sprintf('\nSaved job as %s', jobfn));
    
end % of loop over subjects

disp(sprintf('\nFinished: %d of %d jobs successfully created.', length(jobfiles), length(replace_str)));


% Separate creating jobs from running, so error messages for jobs are 
% noticed before running them.
if strcmp(run, 'yes') && ~isempty(jobfiles)
      
    % set up checkreg postscript output file
    if has_checkreg
        %[path name ext] = fileparts(mfilename('fullpath'));
        [path file] = fileparts(template_job);
        checkregfn = fullfile(path, 'checkreg.ps');
        if exist(checkregfn, 'file'), delete(checkregfn); end 
    end
    
    % loop for running all jobs
    for ijob=1:length(jobfiles)       
        disp(sprintf('\nRunning %s ...', jobfiles{ijob}));       
        load(jobfiles{ijob});
        
        % messing with the different job_root for SPM5 and SPM8
        eval(['spm_jobman(''run'', ', job_root ');']); 
     
        % Create postscipt file for check reg. Note that this works only if
        % the checkreg window is not overwritten by another job module
        % (e.g. normalise). Note that '-dpsc2' instead of '-dps2' prints
        % the crosshair in blue, but produces 3 times larger .ps files.
        if has_checkreg
            fg = spm_figure('FindWin', 'Graphics'); 
            print(fg, '-dpsc2', '-append', '-r100', checkregfn);
        end 
        
        disp(sprintf('\n%s finished.', jobfiles{ijob}));   
    end
    
    % print list of processed jobs
    disp(sprintf('\nAll jobs have successfully been run:'));
    for ijob=1:length(jobfiles)
        disp(sprintf('%d: %s', ijob, jobfiles{ijob}))
    end
        
end % of if run

time_message(sprintf('spmbatch %s finished, (c) by Adrian Imfeld', version_str));

end % of main function




% -------------------------------------------------------------------------
% --------------------------- sub-functions -------------------------------
% -------------------------------------------------------------------------

function replaced_field = recursive_scan(field, find_str, replace_str, mode, list, struct_str)
    global has_checkreg;
    replaced_field = field; 
    
    if isempty(field) % field can be an empty cell!
        ;
    elseif isa(field, 'cell') % recursive call for subfields
        for i1=1:size(field, 1) % support up to 3-dimensional cell arrays (probably never more than 1 dimension used)
            for i2=1:size(field, 2)
                for i3=1:size(field, 3)
                    replaced_field(i1, i2, i3) = {recursive_scan(field{i1, i2, i3}, find_str, replace_str, mode, list, struct_str)};
                end
            end
        end
    elseif isa(field, 'struct') % recursive call for subfields
        fns = fieldnames(field);
        for i1=1:length(field)
            for i2=1:length(fns)
                if strcmp(fns{i2}, 'checkreg')
                    has_checkreg = true;
                end
                replaced_field(i1).(fns{i2}) = recursive_scan(field(i1).(fns{i2}), find_str, replace_str, mode, list, [struct_str '.' fns{i2}]);
            end
        end
    elseif isa(field, 'char') % string replacement     
        if ~isempty(field) 
            if size(field, 1) > 1
                warning('%s is a n>1-dimensional char array and will not be searched!', struct_str);
            else
                replaced_field = replace_field(field, find_str, replace_str, mode, list, struct_str);
            end % if size
        end % ~isempty
    end % isa
end % function


function replaced_field = replace_field(field, find_str, replace_str, mode, list, struct_str)
    global replacement_cnt;
    replaced_field = field;
    
    if strcmp(mode, 'standard')
        position = get_subj_dir_position(field, find_str); % exclude file name from search (only path)
        if ~isempty(position) 
            replaced_field = [replace_str field(position:length(field))];
            replaced_field = regexprep(replaced_field, '[\/\\]', filesep); % Platform independency
            if strcmp(list, 'yes')
                disp(sprintf('found   : %s', field));
                disp(sprintf('replaced: %s', replaced_field));
            end
            replacement_cnt = replacement_cnt + 1;
        end
    elseif strcmp(mode, 'expression')
        if ~isempty(regexp(field, find_str, 'once'))
            replaced_field = regexprep(field, find_str, replace_str);
            if strcmp(list, 'yes')
                disp(sprintf('found   : %s', field));
                disp(sprintf('replaced: %s', replaced_field));
            end
            replacement_cnt = replacement_cnt + 1;
        end
    end % if (mode)
    
    % Warning if SPM.mat already exists
    if ~isempty(regexp(struct_str, '.stats.fmri_spec.dir$', 'once' )) || ...
       ~isempty(regexp(struct_str, '.stats.factorial_design.dir$', 'once' ))     
        if exist(fullfile(replaced_field, 'SPM.mat'), 'file')
            warning('%s\nalready exists and will interrupt SPM from processing.\nDelete the file manually to prevent this.', fullfile(replaced_field, 'SPM.mat'));
        elseif ~exist(replaced_field, 'dir') && ~mkdir(replaced_field)  
            warning('Directory %s\nfor SPM.mat could not be created.', replaced_field);
        end
    end
    
    % Warning if SPM.mat already exists (works only for SPM5 at the moment)
    if (~isempty(regexp(struct_str, '.spatial.normalise.est.eoptions.template$', 'once' )) || ...
       ~isempty(regexp(struct_str, '.spatial.normalise.estwrite.eoptions.template$', 'once' ))) && ...
       ~exist(stripcomma(field), 'file')
       warning('Normalisation template %s not found. \nSPM will probably crash if this job is run.', field);
    end

end

function last_dir = get_last_dir(path)
    [dummy last ext] = fileparts(remove_trailing_sep(path));
    last_dir = [last ext];
end

% Determines the position of the path separator after the subject
% directory. By searching for the separator encapsulated subject directory
% name, invalid position matching is prevented (e.g. if the subject
% directory name is just a number, which is also present later in the path
function position = get_subj_dir_position(field, subj_dir)
    [path rest] = fileparts(field);
    if isempty(rest) % Rest is empty if field is a directory
        path = field; % Now path includes the filesep at the end
    end
    position = regexpi(path, ['\\' subj_dir '\\'], 'end'); 
    if (length(position) ~= 1) % If path separator is not Windows, try Unix
        position = regexpi(path, ['\/' subj_dir '\/'], 'end');
    end    
end

% Convert directories to cell string array if necessary and
% check if directories exist.
function celldirs = checkcelldirs(dirs)
	% convert to cell array of strings (does deblanking, too)
    if ~iscellstr(dirs), celldirs = cellstr(dirs);
    else celldirs = dirs; end;

    % clean up subject name, remove trailing space and trailing / or \  
    for i=1:size(celldirs, 1)
        celldirs{i} = remove_trailing_sep(celldirs{i});
        % check if directory exists
        if ~isdir(celldirs{i}) 
            error('Subject directory %s not found.', celldirs{i});
        end
    end
end


% Remove trailing non-alphabetic, numeric, or underscore characters at the end
% of a string. Used to remove / and \ at path-ends.
function rem = remove_trailing_sep(str)
    rem = deblank(str);
    if length(regexp(rem(length(rem)),'\w'))<1
        rem = rem(1:length(rem)-1);
    end
    if isempty(str)
        rem=[];
    else
        rem = deblank(str);
        if length(regexp(rem(length(rem)),'\w'))<1
            rem = rem(1:length(rem)-1);
        end
    end

end

% Determine if jobs contain a checkreg job
% function hc = has_checkreg(jobs)
%     for ijob=1:length(jobs)
%         if isfield(jobs{ijob}, 'util')
%             for iutil=1:length(jobs{ijob}.util)
%                 if isfield(jobs{ijob}.util{iutil}, 'checkreg')
%                     hc = true;
%                     return;
%                 end
%             end  
%         end
%     end
%     hc = false;
% end

% Get rid of the nasty comma part of image files (*.img,1 -> *.img)
function fn = stripcomma(fn)
    if iscell(fn), fn = fn{:}; end
    [path, name, ext] = fileparts(fn);
    comma = strfind(ext, ','); 
    if ~isempty(comma) 
        ext = ext(1:comma-1); 
        fn = fullfile(path, [name ext]);
    end
end

% Prints message with time report
function time_message(message)
    t_head  = sprintf('------------------------------------------------------------------------');
    t_foot  = sprintf('========================================================================');
    try tmp = datestr(now, 'HH:MM:SS - dd/mm/yyyy');
    catch tmp = datestr(now); end % Workaround for old matlab versions
    t_msg(1:length(t_foot)-length(tmp)) = ' '; 
    t_msg(1:length(message)) = message;
    t_msg = [t_msg, tmp];
    fprintf('\n');
    disp(t_head);
    disp(t_msg);
    disp(t_foot);
end

