function varargout = main(j)
    % load job into Batch GUI
    % j default 'matlabbatch', in case spm 5 ('jobs')
    % spm 8/12 use matlabbatch, spm 5 uses jobs

    if nargin<1, j = 'matlabbatch'; end
    matlabbatch = evalin('base', j);
    spm_jobman('interactive',matlabbatch);
end