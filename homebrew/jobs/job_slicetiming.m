% (inputDir, outputDir, parameters);
% generates 4d file, slice timing correction for each volume in the 4d file
% if output nii files exist with same name, overwrite without any prompt
%
% inputDir ='.../xxx/'; trailing filesep does not matter
% outputDir = '.../xxx/'; % trailing filesep does not matter
% parameters = {nslices, tr(seconds), sliceorder, refslice};
%       e.g.,  {26, 2.5, [1:2:26 2:2:26], 25}
% optional input: together = 0/1 (default 1) if 0 only generates job_.mat files, 1 run the jobs and clean up afterwards
% 
% note: 
%   uses SPM functions; SPM must be added to your matlab path: File -> Set Path... -> add with subfolders. 
%   tested under SPM 12-6225 (with mac lion 10.7.5 and matlab 2012b)
%   if you use this job_function for the first time, consider running only one subject and check the results before processing all 
%
% author = jerryzhujian9@gmail.com
% date: December 10 2014, 11:13:30 AM CST
% inspired by http://www.aimfeld.ch/neurotools/neurotools.html
% https://www.youtube.com/playlist?list=PLcNEqVlhR3BtA_tBf8dJHG2eEcqitNJtw

%------------- BEGIN CODE --------------
function [output1,output2] = main(inputDir, outputDir, parameters, together, email)
% email is optional, if not provided, no email sent
% (re)start spm
spm('fmri');
if ~exist('together','var'), together = 1; end
[nslices, tr, sliceorder, refslice] = parameters{:};

startTime = ez.moment();

runFiles = ez.ls(inputDir,'s\d\d\d\d_r\d\d\.nii$');
for n = 1:ez.len(runFiles)
    runFile = runFiles{n};
    [dummy runFileName] = ez.splitpath(runFile);
    ez.print(['Processing ' runFileName ' ...']);
    
    
    load('mod_slicetiming.mat');
    runVolumes = cellstr(spm_select('ExtList',inputDir,runFileName,[1:1000]));
    runVolumes = cellfun(@(e) ez.joinpath(inputDir,e),runVolumes,'UniformOutput',false);
    matlabbatch{1}.spm.temporal.st.scans{1,1} = runVolumes;  % volumes for only one run/4dfile
    matlabbatch{1}.spm.temporal.st.nslices = nslices;
    matlabbatch{1}.spm.temporal.st.tr = tr;
    matlabbatch{1}.spm.temporal.st.ta = tr - (tr/nslices);
    matlabbatch{1}.spm.temporal.st.so = sliceorder;
    matlabbatch{1}.spm.temporal.st.refslice = refslice;
    prefix = matlabbatch{1}.spm.temporal.st.prefix;
    cd(outputDir);
    save(['job_slicetiming_' runFileName '.mat'], 'matlabbatch');
    if together
        spm_jobman('run',matlabbatch);
        ez.mv(ez.joinpath(inputDir,[prefix runFileName '.nii']), outputDir);
    end
    clear matlabbatch;

    ez.pprint('****************************************'); % pretty colorful print
end
ez.pprint('Done!');
finishTime = ez.moment();
if exist('email','var'), try, jobmail(mfilename, startTime, finishTime); end; end;
end % of main function
%------------- END OF CODE --------------