function batchnew = conn_batch_pct(batch,N,PCTtype,varargin) 
% This script has been deprecated
% Please use batch.parallel options instead (see help conn_batch)
%

% CONN_BATCH_PCT runs batch using Parallel Computing resources
% see CONN_BATCH for details on constructing CONN batch structures/commands 
%
% 1) to run a batch job using Matlab PCT (note: requires Matlab's parallel computing toolbox installed and configured on target machine)
%
% conn_batch_pct(batch,N,'PCT')
%    breaks batch project in N subprojects (subsets of subjects)
%    and runs in parallel using Matlab Parallel Computing Toolbox.
%    note: use Matlab's parpool to define the parallel computing resources 
%    available in your computer before running this function (help parpool)
%
% 2) to run a batch job using SGE or similar command-line syntax (note: requires Grid Engine or similar job scheduler on target machine, and Matlab available on individual nodes)
%
% conn_batch_pct(batch,N,'SGE')
%    breaks batch project in N subprojects (subsets of subjects)
%    and runs in parallel using Sun Grid Engine (SGE) queuing system 
%
% conn_batch_pct(batch,N,'SGE',cmd_submit,cmd_submitdelayed)
%    uses alternative system commands for submition of individual jobs
%    and delayed final job. By default these strings are:
%     cmd_submit =        'qsub -N conn_nJOBNUMBER JOBOTHEROPTIONS JOBCOMMAND';                  % command for submitting individual job to the queue  
%     cmd_submitdelayed = 'qsub -N conn_merge -hold_jid "conn_n*" JOBOTHEROPTIONS JOBCOMMAND';   % command for submitting a "delayed" job to the queue (after the above jobs have finished) 
%         % note: use the string "JOBNUMBER" as a placeholder for a number identifying each individual job 
%                 use the string "JOBCOMMAND" as a placeholder for the job command to be submitted 
%                 use the string "JOBOTHEROPTIONS" as a placeholder for any additional arguments to qsub: syntax: conn_batch_pct(batch,N,'SGE',cmd_submit,cmd_submitdelayed, str_otheroptions) 
%
% 3) to prepare a batch job for other arbitrary parallel computing resources
%
% conn_batch_pct(batch,N,'scripts')
%    breaks batch project in N subprojects (subsets of subjects)
%    and creates N+1 individual scripts for batch job submission to
%    arbitrary queuing system. The first N scripts can be submitted
%    in parallel (they are independent processes), and the final script
%    must be submitted after the first N jobs have finished (it merges
%    the individual nodes projects into a single project)
%
% conn_batch_pct(projectfilename,N,'merge')
%    merges N subprojects into a single project
%
% additional options:
%    conn_batch_pct(... ,'nosoftlink')
%          When merging, by default the final project folder will contain symbolic links to the connectivity datafiles (stored in the individual nodes 
%          folders). This is meant to avoid redundancy and speed up the merging procedure. If you want to change this behavior and have the final 
%          project folder contain copies of the connectivity datafiles use the above syntax instead
%    conn_batch_pct(... ,'nocopyfiles')
%          When merging, by default the final project folder will contain symbolic links to the connectivity datafiles (stored in the individual nodes 
%          folders) or a copy of those same files (stored in the final project folder). If you want to change this behavior and leave the merged 
%          copy without any connectivity datafiles use the above syntax instead
%    conn_batch_pct(... ,'nomergeinfo')
%          When merging, by default the final project definitions will be derived from the individual-node projects. If you want to change this behavior 
%          and leave an already existing target project unchanged (e.g. only copy files but do not change project definitions) use the above syntax instead
%    
%


global CONN_x;

