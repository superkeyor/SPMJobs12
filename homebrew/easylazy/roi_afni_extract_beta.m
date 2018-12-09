function result = main(SPMPath, clusterPath, stat, folder)
% Description:
%       Uses afni functions to extract
%       The betas = mean signal (aka raw intensity values, beta weights, parameter estimates, effect sizes) from your regions of interest
%           parameter estimate (2nd-level GLM regression coeffecient, fmri effect size), arbitary unit, averaged across voxels within the cluster
%           not likely to be standardized beta regression coeffecient
%       See Review-->Design-->Explore-->Files and factors to find out which beta is which
% Input:
%       SPMPath: path to SPM.mat of 2nd level (not applicable to 1st-level SPM.mat)
%       clusterPath: path to cluster nii image(s), str or cell of str
%       stat: method to summarize values across all voxels within a cluster, so far only 'mean' supported
%       folder, path to folder where extracted betas (xlsx) will be saved , default pwd, if not exist, auto create the folder
% Output:
%       xlsx file with extracted betas (betas_extracted.xlsx, file name hard-coded)
%       returns a cell representing the xlsx result

if ischar(clusterPath), clusterPath = cellstr(clusterPath); end
if nargin<3, stat = 'mean'; end
if nargin<4, folder = pwd; else ez.mkdir(folder); end

header = cell(1,length(clusterPath));
result = [];
for i = 1:length(clusterPath)
    cluster = clusterPath{i};
    
    [~,clusterName] = ez.splitpath(cluster);
    header{1,i} = clusterName;
    


    result = [result,summary_data(Y)];
    
end % end for
result = [header;num2cell(result)];
load(SPMPath); P = SPM.xY.P; P = strrep(P,',','_');
result = [['ID';P] result];
T = cell2table(result(2:end,:));
T.Properties.VariableNames = result(1,:);
ez.savex(T, fullfile(folder,'betas_extracted.xlsx'));

end % end function