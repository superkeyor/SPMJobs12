% Put this script in the folder of each step. Change the working directory the a folder/step. Go!
ez.clean();
%----------------------------------
[inputDir,projDir] = ez.stepfolder(-1);
%----------------------------------
outputDir = ez.csd();
%----------------------------------
subjects = {
'00215';
'00216';
'00217';
'00225';
'00226';
'00255';
'00256';
'00258';
'00264';
'00265';
'00266';    
};
inputDirs = ez.joinpath(inputDir,subjects);

%----------------------------------
autodetect = 1;
keep = [1:96];
thresholds = {65, 6, 8};
together = 1;
email = 'jerryzhu@siu.edu';
dbstop if error;  % enter matlab debug mode in case of run-time error
%----------------------------------
diary ON; % save/append all output to "diary"
job_dcm2nii(inputDirs, outputDir, autodetect, keep, thresholds, email);
diary OFF;
dbclear if error;
