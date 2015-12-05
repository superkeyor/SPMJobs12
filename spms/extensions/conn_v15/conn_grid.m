% 
% Using CONN in a computer cluster environment
% 
% CONN grid computing options allow you to process your subjects in parallel, with each subject, 
% or each of several smaller groups of subjects, being processed independently by a different 
% computer node. This can significantly increase the speed of your analyses, allowing you to 
% process hundreds of subjects in the time it would take to process just one or a few subjects.
% 
% To use this functionality, each node in your cluster needs to be in a distributed environment 
% with access to:
% 
% * Matlab (or a pre-compiled version of CONN)
% * The installation folders for SPM and CONN
% * The data folders containing your conn project and data.
% 
% CONN supports natively the following cluster computing job schedulers:
% 
% * Grid Engine (Sun/Oracle Grid Engine, Open Grid Scheduler, or compatible system)
% * PBS/Torque (Portable Batch System, or compatible)
% * LFS (Platform Load Sharing Facility, or compatible)
% 
% note: CONN will work out-of-the-box for many cluster configurations simply by selecting the appropriate
% job scheduler. In addition, profiles for other schedulers, or system-specific settings (e.g to increase
% your system default walltime settings, enter optional project or account ids, etc.), can be easily 
% created/edited in CONN Tools.GridSettings if necessary.
% 
% To get started simply run CONN interactively in your computer cluster and select Tools.GridSettings, 
% where you can select and test your system job scheduler. If in doubt, contact your system administrator 
% to learn about your institution cluster computing options.
% 
% After succesfully testing your cluster configuration, you can simply select the corresponding 
% parallelization option when running your analyses either through the GUI or using batch scripts
% and CONN will automatically:
% 
%    a) submit one or multiple jobs to your cluster
%    b) allow you to easily track their progress and resubmit any failed jobs if necessary
%    c) merge the results back into your conn project when they are ready
% 