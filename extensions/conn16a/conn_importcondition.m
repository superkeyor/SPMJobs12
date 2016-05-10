function out=conn_importcondition(filename,varargin)
% CONN_IMPORTCONDITION import condition onsets/durations from file
% file format: .csv file (comma-separated fields) with one header line, and five columns: condition_name, subject_number, session_number, onsets, durations
%
% Example syntax:
% conn_importcondition('myfile.csv');
%
% Example file contents (myfile.csv):
%   condition_name, subject_number, session_number, onsets, durations
%   task, 1, 1, 0 50 100 150, 25
%   task, 2, 1, 0 50 100 150, 25
%   rest, 1, 1, 25 75 125 175, 25
%   rest, 2, 1, 25 75 125 175, 25
%
% note: leaving the subject_number or session_number empty in a row
% indicates all subjects or all sessions: e.g.
%   condition_name, subject_number, session_number, onsets, durations
%   task, , , 0 50 100 150, 25
%   rest, , , 25 75 125 175, 25
%
 
global CONN_x;

options=struct('breakconditionsbysession',false);
for n1=1:2:nargin-1, if ~isfield(options,lower(varargin{n1})), error('unknown option %s',lower(varargin{n1})); else options.(lower(varargin{n1}))=varargin{n1+1}; end; end

% read text data
if ~nargin||isempty(filename),
    [tfilename,tpathname]=uigetfile({'*.txt','text files (*.txt)'; '*.csv','CSV-files (*.csv)'; '*',  'All Files (*)'},'Select data file');
    if ~ischar(tfilename)||isempty(tfilename), return; end
    filename=fullfile(tpathname,tfilename);
end
[conditions,nsubs,nsess,onsets,durations]=textread(filename, '%s%d%d%s%s','delimiter',',','headerlines',1);
[names,nill,nconds]=unique(conditions);

% fills-in condition info
if any(nsubs>CONN_x.Setup.nsubjects), error('Subject number in file exceeds number of subjects in current CONN project'); end
for nsub=1:max(nsubs)
    if any(nsess>CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsub))), error('Session number in file exceeds number of sessions (subject %d)',nsub); end
end
for nsub=1:CONN_x.Setup.nsubjects
    for nses=1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsub))
        for ncond=1:max(nconds),
            data=find((nsubs==0|nsubs==nsub)&(nsess==0|nsess==nses)&nconds==ncond);
            if ~isempty(data)
                name=names{ncond};
                if numel(data)>1, error('multiple rows for condition %s subject %d session %d',name,nsub,nses); end
                if options.breakconditionsbysession, name=sprintf('%s_Session%d',name,nses); end
                idx=strmatch(name,CONN_x.Setup.conditions.names,'exact');
                if isempty(idx),
                    idx=length(CONN_x.Setup.conditions.names);
                    CONN_x.Setup.conditions.names{end+1}=' ';
                end
                CONN_x.Setup.conditions.param(idx)=0;
                CONN_x.Setup.conditions.filter{idx}=[];
                CONN_x.Setup.conditions.names{idx}=name;
                t1=str2num(onsets{data}); if isempty(t1)&&~isempty(deblank(t1)), error('incorrect syntax in onset field %s (condition %s, subject %d, session %d)',onsets{data}, name, nsub, nses); end
                CONN_x.Setup.conditions.values{nsub}{idx}{nses}{1}=t1;
                t1=str2num(durations{data}); if isempty(t1)&&~isempty(deblank(t1)), error('incorrect syntax in duration field %s (condition %s, subject %d, session %d)',onsets{data}, name, nsub, nses); end
                CONN_x.Setup.conditions.values{nsub}{idx}{nses}{2}=t1;
            end
        end
    end
end

% fills possible empty conditions for each subject/session
for nsub=1:CONN_x.Setup.nsubjects,
    for ncondition=1:length(CONN_x.Setup.conditions.names)-1
        for nses=1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsub))
            if numel(CONN_x.Setup.conditions.values{nsub})<ncondition||numel(CONN_x.Setup.conditions.values{nsub}{ncondition})<nses||numel(CONN_x.Setup.conditions.values{nsub}{ncondition}{nses})<1,
                CONN_x.Setup.conditions.values{nsub}{ncondition}{nses}{1}=[];
            end
            if numel(CONN_x.Setup.conditions.values{nsub})<ncondition||numel(CONN_x.Setup.conditions.values{nsub}{ncondition})<nses||numel(CONN_x.Setup.conditions.values{nsub}{ncondition}{nses})<2,
                CONN_x.Setup.conditions.values{nsub}{ncondition}{nses}{2}=[];
            end
        end
    end
end
if isfield(CONN_x,'gui')&&isnumeric(CONN_x.gui)&&CONN_x.gui, 
    conn_msgbox([num2str(numel(names)),' conditions imported with no errors'],'Done',1);
end
if nargout,out=CONN_x;end
end
