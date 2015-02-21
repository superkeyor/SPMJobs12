% Put this script in the folder of each step. Change the working directory to a folder/step. Go!
ez.clean();
%----------------------------------
projDir = ez.parentdir(ez.csd);
steps = ez.lsd(projDir,'^\d\d'); % a cell of all folders like 01Original, 06Set
[dummy, currentStep] = ez.splitpath(ez.csd);
currentStepNum = find(strcmp(steps,currentStep));
if ~isempty(currentStepNum), prevStep = steps{currentStepNum-1}; else prevStep = currentStep; end
inputDir = ez.joinpath(projDir,prevStep);
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
job_first(inputDir, inputDir2, outputDir, parameters, together, email);

outputDir = ez.csd();
preclean = 1; together = 1;
job_contrastT(outputDir,preclean,together);
dbclear if error;
