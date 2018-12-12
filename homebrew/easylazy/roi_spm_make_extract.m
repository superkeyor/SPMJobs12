function result = main(y,SPM)
% Description:
%       merge ids and extracted betas (single voxel or cluster) into an xlsx file
% Input:
%       y extracted values with SPM GUI in base workspace
%       SPM SPM data structure loaded into base workspace from SPM.mat
% Output:
%       xlsx file with extracted betas (betas_extracted_spm.xlsx, file name hard-coded)
%       returns a cell representing the xlsx result

if nargin<1
    y = evalin('base', 'y');
    SPM = evalin('base', 'SPM');
elseif nargin<2
    SPM = evalin('base', 'SPM');
end

P = SPM.xY.P;
[~,file]=ez.splitpath(P);
meanY = mean(y,2);
medianY = median(y,2);
result = [file, meanY, medianY, y];
result = cell2table(result, 'VariableNames', [ {'ID', 'meanY', 'medianY'}, cellstr(string('Y')+(1:size(y,2))) ]);
ez.savex(result, fullfile('betas_extracted_spm.xlsx'));

end % end function