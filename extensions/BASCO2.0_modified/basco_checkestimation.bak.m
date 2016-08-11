function basco_checkestimation(handles)
% check beta-value estimation for selected ROI
WriteInfoBox(handles,'Check model estimation. Please select ROI.',true)
% select ROI
[roifile,roipath] = uigetfile('*.mat','Select ROI','MultiSelect','off');
fprintf('Selected ROI: %s \n',fullfile(roipath,roifile));
% loop over subjects
for isubj=1:handles.NumJobs
spmfile = 'SPM.mat';
data_path  = handles.anaobj{isubj}.Ana{1}.AnaDef.DataPath;
outdirname = handles.anaobj{isubj}.Ana{1}.AnaDef.OutDir;
spmpath    = fullfile(data_path,outdirname);
WriteInfoBox(handles,sprintf('Processing subject %d ...',isubj),true)

SPMfile = fullfile(spmpath,spmfile);
D = mardo(SPMfile); % Marsbar design object
R = maroi(fullfile(roipath,roifile)); % Marsbar ROI object
Y = get_marsy(R,D,'mean'); % put data into marsbar data object
E = estimate(D,Y); % estimate model based on ROI summary
b = betas(E); % retrieve estimated beta-values

% plot design matrix
load(fullfile(spmpath,spmfile));
X = [SPM.xX.X];
% Xs = spm_DesMtx('sca',X);
% figure('Name','SPM design matrix');
% colormap('gray');
% image((Xs+1)*32);
% title(sprintf('SPM design matrix '));
% xlabel('regressors');
% ylabel('scans');

% get summary time course(s)
ts = summary_data(Y);
% ts = filter_bandpass(ts,2,0.01,0.5/2,4);
thefit = X*b;
[NumScans, NumRegr] = size(X);

figure('Name',sprintf('subject %d',isubj));
plot([1:NumScans],ts,'b-',[1:NumScans],thefit,'r--');
xlabel('signal [a.u.]');
ylabel('scans');
legend('signal','fitted model');

end % end loop opver subjects
