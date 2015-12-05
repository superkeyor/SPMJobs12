
function h=conn_filesearchtool(varargin)
persistent cwd;
global CONN_gui;
if ~isfield(CONN_gui,'font_offset'), CONN_gui.font_offset=0; end
if ~isfield(CONN_gui,'parse_html'), CONN_gui.parse_html={'<HTML><FONT color=rgb(100,100,100)>','</FONT></HTML>'}; end
if isempty(cwd), cwd=pwd; end

if nargin<1 || ischar(varargin{1}),
    fields={'position',[.5,.1,.4,.8],...
        'backgroundcolor',.9*[1,1,1],...
        'foregroundcolor',[0,0,0],...
        'title','File search tool',...
        'folder',cwd,...
        'filter','*',...
        'regexp','.',...
        'callback','',...
        'max',2};
    params=[];
    for n1=1:2:nargin, params=setfield(params,lower(varargin{n1}),varargin{n1+1}); end
    for n1=1:2:length(fields), if ~isfield(params,fields{n1}) | isempty(getfield(params,fields{n1})), params=setfield(params,fields{n1},fields{n1+1}); end; end;
    M=[params.position(1),params.position(3),0,0,0;params.position(2),0,params.position(4),0,0;0,0,0,params.position(3),0;0,0,0,0,params.position(4)]';
    conn_menu('frame2',[1,0,0,1,1]*M);
    %uicontrol('style','frame','units','norm','position',[1,0,0,1,1]*M,'backgroundcolor',params.backgroundcolor);
    %axes('units','norm','position',[1,0,0,1,1]*M,'color',params.backgroundcolor,'xcolor',min(1,1*params.backgroundcolor),'ycolor',min(1,1*params.backgroundcolor),'xtick',[],'ytick',[],'box','on');
    uicontrol('style','text','units','norm','position',[1,.05,.8,.9,.175]*M,'foregroundcolor',params.foregroundcolor,'backgroundcolor',params.backgroundcolor,'string',params.title,'fontname','default','fontsize',8+CONN_gui.font_offset,'fontweight','bold','horizontalalignment','left');
    uicontrol('style','text','units','norm','position',[1,.05,.85,.2,.05]*M,'foregroundcolor',params.foregroundcolor,'backgroundcolor',params.backgroundcolor,'string','Folder','fontangle','normal','fontname','default','fontsize',8+CONN_gui.font_offset,'horizontalalignment','center');
    uicontrol('style','text','units','norm','position',[1,.05,.8,.2,.05]*M,'foregroundcolor',params.foregroundcolor,'backgroundcolor',params.backgroundcolor,'string','Filter','fontangle','normal','fontname','default','fontsize',8+CONN_gui.font_offset,'horizontalalignment','center');
    uicontrol('style','text','units','norm','position',[1,.05,.75,.2,.05]*M,'foregroundcolor',params.foregroundcolor,'backgroundcolor',params.backgroundcolor,'string','Regexp','fontangle','normal','fontname','default','fontsize',8+CONN_gui.font_offset,'horizontalalignment','center');
    %h.filter=uicontrol('style','edit','units','norm','position',[1,.25,.8,.7,.05]*M,'foregroundcolor',params.foregroundcolor,'backgroundcolor',params.backgroundcolor,'string',params.filter,'tooltipstring','Select a file name filter (wildcards may be used)','fontsize',8+CONN_gui.font_offset);
    h.folder=conn_menu('edit',[1,.25,.85,.7,.05]*M,'',params.folder,'Select current folder');
    h.filter=conn_menu('edit',[1,.25,.8,.7,.05]*M,'',params.filter,'Select a file name filter');
    h.regexp=conn_menu('edit',[1,.25,.75,.7,.05]*M,'',params.regexp,'Select an additional file name filter using regexp expressions');
    %h.folder=uicontrol('style','edit','units','norm','position',[1,.25,.85,.7,.05]*M,'foregroundcolor',params.foregroundcolor,'backgroundcolor',params.backgroundcolor,'string',params.folder,'fontname','default','fontsize',8+CONN_gui.font_offset,'tooltipstring','Select the root folder');
    h.selectfile=uicontrol('style','edit','position',[1,.25,.85,.7,.05]*M,'string','','max',2,'visible','off');
    %h.find=uicontrol('style','togglebutton','units','norm','position',[1,.7,.925,.25,.05]*M,'value',0,'string','Find','fontname','default','fontsize',8+CONN_gui.font_offset,'horizontalalignment','center','tooltipstring','Recursively searchs file names matching the filter starting from the current folder');
    h.find=conn_menu('pushbutton',[1,.55,.14,.35,.05]*M,'','Find','Recursively searchs file names matching the filter starting from the current folder');
    set(h.find,'value',0);
    h.find_state=0;
    %h.files=uicontrol('style','listbox','units','norm','position',[1,.05,.2,.9,.55]*M,'foregroundcolor',params.foregroundcolor,'backgroundcolor',params.backgroundcolor,'string','','max',params.max,'fontname','default','fontsize',8+CONN_gui.font_offset,'tooltipstring','Displays file matches. Double-click a folder for browsing to a different location. Double-click a file to import it to the toolbox');
    h.files=conn_menu('listbox',[1,.05,.2,.9,.50]*M,'','','<HTML>Displays file matches<br/> - Double-click a folder for browsing to a different location<br/> - Double-click a file to import it to the toolbox</HTML>');
    set(h.files,'max',params.max);
    h.selected=uicontrol('style','text','units','norm','position',[1,.04,.025,.9,.10]*M,'foregroundcolor',params.foregroundcolor,'backgroundcolor',params.backgroundcolor,'string','','fontname','default','fontsize',8+CONN_gui.font_offset,'horizontalalignment','center');
    %h.select=uicontrol('style','pushbutton','units','norm','position',[1,.7,.14,.25,.05]*M,'string','Select','fontname','default','fontsize',8+CONN_gui.font_offset,'horizontalalignment','center','tooltipstring','Enter selected file(s) or open selected folder','callback',{@conn_filesearchtool,'files',true});
    h.select=conn_menu('pushbutton',[1,.10,.14,.35,.05]*M,'','Select','Enter selected file(s) or open selected folder',{@conn_filesearchtool,'files',true});
    h.selectspm=conn_menu('pushbutton',[1,.7,.94,.29,.05]*M,'','SPMselect','<HTML>Enter file(s) using spm_select GUI instead<br/> - right-click for additional options</HTML>');
    hc1=uicontextmenu;
    h.selectspmalt1=uimenu(hc1,'Label','<HTML><i>spm_select any</i>: Select any filetypes (disregards filter field)</HTML>');%,'callback',{@conn_filesearchtool,'selectspmalt2'});
    h.selectspmalt2=uimenu(hc1,'Label','<HTML><i>spm_select image</i>: Select individual volume(s) from 4d nifti files</HTML>');%,'callback',{@conn_filesearchtool,'selectspmalt2'});
    set(h.selectspm,'uicontextmenu',hc1);
    h.callback=params.callback;
    set([h.files,h.find,h.folder,h.filter,h.regexp,h.select,h.selectspm,h.selectspmalt1,h.selectspmalt2],'userdata',h);
    names={'files','find','selectspm','selectspmalt1','selectspmalt2'}; for n1=1:length(names), set(h.(names{n1}),'callback',{@conn_filesearchtool,names{n1}}); end
    names={'folder','filter','regexp'}; for n1=1:length(names), set(h.(names{n1}),'callback',{@conn_filesearchtool,names{n1},true}); end
    set([h.find h.select h.selectspm],'visible','off');
    conn_menumanager('onregion',[h.find h.select h.selectspm],1,params.position,h.files);
    conn_filesearchtool(h.folder,[],'folder',true);
