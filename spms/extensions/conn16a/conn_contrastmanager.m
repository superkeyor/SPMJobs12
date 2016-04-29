function ok=conn_contrastmanager(str,varargin)
global CONN_x CONN_gui;
if ~isfield(CONN_gui,'font_offset'), CONN_gui.font_offset=0; end

ht1=[];
if nargin
    switch(str)
        case 'names', ok=CONN_x.Results.saved.names; 
        case {'add','delete','edit'}, conn_contrastmanager_update(str,varargin{:});
        otherwise, error('invalid option %s',str);
    end
    return
end
thfig=dialog('units','norm','position',[.3,.4,.4,.3],'windowstyle','normal','name','Contrast manager','color','w','resize','on');
uicontrol(thfig,'style','text','units','norm','position',[.1,.9,.8,.08],'string','Contrasts of interest','backgroundcolor','w','fontsize',9+CONN_gui.font_offset,'fontweight','bold');
ht1=uicontrol(thfig,'style','listbox','units','norm','position',[.1,.35,.8,.50],'max',1,'string','','value',[],'fontsize',8+CONN_gui.font_offset);
ht_add=uicontrol(thfig,'style','pushbutton','string','add','units','norm','position',[.1,.25,.1,.10],'callback',@(varargin)conn_contrastmanager_update('add'),'fontsize',8+CONN_gui.font_offset,'tooltipstring','Adds current contrast definition (defined in the main CONN gui) to this list');
ht_del=uicontrol(thfig,'style','pushbutton','string','delete','units','norm','position',[.2,.25,.1,.10],'callback',@(varargin)conn_contrastmanager_update('delete'),'fontsize',8+CONN_gui.font_offset,'tooltipstring','Deletes selected contrast from this list');
ht_ren=uicontrol(thfig,'style','pushbutton','string','edit','units','norm','position',[.3,.25,.1,.10],'callback',@(varargin)conn_contrastmanager_update('edit'),'fontsize',8+CONN_gui.font_offset,'tooltipstring','Edits selected contrast');
%uicontrol(thfig,'style','text','string','note: changes to this list are temporary until your project is saved','units','norm','position',[.1,.15,.8,.08],'backgroundcolor','w','fontsize',8+CONN_gui.font_offset);
ht_sel=uicontrol(thfig,'style','pushbutton','string','Select','units','norm','position',[.1,.01,.38,.10],'callback','uiresume','fontsize',8+CONN_gui.font_offset,'tooltipstring','Enters selected contrast definition into CONN-gui');
ht_ext=uicontrol(thfig,'style','pushbutton','string','Exit','units','norm','position',[.51,.01,.38,.10],'callback','delete(gcbf)','fontsize',8+CONN_gui.font_offset);
conn_contrastmanager_update('');
% set(ht1 ht2],'callback',@conn_orthogonalizemenuupdate);
% conn_orthogonalizemenuupdate;
uiwait(thfig);
ok=ishandle(thfig);
if ok,
    ok=get(ht1,'value');
    delete(thfig);
end

    function conn_contrastmanager_update(option,ncontrast,name)
        if nargin<2||isempty(ncontrast), ncontrast=get(ht1,'value'); end
        switch(option)
            case 'add'
                if nargin<3||isempty(name), 
%                     newname=conn_resultsfolder('subjectsconditions',0,CONN_x.Results.xX.nsubjecteffects,CONN_x.Results.xX.csubjecteffects,CONN_x.Results.xX.nconditions,CONN_x.Results.xX.cconditions);
                    newname='new contrast';
                    answ=inputdlg('Contrast name','New contrast',1,{newname});
                    if isempty(answ), return; end
                    name=answ{1};
                end
                idx=1:numel(CONN_x.Results.saved.names);
                if any(strcmp(CONN_x.Results.saved.names(idx),name))
                    uiwait(warndlg('Duplicated contrast name. Unable to proceed'));
                    return;
                end
