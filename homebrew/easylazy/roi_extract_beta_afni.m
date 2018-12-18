function result = main(roiNiiPath,SPMMatPath,xlsxPath)
% (roiNiiPath,SPMMatPath,xlsxPath)
% Description:
%       Uses afni 3dmaskave functions to extract beta (roi nii --> xlsx), not intended for time series
%       I confirmed that afni extraction is the 99.99% exactly the same as spm 12 raw y (but not filtered y)
%       The betas = mean signal (aka raw intensity values, beta weights, parameter estimates, effect sizes) from your regions of interest
%           parameter estimate (2nd-level GLM regression coeffecient, fmri effect size), arbitary unit, averaged across voxels within the roi
%           Not likely to be standardized beta regression coeffecient
%       Also see Review-->Design-->Explore-->Files and factors to find out which beta is which
% Input:
%       roiNiiPath: cell str of roi Nii paths. default: ez.ls(pwd,'^ROI.*nii$'). could be saved from SPM or xjview. recommended roi name format: ROI_Label_x_y_z.nii 
%       SPMMatPath: path to (2nd level) SPM.mat default: 'SPM.mat'
%       xlsxPath: xlsx file name default: 'betas_extracted_afni.xlsx'
% Output:
%       xlsx file with extracted betas
%       returns a cell representing the xlsx result

if nargin<1
    xlsxPath='betas_extracted_afni.xlsx';
    SPMMatPath='SPM.mat';
    roiNiiPath=ez.ls(pwd,'^ROI.*nii$');
elseif nargin<2
    xlsxPath='betas_extracted_afni.xlsx';
    SPMMatPath='SPM.mat';
elseif nargin<3
    xlsxPath='betas_extracted_afni.xlsx';
end
    
header = cell(1,numel(roiNiiPath));
result = [];
load(SPMMatPath); P = SPM.xY.P; P = cellfun(@(e) [e(1:end-6), ez.ifelse(strcmp(e(end-4:end-2),'nii'),'.nii','.hdr')], P, 'uniform', false);
for i = 1:length(roiNiiPath)
    roi = roiNiiPath{i};
    
    [~,roiName] = ez.splitpath(roi);
    roiName = regexprep(roiName,'^ROI_*','','ignorecase');
    header{1,i} = roiName;
    
    beta = [];  % a column
    for j = 1:length(P)
        % https://afni.nimh.nih.gov/afni/community/board/read.php?1,137959,137960#msg-137960
            % SPM uses NAN (not a number) within a dataset, 
            % maybe for masking and such, I'm not sure. But 
            % those "values" have no numerical representation, 
            % and that is probably what 3dcopy is complaining 
            % about. 
            % In short, it should be fine. 
        % ignore 'correct float error'
        cmd = ['3dmaskave -mask "', roi, '" -quiet "', P{j}, '"'];
        [sta, res] = system(cmd);
        res = strsplit(res,'\n');
        res = str2num(res{end-1});
        beta = [beta; res];
    end
    result = [result,beta];

end % end for
result = [header;num2cell(result)];
load(SPMMatPath); P = SPM.xY.P; [~,id]=ez.splitpath(P); P = strrep(P,',','_');
result = [['file';P] ['id';id] result];
T = cell2table(result(2:end,:));
T.Properties.VariableNames = matlab.lang.makeValidName(result(1,:));
result = T;
ez.savex(T, xlsxPath);

end % end function