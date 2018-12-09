function result = main(SPMPath, roiMatPath, stat, folder)
% Description:
%       Uses marsbar functions to extract
%       If marsbar path not in searchpath, auto add them internally first.
%       The result should be equal to right-click->extract data->raw y in SPM map
%           if very close, due possibly to conversion of marsbar roi format
%       The betas = mean signal (aka raw intensity values, beta weights, parameter estimates, effect sizes) from your regions of interest
%           parameter estimate (2nd-level GLM regression coeffecient, fmri effect size), arbitary unit, averaged across voxels within the roi
%           not likely to be standardized beta regression coeffecient
%       Reference at http://www.jessicagrahn.com/marsbar-extract-data.html
%       See Review-->Design-->Explore-->Files and factors to find out which beta is which
% Input:
%       SPMPath: path to SPM.mat of 2nd level (not applicable to 1st-level SPM.mat)
%       roiMatPath: path to roi image(s), str or cell of str
%                   recommendated ROIName format is: ROI_label_x_y_z_roi.mat
%       stat: method to summarize values across all voxels within a roi, 'mean'(default), 'median', 'eigen1', 'wtmean' (weighted mean)
%       folder, path to folder where extracted betas (xlsx) will be saved , default pwd, if not exist, auto create the folder
% Output:
%       xlsx file with extracted betas (betas_extracted.xlsx, file name hard-coded)
%       returns a cell representing the xlsx result

if (isempty(which('marsbar'))||isempty(which('spm_get')))
    ez.print('addpath marsbar...')
    extsPath = ez.joinpath(ez.parentdir(ez.parentdir(ez.csd())), 'extensions');
    thePath = ez.lsd(extsPath,'^marsbar');
    thePath = ez.joinpath(extsPath,thePath{1});
    addpath(thePath,'-end');
    % additional path that would be added by marsbar
    addpath(ez.joinpath(thePath,'spm5'),'-end');
end

if ischar(roiMatPath), roiMatPath = cellstr(roiMatPath); end
if nargin<3, stat = 'mean'; end
if nargin<4, folder = pwd; else ez.mkdir(folder); end

% eigen1 relies on a obsolete function in spm: spm_atranspa
if strcmp(stat,'eigen1'), addpath(ez.joinpath(ez.splitpath(which('spm')),'compat'),'-end'); end

header = cell(1,length(roiMatPath));
result = [];
for i = 1:length(roiMatPath)
    roi = roiMatPath{i};
    
    [~,roiName] = ez.splitpath(roi);
    header{1,i} = roiName;
    
    % Make marsbar design object
    D  = mardo(SPMPath);
    % Make marsbar ROI object
    R  = maroi(roi);
    % Fetch data into marsbar data object
    Y = get_marsy(R, D, stat);   % Y will be betas in the case of 2nd level SPM.mat, ignore the following part
    % get summary data from the Y object
    result = [result,summary_data(Y)];
    
    %     % Get contrasts from original design
    %     xCon = get_contrasts(D);
    %     % Estimate design on ROI data
    %     E = estimate(D, Y);
    %     % Put contrasts from original design back into design object
    %     E = set_contrasts(E, xCon);
    %     % get design betas
    %     b = betas(E);
    %     % get stats and stuff for all contrasts into statistics structure 
    %     marsS = compute_contrasts(E, 1:length(xCon));

end % end for
result = [header;num2cell(result)];
load(SPMPath); P = SPM.xY.P; P = strrep(P,',','_');
result = [['ID';P] result];
T = cell2table(result(2:end,:));
T.Properties.VariableNames = result(1,:);
result = T;
ez.savex(T, fullfile(folder,'betas_extracted.xlsx'));

end % end function