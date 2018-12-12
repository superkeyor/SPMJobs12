function main()
    % toggle spm and xjview windows on top
    spmWins = findall(0,'type','figure','-regexp','name','^SPM');
    for w = 1:numel(spmWins)
        ez.WinTop(w);
    end

    xjWins = findall(0,'type','figure','-regexp','name','^xjView');
    for w = 1:numel(spmWins)
        ez.WinTop(w);
    end
end