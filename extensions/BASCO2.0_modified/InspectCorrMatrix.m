function varargout = InspectCorrMatrix(varargin)
% inspect correlation matrix
% input: analysis object (used variables in analysis object: BetaSeries, Matrix)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @InspectCorrMatrix_OpeningFcn, ...
                   'gui_OutputFcn',  @InspectCorrMatrix_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

function InspectCorrMatrix_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;
handles.anaobj = varargin{1};
handles.anaobj{1}.AnaCurrent = 1;
handles.CurrentJob = 1;

% display connectivity matrix and histograms
DisplayMatrix(handles);

for i=1:size(handles.anaobj,2),
    if handles.anaobj{i}.Ana{1}.Configure.UseSPMDesign==true
      list2{i}=sprintf('%d %s',i,handles.anaobj{i}.Ana{1}.Configure.spmdesignpath);
    else
      list2{i}=sprintf('%d %s',i,handles.anaobj{i}.Ana{1}.Configure.datapath); 
    end
end
set(handles.popupmenuselectjob,'String',list2);

% configure slider
NWM = handles.anaobj{1}.Ana{handles.anaobj{1}.AnaCurrent}.Matrix;
[scans, NumROIs]  = size(NWM);
set(handles.editroiselect,'String','1');
set(handles.sliderroiselect,'Min',1);
set(handles.sliderroiselect,'Max',NumROIs);
set(handles.sliderroiselect,'Value',1);
set(handles.sliderroiselect,'SliderStep',[1/(NumROIs-1) 1/(NumROIs-1)]);

guidata(hObject, handles); % update handles structure

function varargout = InspectCorrMatrix_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function slidercut_Callback(hObject, eventdata, handles)
value = get(hObject,'Value');
set(handles.edittextcut,'String',num2str(value));
handles.anaobj{handles.CurrentJob}.Ana{handles.anaobj{handles.CurrentJob}.AnaCurrent}.Cut = value;
DisplayMatrix(handles);
guidata(hObject, handles);

function slidercut_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function edittextcut_Callback(hObject, eventdata, handles)
value = str2num(get(hObject,'String'));
set(handles.edittextcut,'String',num2str(value));
set(handles.slidercut,'Value',value);
for isubj=1:length(handles.anaobj)
    handles.anaobj{isubj}.Ana{1}.Cut = value;
end
DisplayMatrix(handles);
guidata(hObject, handles);

function edittextcut_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%           Display connectivity matrix and histograms                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function DisplayMatrix(handles)
NWM     = handles.anaobj{handles.CurrentJob}.Ana{1}.Matrix;
NumROIs = size(NWM,1);
cut     = handles.anaobj{handles.CurrentJob}.Ana{1}.Cut;
NWM     = (NWM>cut).*NWM;
imshow(NWM,'DisplayRange',[],'Parent',handles.axes1);
colormap(jet);
set(handles.editcost,'String',num2str(nnz(NWM)));
DisplayHistW(handles);
DisplayHistC(handles);
ROItable(handles);
DisplayHistROICorrCoeff(handles);
DisplayTableROI(handles);

%
%  ROI correlation coefficients
%
function DisplayHistROICorrCoeff(handles)
NWM        = handles.anaobj{handles.CurrentJob}.Ana{1}.Matrix;
NumROIs    = handles.anaobj{handles.CurrentJob}.Ana{1}.Configure.ROI.Num;
nROI       = round(str2double(get(handles.editroiselect,'String')));
w          = NWM(nROI,:);
axes(handles.axes5);
hist(w);
title(sprintf('correlation coefficients for %s',handles.anaobj{handles.CurrentJob}.Ana{1}.Configure.ROI.Names{nROI}));
xlabel('correlation coefficient');
ylabel('number');

%
NumSubjects = size(handles.anaobj,2);
for idx=1:NumSubjects, % loop over subjects
  NWM = handles.anaobj{idx}.Ana{handles.anaobj{handles.CurrentJob}.AnaCurrent}.Matrix;
  w = NWM(nROI,:);
  meancorrcoeff(idx)=mean(w);
  stdcorrcoeff(idx)=std(w); 
