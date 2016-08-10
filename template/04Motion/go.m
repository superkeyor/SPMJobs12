% Put this script in the folder of each step. Change the working directory to a folder/step. Go!
ez.clean();
%----------------------------------
[inputDir,projDir] = ez.stepfolder(-1);
%----------------------------------
outputDir = ez.csd();
%----------------------------------
parameters = {};
%----------------------------------
together = 1;
email = 'jerryzhu@siu.edu';
dbstop if error;  % enter matlab debug mode in case of run-time error
%----------------------------------
diary ON; % save/append all output to "diary"
job_motion(inputDir, outputDir, together, email);
diary OFF;
dbclear if error;