if nargin<3||isempty(PCTtype), PCTtype='PCT'; end
if nargin>3, options=varargin; else options={}; end
rmoptions={};
if any(strcmp(options,'nosoftlink')), softlink=false; rmoptions{end+1}=',''nosoftlink'''; options=options(~strcmp(options,'nosoftlink')); else softlink=true; end
if any(strcmp(options,'nocopyfiles')), copyfiles=false; rmoptions{end+1}=',''nocopyfiles'''; options=options(~strcmp(options,'nocopyfiles')); else copyfiles=true; end
if any(strcmp(options,'nomergeinfo')), mergeinfo=false; rmoptions{end+1}=',''nomergeinfo'''; options=options(~strcmp(options,'nomergeinfo')); else mergeinfo=true; end

if ~isempty(batch)&&isstruct(batch)
    batchnew=repmat(batch,[N,1]);
    
    % node-specific project files
    if isfield(batch,'filename'), filename=batch.filename;
    else filename=CONN_x.filename;
    end
    if isempty(filename), error('Undefined project filename'); end
    for n=1:N,
        if 0,%n==1, batchnew(n).filename=filename;
        else batchnew(n).filename=conn_prepend('',filename,sprintf('_node%04d.mat',n));
        end
    end
    defineddata=false;
    Ns=[];
    
    % distributes subject info to node-specific projects
    if isfield(batch,'New')
        if isfield(batch.New,'functionals')&&~isempty(batch.New.functionals)
            defineddata=true;
            if isempty(Ns)
                Ns=numel(batch.New.functionals);
                N=min(Ns,N);
                ns=Ns/N;
            elseif Ns~=numel(batch.New.functionals), error('incorrect number of entries in batch.New.functionals (%d; expected %d)',numel(batch.New.functionals),Ns);
            end
            for n=1:N,
                idx=floor(ns*(n-1))+1:min(Ns,floor(ns*n));
                batchnew(n).New.functionals=batch.New.functionals(idx);
            end
        end
        if isfield(batch.New,'structurals')&&~isempty(batch.New.structurals)
            defineddata=true;
            if isempty(Ns)
                Ns=numel(batch.New.structurals);
                N=min(Ns,N);
                ns=Ns/N;
            elseif Ns~=numel(batch.New.structurals), error('incorrect number of entries in batch.New.structurals (%d; expected %d)',numel(batch.New.structurals),Ns);
            end
            for n=1:N,
                idx=floor(ns*(n-1))+1:min(Ns,floor(ns*n));
                batchnew(n).New.structurals=batch.New.structurals(idx);
            end
        end
    end
    if isfield(batch,'Setup')
        if isfield(batch.Setup,'functionals')&&~isempty(batch.Setup.functionals)
            defineddata=true;
            if isempty(Ns)
                Ns=numel(batch.Setup.functionals);
                N=min(Ns,N);
                ns=Ns/N;
            elseif Ns~=numel(batch.Setup.functionals), error('incorrect number of entries in batch.Setup.functionals (%d; expected %d)',numel(batch.Setup.functionals),Ns);
            end
            for n=1:N,
                idx=floor(ns*(n-1))+1:min(Ns,floor(ns*n));
                batchnew(n).Setup.functionals=batch.Setup.functionals(idx);
                batchnew(n).Setup.nsubjects=numel(idx);
            end
        end
        if isfield(batch.Setup,'structurals')&&~isempty(batch.Setup.structurals)
            defineddata=true;
            if isempty(Ns)
                Ns=numel(batch.Setup.structurals);
                N=min(Ns,N);
                ns=Ns/N;
            elseif Ns~=numel(batch.Setup.structurals), error('incorrect number of entries in batch.Setup.structurals (%d; expected %d)',numel(batch.Setup.structurals),Ns);
            end
            for n=1:N,
                idx=floor(ns*(n-1))+1:min(Ns,floor(ns*n));
                batchnew(n).Setup.structurals=batch.Setup.structurals(idx);
            end
        end
        if isfield(batch.Setup,'spmfiles')&&~isempty(batch.Setup.spmfiles)
            defineddata=true;
            if isempty(Ns)
                Ns=numel(batch.Setup.spmfiles);
                N=min(Ns,N);
                ns=Ns/N;
            elseif Ns~=numel(batch.Setup.spmfiles), error('incorrect number of entries in batch.Setup.spmfiles (%d; expected %d)',numel(batch.Setup.spmfiles),Ns);
            end
            for n=1:N,
                idx=floor(ns*(n-1))+1:min(Ns,floor(ns*n));
                batchnew(n).Setup.spmfiles=batch.Setup.spmfiles(idx);
            end
        end
        if isfield(batch.Setup,'roiextract_functionals')&&~isempty(batch.Setup.roiextract_functionals)
            if isempty(Ns)
                Ns=numel(batch.Setup.roiextract_functionals);
                N=min(Ns,N);
                ns=Ns/N;
            elseif Ns~=numel(batch.Setup.roiextract_functionals), error('incorrect number of entries in batch.Setup.roiextract_functionals (%d; expected %d)',numel(batch.Setup.roiextract_functionals),Ns);
            end
            for n=1:N,
                idx=floor(ns*(n-1))+1:min(Ns,floor(ns*n));
                batchnew(n).Setup.roiextract_functionals=batch.Setup.roiextract_functionals(idx);
            end
        end
        if isfield(batch.Setup,'unwarp_functionals')&&~isempty(batch.Setup.unwarp_functionals)
            if isempty(Ns)
                Ns=numel(batch.Setup.unwarp_functionals);
                N=min(Ns,N);
                ns=Ns/N;
            elseif Ns~=numel(batch.Setup.unwarp_functionals), error('incorrect number of entries in batch.Setup.unwarp_functionals (%d; expected %d)',numel(batch.Setup.unwarp_functionals),Ns);
            end
            for n=1:N,
                idx=floor(ns*(n-1))+1:min(Ns,floor(ns*n));
                batchnew(n).Setup.unwarp_functionals=batch.Setup.unwarp_functionals(idx);
            end
        end
        if isfield(batch.Setup,'masks')&&~isempty(batch.Setup.masks)
            masks={'Grey','White','CSF'};
            for nmask=1:length(masks),
                if isfield(batch.Setup.masks,masks{nmask})&&~isempty(batch.Setup.masks.(masks{nmask})),
                    if ~isstruct(batch.Setup.masks.(masks{nmask})),
                        temp=batch.Setup.masks.(masks{nmask});
                        if iscell(temp)&&numel(temp)>1
                            if isempty(Ns)
                                Ns=numel(temp);
                                N=min(Ns,N);
                                ns=Ns/N;
                            elseif Ns~=numel(temp), error('incorrect number of entries in batch.Setup.masks (%d; expected %d)',numel(temp),Ns);
                            end
                            for n=1:N,
                                idx=floor(ns*(n-1))+1:min(Ns,floor(ns*n));
                                batchnew(n).Setup.masks.(masks{nmask})=temp(idx);
                            end
                        end
                    else
                        temp=batch.Setup.masks.(masks{nmask}).files;
                        if iscell(temp)&&numel(temp)>1
                            if isempty(Ns)
                                Ns=numel(temp);
                                N=min(Ns,N);
                                ns=Ns/N;
                            elseif Ns~=numel(temp), error('incorrect number of entries in batch.Setup.masks (%d; expected %d)',numel(temp),Ns);
                            end                                
                            for n=1:N,
                                idx=floor(ns*(n-1))+1:min(Ns,floor(ns*n));
                                batchnew(n).Setup.masks.(masks{nmask}).files=temp(idx);
                            end
                        end
                    end
                end
            end
        end
        if isfield(batch.Setup,'rois')&&isfield(batch.Setup.rois,'files')&&~isempty(batch.Setup.rois.files)
            for nmask=1:length(batch.Setup.rois.files),
                temp=batch.Setup.rois.files{nmask};
                if iscell(temp)&&numel(temp)>1
                    if isempty(Ns)
                        Ns=numel(temp);
                        N=min(Ns,N);
                        ns=Ns/N;
                    elseif Ns~=numel(temp), error('incorrect number of entries in batch.Setup.rois.files (%d; expected %d)',numel(temp),Ns);
                    end
                    for n=1:N,
                        idx=floor(ns*(n-1))+1:min(Ns,floor(ns*n));
                        batchnew(n).Setup.rois.files{nmask}=temp(idx);
                    end
                end
            end
        end
        if isfield(batch.Setup,'conditions')&&isfield(batch.Setup.conditions,'onsets')&&~isempty(batch.Setup.conditions.onsets)
            for nmask=1:length(batch.Setup.conditions.onsets),
                temp=batch.Setup.conditions.onsets{nmask};
                if iscell(temp)&&numel(temp)>1
                    if isempty(Ns)
                        Ns=numel(temp);
                        N=min(Ns,N);
                        ns=Ns/N;
                    elseif Ns~=numel(temp), error('incorrect number of entries in batch.Setup.conditions.onsets (%d; expected %d)',numel(temp),Ns);
                    end
                    for n=1:N,
                        idx=floor(ns*(n-1))+1:min(Ns,floor(ns*n));
                        batchnew(n).Setup.conditions.onsets{nmask}=temp(idx);
                    end
                end
                temp=batch.Setup.conditions.durations{nmask};
                if iscell(temp)&&numel(temp)>1
                    if isempty(Ns)
                        Ns=numel(temp);
                        N=min(Ns,N);
                        ns=Ns/N;
                    elseif Ns~=numel(temp), error('incorrect number of entries in batch.Setup.conditions.durations (%d; expected %d)',numel(temp),Ns);
                    end
                    for n=1:N,
                        idx=floor(ns*(n-1))+1:min(Ns,floor(ns*n));
                        batchnew(n).Setup.conditions.durations{nmask}=temp(idx);
                    end
                end
            end
        end
        if isfield(batch.Setup,'covariates')&&isfield(batch.Setup.covariates,'files')&&~isempty(batch.Setup.covariates.files)
            for nmask=1:length(batch.Setup.covariates.files),
                temp=batch.Setup.covariates.files{nmask};
                if iscell(temp)&&numel(temp)>1
                    if isempty(Ns)
                        Ns=numel(temp);
                        N=min(Ns,N);
                        ns=Ns/N;
                    elseif Ns~=numel(temp), error('incorrect number of entries in batch.Setup.covariates.files (%d; expected %d)',numel(temp),Ns);
                    end
                    for n=1:N,
                        idx=floor(ns*(n-1))+1:min(Ns,floor(ns*n));
                        batchnew(n).Setup.covariates.files{nmask}=temp(idx);
                    end
                end
            end
        end
    end
    batchnew=batchnew(1:N);
    if ~defineddata, % check node-specific project files exist (if batch does not create them)
        if ~all(arrayfun(@(n)conn_existfile(batchnew(n).filename),1:N))
            error('Node-specific projects have not been created yet. Run conn_batch_pct first with New and/or Setup fields defining subject info');
        end
    end