%                 dirname=regexprep(name,'[^\w\d_-\.]','_');
%                 if ~isempty(dir(fullfile(CONN_x.folders.secondlevel,dirname))), 
%                     answ=questdlg({'Warning!',sprintf('Folder %s already exists. Do you want to continue?',fullfile(CONN_x.folders.secondlevel,dirname))},'','Yes','No','No');
%                     if ~isequal(answ,'Yes'), return; end
%                 end
                label=['<HTML><b>',name,'</b>',' Subject effects: <i>',strjoinstr(CONN_x.Setup.l2covariates.names(CONN_x.Results.xX.nsubjecteffects),'&'),'{',mat2str(CONN_x.Results.xX.csubjecteffects),'}</i> ; Conditions: <i>',strjoinstr(CONN_x.Setup.conditions.names(CONN_x.Results.xX.nconditions),'&'),'{',mat2str(CONN_x.Results.xX.cconditions),'}</i></HTML>'];
                ncontrast=numel(CONN_x.Results.saved.names)+1;
                CONN_x.Results.saved.names{ncontrast}=name;
                CONN_x.Results.saved.labels{ncontrast}=label;
                CONN_x.Results.saved.nsubjecteffects{ncontrast}=CONN_x.Setup.l2covariates.names(CONN_x.Results.xX.nsubjecteffects);
                CONN_x.Results.saved.csubjecteffects{ncontrast}=CONN_x.Results.xX.csubjecteffects;
                CONN_x.Results.saved.nconditions{ncontrast}=CONN_x.Setup.conditions.names(CONN_x.Results.xX.nconditions);
                CONN_x.Results.saved.cconditions{ncontrast}=CONN_x.Results.xX.cconditions;
%                 [ok,nill]=mkdir(CONN_x.folders.secondlevel,dirname);
            case 'delete'
                if ncontrast
                    name=CONN_x.Results.saved.names{ncontrast};
%                 dirname=regexprep(name,'[^\w\d_-\.]','_');
%                 if ~isempty(dir(fullfile(CONN_x.folders.secondlevel,dirname))), 
%                     answ=questdlg({sprintf('Folder %s already exists. Delete its contents as well?',fullfile(CONN_x.folders.secondlevel,dirname))},'','Yes','No','Cancel','Cancel');
%                     if isequal(answ,'Cancel'), return; end
%                     if isequal(answ,'Yes'), 
%                         if ispc, [ok,nill]=system(sprintf('del /Q %s',fullfile(CONN_x.folders.secondlevel,dirname,'*.*')));
%                         else 	 [ok,nill]=system(sprintf('rm -f %s',fullfile(CONN_x.folders.secondlevel,dirname,'*')));
%                         end
%                         if ispc, [ok,nill]=system(sprintf('rmdir "%s"',fullfile(CONN_x.folders.secondlevel,dirname)));
%                         else     [ok,nill]=system(sprintf('rmdir ''%s''',fullfile(CONN_x.folders.secondlevel,dirname)));
%                         end
%                     end
%                 end
                    idx=setdiff(1:numel(CONN_x.Results.saved.names),ncontrast);
                    CONN_x.Results.saved.names=CONN_x.Results.saved.names(idx);
                    CONN_x.Results.saved.labels=CONN_x.Results.saved.labels(idx);
                    CONN_x.Results.saved.nsubjecteffects=CONN_x.Results.saved.nsubjecteffects(idx);
                    CONN_x.Results.saved.csubjecteffects=CONN_x.Results.saved.csubjecteffects(idx);
                    CONN_x.Results.saved.nconditions=CONN_x.Results.saved.nconditions(idx);
                    CONN_x.Results.saved.cconditions=CONN_x.Results.saved.cconditions(idx);
                end
            case 'edit'
                if ncontrast
                    answ={};
                    if nargin<3||isempty(name),
                        answ=inputdlg({'Contrast name','Subject effects','Between-subjects contrast','Conditions','Between-conditions contrast'},'Edit contrast',1,{CONN_x.Results.saved.names{ncontrast},strjoinstr(CONN_x.Results.saved.nsubjecteffects{ncontrast},';'),mat2str(CONN_x.Results.saved.csubjecteffects{ncontrast}),strjoinstr(CONN_x.Results.saved.nconditions{ncontrast},';'),mat2str(CONN_x.Results.saved.cconditions{ncontrast})});
                        if isempty(answ), return; end
                        name=answ{1};
                    end
                    idx=setdiff(1:numel(CONN_x.Results.saved.names),ncontrast);
                    if any(strcmp(CONN_x.Results.saved.names(idx),name))
                        uiwait(warndlg('Duplicated contrast name. Unable to proceed'));
                        return;
                    end
