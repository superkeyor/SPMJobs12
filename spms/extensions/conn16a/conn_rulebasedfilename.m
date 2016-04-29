function [filename,ok]=conn_rulebasedfilename(filename,option,rule,filenamestotest)
% CONN_RULEDBASEDFILENAME
% rule-based definition of functional data filenames
%

global CONN_gui;
default_rule={{1,'^s',''},{1,'^s?w',''},{1,'.*','s$0'},{1,'.*','sw$0'},{2,'func_smoothed','func_normalized'}}; % same as functional without leading 's' character (SPM convention for unsmoothed volume filenames)
if nargin<3||isempty(rule), rule=default_rule{1}; 
elseif ~iscell(rule), rule=default_rule{rule}; 
end
if nargin<4, filenamestotest=[]; end
if ~isfield(CONN_gui,'font_offset'), CONN_gui.font_offset=0; end
if ~nargin
    global CONN_x;
    filename=CONN_x.Setup.functional{1}{1}{1};
    [rule,ok]=conn_rulebasedfilename(filename,0,[],CONN_x.Setup.functional);
    filename={};
    if isequal(ok,true)
        answ=questdlg('Change functional file sources to new values?','','Yes','No','No');
        if isequal(answ,'Yes')
            for nsub=1:CONN_x.Setup.nsubjects
                nsess=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub));
                for nses=1:nsess
                    Vsource=CONN_x.Setup.functional{nsub}{nses}{1};
                    Vsource1=cellstr(Vsource);
                    Vsource2=conn_rulebasedfilename(Vsource1,3,rule);
                    CONN_x.Setup.functional{nsub}{nses}=conn_file(char(Vsource2));
                    filename{nsub}{nses}=char(Vsource2);
                end
            end
        end
    end
    return
end

