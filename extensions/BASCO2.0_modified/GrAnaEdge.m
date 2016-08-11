function varargout = GrAnaEdge(varargin)
% functional connectivity analysis (edges)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GrAnaEdge_OpeningFcn, ...
                   'gui_OutputFcn',  @GrAnaEdge_OutputFcn, ...
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

function GrAnaEdge_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
% get input (command line options)
handles.ana = varargin{1};
handles.leg = varargin{2};
disp('<GrAnaEdges> : Starting tool for connectivity analysis.');

% check if analyses are compatible
NumAna = size(handles.ana,2);
if NumAna~=2 | handles.ana{1}{1}.Ana{1}.Configure.ROI.Num~=handles.ana{2}{1}.Ana{1}.Configure.ROI.Num
   disp('<GrAnaEdges> : Analyses not compatible!');
   return;
end

handles.NumNodes = size(handles.ana{1}{1}.Ana{1}.Matrix,1);
handles.Names    = handles.ana{1}{1}.Ana{1}.Configure.ROI.Names;
handles.TheAna   = 1;

NumAna1 = size(handles.ana{1},2);
NumAna2 = size(handles.ana{2},2);
set(handles.editgroupA,'String',sprintf('group/condition 1: %s %d',handles.leg{1},NumAna1));
set(handles.editgroupB,'String',sprintf('group/condition 2: %s %d',handles.leg{2},NumAna2));

result = RetrieveCorrelationCoefficients(handles);
handles.Amean       = result.Amean;
handles.Astd        = result.Astd;
handles.Aweights    = result.Aweights;   % (row: edge, column: subject)
handles.Bmean       = result.Bmean; 
handles.Bstd        = result.Bstd;
handles.Bweights    = result.Bweights;   % (row: edge, column: subject)
handles.indexNode1  = result.indexNode1;
handles.indexNode2  = result.indexNode2;
handles.NumEdges    = result.NumEdges;

clear result;
NumBoot = str2num(get(handles.editnumbootstraptests,'String'));
result  = PerformStatisticalTests(handles.Aweights,handles.Bweights,NumBoot,1);
handles.Prob             = result.Prob;
handles.Prob_ttest2      = result.Prob_ttest2;

% configure popupmenus
list{1}='two-sample t-test'; 
list{2}='paired t-test';
list{3}='permutation test';
list{4}='one-sided +';
list{5}='one-sided -';
set(handles.popupmenustattest,'String',list);
Names = handles.ana{1}{1}.Ana{1}.Configure.ROI.Names;
set(handles.popupmenuselectseedregion,'String',Names);

% plot
handles.counter = Plot(handles);

guidata(hObject, handles);

function varargout = GrAnaEdge_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;
function editprobcut_Callback(hObject, eventdata, handles)
handles.counter = Plot(handles);
guidata(hObject, handles);
function editprobcut_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editnumsigedges_Callback(hObject, eventdata, handles)
function editnumsigedges_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popupmenustattest_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editgroupA_Callback(hObject, eventdata, handles)
function editgroupA_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editgroupB_Callback(hObject, eventdata, handles)
function editgroupB_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editnumbootstraptests_Callback(hObject, eventdata, handles)
function editnumbootstraptests_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editFDR_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popupmenuselectseedregion_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function popupmenustattest_Callback(hObject, eventdata, handles)
NumBoot  = str2num(get(handles.editnumbootstraptests,'String'));
StatTest = get(hObject,'Value');
result   = PerformStatisticalTests(handles.Aweights,handles.Bweights,NumBoot,StatTest);
handles.Prob        = result.Prob;
handles.Prob_ttest2 = result.Prob_ttest2;
% plot
guidata(hObject, handles);
handles.counter = Plot(handles);

