function [H1,B1,H0,B0,dE,R]=conn_invPPI(X,Nk,X0,X1,DOPLOT)
% EM iterative method for solving the main&interaction factors h in PPI equation:
% X_nj = X_ni*a_ij + sum_k (X_ni.*h_nk)*b_ikj + noise
%   where 
%     i and j are indexes over ROIs
%     n is an index over scans/time
%     X_ni is a [Nscans x Nrois] matrix representing the ROI-level BOLD timeseries
%     k is an index over the unknown interaction terms
%     a_ij is a matrix characterizing the main connectivity effects 
%     h_nj and b_ikj are matrices characterizing the interaction effects 
%       (h: temporal modulation; b: ROI-to-ROI modulation)
%
% [H,B]=conn_invPPI(X,Nk)
%   X:  [Nscans x Nrois] matrix
%   Nk: desired number of components
% returns:
%   H:  [Nscans x Nk] interaction temporal terms
%   B:  [Nrois x Nrois x Nk] interaction ROI-to-ROI connectivity terms
%
% [H,B]=conn_invPPI(...,X0,X1) 
%   X0: control for subject/session effects (by default X0 is fixed to ones(Nt,1); when entering multiple subjects use kron(eye(Nsubjects),ones(Nscans,1)) to remove main between-subject effects )
%   X1: temporal smoothing matrix
%

lambda=0;               % regularization term (optional)
stopcriterion=1e-5;     % converge criterion (minimum h param change between two consecutive iterations)
miniter=8;              % minimum number of iterations
maxiter=1e3;            % maximum number of iterations
[Nt,Nr]=size(X);
DOFAST=8*Nt*Nr^2<4e9;   % set DOFAST=true for fast (memory-hungry) algorithm; set DOFAST=false for slow (low memory usage) algorithm (current limit set to 4Gb memory)
if nargin<2||isempty(Nk), Nk=4; end
if nargin<3||isempty(X0), X0=ones(Nt,1); end
if nargin<4||isempty(X1), X1=speye(Nt); end
if nargin<5||isempty(DOPLOT), DOPLOT=false; end
Nk0=size(X0,2);
Nk=Nk+Nk0;

cYY=repmat(mean(mean(X.^2,1),2),[2,Nr]);
hist_err=nan(Nk,maxiter*Nk);
hist_err(1)=cYY(1);
nhist_err=1;
err_last=cYY(1);
H=zeros(Nt,Nk);
B=zeros(Nr,Nk,Nr);
dE=nan(1,Nk);
if DOFAST
    try
        eX=repmat({X},[1,Nr]);
    catch
        DOFAST=false;
    end
