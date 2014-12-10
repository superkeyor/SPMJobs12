% inputDir = 'd:\studyraw\s00001\dicom';
% outputDir = 'e:\mystudy\s00001';
% bat_dcm2nii('dicom_dir', inputDir, 'subject_dir', outputDir, 'autodetect', 'yes', 'renumber_func_runs', 'yes');
% this is for one subject, for multiple subjects, repeat bat_dcm2nii() for another subject
% after conversion, a nifti-1 file is a 3D file (=1 single volume)
%
% from (search dicom_dir recursively, one subfolder by one)
% %   - c:\studyraw
%     - subj_1
%       - dicom
%         - 1.2.840...141
%           - 1.2.840...424 ( 6016 *.dcm-files -> 188 functional images = run 1)
%           - 1.2.840...522 ( 9664 *.dcm-files -> 302 functional images = run 2)
%           - 1.2.840...620 ( 1008 *.dcm-files -> 24 DTI images, 42 slices each)
%           - 1.2.840...718 ( 172 *.dcm-files -> 1 anatomical image, 172 slices)
%      - subj_2
%        - dicom ...
%      - ... 
% to (create subfolders/subsubfolders in subject_dir automatically if not existing)
% anat, dti, func, loc are basically guessed from # of nii files
% - e:\mystudy
%     - subj_1              ('subject_dir')
%       - anat              ('anat_dir')
%         - anatomy.nii     ('anat_fn')
%       - dti               ('dti_dir')
%         - dti_01.nii      ('dti_prefix', 'dti_digits')   
%         - ...
%         - dti_24.nii         
%       - func              ('func_dir')
%         - run_001         ('run_dir_naming', 'run_dir_prefix', 'run_dir_digits')
%           - vol_001.nii   ('func_prefix', 'func_digits')
%           - ...
%           - vol_188.nii
%         - run_002
%           - vol_001.nii
%           - ...
%           - vol_302.nii
% modified by Jerry December 09 2014, 03:33:35 PM CST
% downloaded from http://www.aimfeld.ch/neurotools/neurotools.html
% orignial author tested spm8, Jerry tested spm12 with matlab2012b, mac10.7.5 lion
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%
%% dicom2nifti(varargin)
%
% Description:
%   
%   Converts DICOM-files (.dcm) to NIfTI-files (.nii or .img/.hdr). A specified 
%   directory (dicom_dir) and its subdirectories are searched for DICOM-files. 
%   These files will then be converted to NIfTI format using SPM functions. 
%   The NIfTI-files will be properly named, moved to a target-directory 
%   (subject_dir) and sorted in subdirectories according to their type 
%   (anatomical, functional, DTI, localizer). Automatic type detection can
%   be disabled if it's not properly working (see below).
%
% Quick start example:
% 
%   Let's say your DICOM-files are organized as follows: 
%   - c:\my_study
%     - subj_1
%       - dicom
%         - 1.2.840...141
%           - 1.2.840...424 ( 6016 *.dcm-files -> 188 functional images = run 1)
%           - 1.2.840...522 ( 9664 *.dcm-files -> 302 functional images = run 2)
%           - 1.2.840...620 ( 1008 *.dcm-files -> 24 DTI images, 42 slices each)
%           - 1.2.840...718 ( 172 *.dcm-files -> 1 anatomical image, 172 slices)
%      - subj_2
%        - dicom ...
%      - ... 
%
%   Proceed as follows:
%   1. Make sure the directory containing dicom2nifti.m is added to your 
%      Matlab path (Use File->Set Path->Add Folder).
%   2. Create a new M-file in Matlab.
%   3. Write a line of code for every subject, e.g.:
%        dicom2nifti('dicom_dir', 'c:\my_study\subj_1\dicom', 'subject_dir', 'c:\my_study\subj_1');
%        dicom2nifti('dicom_dir', 'c:\my_study\subj_2\dicom', 'subject_dir', 'c:\my_study\subj_2');
%        ...
%      However, if you use dicom2nifti for the first time, consider running only 
%      one subject and check the results before processing all your subjects. Note 
%      that the directory 'subject_dir' will be created by dicom2nifti if it 
%      doesn't exist yet.  
%   4. Save the M-file and run it (by pressing F5).
%
%   After a few hours, you'll end up with the following (specify the additional 
%   parameters in brackets to change the file-names and directory-names according 
%   to your preferences):
%   - c:\my_study
%     - subj_1              ('subject_dir')
%       - dicom             ('dicom_dir', remains unchanged)
%       - anat              ('anat_dir')
%         - anatomy.nii     ('anat_fn')
%       - dti               ('dti_dir')
%         - dti_01.nii      ('dti_prefix', 'dti_digits')   
%         - ...
%         - dti_24.nii         
%       - func              ('func_dir')
%         - run_001         ('run_dir_naming', 'run_dir_prefix', 'run_dir_digits')
%           - vol_001.nii   ('func_prefix', 'func_digits')
%           - ...
%           - vol_188.nii
%         - run_002
%           - vol_001.nii
%           - ...
%           - vol_302.nii
%
% Optional Arguments:
%
%   Arguments need to be specified as strings in the following way: 
%   dicom2nifti('parameter', 'value', 'parameter', 'value', ... )
%
%   'dicom_dir':                DICOM-directory, subdirectories are also
%                               searched for DICOM-files. Specify it, if you 
%                               don't want to use the browser.
%   'subject_dir':              Subject-directory. Specify it, if you don't 
%                               want to use the browser. If the specified 
%                               directory doesn't exist yet, it will be 
%                               created.
%   'format':                   'nii': Single file NIfTI format (default)
%                               'img': two file (hdr+img) NIfTI format                              
%   'autodetect':               Autodetect will try to determine volume
%                               types (anatomical, functional, dti, 
%                               localizer) and put them into accordingly
%                               named subdirectories after conversion. If
%                               disabled, all volumes will be put in
%                               subdirectories named by their run number.
%                               Disable autodetect if it doesn't work
%                               properly with your data.
%                               'yes': autodetect on (default)
%                               'no': autodetect disabled
%   'renumber_func_runs':       Specify if you want to renumber functional
%                               runs to 1..n when using autodetect. 
%                               Otherwise, original run numbers will be
%                               kept.
%                               'yes': renumber to 1..n (default)
%                               'no': keep original run numbers.
%
% Note:
%
%   - dicom2nifti depends on SPM functions, so SPM must be added to your
%     matlab path: File -> Set Path... -> add with subfolders. Make sure SPM is
%     properly updated (download latest updates from SPM homepage).
%   - All arguments (also numbers) must be specified as strings! 
%     i.e., should use '100' instead of 100
%   - dicom2nifti has been tested on WinXP and Linux with Matlab 7.0, 7.1
%     7.2, and 7.5. Other platforms (e.g.) MacOSX should work as well. Using
%     older Matlab versions than 7.0 may work, but is not recommended.
%   - Please contact me (Adrian Imfeld) for feedback or bug-reporting.
%   - Distribute dicom2nifti as you please, but please do not distribute
%     modified versions of dicom2nifti.
%   - Thanks to Cyrill Ott and Sylvie Pantano for testing.
%
% Author:
%
%   (c) 26-Feb-2007 Adrian Imfeld
%   contact: neurotools@aimfeld.ch
%   web: www.aimfeld.ch/neurotools/neurotools.html
%
% Last updated:
%
%   09-Jun-2010, Adrian Imfeld 
% 
% Version:
%
%   dicom2nifti v3.1
%
% Version History
%
%   - v3.1: Error message if no *.dcm files were found
%   - v3.0: Completely refactored: more flexibility (dicom files of 
%           separate runs don't have to be located in separate 
%           subdirectories anymore)
%   - v2.0: Support for SPM8b added (may work for future SPM8)
%   - v1.8: Minor tweaks and renaming of dicom2analyze to
%           dicom2nifti.
%   - v1.7: Bugfix of datestr (dicom2nifti may work on
%           Matlab 6.5 now).
%   - v1.6: First release on SPM homepage (15-Sep-2007) .

