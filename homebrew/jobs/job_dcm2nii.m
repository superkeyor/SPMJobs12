% inputDirs = {'.../00ScannerBackup/00215/';
%              '.../00ScannerBackup/00216/';}; 
%                                           trailing filesep does not matter
%                                           the last part, e.g., 00215 is used for subject ID (00215-->0215)
%                                           if it is 's215', will be converted to 0215
%                                           each inputDir for one subject
% outputDir = '.../01Import/'; % trailing filesep does not matter
% optional inputs:
% autodetect = 1 or 0 (default 1); 
%   autodetect func, dti, localizer, anatomical, and renumber func runs
%   if you skip converting a certain (corrupted) dicom folder, this might not work correctly
% keep = [], an array
%   e.g., [9:96], keeps volumes from 9 to 96 in functional runs, discards others, say 1:8 and 97:104 if there are any
%   default [], keep all volumes
%   only works when autodetect=1 because has to guess which run is functional run
% thresholds = {65, 6, 8} % func volumes>=65, 65>dti volumes>=6, localizer min slices<=8
% typically,
% functional dim: 64*64*26  many volumes
% scout dim: 256*256*3 or 256*256*1  few slices, several volumes
% structual dim: 256*256*200 many slices, but only one volume
%
% bat_dcm2nii(inputDir, outputDir, autodetect);
% after conversion, a nifti-1 file is a 3D file (1 nii = 1 single volume)
% if nii files exist with same name, overwrite without any prompt
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
%             -0601_corrupt (9664 *.dcm-files, detect '_\w' to skip this folder)
%         -other subfolders but do not have dcm files
%     -0299 (subject00n)
% notice: if the subfolder is 101 as run number, will be converted to 0101 as run number
%
% outputDir if autodetect (anat, dti, func, loc are guessed from # of nii files/volume info)
% -01Import  (I made the folder structure flat, folders will be auto created)
%     -s0215_loc (from run 0101)
%     -s0215_anat (from run 0201)
%     -s0215_dti (from run 0501)
%     -s0215_r01 (func run 1, from 0301)
%     -s0215_r02 (func run 2, from 0401)
%     -sxxxs_xxxx (another subject)
%
% outputDir if not autodetect
% -01Import
%     -s0215_r0101
%     -s0215_r0201
%     -s0215_r0301
%     -s0215_r0401
%     -s0215_r0501
%     -sxxxx_rxxxx (another subject)
% 
% note: 
%   conversion uses SPM functions; SPM must be added to your matlab path: File -> Set Path... -> add with subfolders. 
%   tested under SPM 12-6225 (with mac lion 10.7.5 and matlab 2012b)
%   if you use dicom2nifti for the first time, consider running only one subject and check the results before processing all 
%
% author = jerryzhujian9@gmail.com
% date: December 10 2014, 11:13:30 AM CST
% inspired by http://www.aimfeld.ch/neurotools/neurotools.html
% https://www.youtube.com/playlist?list=PLcNEqVlhR3BtA_tBf8dJHG2eEcqitNJtw
%

%------------- BEGIN CODE --------------
function [output1,output2] = main(inputDirs, outputDir, autodetect, keep, thresholds, email)
% email is optional, if not provided, no email sent
% (re)start spm
spm('fmri')
if ~exist('autodetect','var'), autodetect = 1; end
if ~exist('keep','var'), keep = []; end
if ~exist('thresholds','var'), thresholds = {65, 6, 8}; end
% func volumes>=65, 65>dti volumes>=6, localizer slices<=8    
func_volumes_threshold = thresholds{1};
dti_volumes_threshold = thresholds{2};   
loc_slices_threshold = thresholds{3};

startTime = ez.moment();
for n = 1:ez.len(inputDirs)
    inputDir = inputDirs{n};
    [dummy, subID] = ez.splitpath(inputDir);
    subID = regexp(subID,'\d+','match'); subID = ez.num(subID{1}); subID = sprintf('s%04d',subID);
    ez.print(['Processing ' subID ' ...']);
    % 1) convert
    % Find DICOM-files and convert them using SPM
    cd(outputDir);
    dcm_converted = recursive_convert(inputDir, subID, outputDir);
    if dcm_converted == 0, error('No *.dcm files found in the specified input directory.'); end

    % 2) rename each nii folder
    if autodetect
        subDirs = ez.lsd(outputDir,['^' subID '_']);
        % track how many functiona runs
        funcRun = 1;
        for i = 1:ez.len(subDirs)
            subDir = ez.joinpath(outputDir, subDirs{i});
            % volumes = ez.len(ez.ls(subDir,'\.nii$')); % assume 1 nii = 1 volume
            P = ez.ls(subDir, '\.nii$'); P = char(P); V = spm_vol(P);
            % V is a structure array, each row has info for one nii file
            volumes = size(V,1);
            if volumes >= func_volumes_threshold % functional
                % keep=[], keep all
                if ~isempty(keep)
                    % trim volumes
                    P = cellstr(P); % convert to cell
                    whole = [1:ez.len(P)]; % all volumes index
                    discards = ez.setdiff(whole,keep);
                    ez.print(sprintf('Discarding volumes in functional run %s', subDirs{i}));
                    discards
                    ez.rm(P(discards)); % P(discards) returns a cell
                end
                ez.rn(subDir,ez.joinpath(outputDir,sprintf('%s_r%02d', subID, funcRun)));
                funcRun = funcRun + 1;
            elseif volumes >= dti_volumes_threshold % DTI
                ez.rn(subDir,ez.joinpath(outputDir,sprintf('%s_dti', subID)));
            % min number of slices across all volumes
            elseif min([V.dim]) <= loc_slices_threshold % localizer
                ez.rn(subDir,ez.joinpath(outputDir,sprintf('%s_loc', subID)));
            elseif volumes == 1 % anatomical
                ez.rn(subDir,ez.joinpath(outputDir,sprintf('%s_anat', subID)));
            else
                % unknown, retain the folder name
            end % end if
        end % end for
    end % end if autodetec

    % 3) Done message
    ez.print(sprintf('\nConverted %d DICOM-files for %s.', dcm_converted, subID));
    ez.pprint('****************************************'); % pretty colorful print
end % end for inputDirs
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
            ez.pprint(sprintf('\nSkipping dicom files in subfolder %s', runNr),'blue');
        else
            ez.print(sprintf('\nFound dicom files in subfolder %s', runNr));
            runNr = regexp(runNr,'\d+','match'); runNr = ez.num(runNr{1}); runNr = sprintf('r%04d',runNr);
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