else
    if ischar(batch), filename=batch;
    else filename=CONN_x.filename;
    end
    if isempty(filename), error('Undefined project filename'); end
end

switch(lower(PCTtype))
    case 'pct', % run using Matlab PCT (parfor). note: use parpool to create your parallel pool on cluster first
        parfor i=1:N
            fprintf('running node %s\n',batchnew(i).filename);
            conn_batch(batchnew(i));
        end
        
    case {'sge','scripts'}, % run using Grid Engine queing system submissions or create individual csh scripts for batch job submission to arbitrary parallel cluster
        % creates individual scripts for submission
        for i=1:N
            batch=batchnew(i);
            tfilename=conn_prepend('',filename,sprintf('_node%04d.mat',i));
            tfolder=fileparts(tfilename); if isempty(tfolder), tfolder=pwd; end
            save(conn_prepend('PCTscript_',tfilename),'batch');
            fh=fopen(conn_prepend('PCTscript_',tfilename,'.sh'),'wt');
            fprintf(fh,'#!/bin/csh\n');
            fprintf(fh,'matlab -nodisplay -nodesktop -nosplash -r "addpath %s; addpath %s; cd %s; load(''%s''); conn_batch(batch); exit"\n',fileparts(which('spm')), fileparts(which('conn')), tfolder, conn_prepend('PCTscript_',tfilename));
            fclose(fh);
            fprintf('Created csh script %s. Edit this file as necessary and submit to your parallel cluster queue\n',conn_prepend('PCTscript_',tfilename,'.sh'));
        end
        tfilename=conn_prepend('',filename,'_merge.mat');
        tfolder=fileparts(tfilename); if isempty(tfolder), tfolder=pwd; end
        fh=fopen(conn_prepend('PCTscript_',tfilename,'.sh'),'wt');
        fprintf(fh,'#!/bin/csh\n');
        fprintf(fh,'matlab -nodisplay -nodesktop -nosplash -r "addpath %s; addpath %s; cd %s; conn_batch_pct(''%s'',%d,''merge''%s); exit"\n',fileparts(which('spm')), fileparts(which('conn')), tfolder, filename, N, [rmoptions{:}]);
        fclose(fh);
        fprintf('Created csh script %s. Edit this file as necessary and submit to your parallel cluster queue AFTER ALL THE OTHERS HAVE FINISHED\n',conn_prepend('PCTscript_',tfilename,'.sh'));
        
        % submits to queuing system
        if strcmp(lower(PCTtype),'sge') 
            if numel(options)<1||isempty(options{1}), cmd_submit='qsub -N conn_nJOBNUMBER JOBOTHEROPTIONS JOBCOMMAND'; else cmd_submit=options{1}; end 
            if numel(options)<2||isempty(options{2}), cmd_submitdelayed='qsub -N conn_merge -hold_jid "conn_n*" JOBOTHEROPTIONS JOBCOMMAND'; else cmd_submitdelayed=options{2}; end 
            if numel(options)<3||isempty(options{3}), cmd_options=''; else cmd_options=options{3}; end % e.g. cmd_options='-l h_rt=48:00:00 -l mem_total=8G';
            basescriptname=conn_prepend('PCTscript_',filename);
            % submit individual jobs to queue
            for i=1:N,
                tfilename=conn_prepend('',basescriptname,sprintf('_node%04d.sh',i));
                str=regexprep(cmd_submit,{'JOBNUMBER','JOBCOMMAND','JOBOTHEROPTIONS'},{num2str(i),tfilename,cmd_options});
                fprintf('submitting job #%d\n',i);
                system(str);
            end
            % submit final merge job to queue (request hold until jobs above have finished)
            tfilename=conn_prepend('',basescriptname,'_merge.sh');
            str=regexprep(cmd_submitdelayed,{'JOBNUMBER','JOBCOMMAND','JOBOTHEROPTIONS'},{num2str(i),tfilename,cmd_options});
            fprintf('submitting delayed job\n');
            system(str);
        end

    case 'merge' % merge final results into single project 
        tfilename={};
        for n=1:N,
            tfilename{n}=conn_prepend('',filename,sprintf('_node%04d.mat',n));
        end
        if ~isempty(dir(filename))&&~mergeinfo, conn('load',filename);
        else conn('load',tfilename{1});
        end
        conn('save',filename);
        conn_merge(char(tfilename),[],copyfiles,true,softlink,mergeinfo);
        if copyfiles, conn_process('prepare_results'); end
        conn save;
        fprintf('Merged project %s\n',filename);
        
    case 'none'
    otherwise
        error('unrecognized option %s',PCTtype);
end

