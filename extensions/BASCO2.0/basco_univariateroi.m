function univariateroi()
% estimate model for selected ROI using SPM design (marsbar)
% select design
[spmfile,spmpath] = uigetfile('SPM.mat','Select SPM-design','MultiSelect','off');
fprintf('Selected SPM.mat file in directory: %s\n',spmpath);
% select ROI
[roifile,roipath] = uigetfile('*.mat','Select ROI','MultiSelect','off');
fprintf('Selected ROI: %s \n',fullfile(roipath,roifile));

load(fullfile(spmpath,spmfile));
X = [SPM.xX.X];
SPMfile = fullfile(spmpath,spmfile);
spm_DesRep('DesRepUI',SPM);
D = mardo(SPMfile); % Marsbar design object
R = maroi(fullfile(roipath,roifile)); % Marsbar ROI object
Y = get_marsy(R,D,'mean'); % put data into marsbar data object
E = estimate(D,Y); % estimate model based on ROI summary
b = betas(E); % retrieve estimated beta-values
ts = summary_data(Y); % get summary time course(s)
ui_plot(Y,'all');
ts = spm_filter(SPM.xX.K,ts); % high pass filtering
[NumScans, NumRegr] = size(X);
NumRegr = size(b,1);
Nruns = length(SPM.Sess);
NScan = NumScans/Nruns;                             % number of scans per run
Ncondvec = str2num(SPM.xsDes.Trials_per_session);   % number of trials per session
Ncond = Ncondvec(1);
Nmotr = (NumRegr-(Nruns*(1+Ncond)))/Nruns;          % number of regressors excluding conditions/trials/stimuli
Nreg  = Ncond+Nmotr;                                % number of regressors per run
% print info
str=sprintf('Selected SPM-file: %s. \nSelected ROI: %s. \nNumber of scans/session: %d',fullfile(spmpath,spmfile),fullfile(roipath,roifile),NScan);
str=sprintf('%s\nRegressors: %d \nSessions: %d \nTrials: %d \nOther (i.e. motion): %d',str,NumRegr,Nruns,Ncond,Nmotr);
disp(str);
thefit = X*b;
figure;
plot([1:NumScans],ts,'b-',[1:NumScans],thefit,'r--');
xlabel('scans');
ylabel('signal [a.u.]');
legend('signal','fitted model');


