
function [h,h2,htb]=conn_menu(type,position,title,string,tooltipstring,callback,callback2)

global CONN_gui CONN_h;
persistent nullstr;

if isempty(nullstr), nullstr=''; end
h=[];h2=[];htb=[];
nmax=500;
if nargin<2 || isempty(position), position=[0,0,0,0]; end
if nargin<3, title=''; end
if nargin<4, string=''; end
if nargin<5, tooltipstring=''; end
if nargin<6, callback=''; end
if nargin<7, callback2=''; end
if ~ischar(type), [type,position,title]=deal(title,get(type,'userdata'),get(type,'value')); end
if ~CONN_gui.tooltips, tooltipstring=''; end
titleopts={'fontname','Arial','fontangle','normal','fontweight','normal','foregroundcolor',CONN_gui.fontcolorA,'fontsize',9+CONN_gui.font_offset};
titleopts2=titleopts;titleopts2(7:8)={'color',CONN_gui.fontcolorA};
contropts={'fontname','Arial','fontangle','normal','fontweight','normal','foregroundcolor',CONN_gui.fontcolorB,'fontsize',8+CONN_gui.font_offset};
doemphasis1=CONN_gui.doemphasis1;
doemphasis2=CONN_gui.doemphasis2;
switch(lower(type)),
    case 'nullstr',
        nullstr=position;
	case {'pushbutton','togglebutton'}
        if ~isequal(CONN_h.screen.hfig,gcf), figure(CONN_h.screen.hfig); end
		if ~isempty(title), h2=uicontrol('style','text','units','norm','position',position+[0,.03,0,0],'string',title,'backgroundcolor',CONN_gui.backgroundcolorA,titleopts{:},'fontunits','norm','horizontalalignment','left'); end
        bg=CONN_gui.backgroundcolorB; %min(1,CONN_gui.backgroundcolorA*5*min(2*(position(2)+.5*position(4)),2-2*(position(2)+.5*position(4))).^2);
		if strcmp(lower(type),'togglebutton')&&CONN_gui.domacGUIbugfix==2, bg(:)=1; end
        h=uicontrol('style',type,'units','norm','position',position,'backgroundcolor',bg,'horizontalalignment','left','string',string,'tooltipstring',tooltipstring,'interruptible','off','callback',callback,contropts{:},'fontweight','bold');
        set(h,'units','pixels');
        tpos=get(h,'position');
        htb=[uicontrol('style','frame','units','pixels','position',tpos+[tpos(3)-CONN_gui.uicontrol_border,0,CONN_gui.uicontrol_border-tpos(3),0],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA,'units','norm'),...
            uicontrol('style','frame','units','pixels','position',tpos+[0,tpos(4)-CONN_gui.uicontrol_border,0,CONN_gui.uicontrol_border-tpos(4)],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA,'units','norm'),...
            uicontrol('style','frame','units','pixels','position',tpos+[0,0,0,CONN_gui.uicontrol_border-tpos(4)],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA,'units','norm'),...
            uicontrol('style','frame','units','pixels','position',tpos+[0,0,CONN_gui.uicontrol_border-tpos(3),0],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA,'units','norm')];
        set(h,'units','norm');
        if doemphasis1, conn_menumanager('onregion',htb,-1,get(h,'position'),h); end
        if doemphasis2, conn_menumanager('onregion',h,0,get(h,'position')); end
	case {'pushbutton2','togglebutton2'}
        if ~isequal(CONN_h.screen.hfig,gcf), figure(CONN_h.screen.hfig); end
		if ~isempty(title), h2=uicontrol('style','text','units','norm','position',position+[0,.03,0,0],'string',title,'backgroundcolor',CONN_gui.backgroundcolorA,titleopts{:},'fontunits','norm','horizontalalignment','center'); end
        bg=CONN_gui.backgroundcolorA;
		if strcmp(lower(type),'togglebutton2')&&CONN_gui.domacGUIbugfix==2, bg(:)=1; end
		h=uicontrol('style',regexprep(type,'2$',''),'units','norm','position',position,'backgroundcolor',bg,'horizontalalignment','left','string',string,'tooltipstring',tooltipstring,'interruptible','off','callback',callback,contropts{:});
        set(h,'units','pixels');
        tpos=get(h,'position');
        htb=[uicontrol('style','frame','units','pixels','position',tpos+[tpos(3)-CONN_gui.uicontrol_border,0,CONN_gui.uicontrol_border-tpos(3),0],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA,'units','norm'),...
            uicontrol('style','frame','units','pixels','position',tpos+[0,tpos(4)-CONN_gui.uicontrol_border,0,CONN_gui.uicontrol_border-tpos(4)],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA,'units','norm'),...
            uicontrol('style','frame','units','pixels','position',tpos+[0,0,0,CONN_gui.uicontrol_border-tpos(4)],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA,'units','norm'),...
            uicontrol('style','frame','units','pixels','position',tpos+[0,0,CONN_gui.uicontrol_border-tpos(3),0],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA,'units','norm')];
        set(h,'units','norm');
        %conn_menumanager('onregion',htb,-1,get(h,'position'),h);
        if doemphasis2, conn_menumanager('onregion',h,0,get(h,'position')); end
	case 'edit'
        if ~isequal(CONN_h.screen.hfig,gcf), figure(CONN_h.screen.hfig); end
		if ~isempty(title), h2=uicontrol('style','text','units','norm','position',position+[0,.03,0,0],'string',title,'backgroundcolor',CONN_gui.backgroundcolorA,titleopts{:},'fontunits','norm','horizontalalignment','left'); end
        bg=CONN_gui.backgroundcolorB; %min(1,CONN_gui.backgroundcolorA*5*min(2*(position(2)+.5*position(4)),2-2*(position(2)+.5*position(4))).^2);
		h=uicontrol('style',type,'units','norm','position',position,'backgroundcolor',bg,'horizontalalignment','left','string',string,'tooltipstring',tooltipstring,'interruptible','off','callback',callback,contropts{:});
        set(h,'units','pixels');
        tpos=get(h,'position');
        htb=[uicontrol('style','frame','units','pixels','position',tpos+[tpos(3)-CONN_gui.uicontrol_border,0,CONN_gui.uicontrol_border-tpos(3),0],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA,'units','norm'),...
             uicontrol('style','frame','units','pixels','position',tpos+[0,tpos(4)-CONN_gui.uicontrol_border,0,CONN_gui.uicontrol_border-tpos(4)],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA,'units','norm'),...
        	 uicontrol('style','frame','units','pixels','position',tpos+[0,0,0,CONN_gui.uicontrol_border-tpos(4)],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA,'units','norm'),...
        	 uicontrol('style','frame','units','pixels','position',tpos+[0,0,CONN_gui.uicontrol_border-tpos(3),0],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA,'units','norm')];
        set(h,'units','norm');
        if doemphasis1, conn_menumanager('onregion',htb(3:4),-1,get(h,'position'),h); end
        if doemphasis2, conn_menumanager('onregion',h,0,get(h,'position')); end
	case 'edit2'
        if ~isequal(CONN_h.screen.hfig,gcf), figure(CONN_h.screen.hfig); end
		if ~isempty(title), h2=uicontrol('style','text','units','norm','position',position+[0,.03,0,0],'string',title,'backgroundcolor',CONN_gui.backgroundcolorA,titleopts{:},'fontunits','norm','horizontalalignment','left'); end
        bg=CONN_gui.backgroundcolorB; %min(1,CONN_gui.backgroundcolorA*5*min(2*(position(2)+.5*position(4)),2-2*(position(2)+.5*position(4))).^2);
		h=uicontrol('style','edit','units','norm','position',position,'backgroundcolor',bg,'horizontalalignment','left','string',string,'tooltipstring',tooltipstring,'interruptible','off','callback',callback,'max',2,contropts{:});
        set(h,'units','pixels');
        tpos=get(h,'position');
        set(h,'units','norm');
        htb=[uicontrol('style','frame','units','pixels','position',tpos+[tpos(3)-18,0,18-tpos(3),0],'foregroundcolor',bg,'backgroundcolor',bg,'units','norm')];
        conn_menumanager('onregion',htb,-1,get(h,'position'),h);
        htb=[uicontrol('style','frame','units','pixels','position',tpos+[0,0,CONN_gui.uicontrol_border-tpos(3),0],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA,'units','norm')];
        uicontrol('style','frame','units','pixels','position',tpos+[0,0,0,CONN_gui.uicontrol_border-tpos(4)],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA,'units','norm');
        uicontrol('style','frame','units','pixels','position',tpos+[0,tpos(4)-CONN_gui.uicontrol_border,0,CONN_gui.uicontrol_border-tpos(4)],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA,'units','norm');
        if doemphasis1, conn_menumanager('onregion',htb,-1,get(h,'position'),h); end
        if doemphasis2, conn_menumanager('onregion',h,0,get(h,'position')); end
	case 'listbox',
        if ~isequal(CONN_h.screen.hfig,gcf), figure(CONN_h.screen.hfig); end
		if ~isempty(title), h2=uicontrol('style','text','units','norm','position',position+[0,position(4),0,.04-position(4)],'string',title,'backgroundcolor',CONN_gui.backgroundcolorA,titleopts{:},'fontunits','norm','horizontalalignment','left'); end
        if isempty(string), string=' '; end
		h=uicontrol('style','listbox','units','norm','position',position,'foregroundcolor',.0+1.0*([0 0 0]+(mean(CONN_gui.backgroundcolorA)<.5)),'backgroundcolor',CONN_gui.backgroundcolorA,'string',string,'max',1,'value',1,'tooltipstring',tooltipstring,'interruptible','off','callback',callback,contropts{:});
        set(h,'units','pixels');
        tpos=get(h,'position');
        tpos2=get(h,'extent');
%         set(h,'position',tpos+[0,0,18,0]);
%         tpos=get(h,'position');
        set(h,'units','norm');