function pushbuttoncorrelationcoefficients_Callback(hObject, eventdata, handles)
% plot correlation coefficients
ProbCut = str2double(get(handles.editprobcut,'String'));
disp(sprintf('Probability threshold: %f',ProbCut));
counter    = 0;
wincounter = 0;
SEED   = get(handles.checkboxseedbasedanalysis,'Value');
seednr = get(handles.popupmenuselectseedregion,'Value');
for i=1:handles.NumEdges,
      if SEED 
          if handles.indexNode1(i)~=seednr & handles.indexNode2(i)~=seednr
             continue;
          end
      end
      theprob = handles.Prob(i);   
      if theprob<=ProbCut
         if mod(counter,9)==0
           figure('Name',sprintf('Distribution of correlation coefficients %d',mod(counter,9)));
           wincounter = 0;
         end
         counter = counter +1;
         wincounter = wincounter+1;
         subplot(3,3,wincounter);
         hist(handles.Aweights(i,:),[-1:0.1:1]);
         hold on;
         hist(handles.Bweights(i,:),[-1:0.1:1]);
         h = findobj(gca,'Type','patch');
         set(h(2),'FaceColor','w','EdgeColor','b','facealpha',0.75,'LineWidth',2);
         set(h(1),'FaceColor','w','EdgeColor','r','facealpha',0.75,'LineWidth',2,'LineStyle','-.');
         title(sprintf('%s and %s (p=%f)',handles.Names{handles.indexNode1(i)},handles.Names{handles.indexNode2(i)},theprob));
         xlabel('correlation coefficients');
         ylabel('number of subjects');
         legend(handles.leg{1},handles.leg{2});
      end
end % end loop over edges

%
% Seed based analysis
%
function checkboxseedbasedanalysis_Callback(hObject, eventdata, handles)
SEED   = get(handles.checkboxseedbasedanalysis,'Value');
seednr = get(handles.popupmenuselectseedregion,'Value');
if SEED==true
    handles.Prob_seed = [];
    handles.Prob_ttest2_seed = [];
    k=0;
    for i=1:handles.NumEdges,
         if handles.indexNode1(i)~=seednr & handles.indexNode2(i)~=seednr
             continue;
         end
         k=k+1;
         handles.Prob_seed(k)             = handles.Prob(i);
         handles.Prob_ttest2_seed(k)      = handles.Prob_ttest2(i);   
    end
end
guidata(hObject, handles);
Plot(handles);

% --- Select seed-region
function popupmenuselectseedregion_Callback(hObject, eventdata, handles)
SEED     = get(handles.checkboxseedbasedanalysis,'Value');
seednr   = get(handles.popupmenuselectseedregion,'Value');
StatTest = get(handles.popupmenustattest,'Value');
StatStr  = get(handles.popupmenustattest,'String');
if SEED==false
   return; 
end
handles.Prob_seed = [];
handles.Prob_ttest2_seed = [];
k=0;
for i=1:handles.NumEdges
     if handles.indexNode1(i)~=seednr & handles.indexNode2(i)~=seednr
         continue;
     end
     k=k+1;
     handles.Prob_seed(k)             = handles.Prob(i);
     handles.Prob_ttest2_seed(k)      = handles.Prob_ttest2(i); 
