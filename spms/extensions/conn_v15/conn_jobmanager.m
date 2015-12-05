function varargout = conn_jobmanager(option,varargin)
% CONN_JOBMANAGER 
%
% conn_jobmanager;  
%   launches GUI displaying pending jobs
%
% conn_jobmanager all;
%   launches GUI displaying finished or pending jobs
%
% conn_jobmanager report;
%   if there is a pending job, displays status of individual nodes
%
% conn_jobmanager restartstopped;
%   if there is a pending job, resubmits any stopped nodes
%
% conn_jobmanager finish;
%   if there is a pending job, stop all nodes and cancel job
%

% note: several options require a conn project currently loaded (e.g. use "conn load conn_myproject.mat")
%
% internal function: manages job submission for parallel/background processes
%

persistent CFG PROFILES DEFAULT;
global CONN_x;
LOADTESTPROFILES=false; % set to "true" for additional test profiles
if isempty(CFG)
    filename=fullfile(fileparts(which(mfilename)),'conn_jobmanager.mat');
    if conn_existfile(filename), data=load(filename,'profiles','default'); PROFILES=data.profiles; DEFAULT=data.default;
    else
        PROFILES={...
            struct('name','Grid Engine computer cluster',... % tested on BU SCC
                   'cmd_submit','qsub -N JOBLABEL -e STDERR -o STDOUT OPTS SCRIPT',...
                   'cmd_submitoptions','',...
                   'cmd_deletejob','qdel JOBLABEL',...
                   'cmd_checkstatus','qstat -j JOBLABEL',...
                   'cmd_submitoptions_example','-l h_rt=[hh:mm:ss] -q [queue] -A [account]'),...
            struct('name','PBS/Torque computer cluster',...  % tested on MIT mindhive
                   'cmd_submit','qsub -N JOBLABEL -e STDERR -o STDOUT OPTS SCRIPT',...
                   'cmd_submitoptions','',...
                   'cmd_deletejob','qdel JOBID',...
                   'cmd_checkstatus','qstat JOBID',...
                   'cmd_submitoptions_example','-l walltime=[hh:mm:ss] -q [queue] -W [account]'),...
            struct('name','LSF computer cluster',...         % untested yet
                   'cmd_submit','bsub -J JOBLABEL -e STDERR -o STDOUT OPTS SCRIPT',...
                   'cmd_submitoptions','',...
                   'cmd_deletejob','bkill -J JOBLABEL',...
                   'cmd_checkstatus','bjobs -J JOBLABEL',...
                   'cmd_submitoptions_example','-W [hh:mm:ss] -q [queue] -P [account]')};
        DEFAULT=1;
    end
    if LOADTESTPROFILES
       TESTPROFILES={...
            struct('name','Background process (Unix,Mac)',...
                   'cmd_submit','/bin/csh SCRIPT 2> STDERR 1> STDOUT &',...
                   'cmd_deletejob','pkill -f STDLOG',...
                   'cmd_checkstatus','pgrep -f STDLOG',...
                   'cmd_submitoptions','',...
                   'cmd_submitoptions_example',''),...
            struct('name','Background process (Windows)',...
                   'cmd_submit','start "JOBLABEL" /min SCRIPT 2> STDERR 1> STDOUT',...
                   'cmd_deletejob','taskkill /FI "WINDOWTITLE eq JOBLABEL"',...
                   'cmd_checkstatus','tasklist /FI "WINDOWTITLE eq JOBLABEL"',...
                   'cmd_submitoptions','',...
                   'cmd_submitoptions_example',''),...
            struct('name','Null profile',...
                   'cmd_submit','',...
                   'cmd_deletejob','',...
                   'cmd_checkstatus','',...
                   'cmd_submitoptions','',...
                   'cmd_submitoptions_example','')};
       for n=1:numel(TESTPROFILES)
           names=cellfun(@(x)x.name,PROFILES,'uni',0);
           if ~any(strcmp(TESTPROFILES{n}.name,names))
               PROFILES{end+1}=TESTPROFILES{n};
           end
       end
    end
    CFG=struct(...
        'profile',DEFAULT,... 
        'matlabpath',fullfile(matlabroot,'bin'),...
        'osquotes',char('"'*ispc+''''*~ispc));
    for n=reshape(fieldnames(PROFILES{CFG.profile}),1,[])
        CFG.(n{1})=PROFILES{CFG.profile}.(n{1});
    end
end
            
varargout={};
qoptions={'all','report','restartstopped','finish'};
if ~nargin||(nargin==1&&ischar(option)&&any(strcmp(option,qoptions)))||isstruct(option), % GUI
    if nargin==1&&ischar(option)&&any(strcmp(option,qoptions)), whichoption=find(strcmp(option,qoptions),1);
    else whichoption=[];
    end
    if ~nargin||~isempty(whichoption), 
        if isempty(CONN_x), 
            ftemp=dir('*.qlog'); 
            if numel(ftemp)==1, CONN_x_filename=conn_fullfile(ftemp.name); 
            else error('Unknown project. Load a conn project first (or cd to the folder containing your conn project)'); 
            end
        else CONN_x_filename=CONN_x.filename;
        end
        if whichoption==1 %all
            files=conn_dir(fullfile(conn_prepend('',conn_fullfile(CONN_x_filename),'.qlog/info.mat')));
            if ~isempty(files), files=cellstr(files); end
        else
            localfilename=conn_projectmanager('projectfile',CONN_x_filename,struct('id','*','isextended',true));
            allfiles=conn_dir(localfilename,'-R'); % check .dmat
            files={};
            if ~isempty(allfiles),
                tag=regexp(cellstr(allfiles),'\d{4}(\d+)\.dmat$','tokens','once');
                tag=unique([tag{:}]);
                for n=1:numel(tag)
                    pathname=fullfile(conn_prepend('',CONN_x_filename,'.qlog'),tag{n});
                    if exist(pathname,'dir')&&conn_existfile(fullfile(pathname,'info.mat'))
                        files{end+1}=fullfile(pathname,'info.mat');
                    end
                end
            end
        end
        if isempty(files), 
            varargout={[]};
            if ~nargout, 
                if whichoption==1, conn_msgbox('There are no finished or pending jobs associated with this project','',true);
                elseif ~isempty(whichoption), disp('There are no pending jobs associated with this project'); 
                else conn_msgbox('There are no pending jobs associated with this project','',true);
                end
            end
            return;
        end
        [nill,filedates]=cellfun(@(x)fileparts(fileparts(x)),files,'uni',0);
        filedates=cellfun(@(x)sprintf('%s-%s-%s %s:%s:%s',x(1:2),x(3:4),x(5:6),x(7:8),x(9:10),x(11:12)),filedates,'uni',0);
        load(files{end},'info');
        if whichoption==2 %report
            info=conn_jobmanager('statusjob',info,[],true,true);
            varargout={info};
            return;
        elseif whichoption==3 %restartstopped
            info=conn_jobmanager('statusjob',info,[],true,true);
            info=conn_jobmanager('submitjob',info,'stopped');
            varargout={info};
            return;
        elseif whichoption==4, %finish
            info=conn_jobmanager('deletejob',info);
            info=conn_jobmanager('clearqlog',info);
            filename=regexprep(info.private{1}(1).project,'\?.*$','');
            conn('load',filename);
            conn save;
            varargout={info};
            return;
        end
    else
        info=option;
        files={};
        filedates={};
    end
    info=conn_jobmanager_gui(info,files,filedates,varargin{:});
    if nargout, varargout={info}; end
else
    switch(lower(option))
        case 'settings'
            [PROFILES,DEFAULT]=conn_jobmanager_settings(PROFILES,DEFAULT);
            CFG.profile=DEFAULT;
            for n=reshape(fieldnames(PROFILES{CFG.profile}),1,[])
                CFG.(n{1})=PROFILES{CFG.profile}.(n{1});
            end
            
        case 'profiles',
            names=cellfun(@(x)x.name,PROFILES,'uni',0);
            varargout={names,DEFAULT};
            
        case 'setprofile'
            name=varargin{1};
            if ischar(name)
                names=cellfun(@(x)lower(x.name),PROFILES,'uni',0);
                idx=strmatch(lower(name),names);
                if numel(idx)~=1, idx=strmatch(lower(name),names,'exact'); end
                if isempty(idx), error('unknown profile name %s',name);
                elseif numel(idx)>1, error('multiple potential matches for profile name %s',name);
                end
            else idx=name;
            end
            if ~isempty(idx)&&~isnan(idx), conn_jobmanager('options','profile',idx); end
            if nargout, varargout={idx}; end
            
        case 'getprofile',
            varargout={CFG.name};
            
        case 'options',
            if numel(varargin)>1
                for n=1:2:numel(varargin)
                    if isfield(CFG,varargin{n}), CFG.(varargin{n})=varargin{n+1}; end
                    if strcmp(varargin{n},'profile'), 
                        for n=reshape(fieldnames(PROFILES{CFG.profile}),1,[])
                            CFG.(n{1})=PROFILES{CFG.profile}.(n{1});
                        end
                    end
                end
                if nargout, varargout={CFG}; end
            else
                varargout={CFG.(varargin{1})};
            end
            
        case 'submit' %('submit',strprocess,N,options) ('submit',batch,N,options) 
            strcom=varargin{1};
            if nargin>2&&~isempty(varargin{2}), N=varargin{2};
            else
                answer=inputdlg('Number of parallel jobs?','',1,{num2str(CONN_x.Setup.nsubjects)});
                if isempty(answer), return; end
                N=str2num(answer{1});
            end
            options=varargin(3:end);
            if isempty(strcom), job=conn_jobmanager('job','test',[]);
            elseif ischar(strcom), job=conn_jobmanager('job','process',strcom,options{:}); 
            elseif iscell(strcom), 
                for n=1:numel(strcom), 
                    job(n)=conn_jobmanager('job','process',strcom{n},options{1}{n}{:}); 
                end
            else job=conn_jobmanager('job','batch',strcom,options{:}); 
            end
            info=conn_jobmanager('createjob',job,N);
            info=conn_jobmanager('submitjob',info);
            save(fullfile(info.pathname,'info.mat'),'info');
            if nargout, varargout={info}; 
            else conn_jobmanager(info);
            end
            
        case 'deletejob' %('deletejob',info,inodes)
            info=varargin{1};
            if nargin>2&&~isempty(varargin{2}), ijobs=varargin{2}; else ijobs=1:numel(info.scripts); end
            for i=ijobs(:)',
                conn_jobmanager('tag',info.scripts{i},'stopped');
                str=regexprep(CFG.cmd_deletejob,{'JOBLABEL','JOBID','OPTS','SCRIPT','STDOUT','STDERR','STDLOG'},[{info.joblabel{i} info.jobid{i} CFG.cmd_submitoptions} cellfun(@(x)[CFG.osquotes x CFG.osquotes],{info.scripts{i},info.stdout{i},info.stderr{i},info.stdlog{i}},'uni',0)]);
                [ok,msg]=system(str);
                %if ok~=0, fprintf(2,'%s\n',msg); end
                msg(msg<32|msg>=127)=' ';
                info.deletemsg{i}=msg;
            end
            varargout={info};
            
        case 'statusjob' %('statusjob',info,inodes)
            info=varargin{1};
            if nargin>2&&~isempty(varargin{2}), ijobs=varargin{2}; else ijobs=1:numel(info.scripts); end
            if nargin>3&&~isempty(varargin{3}), force=varargin{3}; else force=false; end
            if nargin>4&&~isempty(varargin{4}), dodisp=varargin{4}; else dodisp=false; end
            changed=false(1,numel(info.scripts));
            for i=ijobs(:)',
                newtag=conn_jobmanager('tag',info.scripts{i});
                if force||~isfield(info,'tagmsg')||numel(info.tagmsg)<i||~isequal(newtag,info.tagmsg{i}), changed(i)=true; end
                info.tagmsg{i}=newtag; 
            end
            for i=find(changed),
                %disp(['check ',info.joblabel{i}]);
                str=regexprep(CFG.cmd_checkstatus,{'JOBLABEL','JOBID','OPTS','SCRIPT','STDOUT','STDERR','STDLOG'},[{info.joblabel{i} info.jobid{i} CFG.cmd_submitoptions} cellfun(@(x)[CFG.osquotes x CFG.osquotes],{info.scripts{i},info.stdout{i},info.stderr{i},info.stdlog{i}},'uni',0)]);
                [ok,msg]=system(str);
                info.statemsg{i}=msg;
                if strcmp(info.jobid{i},'?')&&~isempty(msg), 
                    ID=regexp(msg,'\d+','match');
                    [nill,idx]=max(cellfun('length',ID));
                    if ~isempty(idx), info.jobid{i}=ID{idx}; else info.jobid{i}='?'; end
                end
                if ~ok, msg=info.jobid{i}; else msg=''; end
                %if ok~=0&&~isempty(msg), fprintf(2,'%s\n',msg); end
                msg(msg<32|msg>=127)='';
                info.statusmsg{i}=msg;
                if strcmp(info.tagmsg{i},'finished')&&~isempty(info.statusmsg{i}), info.tagmsg{i}='finishing'; end
                if strcmp(info.tagmsg{i},'stopped')&&~isempty(info.statusmsg{i}), info.tagmsg{i}='stopping'; end
                if strcmp(info.tagmsg{i},'running')&&isempty(info.statusmsg{i}), info.tagmsg{i}='stopped'; end
                if strcmp(info.tagmsg{i},'submitted')&&isempty(info.statusmsg{i}), info.tagmsg{i}='failed'; end
                if numel(ijobs)==1, fprintf('%s %s\n',info.joblabel{i},info.tagmsg{i}); end
            end
            try, if any(changed), save(fullfile(info.pathname,'info.mat'),'info'); end; end
            varargout={info};
            if dodisp||(any(changed)&&numel(ijobs)>1), 
                [itag,nill,jtag]=unique(info.tagmsg);
                for n=1:numel(itag), fprintf('%d job(s) %s  ',sum(jtag==n),itag{n}); end
                fprintf('\n');
            end
            
        case 'submitjob', %('submitjob',info,inodes)
            info=varargin{1};
            if nargin>2&&~isempty(varargin{2}), ijobs=varargin{2}; else ijobs=1:numel(info.scripts); end
            if ischar(ijobs), ijobs=find(strcmp(info.tagmsg,ijobs)); end
            for i=ijobs(:)',
                conn_jobmanager('tag',info.scripts{i},'submitted');
                str=regexprep(CFG.cmd_submit,{'JOBLABEL','JOBID','OPTS','SCRIPT','STDOUT','STDERR','STDLOG'},[{info.joblabel{i} info.jobid{i} CFG.cmd_submitoptions} cellfun(@(x)[CFG.osquotes x CFG.osquotes],{info.scripts{i},info.stdout{i},info.stderr{i},info.stdlog{i}},'uni',0)]);
                [ok,msg]=system(str);
                if ok~=0, 
                    %fprintf(2,'%s\n',msg); 
                    conn_jobmanager('tag',info.scripts{i},'failed');
                end
                %msg(msg<32|msg>=127)=' ';
                info.submitmsg{i}=msg;
                ID=regexp(msg,'\d+','match'); 
                [nill,idx]=max(cellfun('length',ID)); 
                if ~isempty(idx), info.jobid{i}=ID{idx}; else info.jobid{i}='?'; end
            end
            varargout={info};
            
        case 'waitfor',
            info=varargin{1};
            [info,ok]=conn_jobmanager_gui(info,{},{},'nogui');
            if nargout, varargout={info,ok}; end

        case 'cleardmat'
            tpath=strvcat(conn_dir(conn_prepend('',conn_fullfile(CONN_x.filename),'.*.dmat'),'-R'),conn_dir(conn_prepend('',conn_fullfile(CONN_x.filename),'.*.emat'),'-R'));
            if ~isempty(tpath),
                tpath=cellstr(tpath);
                for n=1:numel(tpath)
                    if ispc,
                        [ok,nill]=system(sprintf('del "%s"',tpath{n}));
                    else
                        [ok,nill]=system(sprintf('rm -f ''%s''',tpath{n}));
                    end
                end
            end
            
        case 'clearqlog',
            if nargin>1&&~isempty(varargin{1}), 
                info=varargin{1};
                tpath={info.pathname}; % removes .qlog folder
            else
                tpath=conn_prepend('',conn_fullfile(CONN_x.filename),'.qlog');
                dirs=dir(fullfile(tpath,'*'));
                dirs=dirs([dirs.isdir]);
                dirs=dirs(cellfun('length',regexp({dirs.name},'^\d+$'))>0);
                tpath=cellfun(@(x)fullfile(tpath,x),{dirs.name},'uni',0);
            end
            for n=1:numel(tpath)
                if ispc,
                    [ok,nill]=system(sprintf('del "%s"\*',tpath{n}));
                    [ok,nill]=system(sprintf('rmdir "%s"',tpath{n}));
                else
                    [ok,nill]=system(sprintf('rm -f ''%s''/*',tpath{n}));
                    [ok,nill]=system(sprintf('rmdir ''%s''',tpath{n}));
                end