else,
    h=get(varargin{1},'userdata');
    set(h.selected,'string','');
    doubleclick=nargin>3|strcmp(get(gcbf,'SelectionType'),'open');
    switch(varargin{3}),
        case {'selectspm','selectspmalt1','selectspmalt2'}
            if strcmp(varargin{3},'selectspm'), 
                regfilter=regexprep(get(h.filter,'string'),{'\s*',';([^;]+)',';','\.','*','([^\$])$'},{'','\$|$1','','\\.','.*','$1\$'});
                names=spm_select(inf,regfilter,[],[],get(h.folder,'string'));
            elseif strcmp(varargin{3},'selectspmalt1'), 
                names=spm_select(inf,'any',[],[],get(h.folder,'string'));
            else
                names=spm_select(inf,'image',[],[],get(h.folder,'string'));
            end
            if ~isempty(names)
                if iscell(h.callback),
                    if length(h.callback)>1, feval(h.callback{1},h.callback{2:end},names); else, feval(h.callback{1},names); end
                else, feval(h.callback,names); end
            end
        case {'folder','filter','regexp','files'},
            parse={[regexprep(CONN_gui.parse_html{1},'<FONT color=rgb\(\d+,\d+,\d+\)>','<i>'),'-'],regexprep(CONN_gui.parse_html{2},'<\/FONT>','</i>')};
            pathname=fliplr(deblank(fliplr(deblank(get(h.folder,'string')))));
            cwd=pathname;
            if strcmp(varargin{3},'files'),
				%disp(get(h.files,'value'))
                filename=get(h.files,'string');
                filename=filename(get(h.files,'value'),:);
                if isempty(filename), return; end
                filename=fliplr(deblank(fliplr(deblank(filename(1,:)))));
                if strncmp(filename,parse{1},numel(parse{1})), filename=fliplr(deblank(fliplr(deblank(filename(numel(parse{1})+1:end-numel(parse{2})))))); end
                if strcmp(filename,'..'),
                    idx=find(pathname==filesep); idx(idx==length(pathname))=[];
                    if ~isempty(idx), pathname=pathname(1:idx(end)); else return; end
                else
                    pathname=fullfile(pathname,filename);
                end
            end
            isdirectory=(isdir(pathname) || isempty(dir(pathname)));
            if isdirectory&&doubleclick,
                results=[parse{1},'   ..',parse{2}]; 
                names=dir(pathname);
                for n1=1:length(names), if names(n1).isdir&&~strcmp(names(n1).name,'.')&&~strcmp(names(n1).name,'..'), results=strvcat(results,[parse{1},'   ',names(n1).name,parse{2}]); end; end
                filter=get(h.filter,'string');
                filter2=get(h.regexp,'string');
                if isempty(filter), filter='*'; end
                if isempty(filter2), filter2='.'; end
                [filternow,filter]=strtok(filter,';');
                while ~isempty(filternow),
                    filename=fullfile(pathname,fliplr(deblank(fliplr(deblank(filternow)))));
                    names=dir(filename);
                    for n1=1:length(names), 
                        if ~names(n1).isdir&&~isempty(regexp(names(n1).name,filter2)), results=strvcat(results,names(n1).name); end; 
                    end
                    [filternow,filter]=strtok(filter,';');
                end
                idx=[];
                selectfile=get(h.selectfile,'string');
                if ~isempty(selectfile), idx=find(ismember(cellstr(results),selectfile)); end
                if isempty(idx), idx=1; end
                idx=unique(max(1,min(size(results,1),idx)));
                set(h.files,'string',results,'value',idx,'listboxtop',1);
                set(h.folder,'string',fullfile(pathname,filesep));
                set(h.selectfile,'string','');
                cwd=fullfile(pathname,filesep);
            elseif ~isdirectory&&~isempty(h.callback)&&doubleclick, 
                idx=get(h.files,'value');
                names=get(h.files,'string');
                if ~isempty(idx) & size(names,1)>=max(idx),
                    names=names(idx,:);
                    pathname=fliplr(deblank(fliplr(deblank(get(h.folder,'string')))));
                    if isempty(pathname)||pathname(end)~=filesep, pathname=[pathname,filesep]; end
                    names=[repmat(pathname,[size(names,1),1]),names];
                    if iscell(h.callback),
                        if length(h.callback)>1, feval(h.callback{1},h.callback{2:end},names); else, feval(h.callback{1},names); end
                    else, feval(h.callback,names); end
                end
            elseif ~doubleclick&&~isdirectory, 
                idx=get(h.files,'value');
                names=get(h.files,'string');
                strselected=sprintf('%d files selected',numel(idx)); 
                if ~isempty(idx) & size(names,1)>=max(idx),
                    names=names(idx,:);
                    pathname=fliplr(deblank(fliplr(deblank(get(h.folder,'string')))));
                    if isempty(pathname)||pathname(end)~=filesep, pathname=[pathname,filesep]; end
                    names=[repmat(pathname,[size(names,1),1]),names];
                    try
                        if size(names,1)>4,
                            strselected={sprintf('[%d files]',size(names,1))};
                            strselected{end+1}=['First: ',names(1,:)]; strselected{end+1}=['Last : ',names(end,:)];
                            for n1=1:length(strselected), if length(strselected{n1})>25+9, strselected{n1}=[strselected{n1}(1:4),' ... ',strselected{n1}(end-25+1:end)]; end; end; 
                        else
                            temp=conn_file(names);
                            if ~isempty(temp{3}), strselected=temp{2};
                            else, strselected='unrecognized format';
                            end
                        end
                    catch
                        strselected='unrecognized format';
                    end
                end
                set(h.selected,'string',strselected);
            end
        case {'find'}
            state=xor(1,h.find_state);%get(h.find,'value');
            h.find_state=state;
            set(h.find,'userdata',h);
            if state,
                results=get(h.files,'string');
                results=results(find(results(:,1)=='<'),:);
                resultsnew=[];
                set(h.find,'string','Cancel');
                pathname=fliplr(deblank(fliplr(deblank(get(h.folder,'string')))));
                filter=get(h.filter,'string');
                filter2=get(h.regexp,'string');
                set(h.files,'string',resultsnew,'value',1);
                dirtree(pathname,filter,filter2,h,length(pathname));
                resultsnew=get(h.files,'string');
                set(h.files,'string',strvcat(results,resultsnew));
                h.find_state=0;
                set(h.find,'value',0,'string','Find','userdata',h);                
            else
                set(h.find,'value',0,'string','Find');
            end
    end
