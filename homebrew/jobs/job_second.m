% (inputDir);
% run prebuilt second level model and estimate
% inputDir
    % job_second.mat
    % job_second_contrasts.mat
% note: 
%   uses SPM functions; SPM must be added to your matlab path: File -> Set Path... -> add with subfolders. 
%   tested under SPM 12-6225 (with mac lion 10.7.5 and matlab 2012b)
%   if you use this job_function for the first time, consider running only one subject and check the results before processing all 
%
% author = jerryzhujian9@gmail.com
% date: December 10 2014, 11:13:30 AM CST
% inspired by http://www.aimfeld.ch/neurotools/neurotools.html
% https://www.youtube.com/playlist?list=PLcNEqVlhR3BtA_tBf8dJHG2eEcqitNJtw

%------------- BEGIN CODE --------------
function [output1,output2] = main(inputDir,email)
% email is optional, if not provided, no email sent
% (re)start spm
spm('fmri');

startTime = ez.moment();

load('job_second.mat');
spm_jobman('run',matlabbatch);
clear matlabbatch;

load('job_second_contrasts.mat');
spm_jobman('run',matlabbatch);
clear matlabbatch;

ez.pprint('Done!');
finishTime = ez.moment();
if exist('email','var'), try, jobmail(mfilename, startTime, finishTime); end; end;
end % of main function
%------------- END OF CODE --------------