% launch a particular version of spm and check for updates
% 
% you might be warned that there are at least two spm versions existing in the searchpath (note: December 08 2014, 07:34:33 PM CST, fixed this issue, will automatcially remove the path from previously launched version)
% the old spm window, if any, will be closed automatically. when you type spm again, always launch the last called version.
% function call: f, f(), f(12)[if there are several v12s, launch the latest one]
% exact version: f('12.6225'), f('12_6225'), f('spm12_6225')
% note: when no spm path in the searchpath, f, f() launches the latest version; 
%       when spm path exists in searchpath, f, f() luanches the last version

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
            addpath(genpath(extsPath));
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
            addpath(genpath(extsPath));
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