%             % removes .dmat .emat
%             for n=1:numel(info.nodes)
%                 tfile=conn_projectmanager('projectfile',regexprep(info.private{n}(1).project,'\?.*$',''),struct('isextended',true,'id',info.nodes{n}));
%                 if ispc, [ok,nill]=system(sprintf('del "%s"',tfile));
%                 else [ok,nill]=system(sprintf('rm ''%s''',tfile));
%                 end
%             end
            end
            
        % internal use
        case 'job', %('job','batch',batch) ('job','process',cmdstr,...)
            if nargin>1&&~isempty(varargin{1}), jtype=varargin{1};
            else jtype='process';
            end
            if nargin>2&&~isempty(varargin{2}), fcn=varargin{2};
            else fcn=[];
            end
            if nargin>3, args=varargin(3:end);
            else args={};
            end
            job=struct('type',jtype,'fcn',fcn,'args',{args});
            varargout={job};
            
        case 'tag', % submitted/started/finished
            filename=varargin{1};
            if nargin>2&&~isempty(varargin{2})
                tag=varargin{2};
                disp(sprintf('%s %s',filename,tag));
                if ispc, [ok,nill]=system(sprintf('del "%s"',conn_prepend('',filename,'.status.*')));
                else [ok,nill]=system(sprintf('rm ''%s''*',conn_prepend('',filename,'.status.')));
                end
                fclose(fopen(conn_prepend('',filename,['.status.' tag]),'wt'));
                varargout={tag};
            else
                tfiles=dir(conn_prepend('',filename,'.status.*'));
                info=regexp({tfiles.name},'^node\.(\d+).status\.(\w+)$','tokens','once');
                info=info(cellfun('length',info)==2);
                if isempty(info), varargout={{},{}};
                else varargout=fliplr(info{1});
                end
            end
            
        case {'exec','rexec'}
            me=[];
            filename=varargin{1};
            try
                load(filename,'job','-mat');
                if strcmp(lower(option),'rexec'), conn_jobmanager('tag',job(1).tag,'running'); end
                for n=1:numel(job)
                    switch(job(n).type)
                        case 'process'
                            fprintf('Processing %s job %d/%d\n',job(n).project,n,numel(job));
                            conn('load',job(n).project);
                            conn save;
                            CONN_x.gui=struct('overwrite','Yes','display',0);
                            if numel(job(n).args)>=1&&~isempty(job(n).args)&&~isempty(job(n).args{1}), CONN_x.gui=job(n).args{1}; end
                            conn_process(job(n).fcn,job(n).args{2:end});
                            conn save;
                        case 'batch'
                            job(n).fcn.filename=job(n).project;
                            conn_batch(job(n).fcn);
                            conn save;
                        case 'test'
                            pause(5);
                            disp('TEST RUN SUCCESSFULLY');
                    end
                end
                if strcmp(lower(option),'rexec'), conn_jobmanager('tag',job(1).tag,'finished'); end
                if strcmp(lower(option),'rexec'), exit(0); end
                
            catch me
                conn_jobmanager('tag',job(1).tag,'error');
                str=conn_errormessage(me,job(1).tag);
                fprintf(2,'%s\n',str{:}); 
                if strcmp(lower(option),'rexec'), exit(1); end
            end
                        
        case 'createjob', % ('createjob',job,N)
            job=varargin{1};
            if nargin>2&&~isempty(varargin{2}), N=varargin{2};
            else N=min(50,CONN_x.Setup.nsubjects);
            end
            
            if iscell(N), Isubjects=N; N=numel(Isubjects); 
            else Isubjects={}; 
            end
            Ns=CONN_x.Setup.nsubjects;
            %N=min(Ns,N);
            ns=Ns/N;
            tag=datestr(now,'yymmddHHMMSSFFF');
            pathname=fullfile(conn_prepend('',CONN_x.filename,'.qlog'),tag);
            [ok,nill]=mkdir(pathname);
            pathname=conn_fullfile(pathname);
            [job.pathname]=deal(pathname);
            isdep=false;
            try, isdep=isdeployed; end
            info=struct('pathname',pathname,'scripts',{{}},'nodes',{{}},'private',{{}});
            for n=1:N
                if isempty(Isubjects), subjects=floor(ns*(n-1))+1:min(Ns,floor(ns*n));
                else subjects=Isubjects{n};
                end
                ID=sprintf('%04d%s',n,tag);
                SUBJECTS=mat2str(subjects);
                REF=conn_fullfile(sprintf('%s?id=%s,subjects=%s',CONN_x.filename,ID,SUBJECTS));
                [job.id]=deal(ID);
                [job.project]=deal(REF);
                filename_mat=fullfile(pathname,sprintf('node.%s.mat',ID));
                if ispc, filename_sh=fullfile(pathname,sprintf('node.%s.bat',ID)); 
                else filename_sh=fullfile(pathname,sprintf('node.%s.sh',ID)); 
                end
                info.scripts{n}=filename_sh;
                info.nodes{n}=ID;
                info.private{n}=job;
                info.joblabel{n}=['conn_',ID];
                info.jobid{n}='';
                info.stdout{n}=conn_prepend('',info.scripts{n},'.stdout');
                info.stderr{n}=conn_prepend('',info.scripts{n},'.stderr');
                info.stdlog{n}=conn_prepend('',info.scripts{n},'.stdlog');
                if ispc
                    fh=fopen(filename_sh,'wt');
                    if isdep,   fprintf(fh,'conn %s jobmanager rexec "%s"\n',filename_mat);
                    else        fprintf(fh,'%s -nodesktop -noFigureWindows -nosplash -automation -logfile "%s" -r "addpath %s; addpath %s; cd %s; conn_jobmanager(''rexec'',''%s''); exit"\n',...
                            fullfile(CFG.matlabpath,'matlab'), info.stdlog{n}, fileparts(which('spm')), fileparts(which('conn')), pathname, filename_mat);
                    end
                    fprintf(fh,'exit\n');
                else
                    fh=fopen(filename_sh,'wt');
                    fprintf(fh,'#!/bin/csh\n');
                    if isdep,   fprintf(fh,'run_conn.sh %s jobmanager rexec ''%s''\n',matlabroot,filename_mat);
                    else        fprintf(fh,'%s -nodesktop -nodisplay -nosplash -logfile ''%s'' -r "addpath %s; addpath %s; cd %s; conn_jobmanager(''rexec'',''%s''); exit"\n',...
                            fullfile(CFG.matlabpath,'matlab'), info.stdlog{n}, fileparts(which('spm')), fileparts(which('conn')), pathname, filename_mat);
                    end
                    fprintf(fh,'echo _NODE END_\n');
                end
                fclose(fh);
                [job.tag]=deal(filename_sh);
                save(filename_mat,'job');
            end
            varargout={info};
            
        otherwise,
            fprintf('Warning: unknwon conn_jobmanager option %s\n',lower(option));
    end
