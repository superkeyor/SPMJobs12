
function var=conn_updatefilepaths(varargin)
global CONN_x CONN_gui;
persistent ht htcancel changed changes holdon; 

connfolder=fileparts(which(mfilename));
if isempty(CONN_gui)||~isfield(CONN_gui,'font_offset'), CONN_gui.font_offset=0; end
if isempty(changed),changed=0;end
if isempty(holdon),holdon=0;end
if nargin==1,
    if ~isempty(ht),
        if ishandle(htcancel)&&get(htcancel,'value'), return; end
        %if ~all(ishandle(ht)), return; end
        if rand<.1, set(ht(2),'cdata',circshift(get(ht(2),'cdata'),[0 1])); drawnow; end
    end
    var=varargin{1};
    if ~iscell(var), return; end
    if length(var)==3 && ischar(var{1}) && iscell(var{2}) && (isstruct(var{3})||isnumeric(var{3})),
        if  ~strcmp(deblank(var{1}(1,:)),'[raw values]')&&~conn_existfile(var{1}(1,:)),%isempty(dir(var{1}(1,:))),
            filename=fliplr(deblank(fliplr(deblank(var{1}))));
            switch(filesep),case '\',idx=find(filename=='/');case '/',idx=find(filename=='\');end; filename(idx)=filesep;
            n=0; while n<size(filename,1),
                ok=conn_existfile(filename(n+1,:));%ok=exist(filename(n+1,:),'file')==2;%dir(deblank(filename(n+1,:)));
                if ok, n=n+1;
                else
                    askthis=1;
                    if changed,
                        for nch=numel(changes):-1:1
                            if strncmp(changes(nch).key,filename(n+1,:),changes(nch).m1)
                                filenamet=[changes(nch).fullname2(1:changes(nch).m2),filename(n+1,changes(nch).m1+1:end)];
                                if conn_existfile(filenamet), ok=1; break; end
                            end
                        end
                    end
                    if ok
                        try,
                            disp(['conn_updatefilepaths: updating reference ',deblank(filenamet)]);
                            [V,str,icon]=conn_getinfo(deblank(filenamet));
                            filename=strvcat(filename(1:n,:),filenamet,filename(n+2:end,:));
                            askthis=0;
                        end
                    end
                    if askthis,
                        fullname1=deblank(filename(n+1,:));
                        [pathname1,name1,ext1,num1]=spm_fileparts(fullname1);
                        [pathname1c,pathname1b]=fileparts(pathname1);
                        [pathname1d,pathname1c]=fileparts(pathname1c);
                        [nill,pathname1d]=fileparts(pathname1d);
                        if strcmp(pathname1c,'conn')&&strcmp(pathname1b,'rois')&&conn_existfile(fullfile(connfolder,'rois',[name1,ext1])) % automatic fixes: fix changes to conn directory
                            filename=strvcat(filename(1:n,:),fullfile(connfolder,'rois',[name1,ext1,num1]),filename(n+2:end,:));
                        elseif strcmp(pathname1d,'conn')&&strcmp(pathname1c,'utils')&&strcmp(pathname1b,'otherrois')&&conn_existfile(fullfile(connfolder,'utils','otherrois',[name1,ext1]))
                            filename=strvcat(filename(1:n,:),fullfile(connfolder,'utils','otherrois',[name1,ext1,num1]),filename(n+2:end,:));
                        elseif strcmp(pathname1d,'conn')&&strcmp(pathname1c,'utils')&&strcmp(pathname1b,'surf')&&conn_existfile(fullfile(connfolder,'utils','surf',[name1,ext1]))
                            filename=strvcat(filename(1:n,:),fullfile(connfolder,'utils','surf',[name1,ext1,num1]),filename(n+2:end,:));
                        elseif strcmp(pathname1,fullfile(connfolder,'rois'))&&conn_existfile(fullfile(connfolder,'utils','otherrois',[name1,ext1])) % automatic fixes: fix ROIs that moved from conn/rois to conn/utils/otherrois
                            filename=strvcat(filename(1:n,:),fullfile(connfolder,'utils','otherrois',[name1,ext1,num1]),filename(n+2:end,:));
                        else
                            disp(['conn_updatefilepaths: file ',fullname1,' not found']);
                            [name2,pathname2]=uigetfile(['*',ext1],['File not found: ',name1,ext1],['*',name1,ext1]);
                            if all(name2==0), filename=[]; break; end
                            fullname2=fullfile(pathname2,[name2,num1]);
                            fullnamematch=strvcat(fliplr(fullname1),fliplr(fullname2));
                            m=sum(cumsum(fullnamematch(1,:)~=fullnamematch(2,:))==0);
                            m1=max(0,length(fullname1)-m); m2=max(0,length(fullname2)-m);
                            changed=1;
                            changes=cat(2,changes, struct('key',filename(n+1,1:m1),'fullname2',fullname2,'m1',m1,'m2',m2));
                            filename=strvcat(filename(1:n,:),[fullname2(1:m2),filename(n+1,m1+1:end)],filename(n+2:end,:));
                            %filename=strvcat(filename(1:n,:),[repmat(fullname2(1:m2),[size(filename,1)-n,1]),filename(n+1:end,m1+1:end)]);
                        end
                    end
                end
            end
            if ~isempty(filename),
                [V,str,icon]=conn_getinfo(filename);
                var={filename,str,icon};
            else var=[]; end
        else
            if ~isstruct(var{3})||numel(var{3})==1
                try
                    filename=fliplr(deblank(fliplr(deblank(var{1}))));
                    if ~strcmp(filename,'[raw values]'),
                        [V,str,icon]=conn_getinfo(filename);
                        var={filename,str,icon};
                    end
                end
            end
        end
    else
        for nvar=1:length(var),
            temp=conn_updatefilepaths(var{nvar});
            if ~isempty(temp), var{nvar}=temp; elseif ~isempty(var{nvar}), var=[]; break; end
        end
    end
