% inputDir ='.../01Import/'; trailing filesep does not matter
% outputDir = '.../024D/'; % trailing filesep does not matter
% optional input: together = 0/1 (default 1) if 0 only generates job_.mat files, 1 run the jobs and clean up afterwards
% generates _s0215_r01.nii (which is 4d as file name, prepending _ now, because later on spm atuo add prefix for each step)
%
% (inputDir, outputDir, together);
% after conversion, a nifti-1 file is a 4D file (1 nii = xxx volumes)
% if nii files exist with same name, overwrite without any prompt
%
% inputDir
% -01Import
%     -s0215_loc
%     -s0215_anat (1 nii file)
%     -s0215_dti (xx nii files)
%     -s0215_r01 (func run 1, xxx nii files)
%     -s0215_r02 (func run 2, xxx nii files)
%     -sxxxs_xxxx (another subject)
%
% outputDir
% -024D
%     -_s0215_anat.nii
%     -_s0215_dti.nii
%     -_s0215_r01.nii
%     -_s0215_r02.nii
%     -(another subject)
% 
% note: 
%   conversion uses SPM functions; SPM must be added to your matlab path: File -> Set Path... -> add with subfolders. 
%   tested under SPM 12-6225 (with mac lion 10.7.5 and matlab 2012b)
%   if you use this job_function for the first time, consider running only one subject and check the results before processing all 
%
% author = jerryzhujian9@gmail.com
% date: December 10 2014, 11:13:30 AM CST
% inspired by http://www.aimfeld.ch/neurotools/neurotools.html
% https://www.youtube.com/playlist?list=PLcNEqVlhR3BtA_tBf8dJHG2eEcqitNJtw
%

%------------- BEGIN CODE --------------
function [output1,output2] = main(inputDir, outputDir, together, email)
% email is optional, if not provided, no email sent
% (re)start spm
spm('fmri');
if ~exist('together','var'), together = 1; end

startTime = ez.moment();
subDirs = ez.lsd(inputDir,'anat|dti|r\d\d'); % skip loc
for n = 1:ez.len(subDirs)
    subDir = subDirs{n};
    ez.print(['Processing ' subDir ' ...']);

    outputFile = ez.joinpath(outputDir,['_' subDir]);
    subDir = ez.joinpath(inputDir,subDir);
    
    load('mod_3dto4d.mat');
    matlabbatch{1}.spm.util.cat.vols = ez.ls(subDir,'\.nii$');
    matlabbatch{1}.spm.util.cat.name = [outputFile '.nii'];
    cd(outputDir);
    [dummy subDir] = ez.splitpath(subDir);
    save(['job_3dto4d_' subDir '.mat'], 'matlabbatch');
    if together
        spm_jobman('run',matlabbatch);
        ez.rm([outputFile '.mat']); % jobman generates a mat file for each concat, not informative
    end
    clear matlabbatch;

    ez.pprint('****************************************'); % pretty colorful print
end

if together
    % % print out a report of volume numbers for each 4d file
    % outputFiles = ez.ls(outputDir,'\.nii$');
    % for n = 1:ez.len(outputFiles)
    %     outputFile = char(outputFiles{n});
    %     V = spm_vol(outputFile);
    %     % V is a structure array, each row has info for one volume
    %     volumes = size(V,1);
    %     [dummy outputFile] = ez.splitpath(outputFile);
    %     ez.print(sprintf('%s has %d volumes',outputFile,volumes));
    % end

    % generate the csv report
    job_report(outputDir);
end
ez.pprint('Done!');

finishTime = ez.moment();
if exist('email','var') && together, try, jobmail(mfilename, startTime, finishTime); end; end;
end % of main function
%------------- END OF CODE --------------