function dicom2nifti(varargin)

version_str = 'v3.1';
SPM_Version = []; % SPM5 or SPM8 (SPM8b gets mapped to SPM8)

%%  SPM version check
if exist('spm','file') && ~isempty(spm('Ver', 'spm', true))
    [a, b] = spm('Ver', 'spm', true); % 'SPM5' returned as a, 'SPM8b' returned as b ...
    if strcmp(a, 'SPM5')
        SPM_Version = 'SPM5';
    elseif ~isempty(strfind(b, 'SPM8')) % matches SPM8*
        SPM_Version = 'SPM8';
    elseif strcmp(b, 'SPM12')
        SPM_Version = 'SPM12';    
    else
        error('Wrong SPM version! Required: SPM5, SPM8b, SPM8, or SPM12');
    end
else
    error('\nThe SPM path is not added to the Matlab search path!');
end 

%% Assign default variable values
dicom_dir = [];
subject_dir = [];
format = 'nii';
autodetect = 'yes';
renumber_func_runs = 'yes';
anat_dir = 'anat';
dti_dir = 'dti';
func_dir = 'func';
loc_dir = 'loc';
func_imgs_threshold = 65; % If number of volumes in a run is bigger -> functional, else DTI
dti_imgs_threshold = 6;   
loc_slices_threshold = 8; % If one dimension is less -> localizer

