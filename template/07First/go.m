% Put this script in the folder of each step. Change the working directory to a folder/step. Go!
ez.clean();
%----------------------------------
[inputDir,projDir] = ez.stepfolder(-1);
%----------------------------------
inputDir2 = ez.joinpath(projDir, '04Motion'); % where estimated motion parameters .txt are.
outputDir = ez.csd();
%----------------------------------
parameters = {2.5, 26, 25};  % parameters = {tr(seconds), nslices, refslice};
together = 1;
%----------------------------------
email = 'jerryzhu@siu.edu';
dbstop if error;  % enter matlab debug mode in case of run-time error
%----------------------------------
diary ON; % save/append all output to "diary"
job_first(inputDir, inputDir2, outputDir, parameters, together, email);

outputDir = ez.csd();
preclean = 1; together = 1;
job_contrastT(outputDir,preclean,together);
diary OFF;
dbclear if error;
