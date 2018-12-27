% launch a particular version of spm and check for updates
% 
% function call: 
%       f, f(), f(12)
%
% you would not be warned that there are at least two spm versions existing in the searchpath 
% because it will automatcially remove the path from previously launched version
% the old spm window, if any, will be closed automatically. when you type spm again, always launch the last called version.
% when no spm path in the searchpath, f, f() launches the latest version; 
% when spm path exists in searchpath, f, f() luanches the last version

function main(v)
    close all;   % close all figures
    
    % prevent warning issue in new version of matlab when spm('quit')
    S = warning('off','MATLAB:lang:cannotClearExecutingFunction');

    % these following toolboxes are harmless to the path, add them when calling/adding spm path
    if isempty(which('mricrondummy'))
        extsPath = ez.joinpath(ez.parentdir(ez.parentdir(ez.csd())), 'extensions');
        thePath = ez.lsd(extsPath,'^mricron');
        thePath = ez.joinpath(extsPath,thePath{1});
        addpath(thePath);
        clear extsPath thePath;
    end

    if isempty(which('xjview'))
        extsPath = ez.joinpath(ez.parentdir(ez.parentdir(ez.csd())), 'extensions');
        thePath = ez.lsd(extsPath,'^xjview');
        thePath = ez.joinpath(extsPath,thePath{1});
        addpath(thePath);
        clear extsPath thePath;
    end

    if nargin < 1
        % no spm ever launched
        if isempty(which('spm'))
            spmsPath = ez.joinpath(ez.parentdir(ez.parentdir(ez.csd())), 'spms');
            vFolderNames = ez.lsd(spmsPath);
            % vFolderNames in the order of: spm12, spm5, spm8
            vLargest = 0;
            for i = 1:length(vFolderNames)
                 vFolderName = vFolderNames{i};
                 vName = regexp(vFolderName,'(\d+)_','tokens');
                 vNumber = ez.num(vName{1}{1});
                 if (vNumber > vLargest), vLargest = vNumber; end
            end
            vFolderName = ez.lsd(spmsPath, ['spm' ez.str(vLargest)]);
            vPath = ez.joinpath(spmsPath, vFolderName{1});
            addpath(vPath);
            spm('fmri');
            commandwindow;                
            ez.pprint('Checking update...');
            try
                spm_update;
            catch
                ez.print('could not check updates at this moment, please try again later.');
            end
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
