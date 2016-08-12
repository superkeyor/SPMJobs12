function varargout = InspectROIBetaSeries(varargin) 
% Inspect ROI beta-series for data quality control.
% input: analysis objects (uses field BetaSeries)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @InspectROIBetaSeries_OpeningFcn, ...
                   'gui_OutputFcn',  @InspectROIBetaSeries_OutputFcn, ...
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

function InspectROIBetaSeries_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
handles.anaobj = varargin{1}; % the analysis object
handles.show  = true;       % show second beta series
set(handles.checkboxshow,'Value',handles.show);
handles.CurrentJob = 1;
for i=1:size(handles.anaobj,2),
   handles.anaobj{i}.AnaCurrent = 1;
end
guidata(hObject, handles);
DisplayTimeCourseCompare(handles,1,2);

% configure slider etc
[scans, NumROIs]  = size(handles.anaobj{1}.Ana{1}.BetaSeries);
set(handles.editroiselect,'String','1');
set(handles.sliderroiselect,'Min',1);
set(handles.sliderroiselect,'Max',NumROIs);
set(handles.sliderroiselect,'Value',1);
set(handles.sliderroiselect,'SliderStep',[1/(NumROIs-1) 1/(NumROIs-1)]);

set(handles.editroiselectCompare,'String','2');
set(handles.sliderroiselectCompare,'Min',1);
set(handles.sliderroiselectCompare,'Max',NumROIs);
set(handles.sliderroiselectCompare,'Value',2);
set(handles.sliderroiselectCompare,'SliderStep',[1/(NumROIs-1) 1/(NumROIs-1)]);

corrcoef = handles.anaobj{1}.Ana{handles.anaobj{1}.AnaNum}.Matrix(1,2);
set(handles.editcorrelation,'String',num2str(corrcoef));

% configure pup-up menus
for i=1:size(handles.anaobj,2),
    if handles.anaobj{i}.Ana{1}.Configure.UseSPMDesign==true
      list3{i}=sprintf('%d %s',i,handles.anaobj{i}.Ana{1}.Configure.spmdesignpath);
    else
      list3{i}=sprintf('%d %s',i,handles.anaobj{i}.Ana{1}.Configure.datapath); 
    end
end
set(handles.popupmenuselectjob,'String',list3);

function varargout = InspectROIBetaSeries_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function sliderroiselect_Callback(hObject, eventdata, handles)
idx = round(get(hObject,'Value')); % index of selected ROI
set(handles.editroiselect,'String',num2str(idx));
DisplayTimeCourseCompare(handles,idx,round(get(handles.sliderroiselectCompare,'Value')));

function sliderroiselect_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function editroiselect_Callback(hObject, eventdata, handles)
[scans, NumROIs]  = size(handles.anaobj{handles.CurrentJob}.Ana{1}.BetaSeries);
idx = round(str2double(get(hObject,'String'))); % index of selected ROI
if idx>NumROIs
   disp('<editroiselect_Callback> : Index out of bounds.');
   set(hObject,'String',num2str(NumROIs));
   return; 
end
set(hObject,'String',num2str(idx));
set(handles.sliderroiselect,'Value',idx);
DisplayTimeCourseCompare(handles,idx,round(get(handles.sliderroiselectCompare,'Value')));

function editroiselect_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function sliderroiselectCompare_Callback(hObject, eventdata, handles)
idx = round(get(hObject,'Value')); % index of selected ROI
set(handles.editroiselectCompare,'String',num2str(idx));
DisplayTimeCourseCompare(handles,round(get(handles.sliderroiselect,'Value')),round(idx));

function sliderroiselectCompare_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function editroiselectCompare_Callback(hObject, eventdata, handles)

[scans, NumROIs]  = size(handles.anaobj{handles.CurrentJob}.Ana{1}.BetaSeries);
idx = round(str2double(get(hObject,'String'))); % index of selected ROI
if idx>NumROIs
   disp('<editroiselectCompare_Callback> : Index out of bounds.');
   set(hObject,'String',num2str(NumROIs));
   return; 
end
set(hObject,'String',num2str(idx));
set(handles.sliderroiselectCompare,'Value',idx);
DisplayTimeCourseCompare(handles,round(get(handles.sliderroiselect,'Value')),idx);

function editroiselectCompare_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function DisplayTimeCourseCompare(handles,idx1,idx2)
currentana = handles.anaobj{handles.CurrentJob}.AnaCurrent;
bs         = handles.anaobj{handles.CurrentJob}.Ana{currentana}.BetaSeries;
NWM        = handles.anaobj{handles.CurrentJob}.Ana{currentana}.Matrix;
[N, NumROIs] = size(bs);

