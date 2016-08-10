% Put this script in the folder of each step. Change the working directory to a folder/step. Go!
ez.clean();
%----------------------------------
[inputDir,projDir] = ez.stepfolder(-1);
%----------------------------------
outputDir = ez.csd();
%----------------------------------
parameters = {26, 2.5, [1:2:26 2:2:26], 25};
together = 1;
%----------------------------------
email = 'jerryzhu@siu.edu';
dbstop if error;  % enter matlab debug mode in case of run-time error
%----------------------------------
diary ON; % save/append all output to "diary"
job_slicetiming(inputDir, outputDir, parameters, together, email);
diary OFF;
dbclear if error;
