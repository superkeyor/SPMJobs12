function [h,F,p,dof,statsname,BB,EE,opt]=conn_glm(X,Y,C,M,opt)
% CONN_GLM General Linear Model estimation and hypothesis testing.
%
%   [h,F,p,dof]=CONN_GLM(X,Y,C,M) estimates a linear model of the form Y = X*B + E
%   where Y is an observed matrix of response or output variables (rows are observations, columns are output variables)
%         X is an observed design or regressor matrix (rows are observations, columns are predictor variables)
%         B is a matrix of unknown regression parameters (rows are predictor variables, columns are output variables)
%         E is an matrix of unobserved multivariate normally distributed disturbances with zero mean and unknown covariance.
%   and tests a general null hypothesis of the form h = C*B*M' = 0
%   where C is matrix or vector of "predictor" contrasts (rows are contrasts, columns are predictor variables, defaults to C=eye(size(X,2)) )
% 		  M is matrix or vector of "outcome" contrasts (rows are contrasts, columns are output variables, defaults to M=eye(size(Y,2)) )
%
%   CONN_GLM returns the following information:
%		  h:   a matrix of estimated contrast effect sizes (h = C*B*M')
%		  F:   the test statistic(s) (T,F,or Chi2 value, depending on whether h is a scalar, a vector, or a matrix. See below)
%		  p:   p-value of the test(s)
%		  dof: degrees of freedom
%
%   Additional information:
%   By default CONN_GLM will use a T, F, or a Chi2 statistic for hypothesis testing depending on the size of h=C*B*M'. The default options are:
%                  when size(h)=[1,1]      -> T statistic (note: one-sided t-test)
%	                      			          Examples of use: one-sided two-sample t-test, linear regression
%                  when size(h)=[1,Ns]     -> F statistic (note: equivalent to two-sided t-test when Ns=1)
%   							  	 		  Examples of use: Hotelling's two sample t-square test, two-sided t-test, multivariate regression
%                  when size(h)=[Nc,1]     -> F statistic (note: equivalent to two-sided t-test when Nc=1)
%					  			     		  Examples of use: ANOVA, ANCOVA, linear regression omnibus test
%                  when size(h)=[Nc,Ns]    -> Wilks' Lambda statistic, Bartlett's Chi2 approximation
%								     		  Examples of use: MANOVA, MANCOVA, multivariate regression omnibus test, likelihood ratio test
%   The default option can be changed using the syntax CONN_GLM(X,Y,C,M,opt) where opt is one of the following character strings:
%               CONN_GLM(X,Y,C,M,'collapse_none') will perform a separate univariate-test on each of the elements of the matrix h=C*B*M'
%  			    CONN_GLM(X,Y,C,M,'collapse_outcomes') will perform a separate multivariate-test on each of the rows of the matrix h (collapsing across multiple outcome variables or outcome contrasts).
% 			    CONN_GLM(X,Y,C,M,'collapse_predictors') will perform a separate multivariate-test on each of the columns of the matrix h (collapsing across multiple predictor variables or predictor contrasts).
% 			    CONN_GLM(X,Y,C,M,'collapse_all') will perform a single multivariate test on the matrix h.
%
% Example of use:
%   % MANOVA (three groups, two outcome variables)
%   % Data preparation
%    N1=10;N2=20;N3=30;
%    Y1=randn(N1,2)+repmat([0,0],[N1,1]); % data for group 1 (N1 samples, population mean = [0,0])
%    Y2=randn(N2,2)+repmat([0,1],[N2,1]); % data for group 2 (N2 samples, population mean = [0,1])
%    Y3=randn(N3,2)+repmat([1,0],[N3,1]); % data for group 2 (N3 samples, population mean = [1,0])
%    Y=cat(1,Y1,Y2,Y3);
%    X=[ones(N1,1),zeros(N1,2); zeros(N2,1),ones(N2,1),zeros(N2,1); zeros(N3,2),ones(N3,1)];
%   % Sample data analyses
%    [h,F,p,dof]=conn_glm(X,Y,[1,-1,0;0,1,-1]); disp(['Multivariate omnibus test of non-equality of means across the three groups:']);disp([' Chi2(',num2str(dof),') = ',num2str(F),'   p = ',num2str(p)]);
%    [h,F,p,dof]=conn_glm(X,Y,[1,-1,0]); disp(['Multivariate test of non-equality of means between groups 1 and 2:']);disp([' F(',num2str(dof(1)),',',num2str(dof(2)),') = ',num2str(F),'   p = ',num2str(p)]);
%    [h,F,p,dof]=conn_glm(X,Y,[-1,1,0],eye(2),'collapse_none'); disp(['Univariate one-sided test of non-equality of means between groups 1 and 2 on each outcome variable:']);disp([' T(',num2str(dof),') = ',num2str(F(:)'),'   p = ',num2str(p(:)')]);
%

% alfnie@gmail.edu
% 04/03

[N1,Nx]=size(X);
[N2,Ns,Na]=size(Y);
if N1~=N2, error('wrong dimensions'); end
if nargin<3 || isempty(C), C=eye(Nx); end
if nargin<4 || isempty(M), M=speye(Ns,Ns); else, Ns=rank(M); end
if nargin<5, opt=[]; end
if ~isempty(opt),switch(lower(opt)),case {'collapse_none','aa'},opt='AA';case {'collapse_outcomes','ab'},opt='AB';case {'collapse_predictors','ba'},opt='BA';case {'collapse_all','bb'},opt='BB';otherwise,error(['Unknown option ',opt]); end; end

Nx=rank(X);
dofe=N1-Nx;
Nc0=rank(X*C');

iX=pinv(X'*X);
r=C*iX*C';
ir=pinv(r);
if nargin<5 || isempty(opt), opt=[char(65+(size(C,1)>1)),char(65+(size(M,1)>1))]; else, opt=upper(opt); end
if Na>1, Na_h=[]; nas=find(~any(any(isnan(Y)|isinf(Y),1),2)); else nas=1; end
if isempty(nas), nas=(1:Na)'; end
univariate=(strcmp(opt,'AA')||strcmp(opt,'BA'))&&size(M,1)==Ns&&size(M,2)==Ns&&all(all(M==eye(Ns)));
for na=nas(:)'
    B=iX*(X'*Y(:,:,na));
    E=Y(:,:,na)-X*B;
    if univariate,EE=diag(sum(abs(E).^2,1)); % univariate case within matrix
    else, if size(E,2)<size(E,1), EE=M*(E'*E)*M'; else, EE=E*M'; EE=EE'*EE; end; end          	% within matrix
    EE=full(EE);
    h=full(C*B*M');
    h(abs(h)<1e-10)=0;
    BB=h'*ir*h;                    % between matrix
    
    switch(opt),
        case 'AA',                          % h: [1,1]  T-test
            k=                sqrt(diag(r)*diag(EE).');
            F=			      real(h./max(eps,k))*sqrt(dofe);
            if nargout>2, p=nan+zeros(size(F));idxvalid=find(~isnan(F));if ~isempty(idxvalid), p(idxvalid)=spm_Tcdf(-F(idxvalid),dofe); end; end
            dof=              dofe;
            statsname=        'T';
        case 'AB',                          % h: [1,Ns] F-test
            F=			      real(sum((h*pinv(EE)).*conj(h),2)./max(eps,diag(r)))*(dofe-Ns+1)/Ns;
            if nargout>2, p=nan+zeros(size(F));idxvalid=find(~isnan(F));if ~isempty(idxvalid), p(idxvalid)=1-spm_Fcdf(F(idxvalid),Ns,dofe-Ns+1); end; end
            dof=              [Ns,dofe-Ns+1];
            statsname=        'F';
        case 'BA',                          % h: [Nc,1] F-test
            F=                real(diag(BB)./max(eps,diag(EE)))*dofe/Nc0;
            if nargout>2, p=nan+zeros(size(F));idxvalid=find(~isnan(F));if ~isempty(idxvalid), p(idxvalid)=1-spm_Fcdf(F(idxvalid),Nc0,dofe); end; end
            dof=              [Nc0,dofe];
            statsname=        'F';
        case 'BB',                          % h: [Nc,Ns] Wilk's Lambda-test (Ns,dof,Nc0)
            if Ns==1 % rank-defficient EE case
                F=                real(diag(BB)./max(eps,diag(EE)))*dofe/Nc0; F=F(1);
                if nargout>2, p=nan+zeros(size(F));idxvalid=find(~isnan(F));if ~isempty(idxvalid), p(idxvalid)=1-spm_Fcdf(F(idxvalid),Nc0,dofe); end; end
                dof=              [Nc0,dofe];
                statsname=        'F';
            else
                F=                -(dofe-1/2*(Ns-Nc0+1))*real(log(real(det(EE)./max(eps,det(EE+BB)))));
                if nargout>2, p=nan+zeros(size(F));idxvalid=find(~isnan(F));if ~isempty(idxvalid), p(idxvalid)=1-spm_Xcdf(F(idxvalid),Ns*Nc0); end; end
                dof=              [Ns*Nc0];
                statsname=        'X';
            end
    end
    if Na>1
        if isempty(Na_h), Na_h=nan(size(h,1),size(h,2),Na);Na_F=nan(size(F,1),size(F,2),Na);Na_p=nan(size(F,1),size(F,2),Na); end
        Na_h(:,:,na)=h;
        Na_F(:,:,na)=F;
        if nargout>2, Na_p(:,:,na)=p; end
    end
end
if Na>1
    h=Na_h;
    F=Na_F;
    if nargout>2, p=Na_p; end
end