elseif nargin>1&&ischar(varargin{1}),
        switch(lower(varargin{1}))
            case 'init'
                if nargin<3, error('Insufficient arguments. Usage conn_updatefilepaths(''init'',root_searchstring, root_replacestring)'); end
                match1=cellstr(varargin{2});
                match2=cellstr(varargin{3});
                if numel(match1)~=numel(match2), error('mismatch number of search/replace pairs. Usage conn_updatefilepaths(''init'',root_searchstring, root_replacestring)'); end
                changed=0;
                changes=[];
                holdon=false;
                for n1=1:numel(match1)
                    holdon=true;
                    changed=1;
                    changes=cat(2,changes, struct('key',match1{n1},'fullname2',match2{n1},'m1',numel(match1{n1}),'m2',numel(match2{n1})));
                end
            case 'hold'
                holdon=strcmp(lower(varargin{2}),'on');
            otherwise
                error('unknown option %s',varargin{1});
        end
else
    update={'Setup.rois.files',...
        'Setup.l1covariates.files',...
        'Setup.structural',...
        'Setup.functional',...
        'Setup.spm',...
        'Setup.unwarp_functional',...
        'Setup.explicitmask'};
    if ~holdon
        changed=0;
        changes=[];
    end
    ht=[];
    disp('Checking if data files have been edited or moved. Please wait...');
    try
        if isfield(CONN_x,'gui')&&(isnumeric(CONN_x.gui)&&CONN_x.gui || isfield(CONN_x.gui,'display')&&CONN_x.gui.display),
            ht=dialog('units','norm','position',[.4,.5,.3,.15],'windowstyle','normal','name','','handlevisibility','on','color','w','colormap',conn_bsxfun(@min,[1 1 1],(flipud(gray(100)))));
            htcancel=uicontrol('units','norm','position',[.3 .15 .4 .2],'style','togglebutton','string','Cancel');%,'callback',@conn_updatefilepaths_stop); 
            axes('units','norm','position',[.3 .4 .4 .1]);
            ht(2)=image(max(0,.5*conn_hanning(16)*(0+50*(sin(16*pi*(0:199)/200))))); axis tight off;
             uicontrol('units','norm','position',[0 .6 1 .3],'style','text','backgroundcolor','w','string',{'Checking if data files have been edited or moved','Press ''Cancel'' to skip this step'},'fontsize',8+CONN_gui.font_offset);
            drawnow;
        end
        if ~ischar(CONN_x.filename) || isempty(dir(CONN_x.filename)),CONN_x.filename=''; end
        for nupdate=1:length(update),
            str=regexp(update{nupdate},'\.','split');
            temp=getfield(CONN_x,str{:});
            if ~isempty(temp), 
                temp=conn_updatefilepaths(temp);
                if ~isempty(temp), CONN_x=setfield(CONN_x,str{:},temp);
                else break;
                end
            end
        end
        for nalt=1:numel(CONN_x.Setup.roifunctional)
            temp=CONN_x.Setup.roifunctional(nalt).roiextract_functional;
            if ~isempty(temp)
                temp=conn_updatefilepaths(temp);
                if ~isempty(temp), CONN_x.Setup.roifunctional(nalt).roiextract_functional=temp;
                else break;
                end
            end
        end 
    catch
        disp('warning: conn_updatefilepaths did not finish');
    end
    if any(ishandle(ht)), delete(ht(ishandle(ht))); drawnow; end
    ht=[];
    htcancel=[];
    var=[];
end
%     function conn_updatefilepaths_stop(varargin)
%         ht=[ht nan];
%     end
end


