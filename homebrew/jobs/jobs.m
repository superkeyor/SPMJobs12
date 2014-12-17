% Usage:
%   put the script in the search path
%   call the function from another script, which is put in the same folder where new files are generated.
%
% Args:
%   a full path to the folder where all .set files are (folder not recursive)
%   a full path to the folder where all output .set files will be saved
%   additional info (e.g. full path to a csv file, [2 5], 5.5, {4,3,70})
%
% Returns:
%   print out the name of the file being processed
%   save the new (.set) files in the output dir
%   Attention: if the folder has the same file names, they will be overwritten without prompt
%   As long as a new EEG file is generated, the function automatically generates an new EEG report and keep the old report
%   email notification when done if email provided
%
% Example: 
%   None
%
% Special Note:
%   This script does not care about ALLEEG. 
%   Script commands are not saved in EEG.history internally by EEGLAB (otherwise could be saved if done with GUI)
%
% Software version tested: eeglab12_0_2_5b, eeglab13_3_2b(recommended), matlab2012b(mac,lion,10.7.5), matlab2014a(win7)
% Other m-files required: ez.m
% Subfunctions: none
% MAT-files required: none
%
% See also: None
%
% Author: Jerry Zhu
% SIUC
% email: jerryzhujian9@gmail.com
% Website: http://zhupsy.com
% June 2014; Last revision: June 18 2014, 06:37:07 PM CDT

function main()
ez.pprint('****************************************');
fprintf(['Enhanced eeglab functions which can handel batch processing.\n\n' ...
        'These are general functions. If one needs to customize a function for a project,\n' ...
        'It is better to first make a copy to the project folder itself and then change there.\n\n' ...
        'File name convention in general: bat_eeglabfunc.m\n\n'...
        'Here are all functions and their inputs.\n\n']);
scripts = ez.ls(ez.csd(),'\.m$');
for n = 1:ez.len(scripts)
    script = scripts{n};
    [filePath,fileName,fileExt] = ez.splitpath(script);
    try
        inputNames = GetArgNames(script);
        fprintf('%-20s:\t(', fileName); 
        if ~isempty(inputNames), fprintf('%s,', inputNames{1}{:}); else, fprintf(','); end
        fprintf('\b);\n');
    end
end % end for

fprintf('\nHere are some general function help information.\n\n');
% the same effect
% help(ez.csf());
help(mfilename);

fprintf('Again, here are all functions and their inputs. Type "help bat_eeglabfunc" for individual function help.\n\n');
for n = 1:ez.len(scripts)
    script = scripts{n};
    [filePath,fileName,fileExt] = ez.splitpath(script);
    try
        inputNames = GetArgNames(script);
        fprintf('%s(', fileName); 
        if ~isempty(inputNames), fprintf('%s,', inputNames{1}{:}); else, fprintf(','); end
        fprintf('\b);\n');
    end
end % end for
ez.pprint('****************************************');
end % end function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [inputNames, outputNames] = GetArgNames(filePath)
% http://stackoverflow.com/questions/10431577/how-do-i-retrieve-the-names-of-function-parameters-in-matlab
% if you give it a path to the function file, it will return two cell arrays containing your input and output parameter strings 
% (or empty cell arrays if there are none). 
% Note that functions with variable input or output lists will simply list 'varargin' or 'varargout', respectively, for the variable names.
    % Open the file:
    fid = fopen(filePath);

    % Skip leading comments and empty lines:
    defLine = '';
    while all(isspace(defLine))
        defLine = strip_comments(fgets(fid));
    end

    % Collect all lines if the definition is on multiple lines:
    index = strfind(defLine, '...');
    while ~isempty(index)
        defLine = [defLine(1:index-1) strip_comments(fgets(fid))];
        index = strfind(defLine, '...');
    end

    % Close the file:
    fclose(fid);

    % Create the regular expression to match:
    matchStr = '\s*function\s+';
    if any(defLine == '=')
        matchStr = strcat(matchStr, '\[?(?<outArgs>[\w, ]*)\]?\s*=\s*');
    end
    matchStr = strcat(matchStr, '\w+\s*\(?(?<inArgs>[\w, ]*)\)?');

    % Parse the definition line (case insensitive):
    argStruct = regexpi(defLine, matchStr, 'names');

    % Format the input argument names:
    if isfield(argStruct, 'inArgs') && ~isempty(argStruct.inArgs)
        inputNames = strtrim(textscan(argStruct.inArgs, '%s', ...
                                      'Delimiter', ','));
    else
        inputNames = {};
    end

    % Format the output argument names:
    if isfield(argStruct, 'outArgs') && ~isempty(argStruct.outArgs)
        outputNames = strtrim(textscan(argStruct.outArgs, '%s', ...
                                       'Delimiter', ','));
    else
        outputNames = {};
    end

% Nested functions:

    function str = strip_comments(str)
        if strcmp(strtrim(str), '%{')
            strip_comment_block;
            str = strip_comments(fgets(fid));
        else
            str = strtok([' ' str], '%');
        end
    end

    function strip_comment_block
        str = strtrim(fgets(fid));
        while ~strcmp(str, '%}')
            if strcmp(str, '%{')
                strip_comment_block;
            end
            str = strtrim(fgets(fid));
        end
    end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
