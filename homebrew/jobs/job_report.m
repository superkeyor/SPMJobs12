% genearte a report of some characteristics of nii files
% in inputDir with name like "Report_2014-07-09_23-16-31-256.csv" so that old report will not be overwritten and can be compared with.

%------------- BEGIN CODE --------------
function [output1,output2] = main(inputDir,email)
% email is optional, if not provided, no email sent
% (re)start spm
spm('fmri')
files = ez.ls(inputDir, '\.nii$'); % nx1 cell array
outputDir = inputDir;
outputCSV = ['Report_' ez.moment() '.csv'];
outputCSV = ez.joinpath(outputDir,outputCSV);
outputCell = {'FileName', 'Dimensions', 'Volumes', 'DataType', 'Description'};

startTime = ez.moment();
% count generated (EEG) files, and csv rows.
newFiles = 0; newRows = 0;
for n = 1:ez.len(files)
    file = files{n}; % linear indexing, using only one subscript
    [filePath,fileName,fileExt] = ez.splitpath(file); % fileExt is .nii
    ez.print(['Processing ' fileName]);    

    V = spm_vol(file);
    FileName = fileName;
    Dimensions = V(1).dim;
    Volumes = ez.len(V);
    DataType = V(1).dt;
    Description = V(1).descrip;

    outputRow = {FileName, Dimensions, Volumes, DataType, Description};
    outputCell(end+1, :) = outputRow; % append to the cell by expanding
    newRows = newRows + 1;
    ez.pprint('****************************************'); % pretty colorful print
end % end for
if newRows > 0, ez.cell2csv(outputCSV,outputCell); end
ez.pprint(sprintf('Report on %d nii files (0 file = no report)', n));
finishTime = ez.moment();
if exist('email','var'), try, jobmail(mfilename, startTime, finishTime); end; end;
end % end function
%------------- END OF CODE --------------
