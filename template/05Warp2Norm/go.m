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
outputDir = ez.csd();
%----------------------------------
inputDir2 = '/Users/jerry/Downloads/AA2/04Motion/mean';  % functional mean
inputDir3 = '/Users/jerry/Downloads/AA2/02Concat'; % anat
%----------------------------------
together = 1;
email = 'jerryzhu@siu.edu';
dbstop if error;  % enter matlab debug mode in case of run-time error
%----------------------------------
job_warp2norm(inputDir, outputDir, inputDir2, inputDir3, together, email);
dbclear if error;
