function conn_slice_display(data,structural,defaultfilepath)

if nargin<2, structural=''; end
if nargin<3, defaultfilepath=''; end

hmsg=conn_msgbox('Initializing. Please wait...');drawnow;
state.structural=structural;
if isstruct(data)
    state.isstat=true;
    state.isvol=true;
    state.T=data.T;
    state.p=data.p;
    state.stats=data.stats;
    state.dof=data.dof;
    state.mat=data.mat;
    if isfield(data,'clusters'), state.clusters=data.clusters;
    else data.clusters=[];
    end
    state.supra=data.supra.*sign(state.T);
    state.size=size(state.supra);
elseif ~isempty(data)
    state.isstat=false;
    state.isvol=true;
    V=spm_vol(data);
    %V=V(1);
    state.supra=max(spm_read_vols(V),[],4);
    state.mat=V(1).mat;
    state.size=size(state.supra);
    state.T=state.supra;
else
    state.isstat=false;
    state.isvol=false;
    V=spm_vol(state.structural);
    %V=V(1);
    state.structural=spm_read_vols(V);
    state.mat=V(1).mat;
    state.size=size(state.structural);
    state.T=state.structural;
end
state.pointer_mm=[0 0 0];
state.pointer_vox=round([state.pointer_mm 1]*pinv(state.mat)'*[1 0 0;0 1 0;0 0 1;0 0 0]+.001);
state.time=1;
if numel(state.size)>3, state.endtime=state.size(4); else state.endtime=1; end
if state.isvol
    state.view=[1 1 1 0 1];
    if ~state.isstat, state.view(4)=1; end
    state.cameraview=[1 1 1];
else
    state.view=[0 1 0 0 1];
    state.cameraview=[0 -1 0];
end
state.transparency=.5;
state.defaultfilepath=defaultfilepath;
[x,y,z]=ndgrid(1:state.size(1),1:state.size(2),1:state.size(3));
xyz=state.mat*[x(:) y(:) z(:) ones(numel(x),1)]';
state.xyz_x=reshape(xyz(1,:),state.size(1:3));
state.xyz_y=reshape(xyz(2,:),state.size(1:3));
state.xyz_z=reshape(xyz(3,:),state.size(1:3));
state.xyz_range=[min(state.xyz_x(:)) max(state.xyz_y(:)); min(state.xyz_y(:)) max(state.xyz_z(:)); min(state.xyz_x(:)) max(state.xyz_z(:))];
if isempty(state.structural), state.structural=fullfile(fileparts(which('spm')),'canonical','avg152T1.nii'); end %'single_subj_T1.nii'); end
%filename=fullfile(fileparts(which('spm')),'canonical','avg152T1.nii');
if ischar(state.structural)
    V=spm_vol(state.structural);
    %V=V(1);
    state.structural=reshape(spm_get_data(V,pinv(V(1).mat)*xyz)',state.size(1),state.size(2),state.size(3),[]);
end
if state.isvol
    pVOL1=conn_surf_volume({state.supra,cat(4,state.xyz_x,state.xyz_y,state.xyz_z)},0,0,[],1,0,0);
    pVOL2=conn_surf_volume({state.supra,cat(4,state.xyz_x,state.xyz_y,state.xyz_z)},0,0,[],1,0,1);
end

state.handles.hfig=figure('units','norm','position',[.1 .3 .8 .5],'name','Slice display','numbertitle','off','menubar','none','color',[.2 .6 .7],'interruptible','off','busyaction','cancel','renderer','opengl');
uicontrol('style','frame','units','norm','position',[.5 .65 .5 .35],'foregroundcolor',[.5 .5 .5]);
uicontrol('style','frame','units','norm','position',[.5 0 .5 .65],'foregroundcolor',[.5 .5 .5]);
uicontrol('style','text','units','norm','position',[.55 .55 .4 .05],'string','Reference point','horizontalalignment','center','fontweight','bold');
uicontrol('style','text','units','norm','position',[.55 .475 .10 .07],'string','Coordinates (mm):');
fontsize=get(0,'defaultuicontrolfontsize')+2;
for n=1:3,
    state.handles.pointer_mm(n)=uicontrol('style','edit','units','norm','position',[.7+.05*(n-1) .50 .05 .05],'string',num2str(state.pointer_mm(n)),'fontsize',fontsize,'callback',{@conn_slice_display_refresh,'pointer_mm'});
end
for n=1:3,
    state.handles.pointer_mm_delta(2*n-1)=uicontrol('style','pushbutton','units','norm','position',[.7+.025*(2*n-2) .470 .025 .03],'string','-','callback',{@conn_slice_display_refresh,'pointer_mm','-',n});
    state.handles.pointer_mm_delta(2*n-0)=uicontrol('style','pushbutton','units','norm','position',[.7+.025*(2*n-1) .470 .025 .03],'string','+','callback',{@conn_slice_display_refresh,'pointer_mm','+',n});
end
uicontrol('style','text','units','norm','position',[.55 .375 .10 .07],'string','Coordinates (voxels):');
for n=1:3,
    state.handles.pointer_vox(n)=uicontrol('style','edit','units','norm','position',[.7+.05*(n-1) .40 .05 .05],'string',num2str(state.pointer_vox(n)),'fontsize',fontsize,'callback',{@conn_slice_display_refresh,'pointer_vox'});
end
for n=1:3,
    state.handles.pointer_vox_delta(2*n-1)=uicontrol('style','pushbutton','units','norm','position',[.7+.025*(2*n-2) .37 .025 .03],'string','-','callback',{@conn_slice_display_refresh,'pointer_vox','-',n});
    state.handles.pointer_vox_delta(2*n-0)=uicontrol('style','pushbutton','units','norm','position',[.7+.025*(2*n-1) .37 .025 .03],'string','+','callback',{@conn_slice_display_refresh,'pointer_vox','+',n});
end
state.handles.view(1)=uicontrol('style','checkbox','units','norm','position',[.55 .90 .25 .05],'string','View yz plane (sagittal)','value',state.view(1),'callback',{@conn_slice_display_refresh,'view'});
state.handles.view(2)=uicontrol('style','checkbox','units','norm','position',[.55 .85 .25 .05],'string','View xz plane (coronal)','value',state.view(2),'callback',{@conn_slice_display_refresh,'view'});
state.handles.view(3)=uicontrol('style','checkbox','units','norm','position',[.55 .80 .25 .05],'string','View xy plane (axial)','value',state.view(3),'callback',{@conn_slice_display_refresh,'view'});
if state.isvol
    if state.isstat, str='View activation volume'; else str='View volume'; end
    state.handles.view(4)=uicontrol('style','checkbox','units','norm','position',[.55 .75 .25 .05],'string',str,'value',state.view(4),'callback',{@conn_slice_display_refresh,'view'});
    state.handles.view(5)=uicontrol('style','checkbox','units','norm','position',[.55 .70 .25 .05],'string','View axis','value',state.view(5),'callback',{@conn_slice_display_refresh,'view'});
end
state.handles.text1=uicontrol('style','edit','units','norm','position',[.55 .20 .4 .05],'string','','horizontalalignment','center');
if state.isstat
    uicontrol('style','text','units','norm','position',[.55 .25 .4 .05],'string','Statistics','horizontalalignment','center','fontweight','bold');
    state.handles.text2=uicontrol('style','edit','units','norm','position',[.55 .15 .4 .05],'string','','horizontalalignment','center');
end
state.handles.mode=uicontrol('style','togglebutton','units','norm','position',[0 0 .5 .05],'string','Click on image to select reference point','value',1,'callback',{@conn_slice_display_refresh,'togglepointer'},'tooltipstring','switch between click-to-rotate and click-to-select behavior');

h=axes('units','norm','position',[.05 .05 .4 .9]);
state.handles.patch=[patch(0,0,0,'w') patch(0,0,0,'w') patch(0,0,0,'w') patch(0,0,0,'w')];
if state.isvol
    state.handles.act1=patch(pVOL1);
    state.handles.act2=patch(pVOL2);
    set([state.handles.act1],'edgecolor','none','facecolor','r','facealpha',state.transparency,'visible','off');
    set([state.handles.act2],'edgecolor','none','facecolor','b','facealpha',state.transparency,'visible','off');
else state.handles.act1=[]; state.handles.act2=[];
end
set(state.handles.patch,'edgecolor','none');
hold on;
state.handles.line1=plot3(state.pointer_mm(1)+[0 0],state.pointer_mm(2)+[0 0],state.xyz_range(3,:),'b-');
state.handles.line2=plot3(state.pointer_mm(1)+[0 0],state.xyz_range(2,:),state.pointer_mm(3)+[0 0],'b-');
state.handles.line3=plot3(state.xyz_range(1,:),state.pointer_mm(2)+[0 0],state.pointer_mm(3)+[0 0],'b-');
hold off;
axis equal tight off;
state.handles.axes=gca;
state.handles.light=[light light];set(state.handles.light,'position',[1 1 1],'visible','off','color',.5*[1 1 1]);
state.handles.slider=uicontrol('style','slider','units','norm','position',[.47 .1 .025 .8],'callback',{@conn_slice_display_refresh,'pointer_vox','x'},'tooltipstring','Select slice');
if state.endtime>1, state.handles.time=uicontrol('style','slider','units','norm','position',[.55 .05 .40 .01],'callback',{@conn_slice_display_refresh,'time'},'tooltipstring',sprintf('Volume/scan %d/%d',state.time,state.endtime)); end
try, addlistener(state.handles.slider, 'ContinuousValueChange',@(varargin)conn_slice_display_refresh(state.handles.slider,[],'pointer_vox','x')); end
try, addlistener(state.handles.time, 'ContinuousValueChange',@(varargin)conn_slice_display_refresh(state.handles.time,[],'time')); end

hc=state.handles.hfig;
hc1=uimenu(hc,'Label','Effects');
if state.isvol
    uimenu(hc1,'Label','normal','callback',{@conn_slice_display_refresh,'material','dull'},'tag','material');
    uimenu(hc1,'Label','emphasis','callback',{@conn_slice_display_refresh,'material',[.1 .75 .5 1 .5]},'tag','material');
    uimenu(hc1,'Label','sketch','callback',{@conn_slice_display_refresh,'material',[.1 1 1 .25 0]},'tag','material');
    uimenu(hc1,'Label','shiny','callback',{@conn_slice_display_refresh,'material',[.3 .6 .9 20 1]},'tag','material');
    uimenu(hc1,'Label','metal','callback',{@conn_slice_display_refresh,'material',[.3 .3 1 25 .5]},'tag','material');
    uimenu(hc1,'Label','flat','callback',{@conn_slice_display_refresh,'material',[]},'tag','material','checked','on');
    uimenu(hc1,'Label','bright','callback',{@conn_slice_display_refresh,'light',.8},'separator','on','tag','light');
    uimenu(hc1,'Label','medium','callback',{@conn_slice_display_refresh,'light',.5},'tag','light','checked','on');
    uimenu(hc1,'Label','dark','callback',{@conn_slice_display_refresh,'light',.2},'tag','light');
end
uimenu(hc1,'Label','white background','callback',{@conn_slice_display_refresh,'background',[1 1 1]},'separator','on','tag','background');
uimenu(hc1,'Label','black background','callback',{@conn_slice_display_refresh,'background',[0 0 0]},'tag','background');
uimenu(hc1,'Label','color background','callback',{@conn_slice_display_refresh,'background',[.2 .6 .7]},'tag','background','checked','on');
if state.isvol&& (~isempty(pVOL1)||~isempty(pVOL2))
    hc2=uimenu(hc1,'Label','activation surface transparency');
    thdl=[];
    for n1=0:.1:.9,thdl=[thdl,uimenu(hc2,'Label',num2str(1-n1),'callback',{@conn_slice_display_refresh,'act_transparency',n1},'tag','act_transparency')]; end
    thdl=[thdl,uimenu(hc1,'Label','activation surface opaque','callback',{@conn_slice_display_refresh,'act_transparency',1},'tag','act_transparency')];
    set(thdl,'checked','off');set(thdl(max(1,min(numel(thdl),1+round(state.transparency*10)))),'checked','on');
end
hc1=uimenu(hc,'Label','Print');
uimenu(hc1,'Label','current view','callback',{@conn_slice_display_refresh,'print',1});
set(state.handles.hfig,'userdata',state);%'uicontextmenu',hc,
set(rotate3d,'ActionPostCallback',{@conn_slice_display_refresh,'position'});
set(rotate3d,'enable','on');
        
conn_slice_display_refresh([],[],'init');
if ishandle(hmsg), delete(hmsg); end

    function conn_slice_display_refresh(hObject,eventdata,option,varargin)
        if numel(hObject)==1&&ishandle(hObject)&&~isempty(get(hObject,'tag'))
            str=get(hObject,'tag');
            set(findobj(state.handles.hfig,'tag',str),'checked','off');
            set(hObject,'checked','on');
        end
        redrawnow=false;
        switch(option)
            case 'init',
                redrawnow=true;
            case 'togglepointer'
                if get(state.handles.mode,'value')==1, set(state.handles.mode,'string','Click on image to select reference point');
                else set(state.handles.mode,'string','Click on image to rotate');
                end
                redrawnow=true;
            case 'pointer_mm',
                if nargin>3,
                    if strcmp(varargin{1},'+'), d=1; else d=-1; end
                    npointer=varargin{2};
                else npointer=1; d=0;
                end
                value=[str2num(get(state.handles.pointer_mm(1),'string')) str2num(get(state.handles.pointer_mm(2),'string')) str2num(get(state.handles.pointer_mm(3),'string'))];
                if numel(value)==3
                    value(npointer)=value(npointer)+d;
                    state.pointer_mm=value;
                    state.pointer_vox=round([state.pointer_mm 1]*pinv(state.mat)'*[1 0 0;0 1 0;0 0 1;0 0 0]+.001);
                end
                for n=1:3, set(state.handles.pointer_mm(n),'string',num2str(state.pointer_mm(n)));end
                for n=1:3, set(state.handles.pointer_vox(n),'string',num2str(state.pointer_vox(n)));end
                redrawnow=true;
            case 'pointer_vox'
                value=[str2num(get(state.handles.pointer_vox(1),'string')) str2num(get(state.handles.pointer_vox(2),'string')) str2num(get(state.handles.pointer_vox(3),'string'))];
                if numel(value)==3
                    if nargin>4,
                        if strcmp(varargin{1},'+'), d=1; else d=-1; end
                        npointer=varargin{2};
                    elseif nargin>3,
                        v=get(state.handles.slider,'value');
                        npointer=find(state.view(1:3),1);
                        d=round(1+v*(state.size(npointer)-1))-value(npointer);
                    else
                        npointer=1; d=0;
                    end
                    value(npointer)=value(npointer)+d;
                    state.pointer_vox=value;
                    state.pointer_mm=round([state.pointer_vox 1]*(state.mat)'*[1 0 0;0 1 0;0 0 1;0 0 0]);
                end
                for n=1:3, set(state.handles.pointer_mm(n),'string',num2str(state.pointer_mm(n)));end
                for n=1:3, set(state.handles.pointer_vox(n),'string',num2str(state.pointer_vox(n)));end
                redrawnow=true;
            case 'time'
                value=get(state.handles.time,'value');
                state.time=round(1+(state.endtime-1)*max(0,min(1,value)));
                set(state.handles.time,'tooltipstring',sprintf('Volume/scan %d/%d',state.time,state.endtime));
                redrawnow=true;
            case 'buttondown',
                p=get(gca,'cameraposition'); 
                pos=get(state.handles.axes,'currentpoint');
                pos=pos(1,1:3);
                mp=-inf;mpos=[];
                for nview=1:3,
                    if state.view(nview)
                        k=(state.pointer_mm(nview)-pos(nview))/p(nview); 
                        tpos=pos+p*k;
                        tp=p*tpos';
                        if all(tpos>=state.xyz_range(:,1)')&&all(tpos<=state.xyz_range(:,2)')&&tp>mp, mpos=tpos; mp=tp; end 
                    end
                end
                if ~isempty(mpos)
                    state.pointer_mm=round(mpos);
                    state.pointer_vox=round([state.pointer_mm 1]*pinv(state.mat)'*[1 0 0;0 1 0;0 0 1;0 0 0]+.001);
                end
%                 nview=find(state.view(1:3));
%                 if numel(nview)==1
%                     pos=get(state.handles.axes,'currentpoint');
%                     switch nview
%                         case 1, state.pointer_mm([2 3])=round(pos(1,[2 3]));
%                         case 2, state.pointer_mm([1 3])=round(pos(1,[1 3]));
%                         case 3, state.pointer_mm([1 2])=round(pos(1,[1 2]));
%                     end
%                     state.pointer_vox=round([state.pointer_mm 1]*pinv(state.mat)'*[1 0 0;0 1 0;0 0 1;0 0 0]+.001);
%                     %state.pointer_mm=round([state.pointer_vox 1]*(state.mat)'*[1 0 0;0 1 0;0 0 1;0 0 0]);
%                 end
                for n=1:3, set(state.handles.pointer_mm(n),'string',num2str(state.pointer_mm(n)));end
                for n=1:3, set(state.handles.pointer_vox(n),'string',num2str(state.pointer_vox(n)));end
                redrawnow=true;
            case 'view',
                oldview=state.view;
                for nview=1:length(state.handles.view), state.view(nview)=get(state.handles.view(nview),'value'); end
                if any(oldview(1:3)~=state.view(1:3))
                    nview=find(state.view(1:3));
                    if isequal(nview,1), state.cameraview=[1 0 0];
                    elseif isequal(nview,2), state.cameraview=[0 -1 0];
                    elseif isequal(nview,3), state.cameraview=[0 0 1];
                    elseif nnz(view*[1 0 0;0 1 0;0 0 1;0 0 0])==3, state.cameraview=[1 1 1];
                    end
                end
                redrawnow=true;
            case 'material'
                str=varargin{1};
                if isempty(str), set(state.handles.light,'visible','off');
                else
                    set(state.handles.light,'visible','on');
                    material(str);
                end
            case 'light'
                scale=varargin{1};
                set(state.handles.light,'color',scale*[1 1 1]);
            case 'background'
                str=varargin{1};
                set(state.handles.hfig,'color',str);
            case 'act_transparency'
                scale=varargin{1};
                state.transparency=max(eps,scale);
                set([state.handles.act1 state.handles.act2],'facealpha',state.transparency);
            case 'position'
                p=get(gca,'cameraposition'); 
                set(findobj(gcbf,'type','light'),'position',p);
                state.cameraview=[];
            case 'print'
                conn_print(fullfile(state.defaultfilepath,'print01.jpg'));
        end
        
        if redrawnow
            for nview=1:3
                if state.view(nview)
                    switch nview
                        case 1,
                            x=permute(state.xyz_x(max(1,min(state.size(1),state.pointer_vox(1))),:,:),[2 3 1]);
                            y=permute(state.xyz_y(max(1,min(state.size(1),state.pointer_vox(1))),:,:),[2 3 1]);
                            z=permute(state.xyz_z(max(1,min(state.size(1),state.pointer_vox(1))),:,:),[2 3 1]);
                            z1=permute(state.structural(max(1,min(state.size(1),state.pointer_vox(1))),:,:,state.time),[2 3 1]);
                            if state.isvol, z2=permute(state.supra(max(1,min(state.size(1),state.pointer_vox(1))),:,:),[2 3 1]); end
                        case 2,
                            x=permute(state.xyz_x(:,max(1,min(state.size(2),state.pointer_vox(2))),:),[1 3 2]);
                            y=permute(state.xyz_y(:,max(1,min(state.size(2),state.pointer_vox(2))),:),[1 3 2]);
                            z=permute(state.xyz_z(:,max(1,min(state.size(2),state.pointer_vox(2))),:),[1 3 2]);
                            z1=permute(state.structural(:,max(1,min(state.size(2),state.pointer_vox(2))),:,state.time),[1 3 2]);
                            if state.isvol, z2=permute(state.supra(:,max(1,min(state.size(2),state.pointer_vox(2))),:),[1 3 2]); end
                        case 3,
                            x=permute(state.xyz_x(:,:,max(1,min(state.size(3),state.pointer_vox(3)))),[1 2 3]);
                            y=permute(state.xyz_y(:,:,max(1,min(state.size(3),state.pointer_vox(3)))),[1 2 3]);
                            z=permute(state.xyz_z(:,:,max(1,min(state.size(3),state.pointer_vox(3)))),[1 2 3]);
                            z1=permute(state.structural(:,:,max(1,min(state.size(3),state.pointer_vox(3))),state.time),[1 2 3]);
                            if state.isvol, z2=permute(state.supra(:,:,max(1,min(state.size(3),state.pointer_vox(3)))),[1 2 3]); end
                    end
                    f1=conn_slice_display_surf2patch(x,y,z,z1);
                    c1=f1.facevertexcdata;
                    %h=conn_hanning(5);h=h/sum(h); c1=convn(convn(c1,h,'same'),h','same');
                    c1=(c1-min(c1))/max(eps,max(c1)-min(c1));
                    c=repmat(c1,[1 3]);
                    if state.isvol, 
                        c0=c;
                        f2=conn_slice_display_surf2patch(x,y,z,z2); 
                        s2=sign(f2.facevertexcdata);
                        c2=.5+.5*abs(f2.facevertexcdata)/max(1e-4,max(abs(f2.facevertexcdata)));
                        c(s2>0,1)=c2(s2>0);
                        c(s2>0,2:3)=0;
                        c(s2<0,3)=c2(s2<0);
                        c(s2<0,1:2)=0;
                        c=conn_bsxfun(@times,c2==0,c0)+conn_bsxfun(@times,c2~=0,c);
                    end
                    %c(~all(c>0,2),:)=nan;
                    set(state.handles.patch(nview),'faces',f1.faces,'vertices',f1.vertices,'facevertexcdata',c,'facecolor','flat','edgecolor','none','FaceLighting', 'gouraud','visible','on');
                else set(state.handles.patch(nview),'visible','off');
                end
            end
            if state.view(4), set([state.handles.act1 state.handles.act2],'visible','on');
            else set([state.handles.act1 state.handles.act2],'visible','off');
            end
            if state.view(5), set([state.handles.line1 state.handles.line2 state.handles.line3],'visible','on');
            else set([state.handles.line1 state.handles.line2 state.handles.line3],'visible','off');
            end
            
            if isempty(state.cameraview), state.cameraview=get(gca,'cameraposition'); state.cameraview=state.cameraview(:)'; 
            else view(state.cameraview); 
            end
            set(findobj(gcbf,'type','light'),'position',state.cameraview);
            set([state.handles.line1 state.handles.line2 state.handles.line3],'xdata',[],'ydata',[],'zdata',[]);
            try, set(state.handles.line1,'xdata',state.xyz_x(state.pointer_vox(1),state.pointer_vox(2),:),'ydata',state.xyz_y(state.pointer_vox(1),state.pointer_vox(2),:),'zdata',state.xyz_z(state.pointer_vox(1),state.pointer_vox(2),:)); end
            try, set(state.handles.line2,'xdata',state.xyz_x(state.pointer_vox(1),:,state.pointer_vox(3)),'ydata',state.xyz_y(state.pointer_vox(1),:,state.pointer_vox(3)),'zdata',state.xyz_z(state.pointer_vox(1),:,state.pointer_vox(3))); end
            try, set(state.handles.line3,'xdata',state.xyz_x(:,state.pointer_vox(2),state.pointer_vox(3)),'ydata',state.xyz_y(:,state.pointer_vox(2),state.pointer_vox(3)),'zdata',state.xyz_z(:,state.pointer_vox(2),state.pointer_vox(3))); end
            if state.isstat, 
                set([state.handles.text1 state.handles.text2],'string','','visible','off');
                try, 
                    if isequal(state.stats,'T'), set(state.handles.text1,'string',sprintf('Voxel-level: (%d,%d,%d)  %s(%s) = %.2f  p = %.6f (two-sided p = %.6f)',round(state.pointer_mm(1)),round(state.pointer_mm(2)),round(state.pointer_mm(3)), state.stats,mat2str(state.dof(end)),state.T(state.pointer_vox(1),state.pointer_vox(2),state.pointer_vox(3)),state.p(state.pointer_vox(1),state.pointer_vox(2),state.pointer_vox(3)),2*min(state.p(state.pointer_vox(1),state.pointer_vox(2),state.pointer_vox(3)),1-state.p(state.pointer_vox(1),state.pointer_vox(2),state.pointer_vox(3)))),'visible','on'); 
                    else set(state.handles.text1,'string',sprintf('Voxel-level: (%d,%d,%d)  %s(%s) = %.2f  p = %.6f',round(state.pointer_mm(1)),round(state.pointer_mm(2)),round(state.pointer_mm(3)), state.stats,mat2str(state.dof),state.T(state.pointer_vox(1),state.pointer_vox(2),state.pointer_vox(3)),state.p(state.pointer_vox(1),state.pointer_vox(2),state.pointer_vox(3))),'visible','on'); 
                    end
                end
                if ~isempty(state.clusters)
                    supra=state.supra~=0;
                    d=inf(state.size);
                    d(supra)=(state.xyz_x(supra)-state.pointer_mm(1)).^2+(state.xyz_y(supra)-state.pointer_mm(2)).^2+(state.xyz_z(supra)-state.pointer_mm(3)).^2;
                    [mind,idxd]=min(d(:));
                    for n=1:numel(state.clusters.idx)
                        if any(d(state.clusters.idx{n})==mind),
                            set(state.handles.text2,'string',sprintf('Closest-cluster: %s',state.clusters.stats{n}),'visible','on');
                            break;
                        end
                    end
                end
            else
                set([state.handles.text1],'string','','visible','off');
                try, set(state.handles.text1,'string',sprintf('Value: (%d,%d,%d)  = %s',round(state.pointer_mm(1)),round(state.pointer_mm(2)),round(state.pointer_mm(3)), mat2str(1e-6*round(1e6*state.T(state.pointer_vox(1),state.pointer_vox(2),state.pointer_vox(3))))),'visible','on'); end
            end
            if get(state.handles.mode,'value')==1,
                set(rotate3d,'enable','off');
                set(state.handles.patch,'buttondownfcn',{@conn_slice_display_refresh,'buttondown'});
                set([state.handles.line1 state.handles.line2 state.handles.line3 state.handles.act1 state.handles.act2],'buttondownfcn',{@conn_slice_display_refresh,'buttondown'});
            else
                set(rotate3d,'enable','on');
                set(state.handles.patch,'buttondownfcn',[]);
                set([state.handles.line1 state.handles.line2 state.handles.line3 state.handles.act1 state.handles.act2],'buttondownfcn',[]);
            end
            if sum(state.view(1:3))==1, 
                npointer=find(state.view(1:3),1);
                d=max(0,min(1,(state.pointer_vox(npointer)-1)/max(1,state.size(npointer)-1)));
                set(state.handles.slider,'visible','on','value',d,'sliderstep',[1/max(1,state.size(npointer)-1), 10/max(1,state.size(npointer)-1)]);
            else set(state.handles.slider,'visible','off');
            end
        end
    end
end

function f=conn_slice_display_surf2patch(x,y,z,c)
x1=[1.5*x(:,1)-.5*x(:,2) .5*x(:,1:end-1)+.5*x(:,2:end) 1.5*x(:,end)-.5*x(:,end-1)]; x1=[1.5*x1(1,:)-.5*x1(2,:);.5*x1(1:end-1,:)+.5*x1(2:end,:);1.5*x1(end,:)-.5*x1(end-1,:)]; 
y1=[1.5*y(:,1)-.5*y(:,2) .5*y(:,1:end-1)+.5*y(:,2:end) 1.5*y(:,end)-.5*y(:,end-1)]; y1=[1.5*y1(1,:)-.5*y1(2,:);.5*y1(1:end-1,:)+.5*y1(2:end,:);1.5*y1(end,:)-.5*y1(end-1,:)]; 
z1=[1.5*z(:,1)-.5*z(:,2) .5*z(:,1:end-1)+.5*z(:,2:end) 1.5*z(:,end)-.5*z(:,end-1)]; z1=[1.5*z1(1,:)-.5*z1(2,:);.5*z1(1:end-1,:)+.5*z1(2:end,:);1.5*z1(end,:)-.5*z1(end-1,:)]; 
f.vertices=[x1(:) y1(:) z1(:)];
a=reshape(1:numel(x1),size(x1));
f.faces=reshape(cat(3, a(1:end-1,1:end-1), a(2:end,1:end-1),a(2:end,2:end),a(1:end-1,2:end)),[],4);
f.facevertexcdata=c(:);

end


    