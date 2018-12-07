function varargout = main(job)
    % run job without GUI
    % (job), matlabbatch variable, or 'path/to/job.mat'
    % essentially, spm_jobman('run',job);
    spm_jobman('run',job);
end