end
guidata(hObject, handles);
Plot(handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function counter = Plot(handles)
StatTest = get(handles.popupmenustattest,'Value');
StatStr  = get(handles.popupmenustattest,'String');
ProbCut = str2double(get(handles.editprobcut,'String'));
fprintf('Probability threshold: %f \n',ProbCut);
% seed-based analysis?
SEED   = get(handles.checkboxseedbasedanalysis,'Value');
seednr = get(handles.popupmenuselectseedregion,'Value');
if SEED 
    fprintf('Seed region: %d \n',seednr);
end
counter = 0;
for i=1:handles.NumEdges
      if SEED 
          if handles.indexNode1(i)~=seednr & handles.indexNode2(i)~=seednr
             continue;
          end
      end
      theprob = handles.Prob(i);
      if theprob<=ProbCut
         counter = counter +1;
         strn1 = strtrim(handles.Names{handles.indexNode1(i)});
         strn2 = strtrim(handles.Names{handles.indexNode2(i)});
         n1max = length(strn1);
         n2max = length(strn2);
         if n1max>20
             n1max=20;
         end
         if n2max>20
             n2max=20;
         end        
         Edgenames(counter)   = cellstr(sprintf('%s <-> %s',strn1(1:n1max),strn2(1:n2max)));
         if StatTest==3
           tableData(counter,1) = handles.Prob(i);
           tableData(counter,2) = handles.Amean(i);
           tableData(counter,3) = handles.Bmean(i);  
         else
           tableData(counter,1) = handles.Prob_ttest2(i);
           tableData(counter,2) = handles.Prob(i);
           tableData(counter,3) = handles.Amean(i);
           tableData(counter,4) = handles.Bmean(i); 
         end
      end
end

% display table with edges which are significantly different
if counter>0
  set(handles.tableedges,'RowName',cell(Edgenames));
  if get(handles.popupmenustattest,'Value')==3
      columnHeaders = {'paired t-test',handles.leg{1},handles.leg{2}}; 
  else
      columnHeaders = {'t-test',StatStr{StatTest},handles.leg{1},handles.leg{2}};
  end
  set(handles.tableedges,'ColumnName',columnHeaders);
  set(handles.tableedges,'data',tableData);
else
  Edgenames(1)   = cellstr('no edge below threshold');
  tableData(1,1) = 0;
  tableData(1,2) = 0;
  tableData(1,3) = 0;
  tableData(1,4) = 0; 
  set(handles.tableedges,'RowName',cell(Edgenames));
  columnHeaders = {'t-test','bootstrapping',handles.leg{1},handles.leg{2}}; 
  set(handles.tableedges,'ColumnName',columnHeaders);
  set(handles.tableedges,'data',tableData);  
end

if SEED==false
   set(handles.editnumsigedges,'String',sprintf('Number of significant edges: %d (of %d, fraction: %f, expected: %.1f)',counter,handles.NumEdges,counter/handles.NumEdges,ProbCut*handles.NumEdges));
end
if SEED==true
   set(handles.editnumsigedges,'String',sprintf('Number of significant edges: %d (of %d, fraction: %f, expected: %.1f)',counter,handles.NumNodes-1,counter/(handles.NumNodes-1),ProbCut*(handles.NumNodes-1)));
end

% plot probability
figure(handles.figure1);
subplot(1,1,1,'Parent',handles.uipanelprob);
if SEED==false
    if StatTest==3 % paired t-test
      hold off;
      hist(handles.Prob,[0:0.02:1]);  
    else
      hold off;
      hist(handles.Prob,[0:0.02:1]);
      hold on;
      hist(handles.Prob_ttest2,[0:0.02:1]);
    end
    Nentr=length(handles.Prob);
end
if SEED==true
   if StatTest==3 % paired t-test   
     hold off;
     hist(handles.Prob_seed,[0:0.02:1]);    
   else    
     hold off;  
     hist(handles.Prob_seed,[0:0.05:1]);
     hold on;
     hist(handles.Prob_ttest2_seed,[0:0.05:1]);
   end
   Nentr=length(handles.Prob_seed);
end

if get(handles.popupmenustattest,'Value')==3 
  title('p distribution');
  ylabel('number of edges');
  xlabel('probability');
else
  h = findobj(gca,'Type','patch');
  set(h(2),'FaceColor','w','EdgeColor','b','facealpha',0.75,'LineWidth',2);
  set(h(1),'FaceColor','w','EdgeColor','r','facealpha',0.75,'LineWidth',2,'LineStyle','-.');  
  title(sprintf('p distribution group differences (A vs B) (%d)',Nentr));
  ylabel('number of edges');
  xlabel('probability');
  legend(StatStr{StatTest},'two-sample t-test');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function results = RetrieveCorrelationCoefficients(handles)
disp('<GrAnaEdges::RetrieveCorrelationCoefficients> : Retrieving correlation coefficients ...');
tic
N      = handles.NumNodes;
theind = find(triu(ones(N,N),1));
results.NumEdges = length(theind);
[ results.indexNode1 results.indexNode2 ] = ind2sub(N,theind);
disp(sprintf('<GrAnaEdges::RetrieveCorrelationCoefficients> : Nodes %d ----- Edges %d (symmetric matrix)',N,results.NumEdges));
[results.Amean results.Astd results.Aweights] = MeanCorrCoef(handles.ana{1},theind);
[results.Bmean results.Bstd results.Bweights] = MeanCorrCoef(handles.ana{2},theind); 
toc
disp('<GrAnaEdges::RetrieveCorrelationCoefficients> : ... done.');

function [themean, thestd, edgeweights] = MeanCorrCoef(anaobj,theind)
% edgeweights(edge,subject)
NumSubj = size(anaobj,2);
edgeweights = zeros(length(theind),NumSubj); % correlation coefficients for different jobs
size(edgeweights)
for idx=1:NumSubj % loop over jobs
    try
      edgeweights(:,idx) = anaobj{idx}.Ana{1}.Matrix(theind)';  
    catch
        fprintf('Wrong number of edges. Subject: %d \n',idx);
        size(anaobj{idx}.Ana{1}.Matrix)
    end
end
themean = mean(edgeweights');
thestd  = std(edgeweights');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function results = PerformStatisticalTests(Amat,Bmat,Num,StatTest)
% input: matrix (rows: edges, columns: subjects)
disp('<GrAnaEdges::PerformStatisticalTests> : Statistical test for group differences ...');
tic
Prob_ttest2              = mattest(Amat,Bmat); % two-tailed two-sample t-test
results.Prob_ttest2      = Prob_ttest2';
results.Prob             = Prob_ttest2';
if StatTest==2 % paired t-test
    disp('<GrAnaEdges::PerformStatisticalTests> : Performing paired t-test ...');
    if size(Amat,2)==size(Bmat,2)
        for iedge=1:size(Amat,1)
            [htmp, Prob_pairedttest(iedge)]= ttest(Amat(iedge,:),Bmat(iedge,:));
        end
    else
        disp('<GrAnaEdges::PerformStatisticalTests> : Error. Different number of subjects! Bailing out!');
        return;
    end
    results.Prob = Prob_pairedttest;
end
if StatTest==3 % permutation test
     fprintf('<GrAnaEdges::PerformStatisticalTests> : Performing permutation test. Number of permutations: %d \n',Num);
     Prob_perm    = mattest(Amat,Bmat,'Permute',Num); % permutation test
     results.Prob = Prob_perm';
end
if StatTest==4 % one-sided test
    disp('<GrAnaEdges::PerformStatisticalTests> : two-sample t-test  - tail right');
    [h, Prob_right] = ttest2(Amat',Bmat',[],'right');
    results.Prob     = Prob_right';
end
if StatTest==5 % one-sided test
    disp('<GrAnaEdges::PerformStatisticalTests> : two-sample t-test  - tail left');
    [h, Prob_left] = ttest2(Amat',Bmat',[],'left');
    results.Prob    = Prob_left';
end
toc
disp('<GrAnaEdges::PerformStatisticalTests> : ... done');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% p-value adjustment using FDR/ Bonferroni FWE                      %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pushbutton_FDR_Callback(hObject, eventdata, handles)
storey=true;

qcut  = str2double(get(handles.editFDR,'String'));
SEED  = get(handles.checkboxseedbasedanalysis,'Value');
if SEED==true
    p = handles.Prob_seed;
    fprintf('Analysis restricted to single seed region. Number of statistical tests: %d \n',length(p));
else
    p = handles.Prob; 
    fprintf('Number of statistical tests: %d \n',length(p));
end

if storey
    disp('FDR correction (Storey, 2002; as implemented in MATLAB mafdr-function).');
    figure('Name','mafdr');
    [fdr, q] = mafdr(p,'showplot',true);
    padj     = max(p(find(q<=qcut)));
    fprintf('Adjusted p-value: %f.  \n',padj);
else
    disp('Method for FDR correction: Benjamini and Hochberg, 1995');
    figure('Name','MAFDR');
    mafdr_fdr   = mafdr(p,'BHFDR',true,'showplot',true);
    significant = mafdr_fdr<=qcut;
    padj        = max(p(find(mafdr_fdr<=qcut)));
    fprintf('=====>> FDR correction: q < %f \n',qcut);
    if length(padj)==0
        disp('No node survived FDR correction.');
        return;
    else
        fprintf('Adjusted p-threshold (MAFDR): %f \n',padj);
    end
end

set(handles.editprobcut,'String',num2str(padj));
guidata(hObject, handles);
Plot(handles);

function pushbutton_fwe_Callback(hObject, eventdata, handles)
disp('Bonferroni FWE correction.');
q     = str2double(get(handles.editFDR,'String'));
SEED  = get(handles.checkboxseedbasedanalysis,'Value');
if SEED==true
    p = handles.Prob_seed;
    fprintf('Analysis restricted to single seed region. Number of statistical tests: %d \n',length(p));
else
    p = handles.Prob; 
    fprintf('Number of statistical tests: %d \n',length(p));
end
padj  = q/length(p);
set(handles.editprobcut,'String',num2str(padj));
guidata(hObject, handles);
Plot(handles);

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Visualization NW
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function pushbuttonplot_Callback(hObject, eventdata, handles)
if ~isfield(handles.ana{1}{1}.Ana{1}.Configure.ROI,'ROICOM')
    disp('Calculating c.o.m. of nodes ...');
    ROIS      = handles.ana{1}{1}.Ana{1}.Configure.ROI.File;
    NumROIs   = handles.ana{1}{1}.Ana{1}.Configure.ROI.Num;
    % get c.o.m.
    for iroi=1:size(ROIS,1)
        load(strtrim(ROIS{iroi}));
        compos(:,iroi) = c_o_m(roi);
    end
    % short labels of ROIs
    for iroi=1:NumROIs
        shortname = '';
        roiname   = handles.ana{1}{1}.Ana{1}.Configure.ROI.Names{iroi};
        theidx   = findstr(roiname,'_');
        shortname(1)=roiname(1);
        if length(theidx)<3
            shortname(2)=roiname(2);
            shortname(3)=roiname(3);
        end
        for idx=theidx
            shortname(length(shortname)+1) = roiname(idx+1);
        end
        shortlabel{iroi} = shortname;
        fprintf('%s -> %s \n',roiname,shortname);
    end
    
    handles.ana{1}{1}.Ana{1}.Configure.ROI.ROIFILES      = ROIS;
    handles.ana{1}{1}.Ana{1}.Configure.ROI.ROICOM        = compos;
    handles.ana{1}{1}.Ana{1}.Configure.ROI.ROIShortLabel = shortlabel;
end

compos     = handles.ana{1}{1}.Ana{1}.Configure.ROI.ROICOM;
shortlabel = handles.ana{1}{1}.Ana{1}.Configure.ROI.ROIShortLabel;
disp('Creating connectivity matrix (.node and .edge files) ...');
rownames      = get(handles.tableedges,'RowName');
columnnames   = get(handles.tableedges,'ColumnName');
thedata       = get(handles.tableedges,'data');
handles.Names = strtrim(handles.Names);
numrows       = length(rownames);
for irow=1:numrows
    htemp{irow} = textscan(rownames{irow},'%s <-> %s');
    idx1(irow)  = find(strcmp(handles.Names,char(htemp{irow}{1}))==1);
    idx2(irow)  = find(strcmp(handles.Names,char(htemp{irow}{2}))==1);
end
idx = unique([idx1 idx2]);
numnodes = length(idx);
for inodes=1:numnodes
    disp(handles.Names{idx(inodes)});
end
fprintf('Number of nodes: %d \n',numnodes);
nwmatrix = zeros(numnodes,numnodes);
for irow=1:numrows
    fprintf('%d <-> %d : weight=%f \n',find(idx==idx1(irow)),find(idx==idx2(irow)),w);
    nwmatrix(find(idx==idx1(irow)),find(idx==idx2(irow)))=1;
    nwmatrix(find(idx==idx2(irow)),find(idx==idx1(irow)))=1;
end
basco_CreateNodeEdgeFiles(idx,compos,shortlabel,nwmatrix);
disp('Plotting NW ...')
fastBrainNetPlot(idx,compos,nwmatrix,shortlabel);
disp('... done.')

function pushbuttonviewrois_Callback(hObject, eventdata, handles)
% display marsbar ROIs
rownames      = get(handles.tableedges,'RowName');
columnnames   = get(handles.tableedges,'ColumnName');
thedata       = get(handles.tableedges,'data');
handles.Names = strtrim(handles.Names);
numrows       = length(rownames);
for irow=1:numrows
    htemp{irow} = textscan(rownames{irow},'%s <-> %s');
    idx1(irow)  = find(strcmp(handles.Names,char(htemp{irow}{1}))==1);
    idx2(irow)  = find(strcmp(handles.Names,char(htemp{irow}{2}))==1);
end
idx = unique([idx1 idx2]);
% show ROIs
ROIS      = handles.ana{1}{1}.Ana{1}.Configure.ROI.File;
NumROIs   = handles.ana{1}{1}.Ana{1}.Configure.ROI.Num;
selection = zeros(1,NumROIs);
selection(idx) = 1;
DisplayMarsBarROIs(ROIS,selection);

function pushbuttonprinttable_Callback(hObject, eventdata, handles)
% print table
rownames = get(handles.tableedges,'RowName');
thedata  = get(handles.tableedges,'data');
numrows  = length(rownames);
for irow=1:numrows
    htemp{irow} = textscan(rownames{irow},'%s <-> %s');
    roi1 = char(htemp{irow}{1});
    roi2 = char(htemp{irow}{2});
    roi1 = strrep(roi1,'_',' ');
    roi2 = strrep(roi2,'_',' ');
    stdroi1 = '                         ';
    stdroi2 = '                         ';
    stdroi1(1:length(roi1)) = roi1;
    stdroi2(1:length(roi2)) = roi2;
    col=size(thedata,2);
    fprintf('%s \t %s \t %.2f \t %.2f \t %.6f \n',stdroi1,stdroi2,thedata(irow,col-1),thedata(irow,col),thedata(irow,1)); 
end

function edit_corrpval_Callback(hObject, eventdata, handles)
function edit_corrpval_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popupmenu_corrtype_Callback(hObject, eventdata, handles)
function popupmenu_corrtype_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popupmenu_corrtail_Callback(hObject, eventdata, handles)
function popupmenu_corrtail_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
