% This script demonstrates how the output files from BASCO can be used to 
% perform a simple network analysis.
%

clear;

load('empathy4D/out_estimated_AAL90_emot.mat'); % load BASCO output-file

nwmat = anaobj{1}.Ana{1}.Matrix; % retrieve connectivity matrix from a single subject
N     = size(nwmat,1);

figure('Name','correlation coefficients');
hist(nwmat(triu(ones(N,N),1)==1),-0.1:0.05:2);
xlabel('correlation coefficients (Fisher z-transformed)');
ylabel('number of edges');

% apply threshold: wu->bu
nwmat(nwmat<0.7)  = 0;
nwmat(nwmat>=0.7) = 1;

figure('Name','network matrix');
imshow(nwmat,'InitialMagnification','fit');
colormap jet;

% degree centrality
deg = sum(nwmat);
[deg_sorted, deg_idx] = sort(deg,'ascend');
roinames = char(anaobj{1}.Ana{1}.Configure.ROI.Names);
roinames = roinames(deg_idx,:);

M=19; % display the nodes with the highest degree centrality
deg_M = deg_sorted(N-M+1:N);
roi_M = roinames(N-M+1:N,:);

figure('Name','degree centrality','Units', 'normalized', 'Position', [0.1, 0.1, 0.4, 0.8]);
barh(deg_M,0.4,'k');
set(gca,'YTick',1:M);
set(gca,'YTickLabel',roi_M);
xlabel('degree centrality');
hold on;
plot(mean(deg)*ones(1,M),1:M,'k-',(mean(deg)+std(deg))*ones(1,M),1:M,'k--');
ylim([0.5 M+0.5])

