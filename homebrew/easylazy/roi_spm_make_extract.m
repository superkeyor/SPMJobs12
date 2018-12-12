function result = main(y,SPM)
% Description:
%       merge ids and extracted betas into an xlsx file
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

P = SPM.xY.P;
[~,file]=ez.splitpath(P);
result = [file, y];
result = cell2table(result,'VariableNames',{'ID','Y'});
ez.savex(result, fullfile('betas_extracted_spm.xlsx'));

end % end function