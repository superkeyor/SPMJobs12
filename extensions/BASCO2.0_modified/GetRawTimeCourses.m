function [tc] = GetRawTimeCourses(DATA,roipath,roifiles)
% retrieve raw time courses using marsbar
NumROIs = size(roifiles,2);
for i=1:NumROIs,
    roi_file = spm_select('FPList', roipath, char(roifiles(i)));
    tc(:,i)  = rawtimecourse(DATA,roi_file);
end
end

function [TS,N] = rawtimecourse(P,roi_file)
rois = maroi('load_cell', roi_file);   % make maroi ROI objects
mY = get_marsy(rois{:}, P, 'mean');    % extract data into marsy data object
TS = summary_data(mY);                 % get summary time course(s)
N  = size(TS);
end
