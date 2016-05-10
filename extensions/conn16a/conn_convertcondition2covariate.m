function out=conn_convertcondition2covariate(varargin)
global CONN_x;

if nargin<1||isempty(varargin{1}), return; end
nconditions=varargin;
donotremove=false;
donotapply=false;
if iscell(nconditions)
    if ~isempty(nconditions)&&isequal(nconditions{1},'-DONOTAPPLY')
        donotapply=true;
        donotremove=true;
        nconditions=nconditions(2:end);
    elseif ~isempty(nconditions)&&isequal(nconditions{1},'-DONOTREMOVE')
        donotremove=true;
        nconditions=nconditions(2:end);
    end
    if ischar(nconditions{1})
        [ok,nconditions]=ismember(nconditions,CONN_x.Setup.conditions.names(1:end-1)); 
    else
        nconditions=cell2mat(nconditions);
    end
end
nconditions0=length(CONN_x.Setup.conditions.names);
nconditions=setdiff(nconditions,[0 nconditions0]);
out={};
for ncondition=nconditions(:)'
    names=['Effect of ',CONN_x.Setup.conditions.names{ncondition}];
    nl1covariates=numel(CONN_x.Setup.l1covariates.names)-1;
    nl1covariate=nl1covariates+1;
    
    % adds first-level covariate
    for nsub=1:CONN_x.Setup.nsubjects,
        nsess=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub));
        rt=CONN_x.Setup.RT(min(numel(CONN_x.Setup.RT),nsub))/10;
        hrf=spm_hrf(rt);
        for nses=1:nsess,
            
            onset=CONN_x.Setup.conditions.values{nsub}{ncondition}{nses}{1};
            durat=CONN_x.Setup.conditions.values{nsub}{ncondition}{nses}{2};
            if numel(CONN_x.Setup.nscans)>=nsub&&numel(CONN_x.Setup.nscans{nsub})>=nses
                durat=max(rt,min(CONN_x.Setup.RT(min(numel(CONN_x.Setup.RT),nsub))*(10+CONN_x.Setup.nscans{nsub}{nses}),durat));
                x=zeros(100+ceil(CONN_x.Setup.nscans{nsub}{nses}*CONN_x.Setup.RT(min(numel(CONN_x.Setup.RT),nsub))/rt),1);
                if length(durat)>=1, for n1=1:length(onset), x(100+round(1+onset(n1)/rt+(0:durat(min(length(durat),n1))/rt-1)))=1; end; end
                if CONN_x.Setup.acquisitiontype==1,
                    x=convn(x,hrf);
                end
                x=mean(reshape(x(100+(1:10*CONN_x.Setup.nscans{nsub}{nses})),[10,CONN_x.Setup.nscans{nsub}{nses}]),1)';%x=x(1+10*(0:CONN_x.Setup.nscans{nsub}{nses}-1));
                if donotapply, out{nsub}{ncondition}{nses}=x;
                else CONN_x.Setup.l1covariates.files{nsub}{nl1covariate}{nses}={'[raw values]',{sprintf('size [%s]',num2str(size(x))),'[raw values]'},x};
                end
            end
        end
    end
    if ~donotapply
        CONN_x.Setup.l1covariates.names{nl1covariate}=names;
        CONN_x.Setup.l1covariates.names{nl1covariate+1}=' ';
    end
end

% removes conditions
if ~donotremove
    nconditions=setdiff(1:nconditions0,nconditions);
    CONN_x.Setup.conditions.names=CONN_x.Setup.conditions.names(nconditions);
    nconditions=setdiff(nconditions,nconditions0);
    for n1=1:length(CONN_x.Setup.conditions.values), CONN_x.Setup.conditions.values{n1}={CONN_x.Setup.conditions.values{n1}{nconditions}}; end
    CONN_x.Setup.conditions.param=CONN_x.Setup.conditions.param(nconditions);
    CONN_x.Setup.conditions.filter=CONN_x.Setup.conditions.filter(nconditions);
end

