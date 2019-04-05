% call xjview to show an activation map (eg, spmT, spmF map) or maps, save threshold as img/hdr in the same folder like "thresholded_spmT_0001_p_k.img"
% if img exisit, replace
% pValue, clusterSizeThreshold: both specified, or not specified
%                               could be either both single value, or both cell of number of same length as maps
%                               or one single value, the other is cell of number
%                               if not specified, try clustsim result first; otherwise xjview default
% example: 
% ({'img1';'img2'})
% ({'img1';'img2'},0.001,50)
% ({'img1';'img2'},0.001,{50;25})
% (maps,pValue,clusterSizeThreshold)

function varargout = main(maps,pValue,clusterSizeThreshold)
    ez.setdefault({'pValue', NaN
                   'clusterSizeThreshold', NaN});
    % ez.clean();
    % close previous xjview windows
    figs = sort(findobj(0,'type','figure'));
    for iii = 1:ez.len(figs);
        fig = figs(iii);
        if strfind(fig.Name,'xjView')
            ez.print(['closing previous ' fig.Name ' ...']);
            close(fig); 
        end
    end
    
    if ~iscell(maps), maps = {maps}; end        
    if ~iscell(pValue), pValue = repmat({pValue}, size(maps,1), 1); end
    if ~iscell(clusterSizeThreshold), clusterSizeThreshold = repmat({clusterSizeThreshold}, size(maps,1), 1); end
    for i = 1:numel(maps)
        map = maps{i};
        if isnan(pValue{i})
            xjview(map);
        else
            xjview(map,pValue{i},clusterSizeThreshold{i});
        end
        warningdlgs = findall(0,'type','figure','name','Warning Dialog');
        close(warningdlgs);
        errordlgs = findall(0,'type','figure','name','error');
        close(errordlgs);

        fig = guidata(gcf); 
        % from xjview: CallBack_saveImagePush(hObject, eventdata, thisfilename, isMask)
        % in case 'filename.nii,1' --> 'filename.nii'
        imageFileName = fig.imageFileName{1}; imageFileName = regexprep(imageFileName,',\d+','');
        p = sprintf('%f',fig.pValue); k = num2str(fig.clusterSizeThreshold);
        [pth,name,ext] = ez.splitpath(imageFileName);
        name = [name,'_',p,'_',k];
        imgpath = ez.jp(pth,['thresholded_',name,ext]);
        fig.saveImagePush.Callback(gcf,'',imgpath,0)
        close all;
    end
end