function basco_checkestimation(handles)
% check beta-value estimation for selected ROI
WriteInfoBox(handles,'Check model estimation. Please select ROI.',true)
% select ROI
[roifile,roipath] = uigetfile('*.mat','Select ROI','MultiSelect','off');
if isequal(roifile,0),disp('User Cancelled'); return; end
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
% Jerry fix, see https://www.nitrc.org/forum/forum.php?thread_id=6781&forum_id=3998
D = autocorr(D, 'fmristat', 2);
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
ts = spm_filter(SPM.xX.K,ts); % high pass filtering
thefit = X*b;
[NumScans, NumRegr] = size(X);

figure('Name',sprintf('subject %d',isubj));
plot([1:NumScans],ts,'b-',[1:NumScans],thefit,'r--');
xlabel('signal [a.u.]');
ylabel('scans');
legend('signal','fitted model');

end % end loop opver subjects


function newstr = WriteInfoBox(handles,str,append)
disp(str);
oldstr = handles.InfoText;
if append==true
    newstr = sprintf('%s \n%s',str,oldstr);
else
    newstr = sprintf('%s',str);
end
set(handles.infobox,'String',newstr);
drawnow;