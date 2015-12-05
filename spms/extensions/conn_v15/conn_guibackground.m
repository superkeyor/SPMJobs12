function data = conn_guibackground(option,varargin)
global CONN_gui CONN_h;
if ~nargin, option='setfile'; end

switch(option)
    case 'clear',
        CONN_gui.background=[];
        
    case {'setfile', 'setfiledefault'}
        if strcmp(option,'setfiledefault'), filename=fullfile(fileparts(which(mfilename)),'conn_guibackground.jpg');
        elseif nargin>1, filename=varargin{1}; 
        else 
            [filename,filepath]=uigetfile({'*.jpg;*.tif;*.tiff;*.gif;*.bmp;*.png','image files';'*','All files'},'Select image file:');
            if isequal(filename,0), return; end
            filename=fullfile(filepath,filename);
        end
        a=imread(filename);
        pos=get(CONN_h.screen.hfig,'position');
%         if size(a,1)*size(a,2)>2e6,
%             n=ceil(sqrt(size(a,1)*size(a,2)/2e6));
%             a=a(1:n:end,1:n:end,:);
%         end
        if max(a(:))>1, a=double(a)/255; end
        if size(a,3)>1,
            answ=questdlg('Color scheme?','','True color','CONN color theme','True color');
            if isequal(answ,'CONN color theme'), 
                a=mean(double(a),3); 
                a=max(0,min(1, conn_bsxfun(@plus,shiftdim(CONN_gui.backgroundcolor,-1),conn_bsxfun(@times,a-.5,min(1,.25*shiftdim(max(.01,CONN_gui.backgroundcolor)/mean(max(.01,CONN_gui.backgroundcolor)),-1))))));
            end
        else
            a=max(0,min(1, conn_bsxfun(@plus,shiftdim(CONN_gui.backgroundcolor,-1),conn_bsxfun(@times,a-.5,min(1,.25*shiftdim(max(.01,CONN_gui.backgroundcolor)/mean(max(.01,CONN_gui.backgroundcolor)),-1))))));
        end
        k=pos(3:4)/max(pos(3)/size(a,2),pos(4)/size(a,1));
        CONN_gui.background=uint8(255*a(round(linspace(1,k(2),pos(4))),round(linspace(1,k(1),pos(3))),:));
        
    case 'cleartrans',
        CONN_gui.background={};
        
    case 'settrans',
        hfig=CONN_h.screen.hfig;
        pos=get(hfig,'position');
        p3=get(0,'screensize');
        %pos(1:2)=pos(1:2)+p3(1:2)-1; % note: fix issue when connecting to external monitor/projector
        pos(2)=p3(4)-pos(2)-pos(4);
        if 1,%~iscell(data)||numel(data)<2||~isequal(data{2},pos)
            rect = java.awt.Rectangle(pos(1), pos(2), pos(3), pos(4));
            robot = java.awt.Robot;
            set(hfig,'visible','off'); drawnow; pause(.5);
            jImage = robot.createScreenCapture(rect);
            set(hfig,'visible','on');
            h = jImage.getHeight;
            w = jImage.getWidth;
            pixelsData = reshape(typecast(jImage.getData.getDataStorage, 'uint8'), 4, w, h);
            img = cat(3, reshape(pixelsData(3, :, :), w, h)', reshape(pixelsData(2, :, :), w, h)', reshape(pixelsData(1, :, :), w, h)');
            img = max(0,min(1, bsxfun(@plus,0*shiftdim(CONN_gui.backgroundcolor,-1),1*double(img)/255)));
            %img = max(0,min(1, bsxfun(@plus,.75*shiftdim(CONN_gui.backgroundcolor,-1),.25*double(img)/255)));
            answ=questdlg('Color scheme?','','True color','CONN color theme','True color');
            if isequal(answ,'CONN color theme'),
                img=mean(double(img),3);
                img=max(0,min(1, conn_bsxfun(@plus,shiftdim(CONN_gui.backgroundcolor,-1),conn_bsxfun(@times,img-mean(img(:)),min(1,.25*shiftdim(max(.01,CONN_gui.backgroundcolor)/mean(max(.01,CONN_gui.backgroundcolor)),-1))))));
            end
            CONN_gui.background=uint8(255*img);
        end
        %CONN_gui.background{2}=pos;
        
    case 'get',
        tpos=varargin{1};
        pos=get(CONN_h.screen.hfig,'position');
        tpos=tpos.*repmat([size(CONN_gui.background,2),size(CONN_gui.background,1)]./pos(3:4),1,2);
        %p3=get(0,'screensize');
        %tpos(1:2)=tpos(1:2)+p3(1:2)-1; % note: fix issue when connecting to external monitor/projector
        tsiz=varargin{2};
        data=shiftdim(CONN_gui.backgroundcolor,-1);
        try
            data=double(CONN_gui.background(...
                max(1,min(size(CONN_gui.background,1), round(linspace(size(CONN_gui.background,1)-tpos(2)-tpos(4)+2,size(CONN_gui.background,1)-tpos(2),tsiz(1))) )),...
                max(1,min(size(CONN_gui.background,2), round(linspace(tpos(1),tpos(1)+tpos(3)-1,tsiz(2))))), ...
                :))/255;
        end
end
