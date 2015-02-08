% Put this script in the folder of each step. Change the working directory to a folder/step. Go!
ez.clean();
%----------------------------------
inputDirs = {'/Users/jerry/Downloads/AA2/00ScannerBackup/00215';
            '/Users/jerry/Downloads/AA2/00ScannerBackup/00216'};
%----------------------------------
outputDir = '/Users/jerry/Downloads/AA2/01Import';
%----------------------------------
autodetect = 1;
discards = 8;
thresholds = {65, 6, 8};
together = 1;
email = 'jerryzhu@siu.edu';
dbstop if error;  % enter matlab debug mode in case of run-time error
%----------------------------------
job_dcm2nii(inputDirs, outputDir, autodetect, discards, thresholds, email);
dbclear if error;
