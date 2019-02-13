% call xjview to show an activation map (eg, spmT, spmF map) or maps, append the map to a pdf file
% pdfpath: file path to pdf. if exisit, would append with bookmark; otherwise new pdf file
% (maps,pdfpath)

function varargout = main(maps,pdfpath,pValue,clusterSizeThreshold)
    ez.setdefault({'pValue', 0.001
                   'clusterSizeThreshold', 5});
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
    for i = 1:numel(maps)
        map = maps{i};
        xjview(map,pValue,clusterSizeThreshold);
        warningdlgs = findall(0,'type','figure','name','Warning Dialog');
        close(warningdlgs);
        errordlgs = findall(0,'type','figure','name','error');
        close(warningdlgs);
        ez.export(pdfpath,'nocrop','bookmark','append');
        close all;
    end
end