end
end

function [profiles,default]=conn_jobmanager_settings(profiles,default)
handles.hfig=figure('units','norm','position',[.3 .3 .3 .6],'name','Distributed computing settings','numbertitle','off','menubar','none','color','w');
uicontrol(handles.hfig,'style','text','units','norm','position',[.1 .90 .8 .05],'string','Profiles:  ','backgroundcolor','w','horizontalalignment','left');
handles.profiles=uicontrol(handles.hfig,'style','popupmenu','units','norm','position',[.1 .85 .8 .05],'string','','value',default,'callback',@(varargin)conn_jobmanager_settings_update('profile'));
handles.new=uicontrol(handles.hfig,'style','pushbutton','units','norm','position',[.1,.8,.2,.05],'string','New','callback',@(varargin)conn_jobmanager_settings_update('new'));
handles.delete=uicontrol(handles.hfig,'style','pushbutton','units','norm','position',[.3,.8,.2,.05],'string','Delete','callback',@(varargin)conn_jobmanager_settings_update('delete'));
handles.test=uicontrol(handles.hfig,'style','pushbutton','units','norm','position',[.5,.8,.4,.05],'string','Test profile','callback',@(varargin)conn_jobmanager_settings_update('test'));
handles.save=uicontrol(handles.hfig,'style','pushbutton','units','norm','position',[.55,.025,.2,.05],'string','Save','callback',@(varargin)conn_jobmanager_settings_update('save'),'tooltipstring','Save profile changes for future Matlab sessions');
handles.exit=uicontrol(handles.hfig,'style','pushbutton','units','norm','position',[.75,.025,.2,.05],'string','Exit','callback','close(gcbf)');
uicontrol(handles.hfig,'style','text','units','norm','position',[.1 .64 .8 .04],'string','Profile name:  ','backgroundcolor','w','horizontalalignment','left');
handles.name=uicontrol(handles.hfig,'style','edit','units','norm','position',[.1,.6,.8,.04],'string','','backgroundcolor','w','fontname','monospace','horizontalalignment','left','callback',@(varargin)conn_jobmanager_settings_update('edit'));
uicontrol(handles.hfig,'style','text','units','norm','position',[.1 .54 .8 .04],'string','Command used to submit a job:','backgroundcolor','w','horizontalalignment','left');
handles.cmd_submit=uicontrol(handles.hfig,'style','edit','units','norm','position',[.1,.5,.8,.04],'string','','backgroundcolor','w','fontname','monospace','horizontalalignment','left','callback',@(varargin)conn_jobmanager_settings_update('edit'),'tooltipstring','<HTML>System command for submitting/executing a job<br/> - Enter <i>SCRIPT</i> to indicate the name of the script to be submitted/executed<br/> - Enter <i>JOBLABEL</i> to indicate a job name (autogenerated for each node)/label<br/> - Enter <i>STDOUT</i> to indicate the file where the stdout stream should be stored<br/> - Enter <i>STDERR</i> to indicate the file where the stderr stream should be stored<br/> - Enter <i>OPTS</i> to indicate additional optional arguments (see <i>additional submit options</i> below)<br/></HTML>');
uicontrol(handles.hfig,'style','text','units','norm','position',[.1 .44 .8 .04],'string','Additional submit options (optional):','backgroundcolor','w','horizontalalignment','left');
handles.cmd_submitoptions=uicontrol(handles.hfig,'style','edit','units','norm','position',[.1,.4,.8,.04],'string','','backgroundcolor','w','fontname','monospace','horizontalalignment','left','callback',@(varargin)conn_jobmanager_settings_update('edit'));
uicontrol(handles.hfig,'style','text','units','norm','position',[.1 .34 .8 .04],'string','Command used to delete a submitted job:','backgroundcolor','w','horizontalalignment','left');
handles.cmd_deletejob=uicontrol(handles.hfig,'style','edit','units','norm','position',[.1,.3,.8,.04],'string','','backgroundcolor','w','fontname','monospace','horizontalalignment','left','callback',@(varargin)conn_jobmanager_settings_update('edit'),'tooltipstring','<HTML>System command for deleting a submitted job<br/> - Enter <i>SCRIPT</i> to indicate the name of the script to be submitted/executed<br/> - Enter <i>JOBLABEL</i> to indicate a job name (autogenerated for each node)/label<br/> - Enter <i>JOBID</i> to indicate a job identifier (output of submit command)<br/> - Enter <i>STDOUT</i> to indicate the file where the stdout stream should be stored<br/> - Enter <i>STDERR</i> to indicate the file where the stderr stream should be stored<br/></HTML>');
uicontrol(handles.hfig,'style','text','units','norm','position',[.1 .24 .8 .04],'string','Command used to check the status of a submitted job:','backgroundcolor','w','horizontalalignment','left');
handles.cmd_checkstatus=uicontrol(handles.hfig,'style','edit','units','norm','position',[.1,.2,.8,.04],'string','','backgroundcolor','w','fontname','monospace','horizontalalignment','left','callback',@(varargin)conn_jobmanager_settings_update('edit'),'tooltipstring','<HTML>System command to check the status of a submitted job<br/>This command is expected to produce a exit(0) status if the job exists<br/> - Enter <i>SCRIPT</i> to indicate the name of the script to be submitted/executed<br/> - Enter <i>JOBLABEL</i> to indicate a job name (autogenerated for each node)/label<br/> - Enter <i>JOBID</i> to indicate a job identifier (output of submit command)<br/> - Enter <i>STDOUT</i> to indicate the file where the stdout stream should be stored<br/> - Enter <i>STDERR</i> to indicate the file where the stderr stream should be stored<br/></HTML>');
handles.isdefault=uicontrol(handles.hfig,'style','checkbox','units','norm','position',[.1,.1,.8,.05],'string','Select as default profile','backgroundcolor','w','callback',@(varargin)conn_jobmanager_settings_update('edit'));
iprofile=max(1,min(numel(profiles), default));
conn_jobmanager_settings_update('refresh');
waitfor(handles.hfig);

    function conn_jobmanager_settings_update(option,varargin)
        switch(option)
            case 'refresh',
                set(handles.profiles,'string',cellfun(@(x)x.name,profiles,'uni',0),'value',max(1,min(numel(profiles), iprofile)));
                set(handles.name,'string',profiles{iprofile}.name);
                set(handles.cmd_submit,'string',profiles{iprofile}.cmd_submit);
                set(handles.cmd_submitoptions,'string',profiles{iprofile}.cmd_submitoptions);
                set(handles.cmd_deletejob,'string',profiles{iprofile}.cmd_deletejob);
                set(handles.cmd_checkstatus,'string',profiles{iprofile}.cmd_checkstatus);
                set(handles.isdefault,'value',iprofile==default);
                set(handles.cmd_submitoptions,'tooltipstring',['<HTML>Additional submit options (optional OPTS field in command above)<br/>Use this to override your system default walltime settings, request specific resources, specify the submission queue, etc.<br/> - Enter <i>SCRIPT</i> to indicate the name of the script to be submitted/executed<br/> - Enter <i>JOBLABEL</i> to indicate a job name (autogenerated for each node)/label<br/> - Enter <i>JOBID</i> to indicate a job identifier (output of submit command)<br/> - Enter <i>STDOUT</i> to indicate the file where the stdout stream should be stored<br/> - Enter <i>STDERR</i> to indicate the file where the stderr stream should be stored<br/> - Example: "',profiles{iprofile}.cmd_submitoptions_example,'"</HTML>']);
                if numel(profiles)>1, set(handles.delete,'enable','on'); else set(handles.delete,'enable','off'); end
            case 'profile',
                iprofile=get(handles.profiles,'value');
                conn_jobmanager_settings_update('refresh');
            case 'edit',
                profiles{iprofile}.name=get(handles.name,'string');
                profiles{iprofile}.cmd_submit=get(handles.cmd_submit,'string');
                profiles{iprofile}.cmd_submitoptions=get(handles.cmd_submitoptions,'string');
                profiles{iprofile}.cmd_deletejob=get(handles.cmd_deletejob,'string');
                profiles{iprofile}.cmd_checkstatus=get(handles.cmd_checkstatus,'string');
                if get(handles.isdefault,'value'), default=iprofile; end
                conn_jobmanager_settings_update('refresh');
            case 'new'
                profiles=[profiles profiles(iprofile)];
                iprofile=numel(profiles);
                profiles{iprofile}.name=[profiles{iprofile}.name ' (copy)'];
                conn_jobmanager_settings_update('refresh');
            case 'delete'
                if numel(profiles)>1
                    answ=questdlg(sprintf('Delete profile %s?',profiles{iprofile}.name),'Warning','Yes','No','Yes');
                    if ~isequal(answ,'Yes'), return; end
                    profiles=profiles(setdiff(1:numel(profiles),iprofile));
                    if default>iprofile, default=default-1; end
                    iprofile=max(1,min(numel(profiles),iprofile));
                    conn_jobmanager_settings_update('refresh');
                end
            case 'test'
                conn_jobmanager('options','profile',iprofile);
                for n=reshape(fieldnames(profiles{iprofile}),1,[])
                    conn_jobmanager('options',n{1},profiles{iprofile}.(n{1}));
                end
                info=conn_jobmanager('submit',[],2); 
                info=conn_jobmanager(info,'Testing. Please wait...','donotupdate');
                if all(strcmp(info.tagmsg,'finished')), 
                    conn_msgbox('Test finished correctly','',true);
                else
                    conn_msgbox('Test did NOT finish correctly','ERROR!',true);
                end
            case 'save'
                if isdeployed, filename=fullfile(matlabroot,'conn_jobmanager.mat');
                else filename=fullfile(fileparts(which(mfilename)),'conn_jobmanager.mat');
                end
                try
                    save(filename,'profiles','default');
                    conn_msgbox({sprintf('Parallelization profiles saved to %s',filename),'Changes will apply to current and future Matlab sessions'},'',true);
                catch
                    conn_msgbox({sprintf('Unable to save file %s. Check permissions and try again',filename),'Changes will only apply to the current Matlab session'},'',true);
                end
        end
    end
