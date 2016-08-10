% Put this script in the folder of each step. Change the working directory to a folder/step. Go!
ez.clean();
%----------------------------------
[inputDir,projDir] = ez.stepfolder(-1);
%----------------------------------
outputDir = ez.csd();
%----------------------------------
inputDir2 = ez.joinpath(projDir, '04Motion', 'mean');  % functional mean
inputDir3 = ez.joinpath(projDir,'02Concat'); % anat
%----------------------------------
together = 1;
email = 'jerryzhu@siu.edu';
dbstop if error;  % enter matlab debug mode in case of run-time error
%----------------------------------
diary ON; % save/append all output to "diary"
job_warp2norm(inputDir, outputDir, inputDir2, inputDir3, together, email);
% job_warp2norm_old(inputDir, outputDir, inputDir2, inputDir3, together, email);
diary OFF;
dbclear if error;
