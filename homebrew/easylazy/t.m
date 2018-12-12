function main()
    % toggle spm and xjview windows on top
    spmWins = findall(0,'type','figure','-regexp','name','^SPM');
    for i = 1:numel(spmWins)
        w = spmWins(i);
        if strcmp(w.Visible,'on'), ez.WinTop(w); end
    end

    xjWins = findall(0,'type','figure','-regexp','name','^xjView');
    for j = 1:numel(xjWins)
        w = xjWins(j);
        if strcmp(w.Visible,'on'), ez.WinTop(w); end
    end
end