end



function [info,ok]=conn_jobmanager_gui(info,files,filedates,varargin)
ok=0;
donotupdate=nargin>3&&any(strcmpi(varargin,'donotupdate'));
varargin=varargin(~strcmpi(varargin,'donotupdate')); 
nogui=nargin>3&&any(strcmpi(varargin,'nogui'));
varargin=varargin(~strcmpi(varargin,'nogui')); 
if nogui, visible='off'; else visible='on'; end
handles.hfig=figure('units','norm','position',[.3 .3 .4 .6],'name',sprintf('job manager (%s)',conn_jobmanager('getprofile')),'numbertitle','off','menubar','none','color','w','visible',visible,'handlevisibility','callback');
if numel(files)>0,
    uicontrol(handles.hfig,'style','text','units','norm','position',[.0 .95 .1 .05],'string','Jobs:  ','backgroundcolor','w','horizontalalignment','right');
    handles.files=uicontrol(handles.hfig,'style','popupmenu','units','norm','position',[.1 .95 .9 .05],'string',filedates,'value',numel(files),'callback',@(varargin)conn_jobmanager_update('updatefile'));
else
    handles.files=[];
end

if ~isempty(varargin), uicontrol(handles.hfig,'style','text','units','norm','position',[.2,.9,.6,.04],'string',varargin{1},'backgroundcolor','w','foregroundcolor','k'); end
handles.axes=axes('units','norm','position',[.2 .85 .6 .05],'parent',handles.hfig);
handles.img=image(shiftdim([1 1 1],-1),'parent',handles.axes);
set(handles.axes,'visible','off');
hold(handles.axes,'on');
handles.txt=text(.5,1,'','horizontalalignment','center','color','w','parent',handles.axes);
hold(handles.axes,'off');
handles.stopall=uicontrol(handles.hfig,'style','pushbutton','units','norm','position',[.4,.775,.2,.05],'string','Cancel job','callback',@(varargin)conn_jobmanager_update('stopall'),'tooltipstring','Stop all nodes and delete this job pipeline');
handles.enable=uicontrol(handles.hfig,'style','checkbox','value',1,'units','norm','position',[.7,.775,.3,.05],'string','Advanced options','backgroundcolor','w','callback',@(varargin)conn_jobmanager_update('enable'));
handles.panel=uipanel(handles.hfig,'units','norm','position',[0 0 1 .7],'backgroundcolor',.9*[1 1 1]);
%txt=sprintf('<HTML>%-13s<b>%-13s</b>%-1000s</HTML>','node','status','job id');
handles.order(1)=uicontrol(handles.panel,'style','pushbutton','units','norm','position',[.1,.90,.7,.05],'string','node','userdata',1,'foregroundcolor','k','fontname','monospaced','horizontalalignment','left','callback',@(varargin)conn_jobmanager_update('order',1));
if ~nogui, set(handles.order(1),'units','characters'); temp=get(handles.order(1),'position'); set(handles.order(1),'position',[temp(1:2) 13 max(1,temp(4))],'units','norm'); end
handles.order(2)=uicontrol(handles.panel,'style','pushbutton','units','norm','position',[.1,.90,.7,.05],'string','status','userdata',0,'foregroundcolor','k','fontname','monospaced','horizontalalignment','left','callback',@(varargin)conn_jobmanager_update('order',2));
if ~nogui, set(handles.order(2),'units','characters'); temp=get(handles.order(2),'position'); set(handles.order(2),'position',[temp(1)+13 temp(2) 13 max(1,temp(4))],'units','norm'); end
handles.order(3)=uicontrol(handles.panel,'style','pushbutton','units','norm','position',[.1,.90,.7,.05],'string','job id','userdata',0,'foregroundcolor','k','fontname','monospaced','horizontalalignment','left','callback',@(varargin)conn_jobmanager_update('order',3));
if ~nogui, set(handles.order(3),'units','characters'); temp=get(handles.order(3),'position'); set(handles.order(3),'position',[temp(1)+2*13 temp(2) temp(3)-2*13 max(1,temp(4))],'units','norm'); end
handles.jobs=uicontrol(handles.panel,'style','listbox','units','norm','position',[.1,.15,.7,.75],'string','','max',2,'backgroundcolor',.9*[1 1 1],'foregroundcolor','k','fontname','monospaced');
handles.refresh=uicontrol(handles.panel,'style','pushbutton','units','norm','position',[.825,.825,.15,.075],'string','Refresh','callback',@(varargin)conn_jobmanager_update('refresh',true),'tooltipstring','Refreshes node''s status information');
handles.details=uicontrol(handles.panel,'style','pushbutton','units','norm','position',[.825,.75,.15,.075],'string','See logs','callback',@(varargin)conn_jobmanager_update('details'),'tooltipstring','See selected node(s) log files');
handles.stop=uicontrol(handles.panel,'style','pushbutton','units','norm','position',[.825,.65,.15,.075],'string','Stop','callback',@(varargin)conn_jobmanager_update('stop'),'tooltipstring','Stop selected node(s)');
handles.restart=uicontrol(handles.panel,'style','pushbutton','units','norm','position',[.825,.575,.15,.075],'string','Restart','callback',@(varargin)conn_jobmanager_update('restart'),'tooltipstring','Restart selected node(s)');
fliporder=0;
order=[];

