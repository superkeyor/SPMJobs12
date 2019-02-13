% use xjview to open specified stats map one by one
% pValue, clusterSizeThreshold: both specified, or not specified
%                               could be either both single value, or both cell of number of same length as maps
%                               or one single value, the other is cell of number
%                               if not specified, try clustsim result first; otherwise xjview default
% example: 
% ({'img1';'img2'},pdfpath)
% ({'img1';'img2'},0.001,50)
% ({'img1';'img2'},0.001,{50;25})

function varargout = main(maps,pValue,clusterSizeThreshold)
    ez.setdefault({'pValue', NaN
                   'clusterSizeThreshold', NaN});
    % ez.clean();
    % close previous xjview windows
    ez.winclose('xjView');
    
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
        input(sprintf('%d of %d -- Press Enter key to move on.', i, numel(maps)));
    end

    % close again
    ez.winclose('xjView');
end