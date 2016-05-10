function [ok,files]=conn_checkdistributionfiles(filename)
if isdeployed, ok=true; files={}; return; end
if ~nargin||isempty(filename), 
    conn_checkdistributionfiles spm;
    conn_checkdistributionfiles conn;
    return
end
thispath=fileparts(which(filename));
names=dir(fullfile(thispath,'*.m'));
files={names.name};
okpath=cellfun(@(x)strcmpi(fileparts(which(x)),thispath)|strncmp(x,'.',1),files);
if ~nargout
    for n=find(~okpath(:)')
        foldername=fileparts(which(files{n}));
        if isempty(foldername), fprintf('Warning: %s overloaded by version in current folder (%s)\n',files{n},pwd);
        else fprintf('Warning: %s overloaded by version in folder %s\n',files{n},foldername);
        end
    end
end
files=files(~okpath);
ok=all(okpath);
