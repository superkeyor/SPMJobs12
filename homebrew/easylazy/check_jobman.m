function varargout = main(job)
    % load job into Batch GUI
    % job: 
    % 1) (), search base workspace 'matlabbatch' (spm8/12) > 'jobs' (spm5)
    % 2) ()  when search fails, pop up Batch Editor
    % 3) ('jobs') ('matlabbatch') to explicitly search base workspace
    % 4) ('path/to/job.mat') 

    if nargin<1
        try
            j = evalin('base', 'matlabbatch');
        catch
            try
                j = evalin('base', 'jobs');
            catch
                spm_jobman;
                return;
            end
        end
    else
        if strcmp(job,'matlabbatch'), j = evalin('base', 'matlabbatch'); end
        if strcmp(job,'jobs'), j = evalin('base', 'jobs'); end
        if strfind(job,'.mat')
            load(job);
            try
                j = eval('matlabbatch');
            catch
                j = eval('jobs');
            end
        end
    end
    spm_jobman('interactive',j);
end