%         position1=get(h,'position');
        uicontrol('style','frame','units','pixels','position',tpos+[0,0,0,CONN_gui.uicontrol_border-tpos(4)],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA,'units','norm');
        ht=uicontrol('style','frame','units','pixels','position',tpos+[0,0,CONN_gui.uicontrol_border-tpos(3),0],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA,'units','norm');
        if doemphasis1, conn_menumanager('onregion',ht,-1,get(h,'position')+~isempty(callback2)*[0 -.04 0 0],h); end
        ht=uicontrol('style','frame','units','pixels','position',tpos+[0,0,0,tpos2(4)-tpos(4)],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA,'units','norm');
        conn_menumanager('onregion',ht,-1,get(h,'position')+~isempty(callback2)*[0 -.04 0 0],h);
        ht=uicontrol('style','frame','units','pixels','position',tpos+[tpos(3)-18,0,18-tpos(3),0],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA,'units','norm');
        conn_menumanager('onregion',ht,-1,get(h,'position'),@(x)get(h,'extent')*max(1,(get(h,'max')==1)*numel(cellstr(get(h,'string'))))*[0;0;0;1]>=get(h,'position')*[0;0;0;1]);
        uicontrol('style','frame','units','pixels','position',tpos+[0,tpos(4)-CONN_gui.uicontrol_border,0,CONN_gui.uicontrol_border-tpos(4)],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA,'units','norm');
        if ~isempty(callback2), 
            if ~iscell(callback2), callback2={['h=get(gcbo,''userdata''); set(h,''value'',numel(cellstr(get(h,''string'')))); ',callback],callback2}; end
            ht=[conn_menu('pushbutton2',position+[0 -.04 .02-position(3) .04-position(4)],'','+',['Adds new ',lower(title)],callback2{1}),...
                conn_menu('pushbutton2',position+[.02 -.04 .02-position(3) .04-position(4)],'','-',['Removes selected ',lower(title)],['if isequal(questdlg(''Are you sure you want to delete the selected ',lower(title),'?'','''',''Yes'',''No'',''Yes''),''Yes''), ',callback2{2},'; end'])];
            set(ht,'userdata',h,'fontweight','bold','visible','off');
            conn_menumanager('onregion',ht,1,get(h,'position')+[0 -.04 0 0],h);
        end
        if doemphasis2, conn_menumanager('onregion',h,0,get(h,'position')); end
	case 'listbox2',
        if ~isequal(CONN_h.screen.hfig,gcf), figure(CONN_h.screen.hfig); end
		if ~isempty(title), h2=uicontrol('style','text','units','norm','position',position+[0,position(4),0,.04-position(4)],'string',title,'backgroundcolor',CONN_gui.backgroundcolorA,titleopts{:},'fontname','monospaced','horizontalalignment','left'); end
		h=uicontrol('style','listbox','units','norm','position',position,'backgroundcolor',CONN_gui.backgroundcolorA,'string',string,'max',1,'value',1,'tooltipstring',tooltipstring,'interruptible','off','callback',callback,contropts{:});
        set(h,'units','pixels');
        tpos=get(h,'position');
        tpos2=get(h,'extent');
%         set(h,'position',tpos+[0,0,18,0]);
%         tpos=get(h,'position');
        set(h,'units','norm');
%         position1=get(h,'position');
        htb=uicontrol('style','frame','units','pixels','position',tpos+[tpos(3)-18,0,18-tpos(3),0],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA,'units','norm');
        conn_menumanager('onregion',htb,-1,get(h,'position'),h);
%             conn_menumanager('onregion',htb,-1,get(h,'position'),@(x)set(h,'position',position+(~x)*(position1-position)));
        uicontrol('style','frame','units','pixels','position',tpos+[0,0,CONN_gui.uicontrol_border-tpos(3),0],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA,'units','norm');
        uicontrol('style','frame','units','pixels','position',tpos+[0,0,0,tpos2(4)-tpos(4)],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA,'units','norm');
        uicontrol('style','frame','units','pixels','position',tpos+[0,tpos(4)-CONN_gui.uicontrol_border,0,CONN_gui.uicontrol_border-tpos(4)],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA,'units','norm');
        if doemphasis2, conn_menumanager('onregion',h,0,get(h,'position')); end
	case 'text',	
        if ~isequal(CONN_h.screen.hfig,gcf), figure(CONN_h.screen.hfig); end
		if ~isempty(title), h2=uicontrol('style','text','units','norm','position',position+[0,position(4),0,.04-position(4)],'string',title,'backgroundcolor',CONN_gui.backgroundcolorA,titleopts{:},'fontunits','norm','horizontalalignment','center'); end
        bg=CONN_gui.backgroundcolorA;
		h=uicontrol('style','text','units','norm','position',position,'backgroundcolor',bg,'string',string,'tooltipstring',tooltipstring,'max',2,'horizontalalignment','center',contropts{:});
    case 'text2',
        if ~isequal(CONN_h.screen.hfig,gcf), figure(CONN_h.screen.hfig); end
        ht=axes('units','norm','position',position,'visible','off');
        h=text(0,0,string,'horizontalalignment','left','verticalalignment','middle');
        set(ht,'xlim',[-.01,1],'ylim',[-1,1]);
	case 'popup',
        if ~isequal(CONN_h.screen.hfig,gcf), figure(CONN_h.screen.hfig); end
		if ~isempty(title), h2=uicontrol('style','text','units','norm','position',position+[0,position(4),0,.03-position(4)],'string',title,'backgroundcolor',CONN_gui.backgroundcolorA,titleopts{:},'fontunits','norm','horizontalalignment','left'); end
        bg=CONN_gui.backgroundcolorB; %min(1,CONN_gui.backgroundcolorA*5*min(2*(position(2)+.5*position(4)),2-2*(position(2)+.5*position(4))).^2); %
        if 0,%CONN_gui.domacGUIbugfix==1,%&&mean(bg)<.5,
            try
                drawnow;
                originalLnF = javax.swing.UIManager.getLookAndFeel;
                javax.swing.UIManager.setLookAndFeel('javax.swing.plaf.metal.MetalLookAndFeel');
                %javax.swing.UIManager.setLookAndFeel('javax.swing.plaf.nimbus.NimbusLookAndFeel');
                %javax.swing.UIManager.setLookAndFeel('com.jgoodies.looks.plastic.PlasticLookAndFeel');
            catch
                CONN_gui.domacGUIbugfix=2;
            end
        end
		h=uicontrol('style','popupmenu','units','norm','position',position,'backgroundcolor',bg,'string',cellstr(string),'value',1,'tooltipstring',tooltipstring,'interruptible','off','callback',callback,contropts{:});
        if CONN_gui.domacGUIbugfix==2,
            set(h,'backgroundcolor',[1 1 1],'foregroundcolor',[0 0 0]);
        end
		if 0,%CONN_gui.domacGUIbugfix==1,%&&mean(bg)<.5, 
           drawnow;
           javax.swing.UIManager.setLookAndFeel(originalLnF);
        end
        set(h,'units','pixels');
        tpos=get(h,'position');
        tpos2=get(h,'extent');
        tpos=tpos+[0,tpos(4)-tpos2(4)-6,0,tpos2(4)-tpos(4)+6]; 
        %uicontrol('style','frame','units','pixels','position',tpos+[tpos(3)-2,0,2-tpos(3),0],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA,'units','norm'),...
        uicontrol('style','frame','units','pixels','position',tpos+[tpos(3)-CONN_gui.uicontrol_borderpopup,0,CONN_gui.uicontrol_borderpopup-tpos(3),0],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA,'units','norm');
        %uicontrol('style','checkbox','units','pixels','position',tpos+[tpos(3)-18,tpos(4)-12,10-tpos(3),10-tpos(4)],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA,'cdata',max(0,min(1,conn_bsxfun(@plus,shiftdim(CONN_gui.backgroundcolorA,-1),conn_bsxfun(@times,shiftdim(CONN_gui.backgroundcolorB-CONN_gui.backgroundcolorA,-1),[0 0 0 0 0 0 0;0 0 0 0 0 0 0;1 1 1 1 1 1 1;0 1 1 1 1 1 0;0 0 1 1 1 0 0;0 0 0 1 0 0 0;0 0 0 0 0 0 0;0 0 0 0 0 0 0])))),'units','norm');
        htb=[uicontrol('style','frame','units','pixels','position',tpos+[0,0,2-tpos(3),0],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA,'units','norm'),...
            uicontrol('style','frame','units','pixels','position',tpos+[0,0,0,4-tpos(4)],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA,'units','norm'),...
        uicontrol('style','frame','units','pixels','position',tpos+[0,tpos(4)-2,0,2-tpos(4)],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA,'units','norm')];
        %uicontrol('style','frame','units','pixels','position',tpos+[0-3,tpos(4)-11,3-tpos(3),3-tpos(4)],'foregroundcolor',CONN_gui.fontcolorB,'backgroundcolor',CONN_gui.fontcolorB,'units','norm');
        set(h,'units','norm');
        if doemphasis1, conn_menumanager('onregion',htb,-1,get(h,'position'),h); end
        if doemphasis2, conn_menumanager('onregion',h,0,get(h,'position')); end
	case 'popup0',
        if ~isequal(CONN_h.screen.hfig,gcf), figure(CONN_h.screen.hfig); end
		if ~isempty(title), h2=uicontrol('style','text','units','norm','position',position+[0,position(4),0,.03-position(4)],'string',title,'backgroundcolor',CONN_gui.backgroundcolorA,titleopts{:},'fontunits','norm','horizontalalignment','left'); end
        bg=CONN_gui.backgroundcolorA; %min(1,CONN_gui.backgroundcolorA*5*min(2*(position(2)+.5*position(4)),2-2*(position(2)+.5*position(4))).^2); %
        if 0,%CONN_gui.domacGUIbugfix==1,%&&mean(bg)<.5,
            try
                drawnow;
                originalLnF = javax.swing.UIManager.getLookAndFeel;
                javax.swing.UIManager.setLookAndFeel('javax.swing.plaf.metal.MetalLookAndFeel');
                %javax.swing.UIManager.setLookAndFeel('javax.swing.plaf.nimbus.NimbusLookAndFeel');
                %javax.swing.UIManager.setLookAndFeel('com.jgoodies.looks.plastic.PlasticLookAndFeel');
            catch
                CONN_gui.domacGUIbugfix=2;
            end
        end
		h=uicontrol('style','popupmenu','units','norm','position',position,'backgroundcolor',bg,'string',cellstr(string),'value',1,'tooltipstring',tooltipstring,'interruptible','off','callback',callback,contropts{:});
        if CONN_gui.domacGUIbugfix==2,
            set(h,'backgroundcolor',[1 1 1],'foregroundcolor',[0 0 0]);
        end
		if 0,%CONN_gui.domacGUIbugfix==1,%&&mean(bg)<.5, 
           drawnow;
           javax.swing.UIManager.setLookAndFeel(originalLnF);
        end
        set(h,'units','pixels');
        tpos=get(h,'position');
        tpos2=get(h,'extent');
        tpos=tpos+[0,tpos(4)-tpos2(4)-6,0,tpos2(4)-tpos(4)+6]; 
        %uicontrol('style','frame','units','pixels','position',tpos+[tpos(3)-2,0,2-tpos(3),0],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA,'units','norm'),...
        uicontrol('style','frame','units','pixels','position',tpos+[tpos(3)-CONN_gui.uicontrol_borderpopup,0,CONN_gui.uicontrol_borderpopup-tpos(3),0],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA,'units','norm');
        %uicontrol('style','checkbox','units','pixels','position',tpos+[tpos(3)-18,tpos(4)-12,10-tpos(3),10-tpos(4)],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA,'cdata',max(0,min(1,conn_bsxfun(@plus,shiftdim(CONN_gui.backgroundcolorA,-1),conn_bsxfun(@times,shiftdim(CONN_gui.backgroundcolorB-CONN_gui.backgroundcolorA,-1),[0 0 0 0 0 0 0;0 0 0 0 0 0 0;1 1 1 1 1 1 1;0 1 1 1 1 1 0;0 0 1 1 1 0 0;0 0 0 1 0 0 0;0 0 0 0 0 0 0;0 0 0 0 0 0 0])))),'units','norm');
        htb=[uicontrol('style','frame','units','pixels','position',tpos+[0,0,2-tpos(3),0],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA,'units','norm'),...
            uicontrol('style','frame','units','pixels','position',tpos+[0,0,0,4-tpos(4)],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA,'units','norm'),...
        uicontrol('style','frame','units','pixels','position',tpos+[0,tpos(4)-2,0,2-tpos(4)],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA,'units','norm')];
        %uicontrol('style','frame','units','pixels','position',tpos+[0-3,tpos(4)-11,3-tpos(3),3-tpos(4)],'foregroundcolor',CONN_gui.fontcolorB,'backgroundcolor',CONN_gui.fontcolorB,'units','norm');
        set(h,'units','norm');
        if doemphasis1, conn_menumanager('onregion',htb,-1,get(h,'position'),h); end
        if doemphasis2, conn_menumanager('onregion',h,0,get(h,'position')); end
	case 'popup2',
        if ~isequal(CONN_h.screen.hfig,gcf), figure(CONN_h.screen.hfig); end
		if ~isempty(title), h2=uicontrol('style','text','units','norm','position',position+[0,position(4),0,.03-position(4)],'string',title,'backgroundcolor',CONN_gui.backgroundcolorA,titleopts{:},'fontunits','norm','horizontalalignment','left'); end
        bg=CONN_gui.backgroundcolorA;%CONN_gui.backgroundcolorB; %min(1,CONN_gui.backgroundcolorA*5*min(2*(position(2)+.5*position(4)),2-2*(position(2)+.5*position(4))).^2); %
        if 0,%CONN_gui.domacGUIbugfix==1,%&&mean(bg)<.5,
            try
                drawnow;
                originalLnF = javax.swing.UIManager.getLookAndFeel;
                javax.swing.UIManager.setLookAndFeel('javax.swing.plaf.metal.MetalLookAndFeel');
            catch
                CONN_gui.domacGUIbugfix=2;
            end
        end
        h=uicontrol('style','popupmenu','units','norm','position',position,'backgroundcolor',bg,'string',cellstr(string),'value',1,'tooltipstring',tooltipstring,'interruptible','off','callback',callback,contropts{:});
        if CONN_gui.domacGUIbugfix==2,
            set(h,'backgroundcolor',[1 1 1],'foregroundcolor',[0 0 0]);
        end
		if 0,%CONN_gui.domacGUIbugfix==1,%&&mean(bg)<.5, 
           drawnow;
           javax.swing.UIManager.setLookAndFeel(originalLnF);
        end
        set(h,'units','pixels');
        tpos=get(h,'position');
        tpos2=get(h,'extent');
        tpos=tpos+[0,tpos(4)-tpos2(4)-6,0,tpos2(4)-tpos(4)+6];
        bg2=CONN_gui.backgroundcolor;
        %uicontrol('style','frame','units','pixels','position',tpos+[tpos(3)-2,0,2-tpos(3),0],'foregroundcolor',bg2,'backgroundcolor',bg2,'units','norm');
        uicontrol('style','frame','units','pixels','position',tpos+[tpos(3)-CONN_gui.uicontrol_borderpopup,0,CONN_gui.uicontrol_borderpopup-tpos(3),0],'foregroundcolor',bg2,'backgroundcolor',bg2,'units','norm');
        htb=[uicontrol('style','frame','units','pixels','position',tpos+[0,0,2-tpos(3),0],'foregroundcolor',bg2,'backgroundcolor',bg2,'units','norm'),...
            uicontrol('style','frame','units','pixels','position',tpos+[0,0,0,2+2-tpos(4)],'foregroundcolor',bg2,'backgroundcolor',bg2,'units','norm')];
        uicontrol('style','frame','units','pixels','position',tpos+[0,tpos(4)-2,0,2-tpos(4)],'foregroundcolor',bg2,'backgroundcolor',bg2,'units','norm');
        %uicontrol('style','frame','units','pixels','position',tpos+[0-3,tpos(4)-11,3-tpos(3),3-tpos(4)],'foregroundcolor',CONN_gui.fontcolorB,'backgroundcolor',CONN_gui.fontcolorB,'units','norm');
        set(h,'units','norm');
        if doemphasis1, conn_menumanager('onregion',htb,-1,get(h,'position'),h); end
        if doemphasis2, conn_menumanager('onregion',h,0,get(h,'position')); end
	case 'checkbox',
        if ~isequal(CONN_h.screen.hfig,gcf), figure(CONN_h.screen.hfig); end
		if ~isempty(title), h2=uicontrol('style','text','units','norm','position',position+[position(3),0,.15-position(3),0],'string',title,'backgroundcolor',CONN_gui.backgroundcolorA,contropts{:},'fontunits','norm','horizontalalignment','left'); hext=get(h2,'extent'); hext=hext(end-1:end); set(h2,'position',position+[position(3),0,max(.05,min(hext(1),.15))-position(3),0]); else hext=[0 0]; end
        if ischar(string),string={string}; end
        for n1=1:numel(string), 
            h(n1)=uicontrol('style','checkbox','units','norm','position',position-[0,position(4)*(n1-1),0,0],'backgroundcolor',CONN_gui.backgroundcolorA,'string',string{n1},'value',1,'tooltipstring',tooltipstring,'interruptible','off','callback',callback,contropts{:}); 
            hext2=get(h(n1),'extent'); hext2=hext2(end-1:end);
            if doemphasis2, hpos=get(h(n1),'position'); conn_menumanager('onregion',[h2 h(n1)],0,hpos+[0 0 max(hext,hext2)-hpos(3:4)]); end
        end
	case 'checkbox2',
        if ~isequal(CONN_h.screen.hfig,gcf), figure(CONN_h.screen.hfig); end
		if ~isempty(title), h2=uicontrol('style','text','units','norm','position',position+[0,position(4),0,.04-position(4)],'string',title,'backgroundcolor',CONN_gui.backgroundcolorA,titleopts{:},'fontunits','norm','horizontalalignment','left'); end
        if ischar(string),string={string}; end
        if ischar(tooltipstring), tooltipstring=repmat({tooltipstring},1,numel(string)); end
        for n1=1:numel(string), 
            h(n1)=uicontrol('style','checkbox','units','norm','position',position-[0,position(4)*(n1-1),0,0],'backgroundcolor',CONN_gui.backgroundcolorA,'string',string{n1},'value',1,'tooltipstring',tooltipstring{n1},'interruptible','off','callback',callback,contropts{:}); 
            if doemphasis2, conn_menumanager('onregion',h(n1),0,get(h(n1),'position')); end
        end
    case 'slider',
        if ~isequal(CONN_h.screen.hfig,gcf), figure(CONN_h.screen.hfig); end
		h=uicontrol('style','slider','units','norm','position',position,'foregroundcolor','w','backgroundcolor',CONN_gui.backgroundcolorA,'tooltipstring',tooltipstring,'interruptible','off','callback',callback,contropts{:});
        try, if iscell(callback)&&~isempty(callback), addlistener(h, 'ContinuousValueChange',@(varargin)feval(callback{1},h,[],callback{2:end})); end; end
%         set(h,'units','pixels');
%         tpos=get(h,'position');
%         uicontrol('style','frame','units','pixels','position',tpos+[tpos(3)-2,0,2-tpos(3),0],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA,'units','norm');
%         uicontrol('style','frame','units','pixels','position',tpos+[0,0,2-tpos(3),0],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA,'units','norm');
%         uicontrol('style','frame','units','pixels','position',tpos+[0,0,0,2-tpos(4)],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA,'units','norm');
%         uicontrol('style','frame','units','pixels','position',tpos+[0,tpos(4)-2,0,2-tpos(4)],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA,'units','norm');
%         set(h,'units','norm');
	case 'axes',
        if ~isequal(CONN_h.screen.hfig,gcf), figure(CONN_h.screen.hfig); end
		if ~isempty(title), h2=uicontrol('style','text','units','norm','position',position+[0,position(4),0,.04-position(4)],'string',title,'backgroundcolor',CONN_gui.backgroundcolorA,titleopts{:},'fontunits','norm','horizontalalignment','center'); end
		h=axes('units','norm','position',position,'visible','off'); 
	case 'image',
        if ~isequal(CONN_h.screen.hfig,gcf), figure(CONN_h.screen.hfig); end
		if ~isempty(title), 
            %h.htitle=uicontrol('style','text','units','norm','position',(position+[0,position(4),0,0]).*[1,1,1,0]+[0,0,0,.04],'string',title,'backgroundcolor',CONN_gui.backgroundcolorA,titleopts{:},'fontunits','norm','horizontalalignment','center'); 
            ht=axes('units','norm','position',position+[0,position(4),0,.04-position(4)],'visible','off');
            h.htitle=text(0,0,title,titleopts2{:},'horizontalalignment','center','verticalalignment','middle'); 
            set(ht,'xlim',[-1,1],'ylim',[-1,1]);
        end
		data=struct('n',[],'thr',.25,'cscale',1,'x0',[],'x1',[],'p',0); 
		h.h21=axes('units','norm','position',position+[.01*position(3),0,-.02*position(3),0],'color',CONN_gui.backgroundcolorA,'xtick',[],'ytick',[]);  axis off;
		h.h22=text(0,0,nullstr,'fontsize',14+CONN_gui.font_offset,'horizontalalignment','center','clipping','on','color',.3+[0 0 0]+.4*(mean(CONN_gui.backgroundcolorA)>.5));%[0.54 0.14 0.07]);
        set(h.h21,'xlim',[-1,1],'ylim',[-1,1],'xtick',[],'ytick',[]);
		h.h1=axes('units','norm','position',position,'xtick',[],'ytick',[]); 
		h.h2=image(shiftdim(CONN_gui.backgroundcolorA,-1)); 
		%h.h6=text(0,0,'','fontsize',8+CONN_gui.font_offset,'color','k','backgroundcolor','w'); 
		h.h3=axes('units','norm','position',position+[.1*position(3),0,-.2*position(3),0]); 
		h.h4=plot(0,zeros(1,nmax))';
		hold on; h.h4b=plot(0,nan,':o','color',[.1 .1 .1]+.8*(.5>mean(CONN_gui.backgroundcolor))); hold off;
		h.h11=axes('units','norm','position',position+[.02*position(3),0,-.04*position(3),0],'color',CONN_gui.backgroundcolorA,'xtick',[],'ytick',[]); 
		h.h12=patch(struct('vertices',[],'faces',[]),'edgecolor','none','facecolor','w','specularstrength',0,'backFaceLighting','lit');
        h.h13=[light('position',[1000 0 .1]) light('position',[-1000 0 .1])];
        hc1=uicontextmenu;
        uimenu(hc1,'Label','Superior view','callback','set(gca,''cameraposition'',[0 0 1000],''cameraupvector'',[0 1 0])');
        uimenu(hc1,'Label','Inferior view','callback','set(gca,''cameraposition'',[0 0 -1000],''cameraupvector'',[0 1 0])');
        uimenu(hc1,'Label','Anterior view','callback','set(gca,''cameraposition'',[0 1000 0],''cameraupvector'',[0 0 1])');
        uimenu(hc1,'Label','Posterior view','callback','set(gca,''cameraposition'',[0 -1000 0],''cameraupvector'',[0 0 1])');
        set([h.h11 h.h12],'uicontextmenu',hc1);
		h.h5=conn_menu('slider',[position(1)+position(3)-0*.015,position(2),.015,position(4)],'','','z-slice',{@conn_menu,'updateslider1'});
		%h.h6=conn_menu('slider',[position(1),position(2)-.035,position(3),.03],'','','display threshold',{@conn_menu,'updateslider2'});
        %set(h.h6,'min',0,'max',1,'value',data.thr);
		%h.h5=uicontrol('style','slider','units','norm','position',[position(1)+position(3)-0*.015,position(2),.015,position(4)],'callback',{@conn_menu,'updateslider1'},'backgroundcolor',CONN_gui.backgroundcolorA);
		%h.h6=uicontrol('style','slider','units','norm','position',[position(1),position(2)-.03,position(3),.03],'min',0,'max',1,'callback',{@conn_menu,'updateslider2'},'backgroundcolor',CONN_gui.backgroundcolorA,'value',data.thr);
		%h.h7=axes('position',[position(1)+0*.015,position(2)-.06,position(3)-0*.03,.02],'color',CONN_gui.backgroundcolorA); 
		h.h7=axes('position',[position(1)-.01,position(2),.01,position(4)],'color',CONN_gui.backgroundcolorA,'xtick',[],'ytick',[]); 
		h.h8=image((1:128)'); 
        [h.h9,nill,h.h9a]=conn_menu('edit',[position(1)-.01,position(2)+position(4)+.001,.02,.04],'',num2str(data.cscale),'display colorscale',{@conn_menu,'updatecscale'});
        [h.h10,nill,h.h10a]=conn_menu('edit',[position(1)+position(3)-.1,position(2)-1*.05,.05,.04],'',num2str(data.thr),'display threshold',{@conn_menu,'updatethr'});
		h.h6a=uicontrol('units','norm','position',[.0001 .0001 .0001 .0001],'style','text','fontsize',8+CONN_gui.font_offset,'foregroundcolor','k','backgroundcolor','w','horizontalalignment','left'); 
        conn_menumanager('onregion',h.h6a,1,position,h.h2,@(varargin)conn_menubuttonmtnfcn('volume',gcf,h.h1,h.h2,h.h6a));
		h.h6b=uicontrol('units','norm','position',[.0001 .0001 .0001 .0001],'style','text','fontsize',8+CONN_gui.font_offset,'foregroundcolor','k','backgroundcolor','w','horizontalalignment','left'); 
        conn_menumanager('onregion',h.h6b,1,position,h.h3,@(varargin)conn_menubuttonmtnfcn('line',gcf,h.h3,h.h4,h.h6b,h.h4b));
        conn_menumanager('onregion',h.h4b,1,position,h.h3);
		%h.h9=uicontrol('style','edit','units','norm','position',[position(1)-.015,position(2)+position(4),.02,.04],'callback',{@conn_menu,'updatecscale'},'backgroundcolor',CONN_gui.backgroundcolorA,'string',num2str(data.cscale),'fontsize',8+CONN_gui.font_offset); 
		%h.h10=uicontrol('style','edit','units','norm','position',[position(1)+position(3)-.1,position(2)-1*.05,.1,.04],'callback',{@conn_menu,'updatethr'},'backgroundcolor',CONN_gui.backgroundcolorA,'foregroundcolor',.0+1.0*([0 0 0]+(mean(CONN_gui.backgroundcolorA)<.5)),'string',num2str(data.thr),'fontsize',8+CONN_gui.font_offset); 
		set(h.h1,'color',CONN_gui.backgroundcolorA,'xtick',[],'ytick',[],'xcolor',CONN_gui.backgroundcolorA,'ycolor',CONN_gui.backgroundcolorA); 
		set(h.h3,'color',CONN_gui.backgroundcolorA,'xtick',[],'ytick',[],'xcolor',CONN_gui.backgroundcolorA,'ycolor',CONN_gui.backgroundcolorA,'visible','off'); 
		set(h.h7,'color',CONN_gui.backgroundcolorA,'xtick',[],'ytick',[64.5],'yticklabel',{'0'},'xcolor',CONN_gui.backgroundcolorB,'ycolor',CONN_gui.backgroundcolorB,'visible','off','ydir','normal'); 
		set(h.h11,'color',CONN_gui.backgroundcolorA,'xtick',[],'ytick',[],'xcolor',CONN_gui.backgroundcolorA,'ycolor',CONN_gui.backgroundcolorA,'zcolor',CONN_gui.backgroundcolorA,'visible','off'); 
		set(h.h9,'backgroundcolor',CONN_gui.backgroundcolorA,'foregroundcolor',.0+1.0*([0 0 0]+(mean(CONN_gui.backgroundcolorA)<.5)),'visible','off'); 
		set([h.h4,h.h4b,h.h5,h.h6a,h.h6b,h.h7,h.h8,h.h9,h.h9a,h.h10,h.h10a,h.h11],'visible','off'); 
		set([h.h5,h.h9,h.h10],'userdata',h);
		set([h.h2],'userdata',data);
	case 'image2',
        if ~isequal(CONN_h.screen.hfig,gcf), figure(CONN_h.screen.hfig); end
		if ~isempty(title), 
            ht=axes('units','norm','position',position+[0,position(4),0,.04-position(4)],'visible','off');
            h.htitle=text(0,0,title,titleopts2{:},'horizontalalignment','center','verticalalignment','middle'); 
            set(ht,'xlim',[-1,1],'ylim',[-1,1]);
            %h.htitle=uicontrol('style','text','units','norm','position',(position+[0,position(4),0,0]).*[1,1,1,0]+[0,0,0,.04],'string',title,'foregroundcolor',.0+1.0*([0 0 0]+(mean(CONN_gui.backgroundcolorA)<.5)),'backgroundcolor',CONN_gui.backgroundcolorA,titleopts{:},'fontunits','norm','horizontalalignment','center'); 
        end
		data=struct('n',[],'thr',.001,'cscale',1,'x0',[],'x1',[],'p',0); 
		h.h21=axes('units','norm','position',position+[.01*position(3),0,-.02*position(3),0],'color',CONN_gui.backgroundcolorA); axis off;
		h.h22=text(0,0,nullstr,'fontsize',14+CONN_gui.font_offset,'horizontalalignment','center','color',.3+[0 0 0]+.4*(mean(CONN_gui.backgroundcolorA)>.5),'clipping','on');
        set(h.h21,'xlim',[-1,1],'ylim',[-1,1],'xtick',[],'ytick',[]);
		h.h1=axes('units','norm','position',position); 
		h.h2=image(shiftdim(CONN_gui.backgroundcolorA,-1)); 
		%h.h6=text(0,0,'','fontsize',8+CONN_gui.font_offset,'color','k','backgroundcolor','w'); 
		h.h3=axes('units','norm','position',position+[.1*position(3),0,-.2*position(3),0]); 
		h.h4=plot(0,zeros(1,nmax))';
		hold on; h.h4b=plot(0,nan,':o','color',[.1 .1 .1]+.8*(.5>mean(CONN_gui.backgroundcolor))); hold off;
		h.h11=axes('units','norm','position',position+[.02*position(3),0,-.04*position(3),0],'color',CONN_gui.backgroundcolorA); 
		h.h12=patch(struct('vertices',[],'faces',[]),'edgecolor','none','facecolor','w','specularstrength',0,'backFaceLighting','lit');
        h.h13=[light('position',[1000 0 .1]) light('position',[-1000 0 .1])];
        hc1=uicontextmenu;
        uimenu(hc1,'Label','Superior view','callback','set(gca,''cameraposition'',[0 0 1000],''cameraupvector'',[0 1 0])');
        uimenu(hc1,'Label','Inferior view','callback','set(gca,''cameraposition'',[0 0 -1000],''cameraupvector'',[0 1 0])');
        uimenu(hc1,'Label','Anterior view','callback','set(gca,''cameraposition'',[0 1000 0],''cameraupvector'',[0 0 1])');
        uimenu(hc1,'Label','Posterior view','callback','set(gca,''cameraposition'',[0 -1000 0],''cameraupvector'',[0 0 1])');
        set([h.h11 h.h12],'uicontextmenu',hc1);
		h.h5=conn_menu('slider',[position(1)+position(3)-0*.015,position(2),.015,position(4)],'','','z-slice',{@conn_menu,'updateslider1'});
		%h.h6=conn_menu('slider',[position(1),position(2)-.035,position(3),.03],'','','display threshold',{@conn_menu,'updateslider2'});
        %set(h.h6,'min',0,'max',1,'value',data.thr);
		%h.h5=uicontrol('style','slider','units','norm','position',[position(1)+position(3)-0*.015,position(2),.015,position(4)],'callback',{@conn_menu,'updateslider1'},'backgroundcolor',CONN_gui.backgroundcolorA);
		%h.h6=uicontrol('style','slider','units','norm','position',[position(1),position(2)-.03,position(3),.03],'min',0,'max',1,'callback',{@conn_menu,'updateslider2'},'backgroundcolor',CONN_gui.backgroundcolorA,'value',data.thr);
		%h.h7=axes('position',[position(1)+0*.015,position(2)-.06,position(3)-0*.03,.02],'color',CONN_gui.backgroundcolorA); 
		h.h7=axes('position',[position(1)-.01,position(2),.01,position(4)],'color',CONN_gui.backgroundcolorA); 
		h.h8=image((1:128)'); 
        [h.h9,nill,h.h9a]=conn_menu('edit',[position(1)-.01,position(2)+position(4),.02,.04],'',num2str(data.cscale),'display colorscale',{@conn_menu,'updatecscale'});
        [h.h10,nill,h.h10a]=conn_menu('edit',[position(1)+position(3)-.1,position(2)-1*.05,.05,.04],'',num2str(data.thr),'display threshold',{@conn_menu,'updatethr'});
		h.h6a=uicontrol('units','norm','position',[.0001 .0001 .0001 .0001],'style','text','fontsize',8+CONN_gui.font_offset,'foregroundcolor','k','backgroundcolor','w','horizontalalignment','left');
        conn_menumanager('onregion',h.h6a,1,position,h.h2,@(varargin)conn_menubuttonmtnfcn('volume',gcf,h.h1,h.h2,h.h6a));
		h.h6b=uicontrol('units','norm','position',[.0001 .0001 .0001 .0001],'style','text','fontsize',8+CONN_gui.font_offset,'foregroundcolor','k','backgroundcolor','w','horizontalalignment','left'); 
        conn_menumanager('onregion',h.h6b,1,position,h.h3,@(varargin)conn_menubuttonmtnfcn('line',gcf,h.h3,h.h4,h.h6b,h.h4b));
        conn_menumanager('onregion',h.h4b,1,position,h.h3);
		%h.h9=uicontrol('style','edit','units','norm','position',[position(1)-.015,position(2)+position(4),.02,.04],'callback',{@conn_menu,'updatecscale'},'backgroundcolor',CONN_gui.backgroundcolorA,'string',num2str(data.cscale)); 
		%h.h10=uicontrol('style','edit','units','norm','position',[position(1)+position(3)-.1,position(2)-1*.05,.1,.04],'callback',{@conn_menu,'updatethr'},'backgroundcolor',CONN_gui.backgroundcolorA,'foregroundcolor',.0+1.0*([0 0 0]+(mean(CONN_gui.backgroundcolorA)<.5)),'string',num2str(data.thr)); 
		set(h.h1,'color',CONN_gui.backgroundcolorA,'xtick',[],'ytick',[],'xcolor',CONN_gui.backgroundcolorA,'ycolor',CONN_gui.backgroundcolorA); 
		set(h.h3,'color',CONN_gui.backgroundcolorA,'xtick',[],'ytick',[],'xcolor',.0+1.0*([0 0 0]+(mean(CONN_gui.backgroundcolorA)<.5)),'ycolor',.0+1.0*([0 0 0]+(mean(CONN_gui.backgroundcolorA)<.5)),'visible','off'); 
		set(h.h7,'color',CONN_gui.backgroundcolorA,'xtick',[],'ytick',[64.5],'yticklabel',{'0'},'xcolor',CONN_gui.backgroundcolorB,'ycolor',CONN_gui.backgroundcolorB,'visible','off','ydir','normal'); 
		set(h.h9,'backgroundcolor',CONN_gui.backgroundcolorA,'foregroundcolor',.0+1.0*([0 0 0]+(mean(CONN_gui.backgroundcolorA)<.5)),'visible','off'); 
		set(h.h11,'color',CONN_gui.backgroundcolorA,'xtick',[],'ytick',[],'xcolor',CONN_gui.backgroundcolorA,'ycolor',CONN_gui.backgroundcolorA,'zcolor',CONN_gui.backgroundcolorA,'visible','off'); 
		set([h.h4,h.h4b,h.h5,h.h6a,h.h6b,h.h7,h.h8,h.h9,h.h9a,h.h10,h.h10a,h.h11],'visible','off'); 
		set([h.h5,h.h9,h.h10],'userdata',h);
		set([h.h2],'userdata',data);
	case 'hist',
        if ~isequal(CONN_h.screen.hfig,gcf), figure(CONN_h.screen.hfig); end
		if ~isempty(title), h2=uicontrol('style','text','units','norm','position',position+[0,position(4),0,.04-position(4)],'string',title,'backgroundcolor',CONN_gui.backgroundcolorA,titleopts{:},'fontunits','norm','horizontalalignment','center'); end
		h.h1=axes('units','norm','position',position,'fontsize',8+CONN_gui.font_offset); 
		h.h3=patch(0,0,'k'); 
		h.h4=patch(0,0,'k'); 
		h.h5=patch(0,0,'k'); 
		hold on; h.h2=plot([0,0],[0,0],'k-'); hold off;
		h.h6=text(0,0,'original','fontsize',8+CONN_gui.font_offset); 
		h.h7=text(0,0,'after denoising','fontsize',8+CONN_gui.font_offset); 
		set(h.h1,'color',CONN_gui.backgroundcolorA,'ytick',[],'xcolor',.5+0.0*([0 0 0]+(mean(CONN_gui.backgroundcolorA)<.5)),'ycolor',CONN_gui.backgroundcolorA,'visible','off'); 
        set([h.h1,h.h2,h.h3,h.h4,h.h5,h.h6,h.h7],'visible','off');
	case 'filesearch',
        if ~isequal(CONN_h.screen.hfig,gcf), figure(CONN_h.screen.hfig); end
		h=conn_filesearchtool('position',[.73,.06,.25,.84],'backgroundcolor',CONN_gui.backgroundcolorA,titleopts{:},...
			'title',title,'filter',string,'callback',callback,'max',1);
        %if ~isempty(callback2), h2=conn_menu('pushbutton',[.652,.78,.02,.04],'','>','go to folder containing selected subject datafile',callback2); end
		%set([h.folder,h.filter,h.files],'backgroundcolor',CONN_gui.backgroundcolorA,'foregroundcolor','w');
	case {'frame','frame2'}
        if ~isequal(CONN_h.screen.hfig,gcf), figure(CONN_h.screen.hfig); end
        if strcmpi(type,'frame')
            h2=axes('units','norm','position',position);
            set(h2,'unit','pixels');
            tpos=get(h2,'position')+1*[-12 -12 24 24];
            set(h2,'position',tpos,'color',min(1,CONN_gui.backgroundcolor),'xtick',[],'ytick',[],'xcolor',max(0,CONN_gui.backgroundcolor),'ycolor',max(0,CONN_gui.backgroundcolor),'box','off','yaxislocation','right');
            [i,j]=ndgrid([0:2:tpos(4) tpos(4):-2:0],[0:2:tpos(3) tpos(3):-2:0]);
            b0=conn_guibackground('get',tpos,size(i));
            h3=image(max(0,min(1, conn_bsxfun(@plus,b0,conn_bsxfun(@times,shiftdim([1 1 .75],-1),-.1*(min(1,min(i,j)/24).^2))))),'parent',h2);
            set(h2,'visible','off','units','norm');
            %h3=patch([0,0,1,1],[0,1,1,0],'w');set(h3,'edgecolor',CONN_gui.backgroundcolorA,'facecolor','none');set(h2,'xlim',[0 1],'ylim',[0 1]); axis off;
            bg2=max(0,min(1,CONN_gui.backgroundcolor));
            h=axes('units','norm','position',position);
            set(h,'color',CONN_gui.backgroundcolorA,'xtick',[],'ytick',[],'xcolor',bg2,'ycolor',bg2,'box','off','yaxislocation','right');
            %set(h,'color',CONN_gui.backgroundcolorA,'xtick',[],'ytick',[],'xcolor',CONN_gui.backgroundcolorA,'ycolor',CONN_gui.backgroundcolorA,'box','on');
            if strcmpi(type,'frame2')
                set([h3],'visible','off'); conn_menumanager('onregion',[h3],1,get(h,'position'));
            end
        else
            bg2=max(0,min(1,CONN_gui.backgroundcolor));
            h=axes('units','norm','position',position);
            set(h,'color',CONN_gui.backgroundcolorA,'xtick',[],'ytick',[],'xcolor',bg2,'ycolor',bg2,'box','off','yaxislocation','right');
        end
		if ~isempty(title), 
            if 0,%strcmpi(type,'frame')
                bg1=CONN_gui.backgroundcolor;
                bg2=max(0,min(1, (1-.75/8)*bg1+.75/8*[6/6,2/6,2/6]));
                ht=axes('units','norm','position',(position+[0,position(4),0,0]).*[1,1,1,0]+[0,.01,0,.04],'color',bg2,'xtick',[],'ytick',[],'xcolor',bg1,'ycolor',bg1); %,'visible','off');
            else
                ht=axes('units','norm','position',(position+[0,position(4),0,0]).*[1,1,1,0]+[0,.01,0,.04],'visible','off');
            end
            ht2=text(0,0,title,'horizontalalignment','center',titleopts2{:}); 
            set(ht,'xlim',[-1,1],'ylim',[-1,1]);
            %uicontrol('style','text','units','norm','position',(position+[0,position(4),0,0]).*[1,1,1,0]+[0,0,0,.04],'string',title,'foregroundcolor',.0+1.0*([0 0 0]+(mean(CONN_gui.backgroundcolorA)<.5)),'backgroundcolor',min(1,1.4*get(gcf,'color')),'fontweight','bold','fontsize',8+CONN_gui.font_offset,'fontunits','norm','horizontalalignment','center'); 
        end
        %image(conn_bsxfun(@times,shiftdim(get(gcf,'color'),-1),0+.5*convn(rand(100),ones(11)/25,'same')));
		%h=axes('units','norm','position',[position(1),position(2)+.99*position(4),position(3),.01*position(4)],'color',CONN_gui.backgroundcolorA,'xtick',[],'ytick',[],'xcolor',.0+1.0*([0 0 0]+(mean(CONN_gui.backgroundcolorA)<.5)),'ycolor',.0+1.0*([0 0 0]+(mean(CONN_gui.backgroundcolorA)<.5)),'box','on');
        
	case 'updatehist',
		if isempty(title), 
			set([position.h1,position.h2,position.h3,position.h4,position.h5,position.h6,position.h7],'visible','off'); 
		else 
            set(position.h3,'xdata',title{1},'ydata',title{2},'facecolor',1/2*[1,1,0],'facealpha',1,'edgecolor','none');
            set(position.h4,'xdata',title{1},'ydata',title{3},'facecolor',.75/2*[1,1,1],'facealpha',1,'edgecolor','none');
            set(position.h5,'xdata',title{1},'ydata',min(title{2},title{3}),'facecolor',[.2,.2,.4],'facealpha',1,'edgecolor','none');
            set(position.h2,'xdata',[0,0],'ydata',[0,max(max(title{2}),max(title{3}))*1.25],'color','w');
            axis(position.h1,'tight');
            [nill,idxtemp]=max(title{3});set(position.h6,'position',[title{1}(idxtemp),title{3}(idxtemp),1],'color',.75/2*[1,1,1],'horizontalalignment','center','verticalalignment','bottom');
            [nill,idxtemp]=max(title{2});set(position.h7,'position',[title{1}(idxtemp),title{2}(idxtemp),1],'color',1/2*[1,1,0],'horizontalalignment','center','verticalalignment','bottom');
            set([position.h1,position.h2,position.h3,position.h4,position.h5,position.h6,position.h7],'visible','on');
        end
	case {'update','updateplot','updateimage','updatematrix'},
		if isempty(title), 
			set(position.h2,'cdata',min(1,conn_bsxfun(@plus,conn_bsxfun(@times,eye(100)|flipud(eye(100)),shiftdim([.25 0 0],-1)),min(1,shiftdim(CONN_gui.backgroundcolorA,-1))))); set(position.h1,'xlim',[.5,1.5],'ylim',[.5,1.5],'xtick',[],'ytick',[]); axis(position.h1,'equal','tight');
			set([position.h1,position.h2],'visible','off'); 
			set([position.h3,position.h4,position.h4b,position.h5,position.h7,position.h9,position.h9a,position.h10,position.h10a,position.h11,position.h12,position.h13],'visible','off'); 
            conn_menumanager('onregionremove',position.h5,get(position.h1,'position')+[0 0 .015 0]);
		else 
            if strcmp(lower(type),'updatematrix')
                temp=title; %256*(title-min(title(:)))/(max(title(:))-min(title(:)));
                temp(isnan(temp))=0;
                if size(temp,3)>1, set(position.h2,'cdata',temp);
                else set(position.h2,'cdata',(temp-min(temp(:)))/max(eps,max(temp(:))-min(temp(:)))*128); 
                end
                set(position.h1,'xlim',[.5,size(title,2)+.5],'ylim',[.5,size(title,1)+.5+eps],'xtick',[],'ytick',[]);
                set([position.h1,position.h2],'visible','on'); set([position.h3,position.h4,position.h4b,position.h11,position.h12,position.h13],'visible','off');
				axis(position.h1,'normal'); 
            elseif strcmp(lower(type),'updateimage')||isstruct(title)||iscell(title)||size(title,2)>nmax||size(title,3)>1, 
				data=get(position.h2,'userdata');
                volhdr=[];
				if iscell(title), 
					title0=title{2}; titleTHR=title{end}; title=title{1}; 
					if any(titleTHR(:)<0), data.p=1; titleTHR=-titleTHR; else  data.p=0; end
				else  title0=[]; data.p=0; end; % title: structural; title0: activation; titleTHR: p-value (nan for missing data)
                if isstruct(title)&&isfield(title,'vertices')
                    title=shiftdim(title(:),-2);
                    title=title(:,:,[1 1 2 2]);
                elseif isstruct(title), 
                    ok=false;
                    if isfield(title(1),'checkSurface'), 
                        [ok,FS_folder,files]=conn_checkFSfiles(title(1)); end
                    if ok
                        title=[conn_surf_readsurf(files{2}) conn_surf_readsurf(files{5})];
                        title(1).faces=fliplr(title(1).faces);
                        title(2).faces=fliplr(title(2).faces);
                        title=reshape(repmat(title(:)',[2,1]),[1,1,4]);
%                         [xyz,faces]=read_surf(files{2});
%                         %title=accumarray(max(1,min(200, 100+round(xyz(:,2:3)))),abs(xyz(:,1)),[200 200],@max,0);
%                         title=struct('vertices',xyz,'faces',fliplr(faces+1));
%                         [xyz,faces]=read_surf(files{5});
%                         title(1,1,2)=struct('vertices',xyz,'faces',fliplr(faces+1));
%                         title=title(:,:,[1 1 2 2]);
                        %title=cat(3,title,accumarray(max(1,min(200, 100+round(xyz(:,2:3)))),abs(xyz(:,1)),[200 200],@max,0));
%                         xyz=conn_surf_readsurfresampled(files{2});
%                         title=struct('vertices',xyz(CONN_gui.refs.surf.default2reduced,:),'faces',fliplr(CONN_gui.refs.surf.spherereduced.faces));
%                         xyz=conn_surf_readsurfresampled(files{5});
%                         title(1,1,2)=struct('vertices',xyz(CONN_gui.refs.surf.default2reduced,:),'faces',fliplr(CONN_gui.refs.surf.spherereduced.faces));
                    else
                        if length(title)>1, 
                            [temp1,volhdr1]=conn_spm_read_vols(title(1));
                            [temp2,volhdr2]=conn_spm_read_vols(title(end));
                            title=cat(2,permute(temp2,[2,1,3]),permute(temp1,[2,1,3]));
                            volhdr=volhdr2;
                        else
                            [temp,volhdr]=conn_spm_read_vols(title);
                            title=permute(temp,[2,1,3]);
                        end
                    end
					%title=permute(spm_read_vols(title),[2,1,3,4]); 
				end
				if size(title,4)>1, title=cat(2,title(:,:,:,end),title(:,:,:,1)); end
				if isempty(data.n), if numel(title)==4, data.n=1; else data.n=ceil(size(title,3)/2); end; end
				data.n=max(1,min(size(title,3),data.n));
                if isstruct(title), data.x1=title;
                else data.x1=round(1+127*(title-min(title(:)))/max(max(title(:))-min(title(:)),eps));
                end
                %data.x1=round(1+127*max(0,min(1,title)));
				if ~isempty(title0),
					data.x0=title0; %max(-1,min(1,title0)); % x1: structural; x0: activation; xTHR: p-value
					data.xTHR=titleTHR;%max(0,min(1,titleTHR));
					t0=(129:256)'; idxt0=find(~isnan(titleTHR)); 
					if isempty(idxt0), idxt0=[1,1]; %ceil(128*max(eps,max(title0(:))))];
					else  idxt0=ceil(128*max(eps,min(1,.5+.5*max(-1,min(1, [min(title0(idxt0)),max(title0(:))]/data.cscale ))))); end
					t0(1:min(idxt0)-1)=1;t0(max(idxt0)+1:end)=1;%t0(idxt0)=128;%t0(max(1,idxt0-1))=1;t0(min(128,idxt0+1))=1;
					set(position.h8,'cdata',t0);
					set([position.h7,position.h8,position.h9,position.h9a,position.h10,position.h10a],'visible','on');
				else  
					data.x0=[]; 
					set([position.h7,position.h8,position.h9,position.h9a,position.h10,position.h10a],'visible','off');
				end
				if size(data.x1,3)>1, 
					set(position.h5,'min',1,'max',size(data.x1,3),'sliderstep',min(1,[1,10]/(size(data.x1,3)-1)),'value',data.n,'visible','off');
                    conn_menumanager('onregion',position.h5,1,get(position.h1,'position')+[0 0 .015 0]);
				else  set(position.h5,'visible','off'); 
                      conn_menumanager('onregionremove',position.h5);
                end
                if isstruct(title)
                    set(position.h12,'vertices',title(data.n).vertices,'faces',title(data.n).faces);%,'facevertexcdata',max(0,min(1,abs(title(data.n).vertices(:,1))/100))*128,'facecolor','flat','cdatamapping','direct');
                    vnorm=get(position.h12,'VertexNormals');
                    if isempty(vnorm), vnorm=zeros(size(title(data.n).vertices)); end
                    vnorm=conn_bsxfun(@rdivide,vnorm,sqrt(sum(vnorm.^2,2)));
                    title=128*(.1+max(0,min(1,abs(vnorm*[1;0;0]).^2))*.5); 
                    if ~isempty(data.x0),
                        title0=reshape(data.x0,[],2);
                        title0=title0(:,ceil(data.n/2));
                        titleTHR=reshape(data.xTHR,[],2);
                        titleTHR=titleTHR(:,ceil(data.n/2));
                        if data.p, idx=find(titleTHR<=data.thr); else  idx=find(titleTHR>data.thr); end
                        title(idx)=round(192.5+63.5*max(-1,min(1, title0(idx)/data.cscale )));
                    end
                    set(position.h12,'facevertexcdata',conn_ind2rgb(title,get(get(position.h1,'parent'),'colormap')),'facecolor','interp');
                    %set(position.h12,'facevertexcdata',title,'facecolor','interp','cdatamapping','direct'); %Use this line instead of line above if experiencing render-related errors 
                    set(position.h11,'xtick',[],'ytick',[],'ztick',[]);
                    set([position.h11 position.h12 position.h13],'visible','on');
                    set([position.h1 position.h2 position.h3],'visible','off');
                    axis(position.h11,'equal','tight'); 
                    set(position.h11,'cameraPosition',[1000-2000*rem(data.n,2) 0 .1],'cameraupvector',[0 0 1]);
                    %set(position.h13,'position',[1000-2000*rem(data.n,2) 0 .1]);
                else
                    title=fliplr(flipud(data.x1(:,:,data.n)));
                    if ~isempty(data.x0),
                        title0=fliplr(flipud(data.x0(:,:,data.n))); %if all(size(title)==2*size(title0)-1), title0=interp2(title0,'nearest'); end
                        titleTHR=fliplr(flipud(data.xTHR(:,:,data.n))); %if all(size(title)==2*size(titleTHR)-1), titleTHR=interp2(titleTHR,'nearest'); end
                        if data.p, idx=find(titleTHR<=data.thr); else  idx=find(titleTHR>data.thr); end
                        title(idx)=round(192.5+63.5*max(-1,min(1, title0(idx)/data.cscale )));
                    end
                    set(position.h2,'cdata',title);set(position.h1,'xlim',[.5,size(title,2)+.5],'ylim',[.5,size(title,1)+.5+eps],'xtick',[],'ytick',[]);
                    set([position.h1,position.h2],'visible','on'); set([position.h3,position.h4,position.h4b,position.h11,position.h12,position.h13],'visible','off');
                end
				axis(position.h1,'equal','tight'); 

                if ~isempty(string),
                    data.buttondown=struct('matdim',string{1},'z',string{2},'h1',position.h1);
                    set(position.h2,'userdata',data); %,'buttondownfcn',@conn_menubuttondownfcn);
                    set(position.h6a,'userdata',data);
                else 
                    if ~isempty(volhdr), data.buttondown=struct('matdim',volhdr,'z',[],'h1',position.h1); end
                    set(position.h2,'userdata',data);
                    set(position.h6a,'userdata',data);
                end
			else  
				if isstruct(title), title=permute(conn_spm_read_vols(title),[2,1,3,4]); end
                if size(title,2)==1&&size(title,1)<=100,
                    set(position.h4(1),'xdata',(1:size(title,1))','ydata',title,'linestyle','none','marker','o','markerfacecolor','r','markeredgecolor','r','tag','plot');
                    for n1=1:size(title,1),set(position.h4(1+n1),'xdata',n1+[0 0],'ydata',[0 title(n1)],'linestyle',':','marker','none','color',[.5 .5 .5],'tag','none');end
                    for n1=size(title,1)+2:nmax,set(position.h4(n1),'xdata',(1:size(title,1))','ydata',zeros(size(title,1),1),'linestyle',':','marker','none','color',[.5 .5 .5],'tag','none');end
                else
                    colors=get(position.h3,'colorOrder');
                    for n1=1:size(title,2),set(position.h4(n1),'xdata',(1:size(title,1))','ydata',title(:,n1),'linestyle','-','marker','none','color',colors(1+mod(n1,size(colors,1)),:),'tag','plot');end
                    for n1=size(title,2)+1:nmax,set(position.h4(n1),'xdata',(1:size(title,1))','ydata',zeros(size(title,1),1),'linestyle',':','marker','none','color',[.5 .5 .5],'tag','none');end
                end
				minmaxt=[min(0,min(title(:))),max(0,max(title(:)))]; set(position.h3,'xlim',[0,size(title,1)+1],'ylim',minmaxt*[1.1,-.1;-.1,1.1]+[-1e-10,1e-10]); 
				set([position.h3,position.h4],'visible','on'); 
                set([position.h1,position.h2,position.h5,position.h7,position.h9,position.h9a,position.h10,position.h10a,position.h11,position.h12,position.h13],'visible','off'); 
                conn_menumanager('onregionremove',position.h5);
			end
		end
	case {'updateslider1','updateslider2','updatethr','updatecscale'}
        if any(strcmpi(type,{'updatethr','updatecscale'}))
            if nargin<=3, tgcbo=gcbo;
            else tgcbo=string;
            end
            position=get(tgcbo,'userdata');
            title=str2num(get(tgcbo,'string'));
            data=get(position.h2,'userdata');
            if strcmpi(type,'updatethr')
                data.thr=max(0,min(inf,str2num(get(tgcbo,'string'))));
                %set(position.h6,'value',data.thr);
            else
                data.cscale=max(eps,title);
            end
        else
            data=get(position.h2,'userdata');
        end
        if strcmpi(type,'updateslider1')
            data.n=max(1,min(size(data.x1,3), round(title)));
        end
        if strcmpi(type,'updateslider2')
            data.thr=max(0,min(1, title));
        end
        set(position.h10,'string',num2str(data.thr));
        if isstruct(data.x1)
            title=data.x1;
            set(position.h12,'vertices',title(data.n).vertices,'faces',title(data.n).faces);%,'facevertexcdata',max(0,min(1,abs(title(data.n).vertices(:,1))/100))*128,'facecolor','flat','cdatamapping','direct');
            vnorm=get(position.h12,'VertexNormals');
            if isempty(vnorm), vnorm=zeros(size(title(data.n).vertices)); end
            vnorm=conn_bsxfun(@rdivide,vnorm,sqrt(sum(vnorm.^2,2)));
            title=128*(.1+max(0,min(1,abs(vnorm*[1;0;0]).^2))*.5);
            if ~isempty(data.x0),
                title0=reshape(data.x0,[],2);
                title0=title0(:,ceil(data.n/2));
                titleTHR=reshape(data.xTHR,[],2);
                titleTHR=titleTHR(:,ceil(data.n/2));
                if data.p, idx=find(titleTHR<=data.thr); else  idx=find(titleTHR>data.thr); end
                title(idx)=round(192.5+63.5*max(-1,min(1, title0(idx)/data.cscale )));
                t0=(129:256)'; idxt0=find(~isnan(titleTHR));
                if isempty(idxt0), idxt0=[1,1]; %ceil(128*max(eps,max(title0(:))))];
                else  idxt0=ceil(128*max(eps,min(1,.5+.5*max(-1,min(1, [min(title0(idxt0)),max(title0(:))]/data.cscale ))))); end
                t0(1:min(idxt0)-1)=1;t0(max(idxt0)+1:end)=1;%t0(idxt0)=128;%t0(max(1,idxt0-1))=1;t0(min(128,idxt0+1))=1;
                set(position.h8,'cdata',t0);
            end
            set(position.h10,'string',num2str(data.thr));
            set(position.h12,'facevertexcdata',conn_ind2rgb(title,get(get(position.h1,'parent'),'colormap')),'facecolor','interp');
            %set(position.h12,'facevertexcdata',title,'facecolor','interp','cdatamapping','direct'); %Use this line instead of line above if experiencing render-related errors 
            set(position.h11,'xtick',[],'ytick',[],'ztick',[]);
            set([position.h11 position.h12 position.h13],'visible','on');
            set([position.h1 position.h2 position.h3],'visible','off');
            axis(position.h11,'equal','tight');
            set(position.h11,'cameraPosition',[1000-2000*rem(data.n,2) 0 .1],'cameraupvector',[0 0 1]);
            %set(position.h13,'position',[1000-2000*rem(data.n,2) 0 .1]);
        else
            title=fliplr(flipud(data.x1(:,:,data.n)));
            if ~isempty(data.x0),
                title0=fliplr(flipud(data.x0(:,:,data.n))); %if all(size(title)==2*size(title0)-1), title0=interp2(title0,'nearest'); end
                titleTHR=fliplr(flipud(data.xTHR(:,:,data.n))); %if all(size(title)==2*size(titleTHR)-1), titleTHR=interp2(titleTHR,'nearest'); end
                if data.p, idx=find(titleTHR<=data.thr); else  idx=find(titleTHR>data.thr); end
                title(idx)=round(192.5+63.5*max(-1,min(1, title0(idx)/data.cscale )));
                t0=(129:256)'; idxt0=find(~isnan(titleTHR));
                if isempty(idxt0), idxt0=[1,1]; %ceil(128*max(eps,max(title0(:))))];
                else  idxt0=ceil(128*max(eps,min(1,.5+.5*max(-1,min(1, [min(title0(idxt0)),max(title0(:))]/data.cscale ))))); end
                t0(1:min(idxt0)-1)=1;t0(max(idxt0)+1:end)=1;%t0(idxt0)=128;%t0(max(1,idxt0-1))=1;t0(min(128,idxt0+1))=1;
                set(position.h8,'cdata',t0);
            end
            set(position.h10,'string',num2str(data.thr));
            set(position.h2,'cdata',title);
            set(position.h1,'xlim',[.5,size(title,2)+.5],'ylim',[.5,size(title,1)+.5+eps],'xtick',[],'ytick',[]);
            axis(position.h1,'equal','tight');
            set([position.h1,position.h2],'visible','on'); set([position.h3,position.h4,position.h4b],'visible','off');
        end
		set([position.h2 position.h6a position.h6b],'userdata',data);
end
end

function rout=conn_ind2rgb(a,cm)
a = max(1,min(round(a),size(cm,1)));
rout=cm(a,:);
end
  
function [x,matdim]=conn_spm_read_vols(v)
global CONN_gui;
xyz=pinv(v(1).mat)*CONN_gui.refs.canonical.xyz;
v1dim=reshape(v(1).dim(1:3),3,1);
xyz_scale=max(.25, min(1, round(min((max(xyz(1:3,:),[],2)-min(xyz(1:3,:),[],2)+1)./v1dim)*10)/10));
if xyz_scale==.25, disp('warning: Volume too big. Displaying only a portion of the original volume'); end
xyz=xyz/xyz_scale; % scale/center to fit
xyz_center=round(mean(xyz(1:3,:),2)-(v1dim+1)/2);
xyz(1:3,:)=conn_bsxfun(@minus,xyz(1:3,:),xyz_center);
x=double(spm_sample_vol(v,xyz(1,:),xyz(2,:),xyz(3,:),1));
%x=spm_get_data(v,xyz);
x=permute(reshape(x,[numel(v),CONN_gui.refs.canonical.V.dim]),[2,3,4,1]);
matdim=struct('dim',CONN_gui.refs.canonical.V.dim,'mat',v(1).mat*[[eye(3) -xyz_center(:)];[0 0 0 1]]*[[eye(3)/xyz_scale zeros(3,1)];[zeros(1,3) 1]]*pinv(v(1).mat)*CONN_gui.refs.canonical.V.mat);
end

function conn_menubuttonmtnfcn(option,hfig,hax,hplot,htxt,hmark)
global CONN_gui;
pos0=get(hfig,'currentpoint');
pos=get(hax,'currentpoint');
xlim=get(hax,'xlim');
ylim=get(hax,'ylim');
pos=pos(1,1:2);
if pos(1)>=xlim(1)&&pos(1)<=xlim(2)&&pos(2)>=ylim(1)&&pos(2)<=ylim(2),
    switch option
        case 'volume'
            data=get(htxt,'userdata');
            if isfield(data,'buttondown'),
                if ~isempty(data.buttondown.z), z=data.buttondown.z; else z=data.n; end
                if pos(1)>0&&pos(1)<=data.buttondown.matdim.dim(1)&&pos(2)>0&&pos(2)<=data.buttondown.matdim.dim(2)
                    xyz=round(data.buttondown.matdim.mat(1:3,:)*[data.buttondown.matdim.dim(1)+1-pos(1),data.buttondown.matdim.dim(2)+1-pos(1,2),z,1]');
                    v=spm_get_data(CONN_gui.refs.rois.V,pinv(CONN_gui.refs.rois.V.mat)*[xyz;1]);
                    if v>0, txt=CONN_gui.refs.rois.labels{v}; else  txt=''; end
                    %if v>0, txt=[CONN_gui.refs.rois.filenameshort,'.',CONN_gui.refs.rois.labels{v}]; else  txt=''; end
                    str={['x,y,z = (',num2str(xyz(1)),',',num2str(xyz(2)),',',num2str(xyz(3)),') mm']};
                    if ~isempty(txt), str=[{txt} str]; end
                    %set(htxt,'units','pixels','position',[pos0(1:2)+[-2 -2] 6 6],'tooltipstring',conn_cell2html(str));
                    set(htxt,'units','pixels','string',str{end});
                    hext=get(htxt,'extent'); hext=hext(end-1:end)+4;
                    set(htxt,'string',str);
                    hext2=get(htxt,'extent'); hext2=hext2(end-1:end)+4;
                    hang=(pos(1)-xlim(1))/max(eps,xlim(2)-xlim(1));
                    set(htxt,'position',[pos0(1:2)+[-hext(1)*hang 10] max(hext,hext2)]);
                end
            else
                str=sprintf('x,y = (%d,%d)',round(pos(1)),round(pos(2))); 
                %cdata=get(hplot(1),'cdata');
                %pos=round(max(1,min([size(cdata,2),size(cdata,1)], pos)));
                %if any(cdata(pos(2),pos(1),:),3), str=sprintf('f(%d,%d) > 0',pos(1),pos(2)); else str=sprintf('f(%d,%d) = 0',pos(1),pos(2)); end
                set(htxt,'units','pixels','string',str);
                hext=get(htxt,'extent'); hext=hext(end-1:end);
                set(htxt,'position',[pos0(1:2)+[10 10] hext]);
            end
        case 'line'
            xdata=get(hplot(1),'xdata');
            [nill1,idx1]=min(abs(xdata-pos(1)));
            xdata=xdata(idx1);
            if nill1<1
                ydata=[];
                for n1=1:numel(hplot)
                    if strcmp(get(hplot(n1),'visible'),'on')&&strcmp(get(hplot(n1),'tag'),'plot')
                        temp=get(hplot(n1),'ydata');
                        ydata=[ydata temp(idx1)];
                    end
                end
                str=sprintf('f(%s) = %s',mat2str(xdata,6),mat2str(ydata',3));
                set(htxt,'units','pixels','string',str);
                hext=get(htxt,'extent'); hext=hext(end-1:end);
                set(htxt,'position',[pos0(1:2)+[10 10] hext]);
                %hang=(pos(1)-xlim(1))/max(eps,xlim(2)-xlim(1));
                %set(htxt,'position',[pos0(1:2)+[-hext(1)*hang 10] hext]);
                if numel(ydata)>1, set(hmark,'xdata',xdata+zeros(size(ydata)),'ydata',sort(ydata));
                elseif numel(ydata)==1, set(hmark,'xdata',xdata,'ydata',ydata);
                else set(hmark,'xdata',[],'ydata',[]);
                end
            end
    end
    %try, uistack(htxt,'top'); end
    %set(htxt,'position',[pos+.05*[diff(xlim) diff(ylim)] 1],'string',str);
end
end


% function conn_menubuttondownfcn(varargin)
% global CONN_gui;
% if strcmp(get(gcbf,'selectionType'),'normal')
%     data=get(gcbo,'userdata');
%     if isfield(data,'buttondown'), 
%         data=data.buttondown;
%         xyz=get(data.h1,'currentpoint');
%         xyz=round(data.matdim.mat(1:3,:)*[data.matdim.dim(1)+1-xyz(1),data.matdim.dim(2)+1-xyz(1,2),data.z,1]');
%         v=spm_get_data(CONN_gui.refs.rois.V,pinv(CONN_gui.refs.rois.V.mat)*[xyz;1]);
%         if v>0, txt=[CONN_gui.refs.rois.filenameshort,'.',CONN_gui.refs.rois.labels{v}]; else  txt=''; end
%         %if v>0, txt=[CONN_gui.refs.rois.filenameshort,'.',CONN_gui.refs.rois.labels{v}]; else  txt=''; end
%         h=findobj('tag','conn_menubuttondownfcn');if isempty(h), h=figure('units','pixels','position',[get(0,'pointerlocation')-[600,30],450,40]);else  figure(h); end;
%         set(h,'units','pixels','position',[get(0,'pointerlocation')-[150,30],0,0]+get(h,'position')*[0,0,0,0;0,0,0,0;-1,0,1,0;0,0,0,1],'menubar','none','numbertitle','off','color','k','tag','conn_menubuttondownfcn');
%         clf(h);text(0,1,['x,y,z = (',num2str(xyz(1)),',',num2str(xyz(2)),',',num2str(xyz(3)),') mm'],'color','y','fontweight','bold','horizontalalignment','center','fontsize',8+CONN_gui.font_offset);
%         text(0,0,txt,'color','y','fontweight','bold','horizontalalignment','center','fontsize',8+CONN_gui.font_offset,'interpreter','none');set(gca,'units','norm','position',[0,0,1,1],'xlim',[-1,1],'ylim',[-.5,1.5],'visible','off');
%     end
%     %hc=get(0,'children');if length(hc)>0&&hc(1)~=h,hc=[h;hc(hc~=h)];set(0,'children',h); end
% end
% end


