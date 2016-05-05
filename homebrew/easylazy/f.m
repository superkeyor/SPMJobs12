% launch a particular version of spm and check for updates
% 
% you might be warned that there are at least two spm versions existing in the searchpath (note: December 08 2014, 07:34:33 PM CST, fixed this issue, will automatcially remove the path from previously launched version)
% the old spm window, if any, will be closed automatically. when you type spm again, always launch the last called version.
% function call: f, f(), f(12)[if there are several v12s, launch the latest one]
% exact version: f('12.6225'), f('12_6225'), f('spm12_6225')
% note: when no spm path in the searchpath, f, f() launches the latest version; 
%       when spm path exists in searchpath, f, f() luanches the last version

% programming note: with new spm folder added, may need to change vFolderName = vFolderNames{end-N}

function main(v)
    close all;   % close all figures
    
    if nargin < 1
        % no spm ever launched
        if isempty(which('spm'))
            % f(13); % recursive call
            spmsPath = ez.joinpath(ez.parentdir(ez.parentdir(ez.csd())), 'spms');
            vFolderNames = ez.lsd(spmsPath);
            vFolderName = vFolderNames{end-2}; % vFolderNames: spm12, spm5, spm8
            vPath = ez.joinpath(spmsPath, vFolderName);
            addpath(vPath);
            spm('fmri');
            commandwindow;                
            ez.pprint('Checking update...');
            try
                spm_update;
            catch
                ez.print('could not check updates at this moment, please try again later.');
            end

            % add extensions to path
            extsPath = ez.joinpath(spmsPath, 'extensions');
            % avoid weird functions from marsbar/spm folders, wfu
            addpath(genpath_exclude(extsPath,{'^spm2$','^spm5$','^spm99$', '^spm_lite$'}));
        % otherwise, simply launch the last called version
        else
            spm('fmri');  % same version, no need to clear base workspace
            return
        end
    else
        spmsPath = ez.joinpath(ez.parentdir(ez.parentdir(ez.csd())), 'spms');
        v = strrep(ez.str(v),'.', '_');
        vFolderNames = ez.lsd(spmsPath, sprintf('spm%s',ez.str(v)));
        if isempty(vFolderNames), error(['Specified spm version not found. Install it to ', spmsPath]); end
        vFolderName = vFolderNames{end};
        vPath = ez.joinpath(spmsPath, vFolderName);
        % no spm ever launched
        if isempty(which('spm'))
            addpath(vPath);
            spm('fmri');
            commandwindow;                
            ez.pprint('Checking update...');
            try
                spm_update;
            catch
                ez.print('could not check updates at this moment, please try again later.');
            end

            % add extensions to path
            extsPath = ez.joinpath(spmsPath, 'extensions');
            addpath(genpath_exclude(extsPath,{'^spm2$','^spm5$','^spm99$', '^spm_lite$'}));
        else
            % previous launched spm path
            preVPath = fileparts(which('spm'));
            % same version
            if strcmp(vPath, preVPath)
                spm('fmri');
            else
                % spm('Quit'); % not the same version, call spm quit 
                % not the same version, clean everything otherwise report error
                evalin('base','ez.clean'); evalin('base','clear classes');
                ez.pprint('Switching to a different version...');
                % warning if to-be-removed path does not exist
                warning('off','MATLAB:rmpath:DirNotFound');
                rmpath(genpath(preVPath));
                warning('on','MATLAB:rmpath:DirNotFound');
                addpath(vPath);
                spm('fmri');
                commandwindow;                
                ez.pprint('Checking update...');
                try
                    spm_update;
                catch
                    ez.print('could not check updates at this moment, please try again later.');
                end
            end
        end
    end
end % end fucntion

function p = genpath_exclude(d,excludeDirs)
% http://www.mathworks.com/matlabcentral/fileexchange/22209-genpath-exclude
% pathStr = genpath_exclude(basePath,ignoreDirs)
%
% Extension of Matlab's "genpath" function, except this will exclude
% directories (and their sub-tree) given by "ignoreDirs". 
%
% Example usage:
% genpath_exclude('C:\myDir',{'CVS'}) %<--- simple usage to ignore CVS direcotries
% genpath_exclude('C:\myDir',{'\.svn'}) %<--- simple usage to ignore .svn (note that "." must be escaped for proper handling in the regexp)
% genpath_exclude('C:\myDir',{'CVS','#.*'}) %<----more advanced usage to ignore CVS directories and any directory starting with "#"
%
% Inputs:
%    basePath: string.  The base path for which to generate path string.
%
%    excludeDirs: cell-array of strings. all directory names to ignore. Note,
%                 these strings are passed into regexp surrounded by
%                 '^'   and '$'.  If your directory name contains special
%                 characters to regexp, they must be escaped.  For example,
%                 use '\.svn' to ignore ".svn" directories.  You may also
%                 use regular expressions to ignore certian patterns. For
%                 example, use '*._ert_rtw' to ignore all directories ending
%                 with "_ert_rtw".
%
% Outputs:
%    pathStr: string. semicolon delimited string of paths. (see genpath)
% 
% See also genpath
%
% ---CVS Keywords----
% $Author: jhopkin $
% $Date: 2009/10/27 19:06:19 $
% $Name:  $
% $Revision: 1.5 $

% $Log: genpath_exclude.m,v $
% Revision 1.5  2009/10/27 19:06:19  jhopkin
% fixed regexp handling.  added more help comments
%
% Revision 1.4  2008/11/25 19:04:29  jhopkin
% minor cleanup.  Made input more robust so that if user enters a string as 'excudeDir' rather than a cell array of strings this function will still work.  (did this by moving the '^' and '$' to surround the entire regexp string, rather than wrapping them around each "excludeDir")
%
% Revision 1.3  2008/11/25 18:43:10  jhopkin
% added help comments
%
% Revision 1.1  2008/11/22 00:23:01  jhopkin
% *** empty log message ***
%
    % if the input is a string, then use it as the searchstr
    if ischar(excludeDirs)
        excludeStr = excludeDirs;
    else
        excludeStr = '';
        if ~iscellstr(excludeDirs)
            error('excludeDirs input must be a cell-array of strings');
        end
        
        for i = 1:length(excludeDirs)
            excludeStr = [excludeStr '|^' excludeDirs{i} '$'];
        end
    end

    
    % Generate path based on given root directory
    files = dir(d);
    if isempty(files)
      return
    end

    % Add d to the path even if it is empty.
    p = [d pathsep];

    % set logical vector for subdirectory entries in d
    isdir = logical(cat(1,files.isdir));
    %
    % Recursively descend through directories which are neither
    % private nor "class" directories.
    %
    dirs = files(isdir); % select only directory entries from the current listing

    for i=1:length(dirs)
        dirname = dirs(i).name;
        %NOTE: regexp ignores '.', '..', '@.*', and 'private' directories by default. 
        % if ~any(regexp(dirname,['^\.$|^\.\.$|^\@.*|^private$|' excludeStr ],'start'))
        if ~any(regexp(dirname,['^\.$|^\.\.$|^\@.*|^\+.*|^private$|' excludeStr ],'start')) 
          p = [p genpath_exclude(fullfile(d,dirname),excludeStr)]; % recursive calling of this function.
        end
    end
end % end function