end
if DOPLOT==1, hdl=conn_timedwaitbar(0,'Computing temporal modulation. Please wait...'); 
elseif DOPLOT==2, hfig=figure('units','norm','position',[.3 .3 .4 .4],'color','w','name','estimation of temporal modulation factors','numbertitle','off','menubar','none'); 
end
%state=rand('state');
%rand('seed',0);
for nk=1:Nk
    h_old=nan;
    %h=rand(Nt,1);
    h=ones(Nt,1);
    if nk<=Nk0,
        h=X0(:,nk)*(X0(:,nk)\h);
    end
    for n=1:maxiter
        db1=zeros(Nr,Nr);
        db2=zeros(Nr,1);
        for nroi=1:Nr
            if DOFAST
                Y=eX{nroi};     % target ROIs
                x=X(:,nroi);    % source ROI
            else
                Y=X;            % target ROIs
                x=X(:,nroi);    % source ROI
                Y=Y-x(:,ones(1,Nr)).*(H(:,1:nk-1)*B(:,1:nk-1,nroi)'); % removes previously-computed effects
            end
            xh=x.*h;
            cXY=xh'*Y;
            db1(:,nroi)=cXY';
            db2(nroi)=sum(xh.^2);
        end
        B(:,nk,:)=(db1+db1')./(lambda*Nt+conn_bsxfun(@plus,db2,db2')); % ROI-to-ROI modulation
        dh1=0;
        dh2=0;
        err=0;
        for nroi=1:Nr
            if DOFAST
                Y=eX{nroi};     % target ROIs
                x=X(:,nroi);    % source ROI
            else
                Y=X;            % target ROIs
                x=X(:,nroi);    % source ROI
                Y=Y-x(:,ones(1,Nr)).*(H(:,1:nk-1)*B(:,1:nk-1,nroi)'); % removes previously-computed effects
            end
            b=B(:,nk,nroi)';
            dh1=dh1+x.*(Y*b');                         % cumulative term for computing temporal modulation
            dh2=dh2+x.^2*sum(b.^2);                    % cumulative term for computing temporal modulation
            xh=x.*h;
            cXY=xh'*Y;
            fitmse=cYY(1,nroi)-cXY*b'/Nr/Nt;           % current mse for each source ROI
            cYY(2,nroi)=fitmse;                        
            err=err+fitmse/Nr;
            %err=err+mean(mean((Y-xh*b).^2,1),2)/Nr;
        end
        if nk<=Nk0, 
            x1=X0(:,nk); ix1=X0(:,nk)';
            h=(x1*(ix1*(dh1)))./max(eps,Nr^2*lambda+x1*(ix1*(dh2)));               
        else
            h=(X1*dh1)./max(eps,Nr^2*lambda+X1*dh2);               % temporal modulation
        end
        nh=max(abs(h));
        %nh=sqrt(mean(h.^2));
        h=h/nh; B(:,nk,:)=B(:,nk,:)*nh;
        if mean(mean(B(:,nk,:)))<-1e-4, h=-h; B(:,nk,:)=-B(:,nk,:); end
        
        nhist_err=nhist_err+1;
        hist_err(nk,nhist_err)=err;
        stopnow=(n>miniter|nk<=Nk0) & mean(abs(h-h_old))<stopcriterion;
        if DOPLOT>1&&(~rem(n,10)||stopnow) % plots
            subplot(211); plot(fliplr(hist_err(:,1:nhist_err)'),'.-'); set(gca,'xcolor',.75*[1 1 1],'ycolor',.75*[1 1 1]); xlabel('iterations'); ylabel('mse'); 
            if nk<=Nk0, title(sprintf('computing covariate #%d / %d',nk,Nk0));
            else title(sprintf('computing term #%d / %d',nk-Nk0,Nk-Nk0));
            end
            subplot(223); plot(h); set(gca,'xcolor',.75*[1 1 1],'ycolor',.75*[1 1 1]); title('temporal modulation');
            subplot(224); imagesc(permute(B(:,nk,:),[1,3,2])); set(gca,'xcolor',.75*[1 1 1],'ycolor',.75*[1 1 1]); axis equal tight; title('ROI-to-ROI modulation'); colorbar;
            drawnow;
        end
        if stopnow, break; end
        h_old=h;
    end
    
    H(:,nk)=h;
    cYY(1,:)=cYY(2,:);
    if nk<Nk, hist_err(nk+1,nhist_err)=err; end
    if DOFAST
        for nroi=1:Nr
            eX{nroi}=eX{nroi}-(X(:,nroi).*H(:,nk)) * B(:,nk,nroi)';
        end
    end
    if 0,%nk>Nk0  % keeps variability in subject-specific factors orthogonal to current factor
        mB=mean(B(:,1:Nk0,:),2);
        iB=sum(sum(B(:,nk,:).^2,1),3);
        for nk0=1:Nk0
            alpha=sum(sum(B(:,nk,:).*(mB-B(:,nk0,:)),1),3)./iB;
            H(:,nk)=H(:,nk)-alpha*X0(:,nk0);
            B(:,nk0,:)=B(:,nk0,:)+alpha*B(:,nk,:);
        end
        alpha=mean(X0\H(:,nk));
        for nk0=1:Nk0
            H(:,nk)=H(:,nk)-alpha*X0(:,nk0);
            B(:,nk0,:)=B(:,nk0,:)+alpha*B(:,nk,:);
        end
    end
    if DOPLOT==1, conn_timedwaitbar((min(nk,Nk0)/Nk0+max(0,nk-Nk0))/(Nk-Nk0+1),hdl); end
    dE(nk)=err_last-err;
    err_last=err;
end
if DOPLOT==1, close(hdl); 
elseif DOPLOT==2, close(hfig);
end
%rand('state',state);

% removes covariates-of-no-interest from returned matrices
H0=H(:,1:Nk0);
B0=permute(B(:,1:Nk0,:),[1 3 2]);
idx1=Nk0+1:Nk;
[sigmaB,idx2]=sort(dE(idx1),'descend');
H1=H(:,idx1(idx2));   
B1=permute(B(:,idx1(idx2),:),[1 3 2]);
dE=dE(idx1(idx2));

if nargout>5
    R=zeros(size(B1,1),size(B1,2),size(H1,1));
    for n=1:size(H1,1)
        r=0;
        for nk=1:size(H0,2)
            r=r+H0(n,nk)*B0(:,:,nk);
        end
        for nk=1:size(H1,2)
            r=r+H1(n,nk)*B1(:,:,nk);
        end
        R(:,:,n)=r;
    end
end






