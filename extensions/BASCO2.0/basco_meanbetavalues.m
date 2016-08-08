function handles = basco_meanbetavalues(handles) 

% mean beta-values for ROIs
NumSubj   = handles.NumJobs;
fprintf('Number of subjects: %d \n',NumSubj);
NumNodes  = size(handles.anaobj{1}.Ana{1}.BetaSeries,2);
Names     = handles.anaobj{1}.Ana{1}.Configure.ROI.Names; % name of ROIs
fprintf('Number of modes: %d \n',NumNodes);
prompt    = { 'Select condition 1' , 'Select condition 2' , 'probability threshold' , 'Subject selection' , 'View ROIs' };
dlg_title = 'Select condition';
num_lines = 1;
def       = { '1 3' , '2 4' , '0.001' , sprintf('%s',num2str([1:1:NumSubj])) , '0'};
answer    = inputdlg(prompt,dlg_title,num_lines,def);
thecond1  = str2num(answer{1});
thecond2  = str2num(answer{2});
thepth    = str2double(answer{3});
idxsubj   = str2num(answer{4});
viewer    = str2num(answer{5});
NumSubj   = size(idxsubj,2);
fprintf('Selected %d of %d subjects.\n',NumSubj,handles.NumJobs);
NumCond1  = size(thecond1,2);
NumCond2  = size(thecond2,2);
fprintf('Alpha-value: %f (performing paired t-test)\n',thepth);
hrfderivs = handles.anaobj{1}.Ana{1}.AnaDef.HRFDERIVS; % should be the same for all subjects
betamat1  = zeros(NumSubj,NumNodes); % mean beta-values in each ROI for the subjects
betamat2  = zeros(NumSubj,NumNodes);

figcounter = 0;
figure('Name',sprintf('mean beta-values for nodes (%d)',figcounter));
for isubj=1:1:NumSubj % loop over subjects 
  disp(sprintf('Processing subject number %d (=> %d) ...',isubj,idxsubj(isubj)));
  bs=handles.anaobj{isubj}.Ana{1}.BetaSeries;
  for inode=1:size(bs,2)
    newbs1(:,inode) = CondSelBS(handles.anaobj{isubj},thecond1,bs(:,inode));
    newbs2(:,inode) = CondSelBS(handles.anaobj{isubj},thecond2,bs(:,inode));    
  end    

  % plot mean beta values for each subject
  if mod(isubj-1,16)==0 && isubj>1
    figcounter=figcounter+1;
    figure('Name',sprintf('mean beta-values for nodes (%d)',figcounter));
  end
  subplot(4,4,isubj-figcounter*16);
  plot([1:1:NumNodes],mean(newbs1,1),'-',[1:1:NumNodes],mean(newbs2,1),'-');
  title(sprintf('mean beta value for subject %d',isubj));
  xlabel('node');
  ylabel('beta-value');
  %legend('condition 1','condition 2');
  
  % store mean beta values for each subject
  betamat1(isubj,:) = mean(newbs1,1);
  betamat2(isubj,:) = mean(newbs2,1);

end % loop over subjects

if NumSubj<10
  return;    
end

%
% mean beta-values significantly different from zero
%
figure('Name','mean beta-values significance');
for inode=1:NumNodes
   [ h1(inode), pval1(inode) ] = ttest(betamat1(:,inode),0,thepth); % one-sample t-test
   [ h2(inode), pval2(inode) ] = ttest(betamat2(:,inode),0,thepth);   
end
subplot(3,2,1);
hist(pval1,[0:0.05:1]);
title('probability (condition  1)');
xlabel('probability');
ylabel('number of nodes');
subplot(3,2,2);
hist(pval2,[0:0.05:1]);
title('probability (condition  2)');
xlabel('probability');
ylabel('number of nodes');
subplot(3,2,[3 4]);
semilogy([1:1:NumNodes],pval1,'-',[1:1:NumNodes],pval2,'-',[1:1:NumNodes],thepth*ones(1,NumNodes),'');
title('mean beta-values significantly different from zero');
xlabel('node');
ylabel('probability');
legend('condition 1','condition 2',sprintf('p=%f',thepth));

therois = (pval1<thepth)|(pval2<thepth);
fprintf('===> ROIs: %d of %d \n',nnz(therois),length(therois));

for i=1:length(therois)
    if therois(i)==1
       fprintf('ROI %d  ->  %s \n',i,Names{i});
    end
end

%
% statistical test - conditions
%
for inode=1:NumNodes
   [ h(inode) pval(inode) ] = ttest(betamat1(:,inode),betamat2(:,inode),thepth); % paired t-test
end
Nsig = 0;
for inode=1:NumNodes
   if pval(inode)<=thepth
       fprintf('%s : p=%f \n',Names{inode},pval(inode));
       Nsig = Nsig+1;
       h(inode) = 1.0;
       ROIFiles{Nsig} = handles.anaobj{1}.Ana{1}.Configure.ROI.File{inode};%fullfile(handles.anaobj{1}.Ana{1}.Configure.ROI.Path,handles.anaobj{1}.Ana{1}.Configure.ROI.File{inode});
   else
       h(inode) = 0.0;   
   end
end
fprintf('Found %d significant differences (alpha-value = %f => %f expected).\n',Nsig,thepth,thepth*NumNodes);

%
% plot
%
figure('Name','test if mean beta values significantly different between conditions');
subplot(2,2,[1 2]);
errorbar([1:1:NumNodes],mean(betamat1,1),std(betamat1,1)/sqrt(NumSubj),'xb');
hold on;
errorbar([1:1:NumNodes],mean(betamat2,1),std(betamat2,1)/sqrt(NumSubj),'xr');
hold on;
plot([1:1:NumNodes],h*0.99,'*');
title('group mean beta-values');
xlabel('node');
ylabel('mean beta-value');
legend('condition 1','condition 2');

subplot(2,2,3);
hist(pval,[0:0.05:1]);
title('probability');
xlabel('probability');
ylabel('number of nodes');
subplot(2,2,4);
semilogy([1:1:NumNodes],pval,'-',[1:1:NumNodes],thepth*ones(NumNodes,1),'-');
title('probability');
xlabel('node');
ylabel('probability');

%
% view ROIs
%
if viewer>0
  mars_display_roi('display',ROIFiles);
  % store information to mat-file
  save('mean_beta.mat','pval','ROIFiles');
end
