% inputDir = '.../00ScannerBackup/0215/'; % trailing filesep does not matter
%                                           the last part, e.g., 0215 is used for subject ID
%                                           if it is 's215', will be converted to 0215
% outputDir = '.../01Import/'; % trailing filesep does not matter
% optional inputs:
% autodetect = 1 (default 1); 
    % autodetect func, dti, localizer, anatomical, and renumber func runs
    % if you skip a certain folder, this might not work correctly
% thresholds = {65, 6, 8} % func volumes>=65, 65>dti volumes>=6, localizer slices<=8
% see below for details
%
% bat_dcm2nii(inputDir, outputDir, autodetect);
% after conversion, a nifti-1 file is a 3D file (1 nii = 1 single volume)
% if nii files exist with same name, overwrite without any prompt
% this is for one subject; for multiple subjects, repeat bat_dcm2nii() for another subject
%
% inputDir (search recursively, one subfolder by one)
% -00ScannerBackup
%     -0215 (subject001)
%         -dicom (subfolder)
%             -0101 (5 *.dcm files -> scout/localizer)
%             -0201 (172 *.dcm-files -> 1 anatomical image, 172 slices)
%             -0301 (6016 *.dcm-files -> 188 functional images = run 1)
%             -0401 (9664 *.dcm-files -> 302 functional images = run 2)
%             -0501 (1008 *.dcm-files -> 24 DTI images, 42 slices each)
%             -0601_corrupt (9664 *.dcm-files, skip this folder)
%         -other subfolders but do not have dcm files
%     -0299 (subject00n)
% notice: if the subfolder is 101 as run number, will be converted to 0101 as run number
%
% outputDir if autodetect (anat, dti, func, loc are guessed from # of nii files and header info)
% -01Import  (I made the folder structure flat, folders will be auto created)
%     -S0215_loc (from run 0101)
%     -S0215_anat (from run 0201)
%     -S0215_dti (from run 0501)
%     -S0215_R0001 (func run 1, from 0301)
%     -S0215_R0002 (func run 2, from 0401)
%     -Sxxxs_xxxx (another subject)
%
% outputDir if not autodetect
% -01Import
%     -S0215_R0101
%     -S0215_R0201
%     -S0215_R0301
%     -S0215_R0401
%     -S0215_R0501
%     -Sxxxx_Rxxxx (another subject)
% 
% note: 
%   conversion uses SPM functions; SPM must be added to your matlab path: File -> Set Path... -> add with subfolders. 
%   tested under SPM 12 (with mac lion 10.7.5 and matlab 2012b)
%   if you use dicom2nifti for the first time, consider running only one subject and check the results before processing all 
%
% author = jerryzhujian9@gmail.com
% date: December 10 2014, 11:13:30 AM CST
% inspired by http://www.aimfeld.ch/neurotools/neurotools.html
% https://www.youtube.com/playlist?list=PLcNEqVlhR3BtA_tBf8dJHG2eEcqitNJtw
%

%------------- BEGIN CODE --------------
function [output1,output2] = main(inputDir, outputDir, autodetect, thresholds, email)
% email is optional, if not provided, no email sent
% (re)start spm
spm('fmri')
[dummy, subID] = ez.splitpath(inputDir);
subID = regexp(subID,'\d+','match'); subID = ez.num(subID{1}); subID = sprintf('S%0.4d',subID);
if ~exist('autodetect','var'), autodetect = 1; end
if ~exist('thresholds','var'), thresholds = {65, 6, 8}; end
% func volumes>=65, 65>dti volumes>=6, localizer slices<=8    
func_imgs_threshold = thresholds{1};
dti_imgs_threshold = thresholds{2};   
loc_slices_threshold = thresholds{3};

startTime = ez.moment();
ez.print(['Processing ' subID ' ...']);
% 1) convert
% Find DICOM-files and convert them using SPM
cd(outputDir);
dcm_converted = recursive_convert(inputDir, subID, outputDir);
if dcm_converted == 0, error('No *.dcm files found in the specified input directory.'); end

% 2) rename each nii folder
if autodetect
subDirs = ez.lsd(outputDir,['^' subID '_']);
for i = 1:ez.len(subDirs)
    % track how many functiona runs
    funcRun = 1;
    subDir = ez.joinpath(outputDir, subDirs{i});
    volumes = ez.len(ez.ls(subDir,'\.nii$')) % assume 1 nii = 1 volume

    if volumes >= func_imgs_threshold % functional
        ez.rn(subDir,ez.joinpath(outputDir,sprintf('%s_R%0.2d', subID, funcRun)));
        funcRun = funcRun + 1;
    elseif volumes >= dti_imgs_threshold % DTI
        ez.mv(subDir,ez.joinpath(outputDir,sprintf('%s_dti', subID)));
    elseif min(subID) <= loc_slices_threshold % localizer
        ez.rn(subDir,ez.joinpath(outputDir,sprintf('%s_R%0.2d', subID, funcRun)));
    elseif volumes == 1 % anatomical
        ez.rn(subDir,ez.joinpath(outputDir,sprintf('%s_anat', subID, funcRun)));
    else
        % unknown, retain the folder name
    end % end if
end % end for
end % end if autodetec

% 3) Done message
ez.print(sprintf('Converted %d DICOM-files.\n', dcm_converted));
ez.pprint('****************************************'); % pretty colorful print
finishTime = ez.moment();
if exist('email','var'), try, batmail(mfilename, startTime, finishTime); end; end;
end % of main function


function dcm_converted = recursive_convert(inputDir, subID, outputDir)
    dcm_converted = 0;
    dcm_files = ez.ls(inputDir,'\.dcm$');
    if ~isempty(dcm_files)
        % the name of the immediate folder that has dcm files
        [dummy runNr] = ez.splitpath(inputDir);
        if ~isempty(regexp(runNr, '_\w'))  % skip a dcm files folder with name like '501_corrupt'
            ez.pprint(sprintf('\nSkipping dicom files in subfolder %s', runNr),'magenta');
        else
            ez.print(sprintf('\nFound dicom files in subfolder %s', runNr));
            runNr = regexp(runNr,'\d+','match'); runNr = ez.num(runNr{1}); runNr = sprintf('R%0.4d',runNr);
            P = char(dcm_files); % convert to char required by spm function
            % Open headers
            ez.print(sprintf('Opening %d DICOM-headers (can take some time) ...', length(dcm_files)));
            hdrs = spm_dicom_headers(P);
            % Convert
            ez.print(sprintf('Converting %d DICOM-files (can also take some time) ...', length(dcm_files)));
            niiFolder = ez.joinpath(outputDir, [subID '_' runNr]);
            ez.mkdir(niiFolder);
            cd(niiFolder);
            % save in the working directory
            % if nii files exist with same name, overwrite without any prompt
            spm_dicom_convert(hdrs, 'all', 'flat', 'nii');
            dcm_converted = length(dcm_files);
            cd(outputDir);
        end
    end
    
    %% Recursive call for subdirectories of inputDir
    subDirs = ez.lsd(inputDir);
    for i=1:length(subDirs)
        dcm_converted = dcm_converted + ...
            recursive_convert(ez.joinpath(inputDir, subDirs{i}), subID, outputDir);                
    end
end % end sub-function
%------------- END OF CODE --------------