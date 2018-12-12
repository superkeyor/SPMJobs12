% use xjview to open specified stats map one by one

function varargout = main(maps)
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
    
    for i = 1:numel(maps)
        map = maps{i};
        xjview(map);
        % close all warning dialog
        warnings = findall(0,'type','figure','name','Warning Dialog');
        close(warnings);

        xjWins = findall(0,'type','figure','-regexp','name','^xjView');
        for j = 1:numel(xjWins)
            w = xjWins(j);
            if strcmp(w.Visible,'on'), ez.WinTop(w); end
        end
        
        input(sprintf('%d of %d -- Press Enter key to move on.', i, numel(maps)));
    end
end