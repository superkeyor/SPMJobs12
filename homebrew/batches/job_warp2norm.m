% (inputDir, outputDir, inputDir2, inputDir3);
% warp anatomical and functional images into normalized/standard space
% step 1) coregister anat to functional mean ref, write the transformation matrix to anat file header, involves only linear transformation
% step 2) segment updated anat file to grey(c1), white(c2), csf(c3), bone(c4), soft-tissue(c5), air/background(c6), 
%         get the deformation info, involves linear transformation and nonlinear warp
% step 3) combine parameters from step 1 & 2, apply to functional and anat images
% if output nii files exist with same name, overwrite without any prompt
%
% inputDir ='.../xxx/'; trailing filesep does not matter
% outputDir = '.../xxx/'; % trailing filesep does not matter
% inputDir2 = folder for functional_mean_ref images
% inputDir3 = folder for anat_source images
% 
% note: 
%   uses SPM functions; SPM must be added to your matlab path: File -> Set Path... -> add with subfolders. 
%   tested under SPM 12 (with mac lion 10.7.5 and matlab 2012b)
%   if you use this job_function for the first time, consider running only one subject and check the results before processing all 
%
% author = jerryzhujian9@gmail.com
% date: December 10 2014, 11:13:30 AM CST
% inspired by http://www.aimfeld.ch/neurotools/neurotools.html
% https://www.youtube.com/playlist?list=PLcNEqVlhR3BtA_tBf8dJHG2eEcqitNJtw

%------------- BEGIN CODE --------------
function [output1,output2] = main(inputDir, outputDir, inputDir2, inputDir3, email)
% email is optional, if not provided, no email sent
% (re)start spm
spm('fmri')

startTime = ez.moment();
% 1) copy anat files to the inputDir
anatFiles = ez.ls(inputDir3,'s\d\d\d\d_anat\.nii$');
cellfun(@(e) ez.cp(e,outputDir),anatFiles,'UniformOutput',false);

% 2) process each subject one by one
% runFiles = ez.ls(inputDir,'^(?!mean).*s\d\d\d\d_r\d\d.nii$');  % not starting with 'mean'  % runFiles across all subjects
runFiles = ez.ls(inputDir,'s\d\d\d\d_r\d\d.nii$');  % runFiles across all subjects
[dummy runFileNames] = cellfun(@(e) ez.splitpath(e),runFiles,'UniformOutput',false);
runFileNames = cellfun(@(e) regexp(e,'_', 'split'),runFileNames,'UniformOutput',false);
subjects = cellfun(@(e) e{end-1},runFileNames,'UniformOutput',false);  
subjects = ez.unique(subjects); % returns {'s0215';'s0216'}

for n = 1:ez.len(subjects)
    subject = subjects{n};
    ez.print(['Processing ' subject ' ...']);

    load('mod_warp2norm.mat');

    % fill out coreg
    refImage = cellstr(spm_select('ExtList',inputDir2,['^mean.*' subject '.*\.nii'],[1]));
    refImage = cellfun(@(e) ez.joinpath(inputDir2,e),refImage,'UniformOutput',false);
    matlabbatch{1}.spm.spatial.coreg.estimate.ref = refImage;

    sourceImage = cellstr(spm_select('ExtList',outputDir,[subject '_anat\.nii'],[1]));
    sourceImage = cellfun(@(e) ez.joinpath(outputDir,e),sourceImage,'UniformOutput',false);
    matlabbatch{1}.spm.spatial.coreg.estimate.source = sourceImage;

    % fill out segment
    matlabbatch{2}.spm.spatial.preproc.channel.vols = sourceImage;
    spmFolder = ez.splitpath(which('spm'));
    tpmFile = ez.joinpath(spmFolder,'tpm','TPM.nii');
    for m = 1:6
        matlabbatch{2}.spm.spatial.preproc.tissue(m).tpm = cellstr([tpmFile ',' ez.str(m)]);
    end

    % fill out normalise
    resampleImages = {};
    % all volumes across run for each subject
    runVolumes = cellstr(spm_select('ExtList',inputDir,['^(?!mean).*' subject '.*\.nii'],[1:1000]));
    runVolumes = cellfun(@(e) ez.joinpath(inputDir,e),runVolumes,'UniformOutput',false);
    % also warp anat to normalised space
    resampleImages = [sourceImage;runVolumes];
    matlabbatch{3}.spm.spatial.normalise.write.subj.resample = resampleImages;    

    cd(outputDir);
    spm_jobman('run',matlabbatch);

    % move stuff to hallway
    hallway = ez.joinpath(outputDir,'hallway'); ez.mkdir(hallway);
    % jobman generates a mat file, not sure informative
    ez.mv(ez.joinpath(outputDir,'*seg8.mat'),hallway);
    % segments
    segs = ez.ls(outputDir,'^c\d.*nii$');
    spm_check_registration(char(segs));
    fig = spm_figure('FindWin','Graphics');
    ez.export(ez.joinpath(outputDir,[subject '_segs.pdf']),fig);
    cellfun(@(e) ez.mv(e,hallway),segs,'UniformOutput',false);
    % inverse/forward matrices
    files = ez.ls(outputDir,'^[iy]_.*nii$');
    cellfun(@(e) ez.mv(e,hallway),files,'UniformOutput',false);
    % bias corrected file
    files = ez.ls(outputDir,'^m.*anat\.nii$');
    cellfun(@(e) ez.mv(e,hallway),files,'UniformOutput',false);
    % process graph
    psFile = ez.ls(outputDir,'\.ps$'){1};
    eps2pdf(psFile,ez.joinpath(outputDir,[subject '_coreg.pdf']));  %eps2pdf comes with ez.export, requires ghostscript
    ez.rm(psFile);
    % move warped files
    files = ez.ls(inputDir,['^w.*' subject '_r\d\d\.nii$']);
    cellfun(@(e) ez.mv(e,outputDir),files,'UniformOutput',false);
    % check warped
    files = cellstr(spm_select('ExtList',outputDir,['^w.*' subject '.*\.nii'],[1]));
    files = cellfun(@(e) ez.joinpath(outputDir,e),files,'UniformOutput',false);
    spm_check_registration(char(files));
    fig = spm_figure('FindWin','Graphics');
    ez.export(ez.joinpath(outputDir,[subject '_warped.pdf']),fig);
    % finally anat with header changed
    files = ez.ls(outputDir,['^_' subject '_anat\.nii$']);
    cellfun(@(e) ez.mv(e,hallway),files,'UniformOutput',false);

    save(['job_warp2norm_' subject '.mat'], 'matlabbatch');
    clear matlabbatch;

    ez.pprint('****************************************'); % pretty colorful print
end
ez.pprint('Done!');
finishTime = ez.moment();
if exist('email','var'), try, batmail(mfilename, startTime, finishTime); end; end;
end % of main function
%------------- END OF CODE --------------