%                 olddirname=regexprep(CONN_x.Results.saved.names{ncontrast},'[^\w\d_-\.]','_');
%                 dirname=regexprep(name,'[^\w\d_-\.]','_');
%                 if ~isempty(dir(fullfile(CONN_x.folders.secondlevel,dirname))), 
%                     answ=questdlg({'Warning!',sprintf('Folder %s already exists. Do you want to continue?',fullfile(CONN_x.folders.secondlevel,dirname))},'','Yes','No','No');
%                     if ~isequal(answ,'Yes'), return; end
%                 end
                    if numel(answ)>1
                        CONN_x.Results.saved.nsubjecteffects{ncontrast}=regexp(answ{2},'\s*;\s*','split');
                        CONN_x.Results.saved.csubjecteffects{ncontrast}=str2num(answ{3});
                        CONN_x.Results.saved.nconditions{ncontrast}=regexp(answ{4},'\s*;\s*','split');
                        CONN_x.Results.saved.cconditions{ncontrast}=str2num(answ{5});
                    end
                    label=['<HTML><b>',name,'</b>',' Subject effects: <i>',strjoinstr(CONN_x.Results.saved.nsubjecteffects{ncontrast},'&'),'{',mat2str(CONN_x.Results.saved.csubjecteffects{ncontrast}),'}</i> ; Conditions: <i>',strjoinstr(CONN_x.Results.saved.nconditions{ncontrast},'&'),'{',mat2str(CONN_x.Results.saved.cconditions{ncontrast}),'}</i></HTML>'];
                    %label=['<HTML><b>',name,'</b>',regexprep(CONN_x.Results.saved.labels{ncontrast},'<HTML><b>.*?</b>','')];
                    CONN_x.Results.saved.names{ncontrast}=name;
                    CONN_x.Results.saved.labels{ncontrast}=label;
%                 cwd=pwd;
%                 cd(CONN_x.folders.secondlevel);
%                 if ispc, [ok,nill]=system(sprintf('ren "%s" "%s"',olddirname,dirname));
%                 else 	 [ok,nill]=system(sprintf('mv ''%s'' ''%s''',olddirname,dirname));
%                 end
%                 cd(cwd);
                end
        end
        ncontrast=min([numel(CONN_x.Results.saved.names),ncontrast]);
        if ~ncontrast, ncontrast=[]; end
        labels=CONN_x.Results.saved.labels;
%         dirnames=regexprep(CONN_x.Results.saved.names,'[^\w\d_-\.]','_');
%         existdirnames=cellfun(@(x)~isempty(dir(fullfile(CONN_x.folders.secondlevel,x,'*.mat'))),dirnames);
%         labels(existdirnames)=regexprep(labels(existdirnames),{'<b>','</b>'},{'<b><FONT color=rgb(0,255,0)>','</FONT></b>'});
%         labels(~existdirnames)=regexprep(labels(~existdirnames),{'<b>','</b>'},{'<b><FONT color=rgb(255,0,0)>','</FONT></b>'});
        set(ht1,'string',labels,'value',ncontrast);
        fileresultsnames=fullfile(CONN_x.folders.secondlevel,'_list_results.mat');
        results=CONN_x.Results.saved;
        save(fileresultsnames,'results');
        if numel(labels)>0, set([ht_del ht_ren ht_sel],'enable','on');
        else set([ht_del ht_ren ht_sel],'enable','off');
        end
    end
end


function str=strjoinstr(str1,str2)
str=[str1(:)';repmat({str2},1,length(str1))];
str=reshape(str(1:end-1),1,numel(str)-1);
str=[str{:}];
end