if idx1>NumROIs | idx2>NumROIs
   disp('<DisplayTimeCourseCompare> : Index out of bounds.');
   return; 
end

idx1 = round(idx1);
idx2 = round(idx2);
axes(handles.axes);
if handles.show==true
  plot([1:N],bs(:,idx1),'+-',[1:N],bs(:,idx2),'+-');
  roiname1 = handles.anaobj{handles.CurrentJob}.Ana{currentana}.Configure.ROI.Names{idx1};
  roiname2 = handles.anaobj{handles.CurrentJob}.Ana{currentana}.Configure.ROI.Names{idx2};
  legend(roiname1,roiname2);
else
  plot([1:N],bs(:,idx1),'+-');
  roiname1 = handles.anaobj{handles.CurrentJob}.Ana{currentana}.Configure.ROI.Names{idx1};
  legend(roiname1);  
end
title('');
xlabel('beta-series');
ylabel('beta-value');

set(handles.editcorrelation,'String',NWM(idx1,idx2));  % show correlation coefficient

corrmat  = corrcoef(bs(:,idx1),bs(:,idx2));

% show scatter plot?
val = get(handles.checkboxscatterplot,'Value');
if val==true
  ScatterPlot(handles);
  figure(handles.figure1);
  
  % outlier rejection
  zthr   = 2.0;
  bs1    = bs(:,idx1);
  bs2    = bs(:,idx2);  
  ztrbs1 = abs(bs1-mean(bs1))./std(bs1);
  ztrbs2 = abs(bs2-mean(bs2))./std(bs2);
  ztrmax = max([ztrbs1'; ztrbs2']);
  inidx  = find(ztrmax<zthr);
  [rho1,pval1] = corr(bs1,bs2);
  [rho2,pval2] = corr(bs1(inidx),bs2(inidx));
  fprintf('Rejected outlier (%.2f --- %d): %.2f -> %.2f \n',zthr,length(bs1)-length(inidx),rho1,rho2);
  
end

function editcorrelation_Callback(hObject, eventdata, handles)
function editcorrelation_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function checkboxshow_Callback(hObject, eventdata, handles)
handles.show = get(hObject,'Value');
idx1 = round(get(handles.sliderroiselect,'Value'));
idx2 = round(get(handles.sliderroiselectCompare,'Value'));
DisplayTimeCourseCompare(handles,idx1,idx2);
guidata(hObject, handles);

function popupmenuselectjob_Callback(hObject, eventdata, handles)
index = get(hObject,'Value');
handles.CurrentJob = index; % set current job
disp(sprintf('Current job: %d (cut %f)',handles.CurrentJob,handles.anaobj{handles.CurrentJob}.Ana{1}.Cut));
DisplayTimeCourseCompare(handles,get(handles.sliderroiselect,'Value'),get(handles.sliderroiselectCompare,'Value'));
guidata(hObject, handles);

function popupmenuselectjob_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function checkboxscatterplot_Callback(hObject, eventdata, handles)
val = get(hObject,'Value');
if val==true
  idx1 = round(get(handles.sliderroiselect,'Value'));
  idx2 = round(get(handles.sliderroiselectCompare,'Value'));
  handles.hfig = figure('Name','scatter plot');
  ScatterPlot(handles);
else
    try
      close(handles.hfig);
    end
end
guidata(hObject, handles);

function ScatterPlot(handles)
figure(handles.hfig);
hold off;
currentana = 1;
bs   = handles.anaobj{handles.CurrentJob}.Ana{currentana}.BetaSeries;
idx1 = round(get(handles.sliderroiselect,'Value'));
idx2 = round(get(handles.sliderroiselectCompare,'Value'));
roiname1 = handles.anaobj{handles.CurrentJob}.Ana{currentana}.Configure.ROI.Names{idx1};
roiname2 = handles.anaobj{handles.CurrentJob}.Ana{currentana}.Configure.ROI.Names{idx2};
scatter(bs(:,idx1),bs(:,idx2),'filled'); grid on; hold on;
title(sprintf('ROI %d vs ROI %d',idx1,idx2));
xlabel(sprintf('beta values for %s',roiname1));
ylabel(sprintf('beta values for %s',roiname2));
brob = robustfit(bs(:,idx1),bs(:,idx2));
plot(bs(:,idx1),brob(1)+brob(2)*bs(:,idx1),'g','LineWidth',2);
hold on;
lsline;
legend('data',sprintf('robust fit (slope: %.2f)',brob(2)),'least-squares fit');
