% Usage:
%   put the script in the search path
%   call the function from another script, which is put in the same folder where new files are generated.
%
% Args:
%   a full path to the folder where all .nii files are (folder not recursive)
%   a full path to the folder where all output .nii files will be saved
%   additional parameters
%
% Returns:
%   print out the name of the file being processed
%   save the new (nii) files in the output dir
%   Attention: if the folder has the same file names, they will be overwritten without prompt
%   email notification when done if email provided
%
% Example: 
%   None
%
% Software version tested: spm12-6225, matlab2012b(mac,lion,10.7.5)

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
% December 16 2014, 09:42:13 PM CST

function main()
ez.pprint('****************************************');
fprintf(['Enhanced spm functions which can handel multiple subjects processing.\n\n' ...
        'These are general functions. If one needs to customize a function for a project,\n' ...
        'It is better to first make a copy of the mod_.mat to the project folder itself and then change there.\n\n' ...
        'File name convention in general: job_func.m\n\n'...
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

fprintf('Again, here are all functions and their inputs. Type "help job_func" for individual function help.\n\n');
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
