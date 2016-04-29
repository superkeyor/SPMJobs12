function [results_patch, results_stats, results_str] = conn_displaydenoisinghistogram(varargin)
global CONN_x;

filepath=CONN_x.folders.data;
results_patch={};
results_stats={};
results_str={};
if ~nargout, ht=conn_timedwaitbar(0,'Computing histograms...'); end
for nsub=1:CONN_x.Setup.nsubjects
    nsess=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub));
    for nses=1:nsess,
        filename=fullfile(filepath,['ROI_Subject',num2str(nsub,'%03d'),'_Session',num2str(nses,'%03d'),'.mat']);
        X1{nses}=load(filename);
        filename=fullfile(filepath,['COV_Subject',num2str(nsub,'%03d'),'_Session',num2str(nses,'%03d'),'.mat']);
        X2{nses}=load(filename);
        filename=fullfile(filepath,['COND_Subject',num2str(nsub,'%03d'),'_Session',num2str(nses,'%03d'),'.mat']);
        C{nses}=load(filename);
        if ~isequal(CONN_x.Setup.conditions.names(1:end-1),C{nses}.names), error(['Incorrect conditions in file ',filename,'. Re-run previous step']); end
        confounds=CONN_x.Preproc.confounds;
        if isfield(CONN_x.Preproc,'detrending')&&CONN_x.Preproc.detrending,
            confounds.types{end+1}='detrend';
            if CONN_x.Preproc.detrending>=2, confounds.types{end+1}='detrend2'; end
            if CONN_x.Preproc.detrending>=3, confounds.types{end+1}='detrend3'; end
        end
        X{nses}=conn_designmatrix(confounds,X1{nses},X2{nses});
        if isfield(CONN_x.Preproc,'regbp')&&CONN_x.Preproc.regbp==2,
            X{nses}=conn_filter(CONN_x.Setup.RT(min(numel(CONN_x.Setup.RT),nsub)),CONN_x.Preproc.filter,X{nses});
        end
        if size(X{nses},1)~=CONN_x.Setup.nscans{nsub}{nses}, error('Wrong dimensions'); end
        iX{nses}=pinv(X{nses});
        
        x0=X1{nses}.sampledata;
        x0=detrend(x0,'constant');
        x0=x0(:,~all(abs(x0)<1e-4,1)&~any(isnan(x0),1));
        if isempty(x0),
            disp('Warning! No temporal variation in BOLD signal within sampled grey-matter voxels');
        end
        
        x1=x0;
        if isfield(CONN_x.Preproc,'despiking')&&CONN_x.Preproc.despiking==1,
            my=repmat(median(x1,1),[size(x1,1),1]);
            sy=repmat(4*median(abs(x1-my)),[size(x1,1),1]);
            x1=my+sy.*tanh((x1-my)./max(eps,sy));
        end
        x1=x1-X{nses}*(iX{nses}*x1);
        if isfield(CONN_x.Preproc,'despiking')&&CONN_x.Preproc.despiking==2,
            my=repmat(median(x1,1),[size(x1,1),1]);
            sy=repmat(4*median(abs(x1-my)),[size(x1,1),1]);
            x1=my+sy.*tanh((x1-my)./max(eps,sy));
        end
        [x1,fy]=conn_filter(max(CONN_x.Setup.RT(min(numel(CONN_x.Setup.RT),nsub))),CONN_x.Preproc.filter,x1);
        fy=mean(abs(fy(1:round(size(fy,1)/2),:)).^2,2); dof=max(0,sum(fy)^2/sum(fy.^2)-size(X{nses},2)); % change dof displayed to WelchSatterthwaite residual dof approximation
        z0=corrcoef(x0);z1=corrcoef(x1);z0=(z0(z0~=1));z1=(z1(z1~=1));
        [a0,b0]=hist(z0(:),linspace(-1,1,100));[a1,b1]=hist(z1(:),linspace(-1,1,100));
        if isempty(z0)||isempty(z1),
            disp('Warning! Empty correlation data');
        else
            results_patch{end+1}={[b1(1),b1,b1(end)],[0,a1,0],[0,a0,0]};
            results_stats{end+1}=[mean(z0(z0~=1)),std(z0(z0~=1)),mean(z1(z1~=1)),std(z1(z1~=1)),dof];
            results_str{end+1}=sprintf('Subject %d session %d before denoising: mean %f std (%f); after denoising: mean %f std %f (dof_res~%.1f)',nsub,nses,mean(z0(z0~=1)),std(z0(z0~=1)),mean(z1(z1~=1)),std(z1(z1~=1)),dof);
        end
        if ~nargout, conn_timedwaitbar(nsub/CONN_x.Setup.nsubjects,ht);
        else fprintf('.');
        end
    end
end
if ~nargout, close(ht);
else fprintf('\n');
end
if ~nargout
    hfig=figure('color','w','menubar','none');
    ht=uimenu(hfig,'Label','Print','callback',@(varargin)conn_print);
    for n=1:numel(results_patch),
        h1=subplot(211); patch(results_patch{n}{[1 3]},'k','edgecolor','k','linestyle',':','facecolor',.9*[1 1 .8],'facealpha',.25); title('Connectivity histogram before denoising'); xlabel('Correlation (r)');
        h2=subplot(212); patch(results_patch{n}{[1 2]},'k','edgecolor','k','linestyle',':','facecolor',.9*[1 1 .8],'facealpha',.25); title('Connectivity histogram after denoising'); xlabel('Correlation (r)');
        disp(results_str{n});
    end
    set([h1 h2],'ytick',[],'ycolor','w','ylim',[0 max(max(get(h1,'ylim'),get(h2,'ylim')))]); 
    stats=cell2mat(results_stats');
    temp=num2cell(mean(stats,1));
    fprintf('Averaged across all subjects/sessions:\n');
    fprintf('Before denoising: mean %f std (%f); After denoising: mean %f std %f (dof_r_e_s~%.1f)\n',temp{:})
end
