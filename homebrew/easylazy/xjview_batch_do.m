% call xjview to show an activation map (eg, spmT, spmF map) or maps, append the map to a pdf file
% pdfpath: file path to pdf. if exisit, would append with bookmark; otherwise new pdf file
% pValue, clusterSizeThreshold: both specified, or not specified
%                               could be either both single value, or both cell of number of same length as maps
%                               or one single value, the other is cell of number
%                               if not specified, try clustsim result first; otherwise xjview default
% example: 
% ({'img1';'img2'},pdfpath)
% ({'img1';'img2'},pdfpath,0.001,50)
% ({'img1';'img2'},pdfpath,0.001,{50;25})
% (maps,pdfpath,pValue,clusterSizeThreshold)

function varargout = main(maps,pdfpath,pValue,clusterSizeThreshold)
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
    if size(pValue,1)==1, pValue = repmat(pValue, size(maps,1), 1); end
    if size(clusterSizeThreshold,1)==1, clusterSizeThreshold = repmat(clusterSizeThreshold, size(maps,1), 1); end
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
        close(warningdlgs);
        ez.export(pdfpath,'nocrop','bookmark','append');
        close all;
    end
end