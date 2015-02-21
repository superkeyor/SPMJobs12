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
inputDirs = {ez.joinpath(inputDir,'00215');
             ez.joinpath(inputDir,'00216');
             ez.joinpath(inputDir,'00217');
             ez.joinpath(inputDir,'00225');
             ez.joinpath(inputDir,'00226');
             ez.joinpath(inputDir,'00255');
             ez.joinpath(inputDir,'00256');
             ez.joinpath(inputDir,'00258');
             ez.joinpath(inputDir,'00264');
             ez.joinpath(inputDir,'00265');
             ez.joinpath(inputDir,'00266');};

%----------------------------------
autodetect = 1;
keep = [1:96];
thresholds = {65, 6, 8};
together = 1;
email = 'jerryzhu@siu.edu';
dbstop if error;  % enter matlab debug mode in case of run-time error
%----------------------------------
job_dcm2nii(inputDirs, outputDir, autodetect, keep, thresholds, email);
dbclear if error;