if ~numel(files)
    handles.continue=[];%handles.continue=uicontrol(handles.hfig,'style','pushbutton','units','norm','position',[.5,.025,.45,.05],'string','Continue (merge results now)','callback',@(varargin)conn_jobmanager_update('finish'));
    handles.cancel=uicontrol(handles.panel,'style','pushbutton','units','norm','position',[.425,.025,.15,.075],'string','Exit','callback','close(gcbf)','tooltipstring','<HTML>Exit this window <br/> - processes will continue running<br/> - visit Tools.ClusterLogs to see this job progress <br/> - when finished re-load your project to merge the results</HTML>');
    %set(handles.continue,'enable','off','visible','off');
    handles.timer=timer('name','jobmanager','period',1,'executionmode','fixedspacing','taskstoexecute',inf,'busymode','drop','timerfcn',@(varargin)conn_jobmanager_update('refresh'));
    set(handles.hfig,'closerequestfcn',@(varargin)conn_jobmanager_update('end'));
    set(handles.enable,'value',0); conn_jobmanager_update('enable');
    handles.finished=false;
    start(handles.timer);
    if nogui, 
        warning('off','MATLAB:hg:NoDisplayNoFigureSupportSeeReleaseNotes');
        fprintf('Waiting for grid/cluster jobs to finish...\n');
    end
    uiwait(handles.hfig);
    if nogui, warning('on','MATLAB:hg:NoDisplayNoFigureSupportSeeReleaseNotes'); end
