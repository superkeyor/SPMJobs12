function varargout = main(varargin)
    % load job into Batch GUI
    matlabbatch = evalin('base', 'matlabbatch');
    spm_jobman('interactive',matlabbatch);
end