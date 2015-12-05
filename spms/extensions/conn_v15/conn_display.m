function hfigure=conn_display(SPMfilename,ncon,varargin)
% CONN_DISPLAY
% Displays second-level results
% conn_display(SPMfilename);
%

% 03/09 alfnie@gmail.com
%
global CONN_x CONN_gui;

hfigure=[];
vol=[];fulld=true;
if nargin<1 || isempty(SPMfilename),
    [filename,filepath]=uigetfile('SPM.mat');
    if ~ischar(filename), return; end
    SPMfilename=fullfile(filepath,filename);
    ismat=false;
elseif ishandle(SPMfilename)
    conn_vproject(SPMfilename,[],ncon,varargin{:});
    return;
elseif isstruct(SPMfilename)
    vol=SPMfilename;
    SPMfilename=vol.fname;
    fulld=false;
else
    [filepath,filename,fileext]=fileparts(SPMfilename);
    if isempty(filepath), filepath=pwd;end
    SPMfilename=fullfile(filepath,[filename,fileext]);
end
[filepath,filename,fileext]=fileparts(SPMfilename);
cwd=pwd;

if ~isempty(filepath), cd(filepath); end
hm=conn_msgbox('Loading... please wait',''); 
if fulld,
    load([filename,fileext],'SPM');
end
if isfield(SPM.xX,'isSurface')&&SPM.xX.isSurface
    close(hm);
    conn_surf_results(fullfile(filepath,[filename,fileext]));
else
    if isfield(SPM,'xCon')&&length(SPM.xCon)>1,
        if nargin<2, ncon=spm_conman(SPM); end
    else ncon=1;
    end
    vol=SPM.xCon(ncon).Vspm;
    [x,y,z]=ndgrid(1:vol.dim(1),1:vol.dim(2),1:vol.dim(3));
    xyz=vol.mat*[x(:),y(:),z(:),ones(numel(x),1)]';
    if isfield(CONN_x,'Setup')&&isfield(CONN_x.Setup,'explicitmask')&&~isempty(dir(CONN_x.Setup.explicitmask{1})), filename=CONN_x.Setup.explicitmask{1};
    else filename=fullfile(fileparts(which(mfilename)),'utils','surf','mask.volume.brainmask.nii');
    end
    voxeltovoxel=0;
    % if isfield(CONN_x,'Setup')&&isfield(CONN_x.Setup,'steps')&&numel(CONN_x.Setup.steps)>2, voxeltovoxel=CONN_x.Setup.steps([3]);
    % else voxeltovoxel=0;
    % end
    strfile=spm_vol(filename);
    if isfield(CONN_x,'Setup')&&isfield(CONN_x.Setup,'analysismask')&&CONN_x.Setup.analysismask==1, a=reshape(spm_get_data(strfile,pinv(strfile.mat)*xyz),vol.dim(1:3));
    else a=ones(vol.dim(1:3));
    end
    %strfile=spm_vol(fullfile(fileparts(which('spm')),'canonical','single_subj_T1.nii'));
    if isfield(CONN_gui,'refs')&&isfield(CONN_gui.refs,'canonical')&&isfield(CONN_gui.refs.canonical,'filename')&&~isempty(CONN_gui.refs.canonical.filename)
        strfile=spm_vol(CONN_gui.refs.canonical.filename);
    else
        strfile=spm_vol(fullfile(fileparts(which('spm')),'canonical','avg305T1.nii'));
    end
    b=reshape(spm_get_data(strfile,pinv(strfile.mat)*xyz),vol.dim(1:3));
    ab=(a>0).*(a.*b);
    if length(vol.dim)>3,vol.dim=vol.dim(1:3); end;
    if ~isfield(vol,'dt'), vol.dt=[spm_type('float32') spm_platform('bigend')]; end
    T=spm_read_vols(vol);
    if fulld
        df=[SPM.xCon(ncon).eidf,SPM.xX.erdf];
        R=SPM.xVol.R;
        S=SPM.xVol.S;
        fwhm=1;
        try, v2r=1/prod(SPM.xVol.FWHM(1:3)); catch, v2r=[]; end
    else
        df=[1 1e3];
        R=[];S=[];v2r=[];fwhm=1;
    end
    p=nan+zeros(size(T));idxvalid=find(~isnan(T)|isequal(T,0));
    if ~fulld||SPM.xCon(ncon).STAT=='T'
        p(idxvalid)=(1-spm_Tcdf(T(idxvalid),df(2)));
    else
        p(idxvalid)=(1-spm_Fcdf(T(idxvalid),df(1),df(2)));
    end
    hfigure=figure('menubar','none');
    close(hm);
    x=find(any(any(ab,2),3)|any(any(T,2),3)); %crop
    y=find(any(any(ab,1),3)|any(any(T,1),3));
    z=find(any(any(ab,1),2)|any(any(T,1),2));
    p=p(x(1):x(end),y(1):y(end),z(1):z(end));
    ab=ab(x(1):x(end),y(1):y(end),z(1):z(end));
    T=T(x(1):x(end),y(1):y(end),z(1):z(end));
    logp=-log(max(eps,p));%logp=p;logp(logp==0)=nan; logp=-log(logp);
    if fulld
        conn_vproject(ab,logp,p,T,[],[],{.001,1,.05,3},[],[],[],{vol.mat*(eye(4)+[zeros(4,3),[x(1)-1;y(1)-1;z(1)-1;0]]),R,df,S,v2r,SPM.xCon(ncon).STAT,fwhm},.50,[],SPMfilename,voxeltovoxel);
    else
        conn_vproject(ab,logp,p,T,[],[],{.001,1,.05,3},[],[],[],{vol.mat*(eye(4)+[zeros(4,3),[x(1)-1;y(1)-1;z(1)-1;0]]),R,df,S,v2r,'T',fwhm},.50,[],SPMfilename,0);
    end
end

cd(cwd);