else
    handles.continue=[];
    handles.cancel=[];
    handles.timer=[];
    handles.finished=false;
    set([handles.enable],'visible','off');
    conn_jobmanager_update('refresh');
end
ok=1+handles.finished;

    function conn_jobmanager_update(option,varargin)
        switch(option)
            case 'updatefile'
                n=get(handles.files,'value');
                data=load(files{n},'info');
                info=data.info;
                conn_jobmanager_update('refresh');
                
            case 'refresh'
                try
                    if nargin==1||varargin{1}==1, info=conn_jobmanager('statusjob',info,[],varargin{:}); end
                    txt=cellfun(@(a,b,c)sprintf('%-13s%-13s%-32s',a(1:min(numel(a),9)),b(1:min(numel(b),12)),c(1:min(numel(c),32))),info.joblabel,info.tagmsg,info.statusmsg,'uni',0);
                    
                    sortedlabels={'finished','finishing','running','submitted','stopping','stopped','error','failed','crashed'};
                    [nill,st]=ismember(info.tagmsg,sortedlabels);
                    if get(handles.order(2),'userdata'), [nill,order]=sort(st);
                    elseif get(handles.order(3),'userdata'), [nill,order]=sort(info.statusmsg);
                    else order=1:numel(st); 
                    end
                    if fliporder, order=order(end:-1:1); end
                    set(handles.jobs,'string',txt(order));
                    set(handles.img,'cdata',ind2rgb(1+sort(st),[0 0 0;linspace(0,1,6)'*[5/6,2/6,1.5/6]+linspace(1,0,6)'*[1.5/6,5/6,2/6];1 0 0;1 0 0;1 0 0]));
                    nl=accumarray(reshape(st(st>0),[],1),1,[numel(sortedlabels),1])';
                    txt=cellfun(@(a,b)sprintf(' %s (%d) ',a,b),reshape(sortedlabels(nl>0),1,[]),num2cell(reshape(nl(nl>0),1,[])),'uni',0);
                    set(handles.txt,'position',[1+(numel(st)-1)/2,1,1],'string',sprintf( '%s',txt{:}));
                    set(handles.axes,'xlim',[.5 numel(st)+.5001],'ylim',[.5 1.5]);
                    
                    validlabels={'finished'}; %{'finished','stopped'};
                    if all(ismember(info.tagmsg,validlabels))
                        set(handles.continue,'enable','on'); 
                        if ~numel(files)&&~handles.finished, conn_jobmanager_update('finish'); end
                    end
