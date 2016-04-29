function h = conn_msgbox(txt,title,ok)

if nargin<2, title=''; end
if nargin<3, ok=false; end
h=figure('units','norm','position',[.5 .7 .2 .2],'color','w','menubar','none','numbertitle','off','name',title,'resize','off','units','pixels');
if ok
    ha=uicontrol('style','text','units','norm','position',[0 .25 1 1],'backgroundcolor','w','horizontalalignment','center','string',txt,'units','pixels');
    hb=uicontrol('style','pushbutton','units','norm','position',[.25 .05 .5 .2],'string','Continue','callback','close(gcbf)');
    hext=get(ha,'extent');
    hext2=max([150 60],hext(end-1:end)+[60 90]);
    hpos=get(h,'position');
    set(h,'position',[hpos(1)-hext2(1)/2,hpos(2)-hext2(2)/2,hext2(1),hext2(2)]);
    set(ha,'position',[30 60 hext(end-1:end)]);
    uiwait(h); 
else
    ha=uicontrol('style','text','units','norm','position',[0 0 1 1],'backgroundcolor','w','horizontalalignment','center','string',txt,'units','pixels');
    hext=get(ha,'extent');
    hext2=hext(end-1:end)+[60 60];
    hpos=get(h,'position');
    set(h,'position',[hpos(1)-hext2(1)/2,hpos(2)-hext2(2)/2,hext2(1),hext2(2)]);
    set(ha,'position',[30 30 hext(end-1:end)]);
    drawnow;
end

