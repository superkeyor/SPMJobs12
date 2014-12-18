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
parameters = {26, 2.5, [1:2:26 2:2:26], 25};
together = 1;
%----------------------------------
email = 'jerryzhu@siu.edu';
dbstop if error;  % enter matlab debug mode in case of run-time error
%----------------------------------
job_slicetiming(inputDir, outputDir, parameters, together, email);
dbclear if error;
