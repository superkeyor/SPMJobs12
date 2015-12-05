function dirs(pathname,dirfilter,filefilter,dircallback,filecallback);
% DIRS recursive directory search
%
% dirs(PATHNAME,DIRFILTER,FILEFILTER,DIRCALLBACK,FILECALLBACK);
% Recursive search through directories starting from the directory PATHNAME
% Uses file filter DIRFILTER to initially filter files (e.g. '*.txt')
% and the filter FILEFILTER to determine a possible file match (e.g. inline('x(2)==''a'''); )
% For each match file DIRS will invoque the function FILECALLBACK(filename)
% and for each folder where at least one match file is found DIRS will invoque 
% the function DIRCALLBACK(pathname)
%
% e.g. dirs('.','*.m',inline('x(2)==''a'''),@disp,@disp);
%


filterrest=dirfilter;
[filternow,filterrest]=strtok(filterrest,';');
ok=0;
while ~isempty(filternow),
    filename=fullfile(pathname,fliplr(deblank(fliplr(deblank(filternow)))));
    dir0=dir(filename);
    [names,idx]=sortrows(strvcat(dir0(:).name));
    for n1=1:length(dir0), 
		if ~dir0(idx(n1)).isdir && filefilter(dir0(idx(n1)).name),
			ok=1;
			if ~isempty(filecallback), feval(filecallback,fullfile(pathname,dir0(idx(n1)).name)); 
			else, break; end
		end;
	end
	if ok&&isempty(filecallback), break; end
	[filternow,filterrest]=strtok(filterrest,';');
end
if ok&&~isempty(dircallback), feval(dircallback,pathname); end
dir0=dir(pathname);
[names,idx]=sortrows(strvcat(dir0(:).name));
for n1=1:length(dir0),
    if dir0(idx(n1)).isdir && ~strcmp(dir0(idx(n1)).name,'.') && ~strcmp(dir0(idx(n1)).name,'..'),
        dirs(fullfile(pathname,dir0(idx(n1)).name),dirfilter,filefilter,dircallback,filecallback);
    end
end