%% Override variables values by arguments
if mod(length(varargin), 2) ~= 0
    error('Wrong number of input arguments! required: (''variable name'', ''value'') ...');
end

for n=1:length(varargin)
    if ~ischar(varargin{n})       
        error('All parameters and values must be passed as strings using quotes ('''').')
    end
end
for n=1:2:length(varargin)
    if strcmp(varargin(n), 'dicom_dir')
        dicom_dir = char(varargin(n+1));
    elseif strcmp(varargin(n), 'subject_dir')
        subject_dir = char(varargin(n+1));
    elseif strcmp(varargin(n), 'format')
        validate_param(varargin(n), varargin(n+1), {'nii', 'img'});
        format = char(varargin(n+1));
    elseif strcmp(varargin(n), 'autodetect')
        validate_param(varargin(n), varargin(n+1), {'yes', 'no'});
        autodetect = char(varargin(n+1));        
    elseif strcmp(varargin(n), 'renumber_func_runs')
        validate_param(varargin(n), varargin(n+1), {'yes', 'no'});
        renumber_func_runs = char(varargin(n+1));
    else
        error('Unknown parameter ''%s'', please check spelling.', char(varargin(n)));
    end
end

%% Running message
time_message(sprintf('Running dicom2nifti %s', version_str));

%% Check input and output directories   
if isempty(dicom_dir)
    dicom_dir = remove_trailing_sep(spm_select(1, 'dir', 'Select directory with DICOM files'));
end
if ~exist(dicom_dir, 'dir')
    error('%s is no valid directory.', dicom_dir);
end


if isempty(subject_dir)
    subject_dir = remove_trailing_sep(spm_select(1, 'dir', 'Select subject directory for converted files'));
    if ~exist(subject_dir, 'dir')
        error('Subject directory not specified.');
    end
end
% Create subject output directory, if neccessary
if ~exist(subject_dir, 'dir') && ~mkdir(subject_dir)
    error('Could not create subject directory %s.', subject_dir);
end

% Create temporary directory
temp_dir = fullfile(subject_dir, 'd2n_temp');
if exist(temp_dir, 'dir')
    rmdir(temp_dir, 's'); % delete old temporary files
end
if ~mkdir(temp_dir)
    error('Temporary directory %s could not be created.', temp_dir);
end

%% Find DICOM-files and convert them using SPM
dcm_converted = recursive_convert(dicom_dir, subject_dir, temp_dir, format);
if dcm_converted == 0
    error('No *.dcm files found in the specified directory.', temp_dir);
end
                   
% Get information from converted files in temp dir
img_files = dir(fullfile(temp_dir, ['*.' format]));
fns = strvcat(img_files.name);
fns = [char(ones(size(fns,1),1)*[temp_dir, filesep]) fns];
volumes = spm_vol(fns);

% Get run and number from file name
for i=1:length(img_files)
    [p fn ext] = fileparts(img_files(i).name);
    volumes(i).run_number = str2double(fn(length(fn)-19:length(fn)-16));
    volumes(i).vol_number = str2double(fn(length(fn)-8:length(fn)-3));
    volumes(i).name = fn;
end

% Sort volumes by vol and run number
[tmp ind] = sort([volumes.vol_number]);
volumes = volumes(ind);
[tmp ind] = sort([volumes.run_number]);
volumes = volumes(ind);

% Count volumes within runs
for iRun=1:max([volumes.run_number])
    run_volume_cnt(iRun) = sum([volumes.run_number] == iRun);
end


%% Rename converted files and move them to their target directories
fprintf('\nOrganizing images (run/volume):            ');

is_functional_run = zeros(1, length(run_volume_cnt)); 
for iRun=1:length(run_volume_cnt)
    run_vols = volumes([volumes.run_number] == iRun);
    for iVol=1:length(run_vols)
        fprintf('\b\b\b\b\b\b\b\b\b\b\b%04d/%06d', iRun, iVol);
        
        if strcmp(autodetect, 'no')
            target_dir = fullfile(subject_dir, sprintf('run_%0.4d', iRun));            
            target_fn = sprintf('vol_%0.4d', iVol);            
        elseif strcmp(autodetect, 'yes')            
            if length(run_vols) >= func_imgs_threshold % functional
                is_functional_run(iRun) = 1;
                if strcmp(renumber_func_runs, 'yes')
                    target_dir = fullfile(subject_dir, func_dir, sprintf('run_%0.4d', sum(is_functional_run)));
                elseif strcmp(renumber_func_runs, 'no')
                    target_dir = fullfile(subject_dir, func_dir, sprintf('run_%0.4d', iRun));
                end
                    target_fn = sprintf('vol_%0.4d', iVol);
            elseif length(run_vols) >= dti_imgs_threshold % DTI
                target_dir = fullfile(subject_dir, dti_dir);
                target_fn = sprintf('dti_%0.4d', iVol);
            elseif min(run_vols(iVol).dim) <= loc_slices_threshold % localizer
                target_dir = fullfile(subject_dir, loc_dir);
                target_fn = sprintf('loc_%0.4d', iVol);
            elseif length(run_vols) == 1 % anatomical
                target_dir = fullfile(subject_dir, anat_dir);
                target_fn = 'anatomy';
            else % unknown
                target_dir = fullfile(subject_dir, sprintf('%0.4d', iRun));            
                target_fn = sprintf('vol_%0.4d', iVol);
            end
        end
                
        if ~exist(target_dir, 'dir')
            mkdir(target_dir);
        end

        % Move images
        exts = {'.nii'};
        if strcmp(format, 'img')
            exts = {'.img' '.hdr'};
        end
        for iext=1:length(exts)
            source_ffn = fullfile(temp_dir, [run_vols(iVol).name, exts{iext}]);
            target_ffn = fullfile(target_dir, [target_fn, exts{iext}]);
            movefile(source_ffn, target_ffn);
        end 
        
    end
end

fprintf(' done.\n');
rmdir(temp_dir, 's'); % temp_dir should be empty by now.
    

%% End message
disp(sprintf('\ndicom2nifti converted %d DICOM-files.\n', dcm_converted));
time_message(sprintf('dicom2nifti %s, (c) by Adrian Imfeld.', version_str));

end % of main function


function dcm_converted = recursive_convert(dicom_dir, subject_dir, temp_dir, format)
    
    dcm_converted = 0;
    disp(sprintf('\nLooking for DICOM-files in %s ...', dicom_dir));
    dicom_files = dir(fullfile(dicom_dir, '*.dcm'));

    if ~isempty(dicom_files)        

        P = strvcat(dicom_files.name);
        P = [char(ones(size(P,1),1)*[dicom_dir, filesep]) P];

        cwd = pwd;
        if strcmp(cwd, temp_dir)
            cwd = subject_dir;
        end
        cd(temp_dir);

        % Open headers
        disp(sprintf('\nOpening %d DICOM-headers (can take some time) ...', length(dicom_files)));
        hdrs = spm_dicom_headers(P);

        % Convert
        disp(sprintf('\nConverting %d DICOM-files (can also take some time) ...', length(dicom_files)));
        % spm_dicom_convert(hdrs);
        spm_dicom_convert(hdrs, 'all', 'flat', format);

        cd(cwd);
        
        dcm_converted = length(dicom_files);
    end
    
    %% Recursive call for subdirectories of dicom_dir
    disp(sprintf('\nLooking for subdirectories ...'));
    d = dir(dicom_dir);
    for i=3:length(d) % Skip . and ..
        if d(i).isdir
            dcm_converted = dcm_converted + ...
                recursive_convert(fullfile(dicom_dir, d(i).name), subject_dir, temp_dir, format);                
        end
    end
end

% Remove trailing non-alphabetic, numeric, or underscore characters at the end
% of a string. Used to remove / and \ at path-ends.
function rem = remove_trailing_sep(str)
    if isempty(str)
        rem=[];
    else
        rem = deblank(str);
        if length(regexp(rem(length(rem)),'\w'))<1
            rem = rem(1:length(rem)-1);
        end
    end
end

% Check if a valid value has been specified for a parameter 
function validate_param(param, value, valid_values)    
    param = char(param);
    value = char(value);
    valid_string = sprintf('''%s'',', valid_values{:});
    valid_string(end) = '';
    if sum(strcmp(value, valid_values)) == 0
        error('''%s'' is an invalid argument for parameter ''%s''.\nValid values are: %s. ', value, param, valid_string);
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