switch option
    case 0, % gui edit rules
        if ischar(filename), filename=cellstr(filename); end
        ok=nan;
        filename=filename{1};
        hfig=figure('units','norm','position',[.1,.3,.4,.4],'numbertitle','off','name','Define programmatic filename rule','menubar','none','color','w');
        uicontrol('units','norm','position',[.05,.8,.25,.1],'style','text','string','Look in:','backgroundcolor','w','horizontalalignment','left','fontweight','bold','fontsize',8+CONN_gui.font_offset);
        hm1=uicontrol('units','norm','position',[.05,.7,.25,.1],'style','popupmenu','string',{'file name','absolute path name'},'value',rule{1},'fontsize',8+CONN_gui.font_offset);
        uicontrol('units','norm','position',[.35,.8,.25,.1],'style','text','string','Find string(s):','backgroundcolor','w','horizontalalignment','left','fontweight','bold','fontsize',8+CONN_gui.font_offset);
        hm2=uicontrol('units','norm','position',[.35,.7,.25,.1],'style','edit','string',rule{2},'fontsize',8+CONN_gui.font_offset,'max',2,'tooltipstring','Search-string patterns (regexp-style, * for 0 or more occurrences; + for 1 or more occurrences; . for any character; ^ for beginning of string; $ for end of string; see HELP regexp for advanced options)');
        uicontrol('units','norm','position',[.65,.8,.25,.1],'style','text','string','Replace with string(s):','backgroundcolor','w','horizontalalignment','left','fontweight','bold','fontsize',8+CONN_gui.font_offset);
        hm3=uicontrol('units','norm','position',[.65,.7,.25,.1],'style','edit','string',rule{3},'fontsize',8+CONN_gui.font_offset,'max',2,'tooltipstring','Replacement-string patterns (see HELP regexp for advanced options)');
        hm6=uicontrol('units','norm','position',[.05,.55,.9,.1],'style','popupmenu','string',{'<HTML><i>example suggestions</i></HTML>','remove leading ''s'' (SPM convention for unsmoothed volumes)','remove leading ''sw'' (SPM convention for subject-space unsmoothed volumes)','prepend ''s'' character (SPM convention for additionally-smoothed volumes)','prepend ''sw'' characters (SPM convention for additionally-normalized&smoothed volumes)','change folder'},'value',1,'fontsize',8+CONN_gui.font_offset);
        uicontrol('units','norm','position',[.05,.45,.9,.05],'style','text','string','Set-0 example input:','backgroundcolor','w','horizontalalignment','left','fontweight','bold','fontsize',8+CONN_gui.font_offset);
        hm4=uicontrol('units','norm','position',[.05,.35,.9,.1],'style','edit','string',filename,'backgroundcolor','w','horizontalalignment','left','fontsize',8+CONN_gui.font_offset);
        uicontrol('units','norm','position',[.05,.25,.9,.05],'style','text','string','Set-N example output:','backgroundcolor','w','horizontalalignment','left','fontweight','bold','fontsize',8+CONN_gui.font_offset);
        hm5=uicontrol('units','norm','position',[.05,.15,.9,.1],'style','text','string','','backgroundcolor','w','horizontalalignment','left','fontsize',8+CONN_gui.font_offset);
        uicontrol('style','pushbutton','string','OK','units','norm','position',[.26,.01,.34,.08],'callback','uiresume');
        uicontrol('style','pushbutton','string','Cancel','units','norm','position',[.63,.01,.34,.08],'callback','delete(gcbf)');
        set([hm6,hm1,hm2,hm3,hm4],'callback',@conn_rulebasedfilename_refresh);
        conn_rulebasedfilename_refresh;
        uiwait(hfig);
        
        if ishandle(hfig)
            rule={get(hm1,'value'),get(hm2,'string'),get(hm3,'string')};
            delete(hfig);
            if ~isempty(filenamestotest)
                answ=questdlg('Do you want to test this rule now on *all* functional filenames?','','Yes','No','No');
                if isequal(answ,'Yes')
                    ko=0;
                    for nsub=1:numel(filenamestotest)
                        for nses=1:numel(filenamestotest{nsub})
                            temp1=cellstr(filenamestotest{nsub}{nses}{1});
                            temp1=temp1{1};
                            temp2=conn_rulebasedfilename(temp1,3,rule);
                            fprintf('%s --> %s',temp1,temp2);
                            if conn_existfile(temp2)
                                fprintf('   ... Ok (file exists)\n');
                            else
                                fprintf('\nWARNING!!!. File %s not found\n',temp2);
                                ko=ko+1;
                            end
                        end
                    end
                    if ko, ok=false; conn_msgbox({sprintf('Filename convention results in several incorrect/non-existing filenames (%d)',ko),' See the command window for a full list, and modify the filename-rule if appropriate'},'ERROR!',true);
                    else   ok=true; conn_msgbox('Filename convention results in correct/existing filenames. See the command window for a full list','',true);
                    end
                end
            end
            filename=rule;
        else
            filename=0;
        end
        
    case 1, % same as functional data files (do nothing)
        
    case 2, % use default programmatic rule
        filename=conn_rulebasedfilename(filename,3,{});
        
    case 3, % use user-defined programmatic rule
        waschar=false;
        if ischar(filename), waschar=true; filename=cellstr(filename); end
        if rule{1}==1,[file_path,filename,file_ext,file_num]=cellfun(@spm_fileparts,filename,'uni',0); end
        filename=regexprep(strtrim(filename),cellstr(rule{2}),cellstr(rule{3}));
        if rule{1}==1,filename=cellfun(@(a,b,c,d)fullfile(a,[b,c,d]),file_path,filename,file_ext,file_num,'uni',0); end
        if waschar, filename=char(filename); end
end

    function conn_rulebasedfilename_refresh(varargin)
        if get(hm6,'value')>1
            value=default_rule{get(hm6,'value')-1};
            set(hm1,'value',value{1});
            set(hm2,'string',value{2});
            set(hm3,'string',value{3});
            set(hm6,'value',1);
        end
        try
            set(hm5,'string',conn_rulebasedfilename(get(hm4,'string'),3,{get(hm1,'value'),get(hm2,'string'),get(hm3,'string')}),'foregroundcolor','k');
        catch me
            set(hm5,'string',['-- error evaluating find/replace expression --- ' me.message],'foregroundcolor','r');
        end
    end
end