%                 catch
%                     fprintf('.');
                end
                
            case 'details'
                clear h;
                thisjob=get(handles.jobs,'value');
                thisjob=find(order==thisjob);
                if isempty(thisjob), thisjob=1;
                else thisjob=thisjob(1);
                end
                tfiles={info.stdout, info.stderr, info.stdlog, info.scripts};
                [nill,names]=cellfun(@fileparts,tfiles{1},'uni',0);
                names=regexp(names,'^.{9}','match','once');
                h.hfig=figure('units','norm','position',[.7 .3 .3 .6],'name','log details','numbertitle','off','menubar','none','color','w');
                h.files=uicontrol(h.hfig,'style','popupmenu','units','norm','position',[.1 .95 .9 .05],'string',names,'value',thisjob,'callback','uiresume(gcbf)');
                h.types=uicontrol(h.hfig,'style','popupmenu','units','norm','position',[.1 .90 .9 .05],'string',{'console output (stdout)','error output (stderr)','Matlab log','submition script','submition message','status message'},'value',1,'callback','uiresume(gcbf)');
                h.str=uicontrol(h.hfig,'style','listbox','units','norm','position',[.05 .1 .9 .75],'string','','max',2,'horizontalalignment','left','fontname','monospace');
                h.refresh=uicontrol(h.hfig,'style','pushbutton','units','norm','position',[.25 .025 .5 .05],'string','refresh','callback','uiresume(gcbf)');
                while ishandle(h.hfig)
                    i=get(h.files,'value');
                    j=get(h.types,'value');
                    switch(j)
                        case {1,2,3,4},
                            fh=fopen(tfiles{j}{i},'rt');
                            if ~isequal(fh,-1)
                                str=fread(fh,inf,'uchar');
                                fclose(fh);
                                str=char(str(:)');
                                b=find(diff([0 str==8 0]));
                                for n=1:2:numel(b)-1,
                                    str(max(1,b(n)-(b(n+1)-b(n))):b(n+1)-1)=0;
                                end
                                str=str(str~=0);
                                str=regexp(str,'\n','split');
                            else str={' '};
                            end
                        case 5,
                            if isfield(info,'submitmsg')&&numel(info.submitmsg)>=i, str=regexp(info.submitmsg{i},'\n','split');
                            else str={' '};
                            end
                        case 6,
                            if isfield(info,'statemsg')&&numel(info.statemsg)>=i, str=regexp(info.statemsg{i},'\n','split');
                            else str={' '};
                            end
                    end
                    set(h.str,'string',str,'value',numel(str),'listboxtop',numel(str));
                    uiwait(h.hfig);
                end
                
            case 'order',
                n=varargin{1};
                if get(handles.order(n),'userdata'), fliporder=~fliporder; end
                set(handles.order,'userdata',0);
                set(handles.order(n),'userdata',1);
                conn_jobmanager_update('refresh',false);
                
            case 'stopall'
                handles.finished=true;
                set(handles.stopall,'string','Canceling...');
                conn_jobmanager('deletejob',info);
                conn_jobmanager('clearqlog',info);
                if ~donotupdate
                    filename=regexprep(info.private{1}(1).project,'\?.*$','');
                    conn('load',filename);
                    conn save;
                end
                set(handles.stopall,'string','Cancel jobs');
                close(handles.hfig);
                
            case 'stop'
                n=get(handles.jobs,'value');
                n=find(order==n);
                conn_jobmanager('deletejob',info,n);
                conn_jobmanager_update('refresh');
                
            case 'restart'
                n=get(handles.jobs,'value');
                n=find(order==n);
                conn_jobmanager('submitjob',info,n);
                handles.finished=false;
                conn_jobmanager_update('refresh');
                
            case 'finish'
                handles.finished=true;
                set(handles.stopall,'string','Finished','callback','close(gcbf)','tooltipstring','Close this window');
                if ~donotupdate
                    filename=regexprep(info.private{1}(1).project,'\?.*$','');
                    conn('load',filename);
                    conn save;
                end
                if ~get(handles.enable,'value'), close(handles.hfig); end
                
            case 'exit'
                close(handles.hfig);
                
            case 'enable',
                st=get(handles.enable,'value');
                vl={'off','on'};
                set([handles.refresh, handles.details, handles.stop, handles.restart, handles.continue, handles.cancel],'visible',vl{1+st});
                
            case 'end'
                stop(handles.timer);
                delete(handles.timer);
                delete(handles.hfig);
        end
    end
end



