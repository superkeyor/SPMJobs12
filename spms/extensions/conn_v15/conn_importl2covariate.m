function conn_importl2covariate(name,y)
global CONN_x CONN_gui;
if ~isfield(CONN_gui,'font_offset'), CONN_gui.font_offset=0; end
if ~isfield(CONN_x,'filename')||isempty(CONN_x.filename), uiwait(warndlg('No CONN toolbox project loaded')); end
if numel(name)~=numel(y), error('Inconsistent number of names/values'); end

ny=cellfun(@numel,y);
if any(ny~=CONN_x.Setup.nsubjects)
    if any(rem(ny,CONN_x.Setup.nsubjects))
        error('Second-level covariates have incorrect number of subjects. Please re-run second-level analyses and import these values again');
    else
        y2={};
        name2={};
        for n=1:numel(y)
            if ny(n)~=CONN_x.Setup.nsubjects
                if isequal(size(y{n}),[1 CONN_x.Setup.nsubjects]), y{n}=y{n}.'; 
                else y{n}=reshape(y{n},CONN_x.Setup.nsubjects,[]);
                end
                for n1=1:size(y{n},2)
                    y2{end+1}=y{n}(:,n1);
                    name2{end+1}=[name{n},' measure',num2str(n1)];
                end
            else
                y2{end+1}=y{n};
                name2{end+1}=name{n};
            end
        end
        y=y2;
        name=name2;
    end
end
ok=true;
thfig=dialog('units','norm','position',[.3,.4,.6,.4],'windowstyle','normal','name','Import 2nd-level covariate','color','w','resize','on');
uicontrol(thfig,'style','text','units','norm','position',[.1,.85,.8,.10],'string',sprintf('New 2nd-level covariate names (%d)',numel(name)),'backgroundcolor','w','fontsize',9+CONN_gui.font_offset,'fontweight','bold');
ht1=uicontrol(thfig,'style','edit','units','norm','position',[.1,.25,.8,.6],'max',2,'string',name,'fontsize',8+CONN_gui.font_offset,'horizontalalignment','left');
uicontrol(thfig,'style','text','string','note: changes to 2nd-level covariates are temporary until your project is saved','units','norm','position',[.1,.12,.8,.10],'backgroundcolor','w','fontsize',8+CONN_gui.font_offset);
uicontrol(thfig,'style','pushbutton','string','Import','units','norm','position',[.1,.01,.38,.10],'callback','uiresume','fontsize',8+CONN_gui.font_offset);
uicontrol(thfig,'style','pushbutton','string','Cancel','units','norm','position',[.51,.01,.38,.10],'callback','delete(gcbf)','fontsize',8+CONN_gui.font_offset);
while ok
    uiwait(thfig);
    ok=ishandle(thfig);
    if ok,
        newname=get(ht1,'string');
        if numel(newname)~=numel(name), uiwait(warndlg('Incorrect number of names entered in GUI'));
        elseif numel(unique(newname))~=numel(newname)||any(ismember(newname,CONN_x.Setup.l2covariates.names(1:end-1))), uiwait(warndlg('Names must be unique and different than existing second-level covariate names'));
        else
            for n=1:numel(newname)
                icov=numel(CONN_x.Setup.l2covariates.names);
                CONN_x.Setup.l2covariates.names{icov}=newname{n};
                CONN_x.Setup.l2covariates.names{icov+1}=' ';
                for n1=1:CONN_x.Setup.nsubjects, CONN_x.Setup.l2covariates.values{n1}{icov}=y{n}(n1); end
            end
            delete(thfig);
            conn_msgbox({sprintf('%d new second-level covariates added',numel(newname)),'(see Tools->Calculator to explore their values)'},'',1);
            ok=false;
        end
    end
end
end