end


function dirtree(pathname,filter,filter2,h,L)
persistent dcharcount
if isempty(dcharcount), dcharcount=0; end

if ~get(h.find,'value'), return; end
dchar=' ...    ';
filterrest=filter;
[filternow,filterrest]=strtok(filterrest,';');
txt1=get(h.files,'string');
txt={};
while ~isempty(filternow),
    if size(txt1,1)>1e5, % Change this value to increase the maximum number of files displayed
        txt=strvcat(txt1,txt{:});
        set(h.files,'string',txt,'value',1);
        set(h.selected,'string',sprintf('(%d files found) %s',size(txt,1),dchar(ones(1,8))));
        return;
    end
    filename=fullfile(pathname,fliplr(deblank(fliplr(deblank(filternow)))));
    dir0=dir(filename);
    [names,idx]=sortrows(strvcat(dir0(:).name));
    for n1=1:length(dir0),
        if ~dir0(idx(n1)).isdir&&(isempty(filter2)||~isempty(regexp(dir0(idx(n1)).name,filter2))),
            txt{end+1}=fullfile(pathname(L+1:end),dir0(idx(n1)).name);
        end
    end
    [filternow,filterrest]=strtok(filterrest,';');
end
txt=strvcat(txt1,txt{:});
set(h.files,'string',txt);
set(h.selected,'string',sprintf('(%d files found) %s',size(txt,1),dchar(mod(dcharcount+(1:8),length(dchar))+1)));
dcharcount=rem(dcharcount-1,8);
drawnow;
set(h.selected,'string',sprintf('(%d files found) %s',size(txt,1),dchar(ones(1,8))));
dir0=dir(pathname);
[names,idx]=sortrows(strvcat(dir0(:).name));
for n1=1:length(dir0),
    if dir0(idx(n1)).isdir && ~strcmp(dir0(idx(n1)).name,'.') && ~strcmp(dir0(idx(n1)).name,'..'),
        dirtree(fullfile(pathname,dir0(idx(n1)).name),filter,filter2,h,L);
    end
end