end % end loop over subjects

axes(handles.axes6);
plot(meancorrcoeff,'+-');
title(sprintf('mean correlation coefficient for %s',handles.anaobj{handles.CurrentJob}.Ana{1}.Configure.ROI.Names{nROI}));
xlabel('subjects');
ylabel('correlation coefficients');

%
% table for selected ROI (connections)
%
function DisplayTableROI(handles)
NWM     = handles.anaobj{handles.CurrentJob}.Ana{1}.Matrix;
NumROIs = handles.anaobj{handles.CurrentJob}.Ana{1}.Configure.ROI.Num;
cut     = handles.anaobj{handles.CurrentJob}.Ana{1}.Cut;
nROI    = round(str2double(get(handles.editroiselect,'String')));

k=0;
for j=1:NumROIs,
   if NWM(nROI,j)>=cut
       k=k+1;  
       ROInames(k)    = cellstr(handles.anaobj{handles.CurrentJob}.Ana{1}.Configure.ROI.Names{j});
       tableData(k,2) = round(100*NWM(nROI,j))/100;
       tableData(k,1) = j;
   end
end

if k>0
set(handles.tableroi,'RowName',cell(ROInames));
columnHeaders = {'Index','Correlation'};
set(handles.tableroi,'ColumnName',columnHeaders);
set(handles.tableroi,'data',tableData);
% display degree of selected ROI
set(handles.editnumcorr,'String',num2str(k-1));
end

%
% histogram: correlations
%
function DisplayHistW(handles)
NWM = handles.anaobj{handles.CurrentJob}.Ana{1}.Matrix;
axes(handles.axes2);
hist(NWM(:));
title('correlation coefficients');
xlabel('correlation coefficient');
ylabel('number');

bs = handles.anaobj{handles.CurrentJob}.Ana{1}.BetaSeries;
axes(handles.axes7);
plot(mean(bs,2));
xlabel('beta-series');
ylabel('beta-value');
title('mean ROI beta-series');

