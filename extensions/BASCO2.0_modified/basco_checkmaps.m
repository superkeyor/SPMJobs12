function basco_checkmaps(handles)
if handles.NumJobs==0
   handles.InfoText = WriteInfoBox(handles,'No analysis. Please open file first.',true);
   guidata(hObject, handles);
   return;
end
% get t-images
tmppath = pwd;
cd(fullfile(handles.anaobj{1}.Ana{1}.AnaDef.DataPath,handles.anaobj{1}.Ana{1}.AnaDef.OutDir));
[file,path] = uigetfile('corrmap*.img','Select two images','MultiSelect','on');
cd(tmppath);
fname1 = file{1};
fname2 = file{2};

% select ROI
[roifile,roipath] = uigetfile('*.mat','Select ROI','MultiSelect','off');
fprintf('Selected ROI: %s',fullfile(roipath,roifile));

% selected subjects
idxsubj = str2num(get(handles.editsubjectselection,'String'));
Nsubj   = length(idxsubj); % number of selected subjects
NumSubj = handles.NumJobs;

% get files
for isubj=1:NumSubj % loop over subjects
   data_path  = handles.anaobj{isubj}.Ana{1}.AnaDef.DataPath;
   outdirname = handles.anaobj{isubj}.Ana{1}.AnaDef.OutDir;
   thefiles1(isubj,:) = fullfile(data_path,outdirname,fname1);
   thefiles2(isubj,:) = fullfile(data_path,outdirname,fname2);
end % end loop over subjects

% retrieve data from images 1
rois = maroi('load_cell', fullfile(roipath,roifile));    % make maroi ROI objects
mY1  = get_marsy(rois{:}, thefiles1, 'mean');            % extract data into marsy data object
TS1  = summary_data(mY1);                                % get summary data
N1   = size(TS1);
% retrieve data from images 2
mY2  = get_marsy(rois{:}, thefiles2, 'mean');            % extract data into marsy data object
TS2  = summary_data(mY2);                                % get summary data
N2   = size(TS2);

figure('Name','correlation map data');
subplot(2,2,1);
plot([1:NumSubj],TS1,'-',[1:NumSubj],TS2,'-');
xlabel('subjects');
ylabel('correlation');
title('mean correlation');
legend('1','2');
subplot(2,2,2); 
hist(TS1);
hold on;
hist(TS2);
h = findobj(gca,'Type','patch');
set(h(2),'FaceColor','w','EdgeColor','b','facealpha',0.75,'LineWidth',2);
set(h(1),'FaceColor','w','EdgeColor','r','facealpha',0.75,'LineWidth',2,'LineStyle','-.');
xlabel('correlation coefficient');
ylabel('number of subjects');
[~, theprob] = ttest(TS1,TS2);
title(sprintf('correlation (probability from t-test: %f)',theprob));
legend(sprintf('mean: %.2f sigma: %.2f',mean(TS1),std(TS1)),sprintf('mean: %.2f sigma: %.2f',mean(TS2),std(TS2)));
subplot(2,2,3); 
plot([1:NumSubj],TS1-TS2,'-',[1:NumSubj],zeros(1,NumSubj),'g--');
xlabel('subjects');
ylabel('difference');
subplot(2,2,4); 
hist(TS1-TS2);
xlabel('difference');
ylabel('number of subjects');
title(sprintf('mean: %.2f sigma: %.2f',mean(TS1-TS2),std(TS1-TS2)));
