% print out all easy lazy function names and their help info
function main()
    files = ez.ls(ez.csd,'\.m$');
    for n = 1:ez.len(files)
        file = files{n}; % linear indexing, using only one subscript
        [filePath,fileName,fileExt] = ez.splitpath(file); % fileExt is .set
        if strcmp(fileName,mfilename), continue; end
        ez.print(fileName);
        help(fileName);
        ez.pprint('****************************************');
    end
    ez.print('Again: ');
    for n = 1:ez.len(files)
        file = files{n}; % linear indexing, using only one subscript
        [filePath,fileName,fileExt] = ez.splitpath(file); % fileExt is .set
        if strcmp(fileName,mfilename), continue; end
        ez.print(fileName);
    end
    ez.pprint('****************************************');
end