function DisplayHistC(handles)
axes(handles.axes3);
GM = [];
for i=1:length(handles.anaobj{handles.CurrentJob}.GlobalMean)
  GM = [GM handles.anaobj{handles.CurrentJob}.GlobalMean{i}'];
end
plot(GM);
title('global mean time course');
xlabel('scan');
ylabel('signal [a.u.]');

%
% ROI table
%

function ROItable(handles)
set(handles.uitablerois,'RowName',handles.anaobj{handles.CurrentJob}.Ana{1}.Configure.ROI.Names);
columnHeaders = {'Index','Degree'};
set(handles.uitablerois,'ColumnName',columnHeaders);
NWM     = handles.anaobj{handles.CurrentJob}.Ana{1}.Matrix;
NumROIs = handles.anaobj{handles.CurrentJob}.Ana{1}.Configure.ROI.Num;
cut     = handles.anaobj{handles.CurrentJob}.Ana{1}.Cut;
tableData = [ zeros(NumROIs,2) ];
for i=1:NumROIs,
 tableData(i,1)=i; 
 for j=1:NumROIs,
     val = 0;
     if NWM(i,j)>=cut
         tableData(i,2)=tableData(i,2)+1;
     end
 end
end
set(handles.uitablerois,'data',tableData);

function popupmenuselectmatrix_Callback(hObject, eventdata, handles)
index = get(hObject,'Value');
handles.anaobj{handles.CurrentJob}.AnaCurrent = index; % set current matrix
set(handles.edittextcut,'String',num2str(handles.anaobj{handles.CurrentJob}.Ana{index}.Cut));
set(handles.slidercut,'Value',handles.anaobj{handles.CurrentJob}.Ana{index}.Cut);
disp(sprintf('Current matrix: %d (cut %f)',handles.anaobj{handles.CurrentJob}.AnaCurrent,handles.anaobj{handles.CurrentJob}.Ana{index}.Cut));
DisplayMatrix(handles);
guidata(hObject, handles);

function popupmenuselectmatrix_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function popupmenuselectjob_Callback(hObject, eventdata, handles)
index = get(hObject,'Value');
handles.CurrentJob = index; % set current job
set(handles.edittextcut,'String',num2str(handles.anaobj{handles.CurrentJob}.Ana{1}.Cut));
set(handles.slidercut,'Value',handles.anaobj{handles.CurrentJob}.Ana{1}.Cut);
disp(sprintf('Current job: %d (cut %f)',handles.CurrentJob,handles.anaobj{handles.CurrentJob}.Ana{1}.Cut));
DisplayMatrix(handles);
guidata(hObject, handles);

function popupmenuselectjob_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function sliderroiselect_Callback(hObject, eventdata, handles)
idx = round(get(hObject,'Value')); % index of selected ROI
set(handles.editroiselect,'String',num2str(idx));
DisplayMatrix(handles);

function sliderroiselect_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function editroiselect_Callback(hObject, eventdata, handles)
[scans, NumROIs] = size(handles.anaobj{handles.CurrentJob}.Ana{handles.anaobj{handles.CurrentJob}.AnaCurrent}.Matrix);
idx = round(str2double(get(hObject,'String'))); % index of selected ROI
if idx>NumROIs
   disp('<editroiselect_Callback> : Index out of bounds.');
   set(hObject,'String',num2str(NumROIs));
   return; 
end
set(hObject,'String',num2str(idx));
set(handles.sliderroiselect,'Value',idx);
DisplayMatrix(handles);

function editroiselect_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editnumcorr_Callback(hObject, eventdata, handles)
function editnumcorr_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editcost_Callback(hObject, eventdata, handles)
function editcost_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pushbuttonshowroi_Callback(hObject, eventdata, handles)
NWM     = handles.anaobj{handles.CurrentJob}.Ana{1}.Matrix;
NumROIs = handles.anaobj{handles.CurrentJob}.Ana{1}.Configure.ROI.Num;
cut     = handles.anaobj{handles.CurrentJob}.Ana{1}.Cut;
nROI    = round(str2double(get(handles.editroiselect,'String')));
path    = handles.anaobj{handles.CurrentJob}.Ana{1}.Configure.ROI.Path;
k=0;
for j=1:NumROIs
   if NWM(nROI,j)>=cut
       k=k+1;  
       ROIFiles{k} = fullfile(handles.anaobj{handles.CurrentJob}.Ana{1}.Configure.ROI.File{j});
   end
end
mars_display_roi('display',ROIFiles);

%
% motion regressors
%
function pushbuttoncheckmotionartefacts_Callback(hObject, eventdata, handles)
anaobj = handles.anaobj{handles.CurrentJob}; 
NumRuns = size(anaobj.RealignmentParameters,2);
%if(NumRuns>1)
    figure('Name','motion regressors');
    for irun=1:NumRuns
       subplot(2,2,irun);
       var = anaobj.RealignmentParameters{irun};
       MotX   = [ var(:,1:6) ];
       modMotX(:,1) = MotX(:,1);
       modMotX(:,2) = MotX(:,2);
       modMotX(:,3) = MotX(:,3);
       modMotX(:,4) = 50*MotX(:,4);
       modMotX(:,5) = 50*MotX(:,5);
       modMotX(:,6) = 50*MotX(:,6);
       plot(modMotX);
       title(sprintf('motion regressors run %d',irun));
       xlabel('scan');
       legend('x','y','z','r','p','y');
    end
%end

%
% global mean time course
%
function pushbuttonglobalmean_Callback(hObject, eventdata, handles)
isubj = handles.CurrentJob;
condind = handles.anaobj{isubj}.Ana{1}.ConditionIndices; % indices of selected conditions
regcond = handles.anaobj{isubj}.Ana{1}.AnaDef.RegCond;   % regressor <-> condition

DataPath = handles.anaobj{isubj}.Ana{1}.AnaDef.DataPath;
Outdir   = handles.anaobj{isubj}.Ana{1}.AnaDef.OutDir;
spmpath  = fullfile(DataPath,Outdir);
spmfile  = 'SPM.mat';

% load design matrix
load(fullfile(spmpath,spmfile));
X = [SPM.xX.X];
%Xs = spm_DesMtx('sca',X);
%figure('Name','SPM design matrix');
%colormap('gray');
%image((Xs+1)*32);
%title(sprintf('SPM design matrix '));
%xlabel('regressors');
%ylabel('scans');

[NumScans, NumRegr] = size(X);
Nruns    = length(SPM.Sess);
NScan    = NumScans/Nruns;                             % number of scans per run
Ncondvec = str2num(SPM.xsDes.Trials_per_session);      % number of trials per session
Ncond    = Ncondvec(1);
Nmotr    = (NumRegr-(Nruns*(1+Ncond)))/Nruns;          % number of regressors excluding conditions/trials/stimuli
Nreg     = Ncond+Nmotr;                                % number of regressors per run

Prefix   = handles.anaobj{isubj}.Ana{1}.AnaDef.Prefix;
NumRuns  = handles.anaobj{isubj}.Ana{1}.AnaDef.NumRuns;
IDRuns   = handles.anaobj{isubj}.Ana{1}.AnaDef.RunDirs;

for irun=1:NumRuns
  figure('Name',sprintf('global mean time courses subject %d (run %d)',isubj,irun));

  % global time courses
  TC{irun} = handles.anaobj{isubj}.GlobalMean{irun};
  subplot(2,1,1);
  plot([1:1:NScan],TC{irun},'-');
  title(sprintf('global mean time course subject %d (run %d)',isubj,irun));
  xlabel('scan');
  ylabel('signal [a.u.]');
 
  % motion
  subplot(2,1,2);
  var = handles.anaobj{isubj}.RealignmentParameters{irun};
  MotX   = [ var(:,1:6) ];
  dMotX = DiffTimeCourse(MotX);
  dMotX(:,4) = 50*dMotX(:,4);
  dMotX(:,5) = 50*dMotX(:,5);
  dMotX(:,6) = 50*dMotX(:,6);
  FD = sum(abs(dMotX),2);
  plot([1:1:NScan],FD,'k-',[1:1:NScan],0.5*ones(1,NScan),'g--');
  title('motion');
  xlabel('scan');
  ylabel('motion [a.u.]');
  
end

% fluctuations in global mean time course
figure('Name',sprintf('global mean time course fluctuation (subject %d)',isubj));
for irun=1:NumRuns % signal fluctuation
    
   Y = handles.anaobj{isubj}.GlobalMean{irun};
   % detrending
   % 'design matrix' X for regression
   % Y = X * B (Y: signal as a function of scan-number)
   % B = pinv(X'*X)*X' * Y <- least squares solution
   X = [ ones(NScan,1) [1:1:NScan]' ([1:1:NScan].*[1:1:NScan])'];
   B = pinv(X'*X)*X'*Y;  
   e = Y - X*B;
   E = X*B; % estimated
   
   subplot(3,2,2*irun-1);
   plot([1:1:NScan],Y,'b-',[1:1:NScan],E,'r-');
   ylabel('global mean time course');
   xlabel('scan');
   title(sprintf('global mean time course run %d',irun)); 
   legend('time course','detrending');
   
   subplot(3,2,2*irun);
   plot([1:1:NScan],100*(e./E),'x',[1:1:NScan],0.5*ones(1,NScan),'g--',[1:1:NScan],-0.5*ones(1,NScan),'g--');
   ylabel('relative deviation [%]');
   xlabel('scan');
   title('relative deviation [%]');
   
end
function dX = DiffTimeCourse(X)
% input:
%         X: matrix(rows: T time points, columns: N time courses)
% output: differentiated time courses
%
M = X'; % rows: different time courses ; columns: time
[N, T] = size(M);
M1 = zeros(N, T+1);
M2 = zeros(N, T+1);
M2(:,1:end-1) = M(:,:);
M1(:,2:end)   = M(:,:);
tmp         = M2-M1;
dM          = zeros(N,T);
dM          = tmp(:,1:end-1);
dM(:,1)     = 0;
dX=dM';
