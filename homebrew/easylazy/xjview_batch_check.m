% use xjview to open specified stats map one by one

function varargout = main(maps)
    % ez.clean();
    % close previous xjview windows
    ez.winclose('xjView');
    
    for i = 1:numel(maps)
        map = maps{i};
        xjview(map);
        % close all warning dialog
        warnings = findall(0,'type','figure','name','Warning Dialog');
        close(warnings);

        xjWins = findall(0,'type','figure','-regexp','name','^xjView');
        for j = 1:numel(xjWins)
            w = xjWins(j);
            if strcmp(w.Visible,'on'), ez.wintop(w); end
        end
        
        [pth,name, ext]=ez.splitpath(ez.abspath(map));
        [dummy,folder]=ez.splitpath(pth);
        ez.pprint(folder,'Magenta');
        ez.pprint([name ext],'Cyan');
        clustsim(pth,1);
        input(sprintf('%d of %d -- Press Enter key to move on.', i, numel(maps)));
    end

    % close again
    ez.winclose('xjView');
end