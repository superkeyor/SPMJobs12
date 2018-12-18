function result = main(xlsxPath)
% Description:
%       merge extracted betas (single voxel or cluster, using spm right click) with ids into an xlsx file
% Input:
%       xlsxPath: xlsx file name default: 'betas_extracted_spm.xlsx'
%       implicit y: extracted values with SPM GUI in base workspace
%       implicit SPM: SPM data structure loaded into base workspace from SPM.mat
% Output:
%       xlsx file with extracted betas
%       returns a cell representing the xlsx result

ez.setdefault({'xlsxPath','betas_extracted_spm.xlsx'});

y = evalin('base', 'y');
SPM = evalin('base', 'SPM');
P = SPM.xY.P; 
[~,id]=ez.splitpath(P); 
P = strrep(P,',','_');
meanY = mean(y,2);
medianY = median(y,2);
result = [file, id, num2cell([meanY, medianY, y])];
result = cell2table(result, 'VariableNames', [ {'file', 'id', 'meanY', 'medianY'}, cellstr(string('Y')+(1:size(y,2))) ]);
ez.savex(result, xlsxPath);

end % end function