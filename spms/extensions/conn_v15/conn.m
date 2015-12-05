function varargout=conn(varargin)
% CONN functional connectivity toolbox
% Developed by 
%  The Gabrieli Lab at MIT
%  McGovern Institute for Brain Research
%
% From Matlab command-line (or system prompt in standalone installations) typing:
%
% conn    
%   launches conn GUI 
%
% conn batch filename
%   executes batch file (.m or .mat file)
%   see also CONN_BATCH
%
% http://www.nitrc.org/projects/conn
% alfnie@gmail.com
%

connver='15.g';
dodebug=false;

global CONN_h CONN_x CONN_gui;
if dodebug, dbstop if caught error; end
me=[]; 
try 
if nargin<1,
    connversion={'CONN functional connectivity toolbox',' (',connver,') '};
    hfig=findobj('tag',connversion{1});
    if ~isempty(hfig),figure(hfig); return;end
    try, warning('off','MATLAB:hg:patch:RGBColorDataNotSupported'); 
         warning('off','MATLAB:load:variableNotFound');
         warning('off','MATLAB:DELETE:FileNotFound');
    end
    conn_backgroundcolor=[.03 .12 .2];                % backgroundcolor
    if ismac, CONN_gui.uicontrol_border=2;            % crops borders GUI elements
    else      CONN_gui.uicontrol_border=2;
    end
    CONN_gui.uicontrol_borderpopup=22;
    CONN_gui.doemphasis1=false;                       % removes border-cropping when hovering over each element
    CONN_gui.doemphasis2=true;                        % changes fontcolor when hovering over each element
    
    conn_font_offset=0;                               % font size offset
    conn_font_init=true;
    conn_background=[];
    conn_tooltips=true;                               % enable tool-tips when hovering over each element
    conn_domacGUIbugfix=ismac;                        % troubleshoot popupmenu behavior 
    conn_dounixGUIbugfix=true;
    conn_checkupdates=false;

    try
        filename0='conn_font_default.dat';
        [nill,username]=system('whoami'); if ~isequal(nill,0), username='unknown'; end
        if isdeployed, userpath=matlabroot;
        else userpath=fileparts(which(mfilename));
        end
        filename=sprintf('conn_font_default_%s.dat',char('0'+mod(cumsum(double(username)),10)));
        if ~isempty(dir(fullfile(pwd,filename))), load('-mat',fullfile(pwd,filename),'conn_font_offset','conn_backgroundcolor','conn_background','conn_tooltips','conn_domacGUIbugfix','conn_dounixGUIbugfix','conn_checkupdates'); conn_font_init=false;
        elseif ~isempty(dir(fullfile(userpath,filename))), load('-mat',fullfile(fileparts(which(mfilename)),filename),'conn_font_offset','conn_backgroundcolor','conn_background','conn_tooltips','conn_domacGUIbugfix','conn_dounixGUIbugfix','conn_checkupdates'); conn_font_init=false;
        elseif ~isempty(dir(fullfile(pwd,filename0))), load('-mat',fullfile(pwd,filename0),'conn_font_offset','conn_backgroundcolor','conn_background','conn_tooltips','conn_domacGUIbugfix','conn_dounixGUIbugfix','conn_checkupdates'); conn_font_init=false;
        elseif ~isempty(dir(fullfile(userpath,filename0))), load('-mat',fullfile(fileparts(which(mfilename)),filename0),'conn_font_offset','conn_backgroundcolor','conn_background','conn_tooltips','conn_domacGUIbugfix','conn_dounixGUIbugfix','conn_checkupdates'); conn_font_init=false;
        end
    end
    CONN_gui.font_offset=conn_font_offset; 
    CONN_gui.tooltips=conn_tooltips;
    CONN_gui.domacGUIbugfix=conn_domacGUIbugfix;
    CONN_gui.dounixGUIbugfix=conn_dounixGUIbugfix;
    CONN_gui.checkupdates=conn_checkupdates;
    CONN_gui.background=conn_background;
    CONN_gui.backgroundcolor=conn_backgroundcolor; 
    CONN_gui.backgroundcolorA=max(0,min(1,CONN_gui.backgroundcolor+0*.025));
    CONN_gui.backgroundcolorB=max(0,min(1,CONN_gui.backgroundcolor-0*sign(mean(CONN_gui.backgroundcolor)-.5)*.025+0*CONN_gui.domacGUIbugfix));
    CONN_gui.fontcolorA=[.10 .10 .10]+.8*(mean(CONN_gui.backgroundcolor)<.5);
    CONN_gui.fontcolorB=[.4 .4 .4]+.2*(mean(CONN_gui.backgroundcolor)<.5);
    CONN_gui.status=0;
    if ismac, CONN_gui.rightclick='ctrl'; else CONN_gui.rightclick='right'; end
	CONN_h=struct;
    cmap=.25+.75*(6*gray(128) + 2*(hot(128)))/8; if mean(CONN_gui.backgroundcolor)>.5,cmap=flipud(cmap); end
    CONN_h.screen.colormap=max(0,min(1, diag((1-linspace(1,0,256)'.^50))*[cmap;jet(128)]+(linspace(1,0,256)'.^50)*CONN_gui.backgroundcolorA ));
    h0=get(0,'screensize'); h0=h0(1,3:4)-h0(1,1:2)+1; h0=h0/max(1,max(abs(h0))/2000);
    %if any(h0(3:4)<[1200 700]), fprintf('Increase resolution size for optimal viewing\n(screen resolution %dx%d; minimum recommended %dx%d\n)',h0(3),h0(4),1200,700); end
    minheight=500;
    tname=strcat(connversion{:});
    if isdeployed, tname=strcat(tname,' (standalone)'); end
	CONN_h.screen.hfig=figure('units','pixels','position',[0*72+1,h0(2)-max(minheight,.4*h0(1))-48,h0(1)-0*72-1,max(minheight,.4*h0(1))],'color',CONN_gui.backgroundcolor,'doublebuffer','on','tag',connversion{1},'name',tname,'numbertitle','off','menubar','none','resize','on','colormap',CONN_h.screen.colormap,'closerequestfcn',@conn_closerequestfcn,'deletefcn',@conn_deletefcn,'resizefcn',@conn_resizefcn,'interruptible','off');
    conn_menuframe;
    uicontrol('style','text','units','norm','position',[0 .2 .6 .5],'string',['CONN '],'fontunits','norm','fontsize',.4,'horizontalalignment','right','foregroundcolor',[0 0 0]+(mean(CONN_gui.backgroundcolor)<.5),'backgroundcolor',CONN_gui.backgroundcolor);
    uicontrol('style','text','units','norm','position',[.6 .2 .4 .5],'string',['(',connver,')'],'fontunits','norm','fontsize',.1,'horizontalalignment','left','foregroundcolor',[0 0 0]+(mean(CONN_gui.backgroundcolor)<.5),'backgroundcolor',CONN_gui.backgroundcolor);
    %uicontrol('style','text','units','norm','position',[0 .2 1 .5],'string',['CONN ',connver],'fontunits','norm','fontsize',.3,'horizontalalignment','center','foregroundcolor',[0 0 0]+(mean(CONN_gui.backgroundcolor)<.5),'backgroundcolor',CONN_gui.backgroundcolor);
    axes('units','norm','position',[0 0 1 1]);
    h=text(0,-2,'Initializing. Please wait','fontunits','norm','fontsize',1/48,'horizontalalignment','center','verticalalignment','bottom','color',.75*[1 1 1]);
    set(gca,'units','norm','position',[0 0 1 1],'xlim',[-2 2],'ylim',[-2.5 2]); axis off;
    if conn_font_init,
        drawnow;
        set(h,'fontunits','points');
        tfontsize=get(h,'fontsize');
        conn_font_offset=max(-4,round(tfontsize)-8);
        %fprintf('Font size change %dpts to %dpts (%f %s)\n',8+CONN_gui.font_offset,8+conn_font_offset,tfontsize,mat2str([get(0,'screensize') get(gca,'position')]));
        CONN_gui.font_offset=conn_font_offset;
    end
    drawnow;
    set(0,{'defaultuicontrolfontsize','defaulttextfontsize','defaultaxesfontsize'},repmat({8+CONN_gui.font_offset},1,3));
    if iscell(CONN_gui.background), conn_guibackground settrans; end
    conn init;
    conn importrois;
    CONN_x.gui=1;
    if CONN_gui.checkupdates&&~isdeployed, if conn_update([],[],true); return; end; end
	conn_menumanager on;
	CONN_h.menus.m_setup_02sub=conn_menumanager([], 'n',8,...
									'string',{'Basic','Structural','Functional','ROIs','Conditions','Covariates 1st-level','Covariates 2nd-level','Options'},...
									'help',{'Defines basic acquisition information','Defines structural/anatomical data source files','Defines functional data source files','Defines regions of interest','Defines experiment conditions (e.g. rest, task, or longitudinal conditions)','Defines 1st level (within subject) variables (a timeseries for each subject/session; e.g. subject movement parameters)','Defines 2nd level (between subjects) variables (one value per subject; e.g. group membership)','Defines processing options'},...
									'position',[.135+0.5*.865/4-.135/2,.955-8*.045,.135,8*.045],...%'position',[.00,.42-.06,.095,7*.06],...
                                    'order','vertical',...
                                    'toggle',0,...
                                    'roll',1,...
									'fontsize',8,...
                                    'bordertype','square',...
									'callback',{{@conn,'gui_setupgo',1},{@conn,'gui_setupgo',2},{@conn,'gui_setupgo',3},{@conn,'gui_setupgo',4},{@conn,'gui_setupgo',5},{@conn,'gui_setupgo',6},{@conn,'gui_setupgo',7},{@conn,'gui_setupgo',8}} );
	CONN_h.menus.m_analyses_03sub=conn_menumanager([], 'n',3,...
									'string',{{'ROI-to-ROI','Seed-to-Voxel'},'Voxel-to-Voxel','Dynamic FC'},...
									'help',{'Define/explore ROI/seed sources for first-level analyses','Define/explore voxel-to-voxel measures for first-level analyses','Define options for Dynamic Connectivity analyses'},...
                                    'order','vertical',...
									'position',[.135+2.5*.865/4-.135/2,.955-4*.045,.135,4*.045],...%[.0,.68,.07,3*.05],...
                                    'toggle',0,...
                                    'roll',1,...
									'fontsize',8,...
                                    'bordertype','square',...
									'callback',{{@conn,'gui_analysesgo',1},{@conn,'gui_analysesgo',2},{@conn,'gui_analysesgo',3}} );
	CONN_h.menus.m_results_03sub=conn_menumanager([], 'n',4,...
									'string',{'ROI-to-ROI','Seed-to-Voxel','Voxel-to-Voxel','Dynamic FC'},...
									'help',{'Define/explore ROI-to-ROI second-level analyses','Define/explore seed-to-voxel second-level analyses','Define/explore voxel-to-voxel second-level analyses','Define/explore dynamic connectivity second-level analyses'},...
                                    'order','vertical',...
									'position',[.135+3.5*.865/4-.135/2,.955-4*.045,.135,4*.045],...%[.0,.68,.07,3*.05],...
                                    'toggle',0,...
                                    'roll',1,...
									'fontsize',8,...
                                    'bordertype','square',...
									'callback',{{@conn,'gui_resultsgo',1},{@conn,'gui_resultsgo',2},{@conn,'gui_resultsgo',3},{@conn,'gui_resultsgo',4}} );                               
	CONN_h.menus.m0=conn_menumanager([],	'n',4,...
									'string',{'Setup','Denoising','first-level Analyses','second-level Results'},...
									'help',{'Step 1/4: Define/Edit experiment setup','Step 2/4: Define/Edit denoising options','Step 3/4: Define/Edit first-level analysis options','Step 4/4: Define/Edit second-level analyses'},...
                                    'order','horizontal',...
									'state',[1,0,0,0],...
                                    'toggle',1,...
									'position',[.135,.955,.865,.045],...
                                    'bordertype','square',...
									'fontsize',8,...
									'callback',{CONN_h.menus.m_setup_02sub,{@conn,'gui_preproc'},CONN_h.menus.m_analyses_03sub,CONN_h.menus.m_results_03sub},...
									'callback2',{{@conn,'gui_setup'},{},{@conn,'gui_analyses'},{@conn,'gui_results'}} );
	CONN_h.menus.m_setup_07e=conn_menumanager([],	'n',4,...
									'string',{'SPM Preprocessing steps','CONN Processing steps','Batch script', 'Matlab command'},...
									'help',{'Run one or several preprocessing steps (e.g. realignment/normalization/etc.) (same as Preprocessing button in Setup tab)','Run one or several processing steps (e.g. Setup/Denoising/First-level) (same as Done button in Setup/Denoising/First-level tabs)','Run batch script (.m or .mat file)','Run individual Matlab commands'},...
                                    'order','vertical',...
                                    'toggle',0,...
                                    'roll',1,...
									'position',[.095,.955-3.5*.045-4*.045,.15,4*.045],...
									'fontsize',8,...
                                    'bordertype','square',...
									'callback',{{@conn,'gui_setup_preproc','multiplesteps',1},{@conn,'run_process',[]},{@conn,'run',[]},{@conn,'run_cmd',[]}} );
	CONN_h.menus.m_setup_07a=conn_menumanager([],	'n',6,...
									'string',{'GUI settings','Grid settings','Grid jobs','Run','Screenshot','Calculator'},...
									'help',{'Changes GUI display options','Defines distributed computer cluster/grid settings (for parallel computations)', 'Displays pending jobs in distributed computer cluster/grid','Run batch script or Matlab commands','Saves a screenshot of the GUI','Compute statistics of second-level covariates'},...
                                    'order','vertical',...
                                    'toggle',0,...
                                    'roll',1,...
									'position',[.045,.955-6*.045,.099,6*.045],...
									'fontsize',8,...
                                    'bordertype','square',...
									'callback',{{@conn,'gui_settings'},{@conn,'parallel_settings'},{@conn_jobmanager},CONN_h.menus.m_setup_07e,{@conn_print},{@conn,'gui_calculator'}} );
	CONN_h.menus.m_setup_07c=conn_menumanager([],	'n',3,...
									'string',{'CONN Manual','Info: Batch Processing', 'Info: Grid Computing'},...
									'help',{'Open CONN toolbox manual','See batch processing help','See Grid/Cluster computing help'},...
                                    'order','vertical',...
                                    'toggle',0,...
                                    'roll',1,...
									'position',[.14,.955-2.5*.045-3*.045,.15,3*.045],...
									'fontsize',8,...
                                    'bordertype','square',...
									'callback',{{@conn,'gui_help','doc'},{@conn,'gui_help','help','conn_batch.m'},{@conn,'gui_help','help','conn_grid.m'}} );
	CONN_h.menus.m_setup_07d=conn_menumanager([],	'n',6,...
									'string',{'Support','FAQ','Publications','CONN site','SPM site','Registration'},...
									'help',{'Search/ask for help at CONN support forum site (browse www.nitrc.org/forum/forum.php?forum_id=1144)','Browse www.nitrc.org/projects/conn','Browse www.alfnie.com/software/conn','Browse www.alfnie.com/software/conn/references','Browse www.fil.ion.ucl.ac.uk/spm','Register CONN toolbox software'},...
                                    'order','vertical',...
                                    'toggle',0,...
                                    'roll',1,...
									'position',[.14,.955-3.5*.045-6*.045,.099,6*.045],...
									'fontsize',8,...
                                    'bordertype','square',...
									'callback',{{@conn,'gui_help','url','http://www.nitrc.org/forum/forum.php?forum_id=1144'},{@conn,'gui_help','url','http://www.alfnie.com/software/conn'},{@conn,'gui_help','url','http://www.alfnie.com/software/conn/references'},{@conn,'gui_help','url','http://www.nitrc.org/projects/conn'},{@conn,'gui_help','url','http://www.fil.ion.ucl.ac.uk/spm'},{@conn_register,'forceregister'}} );
	CONN_h.menus.m_setup_07b=conn_menumanager([],	'n',4,...
									'string',{'Search','Updates','Documentation','Web'},...
									'help',{'Search on a database of support questions','Check for software updates','See specific help topcis',''},...
                                    'order','vertical',...
                                    'toggle',0,...
                                    'roll',1,...
									'position',[.09,.955-4*.045,.099,4*.045],...
									'fontsize',8,...
                                    'bordertype','square',...
									'callback',{{@conn_msghelp},{@conn_update,connver},CONN_h.menus.m_setup_07c,CONN_h.menus.m_setup_07d} );
	CONN_h.menus.m_setup_01a=conn_menumanager([], 'n',7,...
									'string',{'Load','Save','Save As','New (blank)','New (wizard)','Import','Merge'},...
									'help',{'Loads experiment information','Saves current experiment information','Saves current experiment to a different file','Starts a new empty experiment','Starts a new empty experiment and loads/preprocesses your data using a wizard','Imports experiment information from SPM.mat files','Merge other experiment files with the current experiment'},...
                                    'order','vertical',...
                                    'toggle',0,...
                                    'roll',1,...
									'position',[.0,.955-7*.045,.099,7*.045],...%[.09,.88-6*.05,.08,6*.05],...
									'fontsize',8,...
                                    'bordertype','square',...
									'callback',{{@conn,'gui_setup_load'},{@conn,'gui_setup_save'},{@conn,'gui_setup_saveas'},{@conn,'gui_setup_new'},{@conn,'gui_setup_wizard'},{@conn,'gui_setup_import'},{@conn,'gui_setup_merge'}} );
	CONN_h.menus.m_setup_06=conn_menumanager([],	'n',3,...
									'string',{'Project','Tools','Help'},...
									'help',{'','',''},...
                                    'order','horizontal',...
                                    'toggle',0,...
									'position',[.0,.955,3*.045,.045],...
									'fontsize',8,...
                                    'bordertype','square',...
									'callback',{CONN_h.menus.m_setup_01a,CONN_h.menus.m_setup_07a,CONN_h.menus.m_setup_07b} );
% 	CONN_h.menus.m_setup_01=conn_menumanager([], 'n',1,...
% 									'string',{'Project'},...
% 									'help',{''},...
%                                     'order','vertical',...
%                                     'toggle',0,...
% 									'position',[.0,.95,.045,.05],...
% 									'fontsize',8,...
%                                     'bordertype','square',...
% 									'callback',{CONN_h.menus.m_setup_01a} );
	CONN_h.menus.m_setup_01d=conn_menumanager([], 'n',2,...
									'string',{'Preprocessing','Done'},...
									'help',{'Define and apply a sequence of preprocessing steps to structural/functional volumes defined above (e.g. realignment, slice-timing correction, normalization, etc.)','Saves changes to Setup step and runs associated processing pipeline before proceeding to next step (Denoising)'},...
									'position',[0.01,0.01,.115,2*.05],...
                                    'toggle',0,...
									'fontsize',8,...
                                    'fontangle','normal',...
                                    'bordertype','round',...
									'callback',{{@conn,'gui_setup_preproc','multiplesteps',1},{@conn,'gui_setup_finish'}} );
% 	CONN_h.menus.m_setup_03=conn_menumanager([], 'n',2,...
% 									'string',{'1st level','2nd level'},...
% 									'help',{'Defines 1st level (within subject) variables (a timeseries for each subject/session; e.g. subject movement parameters)','Defines 2nd level (between subjects) variables (one value per subject; e.g. group membership)'},...
%                                     'toggle',1,...
% 									'position',[.11,.31,.08,2*.06],...
% 									'fontsize',8,...
%                                     'bordertype','square',...
% 									'callback',{{@conn,'gui_setup_covariates'},{@conn,'gui_setup_covariates'}} );
	CONN_h.menus.m_setup_02=conn_menumanager([], 'n',8,...
									'string',{'Basic','Structural','Functional','ROIs','Conditions','Covariates 1st-level','Covariates 2nd-level','Options'},...
									'help',{'Defines basic acquisition information','Defines structural/anatomical data source files','Defines functional data source files','Defines regions of interest','Defines experiment conditions (e.g. rest, task, or longitudinal conditions)','Defines 1st level (within subject) variables (a timeseries for each subject/session; e.g. subject movement parameters)','Defines 2nd level (between subjects) variables (one value per subject; e.g. group membership)','Defines processing options'},...
									'state',[1,0,0,0,0,0,0,0],...
									'value',1,...
                                    'toggle',1,...
									'position',[.00,.75-8*.06,.135,8*.06],...%'position',[.00,.42-.06,.095,7*.06],...
									'fontsize',8,...
                                    'bordertype','square',...
									'callback',{{@conn,'gui_setup'},{@conn,'gui_setup'},{@conn,'gui_setup'},{@conn,'gui_setup'},{@conn,'gui_setup'},{@conn,'gui_setup'},{@conn,'gui_setup'},{@conn,'gui_setup'}} );
	CONN_h.menus.m_setup_04=conn_menumanager([], 'n',1,...
									'string',{'Done'},...
									'help',{'Imports SPM.mat files and updates Setup information for each subject'},...
									'position',[0.01,0.01,.10,.05],...
                                    'toggle',0,...
									'fontsize',8,...
                                    'fontangle','normal',...
                                    'bordertype','round',...
									'callback',{{@conn,'gui_setup_importdone'}} );
	CONN_h.menus.m_setup_05=conn_menumanager([], 'n',1,...
									'string',{'Done'},...
									'help',{'When finished press ''Done'' to merge CONN_* files'},...
									'position',[0.01,0.01,.10,.05],...
                                    'toggle',0,...
									'fontsize',8,...
                                    'fontangle','normal',...
                                    'bordertype','round',...
									'callback',{{@conn,'gui_setup_mergedone'}} );
	CONN_h.menus.m_preproc_01=conn_menumanager([], 'n',1,...
									'string',{'>'},...
									'help',{''},...
                                    'toggle',0,...
									'position',[.128,.6,.02,.04],...
                                    'bordertype','round',...
									'backgroundcolor',CONN_gui.backgroundcolorA,...
									'callback',{{@conn,'gui_preproc',0}} );
	CONN_h.menus.m_preproc_02=conn_menumanager([], 'n',1,...
									'string',{'Done'},...
									'help',{'Saves changes to Denoising step and runs associated processing pipeline before proceeding to next step (First-level Analyses)'},...
									'position',[0.01,0.01,.10,.05],...
                                    'toggle',0,...
									'fontsize',8,...
                                    'fontangle','normal',...
                                    'bordertype','round',...
									'callback',{{@conn,'gui_preproc_done'}} );
	CONN_h.menus.m_analyses_01=conn_menumanager([], 'n',1,...
									'string',{'>'},...
									'help',{''},...
                                    'toggle',0,...
									'position',[.24,.55,.02,.04],...
                                    'bordertype','round',...
									'backgroundcolor',CONN_gui.backgroundcolorA,...
									'callback',{{@conn,'gui_analyses',0}} );
	CONN_h.menus.m_analyses_01b=conn_menumanager([], 'n',1,...
									'string',{'>'},...
									'help',{''},...
                                    'toggle',0,...
									'position',[.32,.55,.02,.04],...
                                    'bordertype','round',...
									'backgroundcolor',CONN_gui.backgroundcolorA,...
									'callback',{{@conn,'gui_analyses',0}} );
	CONN_h.menus.m_analyses_02=conn_menumanager([], 'n',1,...
									'string',{'Done'},...
									'help',{'Saves changes to current First-level analysis step and runs associated processing pipeline before proceeding to next step (Second-level Results)'},...
									'position',[0.01,0.01,.10,.05],...
                                    'toggle',0,...
									'fontsize',8,...
                                    'fontangle','normal',...
                                    'bordertype','round',...
									'callback',{{@conn,'gui_analyses_done'}} );
	CONN_h.menus.m_analyses_03=conn_menumanager([], 'n',3,...
									'string',{{'ROI-to-ROI','Seed-to-Voxel'},'Voxel-to-Voxel','Dynamic FC'},...
									'help',{'Define/explore ROI/seed sources for first-level analyses','Define/explore voxel-to-voxel measures for first-level analyses','Define options for Dynamic Connectivity analyses'},...
                                    'order','vertical',...
									'position',[.005,.50,.10,4*.06],...%[.0,.68,.07,3*.05],...
									'state',[1,0,0],...
									'value',1,...
                                    'toggle',1,...
									'fontsize',8,...
                                    'bordertype','square',...
									'callback',{{@conn,'gui_analyses'},{@conn,'gui_analyses'},{@conn,'gui_analyses'}} );
	CONN_h.menus.m_analyses_04=conn_menumanager([], 'n',1,...
									'string',{'Done'},...
									'help',{'Saves changes to First-level Voxel-to-Voxel analysis step and runs associated processing pipeline before proceeding to next step (Second-level results)'},...
									'position',[0.01,0.01,.10,.05],...
                                    'toggle',0,...
									'fontsize',8,...
                                    'fontangle','normal',...
                                    'bordertype','round',...
									'callback',{{@conn,'gui_analyses_done_vv'}} );
	CONN_h.menus.m_analyses_05=conn_menumanager([], 'n',1,...
									'string',{'Done'},...
									'help',{'Saves changes to First-level Dynamic FC analysis step and runs associated processing pipeline before proceeding to next step (Second-level results)'},...
									'position',[0.01,0.01,.10,.05],...
                                    'toggle',0,...
									'fontsize',8,...
                                    'fontangle','normal',...
                                    'bordertype','round',...
									'callback',{{@conn,'gui_analyses_done_dyn'}} );
	CONN_h.menus.m_results_03a=conn_menumanager([], 'n',3,...
									'string',{'Explore factors','Factor loadings','Factor scores'},...
									'help',{'Explore estimated dynamic connectivity factors','Define/explore second-level analyses of dynamic factor loadings','Define/explore second-level analyses of dynamic factor scores'},...
                                    'order','vertical',...
									'position',[.005,.40-3*.06,.10,3*.06],...
									'state',[1,0,0],...
									'value',1,...
                                    'toggle',1,...
									'fontsize',8,...
                                    'bordertype','square',...
									'callback',{{@conn,'gui_results_dyn'},{@conn,'gui_results_dyn'},{@conn,'gui_results_dyn'}} );
	CONN_h.menus.m_results_03=conn_menumanager([], 'n',4,...
									'string',{'ROI-to-ROI','Seed-to-Voxel','Voxel-to-Voxel','Dynamic FC'},...
									'help',{'Define/explore ROI-to-ROI second-level analyses','Define/explore seed-to-voxel second-level analyses','Define/explore voxel-to-voxel second-level analyses','Define/explore dynamic connectivity second-level analyses'},...
                                    'order','vertical',...
									'position',[.005,.44,.10,4*.06],...%[.0,.68,.07,3*.05],...
									'state',[1,0,0,0],...
									'value',1,...
                                    'toggle',1,...
									'fontsize',8,...
                                    'bordertype','square',...
									'callback',{{@conn,'gui_results'},{@conn,'gui_results'},{@conn,'gui_results'},{@conn,'gui_results'}} );
% 									'callback',{{@conn,'gui_results'},{@conn,'gui_results'},{@conn,'gui_results'},CONN_h.menus.m_results_03a},...
%                                     'callback2',{{},{},{},{@conn,'gui_results'}} );
	CONN_h.menus.m_results_04=conn_menumanager([], 'n',2,...
									'string',{'Results explorer','Graph theory'},...
									'help',{'Graphic display of ROI-to-ROI second-level results (selected between-subjects and between-conditions contrast for each source ROI)','Graphic display of graph-theory second-level results (for selected between-subjects and between-conditions contrast)'},...
                                    'order','vertical',...
									'position',[.01,.06,1*.10,2*.05],...%[.0,.68,.07,3*.05],...
                                    'toggle',0,...
									'fontsize',8,...
                                    'fontangle','normal',...
                                    'bordertype','round',...
									'callback',{{@conn,'gui_results_roiview'},{@conn,'gui_results_graphtheory'}} );
% 	CONN_h.menus.m_results_04=conn_menumanager([], 'n',1,...
% 									'string',{'Tools'},...
% 									'help',{''},...
%                                     'order','vertical',...
% 									'position',[0.01,0.01,.10,.05],...
%                                     'toggle',0,...
% 									'fontsize',8,...
%                                     'fontangle','normal',...
%                                     'bordertype','square',...
% 									'callback',{CONN_h.menus.m_results_04a} );
	CONN_h.menus.m_results_05=conn_menumanager([], 'n',2,...
									'string',{'Results explorer','Repeat for all sources'},...
									'help',{'Whole-brain display of seed-to-voxel second-level results (for selected between-subjects/conditions/sources contrasts)','Performs seed-to-voxel analyses for each source/seed included in the ''Sources'' list (for selected between-subjects and between-conditions contrasts)'},...
                                    'order','vertical',...
									'position',[.01,.06,1*.10,2*.05],...%[.0,.68,.07,3*.05],...
                                    'toggle',0,...
									'fontsize',8,...
                                    'fontangle','normal',...
                                    'bordertype','round',...
									'callback',{{@conn,'gui_results_wholebrain'},{@conn,'gui_results_done'}} );
% 	CONN_h.menus.m_results_05=conn_menumanager([], 'n',1,...
% 									'string',{'Tools'},...
% 									'help',{''},...
%                                     'order','vertical',...
% 									'position',[0.01,0.01,.10,.05],...
%                                     'toggle',0,...
% 									'fontsize',8,...
%                                     'fontangle','normal',...
%                                     'bordertype','square',...
% 									'callback',{CONN_h.menus.m_results_05a} );
% 	CONN_h.menus.m_results_05=conn_menumanager([], 'n',3,...
% 									'string',{'Seed-to-Voxel explorer','Compute results for all sources','Search additional sources'},...
% 									'help',{'Whole-brain display of seed-to-voxel second-level results (for selected between-subjects/conditions/sources contrasts)','Performs seed-to-voxel analyses for each source/seed included in the ''Sources'' list (for selected between-subject and between-conditions contrasts)','Performs seed-to-voxel analyses using all voxels as potential seeds (returns FWE-corrected seed-level statistics and adds significant seeds as additional sources)'},...
%                                     'order','vertical',...
% 									'position',[.01,.06,1*.10,3*.05],...%[.0,.68,.07,3*.05],...
%                                     'toggle',0,...
% 									'fontsize',8,...
%                                     'fontangle','normal',...
%                                     'bordertype','round',...
% 									'callback',{{@conn,'gui_results_wholebrain'},{@conn,'gui_results_done'},{@conn,'gui_results_searchseed'}} );
% 	CONN_h.menus.m_results_05b=conn_menumanager([], 'n',1,...
% 									'string',{'Tools'},...
% 									'help',{''},...
%                                     'order','vertical',...
% 									'position',[0.01,0.01,.10,.05],...
%                                     'toggle',0,...
% 									'fontsize',8,...
%                                     'fontangle','normal',...
%                                     'bordertype','square',...
% 									'callback',{CONN_h.menus.m_results_05c} );
	CONN_h.menus.m_results_06=conn_menumanager([], 'n',1,...
									'string',{'Results explorer'},...%,'Compute results for all measures'},...
									'help',{'Whole-brain display of voxel-to-voxel measure second-level results (for selected between-subjects/conditions/measures contrasts)'},...%,'Performs group analyses for all measures'},...
                                    'order','vertical',...
									'position',[.01,.06,1*.10,1*.05],...%[.0,.68,.07,3*.05],...
                                    'toggle',0,...
									'fontsize',8,...
                                    'fontangle','normal',...
                                    'bordertype','round',...
									'callback',{{@conn,'gui_results_wholebrain_vv'}});%,{@conn,'gui_results_done_vv'}} );
% 	CONN_h.menus.m_results_06=conn_menumanager([], 'n',1,...
% 									'string',{'Tools'},...
% 									'help',{''},...
%                                     'order','vertical',...
% 									'position',[0.01,0.01,.10,.05],...
%                                     'toggle',0,...
% 									'fontsize',8,...
%                                     'fontangle','normal',...
%                                     'bordertype','square',...
% 									'callback',{CONN_h.menus.m_results_06a} );

    try
        javaMethodEDT('setInitialDelay',javax.swing.ToolTipManager.sharedInstance,500); % tooltipstring timer-on 0.5s
        javaMethodEDT('setDismissDelay',javax.swing.ToolTipManager.sharedInstance,30000); % tooltipstring timer-off 30s
        javaMethodEDT('setReshowDelay',javax.swing.ToolTipManager.sharedInstance,0); % tooltipstring timer-continue 0s
        javax.swing.UIManager.put('ToolTip.background',javax.swing.plaf.ColorUIResource(238/255,238/255,238/255)); % background color tooltipstring
        if ismac&&CONN_gui.domacGUIbugfix, 
            CONN_gui.originalCOMB=javax.swing.UIManager.get('ComboBoxUI');
            javax.swing.UIManager.put('ComboBoxUI','javax.swing.plaf.metal.MetalComboBoxUI'); %com.jgoodies.looks.plastic.PlasticComboBoxUI % fix popup menu colors in mac
            CONN_gui.uicontrol_borderpopup=56;
        end
        if isunix&&~ismac&&conn_dounixGUIbugfix, %(||ismac&&CONN_gui.domacGUIbugfix), 
            CONN_gui.originalLAF=javax.swing.UIManager.getLookAndFeel;
            CONN_gui.originalBORD=javax.swing.UIManager.get('ToggleButton.border');
            javax.swing.UIManager.setLookAndFeel('javax.swing.plaf.metal.MetalLookAndFeel'); %javax.swing.plaf.nimbus.NimbusLookAndFeel com.jgoodies.looks.plastic.PlasticLookAndFeel
            javax.swing.UIManager.put('ToggleButton.border',javax.swing.BorderFactory.createEmptyBorder); % fix menu buttons border in unix
        end
    end
    conn gui_setup;
    conn_register;

else
    if ~isempty(regexp(char(varargin{1}),'\.mat$')); % conn projectfile.mat ... syntax
        conn('load',varargin{1});
        conn(varargin{2:end});
        return;
    end
	switch(lower(varargin{1})),
        case 'init',
            CONN_x=struct('name',[],'filename','','gui',1,'state',0,'ver',connver,...
                'opt',struct('fmt1','%03d'),...
                'pobj',conn_projectmanager('null'),...
                'folders',struct('rois',fullfile(fileparts(which(mfilename)),'rois'),'data',[],'preprocessing',[],'firstlevel',[],'secondlevel',[]),...
                'Setup',struct(...
                 'RT',2,'nsubjects',1,'nsessions',1,'fwhm',12,'reorient',eye(4),'normalized',1,...
                 'functional',{{}},...
                 'structural',{{}},...
                 'structural_sessionspecific',0,...
                 'spm',{{}},...
                 'nscans',{{}},....
                 'rois',         struct('names',{{}},'files',{{}},'dimensions',{{}},'mask',[],'subjectspecific',[],'sessionspecific',[],'multiplelabels',[],'regresscovariates',[],'unsmoothedvolumes',[]),...
                 'conditions',   struct('names',{{}},'values',{{}},'param',[],'filter',{{}},'allnames',{{}},'missingdata',0),...
                 'l1covariates', struct('names',{{}},'files',{{}}),...
                 'l2covariates', struct('names',{{}},'values',{{}}),...
                 'acquisitiontype',1,...
                 'steps',[1,1,1,1],...
                 'spatialresolution',1,...
                 'analysismask',1,...
                 'analysisunits',1,...
                 'explicitmask',{conn_file(fullfile(fileparts(which(mfilename)),'utils','surf','mask.volume.brainmask.nii'))},...
                 'roiextract',2,...
                 'roiextract_functional',{{}},...
                 'roiextract_rule',{{}},...
                 'unwarp_functional',{{}},...
                 'cwthreshold',[.5 1],...
                 'outputfiles',[0,0,0,0,0,0],...
                 'surfacesmoothing',10),...
                'Preproc',struct(...
                 'variables',   struct('names',{{}},'types',{{}},'deriv',{{}},'dimensions',{{}}),...
                 'confounds',	struct('names',{{}},'types',{{}},'deriv',{{}},'dimensions',{{}}),...
                 'filter',[0.008,0.09],...
                 'despiking',0,...
                 'regbp',1,...
                 'detrending',1),...
                'Analyses',struct(...
                 'name','ANALYSIS_01',...
                 'sourcenames',{{}},...
                 'variables', struct('names',{{}},'types',{{}},'deriv',{{}},'fbands',{{}},'dimensions',{{}}),...
                 'regressors',	struct('names',{{}},'types',{{}},'deriv',{{}},'fbands',{{}},'dimensions',{{}}),...
                 'type',[],...
                 'measure',[],...
                 'modulation',[],...
                 'conditions',[],...
                 'weight',[]),...
                'Analysis',1,...
                'dynAnalyses',struct('regressors', struct('names',{{}}),'variables', struct('names',{{}}),'Ncomponents',[10],'condition',1,'filter',.09,'output',[1 1 0]),...
                'vvAnalyses',struct(...
                 'measurenames',{{}},...
                 'variables',  conn_v2v('measures'),...
                 'regressors', conn_v2v('empty') ),...
                'Results',struct(...
                  'foldername','',...
                  'xX',[],...
                  'saved',struct('names',{{}},'labels',{{}},'nsubjecteffects',{{}},'csubjecteffects',{{}},'nconditions',{{}},'cconditions',{{}}) ));
            
            CONN_x.Setup.functional{1}{1}={[],[],[]};
            CONN_x.Setup.nscans{1}{1}=0;
            CONN_x.Setup.spm{1}={[],[],[]};
            CONN_x.Setup.conditions.values{1}{1}{1}={0,inf};
            CONN_x.Setup.conditions.names={'rest',' '};
            CONN_x.Setup.l1covariates.files{1}{1}{1}={[],[],[]};
            CONN_x.Setup.l1covariates.names={' '};
            CONN_x.Setup.l2covariates.values{1}{1}=1;
            CONN_x.Setup.l2covariates.names={'AllSubjects',' '};
            CONN_x.Setup.rois.files{1}{1}{1}={[],[],[]};%{filename,str,icon};
            CONN_x.Setup.rois.files{1}{2}{1}={[],[],[]};%{filename,str,icon};
            CONN_x.Setup.rois.files{1}{3}{1}={[],[],[]};%{filename,str,icon};
            CONN_x.Setup.rois.names={'Grey Matter','White Matter','CSF',' '};
            CONN_x.Setup.rois.dimensions={1,16,16};
            CONN_x.Setup.rois.mask=[0,0,0];
            CONN_x.Setup.rois.subjectspecific=[1 1 1];
            CONN_x.Setup.rois.sessionspecific=[0 0 0];
            CONN_x.Setup.rois.multiplelabels=[0,0,0];
            CONN_x.Setup.rois.regresscovariates=[0,1,1];
            CONN_x.Setup.rois.unsmoothedvolumes=[1,1,1];
            filename=fullfile(fileparts(which('spm')),'canonical','avg152T1.nii');
            %filename=fullfile(fileparts(which('spm')),'canonical','avg305T1.nii');
            [V,str,icon]=conn_getinfo(filename);
            CONN_x.Setup.structural{1}{1}={filename,str,icon};
            CONN_gui.refs.canonical=struct('filename',filename,'V',V,'data',spm_read_vols(V));
            [x,y,z]=ndgrid(1:CONN_gui.refs.canonical.V.dim(1),1:CONN_gui.refs.canonical.V.dim(2),1:CONN_gui.refs.canonical.V.dim(3));
            CONN_gui.refs.canonical.xyz=CONN_gui.refs.canonical.V.mat*[x(:),y(:),z(:),ones(numel(z),1)]';
            filename=fullfile(fileparts(which('conn')),'rois','atlas.nii');
            %filename=fullfile(fileparts(which('conn')),'utils','otherrois','aal.nii');
            %filename=fullfile(fileparts(which('conn')),'utils','otherrois','BA.img');
            [filename_path,filename_name,filename_ext]=fileparts(filename);
            V=spm_vol(filename);
            CONN_gui.refs.rois=struct('filename',filename,'filenameshort',filename_name,'V',V,'data',spm_read_vols(V),'labels',{textread(fullfile(filename_path,[filename_name,'.txt']),'%s','delimiter','\n')});
            CONN_gui.refs.surf.spherereduced=conn_surf_sphere(5);
            [CONN_gui.refs.surf.spheredefault,CONN_gui.refs.surf.default2reduced]=conn_surf_sphere(8,CONN_gui.refs.surf.spherereduced.vertices);
            CONN_gui.refs.surf.defaultsize=[42 83 47*2];%conn_surf_dims(8).*[1 1 2];
            CONN_gui.refs.surf.reducedsize=[42 61 2];   %conn_surf_dims(5); CONN_gui.refs.surf.reducedsize=[prod(CONN_gui.refs.surf.reducedsize(1:2)),CONN_gui.refs.surf.reducedsize(3),2];
            CONN_gui.refs.surf.default=conn_surf_readsurf;
            CONN_gui.refs.surf.defaultreduced=CONN_gui.refs.surf.default;
            CONN_gui.refs.surf.defaultreduced(1).vertices=CONN_gui.refs.surf.defaultreduced(1).vertices(CONN_gui.refs.surf.default2reduced,:);
            CONN_gui.refs.surf.defaultreduced(1).faces=CONN_gui.refs.surf.spherereduced.faces;
            CONN_gui.refs.surf.defaultreduced(2).vertices=CONN_gui.refs.surf.defaultreduced(2).vertices(CONN_gui.refs.surf.default2reduced,:);
            CONN_gui.refs.surf.defaultreduced(2).faces=CONN_gui.refs.surf.spherereduced.faces;
            if ~isfield(CONN_gui,'font_offset'), CONN_gui.font_offset=0; end
            CONN_gui.parse_html={'<HTML><FONT color=rgb(100,100,100)>','</FONT></HTML>'};
            %CONN_gui.parse_html={'',''};
            
        case {'close','forceclose'}
            connversion={'CONN functional connectivity toolbox',' (',connver,') '};
            hfig=findobj('tag',connversion{1});
            if ~isempty(hfig)&&ishandle(hfig),
                if strcmp(lower(varargin{1}),'forceclose'), CONN_gui.status=1; delete(hfig); 
                else close(hfig);
                end
                CONN_x.gui=0;
                %CONN_x=[];
                %CONN_gui=[];
                CONN_h=[];
                return;
            end
            
        case 'importrois',
            if ~isfield(CONN_x.folders,'rois'), CONN_x.folders.rois=fullfile(fileparts(which(mfilename)),'rois'); end
            path=CONN_x.folders.rois;
            names=cat(1,dir(fullfile(path,'*.nii')),dir(fullfile(path,'*.img')),dir(fullfile(path,'*.tal')));
            n0=length(CONN_x.Setup.rois.names)-1;
            for n1=1:length(names),
                [nill,name,nameext]=fileparts(names(n1).name);
                filename=fullfile(path,names(n1).name);
                [V,str,icon,filename]=conn_getinfo(filename);
                CONN_x.Setup.rois.names{n0+n1}=name; CONN_x.Setup.rois.names{n0+n1+1}=' ';
                for nsub=1:CONN_x.Setup.nsubjects, 
                    for nses=1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsub))
                        CONN_x.Setup.rois.files{nsub}{n0+n1}{nses}={filename,str,icon};
                    end
                end
                CONN_x.Setup.rois.dimensions{n0+n1}=1;
                CONN_x.Setup.rois.mask(n0+n1)=0;
                CONN_x.Setup.rois.subjectspecific(n0+n1)=0;
                CONN_x.Setup.rois.sessionspecific(n0+n1)=0;
                CONN_x.Setup.rois.multiplelabels(n0+n1)=(strcmp(nameext,'.img')|strcmp(nameext,'.nii')|strcmp(nameext,'.mgz'))&(~isempty(dir(conn_prepend('',filename,'.txt')))|~isempty(dir(conn_prepend('',filename,'.csv')))|~isempty(dir(conn_prepend('',filename,'.xls'))));
                CONN_x.Setup.rois.regresscovariates(n0+n1)=double(CONN_x.Setup.rois.dimensions{n0+n1}>1);
                CONN_x.Setup.rois.unsmoothedvolumes(n0+n1)=1;
            end
            
        case 'load',
            if nargin>1,filename=varargin{2}; 
            else filename=CONN_x.filename; end
            if nargin>2,fromgui=varargin{3}; 
            else fromgui=false; end
            if isempty(filename)||~ischar(filename),
                disp('warning: invalid filename, project NOT loaded');
            else
                [basefilename,pobj]=conn_projectmanager('extendedname',filename);
                localfilename=conn_projectmanager('projectfile',basefilename,pobj);
				try 
                    if ~pobj.isextended||conn_existfile(localfilename), errstr=localfilename; load(localfilename,'CONN_x','-mat'); 
                    else errstr=basefilename; load(basefilename,'CONN_x','-mat'); 
                    end
                catch %#ok<*CTCH>
                    error(['Failed to load file ',errstr,'.']); 
                    return; 
                end
                if fromgui, CONN_x.gui=1; end
                if ~pobj.isextended&&isfield(CONN_x,'pobj'), % attempting to load an extended project directly (inherits parallelization options from base)
                    pobj=CONN_x.pobj;
                    [basefilename,localfilename]=conn_projectmanager('parentfile',basefilename,pobj);
                end
                if pobj.holdsdata, CONN_x.filename=conn_fullfile(localfilename);
                else CONN_x.filename=conn_fullfile(basefilename);
                end
                CONN_x.pobj=pobj;
                if pobj.holdsdata, conn_updatefolders; end
                conn_projectmanager('updateproject',fromgui);
                if fromgui,
                    try, conn_updatefilepaths; end
                end
            end
			
		case 'save',
            if nargin>1, filename=varargin{2}; 
            else filename=CONN_x.filename; end
            if isempty(filename)||~ischar(filename),
                error('invalid filename, project NOT saved');
            else
                saveas=~isequal(filename,CONN_x.filename);
                CONN_x.filename=conn_fullfile(filename);
                if CONN_x.pobj.holdsdata, 
                    localfilename=CONN_x.filename;
                    conn_updatefolders;
                else
                    localfilename=conn_projectmanager('projectfile');
                end
                try
                    save(localfilename,'CONN_x');
                catch
                    error(['Failed to save file ',localfilename,'. Check file name and/or folder permissions']);
                end
                if ~saveas&&CONN_x.pobj.holdsdata,
                    try
                        conn_projectmanager cleanproject;
                    catch
                        disp('ERROR: CONN was not able to delete the following files. Please delete them');
                        disp('manually before proceeding.');
                        disp(char(CONN_x.pobj.importedfiles));
                        error('Failed to delete temporal project files. Check file name and/or folder permissions');
                    end
                end
                if ~saveas
                    if isfield(CONN_x,'Analyses')
                        for ianalysis=1:numel(CONN_x.Analyses)
                            if isfield(CONN_x.Analyses(ianalysis),'name')&&isfield(CONN_x.Analyses(ianalysis),'sourcenames')
                                filesourcenames=fullfile(CONN_x.folders.firstlevel,CONN_x.Analyses(ianalysis).name,'_list_sources.mat');
                                filesourcenames=conn_projectmanager('projectfile',filesourcenames,CONN_x.pobj,'.mat');
                                sourcenames=CONN_x.Analyses(ianalysis).sourcenames;
                                save(filesourcenames,'sourcenames');
                            end
                        end
                    end
                    if isfield(CONN_x,'vvAnalyses')
                        if isfield(CONN_x.vvAnalyses,'measurenames')
                            filemeasurenames=fullfile(CONN_x.folders.firstlevel,'_list_measures.mat');
                            filemeasurenames=conn_projectmanager('projectfile',filemeasurenames,CONN_x.pobj,'.mat');
                            measurenames=CONN_x.vvAnalyses.measurenames;
                            save(filemeasurenames,'measurenames');
                        end
                    end
                    if isfield(CONN_x.Setup.conditions,'allnames')
                        fileconditionnames=fullfile(CONN_x.folders.preprocessing,'_list_conditions.mat');
                        fileconditionnames=conn_projectmanager('projectfile',fileconditionnames,CONN_x.pobj,'.mat');
                        allnames=CONN_x.Setup.conditions.allnames;
                        save(fileconditionnames,'allnames');
                    end
                end
            end

        case 'ver'
            varargout={connver};
            
        case 'checkver',
            ver2=varargin{2};
            if nargin>=3&&~isempty(varargin{3}), ver1=varargin{3}; else ver1=connver; end
            v1=str2num(regexp(ver1,'^\d+','match','once'));
            r1=char(regexp(ver1,'^\d+\.(.+)$','tokens','once'));
            v2=str2num(regexp(ver2,'^\d+','match','once'));
            r2=char(regexp(ver2,'^\d+\.(.+)$','tokens','once'));
            [nill,idx]=sort({r2,r1});
            varargout={v1>v2 | (v1==v2&idx(1)==1)};
            
        case 'background_image'
            if nargin>1
                filename=varargin{2};
            else
                filename=spm_select(1,'\.img$|\.nii$',['Select background anatomical image'],{},fileparts(CONN_gui.refs.canonical.filename));
                if isempty(filename), return; end
            end
            [V,str,icon,filename]=conn_getinfo(filename);
            CONN_gui.refs.canonical=struct('filename',filename,'V',V,'data',spm_read_vols(V));
            [x,y,z]=ndgrid(1:CONN_gui.refs.canonical.V.dim(1),1:CONN_gui.refs.canonical.V.dim(2),1:CONN_gui.refs.canonical.V.dim(3));
            CONN_gui.refs.canonical.xyz=CONN_gui.refs.canonical.V.mat*[x(:),y(:),z(:),ones(numel(z),1)]';
            
        case 'background_rois'
            if nargin>1
                filename=varargin{2};
            else
                filename=spm_select(1,'\.img$|\.nii$',['Select background ROI atlas'],{CONN_gui.refs.rois.filename},fileparts(CONN_gui.refs.rois.filename));
                if isempty(filename), return; end
            end
            [filename_path,filename_name,filename_ext]=fileparts(filename);
            V=spm_vol(filename);
            CONN_gui.refs.rois=struct('filename',filename,'filenameshort',filename_name,'V',V,'data',spm_read_vols(V),'labels',{textread(fullfile(filename_path,[filename_name,'.txt']),'%s','delimiter','\n')});
            clear conn_vproject;

        case 'gui_calculator'
            conn_menumanager clf;
            conn_menuframe;
            tstate=conn_menumanager(CONN_h.menus.m0,'state'); tstate(:)=0;conn_menumanager(CONN_h.menus.m0,'state',tstate);
            conn_menumanager([CONN_h.menus.m_setup_06,CONN_h.menus.m0],'on',1);
            conn_calculator;
            
        case 'gui_setup_preproc'
            if nargin>1
                ok=conn_setup_preproc('',varargin{2:end});
            else
                ok=conn_setup_preproc;
            end
            if ok==2
                conn gui_setup; 
                conn_msgbox({'Preprocessing finished correctly; Output files imported.'},'',true);
                %conn save; 
            elseif ok==1
                conn_msgbox({'Preprocessing finished correctly'},'',true);
            elseif ok<0
                errordlg({'Some error occurred when running SPM batch.','Please see Matlab command window for full report'},'');
            end
            return;
            
        case 'gui_help',
            switch(lower(varargin{2}))
                case 'url'
                    disp(varargin{3});
                    web(varargin{3},'-browser');
                case 'doc'
                    if nargin<3
                        name=dir(fullfile(fileparts(which(mfilename)),'CONN_fMRI_Functional_connectivity_toolbox_manual*.pdf'));
                        if ~isempty(name)
                            open(fullfile(fileparts(which(mfilename)),name(1).name));
                        end
                    else
                        open(varargin{3});
                    end
                case 'help'
                    if iscell(varargin{3}), str=varargin{3};
                    else
                        if isdeployed,
                            str=fileread(regexprep(which(varargin{3}),'\.m$','.help.txt'));
                            str=regexp(str,'\n([^\n]*)','tokens'); str=[str{:}];
                            %str=fileread(which(varargin{3}));
                            %str=regexp(str,'\n\%+([^\n]*)','tokens'); str=[str{:}];
                            str=regexprep(str,char(13),'');
                            str(find(strcmp(str,'$'),1):end)=[];
                            str(cellfun(@isempty,str))=[];
                        else
                            str=help(varargin{3});
                            str=regexp(str,'\n','split');
                        end
                    end
                    str=regexprep(str,'(<HTML>)?(\s*)(.*)\%\!(</HTML>)?','<HTML><pre>$2<b>$3</b></pre></HTML>');
                    dlg.fig=figure('units','norm','position',[.2,.1,.6,.8],'menubar','none','numbertitle','off','name','help','color','w');
                    dlg.box=uicontrol(dlg.fig,'units','norm','position',[0 0 1 1],'style','listbox','max',1,'str',str,'backgroundcolor','w','horizontalalignment','left','fontname','monospaced');
                    uiwait(dlg.fig,1);
            end
            
        case 'gui_settings',
            dlg.fig=figure('units','norm','position',[.3,.1,.4,.4],'menubar','none','numbertitle','off','name','GUI settings','color','w');
            %uicontrol('style','frame','unit','norm','position',[.05,.5,.9,.45],'backgroundcolor','w','foregroundcolor',[.5 .5 .5]);
            uicontrol('style','text','units','norm','position',[.1,.86,.45,.075],'backgroundcolor','w','foregroundcolor','k','horizontalalignment','right','string','GUI font size (pts):');
            dlg.m1=uicontrol('style','edit','units','norm','position',[.6,.86,.1,.075],'string',num2str(8+CONN_gui.font_offset),'tooltipstring','Changes the default font size used in the CONN toolbox GUI');
            dlg.m4=uicontrol('style','pushbutton','units','norm','position',[.6,.775,.1,.075],'string',' ','backgroundcolor',min(1,CONN_gui.backgroundcolor),'tooltipstring','Changes the default background color used in the CONN toolbox GUI','callback','color=get(gcbo,''backgroundcolor'');if numel(color)~=3, color=uisetcolor; else color=uisetcolor(color); end; if numel(color)==3, set(gcbo,''backgroundcolor'',color); end');
            dlg.m5=uicontrol('style','checkbox','units','norm','position',[.1,.70,.4,.075],'string','Enable tooltips','backgroundcolor','w','tooltipstring','Display help information over each clickable/editable field in the GUI','value',CONN_gui.tooltips);
            %dlg.m6=uicontrol('style','checkbox','units','norm','position',[.1,.625,.8,.075],'string','Troubleshot: use alternative popupmenu type','backgroundcolor','w','tooltipstring','Fixes lightText-on-lightBackground popup menus issue on Mac OS when using dark backgrounds','value',CONN_gui.domacGUIbugfix>0);
            %dlg.m8=uicontrol('style','checkbox','units','norm','position',[.1,.55,.8,.075],'string','Troubleshot: use alternative pushbutton type','backgroundcolor','w','tooltipstring','Fixes fuzzy text on push-buttons','value',CONN_gui.dounixGUIbugfix>0);
            dlg.m7=uicontrol('style','checkbox','units','norm','position',[.1,.625,.4,.075],'string','Automatic updates','backgroundcolor','w','tooltipstring','Checks NITRC site for CONN toolbox updates each time CONN is started and offers to download/install if updates are available','value',CONN_gui.checkupdates);
            uicontrol('style','pushbutton','units','norm','position',[.75,.86,.05,.055],'string','-','backgroundcolor','w','tooltipstring','Decrease font size','callback','hdl=get(gcbo,''userdata''); fontsize=str2num(get(hdl,''string'')); fontsize=max(0,fontsize-1); if numel(fontsize)==1, set(hdl,''string'',num2str(fontsize)); end','userdata',dlg.m1);
            uicontrol('style','pushbutton','units','norm','position',[.80,.86,.05,.055],'string','+','backgroundcolor','w','tooltipstring','Increase font size','callback','hdl=get(gcbo,''userdata''); fontsize=str2num(get(hdl,''string'')); fontsize=fontsize+1; if numel(fontsize)==1, set(hdl,''string'',num2str(fontsize)); end','userdata',dlg.m1);
            uicontrol('style','pushbutton','units','norm','position',[.75,.785,.05,.055],'string','-','backgroundcolor','w','tooltipstring','Decrease brightness','callback','hdl=get(gcbo,''userdata''); color=get(hdl,''backgroundcolor''); color=max(0,color-.025); if numel(color)==3, set(hdl,''backgroundcolor'',color); end','userdata',dlg.m4);
            uicontrol('style','pushbutton','units','norm','position',[.80,.785,.05,.055],'string','+','backgroundcolor','w','tooltipstring','Increase brightness','callback','hdl=get(gcbo,''userdata''); color=get(hdl,''backgroundcolor''); color=min(1,color+.025); if numel(color)==3, set(hdl,''backgroundcolor'',color); end','userdata',dlg.m4);
            hc1=uicontextmenu; 
              uimenu(hc1,'label','Set GUI background image from file','callback','conn_guibackground setfile'); 
              uimenu(hc1,'label','Set GUI background image from screenshot','callback','conn_guibackground cleartrans'); 
              uimenu(hc1,'label','Remove GUI background image','callback','conn_guibackground clear'); 
              set(dlg.m4,'uicontextmenu',hc1);
            uicontrol('style','popupmenu','units','norm','position',[.1,.775,.45,.075],'backgroundcolor','w','foregroundcolor','k','horizontalalignment','left','string',{'Select GUI background color','Use default dark background-color','Use default light background-color','Use default background pattern','Select GUI background image from file','Use background-screenshot image'},'userdata',dlg.m4,'callback',...
                'switch(get(gcbo,''value'')), case 1, conn_guibackground clear; color=uisetcolor; if numel(color)==3, set(get(gcbo,''userdata''),''backgroundcolor'',color); end; case 2, conn_guibackground clear; set(get(gcbo,''userdata''),''backgroundcolor'',[.03 .12 .2]); case 3, conn_guibackground clear; set(get(gcbo,''userdata''),''backgroundcolor'',[.975 .975 .975]); case 4, conn_guibackground setfiledefault; case 5, conn_guibackground setfile; case 6, conn_guibackground cleartrans; end',...
                'tooltipstring','Changes the default font size used in the CONN toolbox GUI');
            uicontrol('style','frame','unit','norm','position',[.05,.15,.9,.25],'backgroundcolor','w','foregroundcolor',[.5 .5 .5]);
            %uicontrol('style','text','unit','norm','position',[.07,.91,.3,.08],'string','Appearance','backgroundcolor','w','foregroundcolor',[.5 .5 .5]);
            uicontrol('style','text','unit','norm','position',[.07,.355,.6,.08],'string','GUI reference-brain (for second-level result displays)','backgroundcolor','w','foregroundcolor',[.5 .5 .5]);
            %uicontrol('style','text','units','norm','position',[.1,.375,.8,.075],'backgroundcolor','w','foregroundcolor','k','horizontalalignment','left','string','GUI reference-brain (for second-level result displays):');
            dlg.m2=uicontrol('style','pushbutton','units','norm','position',[.1,.275,.8,.1],'string','Background anatomical image','tooltipstring',CONN_gui.refs.canonical.filename,'callback','filename=spm_select(1,''\.img$|\.nii$'',''Select image'',{get(gcbo,''tooltipstring'')},fileparts(get(gcbo,''tooltipstring'')));if ~isempty(filename), set(gcbo,''tooltipstring'',filename); end;');
            dlg.m3=uicontrol('style','pushbutton','units','norm','position',[.1,.175,.8,.1],'string','Background reference atlas','tooltipstring',CONN_gui.refs.rois.filename,'callback','filename=spm_select(1,''\.img$|\.nii$'',''Select image'',{get(gcbo,''tooltipstring'')},fileparts(get(gcbo,''tooltipstring'')));if ~isempty(filename), set(gcbo,''tooltipstring'',filename); end;');
            dlg.m11=uicontrol('style','pushbutton','units','norm','position',[.35,.025,.2,.1],'string','OK','tooltipstring','Accept changes','callback','set(gcbf,''userdata'',0); uiresume(gcbf)');
            dlg.m12=uicontrol('style','pushbutton','units','norm','position',[.55,.025,.2,.1],'string','Cancel','callback','delete(gcbf)');
            dlg.m13=uicontrol('style','pushbutton','units','norm','position',[.75,.025,.2,.1],'string','Apply','tooltipstring','Apply changes','callback','set(gcbf,''userdata'',1); uiresume(gcbf)');
            while 1
                set(dlg.fig,'handlevisibility','on','hittest','on','userdata',[]);
                uiwait(dlg.fig);
                if ~ishandle(dlg.fig), break; end
                ok=get(dlg.fig,'userdata');
                if isempty(ok), break; end
                set(dlg.fig,'handlevisibility','off','hittest','off');
                answ=get(dlg.m1,'string');
                if ~isempty(answ)&&~isempty(str2num(answ)),
                    CONN_gui.font_offset=max(4,str2num(answ))-8;
                    set(0,{'defaultuicontrolfontsize','defaulttextfontsize','defaultaxesfontsize'},repmat({8+CONN_gui.font_offset},1,3));
                end
                CONN_gui.tooltips=get(dlg.m5,'value');
                %CONN_gui.domacGUIbugfix=get(dlg.m6,'value');
                %CONN_gui.dounixGUIbugfix=get(dlg.m8,'value');
                CONN_gui.checkupdates=get(dlg.m7,'value');
                answ=get(dlg.m4,'backgroundcolor');
                CONN_gui.backgroundcolor=answ;%/2;
                CONN_gui.backgroundcolorA=max(0,min(1,CONN_gui.backgroundcolor+0*.025));
                CONN_gui.backgroundcolorB=max(0,min(1,CONN_gui.backgroundcolor-0*sign(mean(CONN_gui.backgroundcolor)-.5)*.025+0*CONN_gui.domacGUIbugfix));
                CONN_gui.fontcolorA=[0 0 0]+1*(mean(CONN_gui.backgroundcolor)<.5);
                CONN_gui.fontcolorB=[.3 .3 .3]+.4*(mean(CONN_gui.backgroundcolor)<.5);
                cmap=.25+.75*(6*gray(128) + 2*(hot(128)))/8; if mean(CONN_gui.backgroundcolor)>.5,cmap=flipud(cmap); end
                CONN_h.screen.colormap=max(0,min(1, diag((1-linspace(1,0,256)'.^50))*[cmap;jet(128)]+(linspace(1,0,256)'.^50)*CONN_gui.backgroundcolorA ));
                set(CONN_h.screen.hfig,'color',CONN_gui.backgroundcolor,'colormap',CONN_h.screen.colormap);
                if iscell(CONN_gui.background), 
                    set(dlg.fig,'visible','off'); pause(.1);
                    conn_guibackground settrans; 
                    set(dlg.fig,'visible','on');
                end
                conn_menumanager updatebackgroundcolor;
                filename=get(dlg.m2,'tooltipstring');
                if ~strcmp(filename,CONN_gui.refs.canonical.filename)
                    if isempty(dir(filename))
                        filename=spm_select(1,'\.img$|\.nii$',['Select background anatomical image'],{CONN_gui.refs.canonical.filename},fileparts(CONN_gui.refs.canonical.filename));
                    end
                    if ~isempty(filename),
                        [V,str,icon,filename]=conn_getinfo(filename);
                        CONN_gui.refs.canonical=struct('filename',filename,'V',V,'data',spm_read_vols(V));
                        [x,y,z]=ndgrid(1:CONN_gui.refs.canonical.V.dim(1),1:CONN_gui.refs.canonical.V.dim(2),1:CONN_gui.refs.canonical.V.dim(3));
                        CONN_gui.refs.canonical.xyz=CONN_gui.refs.canonical.V.mat*[x(:),y(:),z(:),ones(numel(z),1)]';
                    end
                end
                filename=get(dlg.m3,'tooltipstring');
                if ~strcmp(filename,CONN_gui.refs.rois.filename)
                    if isempty(dir(filename))
                        filename=spm_select(1,'\.img$|\.nii$',['Select background reference atlas'],{CONN_gui.refs.rois.filename},fileparts(CONN_gui.refs.rois.filename));
                    end
                    if ~isempty(dir(filename))
                        [filename_path,filename_name,filename_ext]=fileparts(filename);
                        V=spm_vol(filename);
                        CONN_gui.refs.rois=struct('filename',filename,'filenameshort',filename_name,'V',V,'data',spm_read_vols(V),'labels',{textread(fullfile(filename_path,[filename_name,'.txt']),'%s','delimiter','\n')});
                        clear conn_vproject;
                    end
                end
                tstate=conn_menumanager(CONN_h.menus.m0,'state');
                if any(tstate)
                    switch(find(tstate))
                        case 1, conn gui_setup;
                        case 2, conn gui_preproc;
                        case 3, conn gui_analyses;
                        case 4, conn gui_results;
                    end
                end
                if ~ok, break; end
            end
            if ishandle(dlg.fig), 
                delete(dlg.fig); 
                conn_font_offset=CONN_gui.font_offset;
                conn_backgroundcolor=CONN_gui.backgroundcolor;
                conn_background=CONN_gui.background;
                conn_tooltips=CONN_gui.tooltips;
                conn_domacGUIbugfix=CONN_gui.domacGUIbugfix;
                conn_dounixGUIbugfix=CONN_gui.dounixGUIbugfix;
                conn_checkupdates=CONN_gui.checkupdates;
                answ=questdlg('Save these graphic settings for all users or current user only?','','All','Current','None','Current');
                if ~(isempty(answ)||strcmp(answ,'None')), 
                    if strcmp(answ,'All'),
                        filename='conn_font_default.dat';
                    else
                        [nill,username]=system('whoami'); if ~isequal(nill,0), username='unknown'; end
                        filename=sprintf('conn_font_default_%s.dat',char('0'+mod(cumsum(double(username)),10)));
                    end
                    try, save(fullfile(fileparts(which(mfilename)),filename),'conn_font_offset','conn_backgroundcolor','conn_background','conn_tooltips','conn_domacGUIbugfix','conn_dounixGUIbugfix','conn_checkupdates','-mat');
                    catch
                        try, save(fullfile(pwd,filename),'conn_font_offset','conn_backgroundcolor','conn_background','conn_tooltips','conn_domacGUIbugfix','conn_dounixGUIbugfix','conn_checkupdates','-mat'); end
                    end
                end
            end
            
        case 'parallel_settings'
            conn_jobmanager('settings');
            
        case 'run_cmd',
            if nargin>1&&~isempty(varargin{2}), str=varargin{2};
            else
                answ=inputdlg({'Enter Matlab command: (evaluated in the base Matlab workspace)'},'',1,{''},struct('Resize','on'));
                if numel(answ)~=1||isempty(answ{1}),return; end
                str=answ{1};
            end
            hmsg=conn_msgbox('Evaluating command... please wait','');
            conn_batch(str);
            if ishandle(hmsg), delete(hmsg); end
            
        case 'run',
            if nargin>1&&~isempty(varargin{2}), filename=varargin{2};
            else
                [tfilename,tpathname]=uigetfile({'*.m','Matlab batch script (*.m)'; '*.mat','Matlab batch structure (*.mat)'; '*',  'All Files (*)'},'Select batch file');
                if ~ischar(tfilename)||isempty(tfilename), return; end
                filename=fullfile(tpathname,tfilename);
            end
            hmsg=conn_msgbox('Running batch script... please wait','');
            conn_batch(filename);
            if ishandle(hmsg), delete(hmsg); end
			
        case 'run_process'
			if isempty(CONN_x.filename), conn gui_setup_save; end
            if conn_questdlg('Choose processing steps',[],CONN_x.Setup.steps(1:3),false,[],true,true);
                conn_menumanager clf;
                conn_menuframe;
                conn_menumanager([CONN_h.menus.m_setup_06,CONN_h.menus.m0],'on',1);
                psteps={'setup','denoising_gui','analyses_gui'};
                psteps=sprintf('%s;',psteps{CONN_x.gui.processes});
                if CONN_x.gui.parallel~=0, 
                    if CONN_x.gui.parallel>0, conn_jobmanager('options','profile',CONN_x.gui.parallel); end; 
                    conn save;
                    conn_jobmanager('submit',psteps,[],CONN_x.gui);
                else conn_process(psteps);
                end
                CONN_x.gui=1;
                conn gui_setup_save;
                conn gui_setup;
            end
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%			
        case 'gui_setupgo',
            state=varargin{2};
            tstate=conn_menumanager(CONN_h.menus.m_setup_02,'state'); tstate(:)=0;tstate(state)=1; conn_menumanager(CONN_h.menus.m_setup_02,'state',tstate); 
            conn gui_setup;
            
        case 'gui_setup',
            CONN_x.gui=1;
			state=find(conn_menumanager(CONN_h.menus.m_setup_02,'state'));
            if nargin<2,
                conn_menumanager clf;
                conn_menuframe;
                %axes('units','norm','position',[.10,.36,.002,.42]); image(shiftdim(1-CONN_gui.backgroundcolorA,-1)); axis off;
				tstate=conn_menumanager(CONN_h.menus.m0,'state'); tstate(:)=0;tstate(1)=1; conn_menumanager(CONN_h.menus.m0,'state',tstate); 
                %conn_menu('frame',[.015-.001,.5-.05-.001,.07+.002,7*.05+.002],'');
				conn_menumanager([CONN_h.menus.m_setup_02,CONN_h.menus.m_setup_01d,CONN_h.menus.m_setup_06,CONN_h.menus.m0],'on',1);
                conn_menu('nullstr',{'No data','selected'});
                %drawnow;
            end
            boffset=[0 0 0 0];
            switch(state),
                case 1, %basic
                    boffset=[.15 -.05 0 0];
                    if nargin<2,
                        conn_menu('frame',boffset+[.19,.36,.22,.44],'BASIC INFO');
						CONN_h.menus.m_setup_00{1}=conn_menu('edit',boffset+[.2,.7,.2,.04],'Number of subjects',num2str(CONN_x.Setup.nsubjects),'Number of subjects in this experiment','conn(''gui_setup'',1);');
						CONN_h.menus.m_setup_00{2}=conn_menu('edit',boffset+[.2,.6,.2,.04],'Number of sessions',num2str(CONN_x.Setup.nsessions,'%1.0f '),'<HTML>Number of scanning sessions per subject <br/> - enter a single number if the same number of scanning sessions were acquired for each subject, or a different number per subject otherwise (e.g. 2 2 3)</HTML>','conn(''gui_setup'',2);');
						CONN_h.menus.m_setup_00{3}=conn_menu('edit',boffset+[.2,.5,.2,.04],'Repetition Time (seconds)',mat2str(CONN_x.Setup.RT),'<HTML>Sampling period of fMRI data (time between two conscutive whole volume acquisitions<br/> - enter a single number if the same TR was used for each subject, or a different number per subject otherwise</HTML>','conn(''gui_setup'',3);');
                        analysistypes={'Continuous','Sparse'};
                        CONN_h.menus.m_setup_00{4}=conn_menu('popup',boffset+[.2,.4,.2,.04],'Acquisition type',analysistypes,'<HTML>Type of acquisition sequence<br/> - selecting <i>sparse acquisition</i> skips hrf-convolution when computing task-related effects</HTML>','conn(''gui_setup'',4);');
                        set(CONN_h.menus.m_setup_00{4},'value',1+(CONN_x.Setup.acquisitiontype~=1));
                    else
                        switch(varargin{2}),
                            case 1, 
								value0=CONN_x.Setup.nsubjects; 
								txt=get(CONN_h.menus.m_setup_00{1},'string'); value=str2num(txt); if ~isempty(value)&&length(value)==1, CONN_x.Setup.nsubjects=value; end; 
								if CONN_x.Setup.nsubjects~=value0, CONN_x.Setup.nsubjects=conn_merge(value0,CONN_x.Setup.nsubjects); end
								set(CONN_h.menus.m_setup_00{1},'string',num2str(CONN_x.Setup.nsubjects)); 
                                set(CONN_h.menus.m_setup_00{2},'string',num2str(CONN_x.Setup.nsessions,'%1.0f '))
                            case 2, txt=get(CONN_h.menus.m_setup_00{2},'string'); value=str2num(txt); if isempty(value), try value=evalin('base',txt); catch, value=[]; end; end;if ~isempty(value)&&(length(value)==1||length(value)==CONN_x.Setup.nsubjects), CONN_x.Setup.nsessions=value; end; set(CONN_h.menus.m_setup_00{2},'string',num2str(CONN_x.Setup.nsessions,'%1.0f ')); 
							case 3, txt=get(CONN_h.menus.m_setup_00{3},'string'); value=str2num(txt); if isempty(value), try value=evalin('base',txt); catch, value=[]; end; end;if ~isempty(value)&&(length(value)==1||length(value)==CONN_x.Setup.nsubjects), CONN_x.Setup.RT=value; end; set(CONN_h.menus.m_setup_00{3},'string',mat2str(CONN_x.Setup.RT)); 
                            case 4, value=get(CONN_h.menus.m_setup_00{4},'value'); CONN_x.Setup.acquisitiontype=value;
                        end
                    end
                case 3, %functional
                    boffset=[.02 .06 0 0];
                    if nargin<2,
                        conn_menu('frame',boffset+[.19,.18,.50,.62],'FUNCTIONAL DATA for voxel-level analyses');
                        conn_menu('frame',boffset+[.19,.03,.50,.08],'FUNCTIONAL DATA for roi-level analyses');
                        global tmp;
						%tmp=conn_menu('text',boffset+[.20,.75,.40,.04],'','Functional data for voxel-level analyses:');
                        %set(tmp,'horizontalalignment','left','fontangle','normal','fontweight','normal','foregroundcolor',CONN_gui.fontcolorA);
						CONN_h.menus.m_setup_00{1}=conn_menu('listbox',boffset+[.200,.25,.075,.50],'Subjects','','Select subject(s)','conn(''gui_setup'',1);');
						CONN_h.menus.m_setup_00{2}=conn_menu('listbox',boffset+[.275,.25,.075,.50],'Sessions','','Select session','conn(''gui_setup'',2);');
						CONN_h.menus.m_setup_00{3}=conn_menu('filesearch',[],'Select functional data files','*.img; *.nii; *.gz','',{@conn,'gui_setup',3},'conn(''gui_setup'',4);');
						CONN_h.menus.m_setup_00{4}=conn_menu('pushbutton2',boffset+[.35,.70,.34,.10],'','','','conn(''gui_setup'',4);');
						CONN_h.menus.m_setup_00{5}=conn_menu('image',boffset+[.36,.24,.31,.45]);
                        set([CONN_h.menus.m_setup_00{4}],'visible','off'); conn_menumanager('onregion',[CONN_h.menus.m_setup_00{4}],1,boffset+[.35,.25,.34,.55]);
                        analysistypes={'Same files','Other: same filenames without leading ''s'' (SPM convention for unsmoothed volumes)','Other: manually define (other filename conventions)','Other: manually selected functional data files (see HELP conn_batch)'};
                        if CONN_x.Setup.roiextract<=3, analysistypes=analysistypes(1:3); end
                        CONN_h.menus.m_setup_00{6}=conn_menu('popup',boffset+[.20,.04,.40,.05],'',analysistypes,'<HTML>Select if you would like to extract ROI BOLD-signal timeseries from the same functional volumes as above or a different set of functional volumes/files<br/> - Typically Voxel-level BOLD timeseries are extracted from spatially-smoothed functional volumes while ROI-level BOLD timeseries are extracted from  <br/> the original -unsmoothed- volumes in order to minimize spillage from neighbouring ROIs</HTML>','conn(''gui_setup'',6);');
                        CONN_h.menus.m_setup_00{14}=conn_menu('popup0',boffset+[.20,.18,.20,.05],'',{'<HTML><i> - functional tools:</i></HTML>','Slice viewer','Check functional/anatomical coregistration','Check functional/MNI coregistration','Apply individual preprocessing step'},'<HTML> - <i>slice viewer</i> displays first functional volume slices<br/> - <i>check registration</i> checks the coregistration of the selected subject functional/anatomical files <br/> - <i>preprocessing</i> runs individual preprocessing step on functional volumes (e.g. realignment, slice-timing correction, etc.)</HTML>','conn(''gui_setup'',14);');
                        %CONN_h.menus.m_setup_00{14}=uicontrol('style','pushbutton','units','norm','position',boffset+[.37,.20,.15,.04],'string','Check registration','tooltipstring','Check coregistration of functional and structural files for selected subject(s)/session(s)','callback','conn(''gui_setup'',14);','fontsize',8+CONN_gui.font_offset);
                        %CONN_h.menus.m_setup_00{14}=uicontrol('style','popupmenu','units','norm','position',boffset+[.37,.16,.15,.04],'string',{'<HTML><i> - options:</i></HTML>','check registration','preprocessing steps'},'foregroundcolor','w','backgroundcolor',CONN_gui.backgroundcolorA,'fontsize',8+CONN_gui.font_offset,'callback','conn(''gui_setup'',14);','tooltipstring','Functional volumes additional options');
						%CONN_h.menus.m_setup_00{11}=conn_menu('checkbox',boffset+[.38,.205,.02,.04],'spatially-normalized images','','','conn(''gui_setup'',11);');
						set(CONN_h.menus.m_setup_00{3}.files,'max',2);
						set(CONN_h.menus.m_setup_00{1},'max',2);
						set(CONN_h.menus.m_setup_00{1},'string',[repmat('Subject ',[CONN_x.Setup.nsubjects,1]),num2str((1:CONN_x.Setup.nsubjects)')]);
                        nsess=CONN_x.Setup.nsessions(1); set(CONN_h.menus.m_setup_00{2},'string',[repmat('Session ',[nsess,1]),num2str((1:nsess)')],'value',min(nsess,get(CONN_h.menus.m_setup_00{2},'value')),'max',2);
                        %if ~isfield(CONN_x.Setup,'normalized'), CONN_x.Setup.normalized=1; end
						set(CONN_h.menus.m_setup_00{6},'value',CONN_x.Setup.roiextract);
                        %hc1=uicontextmenu;uimenu(hc1,'Label','go to source folder','callback','conn(''gui_setup'',4);');set(CONN_h.menus.m_setup_00{4},'uicontextmenu',hc1);
                        %set([CONN_h.menus.m_setup_00{11}],'visible','on','foregroundcolor','w','backgroundcolor',CONN_gui.backgroundcolorA,'value',CONN_x.Setup.normalized);
                    else
                        switch(varargin{2}),
                            case 1, value=get(CONN_h.menus.m_setup_00{1},'value'); 
                                nsess=max(CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),value))); 
                                set(CONN_h.menus.m_setup_00{2},'string',[repmat('Session ',[nsess,1]),num2str((1:nsess)')],'value',min(nsess,get(CONN_h.menus.m_setup_00{2},'value')));
                                %nsess=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),value)); 
                                %set(CONN_h.menus.m_setup_00{2},'string',[repmat('Session ',[nsess,1]),num2str((1:nsess)')],'value',min(nsess,get(CONN_h.menus.m_setup_00{2},'value')));
                            case 2,
                            case 3,
								set(CONN_h.screen.hfig,'pointer','watch');
                                nsubs=get(CONN_h.menus.m_setup_00{1},'value');
                                nsessall=get(CONN_h.menus.m_setup_00{2},'value'); 
                                nsessmax=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsubs));
                                nfields=sum(sum(conn_bsxfun(@le,nsessall(:),nsessmax(:)')));
								filename=fliplr(deblank(fliplr(deblank(varargin{3}))));
                                txt=''; bak1=CONN_x.Setup.functional;bak2=CONN_x.Setup.nscans;
								if size(filename,1)==nfields, 
                                    hmsg=conn_msgbox('Loading files... please wait','');
                                    n0=0;
									for n1=1:length(nsubs),
										nsub=nsubs(n1);
                                        for nses=intersect(nsessall,1:nsessmax(n1))
                                            n0=n0+1;
                                            [CONN_x.Setup.functional{nsub}{nses},V]=conn_file(deblank(filename(n0,:)));
                                            CONN_x.Setup.nscans{nsub}{nses}=prod(size(V));
                                        end
                                    end
                                    txt=sprintf('%d files assigned to %d subjects/sessions\n',size(filename,1),nfields);
                                    if ishandle(hmsg), delete(hmsg); end
								elseif nfields==1,
                                    hmsg=conn_msgbox('Loading files... please wait','');
									for n1=1:length(nsubs),
										nsub=nsubs(n1);
                                        for nses=intersect(nsessall,1:nsessmax(n1))
                                            [CONN_x.Setup.functional{nsub}{nses},V]=conn_file(deblank(filename));
                                            CONN_x.Setup.nscans{nsub}{nses}=prod(size(V));
                                        end
                                    end
                                    txt=sprintf('%d files assigned to %d subjects/sessions\n',size(filename,1),nfields);
                                    if ishandle(hmsg), delete(hmsg); end
								else 
									errordlg(sprintf('mismatched number of files (%d files; %d subjects/sessions)',size(filename,1),nfields),'');
                                end
                                if ~isempty(txt)&&strcmp(questdlg(txt,'','Ok','Undo','Ok'),'Undo'), CONN_x.Setup.functional=bak1; CONN_x.Setup.nscans=bak2; end
								set(CONN_h.screen.hfig,'pointer','arrow');
                            case 4,
                                nsubs=get(CONN_h.menus.m_setup_00{1},'value');nsess=get(CONN_h.menus.m_setup_00{2},'value');
                                if ~isempty(CONN_x.Setup.functional{nsubs(1)}{nsess(1)}{1})
                                    tempstr=cellstr(CONN_x.Setup.functional{nsubs(1)}{nsess(1)}{1});
                                    [nill,tempstr_name,tempstr_ext]=cellfun(@spm_fileparts,tempstr,'uni',0);
                                    tempstr_name=cellfun(@(a,b)[a b],tempstr_name,tempstr_ext,'uni',0);
                                    set(CONN_h.menus.m_setup_00{3}.selectfile,'string',unique(tempstr_name));
                                    set(CONN_h.menus.m_setup_00{3}.folder,'string',fileparts(tempstr{1}));
                                    conn_filesearchtool(CONN_h.menus.m_setup_00{3}.folder,[],'folder',true);
                                end
                            case 6,
                                roiextract=get(CONN_h.menus.m_setup_00{6},'value');
                                if roiextract==3, 
                                    nsubs=get(CONN_h.menus.m_setup_00{1},'value');nsess=get(CONN_h.menus.m_setup_00{2},'value');
                                    filename=CONN_x.Setup.functional{nsubs(1)}{nsess(1)}{1};
                                    rule=conn_rulebasedfilename(filename,0,CONN_x.Setup.roiextract_rule,CONN_x.Setup.functional);
                                    if ~isequal(rule,0)
                                        CONN_x.Setup.roiextract=roiextract;
                                        CONN_x.Setup.roiextract_rule=rule;
                                    end
                                else
                                    CONN_x.Setup.roiextract=roiextract;
                                end
                            case 14,
                                val=get(CONN_h.menus.m_setup_00{14},'value');
                                switch(val)
                                    case 2, % slice viewer
                                        set(CONN_h.menus.m_setup_00{14},'value',1);
                                        nsubs=get(CONN_h.menus.m_setup_00{1},'value');nsess=get(CONN_h.menus.m_setup_00{2},'value');
                                        if ~isempty(CONN_x.Setup.functional{nsubs(1)}{nsess(1)}{1}(1,:))
                                            conn_slice_display([],CONN_x.Setup.functional{nsubs(1)}{nsess(1)}{1}(1,:));
                                        end
                                    case {3,4}, % check coregistration
                                        set(CONN_h.menus.m_setup_00{14},'value',1);
                                        nsubs=get(CONN_h.menus.m_setup_00{1},'value');nsess=get(CONN_h.menus.m_setup_00{2},'value');
                                        if val==3, files={};filenames={};
                                        else
                                            functional_template=fullfile(fileparts(which('spm')),'templates','EPI.nii');
                                            if isempty(dir(functional_template)), functional_template=fullfile(fileparts(which('spm')),'toolbox','OldNorm','EPI.nii'); end
                                            files={spm_vol(functional_template)}; filenames={functional_template};
                                        end
                                        for nsub=nsubs(:)',
%                                             try
                                                for nses=nsess(:)',
                                                    if val==3
                                                        if CONN_x.Setup.structural_sessionspecific,
                                                            files{end+1}=CONN_x.Setup.structural{nsub}{nses}{3}(1);
                                                            filenames{end+1}=CONN_x.Setup.structural{nsub}{nses}{1};
                                                        else
                                                            files{end+1}=CONN_x.Setup.structural{nsub}{1}{3}(1);
                                                            filenames{end+1}=CONN_x.Setup.structural{nsub}{1}{1};
                                                        end
                                                    end
                                                    for unsmoothedvolumes=0:1
                                                        Vsource=CONN_x.Setup.functional{nsub}{nses}{1};
                                                        if unsmoothedvolumes
                                                            try
                                                                if CONN_x.Setup.roiextract==4
                                                                    VsourceUnsmoothed=cellstr(CONN_x.Setup.roiextract_functional{nsub}{nses}{1});
                                                                else
                                                                    Vsource1=cellstr(Vsource);
                                                                    VsourceUnsmoothed=conn_rulebasedfilename(Vsource1,CONN_x.Setup.roiextract,CONN_x.Setup.roiextract_rule);
                                                                end
                                                                existunsmoothed=conn_existfile(VsourceUnsmoothed); %existunsmoothed=cellfun(@conn_existfile,VsourceUnsmoothed);
                                                                if ~all(existunsmoothed),
                                                                    fprintf('warning: unsmoothed data for subject %d session %d not found. Using original functional data instead for ROI extraction\n',nsub,nses);
                                                                else
                                                                    Vsource=char(VsourceUnsmoothed);
                                                                end
                                                            catch
                                                                fprintf('warning: error in CONN_x.Setup.roiextract for subject %d session %d not found. Using original functional data instead for ROI extraction\n',nsub,nses);
                                                            end
                                                        end
                                                        temp=cellstr(Vsource);
                                                        if numel(temp)==1,
                                                            temp=cellstr(conn_expandframe(temp{1}));
                                                        end
                                                        files{end+1}=spm_vol(temp{1});
                                                        filenames{end+1}=temp{1};
                                                    end
                                                end
%                                             catch
%                                                 error('No functional data entered for subject %d session %d',nsub,nses);
%                                             end
                                        end
                                        [nill,idx]=unique(filenames);
                                        spm_check_registration([files{sort(idx)}]);
                                    case 5, % spatial
                                        set(CONN_h.menus.m_setup_00{14},'value',1);
                                        conn('gui_setup_preproc','select','functional');
                                end
                                set(CONN_h.menus.m_setup_00{14},'value',1);
                                return;
%                             case 11,
%                                 normalized=get(CONN_h.menus.m_setup_00{11},'value');
%                                 if ~normalized, warndlg('Warning: Second-level voxel-level analyses not available for un-normalized data'); end
%                                 CONN_x.Setup.normalized=normalized;
                        end
                    end
                    nsubs=get(CONN_h.menus.m_setup_00{1},'value');nsess=get(CONN_h.menus.m_setup_00{2},'value');
                    for nsub=1:CONN_x.Setup.nsubjects
                        if length(CONN_x.Setup.functional)<nsub, CONN_x.Setup.functional{nsub}={}; end
                        for nses=1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsub))
                            if length(CONN_x.Setup.functional{nsub})<nses, CONN_x.Setup.functional{nsub}{nses}={}; end
                            if length(CONN_x.Setup.functional{nsub}{nses})<3, CONN_x.Setup.functional{nsub}{nses}{3}=[]; end
                        end
					end
					ok=1; ko=[];
                    for nsub=nsubs(:)'
                        for nses=intersect(1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsub)),nsess(:)')
                            if isempty(ko), ko=CONN_x.Setup.functional{nsub}{nses}{1};
                            else  if ~all(size(ko)==size(CONN_x.Setup.functional{nsub}{nses}{1})) || ~all(all(ko==CONN_x.Setup.functional{nsub}{nses}{1})), ok=0; end; end
                        end
                    end
                    if isempty(nses)||numel(CONN_x.Setup.functional{nsub})<nses||isempty(CONN_x.Setup.functional{nsub}{nses}{1})
                        conn_menu('updateimage',CONN_h.menus.m_setup_00{5},[]);
                        set(CONN_h.menus.m_setup_00{4},'string','','tooltipstring','');
                        set(CONN_h.menus.m_setup_00{14},'visible','off'); 
                    elseif ok
                        conn_menu('updateimage',CONN_h.menus.m_setup_00{5},CONN_x.Setup.functional{nsub}{nses}{3});
                        set(CONN_h.menus.m_setup_00{14},'visible','on'); 
                        tempstr=cellstr(CONN_x.Setup.functional{nsub}{nses}{1});
                        if numel(tempstr)>1, tempstr=tempstr([1 end]); end
                        set(CONN_h.menus.m_setup_00{4},'string',conn_cell2html(CONN_x.Setup.functional{nsub}{nses}{2}),'tooltipstring',conn_cell2html(tempstr));
                    else
                        conn_menu('updateimage',CONN_h.menus.m_setup_00{5},[]);
                        set(CONN_h.menus.m_setup_00{4},'string','Multiple files','tooltipstring','');
                        set(CONN_h.menus.m_setup_00{14},'visible','on'); 
                    end
					ok=1; ko=[];
                    for nsub=1:CONN_x.Setup.nsubjects
                        for nses=1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsub))
                            if isempty(CONN_x.Setup.functional{nsub}{nses}{1}), ok=0; ko=[nsub nses]; break; end
                        end
                        if ~ok, break; end
                    end
                    conn_menumanager('helpstring','');
                    if ~ok, conn_menumanager('helpstring',sprintf('WARNING: incomplete information (enter functional file(s) for subject %d session %d)',ko(1),ko(2))); end
                case 2, %structural
                    boffset=[.02 0 0 0];
                    if nargin<2,
                        conn_menu('frame',boffset+[.19,.15,.40,.72],'STRUCTURAL DATA');
						CONN_h.menus.m_setup_00{13}=conn_menu('popup',boffset+[.200,.78,.15,.05],'',{'Session-invariant structural data','Session-specific structural data'},'<HTML>(only applies to experiments with multiple sessions/runs) <br/> - Select session-invariant if the structural data does not change across sessions (enter one structural volume per subject) <br/> - Select session-specific if the structural data may change across sessions (enter one structural volume per session; e.g. longitudinal studies)</HTML>','conn(''gui_setup'',13);');
						CONN_h.menus.m_setup_00{1}=conn_menu('listbox',boffset+[.200,.25,.075,.48],'Subjects','','Select subject(s)','conn(''gui_setup'',1);');
						[CONN_h.menus.m_setup_00{2},CONN_h.menus.m_setup_00{15}]=conn_menu('listbox',boffset+[.275,.25,.075,.48],'Sessions','','Select session','conn(''gui_setup'',2);');
						CONN_h.menus.m_setup_00{3}=conn_menu('filesearch',[],'Select structural data files','*.img; *.nii; *.mgh; *.mgz; *.gz','',{@conn,'gui_setup',3},'conn(''gui_setup'',4);');
						CONN_h.menus.m_setup_00{4}=conn_menu('pushbutton2', boffset+[.35,.76,.23,.10],'','','','conn(''gui_setup'',4);');
						CONN_h.menus.m_setup_00{5}=conn_menu('image',boffset+[.36,.23,.20,.53]);
                        CONN_h.menus.m_setup_00{6}=conn_menu('popup',boffset+[.38,.18,.16,.045],'',{'Display structural volume','Display structural surface'},'select display view (surface view only available for freesurfer-generated files)','conn(''gui_setup'',6);');
                        set([CONN_h.menus.m_setup_00{4} CONN_h.menus.m_setup_00{6}],'visible','off'); conn_menumanager('onregion',[CONN_h.menus.m_setup_00{4} CONN_h.menus.m_setup_00{6}],1,boffset+[.35,.18,.23,.70]);
                        %CONN_h.menus.m_setup_00{6}=uicontrol('style','popupmenu','units','norm','position',boffset+[.31,.20,.13,.04],'string',{'Structural volume','Structural surface'},'value',2,'backgroundcolor',CONN_gui.backgroundcolorA,'foregroundcolor','w','fontsize',8+CONN_gui.font_offset,'callback','conn(''gui_setup'',6);','tooltipstring','select display view (surface view only available for freesurfer-generated files)');
                        CONN_h.menus.m_setup_00{14}=conn_menu('popup0',boffset+[.20,.15,.15,.05],'',{'<HTML><i> - structural tools:</i></HTML>','Slice viewer','Check anatomical/MNI coregistration','Apply individual preprocessing step'},'<HTML> - <i>slice viewer</i> displays strucutral volume slices <br/><i>check registration</i> checks the coregistration between the selected subject anatomical files and an MNI template<br/> - <i>preprocessing</i> runs individual preprocessing step on structural volumes (e.g. normalization, segmentation, etc.)</HTML>','conn(''gui_setup'',14);');
                        %CONN_h.menus.m_setup_00{14}=uicontrol('style','popupmenu','units','norm','position',boffset+[.31,.15,.13,.04],'string',{'<HTML><i> - options:</i></HTML>','preprocessing steps'},'fontsize',8+CONN_gui.font_offset,'foregroundcolor','w','backgroundcolor',CONN_gui.backgroundcolorA,'callback','conn(''gui_setup'',14);','tooltipstring','Structural volumes additional options');
						%CONN_h.menus.m_setup_00{11}=conn_menu('checkbox',[.31,.205,.02,.04],'spatially-normalized images','','','conn(''gui_setup'',11);');
						set(CONN_h.menus.m_setup_00{1},'string',[repmat('Subject ',[CONN_x.Setup.nsubjects,1]),num2str((1:CONN_x.Setup.nsubjects)')],'max',2);
						set(CONN_h.menus.m_setup_00{3}.files,'max',2);
                        nsess=CONN_x.Setup.nsessions(1); set(CONN_h.menus.m_setup_00{2},'string',[repmat('Session ',[nsess,1]),num2str((1:nsess)')],'value',min(nsess,get(CONN_h.menus.m_setup_00{2},'value')),'max',2);
                        set(CONN_h.menus.m_setup_00{13},'value', 1+CONN_x.Setup.structural_sessionspecific);
                        if all(CONN_x.Setup.nsessions==1), set(CONN_h.menus.m_setup_00{13},'foregroundcolor',[.5 .5 .5]); end
                        %if all(CONN_x.Setup.nsessions==1), set(CONN_h.menus.m_setup_00{13},'visible','off'); end
                        %hc1=uicontextmenu;uimenu(hc1,'Label','go to source folder','callback','conn(''gui_setup'',4);');set(CONN_h.menus.m_setup_00{4},'uicontextmenu',hc1);
                        %if ~isfield(CONN_x.Setup,'normalized'), CONN_x.Setup.normalized=1; end
                        %set([CONN_h.menus.m_setup_00{11}],'visible','on','foregroundcolor','w','backgroundcolor',CONN_gui.backgroundcolorA,'value',CONN_x.Setup.normalized);
						%for nsub=1:CONN_x.Setup.nsubjects, 
						%	if length(CONN_x.Setup.structural)<nsub || isempty(CONN_x.Setup.structural{nsub}), 
						%		conn('gui_setup',3,fullfile(fileparts(which('spm')),'canonical','avg152T1.nii'),nsub); 
						%	end; 
						%end
                    else
                        switch(varargin{2}),
                            case 1, 
                                value=get(CONN_h.menus.m_setup_00{1},'value'); 
                                nsess=max(CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),value))); 
                                set(CONN_h.menus.m_setup_00{2},'string',[repmat('Session ',[nsess,1]),num2str((1:nsess)')],'value',min(nsess,get(CONN_h.menus.m_setup_00{2},'value')));
                            case 3,
                                if nargin<4, nsubs=get(CONN_h.menus.m_setup_00{1},'value'); else  nsubs=varargin{4}; end
                                nsessall=get(CONN_h.menus.m_setup_00{2},'value'); 
                                nsessmax=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsubs));
                                if ~CONN_x.Setup.structural_sessionspecific, nsessall=1:max(nsessmax); end
								filename=fliplr(deblank(fliplr(deblank(varargin{3}))));
                                nfields=sum(sum(conn_bsxfun(@le,nsessall(:),nsessmax(:)')));
                                txt=''; bak1=CONN_x.Setup.rois.files;bak2=CONN_x.Setup.structural;
								if ~CONN_x.Setup.structural_sessionspecific&&size(filename,1)==numel(nsubs),
                                    hmsg=conn_msgbox('Loading files... please wait','');
                                    askimport=[];
									for n1=1:length(nsubs),
										nsub=nsubs(n1);
                                        nsess=intersect(nsessall,1:nsessmax(n1));
                                        for n2=1:length(nsess)
                                            nses=nsess(n2);
                                            V=conn_file(deblank(filename(n1,:)));
                                            if conn_importaseg(fileparts(V{1}),[],true)
                                                if isempty(askimport)
                                                    answ=questdlg('Freesurfer aseg.mgz segmentation files found. Do you want to import Gray/White/CSF masks from these files?','','Yes','No','Yes');
                                                    if strcmp(answ,'Yes'), askimport=true;
                                                    else askimport=false;
                                                    end
                                                end
                                                if askimport
                                                    filenames=conn_importaseg(fileparts(V{1}));
                                                    for nseg=1:3
                                                        CONN_x.Setup.rois.files{nsub}{nseg}{nses}=conn_file(filenames{nseg});
                                                    end
                                                end
                                            end
                                            CONN_x.Setup.structural{nsub}{nses}=V;
                                        end
									end
                                    txt=sprintf('%d files assigned to %d subjects\n',size(filename,1),length(nsubs));
                                    set(CONN_h.menus.m_setup_00{6},'value',2);
                                    if ishandle(hmsg), delete(hmsg); end
                                elseif CONN_x.Setup.structural_sessionspecific&&size(filename,1)==nfields,
                                    hmsg=conn_msgbox('Loading files... please wait','');
                                    askimport=[];
                                    n0=1;
									for n1=1:length(nsubs),
										nsub=nsubs(n1);
                                        nsess=intersect(nsessall,1:nsessmax(n1));
                                        for n2=1:length(nsess)
                                            nses=nsess(n2);
                                            V=conn_file(deblank(filename(n0,:)));
                                            if conn_importaseg(fileparts(V{1}),[],true)
                                                if isempty(askimport)
                                                    answ=questdlg('Freesurfer aseg.mgz segmentation files found. Do you want to import Gray/White/CSF masks from these files?','','Yes','No','Yes');
                                                    if strcmp(answ,'Yes'), askimport=true;
                                                    else askimport=false;
                                                    end
                                                end
                                                if askimport
                                                    filenames=conn_importaseg(fileparts(V{1}));
                                                    for nseg=1:3
                                                        CONN_x.Setup.rois.files{nsub}{nseg}{nses}=conn_file(filenames{nseg});
                                                    end
                                                end
                                            end
                                            CONN_x.Setup.structural{nsub}{nses}=V;
                                            %[V,str,icon]=conn_getinfo(deblank(filename(n1,:)));
                                            %CONN_x.Setup.structural{nsub}={deblank(filename(n1,:)),str,icon};
                                            n0=n0+1;
                                        end
									end
                                    txt=sprintf('%d files assigned to %d subjects/sessions\n',size(filename,1),nfields);
                                    set(CONN_h.menus.m_setup_00{6},'value',2);
                                    if ishandle(hmsg), delete(hmsg); end
								elseif size(filename,1)==1,
                                    hmsg=conn_msgbox('Loading files... please wait','');
                                    nsessall=get(CONN_h.menus.m_setup_00{2},'value');
                                    nsessmax=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsubs));
                                    if ~CONN_x.Setup.structural_sessionspecific, nsessall=1:max(nsessmax); end
                                    V=conn_file(deblank(filename));
                                    for n1=1:length(nsubs),
                                        nsub=nsubs(n1);
                                        nsess=intersect(nsessall,1:nsessmax(n1));
                                        for n2=1:length(nsess)
                                            nses=nsess(n2);
                                            CONN_x.Setup.structural{nsub}{nses}=V;
                                        end
                                    end
									%[V,str,icon]=conn_getinfo(deblank(filename));
									%for nsub=nsubs(:)',CONN_x.Setup.structural{nsub}={deblank(filename),str,icon};end
                                    txt=sprintf('%d files assigned to %d subjects\n',size(filename,1),length(nsubs));
                                    set(CONN_h.menus.m_setup_00{6},'value',2);
                                    if ishandle(hmsg), delete(hmsg); end
								else 
                                    if CONN_x.Setup.structural_sessionspecific, errordlg(sprintf('mismatched number of files (%d files; %d subjects/sessions)',size(filename,1),nfields),'');
                                    else errordlg(sprintf('mismatched number of files (%d files; %d subjects)',size(filename,1),length(nsubs)),'');
                                    end
                                end
                                if ~isempty(txt)&&strcmp(questdlg(txt,'','Ok','Undo','Ok'),'Undo'), CONN_x.Setup.rois.files=bak1;CONN_x.Setup.structural=bak2; end
                            case 4,
                                nsubs=get(CONN_h.menus.m_setup_00{1},'value');
                                nsess=get(CONN_h.menus.m_setup_00{2},'value');
                                if ~CONN_x.Setup.structural_sessionspecific, nsess=1; end
                                if ~isempty(CONN_x.Setup.structural{nsubs(1)}{nsess(1)}{1})
                                    tempstr=cellstr(CONN_x.Setup.structural{nsubs(1)}{nsess(1)}{1});
                                    [nill,tempstr_name,tempstr_ext]=cellfun(@spm_fileparts,tempstr,'uni',0);
                                    tempstr_name=cellfun(@(a,b)[a b],tempstr_name,tempstr_ext,'uni',0);
                                    set(CONN_h.menus.m_setup_00{3}.selectfile,'string',unique(tempstr_name));
                                    set(CONN_h.menus.m_setup_00{3}.folder,'string',fileparts(tempstr{1}));
                                    conn_filesearchtool(CONN_h.menus.m_setup_00{3}.folder,[],'folder',true);
                                end
                            case 6,
                                if nargin<4, nsubs=get(CONN_h.menus.m_setup_00{1},'value'); else  nsubs=varargin{4}; end
                                nsess=get(CONN_h.menus.m_setup_00{2},'value');
                                value=get(CONN_h.menus.m_setup_00{6},'value');
                                if ~CONN_x.Setup.structural_sessionspecific, nsess=1; end
                                if value==2&&~conn_checkFSfiles(CONN_x.Setup.structural{nsubs(1)}{nsess(1)}{3})
                                    conn_checkFSfiles(CONN_x.Setup.structural{nsubs(1)}{nsess(1)}{3},true);
                                    uiwait(warndlg({'CONN requires Freesurfer-generated subject-specific cortical surfaces for surface-based analyses',' ','No Freesurfer files found (see Matlab command window for details)','Only volume-based analyses available'},''));
                                end
%                             case 11,
%                                 normalized=get(CONN_h.menus.m_setup_00{11},'value');
%                                 if ~normalized, warndlg('Warning: Second-level analyses not available for un-normalized data'); end
%                                 CONN_x.Setup.normalized=normalized;
                            case 13,
                                CONN_x.Setup.structural_sessionspecific=get(CONN_h.menus.m_setup_00{13},'value')-1;
                            case 14,
                                val=get(CONN_h.menus.m_setup_00{14},'value');
                                switch(val)
                                    case 2, % slice viewer
                                        set(CONN_h.menus.m_setup_00{14},'value',1);
                                        nsubs=get(CONN_h.menus.m_setup_00{1},'value');
                                        nsess=get(CONN_h.menus.m_setup_00{2},'value');
                                        if ~CONN_x.Setup.structural_sessionspecific, nsess=1; end
                                        if ~isempty(CONN_x.Setup.structural{nsubs(1)}{nsess(1)}{1})
                                            conn_slice_display([],CONN_x.Setup.structural{nsubs(1)}{nsess(1)}{1});
                                        end
                                    case 3, % checkregistration
                                        set(CONN_h.menus.m_setup_00{14},'value',1);
                                        nsubs=get(CONN_h.menus.m_setup_00{1},'value');
                                        nsess=get(CONN_h.menus.m_setup_00{2},'value');
                                        sessionspecific=CONN_x.Setup.structural_sessionspecific;
                                        if ~sessionspecific, nsess=1; end
                                        structural_template=fullfile(fileparts(which('spm')),'templates','T1.nii');
                                        if isempty(dir(structural_template)), structural_template=fullfile(fileparts(which('spm')),'toolbox','OldNorm','T1.nii'); end
                                        files={spm_vol(structural_template)};filenames={structural_template};
                                        for n1=1:numel(nsubs)
                                            nsub=nsubs(n1);
                                            nsesst=intersect(nsess,1:CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub)));
                                            for n2=1:length(nsesst)
                                                nses=nsesst(n2);
                                                files{end+1}=CONN_x.Setup.structural{nsub}{nses}{3}(1);
                                                filenames{end+1}=CONN_x.Setup.structural{nsub}{nses}{1};
                                            end
                                        end
                                        [nill,idx]=unique(filenames);
                                        spm_check_registration([files{sort(idx)}]);
                                    case 4, % spatial
                                        set(CONN_h.menus.m_setup_00{14},'value',1);
                                        conn('gui_setup_preproc','select','structural');
                                end
                                set(CONN_h.menus.m_setup_00{14},'value',1);
                                return;
                        end
                    end
                    nsubs=get(CONN_h.menus.m_setup_00{1},'value');
                    nsessmax=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsubs));
                    nsess=get(CONN_h.menus.m_setup_00{2},'value');
                    if ~CONN_x.Setup.structural_sessionspecific, nsess=1; end
                    volsurf=get(CONN_h.menus.m_setup_00{6},'value');
                    if ~CONN_x.Setup.structural_sessionspecific, set([CONN_h.menus.m_setup_00{2}, CONN_h.menus.m_setup_00{15}],'visible','off');
                    else set([CONN_h.menus.m_setup_00{2}, CONN_h.menus.m_setup_00{15}],'visible','on');
                    end

                    for nsub=1:CONN_x.Setup.nsubjects
                        if length(CONN_x.Setup.structural)<nsub, CONN_x.Setup.structural{nsub}={}; end
                        for nses=1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsub))
                            if length(CONN_x.Setup.structural{nsub})<nses, CONN_x.Setup.structural{nsub}{nses}={}; end
                            if length(CONN_x.Setup.structural{nsub}{nses})<3, CONN_x.Setup.structural{nsub}{nses}{3}=[]; end
                        end
                    end
					ok=1; ko=[];
                    for n1=1:length(nsubs),
                        nsub=nsubs(n1);
                        for nses=intersect(nsess(:)',1:nsessmax(n1))
                            if isempty(ko), ko=CONN_x.Setup.structural{nsub}{nses}{1};
                            else  if ~all(size(ko)==size(CONN_x.Setup.structural{nsub}{nses}{1})) || ~all(all(ko==CONN_x.Setup.structural{nsub}{nses}{1})), ok=0; end; end
                        end
                    end
                    if isempty(nses)||numel(CONN_x.Setup.structural{nsub})<nses||isempty(CONN_x.Setup.structural{nsub}{nses}{1})
						conn_menu('updateimage',CONN_h.menus.m_setup_00{5},[]);
                        set(CONN_h.menus.m_setup_00{14},'visible','off'); 
						set(CONN_h.menus.m_setup_00{4},'string','','tooltipstring','');
                    elseif ok,
                        vol=CONN_x.Setup.structural{nsub}{nses}{3};
                        if conn_checkFSfiles(CONN_x.Setup.structural{nsub}{nses}{3}), 
                            if volsurf>1, vol.checkSurface=true; end
                        else set(CONN_h.menus.m_setup_00{6},'value',1);
                        end
						conn_menu('updateimage',CONN_h.menus.m_setup_00{5},vol);
                        set(CONN_h.menus.m_setup_00{14},'visible','on'); 
                        tempstr=cellstr(CONN_x.Setup.structural{nsub}{nses}{1});
 						set(CONN_h.menus.m_setup_00{4},'string',conn_cell2html(CONN_x.Setup.structural{nsub}{nses}{2}),'tooltipstring',conn_cell2html(tempstr));
					else  
						conn_menu('updateimage',CONN_h.menus.m_setup_00{5},[]);
                        set(CONN_h.menus.m_setup_00{14},'visible','on'); 
						set(CONN_h.menus.m_setup_00{4},'string','multiple files','tooltipstring','');
					end
                    if ~(nsubs(1)<=numel(CONN_x.Setup.structural)&&nsess(1)<=numel(CONN_x.Setup.structural{nsubs(1)})&&isstruct(CONN_x.Setup.structural{nsubs(1)}{nsess(1)}{3})), set([CONN_h.menus.m_setup_00{6},CONN_h.menus.m_setup_00{14}],'visible','off'); end
					ok=1; ko=[];
                    for nsub=1:CONN_x.Setup.nsubjects
                        nsessall=1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsub));
                        if ~CONN_x.Setup.structural_sessionspecific, nsessall=1; end
                        for nses=nsessall
                            if isempty(CONN_x.Setup.structural{nsub}{nses}{1}), ok=0; ko=[nsub nses]; break; end
                        end
                        if ~ok, break; end
                    end
                    conn_menumanager('helpstring','');
                    if ~ok, conn_menumanager('helpstring',sprintf('WARNING: incomplete information (enter structural file for subject %d session %d)',ko(1),ko(2))); end
                case 4, %ROIs
                    boffset=[.06 .06 0 0];
                    if nargin<2,
                        conn_menu('frame',boffset+[.13,.03,.50,.77],'ROI DATA');
						CONN_h.menus.m_setup_00{1}=conn_menu('listbox',boffset+[.140,.13,.075,.62],'ROIs','',['<HTML>Select ROI <br/> - click after the last item to add a new ROI <br/> - ',CONN_gui.rightclick,'-click for additional options</HTML>'],'conn(''gui_setup'',1);','conn(''gui_setup'',8);');
						[CONN_h.menus.m_setup_00{2},CONN_h.menus.m_setup_00{19}]=conn_menu('listbox',boffset+[.215,.13,.075,.62],'Subjects','','Select subject(s)','conn(''gui_setup'',2);');
						[CONN_h.menus.m_setup_00{16},CONN_h.menus.m_setup_00{15}]=conn_menu('listbox',boffset+[.29,.13,.075,.62],'Sessions','','Select session','conn(''gui_setup'',16);');
						CONN_h.menus.m_setup_00{3}=conn_menu('filesearch',[],'Select ROI definition files','*.img; *.nii; *.tal; *.mgh; *.mgz; *.annot; *.gz','',{@conn,'gui_setup',3},'conn(''gui_setup'',4);');
						CONN_h.menus.m_setup_00{4}=conn_menu('pushbutton2', boffset+[.36,.62,.24,.08],'','','','conn(''gui_setup'',4);');
						CONN_h.menus.m_setup_00{5}=conn_menu('image',boffset+[.37,.15,.24,.47]);
                        set([CONN_h.menus.m_setup_00{4}],'visible','off'); conn_menumanager('onregion',[CONN_h.menus.m_setup_00{4}],1,boffset+[.36,.15,.26,.56]);
						CONN_h.menus.m_setup_00{6}=conn_menu('edit',boffset+[.38,.71,.10,.04],'ROI name','','ROI name','conn(''gui_setup'',6);');
						CONN_h.menus.m_setup_00{7}=conn_menu('edit',boffset+[.49,.71,.06,.04],'Dimensions','','<HTML>number of dimensions characterizing the ROI activation <br/> - use <b>1</b> to extract only the mean BOLD timeseries within the ROI <br/> - use <b>2</b> or above to extract one or several PCA components as well</HTML>','conn(''gui_setup'',7);');
						CONN_h.menus.m_setup_00{10}=conn_menu('checkbox',boffset+[.38,.115,.02,.03],'Multiple ROIs','','<HTML>ROI file contains multiple ROI definitions (atlas file)<br/> - Atlas files combine an image file describing multiple ROIs locations and one text file describing ROI labels<br/> - Image file should contain N integer values, from 1 to N, identifying the different ROI locations<br/> - Text file should have the same base filename and a .txt extension, and it should contain a list with the N ROI labels (one per line) <br/> - Alternatively, if the ROI numbers in the image file are not sequential, the associated labels file can be defined as: <br/> a) a .txt file with two space-separated columns (ROI number ROI label) and N rows; or b) a .csv file with two comma-separated <br/>columns and one header row (ROI number,ROI label)</HTML>','conn(''gui_setup'',10);');
						CONN_h.menus.m_setup_00{18}=conn_menu('checkbox',boffset+[.38,.080,.02,.03],'Subject-specific ROI','','Use subject-specific ROI files (one file per subject)','conn(''gui_setup'',18);');
						[CONN_h.menus.m_setup_00{11},CONN_h.menus.m_setup_00{17}]=conn_menu('checkbox',boffset+[.38,.045,.02,.03],'Session-specific ROI','','Use sesion-specific ROI files (one file per session)','conn(''gui_setup'',11);');
						CONN_h.menus.m_setup_00{9}=conn_menu('checkbox',boffset+[.50,.115,.02,.03],'Mask with Grey Matter','','extract only from grey matter voxels (intersect this ROI with each subject''s grey matter mask)','conn(''gui_setup'',9);');
						CONN_h.menus.m_setup_00{13}=conn_menu('checkbox',boffset+[.50,.080,.02,.03],'Use ROI source data','','<HTML>source of functional data for ROI timeseries extraction<br/> - when checked CONN extracts ROI BOLD timeseries from the funcional volumes defined in the field "<i>Setup.Functional.Functional data for <b>ROI</b>-level analyses: </i>" (default behavior; e.g. unsmoothed volumes)<br/> - when unchecked CONN extracts ROI BOLD timeseries from the functional volumes defined in the field "<i>Setup.Functional.Functional data for <b>voxel</b>-level analyses: </i>" (non-default behavior; e.g. smoothed volumes)</HTML>','conn(''gui_setup'',13);');
						[CONN_h.menus.m_setup_00{12},CONN_h.menus.m_setup_00{20}]=conn_menu('checkbox',boffset+[.50,.045,.02,.03],'Regress out covariates','','<HTML>regress out covariates before performing PCA decomposition of BOLD signal within ROI<br/> - this field only applies when extracting more than 1 dimension (<i>Dimensions</i> > 1) from an ROI</HTML>','conn(''gui_setup'',12);');
                        CONN_h.menus.m_setup_00{14}=conn_menu('popup0',boffset+[.14,.03,.20,.05],'',{'<HTML><i> - ROI tools:</i></HTML>','Slice viewer','Slice viewer with structural overlay','Check ROI/functional coregistration','Check ROI/anatomical coregistration'},'<HTML> - <i>slice viewer</i> displays ROI slices<br/>  - <i>check registration</i> checks the coregistration of the selected subject ROI and anatomical/functional files</HTML>','conn(''gui_setup'',14);');
                        %CONN_h.menus.m_setup_00{14}=uicontrol('style','popupmenu','units','norm','position',boffset+[.37,.08,.15,.04],'string',{'<HTML><i> - options:</i></HTML>','check registration'},'foregroundcolor','w','backgroundcolor',CONN_gui.backgroundcolorA,'fontsize',8+CONN_gui.font_offset,'callback','conn(''gui_setup'',14);','tooltipstring','ROIs additional options');
                        %CONN_h.menus.m_setup_00{14}=uicontrol('style','pushbutton','units','norm','position',boffset+[.37,.08,.15,.04],'string','Check registration','tooltipstring','Check coregistration of ROI and structural files for selected subject(s)/roi(s)','callback','conn(''gui_setup'',14);','fontsize',8+CONN_gui.font_offset);
						set(CONN_h.menus.m_setup_00{2},'string',[repmat('Subject ',[CONN_x.Setup.nsubjects,1]),num2str((1:CONN_x.Setup.nsubjects)')],'value',1,'max',2);
						set(CONN_h.menus.m_setup_00{1},'string',CONN_x.Setup.rois.names,'max',1);
						set(CONN_h.menus.m_setup_00{6},'visible','off');
						set(CONN_h.menus.m_setup_00{3}.files,'max',2);
                        set([CONN_h.menus.m_setup_00{9},CONN_h.menus.m_setup_00{10}],'value',0,'visible','off');
                        nsess=CONN_x.Setup.nsessions(1); set(CONN_h.menus.m_setup_00{16},'string',[repmat('Session ',[nsess,1]),num2str((1:nsess)')],'value',min(nsess,get(CONN_h.menus.m_setup_00{2},'value')),'max',2);
                        set(CONN_h.menus.m_setup_00{11},'value', CONN_x.Setup.structural_sessionspecific);
                        if all(CONN_x.Setup.nsessions==1), set(CONN_h.menus.m_setup_00{17},'foregroundcolor',[.5 .5 .5]); end
                        set(CONN_h.menus.m_setup_00{18},'value', 1);
                        %if ~isfield(CONN_x.Setup,'normalized'), CONN_x.Setup.normalized=1; end
                        %set([CONN_h.menus.m_setup_00{11}],'value',CONN_x.Setup.normalized);
                        hc1=uicontextmenu;uimenu(hc1,'Label','remove selected ROIs','callback','conn(''gui_setup'',8);');set(CONN_h.menus.m_setup_00{1},'uicontextmenu',hc1);
                        %if all(CONN_x.Setup.nsessions==1), set([CONN_h.menus.m_setup_00{11},CONN_h.menus.m_setup_00{17}],'visible','off'); end
                        %hc1=uicontextmenu;uimenu(hc1,'Label','go to source folder','callback','conn(''gui_setup'',4);');set(CONN_h.menus.m_setup_00{4},'uicontextmenu',hc1);
                    else
                        switch(varargin{2}),
                            case 1, 
                            case 2, 
                                value=get(CONN_h.menus.m_setup_00{2},'value'); 
                                nsess=max(CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),value))); 
                                set(CONN_h.menus.m_setup_00{16},'string',[repmat('Session ',[nsess,1]),num2str((1:nsess)')],'value',min(nsess,get(CONN_h.menus.m_setup_00{16},'value')));
                            case 3,
								nrois=get(CONN_h.menus.m_setup_00{1},'value'); 
                                nsubs=get(CONN_h.menus.m_setup_00{2},'value'); 
                                nsessall=get(CONN_h.menus.m_setup_00{16},'value'); 
                                if nrois>3, subjectspecific=CONN_x.Setup.rois.subjectspecific(nrois);
                                else subjectspecific=1;
                                end
                                if ~subjectspecific, nsubs=1:CONN_x.Setup.nsubjects; end
                                nsessmax=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsubs));
                                if nrois>3, sessionspecific=CONN_x.Setup.rois.sessionspecific(nrois);
                                else sessionspecific=CONN_x.Setup.structural_sessionspecific;
                                end
                                if ~sessionspecific, nsessall=1:max(nsessmax); end
								filename=fliplr(deblank(fliplr(deblank(varargin{3}))));
                                nfields0=sum(conn_bsxfun(@le,nsessall(:),nsessmax(:)'),1);
                                nfields=sum(nfields0,2);
                                txt=''; bak1=CONN_x.Setup.rois;
								if ~sessionspecific&&~subjectspecific&&size(filename,1)==1,
                                    hmsg=conn_msgbox('Loading files... please wait','');
									for n1=1:length(nsubs),
										nsub=nsubs(n1);
                                        V=conn_file(deblank(filename(1,:)));
                                        nsess=intersect(nsessall,1:nsessmax(n1));
                                        for n2=1:length(nsess)
                                            nses=nsess(n2);
                                            CONN_x.Setup.rois.files{nsub}{nrois}{nses}=V;
                                        end
                                        filename1=CONN_x.Setup.rois.files{nsub}{nrois}{1}{1};
                                        [nill,nill,nameext]=fileparts(filename1);%deblank(filename(n1,:)));
									end
                                    CONN_x.Setup.rois.multiplelabels(nrois)=(strcmp(nameext,'.img')|strcmp(nameext,'.nii')|strcmp(nameext,'.mgz'))&(~isempty(dir(conn_prepend('',deblank(filename1),'.txt')))|~isempty(dir(conn_prepend('',deblank(filename1),'.csv')))|~isempty(dir(conn_prepend('',deblank(filename1),'.xls'))));
                                    txt=sprintf('%d files assigned to %d subjects\n',size(filename,1),length(nsubs));
                                    if ishandle(hmsg), delete(hmsg); end
                                elseif ~sessionspecific&&subjectspecific&&size(filename,1)==length(nsubs),
                                    hmsg=conn_msgbox('Loading files... please wait','');
									for n1=1:length(nsubs),
										nsub=nsubs(n1);
                                        V=conn_file(deblank(filename(n1,:)));
                                        nsess=intersect(nsessall,1:nsessmax(n1));
                                        for n2=1:length(nsess)
                                            nses=nsess(n2);
                                            CONN_x.Setup.rois.files{nsub}{nrois}{nses}=V;
                                        end
                                        filename1=CONN_x.Setup.rois.files{nsub}{nrois}{1}{1};
                                        [nill,nill,nameext]=fileparts(filename1);%deblank(filename(n1,:)));
									end
                                    CONN_x.Setup.rois.multiplelabels(nrois)=(strcmp(nameext,'.img')|strcmp(nameext,'.nii')|strcmp(nameext,'.mgz'))&(~isempty(dir(conn_prepend('',deblank(filename1),'.txt')))|~isempty(dir(conn_prepend('',deblank(filename1),'.csv')))|~isempty(dir(conn_prepend('',deblank(filename1),'.xls'))));
                                    txt=sprintf('%d files assigned to %d subjects\n',size(filename,1),length(nsubs));
                                    if ishandle(hmsg), delete(hmsg); end
                                elseif sessionspecific&&~subjectspecific&&all(size(filename,1)==nfields0),
                                    hmsg=conn_msgbox('Loading files... please wait','');
                                    nsess=intersect(nsessall,1:nsessmax(1));
                                    for n2=1:length(nsess)
                                        nses=nsess(n2);
                                        V=conn_file(deblank(filename(n2,:)));
                                        for n1=1:length(nsubs),
                                            nsub=nsubs(n1);
                                            CONN_x.Setup.rois.files{nsub}{nrois}{nses}=V;
                                        end
                                        filename1=CONN_x.Setup.rois.files{nsub}{nrois}{nses}{1};
                                        [nill,nill,nameext]=fileparts(filename1);%deblank(filename(n1,:)));
									end
                                    CONN_x.Setup.rois.multiplelabels(nrois)=(strcmp(nameext,'.img')|strcmp(nameext,'.nii')|strcmp(nameext,'.mgz'))&(~isempty(dir(conn_prepend('',deblank(filename1),'.txt')))|~isempty(dir(conn_prepend('',deblank(filename1),'.csv')))|~isempty(dir(conn_prepend('',deblank(filename1),'.xls'))));
                                    txt=sprintf('%d files assigned to %d sessions\n',size(filename,1),length(nsess));
                                    if ishandle(hmsg), delete(hmsg); end
                                elseif subjectspecific&&sessionspecific&&size(filename,1)==nfields,
                                    hmsg=conn_msgbox('Loading files... please wait','');
                                    n0=1;
									for n1=1:length(nsubs),
										nsub=nsubs(n1);
                                        nsess=intersect(nsessall,1:nsessmax(n1));
                                        for n2=1:length(nsess)
                                            tfilename=deblank(filename(n0,:));
                                            nses=nsess(n2);
                                            CONN_x.Setup.rois.files{nsub}{nrois}{nses}=conn_file(tfilename);
                                            filename1=CONN_x.Setup.rois.files{nsub}{nrois}{nses}{1};
                                            [nill,nill,nameext]=fileparts(filename1);%deblank(filename(n1,:)));
                                            n0=n0+1;
                                        end
									end
                                    CONN_x.Setup.rois.multiplelabels(nrois)=(strcmp(nameext,'.img')|strcmp(nameext,'.nii')|strcmp(nameext,'.mgz'))&(~isempty(dir(conn_prepend('',deblank(filename1),'.txt')))|~isempty(dir(conn_prepend('',deblank(filename1),'.csv')))|~isempty(dir(conn_prepend('',deblank(filename1),'.xls'))));
                                    txt=sprintf('%d files assigned to %d subjects/sessions\n',size(filename,1),nfields);
                                    if ishandle(hmsg), delete(hmsg); end
								elseif size(filename,1)==1,
                                    hmsg=conn_msgbox('Loading files... please wait','');
									temp=conn_file(deblank(filename));
									for n1=1:length(nsubs),
										nsub=nsubs(n1);
                                        nsess=intersect(nsessall,1:nsessmax(n1));
                                        for n2=1:length(nsess)
                                            nses=nsess(n2);
                                            CONN_x.Setup.rois.files{nsub}{nrois}{nses}=temp;
                                        end
                                    end
                                    filename1=CONN_x.Setup.rois.files{nsubs(1)}{nrois}{1}{1};
                                    [nill,nill,nameext]=fileparts(filename1);%filename));
                                    CONN_x.Setup.rois.multiplelabels(nrois)=(strcmp(nameext,'.img')|strcmp(nameext,'.nii')|strcmp(nameext,'.mgz'))&(~isempty(dir(conn_prepend('',deblank(filename1),'.txt')))|~isempty(dir(conn_prepend('',deblank(filename1),'.csv')))|~isempty(dir(conn_prepend('',deblank(filename1),'.xls'))));
                                    txt=sprintf('%d files assigned to %d subjects\n',size(filename,1),length(nsubs));
                                    if ishandle(hmsg), delete(hmsg); end
                                else 
                                    if sessionspecific, errordlg(sprintf('mismatched number of files (%d files; %d subjects/sessions)',size(filename,1),nfields),'');
                                    else errordlg(sprintf('mismatched number of files (%d files; %d subjects)',size(filename,1),length(nsubs)),'');
                                    end
								end
                                if ~isempty(txt)&&strcmp(questdlg(txt,'','Ok','Undo','Ok'),'Undo'), CONN_x.Setup.rois=bak1;end
                            case 4,
								nrois=get(CONN_h.menus.m_setup_00{1},'value'); 
                                nsubs=get(CONN_h.menus.m_setup_00{2},'value'); 
                                nsess=get(CONN_h.menus.m_setup_00{16},'value');
                                if nrois>3, subjectspecific=CONN_x.Setup.rois.subjectspecific(nrois);
                                else subjectspecific=1;
                                end
                                if ~subjectspecific, nsubs=1; end
                                if nrois>3, sessionspecific=CONN_x.Setup.rois.sessionspecific(nrois);
                                else sessionspecific=CONN_x.Setup.structural_sessionspecific;
                                end
                                if ~sessionspecific, nsess=1; end
                                if ~isempty(CONN_x.Setup.rois.files{nsubs(1)}{nrois(1)}{nsess(1)}{1})
                                    tempstr=cellstr(CONN_x.Setup.rois.files{nsubs(1)}{nrois(1)}{nsess(1)}{1});
                                    [nill,tempstr_name,tempstr_ext]=cellfun(@spm_fileparts,tempstr,'uni',0);
                                    tempstr_name=cellfun(@(a,b)[a b],tempstr_name,tempstr_ext,'uni',0);
                                    set(CONN_h.menus.m_setup_00{3}.selectfile,'string',unique(tempstr_name));
                                    set(CONN_h.menus.m_setup_00{3}.folder,'string',fileparts(tempstr{1}));
                                    conn_filesearchtool(CONN_h.menus.m_setup_00{3}.folder,[],'folder',true);
                                end
							case 6,
								nrois=get(CONN_h.menus.m_setup_00{1},'value'); 
								names=get(CONN_h.menus.m_setup_00{1},'string');
								name=fliplr(deblank(fliplr(deblank(get(CONN_h.menus.m_setup_00{6},'string')))));
								if nrois<=3||~isempty(strmatch(name,names,'exact')),name=CONN_x.Setup.rois.names{nrois}; end
                                names{nrois}=name;
                                CONN_x.Setup.rois.names{nrois}=name;
                                if nrois==length(CONN_x.Setup.rois.names)&&~strcmp(CONN_x.Setup.rois.names{nrois},' '), CONN_x.Setup.rois.names{nrois+1}=' '; names{nrois+1}=' '; end
                                set(CONN_h.menus.m_setup_00{1},'string',names);
                            case 7,
								nrois=get(CONN_h.menus.m_setup_00{1},'value'); 
								names=get(CONN_h.menus.m_setup_00{1},'string');
								dims=abs(round(str2num(get(CONN_h.menus.m_setup_00{7},'string'))));
								if length(dims)==1,CONN_x.Setup.rois.dimensions{nrois}=dims;end
                            case 8,
                                nrois0=length(CONN_x.Setup.rois.names);
								nrois1=get(CONN_h.menus.m_setup_00{1},'value'); 
                                nrois=setdiff(nrois1,[1:3,nrois0]);
                                nrois=setdiff(1:nrois0,nrois);
                                CONN_x.Setup.rois.names={CONN_x.Setup.rois.names{nrois}};
                                nrois=setdiff(nrois,nrois0);
                                CONN_x.Setup.rois.dimensions={CONN_x.Setup.rois.dimensions{nrois}};
                                CONN_x.Setup.rois.mask=CONN_x.Setup.rois.mask(nrois);
                                CONN_x.Setup.rois.subjectspecific=CONN_x.Setup.rois.subjectspecific(nrois);
                                CONN_x.Setup.rois.sessionspecific=CONN_x.Setup.rois.sessionspecific(nrois);
                                CONN_x.Setup.rois.multiplelabels=CONN_x.Setup.rois.multiplelabels(nrois);
                                CONN_x.Setup.rois.regresscovariates=CONN_x.Setup.rois.regresscovariates(nrois);
                                CONN_x.Setup.rois.unsmoothedvolumes=CONN_x.Setup.rois.unsmoothedvolumes(nrois);
                                for n1=1:length(CONN_x.Setup.rois.files), CONN_x.Setup.rois.files{n1}={CONN_x.Setup.rois.files{n1}{nrois}}; end
        						set(CONN_h.menus.m_setup_00{1},'string',CONN_x.Setup.rois.names,'value',max(1,min(length(CONN_x.Setup.rois.names)-1,max(nrois1))));
                                for n1=1:3,if any(nrois1==n1), 
                                        for nsub=1:CONN_x.Setup.nsubjects, for nses=1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsub)), CONN_x.Setup.rois.files{nsub}{n1}{nses}={[],[],[]}; end; end
                                    end; end
                            case 9,
								nrois=get(CONN_h.menus.m_setup_00{1},'value'); 
                                if nrois>3,
                                    value=get(CONN_h.menus.m_setup_00{9},'value');
                                    CONN_x.Setup.rois.mask(nrois)=value;
                                else set(CONN_h.menus.m_setup_00{9},'value',0);end
                            case 10,
								nrois=get(CONN_h.menus.m_setup_00{1},'value'); 
                                nsubs=get(CONN_h.menus.m_setup_00{2},'value'); 
                                nsess=get(CONN_h.menus.m_setup_00{16},'value');
                                if nrois>3, subjectspecific=CONN_x.Setup.rois.subjectspecific(nrois);
                                else subjectspecific=1;
                                end
                                if ~subjectspecific, nsubs=1; end
                                if nrois>3, sessionspecific=CONN_x.Setup.rois.sessionspecific(nrois);
                                else sessionspecific=CONN_x.Setup.structural_sessionspecific;
                                end
                                if ~sessionspecific, nsess=1; end
                                try
                                    filename=CONN_x.Setup.rois.files{nsubs(1)}{nrois}{nsess(1)}{1};
                                catch
                                    filename='';
                                end
                                [nill,nill,nameext]=fileparts(deblank(filename));
                                if nrois>3&&(strcmp(nameext,'.img')|strcmp(nameext,'.nii')|strcmp(nameext,'.mgz')),
                                    value=get(CONN_h.menus.m_setup_00{10},'value');
                                    CONN_x.Setup.rois.multiplelabels(nrois)=value;
                                    if value&&~((strcmp(nameext,'.img')|strcmp(nameext,'.nii')|strcmp(nameext,'.mgz'))&(~isempty(dir(conn_prepend('',deblank(filename),'.txt')))|~isempty(dir(conn_prepend('',deblank(filename),'.csv')))|~isempty(dir(conn_prepend('',deblank(filename),'.xls')))))
                                        answ=questdlg('Labels file not found for this multiple-ROI file. Do you want to define now?','Warning','Yes','No','Yes');
                                        if strcmp(answ,'Yes')
                                            files={}; for nsub=nsubs(:)', for nses=intersect(nsess,1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsub))), files{end+1}=CONN_x.Setup.rois.files{nsub}{nrois}{nses}{1}; end; end
                                            [nill,idx]=unique(files);
                                            files=files(sort(idx));
                                            files=cellfun(@conn_definelabels,files,'uni',0);
                                            edit(files{:});
                                        end
                                    end
                                else set(CONN_h.menus.m_setup_00{10},'value',0);
                                end
                            case 11,
								nrois=get(CONN_h.menus.m_setup_00{1},'value'); 
                                if nrois>3
                                    value=get(CONN_h.menus.m_setup_00{11},'value');
                                    CONN_x.Setup.rois.sessionspecific(nrois)=value;
                                else set(CONN_h.menus.m_setup_00{11},'value',CONN_x.Setup.structural_sessionspecific);
                                end
%                             case 11,
%                                 normalized=get(CONN_h.menus.m_setup_00{11},'value');
%                                 if ~normalized, warndlg('Warning: Second-level analyses not available for un-normalized data'); end
%                                 CONN_x.Setup.normalized=normalized;
                            case 12
								nrois=get(CONN_h.menus.m_setup_00{1},'value'); 
                                value=get(CONN_h.menus.m_setup_00{12},'value');
                                CONN_x.Setup.rois.regresscovariates(nrois)=value;
                            case 13
								nrois=get(CONN_h.menus.m_setup_00{1},'value'); 
                                value=get(CONN_h.menus.m_setup_00{13},'value');
                                CONN_x.Setup.rois.unsmoothedvolumes(nrois)=value;
                            case 14,
                                val=get(CONN_h.menus.m_setup_00{14},'value');
                                switch(val) 
                                    case {2,3},
                                        set(CONN_h.menus.m_setup_00{14},'value',1);
                                        nrois=get(CONN_h.menus.m_setup_00{1},'value');
                                        nsubs=get(CONN_h.menus.m_setup_00{2},'value');
                                        nsess=get(CONN_h.menus.m_setup_00{16},'value');
                                        if nrois>3, subjectspecific=CONN_x.Setup.rois.subjectspecific(nrois);
                                        else subjectspecific=1;
                                        end
                                        if ~subjectspecific, nsubs=1; end
                                        if nrois>3, sessionspecific=CONN_x.Setup.rois.sessionspecific(nrois);
                                        else sessionspecific=CONN_x.Setup.structural_sessionspecific;
                                        end
                                        if ~sessionspecific, nsess=1; end
                                        if val==2, conn_slice_display([],CONN_x.Setup.rois.files{nsubs(1)}{nrois}{nsess(1)}{1});
                                        else conn_slice_display(CONN_x.Setup.rois.files{nsubs(1)}{nrois}{nsess(1)}{1},CONN_x.Setup.structural{nsubs(1)}{nsess(1)}{1});
                                        end
                                    case {4,5}, % check registration anatomical
                                        set(CONN_h.menus.m_setup_00{14},'value',1);
                                        nrois=get(CONN_h.menus.m_setup_00{1},'value');
                                        nsubs=get(CONN_h.menus.m_setup_00{2},'value');
                                        nsess=get(CONN_h.menus.m_setup_00{16},'value');
                                        if nrois>3, subjectspecific=CONN_x.Setup.rois.subjectspecific(nrois);
                                        else subjectspecific=1;
                                        end
                                        if ~subjectspecific, nsubs=1; end
                                        if nrois>3, sessionspecific=CONN_x.Setup.rois.sessionspecific(nrois);
                                        else sessionspecific=CONN_x.Setup.structural_sessionspecific;
                                        end
                                        if ~sessionspecific, nsess=1; end
                                        unsmoothedvolumes=CONN_x.Setup.rois.unsmoothedvolumes(nrois);
                                        files={};filenames={};
                                        for n1=1:numel(nsubs)
                                            nsub=nsubs(n1);
                                            nsesst=intersect(nsess,1:CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub)));
                                            for n2=1:length(nsesst)
                                                nses=nsesst(n2);
                                                if val==5
                                                    if CONN_x.Setup.structural_sessionspecific,
                                                        files{end+1}=CONN_x.Setup.structural{nsub}{nses}{3}(1);
                                                        filenames{end+1}=CONN_x.Setup.structural{nsub}{nses}{1};
                                                    else
                                                        files{end+1}=CONN_x.Setup.structural{nsub}{1}{3}(1);
                                                        filenames{end+1}=CONN_x.Setup.structural{nsub}{1}{1};
                                                    end
                                                else
                                                    Vsource=CONN_x.Setup.functional{nsub}{nses}{1};
                                                    if unsmoothedvolumes
                                                        try
                                                            if CONN_x.Setup.roiextract==4
                                                                VsourceUnsmoothed=cellstr(CONN_x.Setup.roiextract_functional{nsub}{nses}{1});
                                                            else
                                                                Vsource1=cellstr(Vsource);
                                                                VsourceUnsmoothed=conn_rulebasedfilename(Vsource1,CONN_x.Setup.roiextract,CONN_x.Setup.roiextract_rule);
                                                            end
                                                            existunsmoothed=conn_existfile(VsourceUnsmoothed); %existunsmoothed=cellfun(@conn_existfile,VsourceUnsmoothed);
                                                            if ~all(existunsmoothed),
                                                                fprintf('warning: unsmoothed data for subject %d session %d not found. Using original functional data instead for ROI extraction\n',nsub,nses);
                                                            else
                                                                Vsource=char(VsourceUnsmoothed);
                                                            end
                                                        catch
                                                            fprintf('warning: error in CONN_x.Setup.roiextract for subject %d session %d not found. Using original functional data instead for ROI extraction\n',nsub,nses);
                                                        end
                                                    end
                                                    temp=cellstr(Vsource);
                                                    if numel(temp)==1,
                                                        temp=cellstr(conn_expandframe(temp{1}));
                                                    end
                                                    files{end+1}=spm_vol(temp{1});
                                                    filenames{end+1}=temp{1};
                                                end
                                                for nroi=nrois(:)',
                                                    filename=CONN_x.Setup.rois.files{nsub}{nroi}{nses}{1};
                                                    %[V,str,icon,filename]=conn_getinfo(filename);
                                                    %CONN_x.Setup.rois.files{nsub}{nroi}{nses}={filename,str,icon};
                                                    CONN_x.Setup.rois.files{nsub}{nroi}{nses}=conn_file(filename);
                                                    files{end+1}=CONN_x.Setup.rois.files{nsub}{nroi}{nses}{3}(1);
                                                    filenames{end+1}=CONN_x.Setup.rois.files{nsub}{nroi}{nses}{1};
                                                end
                                            end
                                        end
                                        [nill,idx]=unique(filenames);
                                        spm_check_registration([files{sort(idx)}]);
                                end
                                return;
                            case 16,
                            case 18,
								nrois=get(CONN_h.menus.m_setup_00{1},'value'); 
                                if nrois>3
                                    value=get(CONN_h.menus.m_setup_00{18},'value');
                                    CONN_x.Setup.rois.subjectspecific(nrois)=value;
                                else set(CONN_h.menus.m_setup_00{18},'value',1);
                                end
                        end
                    end
					names=get(CONN_h.menus.m_setup_00{1},'string');
					nrois=get(CONN_h.menus.m_setup_00{1},'value'); 
                    nsubs=get(CONN_h.menus.m_setup_00{2},'value');
                    nsess=get(CONN_h.menus.m_setup_00{16},'value');
					if ~isfield(CONN_x.Setup.rois,'dimensions') || length(CONN_x.Setup.rois.dimensions)<nrois, CONN_x.Setup.rois.dimensions{nrois}=1; end
					if ~isfield(CONN_x.Setup.rois,'mask') || length(CONN_x.Setup.rois.mask)<nrois, CONN_x.Setup.rois.mask(nrois)=0; end
					if ~isfield(CONN_x.Setup.rois,'subjectspecific') || length(CONN_x.Setup.rois.subjectspecific)<nrois, CONN_x.Setup.rois.subjectspecific(nrois)=0; end
					if ~isfield(CONN_x.Setup.rois,'sessionspecific') || length(CONN_x.Setup.rois.sessionspecific)<nrois, CONN_x.Setup.rois.sessionspecific(nrois)=0; end
					if ~isfield(CONN_x.Setup.rois,'multiplelabels') || length(CONN_x.Setup.rois.multiplelabels)<nrois, CONN_x.Setup.rois.multiplelabels(nrois)=0; end
					if ~isfield(CONN_x.Setup.rois,'regresscovariates') || length(CONN_x.Setup.rois.regresscovariates)<nrois, CONN_x.Setup.rois.regresscovariates(nrois)=double(CONN_x.Setup.rois.dimensions{nrois}>1); end
					if ~isfield(CONN_x.Setup.rois,'unsmoothedvolumes') || length(CONN_x.Setup.rois.unsmoothedvolumes)<nrois, CONN_x.Setup.rois.unsmoothedvolumes(nrois)=1; end
                    if nrois>3, subjectspecific=CONN_x.Setup.rois.subjectspecific(nrois);
                    else subjectspecific=1;
                    end
                    if ~subjectspecific, nsubs=1; end
                    if nrois>3, sessionspecific=CONN_x.Setup.rois.sessionspecific(nrois);
                    else sessionspecific=CONN_x.Setup.structural_sessionspecific;
                    end
                    if ~sessionspecific, nsess=1; end
                    nsessmax=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsubs));
                    for nsub=1:CONN_x.Setup.nsubjects
						if length(CONN_x.Setup.rois.files)<nsub, CONN_x.Setup.rois.files{nsub}={}; end
						if length(CONN_x.Setup.rois.files{nsub})<nrois, CONN_x.Setup.rois.files{nsub}{nrois}={}; end
                        for nses=1:CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub))
                            if length(CONN_x.Setup.rois.files{nsub}{nrois})<nses, CONN_x.Setup.rois.files{nsub}{nrois}{nses}={}; end
                            if length(CONN_x.Setup.rois.files{nsub}{nrois}{nses})<3, CONN_x.Setup.rois.files{nsub}{nrois}{nses}{3}=[]; end
                        end
                    end
					ok=1; ko=[];
                    for nsub=1:CONN_x.Setup.nsubjects
                        nsessall=1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsub));
                        if ~sessionspecific, nsessall=1; end
                        for nses=nsessall
                            if isempty(CONN_x.Setup.rois.files{nsub}{nrois}{nses}{1}), ok=0; ko=[nsub nses]; break; end
                        end
                        if ~ok, break; end
                    end
                    conn_menumanager('helpstring','');
                    if ~ok, conn_menumanager('helpstring',sprintf('WARNING: incomplete information (enter ROI file for subject %d session %d)',ko(1),ko(2))); end
                    if ~sessionspecific, set([CONN_h.menus.m_setup_00{16}, CONN_h.menus.m_setup_00{15}],'visible','off');
                    else set([CONN_h.menus.m_setup_00{16}, CONN_h.menus.m_setup_00{15}],'visible','on');
                    end
                    if ~subjectspecific, set([CONN_h.menus.m_setup_00{2}, CONN_h.menus.m_setup_00{19}],'visible','off');
                    else set([CONN_h.menus.m_setup_00{2}, CONN_h.menus.m_setup_00{19}],'visible','on');
                    end
					if strcmp(names{nrois},' '), set(CONN_h.menus.m_setup_00{6},'string','enter ROI name here'); uicontrol(CONN_h.menus.m_setup_00{6}); conn_menumanager('helpstring','WARNING: incomplete information (enter valid ROI name)');
                    else set(CONN_h.menus.m_setup_00{6},'string',deblank(names{nrois}));
                    end
					set(CONN_h.menus.m_setup_00{7},'string',num2str(CONN_x.Setup.rois.dimensions{nrois}));
					set(CONN_h.menus.m_setup_00{9},'value',CONN_x.Setup.rois.mask(nrois));
                    set(CONN_h.menus.m_setup_00{11},'value',sessionspecific);
                    set(CONN_h.menus.m_setup_00{18},'value',subjectspecific);
					set(CONN_h.menus.m_setup_00{10},'value',CONN_x.Setup.rois.multiplelabels(nrois));
					set(CONN_h.menus.m_setup_00{12},'value',CONN_x.Setup.rois.regresscovariates(nrois));
					set(CONN_h.menus.m_setup_00{13},'value',CONN_x.Setup.rois.unsmoothedvolumes(nrois));
                    if CONN_x.Setup.rois.dimensions{nrois}==1, set(CONN_h.menus.m_setup_00{20},'foregroundcolor',[.5 .5 .5]); else  set(CONN_h.menus.m_setup_00{20},'foregroundcolor',CONN_gui.fontcolorB); end
                    %if nrois<=3, set([CONN_h.menus.m_setup_00{6},CONN_h.menus.m_setup_00{9},CONN_h.menus.m_setup_00{10}],'visible','off');
                    %else  set(CONN_h.menus.m_setup_00{6},'visible','on','backgroundcolor','w','foregroundcolor','k'); set([CONN_h.menus.m_setup_00{9},CONN_h.menus.m_setup_00{10}],'visible','on'); end
                    set(CONN_h.menus.m_setup_00{6},'visible','on'); set([CONN_h.menus.m_setup_00{9},CONN_h.menus.m_setup_00{10}],'visible','on');
					ok=1; ko=[];
                    for n1=1:numel(nsubs)
                        nsub=nsubs(n1);
                        tnsess=intersect(nsess,1:nsessmax(n1));
                        for n2=1:length(tnsess)
                            nses=tnsess(n2);
                            if isempty(ko), ko=CONN_x.Setup.rois.files{nsub}{nrois}{nses}{1};
                            else  if ~all(size(ko)==size(CONN_x.Setup.rois.files{nsub}{nrois}{nses}{1})) || ~all(all(ko==CONN_x.Setup.rois.files{nsub}{nrois}{nses}{1})), ok=0; end; end
                        end
                    end
                    if nrois(1)<=numel(CONN_x.Setup.rois.files{nsubs(1)})&&nsess(1)<=numel(CONN_x.Setup.rois.files{nsubs(1)}{nrois(1)})&&isstruct(CONN_x.Setup.rois.files{nsubs(1)}{nrois(1)}{nsess(1)}{3}), set(CONN_h.menus.m_setup_00{14},'visible','on'); else set(CONN_h.menus.m_setup_00{14},'visible','off'); end
                    if isempty(nses)||numel(CONN_x.Setup.rois.files{nsub}{nrois})<nses||isempty(CONN_x.Setup.rois.files{nsub}{nrois}{nses}{1}),
						conn_menu('update',CONN_h.menus.m_setup_00{5},[]);
						set(CONN_h.menus.m_setup_00{4},'string','','tooltipstring','');
                    elseif ok,
						conn_menu('update',CONN_h.menus.m_setup_00{5},CONN_x.Setup.rois.files{nsub}{nrois}{nses}{3});
                        tempstr=cellstr(CONN_x.Setup.rois.files{nsub}{nrois}{nses}{1});
						set(CONN_h.menus.m_setup_00{4},'string',conn_cell2html(CONN_x.Setup.rois.files{nsub}{nrois}{nses}{2}),'tooltipstring',conn_cell2html(tempstr));
					else  
						conn_menu('update',CONN_h.menus.m_setup_00{5},[]);
						set(CONN_h.menus.m_setup_00{4},'string','multiple files','tooltipstring','');
					end
                case 5, %conditions
                    boffset=[.03 .02 0 0];
                    if nargin<2,
                        conn_menu('frame',boffset+[.19,.10,.61,.70],'EXPERIMENT CONDITIONS (within-subject effects)');
						CONN_h.menus.m_setup_00{1}=conn_menu('listbox',boffset+[.200,.20,.075,.55],'Conditions','',['<HTML>Select condition <br/> - click after the last item to add a new condition <br/> - ',CONN_gui.rightclick,'-click for additional options</HTML>'],'conn(''gui_setup'',1);','conn(''gui_setup'',8);');
						CONN_h.menus.m_setup_00{2}=conn_menu('listbox',boffset+[.275,.20,.075,.55],'Subjects','','Select subject(s)','conn(''gui_setup'',2);');
						CONN_h.menus.m_setup_00{3}=conn_menu('listbox',boffset+[.350,.20,.075,.55],'Sessions','','Select session(s)','conn(''gui_setup'',3);');
						CONN_h.menus.m_setup_00{6}=conn_menu('edit',boffset+[.45,.70,.12,.04],'Condition name','','Condition name','conn(''gui_setup'',6);');
						CONN_h.menus.m_setup_00{4}=conn_menu('edit',boffset+[.45,.62,.12,.04],'Onset',[],'<HTML>onset time(s) marking the beginning of each block/event (in seconds) <b>for the selected subject(s)/session(s)</b><br/> - set <i>onset</i> to <b>0</b> and <i>duration</i> to <b>inf</b> to indicate that this condition is present during the entire session (e.g. resting state)<br/> - set <i>onset</i> and <i>duration</i> to <b>[]</b> (empty brackets) if the condition is not present in this session (e.g. pre- post- designs) <br/> - enter a series of block onsets if the condition is only present during a portion of this session (e.g. block designs)</HTML>','conn(''gui_setup'',4);');
						CONN_h.menus.m_setup_00{5}=conn_menu('edit',boffset+[.45,.54,.12,.04],'Duration',[],'<HTML>duration(s) of condition blocks/events (in seconds) <b>for the selected subject(s)/session(s)</b><br/> - set <i>onset</i> to <b>0</b> and <i>duration</i> to <b>inf</b> to indicate that this condition is present during the entire session (e.g. resting state)<br/> - set <i>onset</i> and <i>duration</i> to <b>[]</b> (empty brackets) if the condition is not present in this session (e.g. pre- post- designs) <br/> - enter a series of block/event durations if the condition is only present during a portion of this session (e.g. block designs) <br/> or a single value if all blocks/events have the same duration</HTML>','conn(''gui_setup'',5);');
						tmp=conn_menu('text',boffset+[.59,.73,.20,.04],'','Optional fields:');
                        set(tmp,'horizontalalignment','left','fontangle','normal','fontweight','normal','foregroundcolor',CONN_gui.fontcolorA);
                        analysistypes=[{'condition blocks/events'},cellfun(@(x)['condition blocks * covariate ''',x,''''],CONN_x.Setup.l1covariates.names(1:end-1),'uni',0)];
                        CONN_h.menus.m_setup_00{7}=conn_menu('popup',boffset+[.60,.65,.19,.05],'Task modulation factor',analysistypes,sprintf('optional condition-specific temporal modulation factor:\n  - for First-level analyses using a weighted GLM model (standard functional connectivity) this field has no effect\n  - for First-level analyses using a gPPI task-modulation model this field defines the condition-specific task-interaction factor\n (defaults to simple task effects; hrf-convolved condition blocks)'),'conn(''gui_setup'',7);');
                        CONN_h.menus.m_setup_00{10}=conn_menu('popup',boffset+[.60,.57,.19,.05],'Time-frequency decomposition',{'no decomposition','fixed band-pass filter','frequency decomposition (filter bank)','temporal decomposition (sliding-window)'},'<HTML>optional condition-specific frequency filter or time/frequency decompositions:<br/> - select <i>fixed band-pass filter</i> to define a condition-specific band-pass filter for the current condition (in addition to the filter specified during <i>Denoising</i> which applies to all conditions equally) <br/> - when selecting frequency- or temporal- decompositions, several new conditions will be automatically created during the Denoising step<br/> by partitioning the current condition in the frequency or temporal domains, respectively</HTML>','conn(''gui_setup'',10);');
                        CONN_h.menus.m_setup_00{11}=conn_menu('popup',boffset+[.60,.49,.19,.05],'Missing data',{'No missing data','Allow missing data'},'<HTML>Treatment of missing data: (this option applies to <b>all conditions)</b><br/> - If in one condition the <i>onset</i> and <i>duration</i> fields are left empty on <i>all</i> sessions of a given subject, that subject/condition''s condition-specific connectivity <br/> can not be computed. CONN treats this as ''missing data'' and the subject will be automatically disregarded in all second-level analyses involving this condition <br/> - Select ''<i>No missing data</i>'' if no missing data should be expected. CONN will warn the user if a condition has missing  <i>onset/duration</i> fields in <i>all</i> of the sessions <br/> of any given subject (this check helps avoid accidentally entering incomplete condition information). <br/> - Select ''<i>Allow missing data</i>'' if missing data should be expected, and CONN will skip the above check</HTML>','conn(''gui_setup'',11);');
						CONN_h.menus.m_setup_00{12}=conn_menu('image',boffset+[.45,.15,.33,.20],'Experiment Design   (scans/sessions by conditions)');
                        CONN_h.menus.m_setup_00{14}=conn_menu('popup0',boffset+[.20,.10,.20,.05],'',{'<HTML><i> - condition tools:</i></HTML>','copy selected condition to covariates list','move selected condition to covariates list','Import new condition info from text file'},'<HTML> - <i>copy to covariate list</i> creates a new first-level covariate containing the hrf-convolved condition effects<br/>  - <i>move to covariate list</i> deletes this condition and creates instead a new first-level covariate containing the hrf-convolved <br/> condition effects (e.g. for Fair et al. resting state analyses of task-related data)<br/> - <i>Import condition</i> imports condition names and onsets/durations values (for all subjects/sessions) from a text file<br/> Text file should contain five comma-separated columns (condition-name, subject-number, session-number, onsets, and <br/> durations), one header-line and an arbitrary number of rows containing the condition information</HTML>','conn(''gui_setup'',14);');
						set(CONN_h.menus.m_setup_00{3},'max',2);
						set(CONN_h.menus.m_setup_00{2},'string',[repmat('Subject ',[CONN_x.Setup.nsubjects,1]),num2str((1:CONN_x.Setup.nsubjects)')],'max',2);
						set(CONN_h.menus.m_setup_00{1},'string',CONN_x.Setup.conditions.names,'max',2);
                        nsess=CONN_x.Setup.nsessions(1); set(CONN_h.menus.m_setup_00{3},'string',[repmat('Session ',[nsess,1]),num2str((1:nsess)')],'value',min(nsess,get(CONN_h.menus.m_setup_00{3},'value')));
                        hc1=uicontextmenu;uimenu(hc1,'Label','remove selected condition(s)','callback','conn(''gui_setup'',8);');
                        uimenu(hc1,'Label','replicate selected condition as a new condition','callback','conn(''gui_setup'',9,''replicate'');');
                        %uimenu(hc1,'Label','move selected condition to covariates list (for Fair et al. resting state analyses of task-related data)','callback','conn(''gui_setup'',9,''move'');');
                        %uimenu(hc1,'Label','copy selected condition to covariates list','callback','conn(''gui_setup'',9,''copy'');');
                        set(CONN_h.menus.m_setup_00{1},'uicontextmenu',hc1);
                    else
                        switch(varargin{2}),
                            case 2, value=get(CONN_h.menus.m_setup_00{2},'value'); 
                                nsess=max(CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),value))); 
                                set(CONN_h.menus.m_setup_00{3},'string',[repmat('Session ',[nsess,1]),num2str((1:nsess)')],'value',min(nsess,get(CONN_h.menus.m_setup_00{3},'value')));
							case 4,
								nconditions=get(CONN_h.menus.m_setup_00{1},'value'); 
								nsubs=get(CONN_h.menus.m_setup_00{2},'value');
								nsess=get(CONN_h.menus.m_setup_00{3},'value');
                                strvalue=get(CONN_h.menus.m_setup_00{4},'string');
								value=max(0,str2num(strvalue));
                                if isempty(value), try value=evalin('base',strvalue); catch, value=[]; end; end
								if isempty(strvalue)||strcmp(strvalue,'[]')||~isempty(value),
									for nsub=nsubs(:)', for nses=nsess(:)', for ncondition=nconditions(:)'
											if nses<=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub)), CONN_x.Setup.conditions.values{nsub}{ncondition}{nses}{1}=value; end
									end; end; end
								end
							case 5,
								nconditions=get(CONN_h.menus.m_setup_00{1},'value'); 
								nsubs=get(CONN_h.menus.m_setup_00{2},'value');
								nsess=get(CONN_h.menus.m_setup_00{3},'value');
                                strvalue=get(CONN_h.menus.m_setup_00{5},'string');
								value=str2num(strvalue);
                                if isempty(value), try value=evalin('base',strvalue); catch, value=[]; end; end
								if isempty(strvalue)||strcmp(strvalue,'[]')||~isempty(value),
									for nsub=nsubs(:)', for nses=nsess(:)', for ncondition=nconditions(:)'
											if nses<=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub)), CONN_x.Setup.conditions.values{nsub}{ncondition}{nses}{2}=value; end
									end; end; end
								end
							case 6,
								nconditions=get(CONN_h.menus.m_setup_00{1},'value'); 
								names=get(CONN_h.menus.m_setup_00{1},'string');
								name=fliplr(deblank(fliplr(deblank(get(CONN_h.menus.m_setup_00{6},'string')))));
								if ~isempty(deblank(name))&&isempty(strmatch(name,names,'exact')),
                                    [nill,isnew]=conn_conditionnames(name);
                                    if ~isnew
                                        answ=questdlg('This condition name has been used before and run through at least some of the processing steps. Using this name will associate this condition with those already-processed data. Do you want to proceed?','','Yes','No','No');
                                        isnew=isequal(answ,'Yes');
                                    end
                                    if isnew
                                        names{nconditions}=name;
                                        CONN_x.Setup.conditions.names{nconditions}=name;
                                        if nconditions==length(CONN_x.Setup.conditions.names),
                                            CONN_x.Setup.conditions.names{nconditions+1}=' ';
                                            names{nconditions+1}=' ';
                                            if length(CONN_x.Setup.conditions.param)<nconditions, CONN_x.Setup.conditions.param=[CONN_x.Setup.conditions.param, zeros(1,nconditions-length(CONN_x.Setup.conditions.param))]; end
                                            if length(CONN_x.Setup.conditions.filter)<nconditions, CONN_x.Setup.conditions.filter=[CONN_x.Setup.conditions.filter, cell(1,nconditions-length(CONN_x.Setup.conditions.filter))]; end
                                            for nsub=1:CONN_x.Setup.nsubjects,
                                                if length(CONN_x.Setup.conditions.values)<nsub, CONN_x.Setup.conditions.values{nsub}={}; end
                                                if length(CONN_x.Setup.conditions.values{nsub})<nconditions, CONN_x.Setup.conditions.values{nsub}{nconditions}={}; end
                                                for nses=1:CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub)),
                                                    if length(CONN_x.Setup.conditions.values{nsub}{nconditions})<nses, CONN_x.Setup.conditions.values{nsub}{nconditions}{nses}={[]}; end
                                                    if length(CONN_x.Setup.conditions.values{nsub}{nconditions}{nses})<2, CONN_x.Setup.conditions.values{nsub}{nconditions}{nses}{2}=[]; end
                                                end
                                            end
                                        end
                                        set(CONN_h.menus.m_setup_00{1},'string',names);
                                    end
								end
							case 7,
								nconditions=get(CONN_h.menus.m_setup_00{1},'value'); 
								value=get(CONN_h.menus.m_setup_00{7},'value')-1;
                                CONN_x.Setup.conditions.param(nconditions)=value;
                            case 8,
								nconditions1=get(CONN_h.menus.m_setup_00{1},'value'); 
                                nconditions0=length(CONN_x.Setup.conditions.names);
                                nconditions=setdiff(nconditions1,[nconditions0]);
                                %oldnames=CONN_x.Setup.conditions.names(nconditions);
                                %for n1=1:numel(oldnames), conn_conditionnames(oldnames{n1},'delete'); end 
                                nconditions=setdiff(1:nconditions0,nconditions);
                                CONN_x.Setup.conditions.names={CONN_x.Setup.conditions.names{nconditions}};
                                nconditions=setdiff(nconditions,nconditions0);
                                for n1=1:length(CONN_x.Setup.conditions.values), CONN_x.Setup.conditions.values{n1}={CONN_x.Setup.conditions.values{n1}{nconditions}}; end
                                CONN_x.Setup.conditions.param=CONN_x.Setup.conditions.param(nconditions);
                                CONN_x.Setup.conditions.filter=CONN_x.Setup.conditions.filter(nconditions);
        						set(CONN_h.menus.m_setup_00{1},'string',CONN_x.Setup.conditions.names,'value',max(1,min(length(CONN_x.Setup.conditions.names)-1,max(nconditions1))));
                            case {9,14},
                                if varargin{2}==14
                                    tlvalue=get(CONN_h.menus.m_setup_00{14},'value');
                                    set(CONN_h.menus.m_setup_00{14},'value',1);
                                end
                                if varargin{2}==14&&tlvalue==4, 
                                    conn_importcondition;
                                    set(CONN_h.menus.m_setup_00{1},'string',CONN_x.Setup.conditions.names);
                                else
                                    nconditions=get(CONN_h.menus.m_setup_00{1},'value');
                                    nconditions0=length(CONN_x.Setup.conditions.names);
                                    nconditions=setdiff(nconditions,[nconditions0]);
                                    if ~isempty(nconditions)
                                        if nargin>=3&&isequal(varargin{3},'replicate')
                                            name=arrayfun(@(n)[CONN_x.Setup.conditions.names{n},' (copy)'],nconditions,'uni',0);
                                            CONN_x.Setup.conditions.names(nconditions0-1+(1:numel(nconditions)))=name;
                                            CONN_x.Setup.conditions.names{nconditions0-1+numel(nconditions)+1}=' ';
                                            nconditionsnew=[1:nconditions0-1 nconditions];
                                            for n1=1:length(CONN_x.Setup.conditions.values), CONN_x.Setup.conditions.values{n1}=CONN_x.Setup.conditions.values{n1}(nconditionsnew); end
                                            CONN_x.Setup.conditions.param=CONN_x.Setup.conditions.param(nconditionsnew);
                                            CONN_x.Setup.conditions.filter=CONN_x.Setup.conditions.filter(nconditionsnew);
                                        else
                                            if (varargin{2}==14&&tlvalue==2)||(nargin>=3&&isequal(varargin{3},'copy')), conn_convertcondition2covariate('-DONOTREMOVE',nconditions);
                                            elseif isequal(questdlg({['This step will delete the selected conditions ',sprintf('%s ',CONN_x.Setup.conditions.names{nconditions})],'Do you want to proceed?'},'','Yes','No','Yes'),'Yes'), conn_convertcondition2covariate(nconditions); 
                                            end
                                        end
                                        set(CONN_h.menus.m_setup_00{1},'string',CONN_x.Setup.conditions.names,'value',max(1,min(length(CONN_x.Setup.conditions.names)-1,max(nconditions))));
                                    end
                                end
                            case 10,
								nconditions=get(CONN_h.menus.m_setup_00{1},'value'); 
								value=get(CONN_h.menus.m_setup_00{10},'value');
                                switch(value)
                                    case 1, 
                                        [CONN_x.Setup.conditions.filter{nconditions}]=deal([]);
                                    case 2,
                                        if numel(CONN_x.Setup.conditions.filter{nconditions(1)})==2, answ={mat2str(CONN_x.Setup.conditions.filter{nconditions(1)})}; 
                                        else answ={'[.01 .10]'};
                                        end
                                        answ=inputdlg('Band-pass filter (Hz)','',1,answ);
                                        if numel(answ)==1&&numel(str2num(answ{1}))==2,
                                            [CONN_x.Setup.conditions.filter{nconditions}]=str2num(answ{1});
                                        end
                                    case 3,
                                        if numel(CONN_x.Setup.conditions.filter{nconditions(1)})==1, answ={num2str(CONN_x.Setup.conditions.filter{nconditions(1)})}; 
                                        else answ={'4'};
                                        end
                                        answ=inputdlg('Number of frequency bands','',1,answ);
                                        if numel(answ)==1,
                                            answ=str2num(answ{1});
                                            if numel(answ)==1&&answ>1, 
                                                [CONN_x.Setup.conditions.filter{nconditions}]=deal(answ); 
                                                answ=questdlg({'This will create additional conditions (one per frequency band)','Do you wish to create these conditions now?'},'','Yes','Later','Later');
                                                if ~isempty(answ)&&strcmp(answ,'Yes'),conn_process('setup_conditionsdecomposition'); conn('gui_setup'); end
                                            end
                                        end
                                    case 4,
                                        if numel(CONN_x.Setup.conditions.filter{nconditions(1)})>2, answ={mat2str(CONN_x.Setup.conditions.filter{nconditions(1)}(2:end)),num2str(CONN_x.Setup.conditions.filter{nconditions(1)}(1))}; 
                                        else
                                            try
                                                maxscans=0;
                                                for nsub=1:CONN_x.Setup.nsubjects, 
                                                    for nses=1:CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub)),
                                                        maxscans=max(maxscans,CONN_x.Setup.RT(min(numel(CONN_x.Setup.RT),nsub))*CONN_x.Setup.nscans{nsub}{nses});
                                                    end
                                                end
                                                answ={mat2str(0:25:maxscans-100),'100'};
                                            catch
                                                answ={mat2str(0:25:200),'100'};
                                            end
                                        end
                                        answ=inputdlg({'Sliding-window onsets (in seconds relative to condition onset)','Sliding-window length (in seconds)'},'',1,answ);
                                        if numel(answ)==2,
                                            answ={str2num(answ{1}) str2num(answ{2})};
                                            if numel(answ)==2&&numel(answ{1})>1&&numel(answ{2})==1, 
                                                [CONN_x.Setup.conditions.filter{nconditions}]=deal([answ{2} answ{1}(:)']); 
                                                answ=questdlg({'This will create additional conditions (one per sliding-window onset)','Do you wish to create these conditions now?'},'','Yes','Later','Later');
                                                if ~isempty(answ)&&strcmp(answ,'Yes'),conn_process('setup_conditionsdecomposition'); conn('gui_setup'); end
                                            end
                                        end
                                end
                            case 11,
                                CONN_x.Setup.conditions.missingdata=get(CONN_h.menus.m_setup_00{11},'value')>1;
                        end
                    end
					names=get(CONN_h.menus.m_setup_00{1},'string');
					nconditions=get(CONN_h.menus.m_setup_00{1},'value'); 
                    nsubs=get(CONN_h.menus.m_setup_00{2},'value');
                    nsess=get(CONN_h.menus.m_setup_00{3},'value');
					if numel(nconditions)>1, 
                        set([CONN_h.menus.m_setup_00{6} CONN_h.menus.m_setup_00{7} CONN_h.menus.m_setup_00{10}],'visible','off');
                    else
                        set([CONN_h.menus.m_setup_00{6} CONN_h.menus.m_setup_00{7} CONN_h.menus.m_setup_00{10}],'visible','on');
                        conn_menumanager('helpstring','');
                        if strcmp(names{nconditions},' '), set(CONN_h.menus.m_setup_00{6},'string','enter condition name here'); uicontrol(CONN_h.menus.m_setup_00{6}); conn_menumanager('helpstring','WARNING: incomplete information (enter valid condition name)');
                        else set(CONN_h.menus.m_setup_00{6},'string',deblank(names{nconditions}));
                        end
                    end
                    ok=[1,1]; ko={[],[]}; init=false;
                    if ~isempty(CONN_x.Setup.conditions.names{end})&&~strcmp(CONN_x.Setup.conditions.names{end},' '), CONN_x.Setup.conditions.names{end+1}=' '; set(CONN_h.menus.m_setup_00{1},'string',CONN_x.Setup.conditions.names); end
                    if length(CONN_x.Setup.conditions.param)<nconditions, CONN_x.Setup.conditions.param=[CONN_x.Setup.conditions.param, zeros(1,nconditions-length(CONN_x.Setup.conditions.param))]; end
                    if length(CONN_x.Setup.conditions.filter)<nconditions, CONN_x.Setup.conditions.filter=[CONN_x.Setup.conditions.filter, cell(1,nconditions-length(CONN_x.Setup.conditions.filter))]; end
                    for nsub=1:CONN_x.Setup.nsubjects,
                        if length(CONN_x.Setup.conditions.values)<nsub, CONN_x.Setup.conditions.values{nsub}={}; end
                        for ncondition=1:numel(CONN_x.Setup.conditions.names)-1
                            if length(CONN_x.Setup.conditions.values{nsub})<ncondition, CONN_x.Setup.conditions.values{nsub}{ncondition}={}; end
                            for nses=1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsub)),
                                if length(CONN_x.Setup.conditions.values{nsub}{ncondition})<nses, CONN_x.Setup.conditions.values{nsub}{ncondition}{nses}={[]}; end
                                if length(CONN_x.Setup.conditions.values{nsub}{ncondition}{nses})<2, CONN_x.Setup.conditions.values{nsub}{ncondition}{nses}{2}=[]; end
                            end
                        end
                    end
                    for nsub=nsubs(:)',
                        if length(CONN_x.Setup.conditions.values)<nsub, CONN_x.Setup.conditions.values{nsub}={}; end
                        for ncondition=nconditions(:)'
                            if length(CONN_x.Setup.conditions.values{nsub})<ncondition, CONN_x.Setup.conditions.values{nsub}{ncondition}={}; end
                        end
                        for ncondition=nconditions(:)'
                            for nses=nsess(:)',
                                if nses<=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub)),
                                    if length(CONN_x.Setup.conditions.values{nsub}{ncondition})<nses, CONN_x.Setup.conditions.values{nsub}{ncondition}{nses}={[]}; end
                                    if length(CONN_x.Setup.conditions.values{nsub}{ncondition}{nses})<2, CONN_x.Setup.conditions.values{nsub}{ncondition}{nses}{2}=[]; end
                                    if ~init, ko=CONN_x.Setup.conditions.values{nsub}{ncondition}{nses}; init=true;
                                    else
                                        if ~all(size(ko{1})==size(CONN_x.Setup.conditions.values{nsub}{ncondition}{nses}{1})) || ~all(all(ko{1}==CONN_x.Setup.conditions.values{nsub}{ncondition}{nses}{1})), ok(1)=0; end;
                                        if ~all(size(ko{2})==size(CONN_x.Setup.conditions.values{nsub}{ncondition}{nses}{2})) || ~all(all(ko{2}==CONN_x.Setup.conditions.values{nsub}{ncondition}{nses}{2})), ok(2)=0; end;
                                    end
                                end
                            end
                        end
                    end
                    if ok(1), set(CONN_h.menus.m_setup_00{4},'string',mat2str(ko{1})); else  set(CONN_h.menus.m_setup_00{4},'string','MULTIPLE VALUES'); end
                    if ok(2), set(CONN_h.menus.m_setup_00{5},'string',mat2str(ko{2})); else  set(CONN_h.menus.m_setup_00{5},'string','MULTIPLE VALUES'); end
                    set(CONN_h.menus.m_setup_00{7},'value',CONN_x.Setup.conditions.param(nconditions(1))+1);
                    if numel(CONN_x.Setup.conditions.filter{nconditions(1)})==2, set(CONN_h.menus.m_setup_00{10},'value',2);
                    elseif numel(CONN_x.Setup.conditions.filter{nconditions(1)})==1, set(CONN_h.menus.m_setup_00{10},'value',3);
                    elseif numel(CONN_x.Setup.conditions.filter{nconditions(1)})>2, set(CONN_h.menus.m_setup_00{10},'value',4);
                    else set(CONN_h.menus.m_setup_00{10},'value',1);
                    end
                    set(CONN_h.menus.m_setup_00{11},'value',1+(CONN_x.Setup.conditions.missingdata)); 
                    try
                        out=conn_convertcondition2covariate('-DONOTAPPLY',1:numel(CONN_x.Setup.conditions.names)-1);
                        x=[];
                        for ncondition=1:numel(CONN_x.Setup.conditions.names)-1,
                            for nsub=nsubs(:)',
                                tx=[];
                                for nses=1:CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub)), 
                                    if nses<=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub)),
                                        temp=max(0,out{nsub}{ncondition}{nses});
                                        temp=conn_bsxfun(@rdivide,temp,max(1e-4,max(abs(temp))));
                                        tx=[tx; 129*(ismember(nses,nsess)&ismember(ncondition,nconditions))+64*temp];
                                    end
                                end
                                x=[[x; nan(max(0,size(tx,1)-size(x,1)),size(x,2))] [tx; nan(max(0,size(x,1)-size(tx,1)),1)]];
                            end
                        end
                        x(isnan(x))=0;
                        conn_menu('updatematrix',CONN_h.menus.m_setup_00{12},ind2rgb(max(1,min(256,round(x)')),[gray(128);hot(128)]));
                    catch
                        conn_menu('updatematrix',CONN_h.menus.m_setup_00{12},[]);
                    end
                    
				case 6, % covariates first-level
                    boffset=[.03 .02 0 0];
					if nargin<2,
						conn_menu('frame',boffset+[.19,.14,.44,.66],'FIRST-LEVEL COVARIATES (within-subject effects)');
						CONN_h.menus.m_setup_00{1}=conn_menu('listbox',boffset+[.200,.23,.075,.52],'Covariates','',['<HTML>Select first-level covariate <br/> - click after the last item to add a new covariate <br/> - ',CONN_gui.rightclick,'-click for additional options</HTML>'],'conn(''gui_setup'',1);','conn(''gui_setup'',8);');
						CONN_h.menus.m_setup_00{2}=conn_menu('listbox',boffset+[.275,.23,.075,.52],'Subjects','','Select subject(s)','conn(''gui_setup'',2);');
						CONN_h.menus.m_setup_00{3}=conn_menu('listbox',boffset+[.350,.23,.075,.52],'Sessions','','Select session(s)','conn(''gui_setup'',3);');
						CONN_h.menus.m_setup_00{4}=conn_menu('filesearch',[],'Select covariate files','*.mat; *.txt; *.par','',{@conn,'gui_setup',4},'conn(''gui_setup'',5);');
						CONN_h.menus.m_setup_00{5}=conn_menu('pushbutton2', boffset+[.435,.56,.18,.09],'','','','conn(''gui_setup'',5);');
						CONN_h.menus.m_setup_00{6}=conn_menu('image',boffset+[.435,.20,.20,.35]);
                        set([CONN_h.menus.m_setup_00{5}],'visible','off'); conn_menumanager('onregion',[CONN_h.menus.m_setup_00{5}],1,boffset+[.435,.25,.18,.41]);
						CONN_h.menus.m_setup_00{7}=conn_menu('edit',boffset+[.455,.71,.14,.04],'Covariate name','','First-level covariate name','conn(''gui_setup'',7);');
                        CONN_h.menus.m_setup_00{14}=conn_menu('popup0',boffset+[.20,.14,.14,.05],'',{'<HTML><i> - covariate tools:</i></HTML>','Subject-level aggreagate'},'<HTML><i>subject-level aggregate</i> creates second-level covariates (subject-level measures) by aggregating the selected first-level covariate across scans&sessions</HTML>','conn(''gui_setup'',14);');
                        %CONN_h.menus.m_setup_00{14}=uicontrol('style','popupmenu','units','norm','position',boffset+[.455,.18,.14,.04],'string',{'<HTML><i> - options:</i></HTML>','subject-level aggreagate'},'foregroundcolor','w','backgroundcolor',CONN_gui.backgroundcolorA,'fontsize',8+CONN_gui.font_offset,'callback','conn(''gui_setup'',14);','tooltipstring','First-level covariates additional options');
                        %CONN_h.menus.m_setup_00{9}=uicontrol('style','pushbutton','units','norm','position',boffset+[.455,.18,.14,.04],'string','subject-level aggregate','tooltipstring','Compute subject-level aggregated measures and create associated 2nd-level covariates','callback','conn(''gui_setup'',9);','fontsize',8+CONN_gui.font_offset);
						set(CONN_h.menus.m_setup_00{4}.files,'max',2);
						set(CONN_h.menus.m_setup_00{3},'max',2);
						set(CONN_h.menus.m_setup_00{2},'string',[repmat('Subject ',[CONN_x.Setup.nsubjects,1]),num2str((1:CONN_x.Setup.nsubjects)')],'max',2);
						set(CONN_h.menus.m_setup_00{1},'string',CONN_x.Setup.l1covariates.names,'max',1);
						nsess=CONN_x.Setup.nsessions(1); set(CONN_h.menus.m_setup_00{3},'string',[repmat('Session ',[nsess,1]),num2str((1:nsess)')],'value',min(nsess,get(CONN_h.menus.m_setup_00{3},'value')));
                        hc1=uicontextmenu;uimenu(hc1,'Label','remove selected covariate','callback','conn(''gui_setup'',8);');set(CONN_h.menus.m_setup_00{1},'uicontextmenu',hc1);
                        %hc1=uicontextmenu;uimenu(hc1,'Label','go to source folder','callback','conn(''gui_setup'',5);');set(CONN_h.menus.m_setup_00{5},'uicontextmenu',hc1);
					else
						switch(varargin{2}),
							case 2, value=get(CONN_h.menus.m_setup_00{2},'value'); 
								nsess=max(CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),value))); 
								set(CONN_h.menus.m_setup_00{3},'string',[repmat('Session ',[nsess,1]),num2str((1:nsess)')],'value',min(nsess,get(CONN_h.menus.m_setup_00{3},'value')));
							case 4,
								nl1covariates=get(CONN_h.menus.m_setup_00{1},'value'); 
								nsubs=get(CONN_h.menus.m_setup_00{2},'value');
								nsess=get(CONN_h.menus.m_setup_00{3},'value');
								filename=fliplr(deblank(fliplr(deblank(varargin{3}))));
                                txt=''; bak1=CONN_x.Setup.l1covariates.files;
								if size(filename,1)==length(nsubs)*length(nsess),
									n3=1;for n1=1:length(nsubs), for n2=1:length(nsess),
										nsub=nsubs(n1);nses=nsess(n2);
										%[V,str,icon]=conn_getinfo(deblank(filename(n3,:)));
                                        %CONN_x.Setup.l1covariates.files{nsub}{nl1covariates}{nses}={deblank(filename(n3,:)),str,icon};
                                        CONN_x.Setup.l1covariates.files{nsub}{nl1covariates}{nses}=conn_file(deblank(filename(n3,:)));
                                        n3=n3+1;
                                    end;end
                                    txt=sprintf('%d files assigned to %d sessions x %d subjects\n',size(filename,1),length(nsess),length(nsubs));
								elseif size(filename,1)==1,
                                    [V,str,icon,filename]=conn_getinfo(filename);
                                    for nsub=nsubs(:)', for nses=nsess(:)',
                                            if nses<=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub)), CONN_x.Setup.l1covariates.files{nsub}{nl1covariates}{nses}={filename,str,icon}; end;
                                        end; end
                                    txt=sprintf('%d files assigned to %d sessions x %d subjects\n',size(filename,1),length(nsess),length(nsubs));
								else 
									errordlg(sprintf('mismatched number of files (%d files; %d sessions*subjects)',size(filename,1),length(nsubs)*length(nsess)),'');
                                end
                                if ~isempty(txt)&&strcmp(questdlg(txt,'','Ok','Undo','Ok'),'Undo'), CONN_x.Setup.l1covariates.files=bak1;end
                            case 5,
								nl1covariates=get(CONN_h.menus.m_setup_00{1},'value'); 
								nsubs=get(CONN_h.menus.m_setup_00{2},'value');
								nsess=get(CONN_h.menus.m_setup_00{3},'value');
                                if ~isempty(CONN_x.Setup.l1covariates.files{nsubs(1)}{nl1covariates(1)}{nsess(1)}{1})
                                    tempstr=cellstr(CONN_x.Setup.l1covariates.files{nsubs(1)}{nl1covariates(1)}{nsess(1)}{1});
                                    [nill,tempstr_name,tempstr_ext]=cellfun(@spm_fileparts,tempstr,'uni',0);
                                    tempstr_name=cellfun(@(a,b)[a b],tempstr_name,tempstr_ext,'uni',0);
                                    set(CONN_h.menus.m_setup_00{4}.selectfile,'string',unique(tempstr_name));
                                    set(CONN_h.menus.m_setup_00{4}.folder,'string',fileparts(tempstr{1}));
                                    conn_filesearchtool(CONN_h.menus.m_setup_00{4}.folder,[],'folder',true);
                                end
							case 7,
								nl1covariates=get(CONN_h.menus.m_setup_00{1},'value'); 
								names=get(CONN_h.menus.m_setup_00{1},'string');
								name=fliplr(deblank(fliplr(deblank(get(CONN_h.menus.m_setup_00{7},'string')))));
								if isempty(strmatch(name,names,'exact')),
									names{nl1covariates}=name;
									CONN_x.Setup.l1covariates.names{nl1covariates}=name;
									if nl1covariates==length(CONN_x.Setup.l1covariates.names), CONN_x.Setup.l1covariates.names{nl1covariates+1}=' '; names{nl1covariates+1}=' '; end
									set(CONN_h.menus.m_setup_00{1},'string',names);
								end
                            case 8,
								nl1covariates1=get(CONN_h.menus.m_setup_00{1},'value'); 
                                nl1covariates0=length(CONN_x.Setup.l1covariates.names);
                                nl1covariates=setdiff(nl1covariates1,[nl1covariates0]);
                                nl1covariates=setdiff(1:nl1covariates0,nl1covariates);
                                CONN_x.Setup.l1covariates.names={CONN_x.Setup.l1covariates.names{nl1covariates}};
                                nl1covariates=setdiff(nl1covariates,nl1covariates0);
                                for n1=1:length(CONN_x.Setup.l1covariates.files), CONN_x.Setup.l1covariates.files{n1}={CONN_x.Setup.l1covariates.files{n1}{nl1covariates}}; end
        						set(CONN_h.menus.m_setup_00{1},'string',CONN_x.Setup.l1covariates.names,'value',max(1,min(length(CONN_x.Setup.l1covariates.names)-1,max(nl1covariates1))));
                            case 14,
                                val=get(CONN_h.menus.m_setup_00{14},'value');
                                switch(val)
                                    case 2, % subject-level aggreagate
                                        set(CONN_h.menus.m_setup_00{14},'value',1);
                                        nl1covariates=get(CONN_h.menus.m_setup_00{1},'value');
                                        conn_convertl12l2covariate(nl1covariates);
                                end
                                return;
						end
					end
					names=get(CONN_h.menus.m_setup_00{1},'string');
					nl1covariates=get(CONN_h.menus.m_setup_00{1},'value'); 
					nsubs=get(CONN_h.menus.m_setup_00{2},'value');
					nsess=get(CONN_h.menus.m_setup_00{3},'value');
					for nsub=1:CONN_x.Setup.nsubjects,
						if length(CONN_x.Setup.l1covariates.files)<nsub, CONN_x.Setup.l1covariates.files{nsub}={}; end
						if length(CONN_x.Setup.l1covariates.files{nsub})<nl1covariates, CONN_x.Setup.l1covariates.files{nsub}{nl1covariates}={}; end
						for nses=1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsub)),
							if nses<=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub)), 
								if length(CONN_x.Setup.l1covariates.files{nsub}{nl1covariates})<nses, CONN_x.Setup.l1covariates.files{nsub}{nl1covariates}{nses}={}; end
								if length(CONN_x.Setup.l1covariates.files{nsub}{nl1covariates}{nses})<3, CONN_x.Setup.l1covariates.files{nsub}{nl1covariates}{nses}{3}=[]; end
							end
						end
                    end
					ok=1; ko=[];
					for nsub=nsubs(:)',
						for nses=nsess(:)',
							if nses<=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub)), 
								if isempty(ko), ko=CONN_x.Setup.l1covariates.files{nsub}{nl1covariates}{nses}{1}; 
								elseif ~all(size(ko)==size(CONN_x.Setup.l1covariates.files{nsub}{nl1covariates}{nses}{1})) || ~all(all(ko==CONN_x.Setup.l1covariates.files{nsub}{nl1covariates}{nses}{1})), ok=0; end; 
							end
						end
                    end
                    if isempty(nses)||numel(CONN_x.Setup.l1covariates.files{nsub}{nl1covariates})<nses||isempty(CONN_x.Setup.l1covariates.files{nsub}{nl1covariates}{nses}{1})
						conn_menu('update',CONN_h.menus.m_setup_00{6},[]);
						set(CONN_h.menus.m_setup_00{5},'string','','tooltipstring','');
                        set(CONN_h.menus.m_setup_00{14},'visible','off'); 
                    elseif ok,
						conn_menu('update',CONN_h.menus.m_setup_00{6},CONN_x.Setup.l1covariates.files{nsub}{nl1covariates}{nses}{3});
                        tempstr=cellstr(CONN_x.Setup.l1covariates.files{nsub}{nl1covariates}{nses}{1});
						set(CONN_h.menus.m_setup_00{5},'string',conn_cell2html(CONN_x.Setup.l1covariates.files{nsub}{nl1covariates}{nses}{2}),'tooltipstring',conn_cell2html(tempstr));
                        set(CONN_h.menus.m_setup_00{14},'visible','on'); 
					else  
						conn_menu('update',CONN_h.menus.m_setup_00{6},[]);
						set(CONN_h.menus.m_setup_00{5},'string','multiple files','tooltipstring','');
                        set(CONN_h.menus.m_setup_00{14},'visible','on'); 
                    end
					ok=1; ko=[];
                    for nsub=1:CONN_x.Setup.nsubjects
                        for nses=1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsub))
                            if isempty(CONN_x.Setup.l1covariates.files{nsub}{nl1covariates}{nses}{1}), ok=0; ko=[nsub nses]; break; end
                        end
                        if ~ok, break; end
                    end
                    conn_menumanager('helpstring','');
                    if ~ok, conn_menumanager('helpstring',sprintf('WARNING: incomplete information (enter covariate file for subject %d session %d)',ko(1),ko(2))); end
                    if strcmp(names{nl1covariates},' '), set(CONN_h.menus.m_setup_00{7},'string','enter covariate name here'); uicontrol(CONN_h.menus.m_setup_00{7}); conn_menumanager('helpstring','WARNING: incomplete information (enter valid covariate name)');
                    else set(CONN_h.menus.m_setup_00{7},'string',deblank(names{nl1covariates}));
                    end
                    
                case 7, % covariates second-level
                    boffset=[.05 .02 0 0];
					if nargin<2,
						conn_menu('frame',boffset+[.19,.15,.52,.65],'SECOND-LEVEL COVARIATES (between-subject effects)');
						CONN_h.menus.m_setup_00{1}=conn_menu('listbox',boffset+[.200,.25,.175,.5],'Covariates','',['<HTML>Select second-level covariate <br/> - click after the last item to add a new covariate <br/> - ',CONN_gui.rightclick,'-click for additional options</HTML>'],'conn(''gui_setup'',1);','conn(''gui_setup'',8);');
						CONN_h.menus.m_setup_00{3}=conn_menu('edit',boffset+[.4,.71,.3,.04],'Covariate name','','Second-level covariate name','conn(''gui_setup'',3);');
						[CONN_h.menus.m_setup_00{2},CONN_h.menus.m_setup_00{4}]=conn_menu('edit2',boffset+[.4,.46,.3,.19],'Values',[],'<HTML>values of this covariate for each subject <br/> - enter one value per subject <br/> - for multiple covariates enter one row of values per covariate (separated by '';'') <br/> - you may also enter functions of other covariates (e.g. AllSubjects - Males)<br/> - other valid syntax include any valid Matlab command or variable name evaluated in the base workspace (e.g. rand)<br/> - note: changes to second-level covariates do not require re-running <i>Setup</i> and subsequent steps<br/> (they are directly available in the <i>second-level Results</i> tab)</HTML>','conn(''gui_setup'',2);');
                        CONN_h.menus.m_setup_00{11}=conn_menu('popup0',boffset+[.20,.15,.20,.05],'',{'<HTML><i> - covariate tools:</i></HTML>','Orthogonalize selected covariate(s)','Import covariate data from file','Export covariate data to file'},'<HTML><i> - Orthogonalize</i> makes the selected covariate(s) orthogonal to other covariate(s) (e.g. for centering or when interested in the unique variance associated with this effect) <br/> - <i>Import</i> loads selected covariate values from a file (Text, Spreadsheet, or Matlab format)<br/> - <i>Export</i> saves selected covariate values to a file (Text, Spreadsheet, or Matlab format)</HTML>','conn(''gui_setup'',10+get(gcbo,''value''));');
                        %CONN_h.menus.m_setup_00{11}=conn_menu('pushbutton',boffset+[.4,.24,.05,.045],'','import','imports values from file','conn(''gui_setup'',11);');
                        %CONN_h.menus.m_setup_00{12}=conn_menu('pushbutton',boffset+[.45,.24,.05,.045],'','export','exports values to file','conn(''gui_setup'',12);');
                        %set([CONN_h.menus.m_setup_00{11},CONN_h.menus.m_setup_00{12}],'visible','off');%,'fontweight','bold');
                        %conn_menumanager('onregion',[CONN_h.menus.m_setup_00{11},CONN_h.menus.m_setup_00{12}],1,boffset+[.4,.24,.3,.41]);
                        CONN_h.menus.m_setup_00{5}=conn_menu('image',boffset+[.40,.24,.30,.20],'');
                        set(CONN_h.menus.m_setup_00{5}.h4,'marker','.');
                        set(CONN_h.menus.m_setup_00{2},'max',2,'userdata',CONN_h.menus.m_setup_00{4},'keypressfcn','if isequal(get(gcbf,''currentcharacter''),13), uicontrol(get(gcbo,''userdata'')); uicontrol(gcbo); end');
                        %CONN_h.menus.m_setup_00{9}=uicontrol('style','pushbutton','units','norm','position',boffset+[.4,.45,.2,.04],'string','Orthogonalize covariate','tooltipstring','Make this covariate orthogonal to other covariate(s) (e.g. for centering or when interested in the unique variance associated with this effect)','callback','conn(''gui_setup'',9);','fontsize',8+CONN_gui.font_offset);
						set(CONN_h.menus.m_setup_00{1},'string',CONN_x.Setup.l2covariates.names,'max',2);
                        hc1=uicontextmenu;
                        uimenu(hc1,'Label','remove selected covariate','callback','conn(''gui_setup'',8);');
                        %uimenu(hc1,'Label','orthogonalize selected covariate','callback','conn(''gui_setup'',9);');
                        set(CONN_h.menus.m_setup_00{1},'uicontextmenu',hc1);
                    else
                        set(CONN_h.menus.m_setup_00{11},'value',1);
						switch(varargin{2}),
							case {2,13},
								nl2covariates=get(CONN_h.menus.m_setup_00{1},'value'); 
                                if varargin{2}==13
                                    [tfilename,tpathname]=uigetfile({'*.txt','text files (*.txt)'; '*.csv','CSV-files (*.csv)'; '*.mat','MAT-files (*.mat)'; '*',  'All Files (*)'},'Select data file');
                                    if ~ischar(tfilename)||isempty(tfilename), return; end
                                    tfilename=fullfile(tpathname,tfilename);
                                    [nill,nill,tfileext]=fileparts(tfilename);
                                    switch(tfileext)
                                        case '.mat'
                                            tdata=load(tfilename,'-mat');
                                            tnames=fieldnames(tdata);
                                            if numel(tnames)==1, idata=1;
                                            else idata=listdlg('liststring',tnames,'selectionmode','single','initialvalue',1,'promptstring','Select variable of interest:','ListSize',[300 200]);
                                            end
                                            if isempty(idata), return; end
                                            tstring=tdata.(tnames{idata});
                                        otherwise,
                                            tstring=char(textread(tfilename,'%s','delimiter','\n'));
                                    end
                                else
                                    tstring=get(CONN_h.menus.m_setup_00{2},'string');
                                    tstring=cellstr(tstring);tstring=sprintf('%s;',tstring{:});
                                end
                                if ischar(tstring), value=str2num(tstring); else value=tstring; end
                                if isempty(value), 
                                    ok=0;
                                    for n1=1:3,
                                        try
                                            switch(n1)
                                                case 1, value=evalin('base',tstring);
                                                case 2,
                                                    x=cell2mat(cellfun(@double,cat(1,CONN_x.Setup.l2covariates.values{:}),'uni',0));
                                                    tnames=CONN_x.Setup.l2covariates.names(1:end-1);
                                                    [nill,idx]=sort(-cellfun('length',tnames));
                                                    for n1=idx(:)',
                                                        for n2=fliplr(strfind(tstring,tnames{n1}))
                                                            tstring=[tstring(1:n2-1) '(' mat2str(x(:,n1)') ')' tstring(n2+numel(tnames{n1}):end)];
                                                        end
                                                    end
                                                    value=evalin('base',tstring);
                                                case 3,
                                                    tstring=regexprep(tstring,'([^\.])(\*)|([^\.])(/)|([^\.])(\^)','$1.$2');
                                                    value=evalin('base',tstring);
                                            end
                                            ok=1;
                                        end
                                        if ok, break; end
                                    end
                                    if ~ok, 
                                        value=[]; 
                                        tstring0=get(CONN_h.menus.m_setup_00{2},'string');
                                        tstring0=cellstr(tstring0);tstring0=sprintf('%s;',tstring0{:});
                                        if isequal(tstring0,tstring), uiwait(warndlg(['Unable to interpret string ',tstring0])); 
                                        else uiwait(warndlg({['Unable to interpret string ',tstring0],['Closest attempt (Matlab string) ',tstring]})); 
                                        end
                                    end
                                end
                                value=double(value);
                                if size(value,2)==1&&size(value,1)==CONN_x.Setup.nsubjects&&numel(nl2covariates)==1, value=value.'; end
                                if size(value,2)~=CONN_x.Setup.nsubjects&&size(value,1)==CONN_x.Setup.nsubjects, value=value.'; end
								if (size(value,2)==CONN_x.Setup.nsubjects && (size(value,1)>1&&numel(nl2covariates)==1)),
                                    answ=questdlg({sprintf('Entered array for multiple covariates (%d)',size(value,1)),sprintf('Do you want to expand selected covariate (%s) into multiple ones (%s to %s)?',CONN_x.Setup.l2covariates.names{nl2covariates},sprintf('%s_%d',CONN_x.Setup.l2covariates.names{nl2covariates},1),sprintf('%s_%d',CONN_x.Setup.l2covariates.names{nl2covariates},size(value,1)))},'','Yes','No','Yes');
                                    if isequal(answ,'Yes')
                                        nl2covariates0=nl2covariates;
                                        nl2covariates0_name=CONN_x.Setup.l2covariates.names{nl2covariates0};
                                        if nl2covariates0==numel(CONN_x.Setup.l2covariates.names)||(nl2covariates0==numel(CONN_x.Setup.l2covariates.names)-1&&isequal(CONN_x.Setup.l2covariates.names{nl2covariates0+1},' ')),
                                            nl2covariates=nl2covariates0+(0:size(value,1)-1);
                                        else
                                            nl2covariates=numel(CONN_x.Setup.l2covariates.names)+(0:size(value,1)-1);
                                        end
                                        for il2covariates=1:numel(nl2covariates)
                                            CONN_x.Setup.l2covariates.names{nl2covariates(il2covariates)}=sprintf('%s_%d',nl2covariates0_name,il2covariates);
                                        end
                                        CONN_x.Setup.l2covariates.names{nl2covariates(end)+1}=' ';
                                        for nsub=1:CONN_x.Setup.nsubjects,
                                            for il2covariates=1:numel(nl2covariates)
                                                CONN_x.Setup.l2covariates.values{nsub}{nl2covariates(il2covariates)}=value(min(size(value,1),il2covariates),min(size(value,2),nsub));
                                            end
                                        end
                                        set(CONN_h.menus.m_setup_00{1},'string',CONN_x.Setup.l2covariates.names,'value',nl2covariates);
                                    end
                                elseif numel(value)==1 || (size(value,2)==CONN_x.Setup.nsubjects && (size(value,1)==1||size(value,1)==numel(nl2covariates))),
									for nsub=1:CONN_x.Setup.nsubjects,
                                        for il2covariates=1:numel(nl2covariates)
                                            CONN_x.Setup.l2covariates.values{nsub}{nl2covariates(il2covariates)}=value(min(size(value,1),il2covariates),min(size(value,2),nsub));
                                        end
                                    end
                                elseif ~isempty(value), uiwait(warndlg(sprintf('Incorrect input string size (expected array size = [%dx%d]; entered array size = [%dx%d])',numel(nl2covariates),CONN_x.Setup.nsubjects,size(value,1),size(value,2))));
								end
							case 3,
								nl2covariates=get(CONN_h.menus.m_setup_00{1},'value'); 
								names=get(CONN_h.menus.m_setup_00{1},'string');
								name=fliplr(deblank(fliplr(deblank(get(CONN_h.menus.m_setup_00{3},'string')))));
								if numel(nl2covariates)==1&&isempty(strmatch(name,names,'exact')),
									names{nl2covariates}=name;
									CONN_x.Setup.l2covariates.names{nl2covariates}=name;
									if nl2covariates==length(CONN_x.Setup.l2covariates.names), CONN_x.Setup.l2covariates.names{nl2covariates+1}=' '; names{nl2covariates+1}=' '; end
									set(CONN_h.menus.m_setup_00{1},'string',names);
								end
                            case 8,
								nl2covariates1=get(CONN_h.menus.m_setup_00{1},'value'); 
                                nl2covariates0=length(CONN_x.Setup.l2covariates.names);
                                nl2covariates=setdiff(nl2covariates1,[nl2covariates0]);
                                nl2covariates=setdiff(1:nl2covariates0,nl2covariates);
                                CONN_x.Setup.l2covariates.names={CONN_x.Setup.l2covariates.names{nl2covariates}};
                                nl2covariates=setdiff(nl2covariates,nl2covariates0);
                                for n1=1:length(CONN_x.Setup.l2covariates.values), CONN_x.Setup.l2covariates.values{n1}={CONN_x.Setup.l2covariates.values{n1}{nl2covariates}}; end
        						set(CONN_h.menus.m_setup_00{1},'string',CONN_x.Setup.l2covariates.names,'value',unique(max(1,min(length(CONN_x.Setup.l2covariates.names)-1,max(nl2covariates1)))));
                            case 11,
                            case 12,
								nl2covariates=get(CONN_h.menus.m_setup_00{1},'value'); 
                                X=zeros(CONN_x.Setup.nsubjects,length(CONN_x.Setup.l2covariates.names)-1);
                                for nsub=1:CONN_x.Setup.nsubjects,
                                    for ncovariate=1:length(CONN_x.Setup.l2covariates.names)-1;
                                        X(nsub,ncovariate)=CONN_x.Setup.l2covariates.values{nsub}{ncovariate};
                                    end
                                end

                                nl2covariates_other=setdiff(1:length(CONN_x.Setup.l2covariates.names)-1,nl2covariates);
                                nl2covariates_subjects=1:CONN_x.Setup.nsubjects;
                                if ~isempty(nl2covariates_other)
                                %if numel(nl2covariates_other)>1
                                    thfig=dialog('units','norm','position',[.3,.3,.3,.3],'windowstyle','normal','name',['Orthogonalize covariate ',sprintf('%s ',CONN_x.Setup.l2covariates.names{nl2covariates})],'color','w','resize','on');
                                    uicontrol(thfig,'style','text','units','norm','position',[.1,.9,.8,.08],'string','Select orthogonal factors:','backgroundcolor','w','fontsize',9+CONN_gui.font_offset,'fontweight','bold');
                                    ht1=uicontrol(thfig,'style','listbox','units','norm','position',[.1,.55,.8,.30],'max',2,'string',CONN_x.Setup.l2covariates.names(nl2covariates_other),'value',1:numel(nl2covariates_other),'fontsize',8+CONN_gui.font_offset);
                                    ht2=uicontrol(thfig,'style','checkbox','units','norm','position',[.1,.45,.8,.10],'value',0,'string','Apply only to non-zero values of covariate','backgroundcolor','w','fontsize',8+CONN_gui.font_offset);
                                    uicontrol(thfig,'style','text','units','norm','position',[.1,.35,.8,.08],'string','New values of covariate:','backgroundcolor','w','fontsize',9+CONN_gui.font_offset,'fontweight','bold');
                                    ht3=uicontrol(thfig,'style','edit','units','norm','position',[.1,.25,.8,.08],'string','','backgroundcolor',.9*[1 1 1],'fontsize',8+CONN_gui.font_offset);
                                    uicontrol(thfig,'style','pushbutton','string','Ok','units','norm','position',[.1,.01,.38,.10],'callback','uiresume','fontsize',8+CONN_gui.font_offset);
                                    uicontrol(thfig,'style','pushbutton','string','Cancel','units','norm','position',[.51,.01,.38,.10],'callback','delete(gcbf)','fontsize',8+CONN_gui.font_offset);
                                    set([ht1 ht2],'callback',@conn_orthogonalizemenuupdate);
                                    conn_orthogonalizemenuupdate;
                                    uiwait(thfig);
                                    ok=ishandle(thfig);
                                    if ok, 
                                        nl2covariates_other=nl2covariates_other(get(ht1,'value'));
                                        if get(ht2,'value'), nl2covariates_subjects=find(any(X(:,nl2covariates)~=0,2)&~any(isnan(X(:,nl2covariates)),2)&~any(isnan(X(:,nl2covariates_other)),2)); 
                                        else nl2covariates_subjects=find(~any(isnan(X(:,nl2covariates)),2)&~any(isnan(X(:,nl2covariates_other)),2)); 
                                        end
                                        delete(thfig);
                                    else nl2covariates_other=[];
                                    end
                                end
                                if ~isempty(nl2covariates_other)
                                    X(nl2covariates_subjects,nl2covariates)=X(nl2covariates_subjects,nl2covariates)-X(nl2covariates_subjects,nl2covariates_other)*(X(nl2covariates_subjects,nl2covariates_other)\X(nl2covariates_subjects,nl2covariates));
                                    for nsub=1:CONN_x.Setup.nsubjects,
                                        for ncovariate=nl2covariates(:)'
                                            CONN_x.Setup.l2covariates.values{nsub}{ncovariate}=X(nsub,ncovariate);
                                        end
                                    end
                                end
                            case 14
                                [tfilename,tpathname]=uiputfile({'*.txt','text files (*.txt)'; '*.csv','CSV-files (*.csv)'; '*.mat','MAT-files (*.mat)'; '*',  'All Files (*)'},'Output data to file:');
                                if ~ischar(tfilename)||isempty(tfilename), return; end
                                tfilename=fullfile(tpathname,tfilename);
                                [nill,nill,tfileext]=fileparts(tfilename);
                                nl2covariates=get(CONN_h.menus.m_setup_00{1},'value');
                                tt=[];
                                for il2covariate=1:numel(nl2covariates),
                                    t=[];
                                    for nsub=1:CONN_x.Setup.nsubjects,
                                        if length(CONN_x.Setup.l2covariates.values)<nsub, CONN_x.Setup.l2covariates.values{nsub}={}; end
                                        if length(CONN_x.Setup.l2covariates.values{nsub})<nl2covariates(il2covariate), CONN_x.Setup.l2covariates.values{nsub}{nl2covariates(il2covariate)}=0; end
                                        t=cat(2,t,CONN_x.Setup.l2covariates.values{nsub}{nl2covariates(il2covariate)});
                                    end
                                    tt=cat(1,tt,t);
                                end
                                switch(tfileext)
                                    case '.mat'
                                        data=tt.';
                                        save(tfilename,'data');
                                    otherwise,
                                        fh=fopen(tfilename,'wt');
                                        for n2=1:size(tt,2),
                                            for n1=1:size(tt,1),
                                                fprintf(fh,'%f',tt(n1,n2));
                                                if n1<size(tt,1)&&strcmp(tfileext,'.csv'), fprintf(fh,','); elseif n1<size(tt,1), fprintf(fh,' '); else fprintf(fh,'\n'); end
                                            end
                                        end
                                        fclose(fh);
                                end
                                conn_msgbox({'Data saved to file',tfilename},'',true);
                                return;
                        end
					end
					names=get(CONN_h.menus.m_setup_00{1},'string');
					nl2covariates=get(CONN_h.menus.m_setup_00{1},'value'); 
                    if numel(nl2covariates)==1
                        set(CONN_h.menus.m_setup_00{3},'visible','on');
                        conn_menumanager('helpstring','');
                        if strcmp(names{nl2covariates},' '), set(CONN_h.menus.m_setup_00{3},'string','enter covariate name here'); uicontrol(CONN_h.menus.m_setup_00{3}); conn_menumanager('helpstring','WARNING: incomplete information (enter valid covariate name)');
                        else set(CONN_h.menus.m_setup_00{3},'string',deblank(names{nl2covariates}));
                        end
                    else
                        set(CONN_h.menus.m_setup_00{3},'visible','off')
                    end
                    tt=[];
                    for il2covariate=1:numel(nl2covariates),
                        t=[];
                        for nsub=1:CONN_x.Setup.nsubjects,
                            if length(CONN_x.Setup.l2covariates.values)<nsub, CONN_x.Setup.l2covariates.values{nsub}={}; end
                            if length(CONN_x.Setup.l2covariates.values{nsub})<nl2covariates(il2covariate), CONN_x.Setup.l2covariates.values{nsub}{nl2covariates(il2covariate)}=0; end
                            t=cat(2,t,CONN_x.Setup.l2covariates.values{nsub}{nl2covariates(il2covariate)});
                        end
                        tt=cat(1,tt,t);
                    end
                    set(CONN_h.menus.m_setup_00{2},'string',mat2str(tt,max([0,ceil(log10(max(1e-10,abs(tt(:)'))))])+6));
                    set(CONN_h.menus.m_setup_00{11},'value',1);
                    conn_menu('update',CONN_h.menus.m_setup_00{5},tt');
                    %k=t; for n=0:6, if abs(round(k)-k)<1e-6, break; end; k=k*10; end;
                    %set(CONN_h.menus.m_setup_00{2},'string',num2str(t,['%0.',num2str(n),'f ']));
                    %if numel(CONN_x.Setup.l2covariates.names)<=1+numel(nl2covariates), set(CONN_h.menus.m_setup_00{9},'visible','off'); else set(CONN_h.menus.m_setup_00{9},'visible','on'); end
                    
                case 8, % options
                    boffset=[.05 -.05 0 0];
                    if nargin<2,
                        conn_menu('frame',boffset+[.19,.25,.57,.60],'PROCESSING OPTIONS');
                        analysistypes={'ROI-to-ROI','Seed-to-Voxel','Voxel-to-Voxel','Dynamic FC'};
                        CONN_h.menus.m_setup_00{1}=conn_menu('checkbox2',boffset+[.2,.75,.25,.04],'Enabled analyses',analysistypes,{'Enable ROI-to-ROI analyses','Enable Seed-to-Voxel analyses','Enable Voxel-to-Voxel analyses','Enable dynamic connectivity analyses'},'conn(''gui_setup'',1);');
                        values=CONN_x.Setup.steps;
                        for n1=1:numel(values),set(CONN_h.menus.m_setup_00{1}(n1),'value',values(n1)>0);end
                        analysistypes={'Volume: same as template (2mm isotropic voxels)','Volume: same as structurals','Volume: same as functionals','Surface: same as template (Freesurfer fsaverage)'};
                        CONN_h.menus.m_setup_00{2}=conn_menu('popup',boffset+[.2,.5,.25,.05],'Analysis space (voxel-level)',analysistypes,'<HTML>Choose analysis space <br/> - for <i>volume-based</i> analyses this option defines the dimensionality (bounding box) and spatial resolution (voxel size) of the analyses <br/> - select <i>surface-based</i> for analyses on the cortical surface (this requires selecting FreeSurfer-generated structural files in Setup->Structurals)</HTML>','conn(''gui_setup'',2);');
                        set(CONN_h.menus.m_setup_00{2},'value',CONN_x.Setup.spatialresolution);
                        analysistypes={'Explicit mask ','Implicit mask (subject-specific)'};
                        [nill,tfilename,tfilename_ext]=fileparts(CONN_x.Setup.explicitmask{1});
                        analysistypes{1}=[analysistypes{1},'(',tfilename,tfilename_ext,')'];
                        CONN_h.menus.m_setup_00{3}=conn_menu('popup',boffset+[.2,.4,.25,.05],'Analysis mask (voxel-level)',analysistypes,'<HTML>Choose analysis mask for voxel-based analyses <br/> - select <i>explicit mask</i> for user-defined analysis mask (defaults to MNI-space brainmask for volume-based analyses or fsaverage cortical mask for surface-based analyses) <br/> - select <i>implicit mask</i> to use subject-specific brainmasks derived from global BOLD signal amplitude</HTML>','conn(''gui_setup'',3);');
                        analysistypes={'PSC (percent signal change)','Raw'};
                        CONN_h.menus.m_setup_00{5}=conn_menu('popup',boffset+[.2,.3,.25,.05],'Analysis units',analysistypes,'Choose BOLD signal units for analyses','conn(''gui_setup'',5);');
                        %set(CONN_h.menus.m_setup_00{11},'value',CONN_x.Setup.crop);
                        set(CONN_h.menus.m_setup_00{3},'value',CONN_x.Setup.analysismask);
                        set(CONN_h.menus.m_setup_00{5},'value',CONN_x.Setup.analysisunits);
                        analysistypes={'Create confound effects beta-maps','Create confound-corrected time-series','Create first-level seed-to-voxel r-maps','Create first-level seed-to-voxel p-maps','Create first-level seed-to-voxel FDR-p maps','Create ROI-extraction REX files'};
                        CONN_h.menus.m_setup_00{4}=conn_menu('checkbox2',boffset+[.5,.5,.25,.04],'Optional output files',analysistypes,'Choose optional output files to be generated during the analyses','conn(''gui_setup'',4);');
                        for n1=1:numel(analysistypes),set(CONN_h.menus.m_setup_00{4}(n1),'value',CONN_x.Setup.outputfiles(n1));end
                        if any(CONN_x.Setup.steps([2,3])), set([CONN_h.menus.m_setup_00{2},CONN_h.menus.m_setup_00{3},CONN_h.menus.m_setup_00{4}],'visible','on'); else set([CONN_h.menus.m_setup_00{2},CONN_h.menus.m_setup_00{3},CONN_h.menus.m_setup_00{4}(1:end-1)],'visible','off'); end
                        if any(CONN_x.Setup.steps(2)), set(CONN_h.menus.m_setup_00{4}(3:5),'visible','on'); else set(CONN_h.menus.m_setup_00{4}(3:5),'visible','off'); end
                        if any(CONN_x.Setup.steps(1)), set(CONN_h.menus.m_setup_00{4}(6),'visible','on'); else set(CONN_h.menus.m_setup_00{4}(6),'visible','off'); end
                        if any(CONN_x.Setup.steps([1,2])), set([CONN_h.menus.m_setup_00{1}(4)],'visible','on'); else set([CONN_h.menus.m_setup_00{1}(4)],'visible','off'); end
                        if any(CONN_x.Setup.steps), set([CONN_h.menus.m_setup_00{5}],'visible','on'); else set([CONN_h.menus.m_setup_00{5}],'visible','off'); end
                    else
                        switch(varargin{2}),
                            case 1, 
                                for n1=1:4,value=get(CONN_h.menus.m_setup_00{1}(n1),'value');CONN_x.Setup.steps(n1)=value; end
                                if any(CONN_x.Setup.steps([2,3])), set([CONN_h.menus.m_setup_00{2},CONN_h.menus.m_setup_00{3},CONN_h.menus.m_setup_00{4}],'visible','on'); else set([CONN_h.menus.m_setup_00{2},CONN_h.menus.m_setup_00{3},CONN_h.menus.m_setup_00{4}(1:end-1)],'visible','off'); end
                                if any(CONN_x.Setup.steps(2)), set(CONN_h.menus.m_setup_00{4}(3:5),'visible','on'); else set(CONN_h.menus.m_setup_00{4}(3:5),'visible','off'); end
                                if any(CONN_x.Setup.steps(1)), set(CONN_h.menus.m_setup_00{4}(6),'visible','on'); else set(CONN_h.menus.m_setup_00{4}(6),'visible','off'); end
                                if any(CONN_x.Setup.steps([1,2])), set([CONN_h.menus.m_setup_00{1}(4)],'visible','on'); else set([CONN_h.menus.m_setup_00{1}(4)],'visible','off'); end
                                if any(CONN_x.Setup.steps), set([CONN_h.menus.m_setup_00{5}],'visible','on'); else set([CONN_h.menus.m_setup_00{5}],'visible','off'); end
                            case 2, 
                                value=get(CONN_h.menus.m_setup_00{2},'value'); CONN_x.Setup.spatialresolution=value;
                                if CONN_x.Setup.spatialresolution==4
                                    answ=inputdlg({'BOLD signal surface-based smoothing level (number of diffusion steps)'},'Surface-based analysis options',1,{num2str(CONN_x.Setup.surfacesmoothing)});
                                    if ~isempty(answ)
                                        if ~isempty(str2num(answ{1}))
                                            CONN_x.Setup.surfacesmoothing=max(0,str2num(answ{1}));
                                        end
                                    end
                                end
							case 3, value=get(CONN_h.menus.m_setup_00{3},'value'); CONN_x.Setup.analysismask=value;
                                if value==1
                                    [tfilename,tpathname]=uigetfile('*.nii; *.img','Select explicit mask',CONN_x.Setup.explicitmask{1});
                                    if ischar(tfilename),
                                        CONN_x.Setup.explicitmask=conn_file(fullfile(tpathname,tfilename)); 
                                        analysistypes={'Explicit mask ','Implicit mask (subject-specific)'};
                                        [nill,tfilename,tfilename_ext]=fileparts(CONN_x.Setup.explicitmask{1});
                                        analysistypes{1}=[analysistypes{1},'(',tfilename,tfilename_ext,')'];
                                        set(CONN_h.menus.m_setup_00{3},'string',analysistypes);
                                    end
                                end
                            case 4, for n1=1:numel(CONN_h.menus.m_setup_00{4}),value=get(CONN_h.menus.m_setup_00{4}(n1),'value');CONN_x.Setup.outputfiles(n1)=value; end
							case 5, value=get(CONN_h.menus.m_setup_00{5},'value'); CONN_x.Setup.analysisunits=value;
                        end
                    end
                    
			end
% 		case 'gui_setup_covariates',
% 			state=conn_menumanager(CONN_h.menus.m_setup_02,'state');state=0*state;state(6)=1;conn_menumanager(CONN_h.menus.m_setup_02,'state',state,'on',1);	
% 			state=find(conn_menumanager(CONN_h.menus.m_setup_03,'state'));
%             if nargin<2,
%                 conn_menumanager clf;
%                 conn_menuframe;
% 				conn_menumanager([CONN_h.menus.m_setup_02,CONN_h.menus.m_setup_01d,CONN_h.menus.m_setup_06,CONN_h.menus.m0],'on',1);
%             end
% 			if isempty(state) return; end
%             boffset=[0 0 0 0];
% 			switch(state),
% 				case 1, % first-level covariates
% 
%                     
% 				case 2, %Covariates (L2)
% 			end

		case 'gui_setup_load',
            [filename,pathname]=uigetfile({'*.mat','conn-project files (conn_*.mat)';'*','All Files (*)'},'Loads experiment data','conn_*.mat');
            %[filename,pathname]=uigetfile({'conn_*.mat','conn-project files (conn_*.mat)'},'Loads experiment data');
			if ischar(filename),
				filename=fullfile(pathname,filename);
                ht=conn_msgbox('Loading project file. Please wait...');
                fprintf('Loading project file. Please wait...');
                conn('load',filename,true);
                fprintf(' Done\n');
                if ishandle(ht), delete(ht); end
% 				try, load(filename,'CONN_x'); CONN_x.filename=filename; catch, waitfor(errordlg(['Failed to load file ',filename,'.'],mfilename)); return; end
%                 try, conn_updatefilepaths; end
%                 CONN_x.filename=filename;
%                 conn_updatefolders;
			end
            conn gui_setup;
			
		case {'gui_setup_save','gui_setup_saveas','gui_setup_saveas_nowarning'},
            if strcmp(varargin{1},'gui_setup_saveas')
                answ=questdlg('Warning: Using ''save as'' will create a copy of the current project with all of the current project definitions but NONE of the analyses performed until now. Do you wish to continue?', 'conn','Stop','Continue','Continue');
                if ~strcmp(answ,'Continue'), return; end
            end
            if nargin<2||isempty(varargin{2}), strmsg='Save experiment data'; else strmsg=varargin{2}; end
			if strcmp(varargin{1},'gui_setup_saveas') || strcmp(varargin{1},'gui_setup_saveas_nowarning') || isempty(CONN_x.filename) || ~ischar(CONN_x.filename), if isempty(CONN_x.filename)||~ischar(CONN_x.filename), filename='conn_project01.mat'; else  filename=CONN_x.filename; end; [filename,pathname]=uiputfile('conn_*.mat',strmsg,filename);
			else pathname='';filename=CONN_x.filename; end
			if ischar(filename),
				set(CONN_h.screen.hfig,'pointer','watch');
				filename=fullfile(pathname,filename);
                fprintf('Saving file. Please wait...');
                conn('save',filename);
                fprintf(' Done\n');
				set(CONN_h.screen.hfig,'pointer','arrow');
            end

        case 'gui_setup_new',
            Answ=questdlg({'Proceeding will close the current project and loose any unsaved progress',' ','Do you want to proceed with creating a new project?'},'New project','Proceed','Cancel','Proceed');
            if strcmp(Answ,'Proceed')
                conn init;
                conn importrois;
                conn gui_setup;
                conn('gui_setup_save','Select New project filename:');
            end
            
        case 'gui_setup_wizard'
            Answ=questdlg({'Proceeding will close the current project and loose any unsaved progress',' ','Do you want to proceed with creating a new project?'},'New project','Proceed','Cancel','Proceed');
            if strcmp(Answ,'Proceed')
                conn_setup_wizard;
                conn gui_setup;
            end
            %Answ=questdlg({'New project creation (note: proceeding will close the current project and loose any unsaved progress)',' ','Do you want to use a wizard to select and preprocess your new project data now (e.g. realignment/normalization/smoothing)?',' ','Choosing ''no'' will still allow you to preprocess your data at a later time (select your data on the main CONN gui Functional/Structural tabs, and then preprocess it if required using the ''Preprocessing'' button)'},'New project','Yes','No','Cancel','No');
%             if strcmp(Answ,'Yes'),
%                 conn_setup_wizard;
%                 conn gui_setup;
%             elseif strcmp(Answ,'No')
%                 conn init;
%                 conn importrois;
%                 conn gui_setup;
%                 conn save;
%             end
            
		case 'gui_setup_import',
            boffset=[0 0 0 0];
			if nargin<2
                conn_menumanager clf;
                conn_menuframe;
				conn_menumanager([CONN_h.menus.m_setup_04,CONN_h.menus.m_setup_06,CONN_h.menus.m0],'on',1);
				
				conn_menu('frame',boffset+[.19,.13,.295,.67],'IMPORT SETUP FROM SPM');
				CONN_h.menus.m_setup_00{1}=conn_menu('listbox',boffset+[.2,.15,.075,.5],'Subjects','','Select each subject and enter one SPM.mat file (one file per subject) or multiple SPM.mat files (one file per session)','conn(''gui_setup_import'',1);');
				CONN_h.menus.m_setup_00{2}=conn_menu('edit',boffset+[.2,.7,.2,.04],'Number of subjects',num2str(CONN_x.Setup.nsubjects),'Number of subjects in this experiment','conn(''gui_setup_import'',2);');
				CONN_h.menus.m_setup_00{3}=conn_menu('filesearch',[],'Select SPM.mat files','SPM.mat','',{@conn,'gui_setup_import',3},'conn(''gui_setup_import'',4);');
				CONN_h.menus.m_setup_00{4}=conn_menu('pushbutton2', boffset+[.275,.46,.2,.19],'Files','','','conn(''gui_setup_import'',4)');
				CONN_h.menus.m_setup_00{5}=conn_menu('image',boffset+[.285,.15,.17,.3]);
				set(CONN_h.menus.m_setup_00{1},'string',[repmat('Subject ',[CONN_x.Setup.nsubjects,1]),num2str((1:CONN_x.Setup.nsubjects)')],'max',2);
                set(CONN_h.menus.m_setup_00{3}.files,'max',2);
			else
				switch(varargin{2}),
					case 1, 
					case 2,
						value0=CONN_x.Setup.nsubjects; 
						txt=get(CONN_h.menus.m_setup_00{2},'string'); value=str2num(txt); if ~isempty(value)&&length(value)==1, CONN_x.Setup.nsubjects=value; end; 
						if CONN_x.Setup.nsubjects~=value0, CONN_x.Setup.nsubjects=conn_merge(value0,CONN_x.Setup.nsubjects); end
						set(CONN_h.menus.m_setup_00{2},'string',num2str(CONN_x.Setup.nsubjects)); 
						set(CONN_h.menus.m_setup_00{1},'string',[repmat('Subject ',[CONN_x.Setup.nsubjects,1]),num2str((1:CONN_x.Setup.nsubjects)')],'max',2,'value',unique(min(CONN_x.Setup.nsubjects,get(CONN_h.menus.m_setup_00{1},'value'))));
					case 3,
						if nargin<4, nsubs=get(CONN_h.menus.m_setup_00{1},'value'); else  nsubs=varargin{4}; end
						filename=fliplr(deblank(fliplr(deblank(varargin{3}))));
                        txt=''; bak1=CONN_x.Setup.spm;
                        if size(filename,1)==length(nsubs)
                            for nsub=1:length(nsubs)
                                CONN_x.Setup.spm{nsubs(nsub)}=conn_file(deblank(filename(nsub,:)));
                            end
                            txt=sprintf('%d files assigned to %d subjects\n',size(filename,1),length(nsubs));
                        elseif length(nsubs)==1
                            CONN_x.Setup.spm{nsubs}=conn_file(filename);
                            txt=sprintf('%d files assigned to %d subjects\n',size(filename,1),length(nsubs));
                        else
                            errordlg(sprintf('mismatched number of files (%d files; %d subjects)',size(filename,1),length(nsubs)),'');
                        end
                        if ~isempty(txt)&&strcmp(questdlg(txt,'','Ok','Undo','Ok'),'Undo'), CONN_x.Setup.spm=bak1;end
                    case 4,
                        nsubs=get(CONN_h.menus.m_setup_00{1},'value');
                        if ~isempty(CONN_x.Setup.spm{nsubs(1)}{1})
                            tempstr=cellstr(CONN_x.Setup.spm{nsubs(1)}{1});
                            [nill,tempstr_name,tempstr_ext]=cellfun(@spm_fileparts,tempstr,'uni',0);
                            tempstr_name=cellfun(@(a,b)[a b],tempstr_name,tempstr_ext,'uni',0);
                            set(CONN_h.menus.m_setup_00{3}.selectfile,'string',unique(tempstr_name));
                            set(CONN_h.menus.m_setup_00{3}.folder,'string',fileparts(tempstr{1}));
                            conn_filesearchtool(CONN_h.menus.m_setup_00{3}.folder,[],'folder',true);
                        end
				end
			end
			nsubs=get(CONN_h.menus.m_setup_00{1},'value');
			conn_menu('updatematrix',CONN_h.menus.m_setup_00{5},CONN_x.Setup.spm{nsubs(1)}{3});
			set(CONN_h.menus.m_setup_00{4},'string',conn_cell2html(CONN_x.Setup.spm{nsubs(1)}{2}));
				
		case 'gui_setup_importdone',
			conn_importspm;
			conn gui_setup;
			%conn_menumanager clf;
			%axes('units','norm','position',[0,.935,1,.005]); image(shiftdim(1-CONN_gui.backgroundcolorA,-1)); axis off;
			%conn_menumanager([CONN_h.menus.m_setup_02,CONN_h.menus.m_setup_01d,CONN_h.menus.m0],'on',1);
			
		case 'gui_setup_merge',
            boffset=[0 0 0 0];
			if nargin<2
                conn_menumanager clf;
                conn_menuframe;
				conn_menumanager([CONN_h.menus.m_setup_05,CONN_h.menus.m_setup_06,CONN_h.menus.m0],'on',1);
                
                CONN_x.Setup.merge.nprojs=1;
                CONN_x.Setup.merge.files={{[],[],[]}};
                CONN_x.Setup.merge.type=1;
                conn_menu('frame',boffset+[.19,.13,.37,.67],'MERGE MULTIPLE CONN PROJECTS');
                CONN_h.menus.m_setup_00{1}=conn_menu('listbox',boffset+[.2,.15,.15,.45],'Projects','','','conn(''gui_setup_merge'',1);');
				CONN_h.menus.m_setup_00{2}=conn_menu('edit',boffset+[.2,.7,.15,.04],'Number of projects',num2str(1),'Number of projects to merge','conn(''gui_setup_merge'',2);');
                CONN_h.menus.m_setup_00{6}=conn_menu('popup',boffset+[.2,.65,.15,.04],'',{'Add to current project','Create new project'},'<HTML> Selecting <i>Add to current project</i> will add all of the subjects in the selected projects to the current project <br/> Selecting <i>Create new project</i> will disregard the current project and combine all of the subjects in the selected projects as a new project instead</HTML>','conn(''gui_setup_merge'',6);');
				CONN_h.menus.m_setup_00{3}=conn_menu('filesearch',[],'Select conn_*.mat project files','conn_*.mat','',{@conn,'gui_setup_merge',3});
 				CONN_h.menus.m_setup_00{4}=conn_menu('text', boffset+[.35,.46,.2,.19],'Files');
				CONN_h.menus.m_setup_00{5}=conn_menu('image',boffset+[.36,.15,.17,.3]);
				set(CONN_h.menus.m_setup_00{1},'string',[repmat('Project ',[CONN_x.Setup.merge.nprojs,1]),num2str((1:CONN_x.Setup.merge.nprojs)')],'max',1);
			else
				switch(varargin{2}),
					case 1, 
					case 2,
						value0=CONN_x.Setup.merge.nprojs; 
						txt=get(CONN_h.menus.m_setup_00{2},'string'); value=str2num(txt); 
                        if ~isempty(value)&&length(value)==1, CONN_x.Setup.merge.nprojs=value; end; 
                        for n0=value0+1:CONN_x.Setup.merge.nprojs,CONN_x.Setup.merge.files{n0}={[],[],[]};end
                        CONN_x.Setup.merge.files={CONN_x.Setup.merge.files{1:CONN_x.Setup.merge.nprojs}};
						set(CONN_h.menus.m_setup_00{2},'string',num2str(CONN_x.Setup.merge.nprojs)); 
						set(CONN_h.menus.m_setup_00{1},'string',[repmat('Project ',[CONN_x.Setup.merge.nprojs,1]),num2str((1:CONN_x.Setup.merge.nprojs)')],'max',1,'value',min(CONN_x.Setup.merge.nprojs,get(CONN_h.menus.m_setup_00{1},'value')));
					case 3,
						if nargin<4, nprojs=get(CONN_h.menus.m_setup_00{1},'value'); else  nprojs=varargin{4}; end
						filename=fliplr(deblank(fliplr(deblank(varargin{3}))));
						[V,str,icon,filename]=conn_getinfo(filename);
						CONN_x.Setup.merge.files{nprojs}={filename,str,icon};
                    case 6,
                        CONN_x.Setup.merge.type=get(CONN_h.menus.m_setup_00{6},'value');
				end
			end
			nprojs=get(CONN_h.menus.m_setup_00{1},'value');
			conn_menu('update',CONN_h.menus.m_setup_00{5},CONN_x.Setup.merge.files{nprojs}{3});
			set(CONN_h.menus.m_setup_00{4},'string',CONN_x.Setup.merge.files{nprojs}{2});
				
		case 'gui_setup_mergedone',
            filenames=[];for n1=1:CONN_x.Setup.merge.nprojs,filenames=strvcat(filenames,CONN_x.Setup.merge.files{n1}{1});end
            hm=conn_msgbox('Merging projects... please wait','');
            switch(CONN_x.Setup.merge.type)
                case 1, 
                    value0=CONN_x.Setup.nsubjects;
                    value=conn_merge(filenames);
                case 2, 
                    answ=questdlg({'Proceeding will close the current project and loose any unsaved progress','Do you want to:'},'Warning','Continue','Cancel','Continue');
                    if ~strcmp(answ,'Continue'), if ishandle(hm), close(hm); end; return; end
                    filename='conn_project01.mat'; [filename,pathname]=uiputfile('conn_*.mat','New project name',filename);
                    if ~ischar(filename)||isempty(filename), if ishandle(hm), close(hm); end; return; end
                    filename=fullfile(pathname,filename);
                    conn('load',deblank(filenames(1,:)));
                    conn('save',filename);
                    value0=CONN_x.Setup.nsubjects;
                    value=conn_merge(filenames,[],true,true);
            end
            if value~=value0,
                CONN_x.Setup.nsubjects=value;
                if ishandle(hm), close(hm); end
                conn gui_setup;
                try, conn_process('postmerge'); end
            else 
                if ishandle(hm), close(hm); end
                hm=conn_msgbox('There were problems importing the new subject data. Check the command line for further information','',true);
            end
			%conn_menumanager clf;
			%axes('units','norm','position',[0,.935,1,.005]); image(shiftdim(1-CONN_gui.backgroundcolorA,-1)); axis off;
			%conn_menumanager([CONN_h.menus.m_setup_02,CONN_h.menus.m_setup_01d,CONN_h.menus.m0],'on',1);
			
		case 'gui_setup_finish',
			if isempty(CONN_x.filename), conn gui_setup_save; end
            if conn_questdlg('Ready to run Setup pipeline',[],CONN_x.Setup.steps(1:3),false,[],true);
                conn_menumanager clf;
                conn_menuframe;
                conn_menumanager([CONN_h.menus.m_setup_06,CONN_h.menus.m0],'on',1);
                if CONN_x.gui.parallel~=0, 
                    if CONN_x.gui.parallel>0, conn_jobmanager('options','profile',CONN_x.gui.parallel); end; 
                    conn save;
                    conn_jobmanager('submit','setup',[],CONN_x.gui);
                else conn_process('setup');
                end
                CONN_x.gui=1;
                conn gui_setup_save;
                if ~conn_projectmanager('ispending'), conn gui_preproc; end
            end
			
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%			
		case 'gui_preproc',
            CONN_x.gui=1;
			model=0;
            boffset=[.00 .05 0 0];
            if nargin<2,
                conn_menumanager clf;
                conn_menuframe;
				tstate=conn_menumanager(CONN_h.menus.m0,'state'); tstate(:)=0;tstate(2)=1; conn_menumanager(CONN_h.menus.m0,'state',tstate); 
				conn_menumanager([CONN_h.menus.m_preproc_02,CONN_h.menus.m_setup_06,CONN_h.menus.m0],'on',1);
				if isempty(CONN_x.Preproc.variables.names), uiwait(errordlg('Run first the Setup step by pressing "Done" in the Setup tab','Data not prepared for analyses')); conn gui_setup; return; end
                conn_menu('nullstr',{'No data','to display'});

				%conn_menu('frame',boffset+[.04,.27,.37,.53],'DENOISING OPTIONS');
				%conn_menu('frame',boffset+[.04,.06,.37,.205]);
				conn_menu('frame',boffset+[.04,.06,.39,.74]);
				[nill,CONN_h.menus.m_preproc_00{7}]=conn_menu('text',boffset+[.05,.70,.26,.05],'Linear regression of confounding effects:');
                set(CONN_h.menus.m_preproc_00{7},'horizontalalignment','left');
				CONN_h.menus.m_preproc_00{1}=conn_menu('listbox',boffset+[.05,.22,.075,.48],'all effects','','List of all effects','conn(''gui_preproc'',1);');
				CONN_h.menus.m_preproc_00{2}=conn_menu('listbox',boffset+[.15,.50,.135,.20],'Confounds','','<HTML>List of potential confounding effects (e.g. physiological/movement). <br/> - Linear regression will be used to remove these effects from the BOLD signal <br/> - Select effects in the <i>all effects</i> list and click <b> > </b> to add new effects to this list <br/> - By default this list includes White matter and CSF BOLD timeseries (CompCor), all first-level covariates <br/> (e.g. motion-correction and scrubbing), and all main task effects (for task designs) </HTML>','conn(''gui_preproc'',2);');
				CONN_h.menus.m_preproc_00{4}=conn_menu('edit',boffset+[.30,.69,.09,.05],'Derivatives order','','Include derivates up to n-th order of selected effect (0 for no derivatives, 1 for first-order derivatives,...)','conn(''gui_preproc'',4);');
				CONN_h.menus.m_preproc_00{6}=conn_menu('edit',boffset+[.30,.59,.09,.05],'Dimensions','','<HTML>Number of dimensions of selected effect (<i>inf</i> for all dimensions)</HTML>','conn(''gui_preproc'',6);');
				CONN_h.menus.m_preproc_00{5}=conn_menu('edit',boffset+[.05,.12,.16,.05],'Band-pass filter (Hz):',mat2str(CONN_x.Preproc.filter),'BOLD signal Band-Pass filter threshold. Two values (in Hz): high-pass and low-pass thresholds, respectively','conn(''gui_preproc'',5);');
                CONN_h.menus.m_preproc_00{20}=conn_menu('popup',boffset+[.05,.07,.17,.05],'',{'After regression (RegBP)','Simultaneous (simult)'},'Order of band-pass filtering step (RegBP: regression followed by band-pass; Simult: simultaneous regression&band-pass)','conn(''gui_preproc'',20);');
				CONN_h.menus.m_preproc_00{18}=conn_menu('popup',boffset+[.24,.12,.15,.05],'Additional steps:',{'No detrending','Linear detrending','Quadratic detrending','Cubic detrending'},'BOLD signal session-specific detrending','conn(''gui_preproc'',18);');
				CONN_h.menus.m_preproc_00{19}=conn_menu('popup',boffset+[.24,.07,.15,.05],'',{'No despiking','Despiking before regression','Despiking after regression'},'BOLD signal despiking with a hyperbolic tangent squashing function (before or after confound removal regression)','conn(''gui_preproc'',19);');
                CONN_h.menus.m_preproc_00{22}=[uicontrol('style','frame','units','norm','position',boffset+[.30,.48,.11,.30],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA),...
                    uicontrol('style','frame','units','norm','position',boffset+[.13,.22,.29,.27],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA)];
                %CONN_h.menus.m_preproc_00{21}=conn_menu('popup',boffset+[.22,.07,.15,.05],'',{'No dynamic estimation','Estimate dynamic effects'},'Estimates temporal components characterizing potential dynamic functional connectivity effects','conn(''gui_setup'',21);');
				CONN_h.menus.m_preproc_00{3}=conn_menu('image',boffset+[.12,.22,.30,.23],'Confound timeseries');
				conn_menu('frame2',boffset+[.46,.03,.51,.80],'Preview effect of Denoising');
				CONN_h.menus.m_preproc_00{11}=conn_menu('listbox',boffset+[.47,.45,.11,.3],'Subjects','','Select subject to display','conn(''gui_preproc'',11);');
				CONN_h.menus.m_preproc_00{12}=conn_menu('listbox',boffset+[.58,.45,.11,.3],'Sessions','','Select session to display','conn(''gui_preproc'',12);');
				%CONN_h.menus.m_preproc_00{13}=conn_menu('listbox',boffset+[.59,.45,.075,.3],'Confounds','','Select confound to display','conn(''gui_preproc'',13);');
				CONN_h.menus.m_preproc_00{13}=conn_menu('popup',boffset+[.79,.78,.10,.05],'',{' TOTAL'},'Select confound to display','conn(''gui_preproc'',13);');
				[CONN_h.menus.m_preproc_00{16},CONN_h.menus.m_preproc_00{17}]=conn_menu('hist',boffset+[.47,.17,.225,.20],'Histogram of functional connectivity values');
                CONN_h.menus.m_preproc_00{21}=uicontrol('style','text','units','norm','position',boffset+[.47,.08,.225,.04],'string','voxel-to-voxel r','backgroundcolor',CONN_gui.backgroundcolorA,'foregroundcolor',CONN_gui.fontcolorB,'fontsize',8+CONN_gui.font_offset);
                
                %hc1=uicontextmenu;uimenu(hc1,'Label','Show Histogram for all subjects/sessions','callback',@conn_displaydenoisinghistogram);set([CONN_h.menus.m_preproc_00{16}.h1, CONN_h.menus.m_preproc_00{16}.h3, CONN_h.menus.m_preproc_00{16}.h4, CONN_h.menus.m_preproc_00{16}.h5],'uicontextmenu',hc1);
                CONN_h.menus.m_preproc_00{33}=conn_menu('pushbutton',boffset+[.52,.03,.125,.045],'','show all','compute and display voxel-to-voxel histograms for all subjects/sessions','conn_displaydenoisinghistogram;');
                set([CONN_h.menus.m_preproc_00{33}],'visible','off');%,'fontweight','bold');
                conn_menumanager('onregion',[CONN_h.menus.m_preproc_00{33}],1,boffset+[.47,.02,.225,.40]);
                
				pos=[.73,.10,.22,.65];
				if any(CONN_x.Setup.steps([2,3])),
                    uicontrol('style','text','units','norm','position',boffset+[pos(1)+pos(3)-.170,pos(2)-1*.055,.070,.04],'string','threshold','fontname','default','fontsize',8+CONN_gui.font_offset,'backgroundcolor',CONN_gui.backgroundcolorA,'foregroundcolor',CONN_gui.fontcolorA); 
                    CONN_h.menus.m_preproc_00{15}=conn_menu('slider',boffset+[pos(1)+pos(3)-0*.015,pos(2),.015,pos(4)],'','','z-slice','conn(''gui_preproc'',15);');
                    set(CONN_h.menus.m_preproc_00{15},'visible','off');
                    conn_menumanager('onregion',CONN_h.menus.m_preproc_00{15},1,boffset+pos+[0 0 .015 0]);
                    %CONN_h.menus.m_preproc_00{15}=uicontrol('style','slider','units','norm','position',boffset+[pos(1)+pos(3)-0*.015,pos(2),.015,pos(4)],'callback','conn(''gui_preproc'',15);','backgroundcolor',CONN_gui.backgroundcolorA);
                end
				CONN_h.menus.m_preproc_00{14}=conn_menu('image',boffset+pos,'BOLD % variance explained');

                CONN_h.menus.m_preproc_surfhires=0;
				set(CONN_h.menus.m_preproc_00{20},'value',CONN_x.Preproc.regbp);
				set(CONN_h.menus.m_preproc_00{19},'value',1+CONN_x.Preproc.despiking);
				set(CONN_h.menus.m_preproc_00{18},'value',1+CONN_x.Preproc.detrending);
				set([CONN_h.menus.m_preproc_00{1},CONN_h.menus.m_preproc_00{2}],'max',2);
                tnames=CONN_x.Preproc.variables.names;
                try, tnames=cellfun(@(name,dim)sprintf('%s (%d)',name,dim(1)),CONN_x.Preproc.variables.names,CONN_x.Preproc.variables.dimensions,'uni',0); end
                tnames(ismember(CONN_x.Preproc.variables.names,CONN_x.Preproc.confounds.names))=cellfun(@(x)[CONN_gui.parse_html{1},x,CONN_gui.parse_html{2}],tnames(ismember(CONN_x.Preproc.variables.names,CONN_x.Preproc.confounds.names)),'uni',0);
				set(CONN_h.menus.m_preproc_00{1},'string',tnames);
                tnames=CONN_x.Preproc.confounds.names;
                try, tnames=cellfun(@(name,dim)sprintf('%s (%d)',name,min(dim)),CONN_x.Preproc.confounds.names,CONN_x.Preproc.confounds.dimensions,'uni',0); end
				set(CONN_h.menus.m_preproc_00{2},'string',tnames);
				conn_menumanager(CONN_h.menus.m_preproc_01,'on',1);
				set([CONN_h.menus.m_preproc_00{1},CONN_h.menus.m_preproc_00{2}],'value',[]);
				%set(CONN_h.menus.m_preproc_00{4},'visible','off');%
				%set(CONN_h.menus.m_preproc_00{6},'visible','off');%
				set([CONN_h.menus.m_preproc_00{11},CONN_h.menus.m_preproc_00{12},CONN_h.menus.m_preproc_00{13}],'max',1);
				set(CONN_h.menus.m_preproc_00{11},'string',[repmat('Subject ',[CONN_x.Setup.nsubjects,1]),num2str((1:CONN_x.Setup.nsubjects)')]);
				nsess=CONN_x.Setup.nsessions(1); set(CONN_h.menus.m_preproc_00{12},'string',[repmat('Session ',[nsess,1]),num2str((1:nsess)')],'value',min(nsess,get(CONN_h.menus.m_preproc_00{12},'value')));
				set(CONN_h.menus.m_preproc_00{13},'string',{' TOTAL',CONN_x.Preproc.confounds.names{:}}); 
                
				%set(CONN_h.screen.hfig,'pointer','watch');
				[path,name,ext]=fileparts(CONN_x.filename);
                filepath=CONN_x.folders.data;
                if any(CONN_x.Setup.steps([2,3])),%~isfield(CONN_x.Setup,'doROIonly')||~CONN_x.Setup.doROIonly,
                    filename=fullfile(filepath,['DATA_Subject',num2str(1,'%03d'),'_Session',num2str(1,'%03d'),'.mat']);
                    if isempty(dir(filename)), uiwait(errordlg('Run first the Setup step by pressing "Done" in the Setup tab','Data not prepared for analyses')); conn gui_setup; return; end
                    CONN_h.menus.m_preproc.Y=conn_vol(filename);
                    if isfield(CONN_h.menus.m_preproc.Y,'issurface')&&CONN_h.menus.m_preproc.Y.issurface,%isequal(CONN_h.menus.m_preproc.Y.matdim.dim,conn_surf_dims(8).*[1 1 2])
                        CONN_h.menus.m_preproc.y.slice=1;
                        if CONN_h.menus.m_preproc_surfhires
                            [CONN_h.menus.m_preproc.y.data,CONN_h.menus.m_preproc.y.idx]=conn_get_volume(CONN_h.menus.m_preproc.Y);
                        else
                            [CONN_h.menus.m_preproc.y.data,CONN_h.menus.m_preproc.y.idx]=conn_get_slice(CONN_h.menus.m_preproc.Y,1);
                            [tempdata,tempidx]=conn_get_slice(CONN_h.menus.m_preproc.Y,conn_surf_dims(8)*[0;0;1]+1);
                            CONN_h.menus.m_preproc.y.data=[CONN_h.menus.m_preproc.y.data(:,CONN_gui.refs.surf.default2reduced) tempdata(:,CONN_gui.refs.surf.default2reduced)];
                            CONN_h.menus.m_preproc.y.idx=[CONN_h.menus.m_preproc.y.idx(CONN_gui.refs.surf.default2reduced);prod(conn_surf_dims(8))+tempidx(CONN_gui.refs.surf.default2reduced)];
                        end
                        set(CONN_h.menus.m_preproc_00{15},'visible','off');
                        conn_menumanager('onregionremove',CONN_h.menus.m_preproc_00{15});
                    else
                        CONN_h.menus.m_preproc.y.slice=ceil(CONN_h.menus.m_preproc.Y.matdim.dim(3)/2);
                        [CONN_h.menus.m_preproc.y.data,CONN_h.menus.m_preproc.y.idx]=conn_get_slice(CONN_h.menus.m_preproc.Y,CONN_h.menus.m_preproc.y.slice);
                    end
                end
				filename=fullfile(filepath,['ROI_Subject',num2str(1,'%03d'),'_Session',num2str(1,'%03d'),'.mat']);
				CONN_h.menus.m_preproc.X1=load(filename);
				filename=fullfile(filepath,['COV_Subject',num2str(1,'%03d'),'_Session',num2str(1,'%03d'),'.mat']);
				CONN_h.menus.m_preproc.X2=load(filename);
                if any(CONN_x.Setup.steps([2,3]))
                    if ~(isfield(CONN_h.menus.m_preproc.Y,'issurface')&&CONN_h.menus.m_preproc.Y.issurface)
                        try
                            CONN_h.menus.m_preproc.XS=spm_vol(deblank(CONN_x.Setup.structural{1}{1}{1}));
                        catch
                            CONN_h.menus.m_preproc.XS=spm_vol(fullfile(fileparts(which('spm')),'canonical','single_subj_T1.nii'));
                        end
                        xyz=conn_convertcoordinates('idx2tal',prod(CONN_h.menus.m_preproc.Y.matdim.dim(1:2))*(CONN_h.menus.m_preproc.y.slice-1)+(1:prod(CONN_h.menus.m_preproc.Y.matdim.dim(1:2))),CONN_h.menus.m_preproc.Y.matdim.mat,CONN_h.menus.m_preproc.Y.matdim.dim);
                        CONN_h.menus.m_preproc.Xs=spm_get_data(CONN_h.menus.m_preproc.XS(1),pinv(CONN_h.menus.m_preproc.XS(1).mat)*xyz');
                        CONN_h.menus.m_preproc.Xs=permute(reshape(CONN_h.menus.m_preproc.Xs,CONN_h.menus.m_preproc.Y.matdim.dim(1:2)),[2,1,3]);
                        set(CONN_h.menus.m_preproc_00{15},'min',1,'max',CONN_h.menus.m_preproc.Y.matdim.dim(3),'sliderstep',min(.5,[1,10]/(CONN_h.menus.m_preproc.Y.matdim.dim(3)-1)),'value',CONN_h.menus.m_preproc.y.slice);
                    else
                        CONN_h.menus.m_preproc.y.slice=max(1,min(4,CONN_h.menus.m_preproc.y.slice));
                    end
                end
				model=1;
			else 
				switch(varargin{2}),
					case 0,
						str=conn_menumanager(CONN_h.menus.m_preproc_01,'string');
						switch(str{1}),
							case '>',
								ncovariates=get(CONN_h.menus.m_preproc_00{1},'value'); 
								for ncovariate=ncovariates(:)',
									if isempty(strmatch(CONN_x.Preproc.variables.names{ncovariate},CONN_x.Preproc.confounds.names,'exact')), 
										CONN_x.Preproc.confounds.names{end+1}=CONN_x.Preproc.variables.names{ncovariate}; 
										CONN_x.Preproc.confounds.types{end+1}=CONN_x.Preproc.variables.types{ncovariate}; 
										CONN_x.Preproc.confounds.deriv{end+1}=CONN_x.Preproc.variables.deriv{ncovariate}; 
										CONN_x.Preproc.confounds.dimensions{end+1}=[inf CONN_x.Preproc.variables.dimensions{ncovariate}(1)]; 
									end
								end
                                tnames=CONN_x.Preproc.variables.names;
                                try, tnames=cellfun(@(name,dim)sprintf('%s (%d)',name,dim(1)),CONN_x.Preproc.variables.names,CONN_x.Preproc.variables.dimensions,'uni',0); end
                                tnames(ismember(CONN_x.Preproc.variables.names,CONN_x.Preproc.confounds.names))=cellfun(@(x)[CONN_gui.parse_html{1},x,CONN_gui.parse_html{2}],tnames(ismember(CONN_x.Preproc.variables.names,CONN_x.Preproc.confounds.names)),'uni',0);
                                set(CONN_h.menus.m_preproc_00{1},'string',tnames);
                                tnames=CONN_x.Preproc.confounds.names;
                                try, tnames=cellfun(@(name,dim)sprintf('%s (%d)',name,min(dim)),CONN_x.Preproc.confounds.names,CONN_x.Preproc.confounds.dimensions,'uni',0); end
                                set(CONN_h.menus.m_preproc_00{2},'string',tnames);
								set(CONN_h.menus.m_preproc_00{13},'string',{' TOTAL',CONN_x.Preproc.confounds.names{:}}); 
							case '<',
								ncovariates=get(CONN_h.menus.m_preproc_00{2},'value'); 
								idx=setdiff(1:length(CONN_x.Preproc.confounds.names),ncovariates);
								CONN_x.Preproc.confounds.names={CONN_x.Preproc.confounds.names{idx}};
								CONN_x.Preproc.confounds.types={CONN_x.Preproc.confounds.types{idx}};
								CONN_x.Preproc.confounds.deriv={CONN_x.Preproc.confounds.deriv{idx}};
								CONN_x.Preproc.confounds.dimensions={CONN_x.Preproc.confounds.dimensions{idx}};
                                tnames=CONN_x.Preproc.variables.names;
                                try, tnames=cellfun(@(name,dim)sprintf('%s (%d)',name,dim(1)),CONN_x.Preproc.variables.names,CONN_x.Preproc.variables.dimensions,'uni',0); end
                                tnames(ismember(CONN_x.Preproc.variables.names,CONN_x.Preproc.confounds.names))=cellfun(@(x)[CONN_gui.parse_html{1},x,CONN_gui.parse_html{2}],tnames(ismember(CONN_x.Preproc.variables.names,CONN_x.Preproc.confounds.names)),'uni',0);
                                set(CONN_h.menus.m_preproc_00{1},'string',tnames);
                                tnames=CONN_x.Preproc.confounds.names;
                                try, tnames=cellfun(@(name,dim)sprintf('%s (%d)',name,min(dim)),CONN_x.Preproc.confounds.names,CONN_x.Preproc.confounds.dimensions,'uni',0); end
                                set(CONN_h.menus.m_preproc_00{2},'string',tnames,'value',min(max(ncovariates),length(tnames))); 
								set(CONN_h.menus.m_preproc_00{13},'string',{' TOTAL',CONN_x.Preproc.confounds.names{:}},'value',min(max(get(CONN_h.menus.m_preproc_00{13},'value')),length(CONN_x.Preproc.confounds.names)+1)); 
						end
						model=1;
					case 1,
						conn_menumanager(CONN_h.menus.m_preproc_01,'string',{'>'},'on',1);
						set(CONN_h.menus.m_preproc_00{2},'value',[]); 
                        set(CONN_h.menus.m_preproc_00{22},'visible','on');
						%set([CONN_h.menus.m_preproc_00{4},CONN_h.menus.m_preproc_00{6}],'visible','off');% 
					case 2,
						conn_menumanager(CONN_h.menus.m_preproc_01,'string',{'<'},'on',1);
						set(CONN_h.menus.m_preproc_00{1},'value',[]); 
                        set(CONN_h.menus.m_preproc_00{22},'visible','off');
						nconfounds=get(CONN_h.menus.m_preproc_00{2},'value');
                        if numel(nconfounds)==1
                            set(CONN_h.menus.m_preproc_00{13},'value',nconfounds+1);
                            model=2;
                        end
						%set([CONN_h.menus.m_preproc_00{4},CONN_h.menus.m_preproc_00{6}],'visible','on');% 
					case 4,
						nconfounds=get(CONN_h.menus.m_preproc_00{2},'value');
						value=str2num(get(CONN_h.menus.m_preproc_00{4},'string'));
						if length(value)==1, for nconfound=nconfounds(:)', CONN_x.Preproc.confounds.deriv{nconfound}=round(max(0,min(2,value))); end; end
						model=1;
					case 5,
						value=str2num(get(CONN_h.menus.m_preproc_00{5},'string'));
						if length(value)==2 && value(2)>value(1), CONN_x.Preproc.filter=value; end
						model=1;
					case 6,
						nconfounds=get(CONN_h.menus.m_preproc_00{2},'value');
						value=str2num(get(CONN_h.menus.m_preproc_00{6},'string'));
						%if length(value)==1, for nconfound=nconfounds(:)', CONN_x.Preproc.confounds.dimensions{nconfound}(1)=round(max(1,min(CONN_x.Preproc.confounds.dimensions{nconfound}(2),value))); end; end
						if length(value)==1, for nconfound=nconfounds(:)', CONN_x.Preproc.confounds.dimensions{nconfound}(1)=round(max(1,value)); end; end
						model=1;
					case {11,12},
						nsubs=get(CONN_h.menus.m_preproc_00{11},'value');
						 if varargin{2}==11,
							 nsess=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsubs)); 
							 set(CONN_h.menus.m_preproc_00{12},'string',[repmat('Session ',[nsess,1]),num2str((1:nsess)')],'value',min(nsess,get(CONN_h.menus.m_preproc_00{12},'value')));
						 end
						 nsess=get(CONN_h.menus.m_preproc_00{12},'value');
						 %set(CONN_h.screen.hfig,'pointer','watch');
						 [path,name,ext]=fileparts(CONN_x.filename);
%                          filepath=fullfile(path,name,'data');
                         filepath=CONN_x.folders.data;
                         if any(CONN_x.Setup.steps([2,3])),%~isfield(CONN_x.Setup,'doROIonly')||~CONN_x.Setup.doROIonly,
                             filename=fullfile(filepath,['DATA_Subject',num2str(nsubs,'%03d'),'_Session',num2str(nsess,'%03d'),'.mat']);
                             CONN_h.menus.m_preproc.Y=conn_vol(filename);
                             if isfield(CONN_h.menus.m_preproc.Y,'issurface')&&CONN_h.menus.m_preproc.Y.issurface
                                 if CONN_h.menus.m_preproc_surfhires
                                     [CONN_h.menus.m_preproc.y.data,CONN_h.menus.m_preproc.y.idx]=conn_get_volume(CONN_h.menus.m_preproc.Y);
                                 else
                                     [CONN_h.menus.m_preproc.y.data,CONN_h.menus.m_preproc.y.idx]=conn_get_slice(CONN_h.menus.m_preproc.Y,1);
                                     [tempdata,tempidx]=conn_get_slice(CONN_h.menus.m_preproc.Y,conn_surf_dims(8)*[0;0;1]+1);
                                     CONN_h.menus.m_preproc.y.data=[CONN_h.menus.m_preproc.y.data(:,CONN_gui.refs.surf.default2reduced) tempdata(:,CONN_gui.refs.surf.default2reduced)];
                                     CONN_h.menus.m_preproc.y.idx=[CONN_h.menus.m_preproc.y.idx(CONN_gui.refs.surf.default2reduced);prod(conn_surf_dims(8))+tempidx(CONN_gui.refs.surf.default2reduced)];
                                 end
                             else
                                 [CONN_h.menus.m_preproc.y.data,CONN_h.menus.m_preproc.y.idx]=conn_get_slice(CONN_h.menus.m_preproc.Y,CONN_h.menus.m_preproc.y.slice);
                             end
                         end
						 filename=fullfile(filepath,['ROI_Subject',num2str(nsubs,'%03d'),'_Session',num2str(nsess,'%03d'),'.mat']);
						 CONN_h.menus.m_preproc.X1=load(filename);
						 filename=fullfile(filepath,['COV_Subject',num2str(nsubs,'%03d'),'_Session',num2str(nsess,'%03d'),'.mat']);
						 CONN_h.menus.m_preproc.X2=load(filename);
                         if any(CONN_x.Setup.steps([2,3]))&&~(isfield(CONN_h.menus.m_preproc.Y,'issurface')&&CONN_h.menus.m_preproc.Y.issurface)
                             if ~CONN_x.Setup.structural_sessionspecific, nsesstemp=1; else nsesstemp=nsess; end
                             try
                                 CONN_h.menus.m_preproc.XS=spm_vol(deblank(CONN_x.Setup.structural{nsubs}{nsesstemp}{1}));
                             catch
                                 CONN_h.menus.m_preproc.XS=spm_vol(fullfile(fileparts(which('spm')),'canonical','single_subj_T1.nii'));
                             end
                             xyz=conn_convertcoordinates('idx2tal',prod(CONN_h.menus.m_preproc.Y.matdim.dim(1:2))*(CONN_h.menus.m_preproc.y.slice-1)+(1:prod(CONN_h.menus.m_preproc.Y.matdim.dim(1:2))),CONN_h.menus.m_preproc.Y.matdim.mat,CONN_h.menus.m_preproc.Y.matdim.dim);
                             CONN_h.menus.m_preproc.Xs=spm_get_data(CONN_h.menus.m_preproc.XS(1),pinv(CONN_h.menus.m_preproc.XS(1).mat)*xyz');
                             CONN_h.menus.m_preproc.Xs=permute(reshape(CONN_h.menus.m_preproc.Xs,CONN_h.menus.m_preproc.Y.matdim.dim(1:2)),[2,1,3]);
                         end
						 model=1;
					 case 13,
						 model=2;
					 case 15,
						 nsubs=get(CONN_h.menus.m_preproc_00{11},'value');
                         CONN_h.menus.m_preproc.y.slice=round(get(CONN_h.menus.m_preproc_00{15},'value'));
                         if any(CONN_x.Setup.steps([2,3]))&&~(isfield(CONN_h.menus.m_preproc.Y,'issurface')&&CONN_h.menus.m_preproc.Y.issurface)
                             [CONN_h.menus.m_preproc.y.data,CONN_h.menus.m_preproc.y.idx]=conn_get_slice(CONN_h.menus.m_preproc.Y,CONN_h.menus.m_preproc.y.slice);
                             xyz=conn_convertcoordinates('idx2tal',prod(CONN_h.menus.m_preproc.Y.matdim.dim(1:2))*(CONN_h.menus.m_preproc.y.slice-1)+(1:prod(CONN_h.menus.m_preproc.Y.matdim.dim(1:2))),CONN_h.menus.m_preproc.Y.matdim.mat,CONN_h.menus.m_preproc.Y.matdim.dim);
                             CONN_h.menus.m_preproc.Xs=spm_get_data(CONN_h.menus.m_preproc.XS(1),pinv(CONN_h.menus.m_preproc.XS(1).mat)*xyz');
                             CONN_h.menus.m_preproc.Xs=permute(reshape(CONN_h.menus.m_preproc.Xs,CONN_h.menus.m_preproc.Y.matdim.dim(1:2)),[2,1,3]);
                         end
                         model=1;
                    case 18,
						val=get(CONN_h.menus.m_preproc_00{18},'value');
						CONN_x.Preproc.detrending=val-1;
                        model=1;
                    case 19,
						val=get(CONN_h.menus.m_preproc_00{19},'value');
						CONN_x.Preproc.despiking=val-1;
                        model=1;
                    case 20,
						val=get(CONN_h.menus.m_preproc_00{20},'value');
						CONN_x.Preproc.regbp=val;
                        model=1;
				end
			end
			nsubs=get(CONN_h.menus.m_preproc_00{11},'value');
			nconfounds=get(CONN_h.menus.m_preproc_00{2},'value');
			nview=get(CONN_h.menus.m_preproc_00{13},'value')-1;
            confounds=CONN_x.Preproc.confounds;
            if isfield(CONN_x.Preproc,'detrending')&&CONN_x.Preproc.detrending, 
                confounds.types{end+1}='detrend'; 
                if CONN_x.Preproc.detrending>=2, confounds.types{end+1}='detrend2'; end
                if CONN_x.Preproc.detrending>=3, confounds.types{end+1}='detrend3'; end
            end
			[CONN_h.menus.m_preproc.X,CONN_h.menus.m_preproc.select]=conn_designmatrix(confounds,CONN_h.menus.m_preproc.X1,CONN_h.menus.m_preproc.X2,{nconfounds,nview});
			if isempty(nconfounds)||isequal(nconfounds,0), 
                conn_menu('update',CONN_h.menus.m_preproc_00{3},[]); 
                set(CONN_h.menus.m_preproc_00{22},'visible','on');
            else
                conn_menu('update',CONN_h.menus.m_preproc_00{3},CONN_h.menus.m_preproc.X); 
            end
			if ~isempty(nconfounds)&&all(nconfounds>0), 
				temp=cat(1,CONN_x.Preproc.confounds.deriv{nconfounds});
				if length(temp)==1 || ~any(diff(temp)),set(CONN_h.menus.m_preproc_00{4},'string',num2str(CONN_x.Preproc.confounds.deriv{nconfounds(1)})); 
				else  set(CONN_h.menus.m_preproc_00{4},'string','MULTIPLE VALUES'); end
				temp=cat(1,CONN_x.Preproc.confounds.dimensions{nconfounds});
				if size(temp,1)==1 || ~any(any(diff(temp,1,1))),set(CONN_h.menus.m_preproc_00{6},'string',num2str(CONN_x.Preproc.confounds.dimensions{nconfounds(1)}(1))); 
				else  set(CONN_h.menus.m_preproc_00{6},'string','MULTIPLE VALUES'); end
			end
			set(CONN_h.menus.m_preproc_00{5},'string',mat2str(CONN_x.Preproc.filter));
			if size(CONN_h.menus.m_preproc.X,2)<=500,
				offon={'off','on'};
				for n1=1:size(CONN_h.menus.m_preproc.X,2),
					set(CONN_h.menus.m_preproc_00{3}.h4(n1),'visible',offon{1+CONN_h.menus.m_preproc.select{1}(n1)});
				end
				xtemp=CONN_h.menus.m_preproc.X(:,find(CONN_h.menus.m_preproc.select{1}));
				if ~isempty(xtemp), set(CONN_h.menus.m_preproc_00{3}.h3,'ylim',[min(min(xtemp))-1e-4,max(max(xtemp))+1e-4]); end
			end
			if model==1, 
                if any(CONN_x.Setup.steps([2,3])),%~isfield(CONN_x.Setup,'doROIonly')||~CONN_x.Setup.doROIonly,
                    xf=CONN_h.menus.m_preproc.X;%conn_filter(CONN_x.Setup.RT,CONN_x.Preproc.filter,CONN_h.menus.m_preproc.X,'partial');
                    if isfield(CONN_x.Preproc,'regbp')&&CONN_x.Preproc.regbp==2,
                        xf=conn_filter(max(CONN_x.Setup.RT(min(numel(CONN_x.Setup.RT),nsubs))),CONN_x.Preproc.filter,xf);
                    end
                    yf=CONN_h.menus.m_preproc.y.data;%conn_filter(CONN_x.Setup.RT,CONN_x.Preproc.filter,CONN_h.menus.m_preproc.y.data,'partial');
                    if isfield(CONN_x.Preproc,'despiking')&&CONN_x.Preproc.despiking==1,
                        my=repmat(median(yf,1),[size(yf,1),1]);
                        sy=repmat(4*median(abs(yf-my)),[size(yf,1),1]);
                        yf=my+sy.*tanh((yf-my)./max(eps,sy));
                    end
                    if isfield(CONN_x.Preproc,'regbp')&&CONN_x.Preproc.regbp==2,
                        yf=conn_filter(max(CONN_x.Setup.RT(min(numel(CONN_x.Setup.RT),nsubs))),CONN_x.Preproc.filter,yf); % just to make the 'BOLD % variance' plot more meaningful in this case
                    end
                    yf=detrend(yf,'constant');
                    [CONN_h.menus.m_preproc.B,CONN_h.menus.m_preproc.opt]=conn_glmunivariate('estimate',xf,yf);
                    if isfield(CONN_x.Preproc,'despiking')&&CONN_x.Preproc.despiking==2,
                        my=repmat(median(yf,1),[size(yf,1),1]);
                        sy=repmat(4*median(abs(yf-my)),[size(yf,1),1]);
                        yf=my+sy.*tanh((yf-my)./max(eps,sy));
                    end
                    if CONN_h.menus.m_preproc.opt.dof<=0, disp(['Warning: Over-determined model (no degrees of freedom for this subject). Please consider reducing the number, dimensions, or covariates order of the confounds or disregarding this subject/session']); end
                end
                if isfield(CONN_h.menus.m_preproc.X1,'sampledata'),
                    xf=CONN_h.menus.m_preproc.X;
                    if isfield(CONN_x.Preproc,'regbp')&&CONN_x.Preproc.regbp==2,
                        xf=conn_filter(max(CONN_x.Setup.RT(min(numel(CONN_x.Setup.RT),nsubs))),CONN_x.Preproc.filter,xf);
                    end
%                     if ~any(CONN_x.Setup.steps([2,3])),%isfield(CONN_x.Setup,'doROIonly')&&CONN_x.Setup.doROIonly,
%                         CONN_h.menus.m_preproc.opt.dof=size(CONN_h.menus.m_preproc.X1.sampledata,1)-size(xf,2); 
%                     end
%                     dof=CONN_h.menus.m_preproc.opt.dof;
                    x0=CONN_h.menus.m_preproc.X1.sampledata;
                    %x0=detrend(x0);
                    x0=detrend(x0,'constant');
                    x0=x0(:,~all(abs(x0)<1e-4,1)&~any(isnan(x0),1));
                    if isempty(x0), 
                        disp('Warning! No temporal variation in BOLD signal within sampled grey-matter voxels');
                    end
                    x1=x0;
                    %fy=mean(abs(fft(x0)).^2,2);
                    if isfield(CONN_x.Preproc,'despiking')&&CONN_x.Preproc.despiking==1,
                        my=repmat(median(x1,1),[size(x1,1),1]);
                        sy=repmat(4*median(abs(x1-my)),[size(x1,1),1]);
                        x1=my+sy.*tanh((x1-my)./max(eps,sy));
                    end
                    x1=x1-xf*(pinv(xf)*x1);
                    if isfield(CONN_x.Preproc,'despiking')&&CONN_x.Preproc.despiking==2,
                        my=repmat(median(x1,1),[size(x1,1),1]);
                        sy=repmat(4*median(abs(x1-my)),[size(x1,1),1]);
                        x1=my+sy.*tanh((x1-my)./max(eps,sy));
                    end
                    [x1,fy]=conn_filter(max(CONN_x.Setup.RT(min(numel(CONN_x.Setup.RT),nsubs))),CONN_x.Preproc.filter,x1);
                    %x0=conn_filter(CONN_x.Setup.RT,CONN_x.Preproc.filter,x0);
                    %dof=max(0,size(CONN_h.menus.m_preproc.X1.sampledata,1)*(min(1/(2*max(CONN_x.Setup.RT(min(numel(CONN_x.Setup.RT),nsubs)))),CONN_x.Preproc.filter(2))-max(0,CONN_x.Preproc.filter(1)))/(1/(2*max(CONN_x.Setup.RT(min(numel(CONN_x.Setup.RT),nsubs)))))+1-size(xf,2));
                    fy=mean(abs(fy(1:round(size(fy,1)/2),:)).^2,2); dof=max(0,sum(fy)^2/sum(fy.^2)-size(xf,2)); % change dof displayed to WelchSatterthwaite residual dof approximation
                    z0=corrcoef(x0);z1=corrcoef(x1);z0=(z0(z0~=1));z1=(z1(z1~=1));
                    [a0,b0]=hist(z0(:),linspace(-1,1,100));[a1,b1]=hist(z1(:),linspace(-1,1,100));
                    if isempty(z0)||isempty(z1), 
                        disp('Warning! Empty correlation data');
                        conn_menu('updatehist',CONN_h.menus.m_preproc_00{16},[]);
                    else
                        conn_menu('updatehist',CONN_h.menus.m_preproc_00{16},{[b1(1),b1,b1(end)],[0,a1,0],[0,a0,0]});
                        set(CONN_h.menus.m_preproc_00{16}.h7,'string',['after denoising (dof_r_e_s~',num2str(dof,'%.1f'),')']);
                        %set(CONN_h.menus.m_preproc_00{21},'string',{'voxel-to-voxel r',['dof(residual) ~ ',num2str(dof,'%.1f')]});
                    end
                else  conn_menu('updatehist',CONN_h.menus.m_preproc_00{16},[]); end
			end
			if model,
                if any(CONN_x.Setup.steps([2,3])),%~isfield(CONN_x.Setup,'doROIonly')||~CONN_x.Setup.doROIonly,
                    idx=find(CONN_h.menus.m_preproc.select{2});
                    C=eye(size(CONN_h.menus.m_preproc.X,2));
                    if isempty(idx)&&isequal(get(CONN_h.menus.m_preproc_00{13},'value')-1,0), C=C(2:end,:); 
                    else C=pinv(CONN_h.menus.m_preproc.opt.X(:,[1,idx]))*CONN_h.menus.m_preproc.opt.X; C=C(2:end,:); % unique + shared variance
                        %C=C(idx,:);  % unique variance
                    end
                    if isempty(C)
                        conn_menu('update',CONN_h.menus.m_preproc_00{14},[]);
                    else
                        [h,F,p,dof,R]=conn_glmunivariate('evaluate',CONN_h.menus.m_preproc.opt,[],C);
                        if isfield(CONN_h.menus.m_preproc.Y,'issurface')&&CONN_h.menus.m_preproc.Y.issurface, issurface=true; else issurface=false; end
                        t1=zeros(CONN_h.menus.m_preproc.Y.matdim.dim(1:2+issurface));
                        t2=nan+zeros(CONN_h.menus.m_preproc.Y.matdim.dim(1:2+issurface));
                        t1(CONN_h.menus.m_preproc.y.idx)=abs(R);
                        t2(CONN_h.menus.m_preproc.y.idx)=abs(R);
                        if isfield(CONN_h.menus.m_preproc.Y,'issurface')&&CONN_h.menus.m_preproc.Y.issurface
                            if ~CONN_h.menus.m_preproc_surfhires
                                t1=[t1(CONN_gui.refs.surf.default2reduced) t1(numel(t1)/2+CONN_gui.refs.surf.default2reduced)];
                                t2=[t2(CONN_gui.refs.surf.default2reduced) t2(numel(t2)/2+CONN_gui.refs.surf.default2reduced)];
                                conn_menu('update',CONN_h.menus.m_preproc_00{14},{CONN_gui.refs.surf.defaultreduced,t1,t2},{CONN_h.menus.m_preproc.Y.matdim,CONN_h.menus.m_preproc.y.slice});
                            else
                                conn_menu('update',CONN_h.menus.m_preproc_00{14},{CONN_gui.refs.surf.default,t1,t2},{CONN_h.menus.m_preproc.Y.matdim,CONN_h.menus.m_preproc.y.slice});
                            end
                        else
                            t1=permute(t1,[2,1,3]);
                            t2=permute(t2,[2,1,3]);
                            conn_menu('update',CONN_h.menus.m_preproc_00{14},{CONN_h.menus.m_preproc.Xs,t1,t2},{CONN_h.menus.m_preproc.Y.matdim,CONN_h.menus.m_preproc.y.slice});
                        end
                        %f=conn_hanning(5)/sum(conn_hanning(5)); t1=convn(convn(convn(t1,f,'same'),f','same'),shiftdim(f,-2),'same');
                        %f=conn_hanning(5)/sum(conn_hanning(5)); t2=convn(convn(convn(t2,f,'same'),f','same'),shiftdim(f,-2),'same');
                        %t(CONN_h.menus.m_preproc.Y.voxels)=sqrt(sum(abs(CONN_h.menus.m_preproc.B(find(CONN_h.menus.m_preproc.select{2}),:)).^2,1))';
                    end
                else
                    conn_menu('update',CONN_h.menus.m_preproc_00{14},[]);
                end
			end
			
		case 'gui_preproc_done',
			if isempty(CONN_x.filename), conn gui_setup_save; end
            if conn_questdlg('Ready to run Denoising pipeline',[],CONN_x.Setup.steps(1:3),[],[],true);
                conn_menumanager clf;
                conn_menuframe;
                conn_menumanager([CONN_h.menus.m_setup_06,CONN_h.menus.m0],'on',1);
                if CONN_x.gui.parallel~=0, 
                    if CONN_x.gui.parallel>0, conn_jobmanager('options','profile',CONN_x.gui.parallel); end; 
                    conn save;
                    conn_jobmanager('submit','denoising_gui',[],CONN_x.gui);
                else conn_process('denoising_gui');
                end
                CONN_x.gui=1;
                conn gui_setup_save;
                if ~conn_projectmanager('ispending'), conn gui_analyses; end
            end
			
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%			
        case 'gui_analysesgo',
            state=varargin{2};
            tstate=conn_menumanager(CONN_h.menus.m_analyses_03,'state'); tstate(:)=0;tstate(state)=1; conn_menumanager(CONN_h.menus.m_analyses_03,'state',tstate); 
            conn gui_analyses;
            
		case 'gui_analyses',
            CONN_x.gui=1;
			model=0;
            if ~isfield(CONN_x,'Analysis')||~CONN_x.Analysis, CONN_x.Analysis=1; end
            ianalysis=CONN_x.Analysis;
            if ianalysis>numel(CONN_x.Analyses)||~isfield(CONN_x.Analyses(ianalysis),'name'),
                txt=inputdlg('New analysis name:','conn',1,{['ANALYSIS_',num2str(ianalysis,'%02d')]});
                if isempty(txt), return; end
                CONN_x.Analyses(ianalysis).name=txt{1}; 
                if ianalysis==1, conn_process denoising_finish; end
            end
            state=find(conn_menumanager(CONN_h.menus.m_analyses_03,'state'));
            states={[1,2],3,4};istates=[1,1,2,3]; state=states{state};
            if ~any(CONN_x.Setup.steps(state))
                state=find(CONN_x.Setup.steps,1,'first');
                if isempty(state)||state>3, uiwait(errordlg('No ROI-to-ROI, seed-to-voxel, or voxel-to-voxel analyses prepared. Select these options in ''Setup->Options'' to perform additional analyses','')); conn gui_setup; return; end
                tstate=zeros(size(conn_menumanager(CONN_h.menus.m_analyses_03,'state')));tstate(istates(state))=1;
                conn_menumanager(CONN_h.menus.m_analyses_03,'state',tstate); 
            end
            if state(1)==1, %SEED-TO-VOXEL or ROI-TO-ROI
                boffset=[.02 .03 0 0];
                if nargin<2,
                    if ~any(CONN_x.Setup.steps(state)), uiwait(errordlg('No seed-to-voxel or ROI-to-ROI analyses computed. Select these options in ''Setup->Options'' to perform additional analyses','')); conn gui_setup; return; end
                    conn_menumanager clf;
                    conn_menuframe;
                    tstate=conn_menumanager(CONN_h.menus.m0,'state'); tstate(:)=0;tstate(3)=1; conn_menumanager(CONN_h.menus.m0,'state',tstate);
                    conn_menumanager([CONN_h.menus.m_analyses_02,CONN_h.menus.m_analyses_03,CONN_h.menus.m_setup_06,CONN_h.menus.m0],'on',1);
                    conn_menu('nullstr',{'No data','to display'});
                    
                    txt=strvcat(CONN_x.Analyses(:).name,'<HTML><i>new</i></HTML>','<HTML><i>delete</i></HTML>');
                    CONN_h.menus.m_analyses_00{20}=conn_menu('popup2',[.005,.76,.105,.04],'Analysis name:',txt(ianalysis,:),'<HTML>Analysis name <br/> - Select existing first-level analysis set to edit its properties <br/> - select <i>new</i> to define a new set of first-level analyses within this project</HTML>','conn(''gui_analyses'',20);');
                    set(CONN_h.menus.m_analyses_00{20},'string',txt,'value',ianalysis);%,'fontsize',9+CONN_gui.font_offset);%,'fontweight','bold');
                    
                    %conn_menu('frame',boffset+[.095,.24,.35,.56],'FC ANALYSIS OPTIONS');
                    %conn_menu('frame',boffset+[.095,.08,.35,.155]);
                    conn_menu('frame',boffset+[.115,.08,.415,.745],'');%'FC ANALYSIS OPTIONS');
                    [nill,CONN_h.menus.m_analyses_00{16}]=conn_menu('text',boffset+[.125,.70,.26,.05],'Functional connectivity seeds/sources:');
                    set(CONN_h.menus.m_analyses_00{16},'horizontalalignment','left');
                    CONN_h.menus.m_analyses_00{1}=conn_menu('listbox',boffset+[.125,.25,.095,.45],'all ROIs','','List of all seeds/ROIs','conn(''gui_analyses'',1);');
                    CONN_h.menus.m_analyses_00{2}=conn_menu('listbox',boffset+[.24,.46,.165,.24],'Sources','','<HTML>List of seeds/ROIs to be included in this analysis  <br/> - Connectivity measures will be computed among all selected ROIs (for ROI-to-ROI analyses) and/or between the selected ROIs and all brain voxels (seed-to-voxel analyses) <br/> - Select ROIs in the <i>all ROIs</i> list and click <b> > </b> to add new sources to this list <br/></HTML>','conn(''gui_analyses'',2);');
                    CONN_h.menus.m_analyses_00{4}=conn_menu('edit',boffset+[.415,.67,.11,.04],'Derivatives order','','Include derivates up to n-th order of selected source (0 for no derivatives, 1 for first-order derivatives,...)','conn(''gui_analyses'',4);');
                    CONN_h.menus.m_analyses_00{6}=conn_menu('edit',boffset+[.415,.57,.11,.04],'Dimensions','','Number of dimensions/components of selected source','conn(''gui_analyses'',6);');
                    CONN_h.menus.m_analyses_00{5}=conn_menu('edit',boffset+[.415,.47,.11,.04],'Frequency bands','','Number of frequency bands for BOLD signal spectral decomposition of selected source (1 for single-band covering entire band-pass filtered data)','conn(''gui_analyses'',5);');
                    analysistypes=[{'functional connectivity (weighted GLM)','task-modulation effects (gPPI)','temporal-modulation effects (Dynamic FC)','other temporal-modulation effects'}];%,cellfun(@(x)['gPPI: interaction with covariate ''',x,''''],CONN_x.Setup.l1covariates.names(1:end-1),'uni',0)];
                    %CONN_x.Analyses(ianalysis).modulation=max(0,min(numel(analysistypes)-1,CONN_x.Analyses(ianalysis).modulation));
                    CONN_h.menus.m_analyses_00{10}=conn_menu('popup',boffset+[.125,.14,.21,.05],'Analysis options:',analysistypes,'<HTML>Choose first-level model between the seed/source BOLD timeseries and each target ROI or voxel BOLD timeseries <br/> - select <i>weighted GLM</i> for standard resting-state or task/condition-specific functional connectivity measures <br/> - select <i>gPPI</i> for Generalized PsychoPhysiological Interaction models (task-modulation effects defined in <i>Setup.Conditions</i>) <br/>  - select <i>Dynamic FC</i> for dynamic connectivity analyses (data-driven temporal-modulation effects defined in <i>First-level.Dynamic FC</i>) <br/> - select <i>other temporal-modulation</i> for user-defined temporal-modulation effects (e.g. PhysioPhysiological Interactions)</HTML>','conn(''gui_analyses'',10);');
                    connmeasures={'correlation (bivariate)','correlation (semipartial)','regression (bivariate)','regression (multivariate)'};
                    CONN_h.menus.m_analyses_00{7}=conn_menu('popup',boffset+[.125,.09,.21,.05],'',connmeasures,'<HTML>Choose outcome measure for second level analyses <br/> - <i>bivariate</i> measures are computed separately for each pair of source&target ROIs (ROI-to-ROI analyses)<br/> or for each pair of source ROI and target voxel (seed-to-voxel analyses)<br/> - <i>semipartial</i> and <i>multivariate</i> measures are computed entering all the chosen source ROIs simultaneously <br/>into a single predictive model (separately for each target ROI/voxel) <br/> - <i>correlation</i> measures output Fisher-transformed correlation-coefficients (bivariate or semipartial) and <br/>are typically associated with measures of <i>functional</i> connectivity<br/> - <i>regression</i> measures output regression coefficients (bivariate or multivariate) and are typically associated <br/>with measures of <i>effective</i> connectivity</HTML>','conn(''gui_analyses'',7);');
                    CONN_h.menus.m_analyses_00{8}=conn_menu('popup',boffset+[.345,.14,.18,.05],'',{'no weighting','hrf weighting','hanning weighting','task/condition factor'},'Choose method for weighting samples within each condition block (for weighted GLM analyses only)','conn(''gui_analyses'',8);');
                    CONN_h.menus.m_analyses_00{9}=conn_menu('popup',boffset+[.345,.09,.18,.05],'',{'ROI-to-ROI only','Seed-to-Voxel only','ROI-to-ROI and Seed-to-Voxel'},'Choose type of connectivity analysis','conn(''gui_analyses'',9);');
                    CONN_h.menus.m_analyses_00{19}=conn_menu('popup',boffset+[.295,.42,.15,.04],'',{'Source timeseries','First-level analysis design matrix'},'<HTML>Choose display type<br/> - <i>Source timeseries</i> displays the BOLD signal timeseries for the selected source/subject/session<br/> - <i>Design matrix</i> displays the scans-by-regressors first-level design matrix for the selected <br/> source/subject/session (highlighted the regressor of interest for second-level analyses)</HTML>','conn(''gui_analyses'',19);');
                    CONN_h.menus.m_analyses_00{3}=conn_menu('image',boffset+[.235,.24,.26,.17],'');%'Source timeseries');
                    CONN_h.menus.m_analyses_00{22}=[uicontrol('style','frame','units','norm','position',boffset+[.405,.45,.11,.33],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA),...
                        uicontrol('style','frame','units','norm','position',boffset+[.225,.23,.30,.23],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA)];
                    conn_menu('frame2',boffset+[.55,.05,.425,.79],'Preview first-level analysis results');
                    CONN_h.menus.m_analyses_00{11}=conn_menu('listbox',boffset+[.56,.23,.075,.52],'Subjects','','Select subject to display','conn(''gui_analyses'',11);');
                    CONN_h.menus.m_analyses_00{12}=conn_menu('listbox',boffset+[.635,.23,.075,.52],'Conditions','','Select condition to display','conn(''gui_analyses'',12);');
                    %CONN_h.menus.m_analyses_00{13}=conn_menu('listbox',boffset+[.62,.11,.075,.64],'Sources','','Select source to display','conn(''gui_analyses'',13);');
                    CONN_h.menus.m_analyses_00{13}=conn_menu('popup',boffset+[.81,.80,.10,.04],'',{' TOTAL'},'Select source to display','conn(''gui_analyses'',13);');
                    pos=[.74,.10,.22,.66];
                    if any(CONN_x.Setup.steps([2,3])),
                        uicontrol('style','text','units','norm','position',boffset+[pos(1)+pos(3)-.170,pos(2)-1*.055,.070,.04],'string','threshold','fontname','default','fontsize',8+CONN_gui.font_offset,'backgroundcolor',CONN_gui.backgroundcolorA,'foregroundcolor',CONN_gui.fontcolorA,'tooltipstring','only results with absolute effect sizes above this threshold value are displayed');
                        CONN_h.menus.m_analyses_00{15}=conn_menu('slider',boffset+[pos(1)+pos(3)-0*.015,pos(2),.015,pos(4)],'','','z-slice','conn(''gui_analyses'',15);');
                        set(CONN_h.menus.m_analyses_00{15},'visible','off');
                        conn_menumanager('onregion',CONN_h.menus.m_analyses_00{15},1,boffset+pos+[0 0 .015 0]);
                        %CONN_h.menus.m_analyses_00{15}=uicontrol('style','slider','units','norm','position',boffset+[pos(1)+pos(3)-0*.015,pos(2),.015,pos(4)],'callback','conn(''gui_analyses'',15);','backgroundcolor',CONN_gui.backgroundcolorA);
                    end
                    CONN_h.menus.m_analyses_00{14}=conn_menu('image',boffset+pos,' ');
                    %conn_menu('frame',[2*.91/4,.89,.91/4,.05],'');
                    
                    if ~isfield(CONN_x.Analyses(ianalysis).variables,'names')||isempty(CONN_x.Analyses(ianalysis).variables.names), 
                        conn_menumanager clf;
                        conn_menuframe;
                        conn_menumanager([CONN_h.menus.m_analyses_02,CONN_h.menus.m_analyses_03,CONN_h.menus.m_setup_06,CONN_h.menus.m0],'on',1);
                        uiwait(errordlg('Run first the Denoising step by pressing "Done" in the Denoising tab','Data not prepared for analyses')); 
                        conn gui_preproc; 
                        return; 
                    end
                    if ~isfield(CONN_x.Analyses(ianalysis),'modulation') || isempty(CONN_x.Analyses(ianalysis).modulation), CONN_x.Analyses(ianalysis).modulation=0; end
                    if ~isfield(CONN_x.Analyses(ianalysis),'measure') || isempty(CONN_x.Analyses(ianalysis).measure), CONN_x.Analyses(ianalysis).measure=1; end
                    if ~isfield(CONN_x.Analyses(ianalysis),'weight') || isempty(CONN_x.Analyses(ianalysis).weight), CONN_x.Analyses(ianalysis).weight=2; end
                    if ~isfield(CONN_x.Analyses(ianalysis),'type') || isempty(CONN_x.Analyses(ianalysis).type), CONN_x.Analyses(ianalysis).type=3; end
                    set(CONN_h.menus.m_analyses_00{7},'value',CONN_x.Analyses(ianalysis).measure);
                    if ischar(CONN_x.Analyses(ianalysis).modulation), if ~isempty(regexp(CONN_x.Analyses(ianalysis).modulation,'^Dynamic factor \d+$')), value=3; else value=4; end; else value=CONN_x.Analyses(ianalysis).modulation+1; end
                    set(CONN_h.menus.m_analyses_00{10},'value',value);
                    set(CONN_h.menus.m_analyses_00{8},'value',CONN_x.Analyses(ianalysis).weight);
                    set(CONN_h.menus.m_analyses_00{9},'value',CONN_x.Analyses(ianalysis).type);
                    set([CONN_h.menus.m_analyses_00{1},CONN_h.menus.m_analyses_00{2}],'max',2);
                    tnames=CONN_x.Analyses(ianalysis).variables.names;
                    tnames(ismember(CONN_x.Analyses(ianalysis).variables.names,CONN_x.Analyses(ianalysis).regressors.names))=cellfun(@(x)[CONN_gui.parse_html{1},x,CONN_gui.parse_html{2}],tnames(ismember(CONN_x.Analyses(ianalysis).variables.names,CONN_x.Analyses(ianalysis).regressors.names)),'uni',0);
                    set(CONN_h.menus.m_analyses_00{1},'string',tnames);
                    set(CONN_h.menus.m_analyses_00{2},'string',CONN_x.Analyses(ianalysis).regressors.names);
                    conn_menumanager(CONN_h.menus.m_analyses_01,'on',1);
                    set([CONN_h.menus.m_analyses_00{1},CONN_h.menus.m_analyses_00{2}],'value',[]);
                    %set(CONN_h.menus.m_analyses_00{4},'visible','off');%
                    %set(CONN_h.menus.m_analyses_00{5},'visible','off');%
                    %set(CONN_h.menus.m_analyses_00{6},'visible','off');%
                    set([CONN_h.menus.m_analyses_00{11},CONN_h.menus.m_analyses_00{12},CONN_h.menus.m_analyses_00{13}],'max',1);
                    set(CONN_h.menus.m_analyses_00{11},'string',[repmat('Subject ',[CONN_x.Setup.nsubjects,1]),num2str((1:CONN_x.Setup.nsubjects)')]);
                    nconditions=length(CONN_x.Setup.conditions.names)-1;
                    set(CONN_h.menus.m_analyses_00{12},'string',{CONN_x.Setup.conditions.names{1:end-1}},'value',min(nconditions,get(CONN_h.menus.m_analyses_00{12},'value')));
                    set(CONN_h.menus.m_analyses_00{13},'string',{' TOTAL',CONN_x.Analyses(ianalysis).regressors.names{:}});
                    if ~isempty(CONN_x.Analyses(ianalysis).regressors.names), set(CONN_h.menus.m_analyses_00{2},'value',1); set(CONN_h.menus.m_analyses_00{13},'value',2); end
                    %set(CONN_h.screen.hfig,'pointer','watch');

                    %[path,name,ext]=fileparts(CONN_x.filename);
                    % 				filepath=fullfile(path,name,'data');
                    CONN_h.menus.m_analyses_surfhires=0;
                    icondition=[];isnewcondition=[];for ncondition=1:nconditions,[icondition(ncondition),isnewcondition(ncondition)]=conn_conditionnames(CONN_x.Setup.conditions.names{ncondition}); end
                    if any(isnewcondition), 
                        uiwait(errordlg(sprintf('Some conditions (%s) have not been processed yet. Re-run previous step (Denoising)',sprintf('%s ',CONN_x.Setup.conditions.names{isnewcondition>0})),'Data not prepared for analyses')); 
                        %conn gui_preproc; 
                        %return; 
                    end
                    CONN_h.menus.m_analyses.icondition=icondition;
                    filepath=CONN_x.folders.preprocessing;
                    if any(CONN_x.Setup.steps([2,3])),%~isfield(CONN_x.Setup,'doROIonly')||~CONN_x.Setup.doROIonly,
                        filename=fullfile(filepath,['DATA_Subject',num2str(1,'%03d'),'_Condition',num2str(CONN_h.menus.m_analyses.icondition(1),'%03d'),'.mat']);
                        CONN_h.menus.m_analyses.Y=conn_vol(filename);
                        if isfield(CONN_h.menus.m_analyses.Y,'issurface')&&CONN_h.menus.m_analyses.Y.issurface, %isequal(CONN_h.menus.m_analyses.Y.matdim.dim,conn_surf_dims(8).*[1 1 2])
                            CONN_h.menus.m_analyses.y.slice=1;
                            if CONN_h.menus.m_analyses_surfhires
                                [CONN_h.menus.m_analyses.y.data,CONN_h.menus.m_analyses.y.idx]=conn_get_volume(CONN_h.menus.m_analyses.Y);
                            else
                                [CONN_h.menus.m_analyses.y.data,CONN_h.menus.m_analyses.y.idx]=conn_get_slice(CONN_h.menus.m_analyses.Y,1);
                                [tempdata,tempidx]=conn_get_slice(CONN_h.menus.m_analyses.Y,conn_surf_dims(8)*[0;0;1]+1);
                                CONN_h.menus.m_analyses.y.data=[CONN_h.menus.m_analyses.y.data(:,CONN_gui.refs.surf.default2reduced) tempdata(:,CONN_gui.refs.surf.default2reduced)];
                                CONN_h.menus.m_analyses.y.idx=[CONN_h.menus.m_analyses.y.idx(CONN_gui.refs.surf.default2reduced);prod(conn_surf_dims(8))+tempidx(CONN_gui.refs.surf.default2reduced)];
                            end
                            set(CONN_h.menus.m_analyses_00{15},'visible','off');
                            conn_menumanager('onregionremove',CONN_h.menus.m_analyses_00{15});
                        else
                            CONN_h.menus.m_analyses.y.slice=ceil(CONN_h.menus.m_analyses.Y.matdim.dim(3)/2);
                            [CONN_h.menus.m_analyses.y.data,CONN_h.menus.m_analyses.y.idx]=conn_get_slice(CONN_h.menus.m_analyses.Y,CONN_h.menus.m_analyses.y.slice);
                        end
                    end
                    filename=fullfile(filepath,['ROI_Subject',num2str(1,'%03d'),'_Condition',num2str(CONN_h.menus.m_analyses.icondition(1),'%03d'),'.mat']);
                    CONN_h.menus.m_analyses.X1=load(filename);
%                     CONN_h.menus.m_analyses.ConditionWeights={};
%                     for ncondition=1:nconditions,
%                         for nsub=1:CONN_x.Setup.nsubjects,
%                             filename=fullfile(filepath,['ROI_Subject',num2str(nsub,'%03d'),'_Condition',num2str(icondition(ncondition),'%03d'),'.mat']);
%                             X1=load(filename,'conditionweights');
%                             for n1=1:numel(X1.conditionweights)
%                                 CONN_h.menus.m_analyses.ConditionWeights{nsub,n1}(:,ncondition)=X1.conditionweights{n1};
%                             end
%                         end
%                     end
                    if any(CONN_x.Setup.steps([2,3]))
                        if ~(isfield(CONN_h.menus.m_analyses.Y,'issurface')&&CONN_h.menus.m_analyses.Y.issurface)
                            try
                                CONN_h.menus.m_analyses.XS=spm_vol(deblank(CONN_x.Setup.structural{1}{1}{1}));
                            catch
                                CONN_h.menus.m_analyses.XS=spm_vol(fullfile(fileparts(which('spm')),'canonical','single_subj_T1.nii'));
                            end
                            xyz=conn_convertcoordinates('idx2tal',prod(CONN_h.menus.m_analyses.Y.matdim.dim(1:2))*(CONN_h.menus.m_analyses.y.slice-1)+(1:prod(CONN_h.menus.m_analyses.Y.matdim.dim(1:2))),CONN_h.menus.m_analyses.Y.matdim.mat,CONN_h.menus.m_analyses.Y.matdim.dim);
                            CONN_h.menus.m_analyses.Xs=spm_get_data(CONN_h.menus.m_analyses.XS(1),pinv(CONN_h.menus.m_analyses.XS(1).mat)*xyz');
                            CONN_h.menus.m_analyses.Xs=permute(reshape(CONN_h.menus.m_analyses.Xs,CONN_h.menus.m_analyses.Y.matdim.dim(1:2)),[2,1,3]);
                            set(CONN_h.menus.m_analyses_00{15},'min',1,'max',CONN_h.menus.m_analyses.Y.matdim.dim(3),'sliderstep',min(.5,[1,10]/(CONN_h.menus.m_analyses.Y.matdim.dim(3)-1)),'value',CONN_h.menus.m_analyses.y.slice);
                        else
                            CONN_h.menus.m_analyses.y.slice=max(1,min(4,CONN_h.menus.m_analyses.y.slice));
                        end
                    end
                    model=1;
                else
                    switch(varargin{2}),
                        case 0,
                            str=conn_menumanager(CONN_h.menus.m_analyses_01,'string');
                            switch(str{1}),
                                case '>',
                                    ncovariates=get(CONN_h.menus.m_analyses_00{1},'value');
                                    for ncovariate=ncovariates(:)',
                                        if isempty(strmatch(CONN_x.Analyses(ianalysis).variables.names{ncovariate},CONN_x.Analyses(ianalysis).regressors.names,'exact')),
                                            CONN_x.Analyses(ianalysis).regressors.names{end+1}=CONN_x.Analyses(ianalysis).variables.names{ncovariate};
                                            CONN_x.Analyses(ianalysis).regressors.types{end+1}=CONN_x.Analyses(ianalysis).variables.types{ncovariate};
                                            CONN_x.Analyses(ianalysis).regressors.deriv{end+1}=CONN_x.Analyses(ianalysis).variables.deriv{ncovariate};
                                            CONN_x.Analyses(ianalysis).regressors.fbands{end+1}=CONN_x.Analyses(ianalysis).variables.fbands{ncovariate};
                                            CONN_x.Analyses(ianalysis).regressors.dimensions{end+1}=CONN_x.Analyses(ianalysis).variables.dimensions{ncovariate};
                                        end
                                    end
                                    set(CONN_h.menus.m_analyses_00{2},'string',CONN_x.Analyses(ianalysis).regressors.names);
                                    set(CONN_h.menus.m_analyses_00{13},'string',{' TOTAL',CONN_x.Analyses(ianalysis).regressors.names{:}});
                                    tnames=CONN_x.Analyses(ianalysis).variables.names;
                                    tnames(ismember(CONN_x.Analyses(ianalysis).variables.names,CONN_x.Analyses(ianalysis).regressors.names))=cellfun(@(x)[CONN_gui.parse_html{1},x,CONN_gui.parse_html{2}],tnames(ismember(CONN_x.Analyses(ianalysis).variables.names,CONN_x.Analyses(ianalysis).regressors.names)),'uni',0);
                                    set(CONN_h.menus.m_analyses_00{1},'string',tnames);
                                case '<',
                                    ncovariates=get(CONN_h.menus.m_analyses_00{2},'value');
                                    idx=setdiff(1:length(CONN_x.Analyses(ianalysis).regressors.names),ncovariates);
                                    CONN_x.Analyses(ianalysis).regressors.names={CONN_x.Analyses(ianalysis).regressors.names{idx}};
                                    CONN_x.Analyses(ianalysis).regressors.types={CONN_x.Analyses(ianalysis).regressors.types{idx}};
                                    CONN_x.Analyses(ianalysis).regressors.deriv={CONN_x.Analyses(ianalysis).regressors.deriv{idx}};
                                    CONN_x.Analyses(ianalysis).regressors.fbands={CONN_x.Analyses(ianalysis).regressors.fbands{idx}};
                                    CONN_x.Analyses(ianalysis).regressors.dimensions={CONN_x.Analyses(ianalysis).regressors.dimensions{idx}};
                                    set(CONN_h.menus.m_analyses_00{2},'string',CONN_x.Analyses(ianalysis).regressors.names,'value',min(max(ncovariates),length(CONN_x.Analyses(ianalysis).regressors.names)));
                                    set(CONN_h.menus.m_analyses_00{13},'string',{' TOTAL',CONN_x.Analyses(ianalysis).regressors.names{:}},'value',min(max(get(CONN_h.menus.m_analyses_00{13},'value')),length(CONN_x.Analyses(ianalysis).regressors.names)+1));
                                    tnames=CONN_x.Analyses(ianalysis).variables.names;
                                    tnames(ismember(CONN_x.Analyses(ianalysis).variables.names,CONN_x.Analyses(ianalysis).regressors.names))=cellfun(@(x)[CONN_gui.parse_html{1},x,CONN_gui.parse_html{2}],tnames(ismember(CONN_x.Analyses(ianalysis).variables.names,CONN_x.Analyses(ianalysis).regressors.names)),'uni',0);
                                    set(CONN_h.menus.m_analyses_00{1},'string',tnames);
                            end
                            model=1;
                        case 1,
                            conn_menumanager(CONN_h.menus.m_analyses_01,'string',{'>'},'on',1);
                            set(CONN_h.menus.m_analyses_00{2},'value',[]);
                            set(CONN_h.menus.m_analyses_00{22},'visible','on');
                            %set([CONN_h.menus.m_analyses_00{4},CONN_h.menus.m_analyses_00{5},CONN_h.menus.m_analyses_00{6}],'visible','off');%
                        case 2,
                            conn_menumanager(CONN_h.menus.m_analyses_01,'string',{'<'},'on',1);
                            set(CONN_h.menus.m_analyses_00{1},'value',[]);
                            set(CONN_h.menus.m_analyses_00{22},'visible','off');
                            %set([CONN_h.menus.m_analyses_00{4},CONN_h.menus.m_analyses_00{5},CONN_h.menus.m_analyses_00{6}],'visible','on');%
                            nregressors=get(CONN_h.menus.m_analyses_00{2},'value');
                            if numel(nregressors)==1, 
                                set(CONN_h.menus.m_analyses_00{13},'value',nregressors+1);
                                model=2;
                            end
                        case 4,
                            nregressors=get(CONN_h.menus.m_analyses_00{2},'value');
                            value=str2num(get(CONN_h.menus.m_analyses_00{4},'string'));
                            if length(value)==1, for nregressor=nregressors(:)', CONN_x.Analyses(ianalysis).regressors.deriv{nregressor}=round(max(0,min(2,value))); end; end
                            model=1;
                        case 5,
                            nregressors=get(CONN_h.menus.m_analyses_00{2},'value');
                            value=str2num(get(CONN_h.menus.m_analyses_00{5},'string'));
                            if length(value)==1
                                if ~isfield(CONN_h.menus.m_analyses.X1,'fbdata')
                                    answ=questdlg('To use this feature you need to first re-run the ROI-based Denoising step. Do you want to do this now?','','Yes','No','Yes');
                                    if strcmp(answ,'Yes'), 
                                        conn_process('preprocessing_roi'); 
                                        nsubs=get(CONN_h.menus.m_analyses_00{11},'value');
                                        nconditions=get(CONN_h.menus.m_analyses_00{12},'value');
                                        filepath=CONN_x.folders.preprocessing;
                                        filename=fullfile(filepath,['ROI_Subject',num2str(nsubs,'%03d'),'_Condition',num2str(CONN_h.menus.m_analyses.icondition(nconditions),'%03d'),'.mat']);
                                        CONN_h.menus.m_analyses.X1=load(filename);
                                    else value=1;
                                    end
                                end
                                for nregressor=nregressors(:)', 
                                    CONN_x.Analyses(ianalysis).regressors.fbands{nregressor}=max(1,min(numel(CONN_h.menus.m_analyses.X1.fbdata{1}),round(value))); 
                                end
                            end
                            model=1;
                        case 6,
                            nregressors=get(CONN_h.menus.m_analyses_00{2},'value');
                            value=str2num(get(CONN_h.menus.m_analyses_00{6},'string'));
                            if length(value)==1, for nregressor=nregressors(:)', CONN_x.Analyses(ianalysis).regressors.dimensions{nregressor}(1)=round(max(1,min(CONN_x.Analyses(ianalysis).regressors.dimensions{nregressor}(2),value))); end; end
                            model=1;
                        case 7,
                            CONN_x.Analyses(ianalysis).measure=get(CONN_h.menus.m_analyses_00{7},'value');
                            model=1;
                        case 8,
                            CONN_x.Analyses(ianalysis).weight=get(CONN_h.menus.m_analyses_00{8},'value');
                            model=1;
                        case 9,
                            CONN_x.Analyses(ianalysis).type=get(CONN_h.menus.m_analyses_00{9},'value');
                            model=1;
                        case 10,
                            value=get(CONN_h.menus.m_analyses_00{10},'value');
                            if value==2 % gPPI
                                CONN_x.Analyses(ianalysis).modulation=1;
                                names=CONN_x.Setup.conditions.names(1:end-1);
                                cnames=CONN_x.Analyses(ianalysis).conditions;
                                if isempty(cnames), value=1:numel(names); 
                                else value=find(ismember(names,cnames)); 
                                end
                                value=listdlg('liststring',names,'selectionmode','multiple','initialvalue',value,'promptstring',{'Select TASK conditions of interest:',' ','notes:','  - Only select task conditions; a baseline/reference condition will be implicitly modeled','  - The selected conditions will be included in all condition-specific models','  - Select all task conditions for a standard gPPI model (multiple-condition PPI)','  - Leave emtpy or click Cancel for a standard sPPI model (single-condition PPI)'},'ListSize',[300 200]);
                                if isempty(value), cnames={''};
                                elseif isequal(value,1:numel(names)), cnames=[];
                                else cnames=names(value);
                                end
                                CONN_x.Analyses(ianalysis).conditions=cnames;
                            elseif value==3 % temporal modulation dynamic FC
                                filename=fullfile(CONN_x.folders.preprocessing,['dyn_Subject',num2str(1,'%03d'),'.mat']);
                                try
                                    load(filename,'names');
                                    if ischar(CONN_x.Analyses(ianalysis).modulation)
                                        [ok,value]=ismember(CONN_x.Analyses(ianalysis).modulation,names);
                                        if ~ok, value=1; end
                                    else value=1;
                                    end
                                    value=listdlg('liststring',names,'selectionmode','single','initialvalue',value,'promptstring','Select interaction factor','ListSize',[300 200]);
                                    if isempty(value), value=CONN_x.Analyses(ianalysis).modulation;
                                    else value=names{value};
                                    end
                                catch
                                    if CONN_x.Setup.steps(4)
                                        uiwait(warndlg('Please run first first-level analysis ''Dynamic FC'' step to enable these analyes',''));
                                    else
                                        uiwait(warndlg('Please enable ''Dynamic FC'' in Setup.Options, and then run first-level analysis ''Dynamic FC'' step to enable these analyes',''));
                                    end
                                    value=0;
                                end
                                CONN_x.Analyses(ianalysis).modulation=value;
                            elseif value==4 % other temporal modulation
                                if ischar(CONN_x.Analyses(ianalysis).modulation)
                                    idx=find(strcmp(CONN_x.Analyses(ianalysis).modulation,CONN_h.menus.m_analyses.X1.names));
                                    if numel(idx)==1, value=idx; 
                                    elseif isempty(idx), value=1;
                                    else,
                                        idx=find(cellfun(@(x)all(isnan(x)),CONN_h.menus.m_analyses.X1.xyz));
                                        idx=idx(strcmp(CONN_x.Analyses(ianalysis).modulation,CONN_h.menus.m_analyses.X1.names(idx)));
                                        if numel(idx)==1, value=idx;
                                        else value=1;
                                        end
                                    end
                                else value=1; 
                                end
                                value=listdlg('liststring',CONN_h.menus.m_analyses.X1.names,'selectionmode','single','initialvalue',value,'promptstring','Select interaction factor','ListSize',[300 200]);
                                if isempty(value), value=CONN_x.Analyses(ianalysis).modulation;
                                else value=CONN_h.menus.m_analyses.X1.names{value};
                                end
                                CONN_x.Analyses(ianalysis).modulation=value;
                            else
                                CONN_x.Analyses(ianalysis).modulation=value-1;
                            end
                            model=1;
                        case {11,12},
                            nsubs=get(CONN_h.menus.m_analyses_00{11},'value');
                            nconditions=get(CONN_h.menus.m_analyses_00{12},'value');
                            %[path,name,ext]=fileparts(CONN_x.filename);
                            filepath=CONN_x.folders.preprocessing;
                            if any(CONN_x.Setup.steps([2,3])),%~isfield(CONN_x.Setup,'doROIonly')||~CONN_x.Setup.doROIonly,
                                filename=fullfile(filepath,['DATA_Subject',num2str(nsubs,'%03d'),'_Condition',num2str(CONN_h.menus.m_analyses.icondition(nconditions),'%03d'),'.mat']);
                                CONN_h.menus.m_analyses.Y=conn_vol(filename);
                                if isfield(CONN_h.menus.m_analyses.Y,'issurface')&&CONN_h.menus.m_analyses.Y.issurface
                                    if CONN_h.menus.m_analyses_surfhires
                                        [CONN_h.menus.m_analyses.y.data,CONN_h.menus.m_analyses.y.idx]=conn_get_volume(CONN_h.menus.m_analyses.Y);
                                    else
                                        [CONN_h.menus.m_analyses.y.data,CONN_h.menus.m_analyses.y.idx]=conn_get_slice(CONN_h.menus.m_analyses.Y,1);
                                        [tempdata,tempidx]=conn_get_slice(CONN_h.menus.m_analyses.Y,conn_surf_dims(8)*[0;0;1]+1);
                                        CONN_h.menus.m_analyses.y.data=[CONN_h.menus.m_analyses.y.data(:,CONN_gui.refs.surf.default2reduced) tempdata(:,CONN_gui.refs.surf.default2reduced)];
                                        CONN_h.menus.m_analyses.y.idx=[CONN_h.menus.m_analyses.y.idx(CONN_gui.refs.surf.default2reduced);prod(conn_surf_dims(8))+tempidx(CONN_gui.refs.surf.default2reduced)];
                                    end
                                else
                                    [CONN_h.menus.m_analyses.y.data,CONN_h.menus.m_analyses.y.idx]=conn_get_slice(CONN_h.menus.m_analyses.Y,CONN_h.menus.m_analyses.y.slice);
                                end
                            end
                            filename=fullfile(filepath,['ROI_Subject',num2str(nsubs,'%03d'),'_Condition',num2str(CONN_h.menus.m_analyses.icondition(nconditions),'%03d'),'.mat']);
                            CONN_h.menus.m_analyses.X1=load(filename);
                            %filename=fullfile(filepath,['COV_Subject',num2str(nsubs,'%03d'),'_Session',num2str(nconditions,'%03d'),'.mat']);
                            %CONN_h.menus.m_analyses.X2=load(filename);
                            if any(CONN_x.Setup.steps([2,3]))
                                if ~(isfield(CONN_h.menus.m_analyses.Y,'issurface')&&CONN_h.menus.m_analyses.Y.issurface)
                                    try
                                        CONN_h.menus.m_analyses.XS=spm_vol(deblank(CONN_x.Setup.structural{nsubs}{1}{1})); %note: displaying first-session structural here
                                    catch
                                        CONN_h.menus.m_analyses.XS=spm_vol(fullfile(fileparts(which('spm')),'canonical','single_subj_T1.nii'));
                                    end
                                    xyz=conn_convertcoordinates('idx2tal',prod(CONN_h.menus.m_analyses.Y.matdim.dim(1:2))*(CONN_h.menus.m_analyses.y.slice-1)+(1:prod(CONN_h.menus.m_analyses.Y.matdim.dim(1:2))),CONN_h.menus.m_analyses.Y.matdim.mat,CONN_h.menus.m_analyses.Y.matdim.dim);
                                    CONN_h.menus.m_analyses.Xs=spm_get_data(CONN_h.menus.m_analyses.XS(1),pinv(CONN_h.menus.m_analyses.XS(1).mat)*xyz');
                                    CONN_h.menus.m_analyses.Xs=permute(reshape(CONN_h.menus.m_analyses.Xs,CONN_h.menus.m_analyses.Y.matdim.dim(1:2)),[2,1,3]);
                                end
                            end
                            model=1;
                        case 13,
                            model=2;
                        case 15,
                            CONN_h.menus.m_analyses.y.slice=round(get(CONN_h.menus.m_analyses_00{15},'value'));
                            if any(CONN_x.Setup.steps([2,3]))&&~(isfield(CONN_h.menus.m_analyses.Y,'issurface')&&CONN_h.menus.m_analyses.Y.issurface)
                                [CONN_h.menus.m_analyses.y.data,CONN_h.menus.m_analyses.y.idx]=conn_get_slice(CONN_h.menus.m_analyses.Y,CONN_h.menus.m_analyses.y.slice);
                                xyz=conn_convertcoordinates('idx2tal',prod(CONN_h.menus.m_analyses.Y.matdim.dim(1:2))*(CONN_h.menus.m_analyses.y.slice-1)+(1:prod(CONN_h.menus.m_analyses.Y.matdim.dim(1:2))),CONN_h.menus.m_analyses.Y.matdim.mat,CONN_h.menus.m_analyses.Y.matdim.dim);
                                CONN_h.menus.m_analyses.Xs=spm_get_data(CONN_h.menus.m_analyses.XS(1),pinv(CONN_h.menus.m_analyses.XS(1).mat)*xyz');
                                CONN_h.menus.m_analyses.Xs=permute(reshape(CONN_h.menus.m_analyses.Xs,CONN_h.menus.m_analyses.Y.matdim.dim(1:2)),[2,1,3]);
                            end
                            model=1;
                        case 19,
                            model=2;
                        case 20,
                            tianalysis=get(CONN_h.menus.m_analyses_00{20},'value');
                            analysisname=char(get(CONN_h.menus.m_analyses_00{20},'string'));
                            if tianalysis==size(analysisname,1)-1, % new %strcmp(deblank(analysisname(tianalysis,:)),'<HTML><i>new</i></HTML>'),
                                ok=0;
                                while ~ok,
                                    txt=inputdlg('New analysis name:','conn',1,{['ANALYSIS_',num2str(tianalysis,'%02d')]});
                                    if isempty(txt), break; end
                                    txt{1}(~isstrprop(txt{1},'alphanum'))='_';
                                    [ok,nill]=mkdir(CONN_x.folders.firstlevel,txt{1});
                                    if ~ok, uiwait(errordlg('Unable to create folder. Check folder permissions','conn'));end
                                end
                                if ok,
                                    CONN_x.Analyses(tianalysis)=CONN_x.Analyses(ianalysis);
                                    CONN_x.Analyses(tianalysis).name=txt{1};
                                    CONN_x.Analyses(tianalysis).sourcenames={};
                                    CONN_x.Analysis=tianalysis;
                                    conn gui_analyses;
                                    return;
                                else
                                    set(CONN_h.menus.m_analyses_00{20},'value',ianalysis);
                                end
                            elseif tianalysis==size(analysisname,1),  % delete
                                answ=questdlg({sprintf('Are you sure you want to delete analysis %s?',CONN_x.Analyses(CONN_x.Analysis).name),'This is a non-reversible operation'},'','Delete','Cancel','Cancel');
                                if isequal(answ,'Delete')
                                    CONN_x.Analyses=CONN_x.Analyses([1:CONN_x.Analysis-1,CONN_x.Analysis+1:end]);
                                    CONN_x.Analysis=min(numel(CONN_x.Analyses),CONN_x.Analysis);
                                    conn gui_analyses;
                                    return;
                                else
                                    set(CONN_h.menus.m_analyses_00{20},'value',ianalysis);
                                end
                            else
                                CONN_x.Analysis=tianalysis;
                                conn gui_analyses;
                                return;
                            end
                    end
                end
                nsubs=get(CONN_h.menus.m_analyses_00{11},'value');
                nregressors=get(CONN_h.menus.m_analyses_00{2},'value');
                nview=get(CONN_h.menus.m_analyses_00{13},'value')-1;
                nconditions=get(CONN_h.menus.m_analyses_00{12},'value');
                if ischar(CONN_x.Analyses(ianalysis).modulation)||CONN_x.Analyses(ianalysis).modulation>0
                    if ~isfield(CONN_h.menus.m_analyses.X1,'crop')||CONN_h.menus.m_analyses.X1.crop||(any(CONN_x.Setup.steps([2,3]))&&(~isfield(CONN_h.menus.m_analyses.Y,'crop')||CONN_h.menus.m_analyses.Y.crop)),
                        CONN_x.Analyses(ianalysis).modulation=0;
                        uiwait(warndlg({'Temporal-modulation analyses not ready for selected condition',' ','Please re-run the first-level analysis ''Dynamic FC'' step to enable these analyses.'},'')); 
                    end
                end
                if ischar(CONN_x.Analyses(ianalysis).modulation)||CONN_x.Analyses(ianalysis).modulation>0, 
                    set(CONN_h.menus.m_analyses_00{8},'visible','off'); 
                    set(CONN_h.menus.m_analyses_00{14}.htitle,'string','Temporal Modulation');
                    %set(CONN_h.menus.m_analyses_00{10},'position',boffset+[.105,.15,.31,.04]);
%                     if CONN_x.Analyses(ianalysis).measure<3,
%                         disp('Warning: correlation measure not recommended for gPPI analyses');
%                     end
                else
                    set(CONN_h.menus.m_analyses_00{8},'visible','on'); 
                    set(CONN_h.menus.m_analyses_00{14}.htitle,'string','Connectivity (seed-to-voxel)');
                    %set(CONN_h.menus.m_analyses_00{10},'position',boffset+[.105,.15,.23,.04]);
                end
                %if CONN_x.Analyses(ianalysis).weight==1&&CONN_x.Analyses(ianalysis).modulation==1, uiwait(warndlg({'Parametric task-effect modulation requires non-constant interaction term / weights','Change ''weights'' to hrf for standard analyses'})); end
                set(CONN_h.menus.m_analyses_00{7},'value',CONN_x.Analyses(ianalysis).measure);
                if ischar(CONN_x.Analyses(ianalysis).modulation), if ~isempty(regexp(CONN_x.Analyses(ianalysis).modulation,'^Dynamic factor \d+$')), value=3; else value=4; end; else value=CONN_x.Analyses(ianalysis).modulation+1; end
                set(CONN_h.menus.m_analyses_00{10},'value',value);
                [CONN_h.menus.m_analyses.X,CONN_h.menus.m_analyses.select]=conn_designmatrix(CONN_x.Analyses(ianalysis).regressors,CONN_h.menus.m_analyses.X1,[],{nregressors,nview});
                if ~isempty(nregressors)&&all(nregressors>0),
                    temp=cat(1,CONN_x.Analyses(ianalysis).regressors.deriv{nregressors});
                    if length(temp)==1 || ~any(any(diff(temp,1,1))),set(CONN_h.menus.m_analyses_00{4},'string',num2str(CONN_x.Analyses(ianalysis).regressors.deriv{nregressors(1)}));
                    else  set(CONN_h.menus.m_analyses_00{4},'string','MULTIPLE VALUES'); end
                    temp=cat(1,CONN_x.Analyses(ianalysis).regressors.fbands{nregressors});
                    if length(temp)==1 || ~any(any(diff(temp,1,1))),set(CONN_h.menus.m_analyses_00{5},'string',num2str(CONN_x.Analyses(ianalysis).regressors.fbands{nregressors(1)}));
                    else  set(CONN_h.menus.m_analyses_00{5},'string','MULTIPLE VALUES'); end
                    temp=cat(1,CONN_x.Analyses(ianalysis).regressors.dimensions{nregressors});
                    if size(temp,1)==1 || ~any(any(diff(temp,1,1))),set(CONN_h.menus.m_analyses_00{6},'string',num2str(CONN_x.Analyses(ianalysis).regressors.dimensions{nregressors(1)}(1)));
                    else  set(CONN_h.menus.m_analyses_00{6},'string','MULTIPLE VALUES'); end
                end
                if model==1,
                    xf=CONN_h.menus.m_analyses.X;
                    nX=size(xf,2);
                    wx=ones(size(xf,1),1);
                    switch(CONN_x.Analyses(ianalysis).weight),
                        case 1, wx=double(CONN_h.menus.m_analyses.X1.conditionweights{1}>0);
                        case 2, wx=CONN_h.menus.m_analyses.X1.conditionweights{1};
                        case 3, wx=CONN_h.menus.m_analyses.X1.conditionweights{2};
                        case 4, wx=CONN_h.menus.m_analyses.X1.conditionweights{3};
                    end
                    if any(CONN_x.Setup.steps([2,3])),%~isfield(CONN_x.Setup,'doROIonly')||~CONN_x.Setup.doROIonly,
                        if ~(ischar(CONN_x.Analyses(ianalysis).modulation)||CONN_x.Analyses(ianalysis).modulation>0)
                            wx=max(0,wx);
                            xf=cat(2,xf(:,1),conn_wdemean(xf(:,2:end),wx));
                            xf=xf.*repmat(wx,[1,size(xf,2)]);
                            yf=CONN_h.menus.m_analyses.y.data;
                            yf=conn_wdemean(yf,wx);
                            yf=yf.*repmat(wx,[1,size(yf,2)]);
                        else
                            %xf=cat(2,xf(:,1),detrend(xf(:,2:end),'constant'));
                            yf=CONN_h.menus.m_analyses.y.data;
                            yf=detrend(yf,'constant');
                            if ~ischar(CONN_x.Analyses(ianalysis).modulation)
                                %wx=CONN_h.menus.m_analyses.X1.conditionweights{3}; %PPI
                                if isempty(CONN_x.Analyses(ianalysis).conditions), validconditions=1:length(CONN_x.Setup.conditions.names)-1;
                                else validconditions=find(ismember(CONN_x.Setup.conditions.names(1:end-1),CONN_x.Analyses(ianalysis).conditions));
                                end
                                wx=[];
                                for tncondition=[setdiff(validconditions,nconditions) nconditions],
                                    filename=fullfile(CONN_x.folders.preprocessing,['ROI_Subject',num2str(nsubs,'%03d'),'_Condition',num2str(CONN_h.menus.m_analyses.icondition(tncondition),'%03d'),'.mat']);
                                    X1=load(filename,'conditionweights');
                                    wx=[wx X1.conditionweights{3}(:)];
                                end
%                                 wx=CONN_h.menus.m_analyses.ConditionWeights{nsubs,3}(:,[setdiff(validconditions,nconditions) nconditions]); %gPPI
                            elseif ~isempty(regexp(CONN_x.Analyses(ianalysis).modulation,'^Dynamic factor \d+$')), 
                                filename=fullfile(CONN_x.folders.preprocessing,['dyn_Subject',num2str(nsubs,'%03d'),'.mat']);
                                xmod=load(filename);
                                [ok,idx]=ismember(CONN_x.Analyses(ianalysis).modulation,xmod.names);
                                if ok, wx=xmod.data(:,idx);
                                else error('Temporal factor not found');
                                end
                                wx=conn_bsxfun(@times,wx,CONN_h.menus.m_analyses.X1.conditionweights{1}>0);
                            else
                                idx=find(strcmp(CONN_x.Analyses(ianalysis).modulation,CONN_h.menus.m_analyses.X1.names));
                                if numel(idx)==1, wx=CONN_h.menus.m_analyses.X1.data{idx};
                                elseif isempty(idx), error('Covariate not found. Please re-run Dynamic FC step');
                                else, 
                                    idx=find(cellfun(@(x)all(isnan(x)),CONN_h.menus.m_analyses.X1.xyz));
                                    idx=idx(strcmp(CONN_x.Analyses(ianalysis).modulation,CONN_h.menus.m_analyses.X1.names(idx)));
                                    if numel(idx)==1, wx=CONN_h.menus.m_analyses.X1.data{idx};
                                    else error('Covariate not found');
                                    end
                                end
                                wx=conn_bsxfun(@times,wx,CONN_h.menus.m_analyses.X1.conditionweights{1}>0);
                            end
                            inter=wx;
                            xf=[xf(:,1) detrend([xf(:,2:end) reshape(repmat(permute(inter,[1 3 2]),[1,size(xf,2),1]),size(xf,1),[]) reshape(conn_bsxfun(@times,xf,permute(inter,[1 3 2])),size(xf,1),[])],'constant')];
                            %xf=[xf inter conn_bsxfun(@times,xf,inter)];
                            %xf=[xf(:,1) detrend([xf(:,2:end) repmat(inter,[1,size(xf,2)]) conn_bsxfun(@times,xf,inter)],'constant')];
                        end
                        [CONN_h.menus.m_analyses.B,CONN_h.menus.m_analyses.opt]=conn_glmunivariate('estimate',xf,yf);
                    end
                    CONN_h.menus.m_analyses.nVars=size(xf,2)/nX;
                    CONN_h.menus.m_analyses.Xf=xf;
                    %CONN_h.menus.m_analyses.B=pinv(CONN_h.menus.m_analyses.X)*CONN_h.menus.m_analyses.Y.data;
                end
                if isempty(nregressors)||any(nregressors==0), 
                    conn_menu('update',CONN_h.menus.m_analyses_00{3},[]);
                    set(CONN_h.menus.m_analyses_00{22},'visible','on');
                else
                    if get(CONN_h.menus.m_analyses_00{19},'value')==1
                        conn_menu('update',CONN_h.menus.m_analyses_00{3},CONN_h.menus.m_analyses.X);
                        if size(CONN_h.menus.m_analyses.X,2)<=500,
                            offon={'off','on'};
                            for n1=1:size(CONN_h.menus.m_analyses.X,2),
                                set(CONN_h.menus.m_analyses_00{3}.h4(n1),'visible',offon{1+CONN_h.menus.m_analyses.select{1}(n1)});
                            end
                            xtemp=CONN_h.menus.m_analyses.X(:,find(CONN_h.menus.m_analyses.select{1}));
                            if ~isempty(xtemp), set(CONN_h.menus.m_analyses_00{3}.h3,'ylim',[min(min(xtemp))-1e-4,max(max(xtemp))+1e-4]); end
                        end
                    else
                        if ismember(CONN_x.Analyses(ianalysis).measure,[1 3]), idx1=find(CONN_h.menus.m_analyses.select{1});
                        else idx1=2:numel(CONN_h.menus.m_analyses.select{1}); 
                        end
                        emph2=[]; idx2=[]; for n1=1:numel(idx1), idx3=idx1(n1):size(CONN_h.menus.m_analyses.Xf,2)/CONN_h.menus.m_analyses.nVars:size(CONN_h.menus.m_analyses.Xf,2); idx2=[idx2 idx3]; emph2=[emph2 zeros(1,numel(idx3)-1) CONN_h.menus.m_analyses.select{1}(idx1(n1))]; end; [idx2,idx3]=sort(idx2); emph2=emph2(idx3); temp=CONN_h.menus.m_analyses.Xf(:,idx2); temp=bsxfun(@rdivide,temp,max(.01,max(abs(temp),[],1)));
                        temp=round(128+64.5+63.5*temp);
                        temp(:,~emph2)=temp(:,~emph2)-128;
                        set(CONN_h.menus.m_analyses_00{3}.h4,'visible','off');
                        conn_menu('updatematrix',CONN_h.menus.m_analyses_00{3},ind2rgb(max(1,min(256,round(temp)')),[gray(128);hot(128)]));
                    end
                end
                
                if model,
                    if any(CONN_x.Setup.steps([2,3])),%~isfield(CONN_x.Setup,'doROIonly')||~CONN_x.Setup.doROIonly,
                        t1=zeros(CONN_h.menus.m_analyses.Y.matdim.dim(1:2));
                        t2=0+zeros(CONN_h.menus.m_analyses.Y.matdim.dim(1:2));
                        idx=find(CONN_h.menus.m_analyses.select{2});
                        C=eye(size(CONN_h.menus.m_analyses.opt.X,2));
                        if ischar(CONN_x.Analyses(ianalysis).modulation)||CONN_x.Analyses(ianalysis).modulation>0 % parametric modulation
                            switch(CONN_x.Analyses(ianalysis).measure),
                                case {1,3}, %bivariate
                                    C=pinv((CONN_h.menus.m_analyses.opt.XX).*kron(ones(CONN_h.menus.m_analyses.nVars),eye(size(CONN_h.menus.m_analyses.opt.XX,2)/CONN_h.menus.m_analyses.nVars)))*CONN_h.menus.m_analyses.opt.XX;
                                    C=C((CONN_h.menus.m_analyses.nVars-1)*size(C,1)/CONN_h.menus.m_analyses.nVars+1:end,:);
                                    if ~isempty(idx), C=C(idx,:); end
                                    %C=pinv(CONN_h.menus.m_analyses.opt.X(:,[1,idx]))*CONN_h.menus.m_analyses.opt.X;
                                    %C=C(2:end,:); % unique + shared variance
                                case {2,4}, %partial
                                    C=C((CONN_h.menus.m_analyses.nVars-1)*size(C,1)/CONN_h.menus.m_analyses.nVars+1:end,:);
                                    if ~isempty(idx), C=C(idx,:); end % unique variance
                            end
                        else % functional connectivity
                            if ~isempty(idx),
                                switch(CONN_x.Analyses(ianalysis).measure),
                                    case {1,3}, %bivariate
                                        C=pinv(CONN_h.menus.m_analyses.opt.X(:,[1,idx]))*CONN_h.menus.m_analyses.opt.X;
                                        C=C(2:end,:); % unique + shared variance
                                    case {2,4}, %partial
                                        C=C(idx,:);  % unique variance
                                end
                            end
                        end
                        [h,F,p,dof,R]=conn_glmunivariate('evaluate',CONN_h.menus.m_analyses.opt,[],C);
                        switch(CONN_x.Analyses(ianalysis).measure),
                            case {1,2}, %correlation
                                S1=sign(R).*sqrt(abs(R)); S2=abs(S1);
                            case {3,4}, %regression
                                S1=h; if size(S1,1)>1, S1=sqrt(sum(abs(S1).^2,1)); end; S2=abs(S1);
                        end
                        if isfield(CONN_h.menus.m_analyses.Y,'issurface')&&CONN_h.menus.m_analyses.Y.issurface, issurface=true; else issurface=false; end
                        t1=zeros(CONN_h.menus.m_analyses.Y.matdim.dim(1:2+issurface));
                        t2=nan+zeros(CONN_h.menus.m_analyses.Y.matdim.dim(1:2+issurface));
                        t1(CONN_h.menus.m_analyses.y.idx)=S1;
                        t2(CONN_h.menus.m_analyses.y.idx)=S2;
                        if isfield(CONN_h.menus.m_analyses.Y,'issurface')&&CONN_h.menus.m_analyses.Y.issurface
                            if ~CONN_h.menus.m_analyses_surfhires
                                t1=[t1(CONN_gui.refs.surf.default2reduced) t1(numel(t1)/2+CONN_gui.refs.surf.default2reduced)];
                                t2=[t2(CONN_gui.refs.surf.default2reduced) t2(numel(t2)/2+CONN_gui.refs.surf.default2reduced)];
                                conn_menu('update',CONN_h.menus.m_analyses_00{14},{CONN_gui.refs.surf.defaultreduced,t1,t2},{CONN_h.menus.m_analyses.Y.matdim,CONN_h.menus.m_analyses.y.slice});
                            else
                                conn_menu('update',CONN_h.menus.m_analyses_00{14},{CONN_gui.refs.surf.default,t1,t2},{CONN_h.menus.m_analyses.Y.matdim,CONN_h.menus.m_analyses.y.slice});
                            end
                        else
                            t1=permute(t1,[2,1,3]);
                            t2=permute(t2,[2,1,3]);
                            conn_menu('update',CONN_h.menus.m_analyses_00{14},{CONN_h.menus.m_analyses.Xs,t1,t2},{CONN_h.menus.m_analyses.Y.matdim,CONN_h.menus.m_analyses.y.slice});
                        end
                    else
                        conn_menu('update',CONN_h.menus.m_analyses_00{14},[]);
                    end
                end
            elseif state(1)==3 % VOXEL-TO-VOXEL
                boffset=[.02 .03 0 0];
                if nargin<2,
                    if ~any(CONN_x.Setup.steps(state)), uiwait(errordlg('No voxel-to-voxel analyses computed. Select these options in ''Setup->Options'' to perform additional analyses','')); conn gui_setup; return; end
                    conn_menumanager clf;
                    conn_menuframe;
                    tstate=conn_menumanager(CONN_h.menus.m0,'state'); tstate(:)=0;tstate(3)=1; conn_menumanager(CONN_h.menus.m0,'state',tstate);
                    conn_menumanager([CONN_h.menus.m_analyses_04,CONN_h.menus.m_analyses_03,CONN_h.menus.m_setup_06,CONN_h.menus.m0],'on',1);
                    if isempty(CONN_x.vvAnalyses.regressors.names), uiwait(errordlg('Run first the Denoising step by pressing "Done" in the Denoising tab','Data not prepared for analyses')); conn gui_preproc; return; end
                    conn_menu('nullstr',{'Preview not','available'});
                    
                    nsubs=1;
                    nconditions=1;
                    filepath=CONN_x.folders.preprocessing;
                    nconditions=length(CONN_x.Setup.conditions.names)-1;
                    icondition=[];isnewcondition=[];for ncondition=1:nconditions,[icondition(ncondition),isnewcondition(ncondition)]=conn_conditionnames(CONN_x.Setup.conditions.names{ncondition}); end
                    if any(isnewcondition), 
                        uiwait(errordlg(sprintf('Some conditions (%s) have not been processed yet. Re-run previous step (Denoising)',sprintf('%s ',CONN_x.Setup.conditions.names{isnewcondition>0})),'Data not prepared for analyses')); 
                        %conn gui_preproc; 
                        %return; 
                    end
                    CONN_h.menus.m_analyses.icondition=icondition;
                    if any(CONN_x.Setup.steps(3)),%~isfield(CONN_x.Setup,'doROIonly')||~CONN_x.Setup.doROIonly,
                        filename=fullfile(filepath,['vvPC_Subject',num2str(nsubs,'%03d'),'_Condition',num2str(CONN_h.menus.m_analyses.icondition(nconditions),'%03d'),'.mat']);
                        CONN_h.menus.m_analyses.Y=conn_vol(filename);
                        CONN_h.menus.m_analyses.y.slice=ceil(CONN_h.menus.m_analyses.Y.matdim.dim(3)/2);
                        filename=fullfile(filepath,['vvPCeig_Subject',num2str(nsubs,'%03d'),'_Condition',num2str(CONN_h.menus.m_analyses.icondition(nconditions),'%03d'),'.mat']);
                        CONN_h.menus.m_analyses.y.data=load(filename,'D');
                    end
                    
                    conn_menu('frame',boffset+[.115,.22,.415,.60],'');%'FC ANALYSIS OPTIONS');
                    [nill,CONN_h.menus.m_analyses_00{16}]=conn_menu('text',boffset+[.125,.70,.26,.05],'Functional connectivity measures of interest:');
                    set(CONN_h.menus.m_analyses_00{16},'horizontalalignment','left');
                    CONN_h.menus.m_analyses_00{1}=conn_menu('listbox',boffset+[.125,.25,.095,.45],'all measures','','All available types of voxel-to-voxel measures','conn(''gui_analyses'',1);');
                    CONN_h.menus.m_analyses_00{2}=conn_menu('listbox',boffset+[.24,.25,.17,.45],'Voxel-to-Voxel Measures','','<HTML>Select the desired set of voxel-to-voxel measures to compute  <br/> - <i>connectome-MVPA</i> estimates, for each seed-voxel, a multivariate representation of the connectivity pattern between this voxel and the entire brain<br/> - <i>IntegratedLocalCorrelation</i> computes, for each seed-voxel, the average correlation between this voxel and its neighbours<br/> - <i>RadialCorrelationContrast</i> computes, for each seed-voxel, the spatial gradient of the local connectivity between this voxel and its neighbors<br/> - <i>IntrinsicConnectivityContrast</i> computes, for each seed-voxel, the strength/norm of the connectivity pattern between this voxel and the entire brain<br/> - <i>RadialSimilarityContrast</i> computes, for each seed-voxel, the strength/norm of the spatial gradient in connectivity patterns between this voxel and the entire brain<br/> - Select measures in the <i>all measures</i> list and click <b> > </b> to add new measures to this list <br/></HTML>','conn(''gui_analyses'',2);');
                    [CONN_h.menus.m_analyses_00{7}(1),CONN_h.menus.m_analyses_00{7}(2)]=conn_menu('edit',boffset+[.42,.7,.11,.04],'Name','','name of voxel-to-voxel measure','conn(''gui_analyses'',7);');
                    [CONN_h.menus.m_analyses_00{4}(1),CONN_h.menus.m_analyses_00{4}(2)]=conn_menu('edit',boffset+[.42,.6,.11,.04],'Kernel size (mm)','','<HTML>Define integration kernel size (FWHM of Gaussian kernel) <br/> - special cases: <i>0</i> for single voxel; <i>inf</i> for entire brain</HTML>','conn(''gui_analyses'',4);');
                    measuretypes={'Local','Global'};
                    CONN_h.menus.m_analyses_00{5}=[];%[CONN_h.menus.m_analyses_00{5}(1),CONN_h.menus.m_analyses_00{5}(2)]=conn_menu('popup',boffset+[.4,.4,.11,.04],'Measure type',measuretypes,'Select type of voxel-to-voxel measure (local for analyses of local connectivity patterns; global for analyses of global connectivity patterns)','conn(''gui_analyses'',5);');
                    measuretypes={'Gaussian','Gradient','Laplacian'};
                    CONN_h.menus.m_analyses_00{6}=[];%[CONN_h.menus.m_analyses_00{6}(1),CONN_h.menus.m_analyses_00{6}(2)]=conn_menu('popup',boffset+[.4,.3,.11,.04],'Kernel shape',measuretypes,'Define integration kernel shape','conn(''gui_analyses'',6);');
                    [CONN_h.menus.m_analyses_00{8}(1),CONN_h.menus.m_analyses_00{8}(2)]=conn_menu('edit',boffset+[.42,.4,.11,.04],'Dimensionality reduction','','<HTML>(optional) dimensionality reduction step <br/> - define number of SVD components characterizing each subject Voxel-to-Voxel correlation matrix to retain <br/> - set to <i>inf</i> for no dimensionality reduction</HTML>','conn(''gui_analyses'',8);');
                    [CONN_h.menus.m_analyses_00{9}(1),CONN_h.menus.m_analyses_00{9}(2)]=conn_menu('edit',boffset+[.42,.6,.11,.04],'Number of factors','','<HTML>Define number of MVPA components to estimate. <br/> For each voxel/seed, MVPA components are computed using a Principal Component Decomposition of the between-subjects <br/> variability in seed-to-voxel connectivity maps. The resulting principal component scores serve as a multivariate representation <br/> of the functional connectivity between each voxel and the rest of the brain </HTML>','conn(''gui_analyses'',9);');
                    CONN_h.menus.m_analyses_00{3}=[];[CONN_h.menus.m_analyses_00{3}(1),CONN_h.menus.m_analyses_00{3}(2)]=conn_menu('checkbox',boffset+[.42,.5,.02,.04],'Normalization','','<HTML>(optional) computes normalized z-score measures <br/> - When selecting this option the distribution of the resulting voxel-level measures for each subject and condition is Gaussian with mean 0 and variance 1 <br/> - Uncheck this option to skip normalization (keep the original voxel-level values instead) </HTML>','conn(''gui_analyses'',3);');
                    CONN_h.menus.m_analyses_00{17}=[];[CONN_h.menus.m_analyses_00{17}(1),CONN_h.menus.m_analyses_00{17}(2)]=conn_menu('checkbox',boffset+[.42,.5,.02,.04],'Centering','','<HTML>(optional) centers MVPA components<br/> - When selecting this option the MVPA components have zero mean across all subjects/conditions (MVPA components defined using PCA of covariance in seed-to-voxel connectivity values across subjets) <br/> - Uncheck this option to skip centering (PCA decomposition uses second moment about zero instead of second moment about the mean) </HTML>','conn(''gui_analyses'',17);');
                    set([CONN_h.menus.m_analyses_00{3}(2) CONN_h.menus.m_analyses_00{17}(2)],'position',boffset+[.44,.5,.09,.04]);
                    if (isfield(CONN_h.menus.m_analyses.Y,'issurface')&&CONN_h.menus.m_analyses.Y.issurface)
                        [CONN_h.menus.m_analyses_00{10:15}]=deal([]);
                    else
                        CONN_h.menus.m_analyses_00{10}=conn_menu('frame2',boffset+[.55,.08,.43,.75],'Preview voxel-to-voxel analysis results');
                        CONN_h.menus.m_analyses_00{11}=conn_menu('listbox',boffset+[.565,.11,.075,.64],'Subjects','','Select subject to display','conn(''gui_analyses'',11);');
                        CONN_h.menus.m_analyses_00{12}=conn_menu('listbox',boffset+[.640,.11,.075,.64],'Conditions','','Select condition to display','conn(''gui_analyses'',12);');
                        CONN_h.menus.m_analyses_00{13}=conn_menu('popup',boffset+[.79,.78,.12,.05],'',{' '},'Select measure to display','conn(''gui_analyses'',13);');
                        pos=[.74,.15,.22,.63];
                        if any(CONN_x.Setup.steps([3])),
                            uicontrol('style','text','units','norm','position',boffset+[pos(1)+pos(3)-.170,pos(2)-1*.055,.070,.04],'string','threshold','fontname','default','fontsize',8+CONN_gui.font_offset,'backgroundcolor',CONN_gui.backgroundcolorA,'foregroundcolor',CONN_gui.fontcolorA,'tooltipstring','only results with absolute effect sizes above this threshold value are displayed');
                            CONN_h.menus.m_analyses_00{15}=conn_menu('slider',boffset+[pos(1)+pos(3)-0*.015,pos(2),.015,pos(4)],'','','z-slice','conn(''gui_analyses'',15);');
                            set(CONN_h.menus.m_analyses_00{15},'visible','off');
                            conn_menumanager('onregion',CONN_h.menus.m_analyses_00{15},1,boffset+pos+[0 0 .015 0]);
                            %CONN_h.menus.m_analyses_00{15}=uicontrol('style','slider','units','norm','position',boffset+[pos(1)+pos(3)-0*.015,pos(2),.015,pos(4)],'callback','conn(''gui_analyses'',15);','backgroundcolor',CONN_gui.backgroundcolorA);
                        end
                        CONN_h.menus.m_analyses_00{14}=conn_menu('image',boffset+pos,'');
                    end
                    
                    %set([CONN_h.menus.m_analyses_00{1}],'max',2);
                    set([CONN_h.menus.m_analyses_00{1},CONN_h.menus.m_analyses_00{2}],'max',2);
                    set(CONN_h.menus.m_analyses_00{1},'string',CONN_x.vvAnalyses.variables.names);
                    set(CONN_h.menus.m_analyses_00{2},'string',CONN_x.vvAnalyses.regressors.names);
                    conn_menumanager(CONN_h.menus.m_analyses_01,'on',1);
                    set([CONN_h.menus.m_analyses_00{11},CONN_h.menus.m_analyses_00{12},CONN_h.menus.m_analyses_00{13}],'max',1);
                    set(CONN_h.menus.m_analyses_00{11},'string',[repmat('Subject ',[CONN_x.Setup.nsubjects,1]),num2str((1:CONN_x.Setup.nsubjects)')]);
                    set(CONN_h.menus.m_analyses_00{12},'string',{CONN_x.Setup.conditions.names{1:end-1}},'value',1);
                    set(CONN_h.menus.m_analyses_00{13},'string',CONN_x.vvAnalyses.regressors.names,'value',1);
                    
                    if ~(isfield(CONN_h.menus.m_analyses.Y,'issurface')&&CONN_h.menus.m_analyses.Y.issurface)
                        try
                            CONN_h.menus.m_analyses.XS=spm_vol(deblank(CONN_x.Setup.structural{1}{1}{1}));
                        catch
                            CONN_h.menus.m_analyses.XS=spm_vol(fullfile(fileparts(which('spm')),'canonical','single_subj_T1.nii'));
                        end
                    end
                    if ~(isfield(CONN_h.menus.m_analyses.Y,'issurface')&&CONN_h.menus.m_analyses.Y.issurface)&&any(CONN_x.Setup.steps([3])),%~isfield(CONN_x.Setup,'doROIonly')||~CONN_x.Setup.doROIonly,
                        xyz=conn_convertcoordinates('idx2tal',prod(CONN_h.menus.m_analyses.Y.matdim.dim(1:2))*(CONN_h.menus.m_analyses.y.slice-1)+(1:prod(CONN_h.menus.m_analyses.Y.matdim.dim(1:2))),CONN_h.menus.m_analyses.Y.matdim.mat,CONN_h.menus.m_analyses.Y.matdim.dim);
                        CONN_h.menus.m_analyses.Xs=spm_get_data(CONN_h.menus.m_analyses.XS(1),pinv(CONN_h.menus.m_analyses.XS(1).mat)*xyz');
                        CONN_h.menus.m_analyses.Xs=permute(reshape(CONN_h.menus.m_analyses.Xs,CONN_h.menus.m_analyses.Y.matdim.dim(1:2)),[2,1,3]);
                        set(CONN_h.menus.m_analyses_00{15},'min',1,'max',CONN_h.menus.m_analyses.Y.matdim.dim(3),'sliderstep',min(.5,[1,10]/(CONN_h.menus.m_analyses.Y.matdim.dim(3)-1)),'value',CONN_h.menus.m_analyses.y.slice);
                        set(CONN_h.menus.m_analyses_00{14}.h10,'string','eps');
                    else
                        CONN_h.menus.m_analyses.y.slice=max(1,min(4,CONN_h.menus.m_analyses.y.slice));
                        set(CONN_h.menus.m_analyses_00{15},'visible','off');
                        conn_menumanager('onregionremove',CONN_h.menus.m_analyses_00{15});
                    end
                    model=1;

                else
                    switch(varargin{2}),
                        case 0,
                            str=conn_menumanager(CONN_h.menus.m_analyses_01,'string');
                            switch(str{1}),
                                case '>',
                                    ncovariates=get(CONN_h.menus.m_analyses_00{1},'value');
                                    for ncovariate=ncovariates(:)',
                                        if 1,%isempty(strmatch(CONN_x.vvAnalyses.variables.names{ncovariate},CONN_x.vvAnalyses.regressors.names,'exact'))||strcmp(CONN_x.vvAnalyses.variables.names{ncovariate},'other (Generalized Functional form)'),
                                            optionsnames=fieldnames(CONN_x.vvAnalyses.variables);
                                            for n1=1:numel(optionsnames),
                                                CONN_x.vvAnalyses.regressors.(optionsnames{n1}){end+1}=CONN_x.vvAnalyses.variables.(optionsnames{n1}){ncovariate};
                                            end
                                        end
                                    end
                                    set(CONN_h.menus.m_analyses_00{2},'string',CONN_x.vvAnalyses.regressors.names,'value',max(1,min(max(get(CONN_h.menus.m_analyses_00{2},'value')),length(CONN_x.vvAnalyses.regressors.names))));
                                    set(CONN_h.menus.m_analyses_00{13},'string',CONN_x.vvAnalyses.regressors.names,'value',max(1,min(max(get(CONN_h.menus.m_analyses_00{13},'value')),length(CONN_x.vvAnalyses.regressors.names))));
                                case '<',
                                    ncovariates=get(CONN_h.menus.m_analyses_00{2},'value');
                                    idx=setdiff(1:length(CONN_x.vvAnalyses.regressors.names),ncovariates);
                                    optionsnames=fieldnames(CONN_x.vvAnalyses.regressors);
                                    for n1=1:numel(optionsnames),
                                        CONN_x.vvAnalyses.regressors.(optionsnames{n1})={CONN_x.vvAnalyses.regressors.(optionsnames{n1}){idx}};
                                    end
                                    set(CONN_h.menus.m_analyses_00{2},'string',CONN_x.vvAnalyses.regressors.names,'value',max(1,min(max(ncovariates),length(CONN_x.vvAnalyses.regressors.names))));
                                    set(CONN_h.menus.m_analyses_00{13},'string',CONN_x.vvAnalyses.regressors.names,'value',max(1,min(max(get(CONN_h.menus.m_analyses_00{13},'value')),length(CONN_x.vvAnalyses.regressors.names))));
                            end
                            model=1;
                        case 1,
                            conn_menumanager(CONN_h.menus.m_analyses_01,'string',{'>'},'on',1);
                            set(CONN_h.menus.m_analyses_00{2},'value',[]);
                            set([CONN_h.menus.m_analyses_00{3},CONN_h.menus.m_analyses_00{17},CONN_h.menus.m_analyses_00{4},CONN_h.menus.m_analyses_00{5},CONN_h.menus.m_analyses_00{6},CONN_h.menus.m_analyses_00{7},CONN_h.menus.m_analyses_00{8}],'visible','off');%
                        case 2,
                            conn_menumanager(CONN_h.menus.m_analyses_01,'string',{'<'},'on',1);
                            set(CONN_h.menus.m_analyses_00{1},'value',[]);
                            set([CONN_h.menus.m_analyses_00{3},CONN_h.menus.m_analyses_00{17},CONN_h.menus.m_analyses_00{4},CONN_h.menus.m_analyses_00{5},CONN_h.menus.m_analyses_00{6},CONN_h.menus.m_analyses_00{7},CONN_h.menus.m_analyses_00{8},CONN_h.menus.m_analyses_00{9}],'visible','on');%,'backgroundcolor','k','foregroundcolor','w');%
                            % uncomment below to link the two "measure" menus 
                            %nregressors=get(CONN_h.menus.m_analyses_00{2},'value');
                            %if numel(nregressors)==1, 
                            %    set(CONN_h.menus.m_analyses_00{13},'value',nregressors); 
                            %    model=1;
                            %end
                        case 3,
                            nregressors=get(CONN_h.menus.m_analyses_00{2},'value');
                            value=get(CONN_h.menus.m_analyses_00{3}(1),'value');
                            for nregressor=nregressors(:)', CONN_x.vvAnalyses.regressors.norm{nregressor}=value; end
                            nview=get(CONN_h.menus.m_analyses_00{13},'value');
                            model=any(nregressors==nview);
                        case 4,
                            nregressors=get(CONN_h.menus.m_analyses_00{2},'value');
                            value=str2num(get(CONN_h.menus.m_analyses_00{4}(1),'string'));
                            if length(value)==1, for nregressor=nregressors(:)', CONN_x.vvAnalyses.regressors.localsupport{nregressor}=value; end; end
                            nview=get(CONN_h.menus.m_analyses_00{13},'value');
                            model=any(nregressors==nview);
                        case 5,
                            nregressors=get(CONN_h.menus.m_analyses_00{2},'value');
                            value=get(CONN_h.menus.m_analyses_00{5}(1),'value')-1;
                            if length(value)==1, for nregressor=nregressors(:)', CONN_x.vvAnalyses.regressors.global{nregressor}=value; end; end
                            nview=get(CONN_h.menus.m_analyses_00{13},'value');
                            model=any(nregressors==nview);
                        case 6,
                            nregressors=get(CONN_h.menus.m_analyses_00{2},'value');
                            value=get(CONN_h.menus.m_analyses_00{6}(1),'value')-1;
                            if length(value)==1, for nregressor=nregressors(:)', CONN_x.vvAnalyses.regressors.deriv{nregressor}=value; if CONN_x.vvAnalyses.regressors.deriv{nregressor}==1, CONN_x.vvAnalyses.regressors.dimensions_out{nregressor}=3; else CONN_x.vvAnalyses.regressors.dimensions_out{nregressor}=1; end; end; end
                            nview=get(CONN_h.menus.m_analyses_00{13},'value');
                            model=any(nregressors==nview);
                        case 7,
                            nregressors=get(CONN_h.menus.m_analyses_00{2},'value');
                            txt=deblank(get(CONN_h.menus.m_analyses_00{7}(1),'string'));
                            for nregressor=nregressors(:)', CONN_x.vvAnalyses.regressors.names{nregressor}=txt; end; 
                            set(CONN_h.menus.m_analyses_00{2},'string',CONN_x.vvAnalyses.regressors.names,'value',max(1,min(max(get(CONN_h.menus.m_analyses_00{2},'value')),length(CONN_x.vvAnalyses.regressors.names))));
                            set(CONN_h.menus.m_analyses_00{13},'string',CONN_x.vvAnalyses.regressors.names,'value',max(1,min(max(get(CONN_h.menus.m_analyses_00{13},'value')),length(CONN_x.vvAnalyses.regressors.names))));
                        case 8,
                            nregressors=get(CONN_h.menus.m_analyses_00{2},'value');
                            value=str2num(get(CONN_h.menus.m_analyses_00{8}(1),'string'));
                            if length(value)==1, for nregressor=nregressors(:)', CONN_x.vvAnalyses.regressors.dimensions_in{nregressor}=value; end; end
                            nview=get(CONN_h.menus.m_analyses_00{13},'value');
                            model=any(nregressors==nview);
                        case 9,
                            nregressors=get(CONN_h.menus.m_analyses_00{2},'value');
                            value=str2num(get(CONN_h.menus.m_analyses_00{9}(1),'string'));
                            if length(value)==1, for nregressor=nregressors(:)', CONN_x.vvAnalyses.regressors.dimensions_out{nregressor}=value; end; end
                            nview=get(CONN_h.menus.m_analyses_00{13},'value');
                            model=any(nregressors==nview);
                        case {11,12}
                            nsubs=get(CONN_h.menus.m_analyses_00{11},'value');
                            nconditions=get(CONN_h.menus.m_analyses_00{12},'value');
                            filepath=CONN_x.folders.preprocessing;
                            if any(CONN_x.Setup.steps([2,3])),%~isfield(CONN_x.Setup,'doROIonly')||~CONN_x.Setup.doROIonly,
                                filename=fullfile(filepath,['vvPC_Subject',num2str(nsubs,'%03d'),'_Condition',num2str(CONN_h.menus.m_analyses.icondition(nconditions),'%03d'),'.mat']);
                                CONN_h.menus.m_analyses.Y=conn_vol(filename);
                                filename=fullfile(filepath,['vvPCeig_Subject',num2str(nsubs,'%03d'),'_Condition',num2str(CONN_h.menus.m_analyses.icondition(nconditions),'%03d'),'.mat']);
                                CONN_h.menus.m_analyses.y.data=load(filename,'D');
                            end
                            if ~(isfield(CONN_h.menus.m_analyses.Y,'issurface')&&CONN_h.menus.m_analyses.Y.issurface)
                                try
                                    CONN_h.menus.m_analyses.XS=spm_vol(deblank(CONN_x.Setup.structural{nsubs}{1}{1})); %note: displaying first-session structural here
                                catch
                                    CONN_h.menus.m_analyses.XS=spm_vol(fullfile(fileparts(which('spm')),'canonical','single_subj_T1.nii'));
                                end
                            end
                            if ~(isfield(CONN_h.menus.m_analyses.Y,'issurface')&&CONN_h.menus.m_analyses.Y.issurface)&&any(CONN_x.Setup.steps([3])),%~isfield(CONN_x.Setup,'doROIonly')||~CONN_x.Setup.doROIonly,
                                xyz=conn_convertcoordinates('idx2tal',prod(CONN_h.menus.m_analyses.Y.matdim.dim(1:2))*(CONN_h.menus.m_analyses.y.slice-1)+(1:prod(CONN_h.menus.m_analyses.Y.matdim.dim(1:2))),CONN_h.menus.m_analyses.Y.matdim.mat,CONN_h.menus.m_analyses.Y.matdim.dim);
                                CONN_h.menus.m_analyses.Xs=spm_get_data(CONN_h.menus.m_analyses.XS(1),pinv(CONN_h.menus.m_analyses.XS(1).mat)*xyz');
                                CONN_h.menus.m_analyses.Xs=permute(reshape(CONN_h.menus.m_analyses.Xs,CONN_h.menus.m_analyses.Y.matdim.dim(1:2)),[2,1,3]);
                            else
                                CONN_h.menus.m_analyses.y.slice=max(1,min(4,CONN_h.menus.m_analyses.y.slice));
                                set(CONN_h.menus.m_analyses_00{15},'visible','off');
                                conn_menumanager('onregionremove',CONN_h.menus.m_analyses_00{15});
                            end
                            model=1;
                        case 13
                            model=1;
                        case 15
                            CONN_h.menus.m_analyses.y.slice=round(get(CONN_h.menus.m_analyses_00{15},'value'));
%                             [CONN_h.menus.m_analyses.y.data,CONN_h.menus.m_analyses.y.idx]=conn_get_slice(CONN_h.menus.m_analyses.Y,CONN_h.menus.m_analyses.y.slice);
                            xyz=conn_convertcoordinates('idx2tal',prod(CONN_h.menus.m_analyses.Y.matdim.dim(1:2))*(CONN_h.menus.m_analyses.y.slice-1)+(1:prod(CONN_h.menus.m_analyses.Y.matdim.dim(1:2))),CONN_h.menus.m_analyses.Y.matdim.mat,CONN_h.menus.m_analyses.Y.matdim.dim);
                            CONN_h.menus.m_analyses.Xs=spm_get_data(CONN_h.menus.m_analyses.XS(1),pinv(CONN_h.menus.m_analyses.XS(1).mat)*xyz');
                            CONN_h.menus.m_analyses.Xs=permute(reshape(CONN_h.menus.m_analyses.Xs,CONN_h.menus.m_analyses.Y.matdim.dim(1:2)),[2,1,3]);
                            model=1;
                        case 17,
                            nregressors=get(CONN_h.menus.m_analyses_00{2},'value');
                            value=get(CONN_h.menus.m_analyses_00{17}(1),'value');
                            for nregressor=nregressors(:)', CONN_x.vvAnalyses.regressors.norm{nregressor}=value; end
                            nview=get(CONN_h.menus.m_analyses_00{13},'value');
                            model=any(nregressors==nview);
                    end
                end
                nsubs=get(CONN_h.menus.m_analyses_00{11},'value');
                nregressors=min(get(CONN_h.menus.m_analyses_00{2},'value'),numel(get(CONN_h.menus.m_analyses_00{2},'string')));
                nview=get(CONN_h.menus.m_analyses_00{13},'value');
                nmeasure=nview;
%                 [CONN_h.menus.m_analyses.X,CONN_h.menus.m_analyses.select]=conn_designmatrix(CONN_x.Analyses(ianalysis).regressors,CONN_h.menus.m_analyses.X1,[],{nregressors,nview});
%                 if isempty(nregressors), conn_menu('update',CONN_h.menus.m_analyses_00{3},[]);
%                 else  conn_menu('update',CONN_h.menus.m_analyses_00{3},CONN_h.menus.m_analyses.X); end
                if ~isempty(nregressors)&&all(nregressors>0),
                    temp=cat(1,CONN_x.vvAnalyses.regressors.localsupport{nregressors});
                    if length(temp)==1 || ~any(any(diff(temp,1,1))),set(CONN_h.menus.m_analyses_00{4}(1),'string',num2str(CONN_x.vvAnalyses.regressors.localsupport{nregressors(1)}));
                    else  set(CONN_h.menus.m_analyses_00{4}(1),'string','MULTIPLE VALUES'); end
                    temp=cat(1,CONN_x.vvAnalyses.regressors.norm{nregressors});
                    if size(temp,1)==1 || ~any(any(diff(temp,1,1))), set([CONN_h.menus.m_analyses_00{3} CONN_h.menus.m_analyses_00{17}],'value',CONN_x.vvAnalyses.regressors.norm{nregressors(1)},'visible','on');
                    else set([CONN_h.menus.m_analyses_00{3} CONN_h.menus.m_analyses_00{17}],'visible','off'); end
                    temp=cat(1,CONN_x.vvAnalyses.regressors.global{nregressors});
                    if all(cell2mat(CONN_x.vvAnalyses.regressors.global(nregressors))==0),set(CONN_h.menus.m_analyses_00{4},'visible','on');
                    else set(CONN_h.menus.m_analyses_00{4},'visible','off'); end
                    if 0,%size(temp,1)==1 || ~any(any(diff(temp,1,1))),set(CONN_h.menus.m_analyses_00{5}(1),'value',1+CONN_x.vvAnalyses.regressors.global{nregressors(1)}(1));set(CONN_h.menus.m_analyses_00{5},'visible','on');
                    else  set(CONN_h.menus.m_analyses_00{5},'visible','off'); end
                    temp=cat(1,CONN_x.vvAnalyses.regressors.deriv{nregressors});
                    if 0,%size(temp,1)==1 || ~any(any(diff(temp,1,1))),set(CONN_h.menus.m_analyses_00{6}(1),'value',1+CONN_x.vvAnalyses.regressors.deriv{nregressors(1)}(1));set(CONN_h.menus.m_analyses_00{6},'visible','on');
                    else  set(CONN_h.menus.m_analyses_00{6},'visible','off'); end
                    temp=strvcat(CONN_x.vvAnalyses.regressors.names{nregressors});
                    if size(temp,1)==1 || ~any(any(diff(temp,1,1))),set(CONN_h.menus.m_analyses_00{7}(1),'string',deblank(CONN_x.vvAnalyses.regressors.names{nregressors(1)}(1,:)));
                    else  set(CONN_h.menus.m_analyses_00{7}(1),'string','MULTIPLE VALUES'); end
                    temp=cat(1,CONN_x.vvAnalyses.regressors.dimensions_in{nregressors});
                    if length(temp)==1 || ~any(any(diff(temp,1,1))),set(CONN_h.menus.m_analyses_00{8}(1),'string',num2str(CONN_x.vvAnalyses.regressors.dimensions_in{nregressors(1)}));
                    else  set(CONN_h.menus.m_analyses_00{8}(1),'string','MULTIPLE VALUES'); end
                    temp=cat(1,CONN_x.vvAnalyses.regressors.dimensions_out{nregressors});
                    if length(temp)==1 || ~any(any(diff(temp,1,1))),set(CONN_h.menus.m_analyses_00{9}(1),'string',num2str(CONN_x.vvAnalyses.regressors.dimensions_out{nregressors(1)}));
                    else  set(CONN_h.menus.m_analyses_00{9}(1),'string','MULTIPLE VALUES'); end
                    temp=cat(1,CONN_x.vvAnalyses.regressors.measuretype{nregressors});
                    if any(temp>1), set([CONN_h.menus.m_analyses_00{3},CONN_h.menus.m_analyses_00{4},CONN_h.menus.m_analyses_00{5},CONN_h.menus.m_analyses_00{6}],'visible','off'); end
                    if any(temp==1), set([CONN_h.menus.m_analyses_00{17},CONN_h.menus.m_analyses_00{9}],'visible','off'); end
                else
                    set([CONN_h.menus.m_analyses_00{3},CONN_h.menus.m_analyses_00{17},CONN_h.menus.m_analyses_00{4},CONN_h.menus.m_analyses_00{5},CONN_h.menus.m_analyses_00{6},CONN_h.menus.m_analyses_00{7},CONN_h.menus.m_analyses_00{8},CONN_h.menus.m_analyses_00{9}],'visible','off');%
                end
                value=get(CONN_h.menus.m_analyses_00{13},'value');if isempty(value),set(CONN_h.menus.m_analyses_00{13},'value',1); end

                if model&&any(CONN_x.Setup.steps(3))&&~isempty(nmeasure),%~isfield(CONN_x.Setup,'doROIonly')||~CONN_x.Setup.doROIonly,
                    measures=CONN_x.vvAnalyses.regressors;
                    if numel(measures.names)>0
                        if measures.measuretype{nmeasure}==1
                            if ~(isfield(CONN_h.menus.m_analyses.Y,'issurface')&&CONN_h.menus.m_analyses.Y.issurface)
                                set(CONN_h.screen.hfig,'pointer','watch');drawnow
                                d=conn_v2v('compute_slice',measures,nmeasure,CONN_h.menus.m_analyses.Y,CONN_h.menus.m_analyses.y.data.D,CONN_h.menus.m_analyses.y.slice);
                                set(CONN_h.screen.hfig,'pointer','arrow');
                                %                         t1=zeros(CONN_h.menus.m_analyses.Y(1).dim(1:2));
                                %                         t2=0+zeros(CONN_h.menus.m_analyses.Y(1).dim(1:2));
                                t1=d;
                                t1=permute(t1,[2,1,3]);
                                t2=abs(d);
                                t2=permute(t2,[2,1,3]);
                                set(CONN_h.menus.m_analyses_00{14}.h9,'string',num2str(max(t2(:))));
                                conn_menu('update',CONN_h.menus.m_analyses_00{14},{CONN_h.menus.m_analyses.Xs,t1,t2},{CONN_h.menus.m_analyses.Y.matdim,CONN_h.menus.m_analyses.y.slice});
                                conn_menu('updatecscale',[],[],CONN_h.menus.m_analyses_00{14}.h9);
                                conn_menu('updatethr',[],[],CONN_h.menus.m_analyses_00{14}.h10);
                            else
                                conn_menu('update',CONN_h.menus.m_analyses_00{14},[]);
                                % preview not available yet... (need to optimize code below for speed in low-res case)
%                                 params=conn_v2v('compute_start',measures,nmeasure,Y1.matdim.mat,issurface);
%                                 for ndim=1:min(params.dimensions_in,Y1.size.Nt),
%                                     y1=conn_get_time(Y1,ndim);
%                                     params=conn_v2v('compute_step',params,y1,D1.D(ndim));
%                                 end
%                                 d=conn_v2v('compute_end',params);
%                                 if iscell(d)
%                                     dsum=0;
%                                     for nout=1:numel(d), dsum=dsum+abs(d{nout}).^2; end
%                                     dsum=sqrt(abs(dsum));
%                                 end
                            end
                        else
                            conn_menu('update',CONN_h.menus.m_analyses_00{14},[]);
                        end
                    end
                end
            else, %DYNAMIC CONNECTIVITY
                boffset=[.07 .08 0 0];
                if nargin<2, 
                    if ~any(CONN_x.Setup.steps(state)), uiwait(errordlg('Dynamic connectivity analyses not enabled in Setup.Options. Please enable this option before continuing','')); conn gui_setup; return; end
                    conn_menumanager clf;
                    conn_menuframe;
                    tstate=conn_menumanager(CONN_h.menus.m0,'state'); tstate(:)=0;tstate(3)=1; conn_menumanager(CONN_h.menus.m0,'state',tstate);
                    conn_menumanager([CONN_h.menus.m_analyses_05,CONN_h.menus.m_analyses_03,CONN_h.menus.m_setup_06,CONN_h.menus.m0],'on',1);
                    conn_menu('nullstr',{'No data','to display'});
                    
                    conn_menu('frame',boffset+[.095,.02,.35,.79],'');%'DYNAMIC CONNECTIVITY ANALYSIS');
                    [nill,CONN_h.menus.m_analyses_00{16}]=conn_menu('text',boffset+[.105,.70,.26,.05],'Dynamic connectivity seeds/sources:');
                    set(CONN_h.menus.m_analyses_00{16},'horizontalalignment','left');
                    CONN_h.menus.m_analyses_00{1}=conn_menu('listbox',boffset+[.105,.35,.145,.35],'all ROIs','','List of all seeds/ROIs','conn(''gui_analyses'',1);');
                    CONN_h.menus.m_analyses_00{2}=conn_menu('listbox',boffset+[.27,.35,.145,.35],'Sources','','<HTML>List of seeds/ROIs to be included in this analysis  <br/> - This analysis will explore the ROI-to-ROI connectivity matrix among the selected ROIs and return a number of data-driven <br/>temporal factors characterizing the largest temporal modulation effects observed in this connectivity matrix across time</HTML>','conn(''gui_analyses'',2);');
                    [nill,CONN_h.menus.m_analyses_00{16}]=conn_menu('text',boffset+[.105,.25,.26,.04],'Analysis options:');
                    set(CONN_h.menus.m_analyses_00{16},'horizontalalignment','left');
                    CONN_h.menus.m_analyses_00{4}=conn_menu('edit',boffset+[.105,.20,.12,.04],'Number of dynamic factors','','Determine the number of data-driven temporal modulation factors to be estimated','conn(''gui_analyses'',4);');
                    CONN_h.menus.m_analyses_00{5}=conn_menu('popup',boffset+[.105,.12,.12,.04],'Condition',CONN_x.Setup.conditions.names(1:end-1),'<HTML>Determine the span of the BOLD timeseries used in these analyses <br/> - Select ''rest'' condition to use entire BOLD timeseries</HTML>','conn(''gui_analyses'',5);');
                    CONN_h.menus.m_analyses_00{6}=conn_menu('edit',boffset+[.105,.04,.12,.04],'Low-pass filter (Hz)','','<HTML>Temporal modulation Low-Pass filter threshold (in Hz)<br/> - Leave empty or set to <i>inf</i> for no filtering</HTML>','conn(''gui_analyses'',6);');
                    CONN_h.menus.m_analyses_00{9}=conn_menu('checkbox',boffset+[.255,.22,.02,.03],'Estimate Dynamic loadings','','<HTML>Dynamic factor loadings represent ROI-to-ROI connectivity matrices characterizing the observed modulatory effects <br/> - Factor loadings are estimated using a PPI model with the estimated factors timeseries as modulatory variable <br/> - Additional first-level ROI-to-ROI and seed-to-voxel analyses (using these or other ROIs) can be performed at a later time by selecting analysis type <i>temporal-modulation effects (Dynamic FC)</i> in </i> first-level analyses</i></HTML>','conn(''gui_analyses'',9);');
                    CONN_h.menus.m_analyses_00{10}=conn_menu('checkbox',boffset+[.255,.17,.02,.03],'Estimate Dynamic scores','','<HTML>Dynamic factor scores represent average/baseline and variability/modulation-strength of each factor timeseries for each subject&condition</HTML>','conn(''gui_analyses'',10);');
                    CONN_h.menus.m_analyses_00{11}=conn_menu('checkbox',boffset+[.255,.12,.02,.03],'Export Factor timeseries','','Export the estimated dynamic factor timeseries as first-level covariates for additional analyses','conn(''gui_analyses'',11);');
                    for n=1:3, set(CONN_h.menus.m_analyses_00{8+n},'value',CONN_x.dynAnalyses.output(n)); end
                     
                    if ~isfield(CONN_x.dynAnalyses.variables,'names')||isempty(CONN_x.dynAnalyses.variables.names), 
                        CONN_x.dynAnalyses.variables.names=CONN_x.Analyses(1).variables.names;
                        CONN_x.dynAnalyses.regressors.names=CONN_x.Analyses(1).regressors.names;
                    end
                    set([CONN_h.menus.m_analyses_00{1},CONN_h.menus.m_analyses_00{2}],'max',2);
                    tnames=CONN_x.dynAnalyses.variables.names;
                    tnames(ismember(CONN_x.dynAnalyses.variables.names,CONN_x.dynAnalyses.regressors.names))=cellfun(@(x)[CONN_gui.parse_html{1},x,CONN_gui.parse_html{2}],tnames(ismember(CONN_x.dynAnalyses.variables.names,CONN_x.dynAnalyses.regressors.names)),'uni',0);
                    set(CONN_h.menus.m_analyses_00{1},'string',tnames);
                    set(CONN_h.menus.m_analyses_00{2},'string',CONN_x.dynAnalyses.regressors.names);
                    conn_menumanager(CONN_h.menus.m_analyses_01b,'on',1);
                    set([CONN_h.menus.m_analyses_00{1},CONN_h.menus.m_analyses_00{2}],'value',[]);
                    set(CONN_h.menus.m_analyses_00{4},'string',num2str(CONN_x.dynAnalyses.Ncomponents));
                    set(CONN_h.menus.m_analyses_00{5},'value',CONN_x.dynAnalyses.condition);
                    set(CONN_h.menus.m_analyses_00{6},'string',mat2str(CONN_x.dynAnalyses.filter));
                    if any(arrayfun(@(n)isempty(dir(fullfile(CONN_x.folders.preprocessing,['ROI_Subject',num2str(n,'%03d'),'_Condition',num2str(0,'%03d'),'.mat']))),1:CONN_x.Setup.nsubjects)), uiwait(errordlg('Run first the Denoising step by pressing "Done" in the Denoising tab','Data not prepared for analyses')); conn gui_preproc; return; end
                else
                    switch(varargin{2}),
                        case 0,
                            str=conn_menumanager(CONN_h.menus.m_analyses_01b,'string');
                            switch(str{1}),
                                case '>',
                                    ncovariates=get(CONN_h.menus.m_analyses_00{1},'value');
                                    for ncovariate=ncovariates(:)',
                                        if isempty(strmatch(CONN_x.dynAnalyses.variables.names{ncovariate},CONN_x.dynAnalyses.regressors.names,'exact')),
                                            CONN_x.dynAnalyses.regressors.names{end+1}=CONN_x.dynAnalyses.variables.names{ncovariate};
                                        end
                                    end
                                    set(CONN_h.menus.m_analyses_00{2},'string',CONN_x.dynAnalyses.regressors.names);
                                    tnames=CONN_x.dynAnalyses.variables.names;
                                    tnames(ismember(CONN_x.dynAnalyses.variables.names,CONN_x.dynAnalyses.regressors.names))=cellfun(@(x)[CONN_gui.parse_html{1},x,CONN_gui.parse_html{2}],tnames(ismember(CONN_x.dynAnalyses.variables.names,CONN_x.dynAnalyses.regressors.names)),'uni',0);
                                    set(CONN_h.menus.m_analyses_00{1},'string',tnames);
                                case '<',
                                    ncovariates=get(CONN_h.menus.m_analyses_00{2},'value');
                                    idx=setdiff(1:length(CONN_x.dynAnalyses.regressors.names),ncovariates);
                                    CONN_x.dynAnalyses.regressors.names={CONN_x.dynAnalyses.regressors.names{idx}};
                                    set(CONN_h.menus.m_analyses_00{2},'string',CONN_x.dynAnalyses.regressors.names,'value',min(max(ncovariates),length(CONN_x.dynAnalyses.regressors.names)));
                                    tnames=CONN_x.dynAnalyses.variables.names;
                                    tnames(ismember(CONN_x.dynAnalyses.variables.names,CONN_x.dynAnalyses.regressors.names))=cellfun(@(x)[CONN_gui.parse_html{1},x,CONN_gui.parse_html{2}],tnames(ismember(CONN_x.dynAnalyses.variables.names,CONN_x.dynAnalyses.regressors.names)),'uni',0);
                                    set(CONN_h.menus.m_analyses_00{1},'string',tnames);
                            end
                            model=1;
                        case 1,
                            conn_menumanager(CONN_h.menus.m_analyses_01b,'string',{'>'},'on',1);
                            set(CONN_h.menus.m_analyses_00{2},'value',[]);
                        case 2,
                            conn_menumanager(CONN_h.menus.m_analyses_01b,'string',{'<'},'on',1);
                            set(CONN_h.menus.m_analyses_00{1},'value',[]);
                        case 4,
                            nregressors=get(CONN_h.menus.m_analyses_00{2},'value');
                            value=str2num(get(CONN_h.menus.m_analyses_00{4},'string'));
                            if length(value)==1, CONN_x.dynAnalyses.Ncomponents=round(max(0,min(inf,value))); end
                        case 6,
                            temp=str2num(get(CONN_h.menus.m_analyses_00{6},'string'));
                            if numel(temp)==1||isempty(temp), CONN_x.dynAnalyses.filter=temp; end
                            set(CONN_h.menus.m_analyses_00{6},'string',mat2str(CONN_x.dynAnalyses.filter));
                        case 9,
                            val=get(CONN_h.menus.m_analyses_00{9},'value');
                            CONN_x.dynAnalyses.output(1)=val;
                        case 10,
                            val=get(CONN_h.menus.m_analyses_00{10},'value');
                            CONN_x.dynAnalyses.output(2)=val;
                        case 11,
                            val=get(CONN_h.menus.m_analyses_00{11},'value');
                            CONN_x.dynAnalyses.output(3)=val;
                    end
                end
                nregressors=get(CONN_h.menus.m_analyses_00{2},'value');
                set(CONN_h.menus.m_analyses_00{4},'string',num2str(CONN_x.dynAnalyses.Ncomponents));
            end
			
		case 'gui_analyses_done',
			if isempty(CONN_x.filename), conn gui_setup_save; end
            tsteps=CONN_x.Setup.steps(1:3);
            switch(CONN_x.Analyses(CONN_x.Analysis).type)
                case 1, tsteps=[1 0 0]; 
                case 2, tsteps=[0 1 0];
                case 3, tsteps=[1 1 0]; 
            end
            if ~ischar(CONN_x.Analyses(CONN_x.Analysis).modulation)&&CONN_x.Analyses(CONN_x.Analysis).modulation>0&&~isempty(CONN_x.Analyses(CONN_x.Analysis).conditions), condsoption=find(ismember(CONN_x.Setup.conditions.names(1:end-1),CONN_x.Analyses(CONN_x.Analysis).conditions)); %gPPI conditions
            else condsoption=true;
            end
            if conn_questdlg('Ready to run First-level Analysis processing pipeline',false,tsteps,condsoption,[],true);
                conn_menumanager clf;
                conn_menuframe;
                conn_menumanager([CONN_h.menus.m_setup_06,CONN_h.menus.m0],'on',1);
                if CONN_x.gui.parallel~=0, 
                    if CONN_x.gui.parallel>0, conn_jobmanager('options','profile',CONN_x.gui.parallel); end; 
                    conn save;
                    conn_jobmanager('submit','analyses_gui_seed',[],CONN_x.gui,CONN_x.Analysis);
                else conn_process('analyses_gui_seed',CONN_x.Analysis);
                end
                CONN_x.gui=1;
                conn gui_setup_save;
                if ~conn_projectmanager('ispending'), conn gui_results; end
            end

		case 'gui_analyses_done_vv',
			if isempty(CONN_x.filename), conn gui_setup_save; end
            tsteps=[0 0 1]; 
            if conn_questdlg('Ready to run Voxel-to-Voxel processing pipeline',false,tsteps,[],[],true);
                conn_menumanager clf;
                conn_menuframe;
                conn_menumanager([CONN_h.menus.m_setup_06,CONN_h.menus.m0],'on',1);
                if CONN_x.gui.parallel~=0, 
                    if CONN_x.gui.parallel>0, conn_jobmanager('options','profile',CONN_x.gui.parallel); end; 
                    conn save;
                    conn_jobmanager('submit','analyses_gui_vv',[],CONN_x.gui);
                else conn_process('analyses_gui_vv');
                end
                CONN_x.gui=1;
                conn gui_setup_save;
                if ~conn_projectmanager('ispending'), conn gui_results; end
            end

		case 'gui_analyses_done_dyn',
			if isempty(CONN_x.filename), conn gui_setup_save; end
            tsteps=[0 0 0 1]; 
            condsoption=false;
            if CONN_x.dynAnalyses.output(1), condsoption=CONN_x.dynAnalyses.condition; end
            if conn_questdlg('Ready to run Dynamic connectivity processing pipeline',false,tsteps,condsoption);
                conn_menumanager clf;
                conn_menuframe;
                conn_menumanager([CONN_h.menus.m_setup_06,CONN_h.menus.m0],'on',1);
                conn_process('analyses_gui_dyn');
                CONN_x.gui=1;
                conn gui_setup_save;
                conn gui_results_dyn_factors;
                %if CONN_x.dynAnalyses.output(1), conn gui_results_dyn_loadings;
                %elseif CONN_x.dynAnalyses.output(2), conn gui_results_dyn_scores;
                %end
            end
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%			
        case 'gui_resultsgo'
            state=varargin{2};
            tstate=conn_menumanager(CONN_h.menus.m_results_03,'state'); tstate(:)=0;tstate(state)=1; conn_menumanager(CONN_h.menus.m_results_03,'state',tstate); 
            conn gui_results;
        case {'gui_results','gui_results_dyn','gui_results_dyn_loadings','gui_results_dyn_scores','gui_results_dyn_factors'}
            CONN_x.gui=1;
			model=0;modelroi=0;
            boffset=[.05 .00 0 0];
            %if ~isfield(CONN_x.Setup,'normalized'), CONN_x.Setup.normalized=1; end
            if ~isfield(CONN_x,'Analysis'), CONN_x.Analysis=1; end
            ianalysis=max(1,CONN_x.Analysis);
            if ~isfield(CONN_x.Analyses(ianalysis),'name'),CONN_x.Analyses(ianalysis).name='ANALYSIS_01'; end
            stateb=0;
            state=find(conn_menumanager(CONN_h.menus.m_results_03,'state'));
            if state==4||strcmp(lower(varargin{1}),'gui_results_dyn')||strcmp(lower(varargin{1}),'gui_results_dyn_loadings')||strcmp(lower(varargin{1}),'gui_results_dyn_scores')||strcmp(lower(varargin{1}),'gui_results_dyn_factors')
                state=4;
                tstate=find(conn_menumanager(CONN_h.menus.m_results_03a,'state'));
                if strcmp(lower(varargin{1}),'gui_results_dyn_factors')
                    tstate=zeros(size(conn_menumanager(CONN_h.menus.m_results_03a,'state')));tstate(1)=1;
                    conn_menumanager(CONN_h.menus.m_results_03a,'state',tstate);
                    tstate=1;
                elseif strcmp(lower(varargin{1}),'gui_results_dyn_loadings')
                    tstate=zeros(size(conn_menumanager(CONN_h.menus.m_results_03a,'state')));tstate(2)=1;
                    conn_menumanager(CONN_h.menus.m_results_03a,'state',tstate);
                    tstate=2;
                elseif strcmp(lower(varargin{1}),'gui_results_dyn_scores')
                    tstate=zeros(size(conn_menumanager(CONN_h.menus.m_results_03a,'state')));tstate(3)=1;
                    conn_menumanager(CONN_h.menus.m_results_03a,'state',tstate);
                    tstate=3;
                end
                stateb=tstate;
                if ~isfield(CONN_x.dynAnalyses,'sources')||isempty(CONN_x.dynAnalyses.sources), uiwait(errordlg('No Dynamic FC analyses computed. Select Dynamic FC in ''Setup->Options'' and run ''first-level Analyses->Dyn FC'' step','')); return; end
                if tstate==2, 
                    txt={CONN_x.Analyses(:).name};
                    dynanalyses=cellfun(@(x)~isempty(regexp(x,'^Dynamic factor .*\d+$')),txt);
                    if ~any(dynanalyses),  uiwait(errordlg('No Dynamic factor loadings computed. Re-run Dynamic analyses in ''first-level Analyses->Dyn FC'' to continue','')); return; end
                    state=1; 
                    if ianalysis>numel(dynanalyses)||~dynanalyses(ianalysis), ianalysis=find(dynanalyses,1); CONN_x.Analysis=ianalysis; end
                elseif tstate==3
                    txt=CONN_x.Setup.l2covariates.names(1:end-1);
                    dyneffects=find(cellfun(@(x)~isempty(regexp(x,'^Dynamic ')),txt)); 
                    if ~any(dyneffects),  uiwait(errordlg('No Dynamic factor scores computed. Re-run Dynamic analyses in ''first-level Analyses->Dyn FC'' to continue','')); return; end
                end
                tstate=zeros(size(conn_menumanager(CONN_h.menus.m_results_03,'state')));tstate(4)=1;
                conn_menumanager(CONN_h.menus.m_results_03,'state',tstate); 
            else
                if any(state==[1 2])
                    txt={CONN_x.Analyses(:).name};
                    dynanalyses=cellfun(@(x)~isempty(regexp(x,'^Dynamic factor .*\d+$')),txt);
                    if ianalysis>numel(dynanalyses)||dynanalyses(ianalysis), ianalysis=find(~dynanalyses,1); CONN_x.Analysis=ianalysis; end
                end
            end
            if isempty(CONN_x.Analyses(ianalysis).type), okstate=[true,true,true,true]; 
            else okstate=[any(CONN_x.Analyses(ianalysis).type==[1,3]),any(CONN_x.Analyses(ianalysis).type==[2,3]),true,true]; end
            okstate=CONN_x.Setup.steps&okstate;
            if ~okstate(state)
                %dynanalyses=~isempty(regexp(CONN_x.Setup.l2covariates.names(ianalysis),'^Dynamic factor .*\d+$'));
                %state=find(okstate&[~dynanalyses ~dynanalyses dynanalyses dynanalyses],1,'first');
                state=find(okstate,1,'first');
                if isempty(state), uiwait(errordlg('No matching analysis computed. Select analysis options in ''Setup->Options'' to perform additional analyses','')); conn gui_setup; return; end
                tstate=zeros(size(conn_menumanager(CONN_h.menus.m_results_03,'state')));tstate(state)=1;
                conn_menumanager(CONN_h.menus.m_results_03,'state',tstate); 
            end
            if nargin<2,
                %if ~any(CONN_x.Setup.steps([1,2])), uiwait(errordlg('No seed-to-voxel or ROI-to-ROI analyses computed. Select these options in ''Setup->Options'' to perform additional analyses','')); conn gui_setup; return; end
                conn_menumanager clf;
                conn_menuframe;
				tstate=conn_menumanager(CONN_h.menus.m0,'state'); tstate(:)=0;tstate(4)=1; conn_menumanager(CONN_h.menus.m0,'state',tstate); 
                conn_menumanager([CONN_h.menus.m_setup_06,CONN_h.menus.m_results_03,CONN_h.menus.m0],'on',1);
                conn_menu('nullstr',{'Preview not','available'});
				%conn_menumanager([CONN_h.menus.m0],'on',1);
                ok=true;
                if CONN_x.Setup.nsubjects==1&&state~=4, 
                    uiwait(warndlg({'Single-subject second-level analyses not supported (only population-level inferences via random-effect analyses available)','Please add more subjects before proceeding to the Results tab'},'')); 
                    ok=false;
                end
                switch(state)
                    case 1, if ok, conn_menumanager([CONN_h.menus.m_results_04],'on',1); end
                        if stateb, conn_menumanager(CONN_h.menus.m_results_03a,'on',1); end
                        dp1=-.025;dp2=.27;
                    case 2, if ok, conn_menumanager([CONN_h.menus.m_results_05],'on',1); end
                        dp1=.25;dp2=0;
                    case 3, if ok, conn_menumanager([CONN_h.menus.m_results_06],'on',1); end
                        dp1=.25;dp2=0;
                    case 4, conn_menumanager(CONN_h.menus.m_results_03a,'on',1);
                end
                if state==1||state==2
                    txt={CONN_x.Analyses(:).name};
                    txt_ext={' (R2R)',' (S2V)',' (S2V & R2R)'};
                    if stateb, CONN_h.menus.m_results.shownanalyses=find(cellfun(@(x)~isempty(regexp(x,'^Dynamic factor .*\d+$')),txt)); 
                    else       CONN_h.menus.m_results.shownanalyses=find(cellfun(@(x)isempty(regexp(x,'^Dynamic factor .*\d+$')),txt)); 
                    end
                    try, txt=cellfun(@(a,b)[a b],txt,txt_ext([CONN_x.Analyses(:).type]),'uni',0); end
                    [ok1,tempanalyses]=ismember(ianalysis,CONN_h.menus.m_results.shownanalyses);
                    if ~ok1, CONN_x.Analysis=1; error('Analysis not ready'); end
                    %CONN_h.menus.m_results_00{20}=uicontrol('units','norm','position',[2.1*.91/4,.895,(.91-3*.91/4)*.8,.05],'style','popupmenu','string',txt,'fontsize',8+CONN_gui.font_offset,'value',ianalysis,'backgroundcolor','k','foregroundcolor','w','callback','conn(''gui_results'',20);','tooltipstring','Select first-level analysis set');
                    CONN_h.menus.m_results_00{20}=conn_menu('popup2',[.005,.75,.125,.04],'Analysis name:',txt(CONN_h.menus.m_results.shownanalyses),'<HTML>First-level analysis name <br/> - Select first-level analysis set</HTML>','conn(''gui_results'',20);');
                    %CONN_h.menus.m_results_00{20}=conn_menu('popup2',[boffset(1)+.095,boffset(2)+.84,.315,.04],'',txt(CONN_h.menus.m_results.shownanalyses),'<HTML>First-level analysis name <br/> - Select first-level analysis set</HTML>','conn(''gui_results'',20);');
                    set(CONN_h.menus.m_results_00{20},'value',tempanalyses);%,'fontsize',9+CONN_gui.font_offset);%,'fontweight','bold');
                end
				if (state==1||state==2) && (~isfield(CONN_x.Analyses(ianalysis),'sources')||isempty(CONN_x.Analyses(ianalysis).sources)), uiwait(errordlg('Run first the first-level Analysis step by pressing "Done" in the Seed-to-Voxel/ROI-to-ROI Analysis tab','Data not prepared for analyses')); return; end %conn gui_analyses; return; end
				if (state==3) && (~isfield(CONN_x.vvAnalyses,'measures')||isempty(CONN_x.vvAnalyses.measures)), uiwait(errordlg('Run first the first-level Analysis step by pressing "Done" in the Voxel-to-Voxel Analysis tab','Data not prepared for analyses')); return; end %conn gui_analyses; return; end
				if (state==4) && (~isfield(CONN_x.dynAnalyses,'sources')||isempty(CONN_x.dynAnalyses.sources)), uiwait(errordlg('Run first the first-level Analysis step by pressing "Done" in the Dynamic FC tab','Data not prepared for analyses')); return; end %conn gui_analyses; return; end
                if ~isfield(CONN_x,'Results')||~isfield(CONN_x.Results,'xX'), CONN_x.Results.xX=[]; end

                if state==4
                    if stateb==1
                        conn_dynexplore;
                        return;
                    elseif stateb==3
                        icovariates=find(cellfun(@(x)~isempty(regexp(x,'^Dynamic ')),CONN_x.Setup.l2covariates.names));
                        conn_calculator(icovariates);
                        return
                    end
                else 
                    if state==1, conn_menu('frame',boffset+[.095,.41,.55,.48],'');%'2^n^d-level analysis');
                    else conn_menu('frame',boffset+[.095,.13,.55,.75],'');%'2^n^d-level analysis');
                    end
                    
                    conn_menu('frame2',boffset+[.655,.08,.28,.85],'');%'2^n^d-level analysis');
                    CONN_h.menus.m_results_00{11}=conn_menu('listbox',boffset+[.105,.53-dp1,.175,.30+dp1],'Subject effects','','select subject effect(s) characterizing second-level analysis model','conn(''gui_results'',11);');
                    CONN_h.menus.m_results_00{16}=conn_menu('edit',boffset+[.105,.44-dp1,.175,.04],'Between-subjects contrast',num2str(1),['<HTML>Define desired contrast across selected subject-effects<br/> - enter contrast vector/matrix with as many elements/columns as subject-effects selected <br/> - ',CONN_gui.rightclick,'-click or use the list below to see a list of standard contrasts for the selected subject-effects <br/> - enter multiple rows separated by <b>;</b> (semicolon) for OR conjunction (multivariate test) of several contrasts</HTML>'],'conn(''gui_results'',16);');
                    CONN_h.menus.m_results_00{12}=conn_menu('listbox',boffset+[.280,.53-dp1,.175,.30+dp1],'Conditions','','select condition(s) of interest','conn(''gui_results'',12);');
                    CONN_h.menus.m_results_00{19}=conn_menu('edit',boffset+[.280,.44-dp1,.175,.04],'Between-conditions contrast',num2str(1),['<HTML>Define desired contrast across selected conditions <br/> - enter contrast vector/matrix (as many elements/columns as conditions selected) <br/> - ',CONN_gui.rightclick,'-click or use the list below to see a list of standard contrasts for the selected conditions<br/> - enter multiple rows separated by <b>;</b> (semicolon) for OR conjunction (multivariate test) of several contrasts</HTML>'],'conn(''gui_results'',19);');
                    %connmeasures={'correlation (bivariate)','correlation (semipartial)','regression (bivariate)','regression (multivariate)'};
                    if state==3, 
                        CONN_h.menus.m_results_00{13}=conn_menu('listbox',boffset+[.455,.53-dp1,.185,.30+dp1],'Voxel-to-Voxel Measures','','select voxel-to-voxel measure(s) of interest','conn(''gui_results'',13);');
                        CONN_h.menus.m_results_00{17}=conn_menu('edit',boffset+[.455,.44-dp1,.185,.04],'Between-measures contrast',num2str(1),['<HTML>Define desired contrast across selected measures <br/> - enter contrast vector/matrix (as many elements/columns as measures selected) <br/> - ',CONN_gui.rightclick,'-click or use the list below to see a list of standard contrasts for the selected measures<br/> - enter multiple rows separated by <b>;</b> (semicolon) for OR conjunction (multivariate test) of several contrasts</HTML>'],'conn(''gui_results'',17);');
                    else
                        CONN_h.menus.m_results_00{13}=conn_menu('listbox',boffset+[.455,.53-dp1,.185,.30+dp1],'Seeds/Sources','','select seed/source ROI(s) of interest','conn(''gui_results'',13);');
                        CONN_h.menus.m_results_00{17}=conn_menu('edit',boffset+[.455,.44-dp1,.185,.04],'Between-sources contrast',num2str(1),['<HTML>Define desired contrast across selected sources <br/> - enter contrast vector/matrix (as many elements/columns as sources selected) <br/> - ',CONN_gui.rightclick,'-click or use the list below to see a list of standard contrasts for the selected sources<br/> - enter multiple rows separated by <b>;</b> (semicolon) for OR conjunction (multivariate test) of several contrasts</HTML>'],'conn(''gui_results'',17);');
                    end
                    
                    if state==2||state==3,
                        pos=[.67,.14,.235,.73];
                        if ~isfield(CONN_x.Results.xX,'displayvoxels'), CONN_x.Results.xX.displayvoxels=1; end
                        CONN_h.menus.m_results_00{24}=uicontrol('style','text','units','norm','position',boffset+[pos(1)+pos(3)-.195,pos(2)-1*.05,.095,.04],'string','p-uncorrected <','fontname','default','fontsize',8+CONN_gui.font_offset,'backgroundcolor',CONN_gui.backgroundcolorA,'foregroundcolor',CONN_gui.fontcolorA);
                        CONN_h.menus.m_results_00{15}=conn_menu('slider',boffset+[pos(1)+pos(3)-0*.01,pos(2),.015,pos(4)],'','','z-slice','conn(''gui_results'',15);');
                        set(CONN_h.menus.m_results_00{15},'visible','off');
                        conn_menumanager('onregion',CONN_h.menus.m_results_00{15},1,boffset+pos+[0 0 .015 0]);
                        %CONN_h.menus.m_results_00{15}=uicontrol('style','slider','units','norm','position',boffset+[pos(1)+pos(3)-0*.01,pos(2),.015,pos(4)],'callback','conn(''gui_results'',15);','backgroundcolor',CONN_gui.backgroundcolorA);
                        strstr3={'Analysis results preview (voxel-level)','Do not show analysis results preview','Whole-brain display (results explorer)'};
                        CONN_h.menus.m_results_00{32}=conn_menu('popup',boffset+[.71,.87,.19,.045],'',strstr3,'Display options','conn(''gui_results'',32);');
                        set(CONN_h.menus.m_results_00{32},'value',CONN_x.Results.xX.displayvoxels);
                        if state==2, [CONN_h.menus.m_results_00{14}]=conn_menu('image2',boffset+pos,'');%['Analysis results (voxel-level)']);%,connmeasures{CONN_x.Results.measure}]);
                        else         [CONN_h.menus.m_results_00{14}]=conn_menu('image2',boffset+pos,'');%['Connectivity measure (voxel-level)']);
                        end
                        %CONN_h.menus.m_results_00{32}=uicontrol('style','popupmenu','units','norm','position',boffset+[.70,.77,.195,.045],'string',strstr3,'fontsize',8+CONN_gui.font_offset,'value',CONN_x.Results.xX.displayvoxels,'backgroundcolor',CONN_gui.backgroundcolorA,'foregroundcolor',[0 0 0]+.4+.2*(mean(CONN_gui.backgroundcolorA)<.5),'tooltipstring','Display options','callback','conn(''gui_results'',32);');
                    end
                    
                    if state==1 % ROI-to-ROI
                        [CONN_h.menus.m_results_00{18},CONN_h.menus.m_results_00{22}]=conn_menu('listbox2',boffset+[.105,.07,.535,.23],sprintf('%-50s%10s%10s%12s%12s','Targets','beta','T','p-unc','p-FDR'),'   ','browse target ROIs -or right click for more options-','conn(''gui_results'',18);');
                        set(CONN_h.menus.m_results_00{18},'max',2,'fontname','monospaced','fontsize',8+CONN_gui.font_offset);
                        set(CONN_h.menus.m_results_00{22},'fontsize',8+CONN_gui.font_offset);
                        hc1=uicontextmenu;
                        %uimenu(hc1,'Label','Select target-ROIs set','callback','conn(''gui_results'',27)');
                        uimenu(hc1,'Label','Export stats','callback',@conn_exporttable);
                        set(CONN_h.menus.m_results_00{18},'uicontextmenu',hc1);
                        uicontrol('style','text','units','norm','position',boffset+[.105,.345,.535,.04],'string','Analysis results','backgroundcolor',CONN_gui.backgroundcolorA,'foregroundcolor',CONN_gui.fontcolorA,'fontangle','normal','fontweight','normal','fontname','default','fontsize',8+CONN_gui.font_offset,'horizontalalignment','center');
                        
                        if ~isfield(CONN_x.Results.xX,'inferencetype'), CONN_x.Results.xX.inferencetype=1; end
                        if ~isfield(CONN_x.Results.xX,'inferencelevel'), CONN_x.Results.xX.inferencelevel=.05; end
                        if ~isfield(CONN_x.Results.xX,'inferenceleveltype'), CONN_x.Results.xX.inferenceleveltype=1; end
                        if ~isfield(CONN_x.Results.xX,'displayrois'), CONN_x.Results.xX.displayrois=1; end
                        strstr1={'Two-sided','One-sided (positive)','One-sided (negative)'};
                        strstr2={'p-FDR corrected < ','p-uncorrected < '};
                        strstr3={'Analysis results: Targets are all ROIs','Analysis results: Targets are source ROIs only','Analysis results: Targets are selected ROIs only'};
                        %CONN_h.menus.m_results_00{24}=uicontrol('style','text','units','norm','position',boffset+[.675,.08,.05,.045],'string','threshold','fontname','default','fontsize',8,'backgroundcolor',CONN_gui.backgroundcolorA,'foregroundcolor',[0 0 0]+.4+.2*(mean(CONN_gui.backgroundcolorA)<.5));
                        CONN_h.menus.m_results_00{29}=conn_menu('popup',boffset+[.68,.13,.10,.045],'',strstr2,'choose type of false-positive control','conn(''gui_results'',29);');
                        set(CONN_h.menus.m_results_00{29},'value',CONN_x.Results.xX.inferenceleveltype);
                        CONN_h.menus.m_results_00{30}=conn_menu('edit',boffset+[.78,.13,.04,.045],'',num2str(CONN_x.Results.xX.inferencelevel),'enter false-positive threshold value','conn(''gui_results'',30);');
                        CONN_h.menus.m_results_00{28}=conn_menu('popup',boffset+[.83,.13,.09,.045],'',strstr1,'choose inference directionality','conn(''gui_results'',28);');
                        set(CONN_h.menus.m_results_00{28},'value',CONN_x.Results.xX.inferencetype);
                        CONN_h.menus.m_results_00{31}=conn_menu('popup',boffset+[.70,.87,.20,.045],'',strstr3,'choose target ROIs','conn(''gui_results'',31);');
                        set(CONN_h.menus.m_results_00{31},'value',CONN_x.Results.xX.displayrois);
                        %CONN_h.menus.m_results_00{28}=uicontrol('style','popupmenu','units','norm','position',boffset+[.81,.08,.08,.045],'string',strstr1,'fontsize',8+CONN_gui.font_offset,'value',CONN_x.Results.xX.inferencetype,'backgroundcolor',CONN_gui.backgroundcolorA,'foregroundcolor',[0 0 0]+.4+.2*(mean(CONN_gui.backgroundcolorA)<.5),'tooltipstring','choose inference directionality','callback','conn(''gui_results'',28);');
                        %CONN_h.menus.m_results_00{29}=uicontrol('style','popupmenu','units','norm','position',boffset+[.71,.08,.10,.045],'string',strstr2,'fontsize',8+CONN_gui.font_offset,'value',CONN_x.Results.xX.inferenceleveltype,'backgroundcolor',CONN_gui.backgroundcolorA,'foregroundcolor',[0 0 0]+.4+.2*(mean(CONN_gui.backgroundcolorA)<.5),'tooltipstring','choose type of false-positive control','callback','conn(''gui_results'',29);');
                        %CONN_h.menus.m_results_00{30}=uicontrol('style','edit','units','norm','position',boffset+[.66,.08,.05,.045],'string',num2str(CONN_x.Results.xX.inferencelevel),'fontsize',8+CONN_gui.font_offset,'backgroundcolor',CONN_gui.backgroundcolorA,'foregroundcolor',[0 0 0]+.4+.2*(mean(CONN_gui.backgroundcolorA)<.5),'tooltipstring','enter false-positive threshold value','callback','conn(''gui_results'',30);');
                        %CONN_h.menus.m_results_00{31}=uicontrol('style','popupmenu','units','norm','position',boffset+[.66,.77,.23,.045],'string',strstr3,'fontsize',8+CONN_gui.font_offset,'value',CONN_x.Results.xX.displayrois,'backgroundcolor',CONN_gui.backgroundcolorA,'foregroundcolor',[0 0 0]+.4+.2*(mean(CONN_gui.backgroundcolorA)<.5),'tooltipstring','choose target ROIs','callback','conn(''gui_results'',31);');
                        CONN_h.menus.m_results_00{25}=conn_menu('axes',boffset+[.67,.18,.24,.69]);
                        h0=CONN_gui.backgroundcolorA;
                        xs=conn_conv(mean(CONN_gui.refs.canonical.data,3)',[0,0]);xs=max(0,min(1,xs/max(xs(:))-.25));
                        %xs=repmat(xs,[1,1,3]).*repmat(shiftdim((1-h0),-1),[size(xs,1),size(xs,2),1])+repmat(shiftdim(h0,-1),[size(xs,1),size(xs,2),1]);
                        %xs=conn_bsxfun(@plus,shiftdim(h0,-1),conn_bsxfun(@times,xs,shiftdim((1-h0),-1)));
                        xs=ind2rgb(round(1+(size(CONN_h.screen.colormap,1)/2-1)*xs),CONN_h.screen.colormap);
                        %xs=conn_bsxfun(@times,1-xs,shiftdim(h0,-1))+conn_bsxfun(@times,xs,shiftdim((1-h0),-1));
                        %h0=CONN_gui.backgroundcolorA;xs=max(0,min(1,.5*abs(convn(mean(CONN_gui.refs.canonical.data>.5&CONN_gui.refs.canonical.data<.8,3)',[1;0;-1]*[1,0,-1],'same')))); xs=bsxfun(@plus,shiftdim(h0,-1),bsxfun(@times,xs,shiftdim((1-h0),-1)));
                        hi=image(xs); set(gca,'xdir','reverse','ydir','normal'); axis(gca,'equal','tight','off');
                        set(hi,'buttondownfcn','conn(''gui_results'',26);');
                        hold on;
                        CONN_h.menus.m_results_00{26}=patch(nan,nan,'k');
                        hc1=uicontextmenu;
                        uimenu(hc1,'Label','3d view','callback','conn(''gui_results_roi3d'');');
                        uimenu(hc1,'Label','Change background anatomical image','callback','conn(''background_image'');conn gui_results;');
                        set(hi,'uicontextmenu',hc1);
                        hold off;
                        CONN_h.menus.m_results_00{33}=conn_menu('pushbutton',boffset+[.66,.08,.08,.045],'','display 3D','displays 3d view of current analysis results','conn(''gui_results_roi3d'');');
                        CONN_h.menus.m_results_00{34}=conn_menu('pushbutton',boffset+[.75,.08,.08,.045],'','display values','<HTML>display effet sizes between selected ROI pairs for each condition/source <br/> - also exports values for each subject to Matlab workspace</HTML>','conn(''gui_results'',35);');
                        CONN_h.menus.m_results_00{35}=conn_menu('pushbutton',boffset+[.84,.08,.08,.045],'','import values','import connectivity values between selected ROI pairs for each condition/source/subject as 2nd-level covariates','conn(''gui_results'',34);');
                        set([CONN_h.menus.m_results_00{33},CONN_h.menus.m_results_00{34},CONN_h.menus.m_results_00{35}],'visible','off');%,'fontweight','bold');
                        conn_menumanager('onregion',[CONN_h.menus.m_results_00{33},CONN_h.menus.m_results_00{34},CONN_h.menus.m_results_00{35}],1,boffset+[.645,.08,.28,.81]);
                    end
                    
                    [path,name,ext]=fileparts(CONN_x.filename);
                    if state==1||state==2
                        filepathresults=fullfile(CONN_x.folders.firstlevel,CONN_x.Analyses(ianalysis).name);
                    else
                        filepathresults=CONN_x.folders.firstlevel;
                    end
                    ncovariates=length(CONN_x.Setup.l2covariates.names)-1;
                    nconditions=length(CONN_x.Setup.conditions.names)-1;
                    icondition=[];isnewcondition=[];for ncondition=1:nconditions,[icondition(ncondition),isnewcondition(ncondition)]=conn_conditionnames(CONN_x.Setup.conditions.names{ncondition}); end                    
                    
                    if state==1||state==2
                        CONN_h.menus.m_results.outcomenames=CONN_x.Analyses(ianalysis).sources;
                        CONN_h.menus.m_results.outcomeisource=[];for n1=1:length(CONN_h.menus.m_results.outcomenames),
                            [CONN_h.menus.m_results.outcomeisource(n1),isnew]=conn_sourcenames(CONN_h.menus.m_results.outcomenames{n1},'-');
                            if isnew&&state==2, error('Source %s not found in global source list. Please re-run first-level analyses',CONN_h.menus.m_results.outcomenames{n1}); end
                        end
                    else
                        CONN_h.menus.m_results.outcomenames=CONN_x.vvAnalyses.measures;%CONN_x.vvAnalyses.regressors.names;
                        CONN_h.menus.m_results.outcomeisource=[];for n1=1:length(CONN_h.menus.m_results.outcomenames),
                            [CONN_h.menus.m_results.outcomeisource(n1),isnew,CONN_h.menus.m_results.outcomencompsource(n1)]=conn_v2v('match_extended',CONN_h.menus.m_results.outcomenames{n1});
                            if isnew, error('Measure %s not found in global measures list. Please re-run first-level analyses',CONN_h.menus.m_results.outcomenames{n1}); end
                        end
                    end
                    
                    isvalidcondition=true(1,nconditions);
                    switch(state)
                        case 1, isvalidcondition=arrayfun(@(n)conn_existfile(fullfile(filepathresults,['resultsROI_Condition',num2str(n,'%03d'),'.mat'])),icondition);
                        case 2, isvalidcondition=arrayfun(@(n)conn_existfile(fullfile(filepathresults,['BETA_Subject',num2str(1,CONN_x.opt.fmt1),'_Condition',num2str(n,'%03d'),'_Source',num2str(CONN_h.menus.m_results.outcomeisource(1),'%03d'),'.nii'])),icondition);
                        case 3, isvalidcondition=arrayfun(@(n)conn_existfile(fullfile(filepathresults,['BETA_Subject',num2str(1,'%03d'),'_Condition',num2str(n,'%03d'),'_Measure',num2str(CONN_h.menus.m_results.outcomeisource(1),'%03d'),'_Component',num2str(CONN_h.menus.m_results.outcomencompsource(1),'%03d'),'.nii'])),icondition);
                    end
                    CONN_h.menus.m_results.shownconditions=find(~isnewcondition&isvalidcondition);
%                     if state==1
%                         isvalidcondition=arrayfun(@(n)conn_existfile(fullfile(filepathresults,['resultsROI_Condition',num2str(n,'%03d'),'.mat'])),icondition);
%                         CONN_h.menus.m_results.shownconditions=find(~isnewcondition&isvalidcondition); 
%                     else CONN_h.menus.m_results.shownconditions=1:nconditions;
%                     end
                    if isempty(CONN_h.menus.m_results.shownconditions)
                        uiwait(errordlg(sprintf('Condition (%s) have not been processed yet. Please re-run previous step (First-level analyses)',sprintf('%s ',CONN_x.Setup.conditions.names{:})),'Data not prepared for analyses'));
                        %conn gui_analyses;
                        %return;
                    end
                    CONN_h.menus.m_results.icondition=icondition;
                    %                 filename=fullfile(filepathresults,['resultsROI_Condition',num2str(1,'%03d'),'.mat']);
                    %                 if isempty(dir(filename)),Ransw=questdlg('First-level ROI analyses have not completed. Perform now?','warning','Yes','No','Yes');if strcmp(Ransw,'Yes'), conn_process('analyses_ROI'); end;end
                    %                 load(filename,'names','xyz');
                    set(CONN_h.menus.m_results_00{11},'max',2);set(CONN_h.menus.m_results_00{12},'max',2);set(CONN_h.menus.m_results_00{13},'max',2);
                    tnames=CONN_x.Setup.l2covariates.names(1:end-1); 
                    if ~isfield(CONN_h.menus.m_results,'showneffects_showall'), CONN_h.menus.m_results.showneffects_showall=false; end
                    if CONN_h.menus.m_results.showneffects_showall, CONN_h.menus.m_results.showneffects=1:numel(tnames); 
                    else CONN_h.menus.m_results.showneffects=find(cellfun(@(x)isempty(regexp(x,'^Dynamic ')),tnames)); 
                    end
                    if any(cellfun(@(x)~isempty(regexp(x,'^Dynamic ')),tnames))
                        hc1=uicontextmenu;
                        if CONN_h.menus.m_results.showneffects_showall, uimenu(hc1,'Label','Hide Dynamic factor score variables','callback','conn(''gui_results'',36);');
                        else uimenu(hc1,'Label','Show Dynamic factor score variables','callback','conn(''gui_results'',36);');
                        end
                        set(CONN_h.menus.m_results_00{11},'uicontextmenu',hc1);
                    end
                    set(CONN_h.menus.m_results_00{11},'string',tnames(CONN_h.menus.m_results.showneffects),'value',min(numel(CONN_h.menus.m_results.showneffects),get(CONN_h.menus.m_results_00{11},'value')));
                    tnames=CONN_x.Setup.conditions.names(1:end-1);
                    %tnames(isnewcondition|~isvalidcondition)=cellfun(@(x)[CONN_gui.parse_html{1},x,CONN_gui.parse_html{2}],tnames(isnewcondition|~isvalidcondition),'uni',0);
                    set(CONN_h.menus.m_results_00{12},'string',tnames(CONN_h.menus.m_results.shownconditions),'value',min(numel(CONN_h.menus.m_results.shownconditions),get(CONN_h.menus.m_results_00{12},'value')));
                    
                    if state==1||state==2, temptxt={CONN_h.menus.m_results.outcomenames{:}};
                    else temptxt=conn_v2v('cleartext',{CONN_h.menus.m_results.outcomenames{:}});
                    end
                    set(CONN_h.menus.m_results_00{13},'string',temptxt,'value',1);
                    
                    modeltypes={'Random effects','Fixed effects'};
                    modeltype=1;%+(CONN_x.Setup.nsubjects==1);
                    %CONN_h.menus.m_results_00{21}=conn_menu('popup',[.10,.44-dp1,.125,.04],'Between-subjects model',modeltypes,'Select model type','conn(''gui_results'',21);');
                    %set(CONN_h.menus.m_results_00{21},'value',modeltype);
                    
                    nconditions=1;nsources=1;
                    if isfield(CONN_x.Results.xX,'nsubjecteffects')&&isfield(CONN_x.Results.xX,'csubjecteffects')&&size(CONN_x.Results.xX.csubjecteffects,2)==numel(CONN_x.Results.xX.nsubjecteffects)&&all(ismember(CONN_x.Results.xX.nsubjecteffects,CONN_h.menus.m_results.showneffects)),
                        ncovariates=CONN_x.Results.xX.nsubjecteffects;
                        [nill,tempcovariates]=ismember(ncovariates,CONN_h.menus.m_results.showneffects);
                        set(CONN_h.menus.m_results_00{11},'value',tempcovariates); %min(CONN_x.Results.xX.nsubjecteffects,numel(get(CONN_h.menus.m_results_00{11},'string'))));
                        set(CONN_h.menus.m_results_00{16},'string',mat2str(CONN_x.Results.xX.csubjecteffects));
                    end
                    if isfield(CONN_x.Results.xX,'nconditions')&&isfield(CONN_x.Results.xX,'cconditions')&&(state==1&&ischar(CONN_x.Results.xX.cconditions)||size(CONN_x.Results.xX.cconditions,2)==numel(CONN_x.Results.xX.nconditions))&&all(ismember(CONN_x.Results.xX.nconditions,CONN_h.menus.m_results.shownconditions)),
                        nconditions=CONN_x.Results.xX.nconditions;
                        [nill,tempconditions]=ismember(nconditions,CONN_h.menus.m_results.shownconditions);
                        set(CONN_h.menus.m_results_00{12},'value',tempconditions);%min(CONN_x.Results.xX.nconditions,numel(get(CONN_h.menus.m_results_00{12},'string'))));
                        set(CONN_h.menus.m_results_00{19},'string',mat2str(CONN_x.Results.xX.cconditions));
                    end
                    %                 if isfield(CONN_x.Results.xX,'nsubjecteffects'), ncovariates=CONN_x.Results.xX.nsubjecteffects; set(CONN_h.menus.m_results_00{11},'value',min(CONN_x.Results.xX.nsubjecteffects,numel(get(CONN_h.menus.m_results_00{11},'string')))); end
                    %                 if isfield(CONN_x.Results.xX,'csubjecteffects'), set(CONN_h.menus.m_results_00{16},'string',num2str(CONN_x.Results.xX.csubjecteffects)); end
                    %                 if isfield(CONN_x.Results.xX,'nconditions'), nconditions=CONN_x.Results.xX.nconditions; set(CONN_h.menus.m_results_00{12},'value',min(CONN_x.Results.xX.nconditions,numel(get(CONN_h.menus.m_results_00{12},'string')))); end
                    %                 if isfield(CONN_x.Results.xX,'cconditions'), set(CONN_h.menus.m_results_00{19},'string',num2str(CONN_x.Results.xX.cconditions)); end
                    if state==1||state==2
                        if isfield(CONN_x.Results.xX,'nsources')&&isfield(CONN_x.Results.xX,'csources')&&size(CONN_x.Results.xX.csources,2)==numel(CONN_x.Results.xX.nsources)&&numel(get(CONN_h.menus.m_results_00{13},'string'))>=max(CONN_x.Results.xX.nsources),
                            nsources=CONN_x.Results.xX.nsources;
                            set(CONN_h.menus.m_results_00{13},'value',nsources);
                            set(CONN_h.menus.m_results_00{17},'string',mat2str(CONN_x.Results.xX.csources));
                        end
                    else
                        if isfield(CONN_x.Results.xX,'nmeasures')&&isfield(CONN_x.Results.xX,'cmeasures')&&size(CONN_x.Results.xX.cmeasures,2)==numel(CONN_x.Results.xX.nmeasures)&&numel(get(CONN_h.menus.m_results_00{13},'string'))>=max(CONN_x.Results.xX.nmeasures),
                            nsources=CONN_x.Results.xX.nmeasures;
                            set(CONN_h.menus.m_results_00{13},'value',nsources);
                            set(CONN_h.menus.m_results_00{17},'string',mat2str(CONN_x.Results.xX.cmeasures));
                        end
                    end
                    modeltype=1;%if isfield(CONN_x.Results.xX,'modeltype'), modeltype=CONN_x.Results.xX.modeltype; set(CONN_h.menus.m_results_00{21},'value',min(CONN_x.Results.xX.modeltype,numel(get(CONN_h.menus.m_results_00{21},'string')))); end
                    
                    %c=str2num(get(CONN_h.menus.m_results_00{17},'string'));
                    %txt=get(CONN_h.menus.m_results_00{17},'string'); value=str2num(txt); if isempty(value), try value=evalin('base',txt); set(CONN_h.menus.m_results_00{17},'string',mat2str(value)); catch, value=[]; end; end;c=value;
                    CONN_h.menus.m_results.X=zeros(CONN_x.Setup.nsubjects,length(CONN_x.Setup.l2covariates.names)-1);
                    for nsub=1:CONN_x.Setup.nsubjects,
                        for ncovariate=1:length(CONN_x.Setup.l2covariates.names)-1;
                            CONN_h.menus.m_results.X(nsub,ncovariate)=CONN_x.Setup.l2covariates.values{nsub}{ncovariate};
                        end
                    end
%                     if state==1||state==2
%                         txt=strvcat(CONN_x.Analyses(:).name);
%                         CONN_h.menus.m_results_00{20}=uicontrol('units','norm','position',[2.1*.91/4,.895,(.91-3*.91/4)*.8,.05],'style','popupmenu','string',txt,'fontsize',8+CONN_gui.font_offset,'value',ianalysis,'backgroundcolor','k','foregroundcolor','w','callback','conn(''gui_results'',20);','tooltipstring','Select first-level analysis set');
%                     end
                    tnames=conn_contrastmanager('names');
                    if numel(CONN_x.Setup.l2covariates.names)>2||numel(CONN_x.Setup.conditions.names)>2
                        %CONN_h.menus.m_results_00{21}=uicontrol('units','norm','position',[3.1*.91/4,.895,(.91-3*.91/4)*.8,.05],'style','popupmenu','string',[tnames,{'<HTML><i>contrast manager</i></HTML>'}],'fontsize',8+CONN_gui.font_offset,'value',numel(tnames)+1,'backgroundcolor','k','foregroundcolor','w','callback','conn(''gui_results'',21);','tooltipstring','User-defined list of contrasts of interest (between-subjects&conditions)');
                        CONN_h.menus.m_results_00{21}=conn_menu('popup2',[.005,.70,.125,.04],'',[{'user-defined contrast'},tnames,{'<HTML><i> save/delete contrast</i></HTML>'}],'User-defined list of contrasts of interest (between-subjects&conditions)','conn(''gui_results'',21);');
                        %CONN_h.menus.m_results_00{21}=conn_menu('popup2',[boffset(1)+.41,boffset(2)+.84,.23,.04],'',[{'user-defined contrast'},tnames,{'<HTML><i> save/delete contrast</i></HTML>'}],'User-defined list of contrasts of interest (between-subjects&conditions)','conn(''gui_results'',21);');
                        set(CONN_h.menus.m_results_00{21},'value',1);%,'fontsize',9+CONN_gui.font_offset);%,'fontweight','bold');
                    end
                    
                    CONN_h.menus.m_results_surfhires=0;
                    CONN_h.menus.m_results.y.data=[];
                    CONN_h.menus.m_results.y.MDok=[];
                    txt=get(CONN_h.menus.m_results_00{16},'string'); value=str2num(txt); if isempty(value), try value=evalin('base',txt); set(CONN_h.menus.m_results_00{16},'string',mat2str(value)); catch, value=[]; end; end;
                    b=value;
                    txt=get(CONN_h.menus.m_results_00{17},'string'); value=str2num(txt); if isempty(value), try value=evalin('base',txt); set(CONN_h.menus.m_results_00{17},'string',mat2str(value)); catch, value=[]; end; end;
                    c=value;
                    txt=get(CONN_h.menus.m_results_00{19},'string'); value=str2num(txt); if isempty(value), try value=evalin('base',txt); set(CONN_h.menus.m_results_00{19},'string',mat2str(value)); catch, value=[]; end; end;
                    d=value;
                    if (state==2||state==3)&&any(CONN_x.Setup.steps([2,3]))&&CONN_x.Results.xX.displayvoxels==1&&size(c,1)==1&&size(d,1)==1,%(~isfield(CONN_x.Setup,'doROIonly')||~CONN_x.Setup.doROIonly),
                        % loads voxel-level data
                        set(CONN_h.screen.hfig,'pointer','watch');drawnow
                        CONN_h.menus.m_results.y.MDok=conn_checkmissingdata(state,nconditions,nsources);
                        CONN_h.menus.m_results.y.data=0;
                        %                     CONN_h.menus.m_results.se.data=0;
                        %                     CONN_h.menus.m_results.se.dof=0;
                        for ncondition=1:length(nconditions),
                            for nsource=1:length(nsources),
                                filename=cell(1,CONN_x.Setup.nsubjects);
                                for nsub=1:CONN_x.Setup.nsubjects
                                    if state==1||state==2
                                        filename{nsub}=fullfile(filepathresults,['BETA_Subject',num2str(nsub,CONN_x.opt.fmt1),'_Condition',num2str(CONN_h.menus.m_results.icondition(nconditions(ncondition)),'%03d'),'_Source',num2str(CONN_h.menus.m_results.outcomeisource(nsources(nsource)),'%03d'),'.nii']);
                                    else
                                        filename{nsub}=fullfile(filepathresults,['BETA_Subject',num2str(nsub,'%03d'),'_Condition',num2str(CONN_h.menus.m_results.icondition(nconditions(ncondition)),'%03d'),'_Measure',num2str(CONN_h.menus.m_results.outcomeisource(nsources(nsource)),'%03d'),'_Component',num2str(CONN_h.menus.m_results.outcomencompsource(nsources(nsource)),'%03d'),'.nii']);
                                    end
                                end
                                try, CONN_h.menus.m_results.Y=spm_vol(char(filename));
                                catch,
                                    CONN_h.menus.m_results.y.data=[];
                                    uiwait(errordlg(sprintf('Condition (%s) has not been processed yet. Please re-run previous step (First-level analyses)',sprintf('%s ',CONN_x.Setup.conditions.names{ncondition})),'Data not prepared for analyses'));
                                    break;
                                end
                                if isequal(CONN_h.menus.m_results.Y(1).dim,conn_surf_dims(8).*[1 1 2]) % surface
                                    CONN_h.menus.m_results.y.slice=1;
                                    set(CONN_h.menus.m_results_00{15},'visible','off');
                                    conn_menumanager('onregionremove',CONN_h.menus.m_results_00{15});
                                else
                                    if ~isfield(CONN_h.menus.m_results.y,'slice')||CONN_h.menus.m_results.y.slice<1||CONN_h.menus.m_results.y.slice>CONN_h.menus.m_results.Y(1).dim(3), CONN_h.menus.m_results.y.slice=ceil(CONN_h.menus.m_results.Y(1).dim(3)/2); end
                                    set(CONN_h.menus.m_results_00{15},'min',1,'max',CONN_h.menus.m_results.Y(1).dim(3),'sliderstep',min(.5,[1,10]/(CONN_h.menus.m_results.Y(1).dim(3)-1)),'value',CONN_h.menus.m_results.y.slice);
                                end
                                %                             filename=fullfile(filepathresults,['resultsDATA_Condition',num2str(nconditions(ncondition),'%03d'),'_Source',num2str(CONN_h.menus.m_results.outcomeisource(nsources(nsource)),'%03d'),'.mat']);
                                %                             CONN_h.menus.m_results.Y=conn_vol(filename);
                                if ncondition==1&&nsource==1
                                    [ndgridx,ndgridy]=ndgrid(1:CONN_h.menus.m_results.Y(1).dim(1),1:CONN_h.menus.m_results.Y(1).dim(2));
                                    CONN_h.menus.m_results.y.xyz=[ndgridx(:),ndgridy(:),ones(numel(ndgridx),2)]';
                                end
                                if isequal(CONN_h.menus.m_results.Y(1).dim,conn_surf_dims(8).*[1 1 2])
                                    if CONN_h.menus.m_results_surfhires
                                        temp=spm_read_vols(CONN_h.menus.m_results.Y);
                                        temp=permute(temp,[4,1,2,3]);
                                        temp=temp(:,:);
                                    else
                                        tempxyz1=CONN_h.menus.m_results.y.xyz;
                                        tempxyz1(3,:)=1;
                                        temp1=spm_get_data(CONN_h.menus.m_results.Y,tempxyz1);
                                        tempxyz2=CONN_h.menus.m_results.y.xyz;
                                        tempxyz2(3,:)=conn_surf_dims(8)*[0;0;1]+1;
                                        temp2=spm_get_data(CONN_h.menus.m_results.Y,tempxyz2);
                                        temp=[temp1(:,CONN_gui.refs.surf.default2reduced) temp2(:,CONN_gui.refs.surf.default2reduced)];
                                    end
                                else
                                    CONN_h.menus.m_results.y.xyz(3,:)=CONN_h.menus.m_results.y.slice;
                                    temp=spm_get_data(CONN_h.menus.m_results.Y,CONN_h.menus.m_results.y.xyz);
                                end
                                
                                %                             [temp,CONN_h.menus.m_results.y.idx]=conn_get_slice(CONN_h.menus.m_results.Y,CONN_h.menus.m_results.y.slice);
                                CONN_h.menus.m_results.y.data=CONN_h.menus.m_results.y.data+temp*c(nsource)*d(ncondition);
                            end
                            if isempty(CONN_h.menus.m_results.y.data), break; end
                            %                         filename=fullfile(filepathresults,['seDATA_Condition',num2str(nconditions(ncondition),'%03d'),'.mat']);
                            %                         CONN_h.menus.m_results.SE=conn_vol(filename);
                            %                         [temp,nill]=conn_get_slice(CONN_h.menus.m_results.SE,CONN_h.menus.m_results.y.slice);
                            %                         CONN_h.menus.m_results.se.data=CONN_h.menus.m_results.se.data+sum(c.^2)*(d(ncondition)*temp).^2;
                            %                         CONN_h.menus.m_results.se.dof=CONN_h.menus.m_results.se.dof+CONN_h.menus.m_results.SE.DOF;
                        end
                        %                     CONN_h.menus.m_results.se.data=sqrt(CONN_h.menus.m_results.se.data);
                        
                        CONN_h.menus.m_results.XS=CONN_gui.refs.canonical.V;
                        xyz=conn_convertcoordinates('idx2tal',prod(CONN_h.menus.m_results.Y(1).dim(1:2))*(CONN_h.menus.m_results.y.slice-1)+(1:prod(CONN_h.menus.m_results.Y(1).dim(1:2))),CONN_h.menus.m_results.Y(1).mat,CONN_h.menus.m_results.Y(1).dim);
                        txyz=pinv(CONN_h.menus.m_results.XS(1).mat)*xyz'; CONN_h.menus.m_results.Xs=spm_sample_vol(CONN_h.menus.m_results.XS(1),txyz(1,:),txyz(2,:),txyz(3,:),1);
                        CONN_h.menus.m_results.Xs=permute(reshape(CONN_h.menus.m_results.Xs,CONN_h.menus.m_results.Y(1).dim(1:2)),[2,1,3]);
                        CONN_h.menus.m_results.Xs=(CONN_h.menus.m_results.Xs/max(CONN_h.menus.m_results.Xs(:))).^3;
                        set(CONN_h.screen.hfig,'pointer','arrow');
                        if isequal(CONN_h.menus.m_results.Y(1).dim,conn_surf_dims(8).*[1 1 2])&&~CONN_h.menus.m_results_surfhires, 
                            strstr3={'Analysis results preview (low-res preview)','Do not show analysis results preview','Whole-brain display (results explorer)'};
                        else 
                            strstr3={'Analysis results preview (voxel-level)','Do not show analysis results preview','Whole-brain display (results explorer)'};
                        end
                        set(CONN_h.menus.m_results_00{32},'string',strstr3,'value',CONN_x.Results.xX.displayvoxels);
                    elseif state==2||state==3
                        if state==1||state==2
                            filename=fullfile(filepathresults,['BETA_Subject',num2str(1,CONN_x.opt.fmt1),'_Condition',num2str(CONN_h.menus.m_results.icondition(nconditions(1)),'%03d'),'_Source',num2str(CONN_h.menus.m_results.outcomeisource(nsources(1)),'%03d'),'.nii']);
                        else
                            filename=fullfile(filepathresults,['BETA_Subject',num2str(1,'%03d'),'_Condition',num2str(CONN_h.menus.m_results.icondition(nconditions(1)),'%03d'),'_Measure',num2str(CONN_h.menus.m_results.outcomeisource(nsources(1)),'%03d'),'_Component',num2str(CONN_h.menus.m_results.outcomencompsource(nsources(1)),'%03d'),'.nii']);
                        end
                        CONN_h.menus.m_results.Y=spm_vol(char(filename));
                        if ~isfield(CONN_h.menus.m_results.y,'slice')||CONN_h.menus.m_results.y.slice<1||CONN_h.menus.m_results.y.slice>CONN_h.menus.m_results.Y(1).dim(3), CONN_h.menus.m_results.y.slice=ceil(CONN_h.menus.m_results.Y(1).dim(3)/2); end
                        [ndgridx,ndgridy]=ndgrid(1:CONN_h.menus.m_results.Y(1).dim(1),1:CONN_h.menus.m_results.Y(1).dim(2));
                        CONN_h.menus.m_results.y.xyz=[ndgridx(:),ndgridy(:),ones(numel(ndgridx),2)]';
                        CONN_h.menus.m_results.y.xyz(3,:)=CONN_h.menus.m_results.y.slice;
                        CONN_h.menus.m_results.y.data=[];
                        CONN_h.menus.m_results.y.MDok=[];%conn_checkmissingdata(state,nconditions,nsources);
                        CONN_h.menus.m_results.XS=CONN_gui.refs.canonical.V;
                        xyz=conn_convertcoordinates('idx2tal',prod(CONN_h.menus.m_results.Y(1).dim(1:2))*(CONN_h.menus.m_results.y.slice-1)+(1:prod(CONN_h.menus.m_results.Y(1).dim(1:2))),CONN_h.menus.m_results.Y(1).mat,CONN_h.menus.m_results.Y(1).dim);
                        txyz=pinv(CONN_h.menus.m_results.XS(1).mat)*xyz'; CONN_h.menus.m_results.Xs=spm_sample_vol(CONN_h.menus.m_results.XS(1),txyz(1,:),txyz(2,:),txyz(3,:),1);
                        CONN_h.menus.m_results.Xs=permute(reshape(CONN_h.menus.m_results.Xs,CONN_h.menus.m_results.Y(1).dim(1:2)),[2,1,3]);
                        CONN_h.menus.m_results.Xs=(CONN_h.menus.m_results.Xs/max(CONN_h.menus.m_results.Xs(:))).^3;
                    end
                    model=1;
                    modelroi=1;
                end
            else
                if ismember(varargin{2},[11,12,16,19])&&all(ishandle(CONN_h.menus.m_results_00{21})), set(CONN_h.menus.m_results_00{21},'value',1); end
				switch(varargin{2}),
					case 11,
						model=2;modelroi=1;
						ncovariates=get(CONN_h.menus.m_results_00{11},'value');
                        if isempty(ncovariates), ncovariates=1; set(CONN_h.menus.m_results_00{11},'value',1); end
                        ncovariates=CONN_h.menus.m_results.showneffects(ncovariates);
						if length(ncovariates)==1, set(CONN_h.menus.m_results_00{16},'string','1'); else  set(CONN_h.menus.m_results_00{16},'string',['eye(',num2str(length(ncovariates)),')']); end
					case {12,13,15,17,18,19,32,39}
                         modelroi=1;
						 nconditions=get(CONN_h.menus.m_results_00{12},'value');
                         if isempty(nconditions), nconditions=1; set(CONN_h.menus.m_results_00{12},'value',1); end
                         nconditions=CONN_h.menus.m_results.shownconditions(nconditions);
						 nsources=get(CONN_h.menus.m_results_00{13},'value');
                         if isempty(nsources), nsources=1; set(CONN_h.menus.m_results_00{13},'value',1); end
						 if varargin{2}==18,
                             ntarget=get(CONN_h.menus.m_results_00{18},'value');
                             ntarget=CONN_h.menus.m_results.roiresults.idx(ntarget);
                             CONN_h.menus.m_results.roiresults.lastselected=ntarget;
                             if state==2,%&&any(CONN_x.Setup.steps([2,3])),%(~isfield(CONN_x.Setup,'doROIonly')||~CONN_x.Setup.doROIonly),
                                 CONN_h.menus.m_results.y.slice=ceil(conn_convertcoordinates('tal2idx',CONN_h.menus.m_results.roiresults.xyz2{ntarget},CONN_h.menus.m_results.Y.matdim.mat,CONN_h.menus.m_results.Y.matdim.dim)/prod(CONN_h.menus.m_results.Y.matdim.dim(1:2)));
                                 if ~isfield(CONN_h.menus.m_results.y,'slice')||CONN_h.menus.m_results.y.slice<1||CONN_h.menus.m_results.y.slice>CONN_h.menus.m_results.Y(1).dim(3), CONN_h.menus.m_results.y.slice=ceil(CONN_h.menus.m_results.Y(1).dim(3)/2); end
                                 set(CONN_h.menus.m_results_00{15},'value',CONN_h.menus.m_results.y.slice);
                             end
                         elseif state==2||state==3
                             CONN_h.menus.m_results.y.slice=round(get(CONN_h.menus.m_results_00{15},'value')); 
                             if ~isempty(CONN_h.menus.m_results.y.data)&&isfield(CONN_h.menus.m_results,'Y')&&(~isfield(CONN_h.menus.m_results.y,'slice')||CONN_h.menus.m_results.y.slice<1||CONN_h.menus.m_results.y.slice>CONN_h.menus.m_results.Y(1).dim(3)), CONN_h.menus.m_results.y.slice=ceil(CONN_h.menus.m_results.Y(1).dim(3)/2); end
                             set(CONN_h.menus.m_results_00{15},'value',CONN_h.menus.m_results.y.slice);
                         end
						 if varargin{2}==12,if length(nconditions)==1, set(CONN_h.menus.m_results_00{19},'string','1'); else  set(CONN_h.menus.m_results_00{19},'string',['eye(',num2str(length(nconditions)),')']);end; end
						 if varargin{2}==13,if length(nsources)==1, set(CONN_h.menus.m_results_00{17},'string','1'); else  set(CONN_h.menus.m_results_00{17},'string',['eye(',num2str(length(nsources)),')']);end; end
                         if state==1||state==2
                             filepathresults=fullfile(CONN_x.folders.firstlevel,CONN_x.Analyses(ianalysis).name);
                         else
                             filepathresults=CONN_x.folders.firstlevel;
                         end
						 %c=str2num(get(CONN_h.menus.m_results_00{17},'string'));
						 %d=str2num(get(CONN_h.menus.m_results_00{19},'string'));
                         txt=get(CONN_h.menus.m_results_00{16},'string'); value=str2num(txt); if isempty(value), try value=evalin('base',txt); set(CONN_h.menus.m_results_00{16},'string',mat2str(value)); catch, value=[]; end; end;
                         b=value;
                         txt=get(CONN_h.menus.m_results_00{17},'string'); value=str2num(txt); if isempty(value), try value=evalin('base',txt); set(CONN_h.menus.m_results_00{17},'string',mat2str(value)); catch, value=[]; end; end;
                         if state==1||state==2, if isempty(value)||size(value,2)~=numel(nsources), value=CONN_x.Results.xX.csources; set(CONN_h.menus.m_results_00{17},'string',mat2str(value)); end
                         else                   if isempty(value)||size(value,2)~=numel(nsources), value=CONN_x.Results.xX.cmeasures; set(CONN_h.menus.m_results_00{17},'string',mat2str(value)); end; 
                         end
                         c=value;
                         txt=get(CONN_h.menus.m_results_00{19},'string'); 
                         if state==1&&isequal(txt,'var'), 
                             d=eye(numel(nconditions)); 
                             dvar=true;
                         else
                             value=str2num(txt); if isempty(value), try value=evalin('base',txt); set(CONN_h.menus.m_results_00{19},'string',mat2str(value)); catch, value=[]; end; end;
                             if isempty(value)||size(value,2)~=numel(nconditions), value=CONN_x.Results.xX.cconditions; set(CONN_h.menus.m_results_00{19},'string',mat2str(value)); end
                             d=value;
                             dvar=false;
                         end
                         if varargin{2}==32, 
                             value=get(CONN_h.menus.m_results_00{32},'value'); 
                             if value==3
                                 set(CONN_h.menus.m_results_00{32},'value',CONN_x.Results.xX.displayvoxels);
                                 CONN_x.gui=struct('overwrite','No','display',1);
                                 if state==2,     conn gui_results_wholebrain;
                                 elseif state==3, conn gui_results_wholebrain_vv;
                                 end
                                 CONN_x.gui=1;
                                 return;
                             else
                                 CONN_x.Results.xX.displayvoxels=value;
                             end
                         end
                         if (state==2||state==3)&&CONN_x.Results.xX.displayvoxels==1&&size(c,1)==1&&size(d,1)==1,%(~isfield(CONN_x.Setup,'doROIonly')||~CONN_x.Setup.doROIonly),
                             set(CONN_h.screen.hfig,'pointer','watch');drawnow
                             CONN_h.menus.m_results.y.xyz(3,:)=CONN_h.menus.m_results.y.slice;
                             CONN_h.menus.m_results.y.MDok=conn_checkmissingdata(state,nconditions,nsources);
                             CONN_h.menus.m_results.y.data=0;
%                              CONN_h.menus.m_results.se.data=0;
%                              CONN_h.menus.m_results.se.dof=0;
                             for ncondition=1:length(nconditions),
                                 for nsource=1:length(nsources),
                                     filename=cell(1,CONN_x.Setup.nsubjects);
                                     for nsub=1:CONN_x.Setup.nsubjects
                                         if state==1||state==2
                                             filename{nsub}=fullfile(filepathresults,['BETA_Subject',num2str(nsub,CONN_x.opt.fmt1),'_Condition',num2str(CONN_h.menus.m_results.icondition(nconditions(ncondition)),'%03d'),'_Source',num2str(CONN_h.menus.m_results.outcomeisource(nsources(nsource)),'%03d'),'.nii']);
                                         else
                                             filename{nsub}=fullfile(filepathresults,['BETA_Subject',num2str(nsub,'%03d'),'_Condition',num2str(CONN_h.menus.m_results.icondition(nconditions(ncondition)),'%03d'),'_Measure',num2str(CONN_h.menus.m_results.outcomeisource(nsources(nsource)),'%03d'),'_Component',num2str(CONN_h.menus.m_results.outcomencompsource(nsources(nsource)),'%03d'),'.nii']);
                                         end
                                     end
                                     try, CONN_h.menus.m_results.Y=spm_vol(char(filename));
                                     catch, 
                                         CONN_h.menus.m_results.y.data=[]; 
                                         uiwait(errordlg(sprintf('Condition (%s) has not been processed yet. Please re-run previous step (First-level analyses)',sprintf('%s ',CONN_x.Setup.conditions.names{ncondition})),'Data not prepared for analyses'));
                                         break;
                                     end
                                     if isequal(CONN_h.menus.m_results.Y(1).dim,conn_surf_dims(8).*[1 1 2]) % surface
                                         CONN_h.menus.m_results.y.slice=1;
                                         set(CONN_h.menus.m_results_00{15},'visible','off');
                                         conn_menumanager('onregionremove',CONN_h.menus.m_results_00{15});
                                     else
                                         if ~isfield(CONN_h.menus.m_results.y,'slice')||CONN_h.menus.m_results.y.slice<1||CONN_h.menus.m_results.y.slice>CONN_h.menus.m_results.Y(1).dim(3), CONN_h.menus.m_results.y.slice=ceil(CONN_h.menus.m_results.Y(1).dim(3)/2); end
                                         set(CONN_h.menus.m_results_00{15},'min',1,'max',CONN_h.menus.m_results.Y(1).dim(3),'sliderstep',min(.5,[1,10]/(CONN_h.menus.m_results.Y(1).dim(3)-1)),'value',CONN_h.menus.m_results.y.slice);
                                     end
                                     
                                     if ncondition==1&&nsource==1
                                         [ndgridx,ndgridy]=ndgrid(1:CONN_h.menus.m_results.Y(1).dim(1),1:CONN_h.menus.m_results.Y(1).dim(2));
                                         CONN_h.menus.m_results.y.xyz=[ndgridx(:),ndgridy(:),ones(numel(ndgridx),2)]';
                                     end
                                     if isequal(CONN_h.menus.m_results.Y(1).dim,conn_surf_dims(8).*[1 1 2])
                                         if CONN_h.menus.m_results_surfhires
                                             temp=spm_read_vols(CONN_h.menus.m_results.Y);
                                             temp=permute(temp,[4,1,2,3]);
                                             temp=temp(:,:);
                                         else
                                             tempxyz1=CONN_h.menus.m_results.y.xyz;
                                             tempxyz1(3,:)=1;
                                             temp1=spm_get_data(CONN_h.menus.m_results.Y,tempxyz1);
                                             tempxyz2=CONN_h.menus.m_results.y.xyz;
                                             tempxyz2(3,:)=conn_surf_dims(8)*[0;0;1]+1;
                                             temp2=spm_get_data(CONN_h.menus.m_results.Y,tempxyz2);
                                             temp=[temp1(:,CONN_gui.refs.surf.default2reduced) temp2(:,CONN_gui.refs.surf.default2reduced)];
                                         end
                                     else
                                         CONN_h.menus.m_results.y.xyz(3,:)=CONN_h.menus.m_results.y.slice;
                                         temp=spm_get_data(CONN_h.menus.m_results.Y,CONN_h.menus.m_results.y.xyz);
                                     end
                                     CONN_h.menus.m_results.y.data=CONN_h.menus.m_results.y.data+temp*c(nsource)*d(ncondition);
%                                      filename=fullfile(filepathresults,['resultsDATA_Condition',num2str(nconditions(ncondition),'%03d'),'_Source',num2str(CONN_h.menus.m_results.outcomeisource(nsources(nsource)),'%03d'),'.mat']);
%                                      CONN_h.menus.m_results.Y=conn_vol(filename);
%                                      [temp,CONN_h.menus.m_results.y.idx]=conn_get_slice(CONN_h.menus.m_results.Y,CONN_h.menus.m_results.y.slice);
%                                      CONN_h.menus.m_results.y.data=CONN_h.menus.m_results.y.data+temp*c(nsource)*d(ncondition);
                                 end
%                                  filename=fullfile(filepathresults,['seDATA_Condition',num2str(nconditions(ncondition),'%03d'),'.mat']);
%                                  CONN_h.menus.m_results.SE=conn_vol(filename);
%                                  [temp,nill]=conn_get_slice(CONN_h.menus.m_results.SE,CONN_h.menus.m_results.y.slice);
%                                  CONN_h.menus.m_results.se.data=CONN_h.menus.m_results.se.data+sum(c.^2)*(d(ncondition)*temp).^2;
%                                  CONN_h.menus.m_results.se.dof=CONN_h.menus.m_results.se.dof+CONN_h.menus.m_results.SE.DOF;
                                if isempty(CONN_h.menus.m_results.y.data), break; end
                             end
%                              CONN_h.menus.m_results.se.data=sqrt(CONN_h.menus.m_results.se.data);
                             if varargin{2}==15||varargin{2}==18,
                                 xyz=conn_convertcoordinates('idx2tal',prod(CONN_h.menus.m_results.Y(1).dim(1:2))*(CONN_h.menus.m_results.y.slice-1)+(1:prod(CONN_h.menus.m_results.Y(1).dim(1:2))),CONN_h.menus.m_results.Y(1).mat,CONN_h.menus.m_results.Y(1).dim);
                                 txyz=pinv(CONN_h.menus.m_results.XS(1).mat)*xyz'; CONN_h.menus.m_results.Xs=spm_sample_vol(CONN_h.menus.m_results.XS(1),txyz(1,:),txyz(2,:),txyz(3,:),1);
                                 CONN_h.menus.m_results.Xs=permute(reshape(CONN_h.menus.m_results.Xs,CONN_h.menus.m_results.Y(1).dim(1:2)),[2,1,3]);
                                 CONN_h.menus.m_results.Xs=(CONN_h.menus.m_results.Xs/max(CONN_h.menus.m_results.Xs(:))).^3;
                                 set(CONN_h.menus.m_results_00{15},'min',1,'max',CONN_h.menus.m_results.Y(1).dim(3),'sliderstep',min(.5,[1,10]/(CONN_h.menus.m_results.Y(1).dim(3)-1)),'value',CONN_h.menus.m_results.y.slice);
                                 modelroi=0;
                             end
                             set(CONN_h.screen.hfig,'pointer','arrow');
                         elseif state==2||state==3
                             CONN_h.menus.m_results.y.data=[];
                         end
						 model=1;
					case 16,
						ncovariates=get(CONN_h.menus.m_results_00{11},'value');
                        ncovariates=CONN_h.menus.m_results.showneffects(ncovariates);
                        txt=get(CONN_h.menus.m_results_00{16},'string'); value=str2num(txt); if isempty(value), try value=evalin('base',txt); set(CONN_h.menus.m_results_00{16},'string',mat2str(value)); catch, value=[]; end; end;
                        if isempty(value)||size(value,2)~=numel(ncovariates), value=CONN_x.Results.xX.csubjecteffects; set(CONN_h.menus.m_results_00{16},'string',mat2str(value)); end
                        model=2;modelroi=1;
                    case 20,
                        tianalysis=get(CONN_h.menus.m_results_00{20},'value');
                        tianalysis=CONN_h.menus.m_results.shownanalyses(tianalysis);
                        CONN_x.Analysis=tianalysis;
                        conn gui_results;
                        return;
                    case 21,
                        ncontrast=get(CONN_h.menus.m_results_00{21},'value')-1;
                        if ncontrast==numel(get(CONN_h.menus.m_results_00{21},'string'))-1,
                            ncontrast=conn_contrastmanager;
                            tnames=conn_contrastmanager('names');
                            set(CONN_h.menus.m_results_00{21},'string',[{'user-defined contrast'},tnames,{'<HTML><i> save/delete contrast</i></HTML>'}]);
                            if ncontrast, set(CONN_h.menus.m_results_00{21},'value',ncontrast+1);
                            else          set(CONN_h.menus.m_results_00{21},'value',1);
                            end
                        end
                        if ncontrast
                            [ok1,i1]=ismember(CONN_x.Results.saved.nsubjecteffects{ncontrast},CONN_x.Setup.l2covariates.names(1:end-1));
                            if ~all(ok1), uiwait(warndlg('Error. Invalid second-level covariate names','')); ok=false;
                            else
                                [ok2,i2]=ismember(CONN_x.Results.saved.nconditions{ncontrast},CONN_x.Setup.conditions.names(1:end-1));
                                if ~all(ok2), uiwait(warndlg('Error. Invalid condition names','')); ok=false;
                                else 
                                    CONN_x.Results.xX.nsubjecteffects=i1;
                                    CONN_x.Results.xX.csubjecteffects=CONN_x.Results.saved.csubjecteffects{ncontrast};
                                    CONN_x.Results.xX.nconditions=i2;
                                    CONN_x.Results.xX.cconditions=CONN_x.Results.saved.cconditions{ncontrast};
                                    if isfield(CONN_x.Results.xX,'nsubjecteffects')&&isfield(CONN_x.Results.xX,'csubjecteffects')&&size(CONN_x.Results.xX.csubjecteffects,2)==numel(CONN_x.Results.xX.nsubjecteffects)&&all(ismember(CONN_x.Results.xX.nsubjecteffects,CONN_h.menus.m_results.showneffects)),
                                        ncovariates=CONN_x.Results.xX.nsubjecteffects;
                                        [nill,tempcovariates]=ismember(ncovariates,CONN_h.menus.m_results.showneffects);
                                        set(CONN_h.menus.m_results_00{11},'value',tempcovariates); %min(CONN_x.Results.xX.nsubjecteffects,numel(get(CONN_h.menus.m_results_00{11},'string'))));
                                        set(CONN_h.menus.m_results_00{16},'string',mat2str(CONN_x.Results.xX.csubjecteffects));
                                    else disp('Warning. Unable to match subject effects from saved contrast to current analyses'); 
                                    end
                                    if isfield(CONN_x.Results.xX,'nconditions')&&isfield(CONN_x.Results.xX,'cconditions')&&size(CONN_x.Results.xX.cconditions,2)==numel(CONN_x.Results.xX.nconditions)&&all(ismember(CONN_x.Results.xX.nconditions,CONN_h.menus.m_results.shownconditions)),
                                        nconditions=CONN_x.Results.xX.nconditions;
                                        [nill,tempconditions]=ismember(nconditions,CONN_h.menus.m_results.shownconditions);
                                        set(CONN_h.menus.m_results_00{12},'value',tempconditions);%min(CONN_x.Results.xX.nconditions,numel(get(CONN_h.menus.m_results_00{12},'string'))));
                                        set(CONN_h.menus.m_results_00{19},'string',mat2str(CONN_x.Results.xX.cconditions));
                                    else disp('Warning. Unable to match condition names from saved contrast to current analyses'); 
                                    end
                                    conn('gui_results',39);
                                    return;
                                end
                                %conn gui_results;
                                %return;
                            end
                        end
%                     case 21,
% 						model=1;modelroi=1;
                    case 26,
                        if ~isempty(CONN_h.menus.m_results_00{26})&&ishandle(CONN_h.menus.m_results_00{26}(1))
                            %CONN_h.menus.m_results.roiresults.displayrois;
                            %CONN_h.menus.m_results.roiresults.displayroisnames;
                            xyz=get(get(CONN_h.menus.m_results_00{26}(1),'parent'),'currentpoint');
                            [nill,idx]=min(sum(abs(conn_bsxfun(@minus,xyz(1,1:2),CONN_h.menus.m_results.roiresults.displayrois(:,6:7))).^2,2));
                            if nill<10
                                ntarget=find(CONN_h.menus.m_results.roiresults.idx==CONN_h.menus.m_results.roiresults.displayrois(idx,8));
                                if numel(ntarget)==1&&size(get(CONN_h.menus.m_results_00{18},'string'),1)>=ntarget
                                    if strcmp(get(CONN_h.screen.hfig,'selectiontype'),'extend')
                                        ntargetold=get(CONN_h.menus.m_results_00{18},'value');
                                        if ismember(ntarget,ntargetold), set(CONN_h.menus.m_results_00{18},'value',setdiff(ntargetold,ntarget));
                                        else set(CONN_h.menus.m_results_00{18},'value',union(ntargetold,ntarget));
                                        end
                                    else set(CONN_h.menus.m_results_00{18},'value',ntarget);
                                    end
                                end
                            end
                        end
                    case 28
                        CONN_x.Results.xX.inferencetype=get(CONN_h.menus.m_results_00{28},'value');
                        modelroi=2;
                    case 29
                        CONN_x.Results.xX.inferenceleveltype=get(CONN_h.menus.m_results_00{29},'value');
                        modelroi=2;
                    case 30
                        txt=get(CONN_h.menus.m_results_00{30},'string'); value=str2num(txt); if isempty(value), try value=evalin('base',txt); set(CONN_h.menus.m_results_00{30},'string',num2str(value)); catch, value=[]; end; end;
                        if ~isempty(value), CONN_x.Results.xX.inferencelevel=value; else set(CONN_h.menus.m_results_00{30},'string',num2str(CONN_x.Results.xX.inferencelevel)); end
                        modelroi=2;
                    case 31,
                        CONN_x.Results.xX.displayrois=get(CONN_h.menus.m_results_00{31},'value');
                        if ~isfield(CONN_x.Results.xX,'roiselected2'), CONN_x.Results.xX.roiselected2=1:numel(CONN_h.menus.m_results.roiresults.names2); end
                        if CONN_x.Results.xX.displayrois==3
                            idxresortv=1:numel(CONN_h.menus.m_results.roiresults.names2);
                            temp=regexp(CONN_h.menus.m_results.roiresults.names2,'BA\.(\d*) \(L\)','tokens'); itemp=~cellfun(@isempty,temp); idxresortv(itemp)=-2e6+cellfun(@(x)str2double(x{1}),temp(itemp));
                            temp=regexp(CONN_h.menus.m_results.roiresults.names2,'BA\.(\d*) \(R\)','tokens'); itemp=~cellfun(@isempty,temp); idxresortv(itemp)=-1e6+cellfun(@(x)str2double(x{1}),temp(itemp));
                            [nill,idxresort]=sort(idxresortv);
                            [nill,tidx]=ismember(CONN_x.Results.xX.roiselected2,idxresort);
                            answ=listdlg('Promptstring','Select target ROIs','selectionmode','multiple','liststring',CONN_h.menus.m_results.roiresults.names2(idxresort),'initialvalue',sort(tidx));
                            if ~isempty(answ)>0, CONN_x.Results.xX.roiselected2=sort(idxresort(answ)); end
                        end
                        modelroi=2;
                    case {34,35}
						 nconditions=get(CONN_h.menus.m_results_00{12},'value');
                         nconditions=CONN_h.menus.m_results.shownconditions(nconditions);
						 nsources=get(CONN_h.menus.m_results_00{13},'value');
                         ntarget=get(CONN_h.menus.m_results_00{18},'value');
                         ntarget=CONN_h.menus.m_results.roiresults.idx(ntarget);
                         CONN_h.menus.m_results.roiresults.lastselected=ntarget;
                         names_sources=get(CONN_h.menus.m_results_00{13},'string');
                         names_conditions=CONN_x.Setup.conditions.names(1:end-1);%get(CONN_h.menus.m_results_00{12},'string');
                         y={};
                         name={};
                         for itarget=1:numel(ntarget)
                             for icondition=1:numel(nconditions)
                                 for isource=1:numel(nsources)
                                     ty=CONN_h.menus.m_results.roiresults.y(:,ntarget(itarget),isource,icondition);
                                     if isfield(CONN_h.menus.m_results.roiresults.xX,'SelectedSubjects')&&~rem(size(ty,1),nnz(CONN_h.menus.m_results.roiresults.xX.SelectedSubjects))
                                         ty2=nan(size(ty,1)/nnz(CONN_h.menus.m_results.roiresults.xX.SelectedSubjects)*numel(CONN_h.menus.m_results.roiresults.xX.SelectedSubjects),size(ty,2));
                                         ty2(repmat(logical(CONN_h.menus.m_results.roiresults.xX.SelectedSubjects),size(ty,1)/nnz(CONN_h.menus.m_results.roiresults.xX.SelectedSubjects),1),:)=ty;
                                         ty=ty2;
                                     end
                                     y{end+1}=ty;
                                     name{end+1}=sprintf('conn between %s and %s at %s',...
                                         regexprep(names_sources{nsources(isource)},{'^BA\.(\d+) \(([LR])\)\. .*','^\((-?\d+),(-?\d+),(-?\d+)\)$','^SLrois\.|^aal\.|^atlas\.','([^\(\)]+)\(.+)\s*$'},{'$1$2','($1 $2 $3)','','$1'}),...
                                         regexprep(CONN_h.menus.m_results.roiresults.names2{ntarget(itarget)},{'^BA\.(\d+) \(([LR])\)\. .*','^\((-?\d+),(-?\d+),(-?\d+)\)$','^SLrois\.|^aal\.|^atlas\.','([^\(\)]+)\(.+)\s*$'},{'$1$2','($1 $2 $3)','','$1'}),...
                                         names_conditions{nconditions(icondition)});
                                 end
                             end
                         end
                         if varargin{2}==34
                             conn_importl2covariate(name,y);
                             conn gui_results;
                         else
                             assignin('base','Effect_values',y);
                             assignin('base','Effect_names',name);
                             disp('Exported the following effects:');
                             disp(char(name));
                             disp('Values exported to variable ''Effect_values''; Names exported to variable ''Effect_names''');
                             disp(' ');
                             
                             clear Stats_values;
                             if isfield(CONN_h.menus.m_results.roiresults.xX,'SelectedSubjects')
                                 xf=zeros(numel(CONN_h.menus.m_results.roiresults.xX.SelectedSubjects),size(CONN_h.menus.m_results.roiresults.xX.X,2));
                                 xf(CONN_h.menus.m_results.roiresults.xX.SelectedSubjects,:)=CONN_h.menus.m_results.roiresults.xX.X; %CONN_x.Results.xX.X(:,CONN_x.Results.xX.nsubjecteffects);
                             else
                                 xf=CONN_h.menus.m_results.roiresults.xX.X;
                             end
                             nsubjects=find(any(xf~=0,2)&~any(isnan(xf),2));
                             xf=xf(nsubjects,:);
                             for ny=1:numel(y)
                                 yf=y{ny}(nsubjects,:);
                                 [Stats_values(ny).beta,Stats_values(ny).F,Stats_values(ny).p,Stats_values(ny).dof,Stats_values(ny).stat]=conn_glm(xf,yf,[],[],'collapse_none');
                             end
                             %assignin('base','Effect_stats',Stats_values);
                             %disp('Stats exported to variable ''Effect_stats''');
                             
                             hfig=figure('units','norm','position',[.2 .3 .6 .6],'color','w','name','connectivity values','numbertitle','off','menubar','none');
                             cbeta=[Stats_values.beta];
                             CI=spm_invTcdf(1-.05,Stats_values(1).dof)*cbeta./[Stats_values.F];
                             tnames=CONN_h.menus.m_results.roiresults.xX.name; %CONN_x.Setup.l2covariates.names(CONN_x.Results.xX.nsubjecteffects);
                             hax=gca;
                             hpatches=conn_plotbars(cbeta,CI);
                             set(hax,'units','norm','position',[.2,.4,.6,.5],'box','off','xlim',[0 size(cbeta,1)+1]);
                             if size(cbeta,1)>1, set(hax,'xtick',1:numel(tnames),'xticklabel',tnames);
                             else set(hax,'xtick',[]);
                             end
                             xlabel('2nd-level GLM model regression coefficients');
                             ylabel('Effect size');
                             if numel(name)>1, hl=legend(hpatches(1,:),name); set(hl,'box','off','units','norm','position',[.2,.1,.6,.2]);
                             else set(hax,'units','norm','position',[.2,.15,.6,.7]); set(hfig,'name',char(name),'position',[.2 .3 .4 .3]); 
                             end
                         end
                         return;
                    case 36
						ncovariates=get(CONN_h.menus.m_results_00{11},'value');
                        ncovariates=CONN_h.menus.m_results.showneffects(ncovariates);
                        tnames=CONN_x.Setup.l2covariates.names(1:end-1);
                        if ~isfield(CONN_h.menus.m_results,'showneffects_showall'), CONN_h.menus.m_results.showneffects_showall=false; end
                        CONN_h.menus.m_results.showneffects_showall=1-CONN_h.menus.m_results.showneffects_showall;
                        if CONN_h.menus.m_results.showneffects_showall, CONN_h.menus.m_results.showneffects=1:numel(tnames);
                        else CONN_h.menus.m_results.showneffects=find(cellfun(@(x)isempty(regexp(x,'^Dynamic ')),tnames));
                        end
                        set(CONN_h.menus.m_results_00{11},'string',tnames(CONN_h.menus.m_results.showneffects));
                        [ok1,tempcovariates]=ismember(ncovariates,CONN_h.menus.m_results.showneffects);
                        if ~all(ok1), set(CONN_h.menus.m_results_00{11},'value',1);set(CONN_h.menus.m_results_00{16},'string','1');
                        else set(CONN_h.menus.m_results_00{11},'value',tempcovariates);
                        end
                        hc1=get(CONN_h.menus.m_results_00{11},'uicontextmenu');
                        if CONN_h.menus.m_results.showneffects_showall, set(get(hc1,'children'),'label','Hide Dynamic factor score variables');
                        else set(get(hc1,'children'),'Label','Show Dynamic factor score variables');
                        end
						model=2;modelroi=1;
				end
			end
			ncovariates=get(CONN_h.menus.m_results_00{11},'value');
            ncovariates=CONN_h.menus.m_results.showneffects(ncovariates);
			nconditions=get(CONN_h.menus.m_results_00{12},'value');
            nconditions=CONN_h.menus.m_results.shownconditions(nconditions);
			nsources=get(CONN_h.menus.m_results_00{13},'value');
			modeltype=1;%get(CONN_h.menus.m_results_00{21},'value');
            conn_contrasthelp(CONN_h.menus.m_results_00{16},CONN_x.Setup.l2covariates.names(1:end-1),ncovariates,all(ismember(CONN_h.menus.m_results.X(:,ncovariates),[0 1]),1)+2*all(ismember(CONN_h.menus.m_results.X(:,ncovariates),[-1 1]),1));
            conn_contrasthelp(CONN_h.menus.m_results_00{19},CONN_x.Setup.conditions.names(1:end-1),nconditions,[]);
            conn_contrasthelp(CONN_h.menus.m_results_00{17},get(CONN_h.menus.m_results_00{13},'string'),nsources,[]);

            %set([CONN_h.menus.m_results_00{24},CONN_h.menus.m_results_00{15},CONN_h.menus.m_results_00{23}],'visible','off');
%             if (state==2||state==3)&&model==1,%&&CONN_x.Setup.normalized&&any(CONN_x.Setup.steps([2,3])),%(~isfield(CONN_x.Setup,'doROIonly')||~CONN_x.Setup.doROIonly),
%                 MDok=conn_checkmissingdata(state,nconditions,nsources);
%                 xf=CONN_h.menus.m_results.X;
%                 yf=CONN_h.menus.m_results.y.data;
%                 nsubjects=find(any(xf~=0,2)&~any(isnan(xf),2)&MDok);
%                 xf=xf(nsubjects,:);
%                 if ~isempty(yf)
%                     yf=yf(nsubjects,:);
%                     if modeltype==1, [CONN_h.menus.m_results.B,CONN_h.menus.m_results.opt]=conn_glmunivariate('estimate',xf,yf);
%                     else [CONN_h.menus.m_results.B,CONN_h.menus.m_results.opt]=conn_glmunivariate('estimatefixed',xf,yf,CONN_h.menus.m_results.se); end
%                 end
%                 CONN_h.menus.m_results.ncovariates=1:size(xf,2);
%                 CONN_x.Results.xX.X=xf;
%             elseif (state==1)&&model==1,
%                 xf=CONN_h.menus.m_results.X;
%                 nsubjects=find(any(xf~=0,2)&~any(isnan(xf),2));
%                 xf=xf(nsubjects,:);
%                 CONN_h.menus.m_results.ncovariates=1:size(xf,2);
%                 CONN_x.Results.xX.X=xf;
%             end
            if model
                idx=ncovariates;
                if 1,%~isempty(idx),
                    CONN_x.Results.xX.nsubjecteffects=ncovariates;
                    CONN_x.Results.xX.nconditions=nconditions;
                    txt=get(CONN_h.menus.m_results_00{16},'string'); value=str2num(txt); if isempty(value), try value=evalin('base',txt); set(CONN_h.menus.m_results_00{16},'string',mat2str(value)); catch, value=[]; end; end;
                    CONN_x.Results.xX.csubjecteffects=value;
                    txt=get(CONN_h.menus.m_results_00{17},'string'); value=str2num(txt); if isempty(value), try value=evalin('base',txt); set(CONN_h.menus.m_results_00{17},'string',mat2str(value)); catch, value=[]; end; end;
                    if state==1||state==2
                        CONN_x.Results.xX.nsources=nsources;
                        CONN_x.Results.xX.csources=value;
                    else
                        CONN_x.Results.xX.nmeasures=nsources;
                        CONN_x.Results.xX.cmeasures=value;
                    end
                    txt=get(CONN_h.menus.m_results_00{19},'string'); 
                    if isequal(txt,'var'), value=txt; 
                    else value=str2num(txt); if isempty(value), try value=evalin('base',txt); set(CONN_h.menus.m_results_00{19},'string',mat2str(value)); catch, value=[]; end; end;
                    end
                    CONN_x.Results.xX.cconditions=value;
                    CONN_x.Results.xX.modeltype=modeltype;
                    if (state==2||state==3),%&&CONN_x.Setup.normalized&&any(CONN_x.Setup.steps([2,3])),%(~isfield(CONN_x.Setup,'doROIonly')||~CONN_x.Setup.doROIonly),
                        if model==1 || length(idx)~=length(CONN_h.menus.m_results.ncovariates) || any(idx~=CONN_h.menus.m_results.ncovariates),
                            if ~isfield(CONN_h.menus.m_results.y,'MDok')||isempty(CONN_h.menus.m_results.y.MDok), CONN_h.menus.m_results.y.MDok=conn_checkmissingdata(state,nconditions,nsources); end
                            MDok=CONN_h.menus.m_results.y.MDok;
                            xf=CONN_h.menus.m_results.X(:,idx);
                            yf=CONN_h.menus.m_results.y.data;
                            %                             se=CONN_h.menus.m_results.se;
                            nsubjects=find(any(xf~=0,2)&~any(isnan(xf),2)&MDok);
                            xf=xf(nsubjects,:);
                            if ~isempty(yf)&&~isequal(yf,0)
                                yf=yf(nsubjects,:);
                                if modeltype==1, [CONN_h.menus.m_results.B,CONN_h.menus.m_results.opt]=conn_glmunivariate('estimate',xf,yf);
                                else  [CONN_h.menus.m_results.B,CONN_h.menus.m_results.opt]=conn_glmunivariate('estimatefixed',xf,yf,se); end
                            end
                            CONN_h.menus.m_results.ncovariates=idx;
                            CONN_x.Results.xX.X=xf;
                        end
                        if ~isempty(CONN_h.menus.m_results.y.data)&&size(CONN_x.Results.xX.csubjecteffects,1)==1
                            if modeltype==1, [h,F,p,dof,R]=conn_glmunivariate('evaluate',CONN_h.menus.m_results.opt,[],CONN_x.Results.xX.csubjecteffects);
                            else  [h,F,p,dof,R]=conn_glmunivariate('evaluatefixed',CONN_h.menus.m_results.opt,[],CONN_x.Results.xX.csubjecteffects);
                            end
                            if CONN_x.Setup.nsubjects==1,
                                if isequal(size(p),size(h)), p(h~=0)=.5;
                                else p=.5+zeros(size(p));
                                end
                            end
                            if state==2
                                %                         t1=zeros(CONN_h.menus.m_results.Y.matdim.dim(1:2));
                                %                         t2=nan+zeros(CONN_h.menus.m_results.Y.matdim.dim(1:2));
                                switch(CONN_x.Analyses(ianalysis).measure),
                                    case {1,2}, % correlation
                                        S1=tanh(h); S2=2*min(p,1-p);
                                    otherwise, % regression
                                        S1=h; S2=2*min(p,1-p);
                                end
                                %                             t1(CONN_h.menus.m_results.y.idx)=S1;
                                %                             t2(CONN_h.menus.m_results.y.idx)=S2;
                            else
                                S1=h;
                                S2=2*min(p,1-p);
                            end
                            
                            if isequal(CONN_h.menus.m_results.Y(1).dim,conn_surf_dims(8).*[1 1 2]),
                                t1=reshape(S1,[],2);
                                t2=reshape(S2,[],2);
                                if ~CONN_h.menus.m_results_surfhires
                                    conn_menu('update',CONN_h.menus.m_results_00{14},{CONN_gui.refs.surf.defaultreduced,t1,-t2},{CONN_h.menus.m_results.Y(1),CONN_h.menus.m_results.y.slice});
                                else
                                    conn_menu('update',CONN_h.menus.m_results_00{14},{CONN_gui.refs.surf.default,t1,-t2},{CONN_h.menus.m_results.Y(1),CONN_h.menus.m_results.y.slice});
                                end
                                set([CONN_h.menus.m_results_00{24}],'visible','on');
                            else
                                t1=reshape(S1,CONN_h.menus.m_results.Y(1).dim(1:2));
                                t2=reshape(S2,CONN_h.menus.m_results.Y(1).dim(1:2));
                                t1=permute(t1,[2,1,3]);
                                t2=permute(t2,[2,1,3]);
                                set(CONN_h.menus.m_results_00{14}.h9,'string',num2str(max(t1(:))));
                                conn_menu('update',CONN_h.menus.m_results_00{14},{CONN_h.menus.m_results.Xs,t1,-t2},{CONN_h.menus.m_results.Y(1),CONN_h.menus.m_results.y.slice});
                                %                         conn_menu('update',CONN_h.menus.m_results_00{14},{CONN_h.menus.m_results.Xs,t1,-t2},{CONN_h.menus.m_results.Y.matdim,CONN_h.menus.m_results.y.slice})
                                set([CONN_h.menus.m_results_00{24}],'visible','on');
                                %set([CONN_h.menus.m_results_00{15}],'visible','on');
                                hc1=uicontextmenu;uimenu(hc1,'Label','Change background anatomical image','callback','conn(''background_image'');conn gui_results;');uimenu(hc1,'Label','Change background reference rois','callback','conn(''background_rois'');');set(CONN_h.menus.m_results_00{14}.h2,'uicontextmenu',hc1);
                            end
                            
                            conn_menu('updatecscale',[],[],CONN_h.menus.m_results_00{14}.h9);
                            if isequal(CONN_h.menus.m_results.Y(1).dim,conn_surf_dims(8).*[1 1 2])&&~CONN_h.menus.m_results_surfhires, 
                                strstr3={'Analysis results preview (low-res preview)','Do not show analysis results preview','Whole-brain display (results explorer)'};
                            else 
                                strstr3={'Analysis results preview (voxel-level)','Do not show analysis results preview','Whole-brain display (results explorer)'};
                            end
                            set(CONN_h.menus.m_results_00{32},'string',strstr3,'value',CONN_x.Results.xX.displayvoxels);
                        else
                            if CONN_x.Results.xX.displayvoxels==1
                                set(CONN_h.menus.m_results_00{32},'string',{'preview not available - select results explorer'},'value',1);
                            end
                            conn_menu('update',CONN_h.menus.m_results_00{14},[]);
                            set([CONN_h.menus.m_results_00{24},CONN_h.menus.m_results_00{15}],'visible','off');
                        end
                    end
                end
            end
            roierr=false;
            if modelroi&&state==1, % ROI-level
                if isfield(CONN_h.menus.m_results,'roiresults')&&isfield(CONN_h.menus.m_results.roiresults,'lastselected'), bakroiresultsidx=CONN_h.menus.m_results.roiresults.lastselected; else bakroiresultsidx=[]; end
                CONN_h.menus.m_results.roiresults=conn_process('results_ROI',CONN_x.Results.xX.nsources,CONN_x.Results.xX.csources);
%                 try, CONN_h.menus.m_results.roiresults=conn_process('results_ROI',CONN_x.Results.xX.nsources,CONN_x.Results.xX.csources);
%                 catch, 
%                     roierr=true;
%                     uiwait(errordlg('Some conditions have not been processed yet. Re-run previous step (First-level analyses)','Data not prepared for analyses'));
%                 end
                if ~roierr
                    if isequal(CONN_h.menus.m_results.roiresults.statsname,'T')
                        set(CONN_h.menus.m_results_00{28},'visible','on');
                        switch CONN_x.Results.xX.inferencetype
                            case 1, CONN_h.menus.m_results.roiresults.p=2*min(CONN_h.menus.m_results.roiresults.p,1-CONN_h.menus.m_results.roiresults.p);
                            case 2,
                            case 3, CONN_h.menus.m_results.roiresults.p=1-CONN_h.menus.m_results.roiresults.p;
                        end
                    else
                        set(CONN_h.menus.m_results_00{28},'visible','off');
                    end
                    switch CONN_x.Results.xX.displayrois
                        case 1, CONN_x.Results.xX.roiselected2=1:numel(CONN_h.menus.m_results.roiresults.names2);
                        case 2, CONN_x.Results.xX.roiselected2=1:numel(CONN_h.menus.m_results.roiresults.names);
                    end
                    if ~isfield(CONN_x.Results.xX,'roiselected2')||isempty(CONN_x.Results.xX.roiselected2)||any(CONN_x.Results.xX.roiselected2>numel(CONN_h.menus.m_results.roiresults.names2)), CONN_x.Results.xX.roiselected2=1:numel(CONN_h.menus.m_results.roiresults.names2); end
                    CONN_h.menus.m_results.roiresults.P=nan(size(CONN_h.menus.m_results.roiresults.p));
                    CONN_h.menus.m_results.roiresults.P(CONN_x.Results.xX.roiselected2)=conn_fdr(CONN_h.menus.m_results.roiresults.p(CONN_x.Results.xX.roiselected2),2);
                    switch CONN_x.Results.xX.inferenceleveltype
                        case 1, CONN_h.menus.m_results.roiresults.Pthr=CONN_h.menus.m_results.roiresults.P;
                        case 2, CONN_h.menus.m_results.roiresults.Pthr=CONN_h.menus.m_results.roiresults.p;
                    end
                    if size(CONN_h.menus.m_results.roiresults.dof,2)>1
                        set(CONN_h.menus.m_results_00{22},'string',sprintf('%-30s%10s%10s%12s%12s','Targets','beta',[CONN_h.menus.m_results.roiresults.statsname,'(',num2str(CONN_h.menus.m_results.roiresults.dof(1)),',',num2str(CONN_h.menus.m_results.roiresults.dof(2)),')'],'p-unc','p-FDR'));
                    else
                        set(CONN_h.menus.m_results_00{22},'string',sprintf('%-30s%10s%10s%12s%12s','Targets','beta',[CONN_h.menus.m_results.roiresults.statsname,'(',num2str(CONN_h.menus.m_results.roiresults.dof(1)),')'],'p-unc','p-FDR'));
                    end
                    [nill,CONN_h.menus.m_results.roiresults.idx]=sort(CONN_h.menus.m_results.roiresults.P(CONN_x.Results.xX.roiselected2)-1e-10*abs(CONN_h.menus.m_results.roiresults.F(CONN_x.Results.xX.roiselected2)));
                    CONN_h.menus.m_results.roiresults.idx=CONN_x.Results.xX.roiselected2(CONN_h.menus.m_results.roiresults.idx);
                    txt=[];
                    for n1=1:numel(CONN_h.menus.m_results.roiresults.idx),
                        n2=CONN_h.menus.m_results.roiresults.idx(n1);
                        tmp=CONN_h.menus.m_results.roiresults.names2{n2};if length(tmp)>30,tmp=[tmp(1:30-5),'*',tmp(end-3:end)]; end;
                        txt=strvcat(txt,...
                            [[sprintf('%-30s',tmp)],...
                            [sprintf('%10.2f',CONN_h.menus.m_results.roiresults.h(n2))],...
                            [sprintf('%10.2f',CONN_h.menus.m_results.roiresults.F(n2))],...
                            [sprintf('%12f',CONN_h.menus.m_results.roiresults.p(n2))],...
                            [sprintf('%12f',CONN_h.menus.m_results.roiresults.P(n2))]]);
                    end;
                    if ~isempty(txt)
                        parse_html=regexprep(CONN_gui.parse_html,{'<HTML>','</HTML>'},{'<HTML><pre>','</pre></HTML>'});
                        txt=cellstr(txt);
                        ntemp=~(CONN_h.menus.m_results.roiresults.Pthr(CONN_h.menus.m_results.roiresults.idx)<CONN_x.Results.xX.inferencelevel);
                        txt(ntemp)=cellfun(@(x)[parse_html{1},x,parse_html{2}],txt(ntemp),'uni',0);
                        txt=char(txt);
                    end
                    listboxtop=get(CONN_h.menus.m_results_00{18},'listboxtop');
                    if isempty(bakroiresultsidx), txtok=[]; 
                    else [txtok,txtidx]=ismember(bakroiresultsidx,CONN_h.menus.m_results.roiresults.idx);
                    end
                    if any(txtok), txtval=min(txtidx(txtok),size(txt,1));  
                    else txtval=min(get(CONN_h.menus.m_results_00{18},'value'),size(txt,1));
                    end
                    if ~isempty(txtval)&&~ismember(listboxtop,min(txtval)+(-10:0)), listboxtop=max(1,min(size(txt,1),min(txtval)-2)); end
                    set(CONN_h.menus.m_results_00{18},'string',txt,'value',txtval,'ListboxTop',listboxtop);
                    if get(CONN_h.menus.m_results_00{18},'listboxtop')>size(txt,1), warning('off','MATLAB:hg:uicontrol:ListboxTopMustBeWithinStringRange'); drawnow; warning('on','MATLAB:hg:uicontrol:ListboxTopMustBeWithinStringRange'); set(CONN_h.menus.m_results_00{18},'listboxtop',1); end
                else
                    set(CONN_h.menus.m_results_00{18},'string',[],'value',1,'listboxtop',1);
                end
            end
            if state==1, % ROI-level
                idxplotroi=ishandle(CONN_h.menus.m_results_00{26});
                tobedeleted=CONN_h.menus.m_results_00{26}(idxplotroi);
                CONN_h.menus.m_results_00{26}=[];
                if ~roierr
                    xtemp=cos((0:32)'/16*pi);ytemp=sin((0:32)'/16*pi);
                    axes(CONN_h.menus.m_results_00{25}); %hold on;
                    ntarget=get(CONN_h.menus.m_results_00{18},'value');
                    ntarget=CONN_h.menus.m_results.roiresults.idx(ntarget);
                    CONN_h.menus.m_results.roiresults.lastselected=ntarget;
                    ntemp=find(CONN_h.menus.m_results.roiresults.Pthr(CONN_x.Results.xX.roiselected2)<CONN_x.Results.xX.inferencelevel);
                    ntemp=CONN_x.Results.xX.roiselected2(ntemp);
                    wtemp=-log10(max(1e-8,CONN_h.menus.m_results.roiresults.p(ntemp)))/8;
                    wtemp=max(.25,wtemp/max(eps,max(wtemp)));
                    %ctemp=.75+.25*(CONN_h.menus.m_results.roiresults.P(ntemp)<.05);
                    if isempty(wtemp),wtemp=1;ctemp=0;end
                    CONN_h.menus.m_results.roiresults.displayrois=[];
                    CONN_h.menus.m_results.roiresults.displayroisnames={};
                    ntemp2=find(CONN_h.menus.m_results.roiresults.h(ntemp)<0);
                    if ~isempty(ntemp2)
                        xyz=pinv(CONN_gui.refs.canonical.V.mat)*[cat(1,CONN_h.menus.m_results.roiresults.xyz2{ntemp(ntemp2)}),ones(numel(ntemp2),1)]';
                        [nill,idxsort]=sort(xyz(3,:));
                        CONN_h.menus.m_results_00{26}=cat(2,CONN_h.menus.m_results_00{26},patch(conn_bsxfun(@plus,xyz(1,idxsort),conn_bsxfun(@times,0+3*wtemp(ntemp2(idxsort)),xtemp)),conn_bsxfun(@plus,xyz(2,idxsort),conn_bsxfun(@times,0+3*wtemp(ntemp2(idxsort)),ytemp)),'b','edgecolor','k'));
                        CONN_h.menus.m_results.roiresults.displayrois=cat(1,CONN_h.menus.m_results.roiresults.displayrois,[cat(1,CONN_h.menus.m_results.roiresults.xyz2{ntemp(ntemp2)}),2*3*wtemp(ntemp2)',-ones(numel(ntemp2),1), xyz(1:2,:)', reshape(ntemp(ntemp2),[],1)]);
                        CONN_h.menus.m_results.roiresults.displayroisnames=cat(2,CONN_h.menus.m_results.roiresults.displayroisnames,CONN_h.menus.m_results.roiresults.names2(ntemp(ntemp2)));
                        %CONN_h.menus.m_results_00{26}=cat(2,CONN_h.menus.m_results_00{26},patch(bsxfun(@plus,xyz(1,:),bsxfun(@times,0+3*wtemp(ntemp2),xtemp)),bsxfun(@plus,xyz(2,:),bsxfun(@times,0+3*wtemp(ntemp2),ytemp)),bsxfun(@times,ctemp(ntemp2),shiftdim([0,0,1],-1)),'edgecolor',0*[0,0,.5]));
                    end
                    ntemp2=find(CONN_h.menus.m_results.roiresults.h(ntemp)>0);
                    if ~isempty(ntemp2)
                        xyz=pinv(CONN_gui.refs.canonical.V.mat)*[cat(1,CONN_h.menus.m_results.roiresults.xyz2{ntemp(ntemp2)}),ones(numel(ntemp2),1)]';
                        [nill,idxsort]=sort(xyz(3,:));
                        CONN_h.menus.m_results_00{26}=cat(2,CONN_h.menus.m_results_00{26},patch(conn_bsxfun(@plus,xyz(1,idxsort),conn_bsxfun(@times,0+3*wtemp(ntemp2(idxsort)),xtemp)),conn_bsxfun(@plus,xyz(2,idxsort),conn_bsxfun(@times,0+3*wtemp(ntemp2(idxsort)),ytemp)),'r','edgecolor','k'));
                        CONN_h.menus.m_results.roiresults.displayrois=cat(1,CONN_h.menus.m_results.roiresults.displayrois,[cat(1,CONN_h.menus.m_results.roiresults.xyz2{ntemp(ntemp2)}),2*3*wtemp(ntemp2)',ones(numel(ntemp2),1), xyz(1:2,:)', reshape(ntemp(ntemp2),[],1)]);
                        CONN_h.menus.m_results.roiresults.displayroisnames=cat(2,CONN_h.menus.m_results.roiresults.displayroisnames,CONN_h.menus.m_results.roiresults.names2(ntemp(ntemp2)));
                        %CONN_h.menus.m_results_00{26}=cat(2,CONN_h.menus.m_results_00{26},patch(bsxfun(@plus,xyz(1,:),bsxfun(@times,0+3*wtemp(ntemp2),xtemp)),bsxfun(@plus,xyz(2,:),bsxfun(@times,0+3*wtemp(ntemp2),ytemp)),bsxfun(@times,ctemp(ntemp2),shiftdim([1,0,0],-1)),'edgecolor',0*[.5,0,0]));
                    end
                    if ~isempty(ntarget)
                        for itarget=1:numel(ntarget)
                            ntemp2=find(ntemp==ntarget(itarget),1);
                            xyz=pinv(CONN_gui.refs.canonical.V.mat)*[CONN_h.menus.m_results.roiresults.xyz2{ntarget(itarget)},1]';
                            if ~isempty(ntemp2), wt2=3*wtemp(ntemp2);
                            else wt2=1;
                            end
                            %patch(xyz(1)+(0+3*wtemp(ntemp2))*[-1 -1 1 1 nan 0 0 0 0 nan],xyz(2)+(0+3*wtemp(ntemp2))*[0 0 0 0 nan -1 1 1 -1 nan],'k','facecolor','none','edgecolor','y','linestyle','-','linewidth',1));
                            CONN_h.menus.m_results_00{26}=cat(2,CONN_h.menus.m_results_00{26},...
                                patch(xyz(1)+(0+wt2)*[-1 -1 1 1 nan 0 0 0 0 nan],xyz(2)+(0+wt2)*[0 0 0 0 nan -1 1 1 -1 nan],'k','facecolor','none','edgecolor','w','linestyle',':','linewidth',1));
                            [beta.h,beta.F,beta.p,beta.dof,beta.statsname]=conn_glm(CONN_h.menus.m_results.roiresults.xX.X,permute(CONN_h.menus.m_results.roiresults.y(:,ntarget(itarget),:),[1,3,2]),[],[],'collapse_none');
                            cbeta=beta.h;
                            if nnz(~isnan(cbeta))
                                CI=spm_invTcdf(1-.05,beta.dof)*cbeta./beta.F;
                                crange=[min(0,min(cbeta(:)-CI(:))) max(0,max(cbeta(:)+CI(:)))];
                                xrange=min([10*size(cbeta,2).^.75/size(cbeta,1).^.25, 2*abs(CONN_gui.refs.canonical.V.dim(1)-(xyz(1)-2))/size(cbeta,1)/1.25, 2*abs(xyz(1)-2)/size(cbeta,1)/1.25]);
                                h0a=line(xyz(1)-2+1*xrange*(size(cbeta,1))/2*[-1 1],xyz(2)+2+wt2+0.125*10+10*(-crange(1)/diff(crange))+[0 0],numel(ntarget)-itarget+1+[.2 .2],'color','k','linewidth',1);
                                h0b=patch(xyz(1)-2+1.25*xrange*(size(cbeta,1))/2*[-1 -1 1 1],xyz(2)+2+wt2+1.25*10*[0 1 1 0],numel(ntarget)-itarget+1+[0 0 0 0],'k','facecolor','w','edgecolor','none','linestyle','-','linewidth',1,'facealpha',.90);
                                h0c=patch(xyz(1)+[0 -2 -.5],xyz(2)+[0 2 2]+wt2,numel(ntarget)-itarget+1+[.2 .2 .2],'w','facecolor','w','edgecolor','none','facealpha',.90);
                                [h1,h2]=conn_plotbars(cbeta,CI, [xyz(1)-2+xrange*size(cbeta,1)/2+xrange/2, xyz(2)+2+wt2+0.125*10+10*(-crange(1)/diff(crange)), numel(ntarget)-itarget+1, -xrange, 10/diff(crange), .1]);
                                set(h1,'facecolor',[.5 .5 .5],'facealpha',.90);set(h2,'linewidth',1,'color',.25*[1 1 1]);
                                set([h0a,h0b,h0c,h1(:)',h2(:)'], 'buttondownfcn','conn(''gui_results'',35);');
                                CONN_h.menus.m_results_00{26}=cat(2,CONN_h.menus.m_results_00{26},h0a,h0b,h0c,h1(:)',h2(:)');
                            end
                        end
                    end
                    if ~isempty(nsources)
                        xyz=pinv(CONN_gui.refs.canonical.V.mat)*[cat(1,CONN_h.menus.m_results.roiresults.xyz{nsources}),ones(numel(nsources),1)]';
                        [nill,idxsort]=sort(xyz(3,:));
                        CONN_h.menus.m_results_00{26}=cat(2,CONN_h.menus.m_results_00{26},patch(conn_bsxfun(@plus,xyz(1,idxsort),4*xtemp),conn_bsxfun(@plus,xyz(2,idxsort),4*ytemp),'w','facecolor','k','edgecolor',.25*[1,1,1]));
                        CONN_h.menus.m_results.roiresults.displayrois=cat(1,CONN_h.menus.m_results.roiresults.displayrois,[cat(1,CONN_h.menus.m_results.roiresults.xyz2{nsources}),2*4*ones(numel(nsources),1),0*ones(numel(nsources),1), xyz(1:2,:)', reshape(nsources,[],1)]);
                        CONN_h.menus.m_results.roiresults.displayroisnames=cat(2,CONN_h.menus.m_results.roiresults.displayroisnames,CONN_h.menus.m_results.roiresults.names2(nsources));
                    end
                    %hold off;
                    
                    if numel(CONN_h.menus.m_results_00{26})>1, set(CONN_h.menus.m_results_00{26}(cellfun(@isempty,get(CONN_h.menus.m_results_00{26},'buttondown'))),'buttondownfcn','conn(''gui_results'',26);');
                    elseif numel(CONN_h.menus.m_results_00{26})==1&&isempty(get(CONN_h.menus.m_results_00{26},'buttondown')), set(CONN_h.menus.m_results_00{26},'buttondown','conn(''gui_results'',26);'); 
                    end
                    set(findobj(CONN_h.menus.m_results_00{25}),'visible','on');
                    set(CONN_h.menus.m_results_00{25},'visible','off');
                else
                    set(findobj(CONN_h.menus.m_results_00{25}),'visible','off');
                end
                delete(tobedeleted);
            end
		
        case 'gui_results_roiview',
            conn_displayroi('init','results_roi',CONN_x.Results.xX.nsources,-1);
            return;

        case 'gui_results_roi3d'
            c={[0,0,1],[.25,.25,.25],[1,0,0]};
            conn_mesh_display('','',[],struct('sph_names',{CONN_h.menus.m_results.roiresults.displayroisnames},'sph_xyz',CONN_h.menus.m_results.roiresults.displayrois(:,1:3),'sph_r',CONN_h.menus.m_results.roiresults.displayrois(:,4),'sph_c',{c(2+sign(CONN_h.menus.m_results.roiresults.displayrois(:,5)))}), [], .25, [0,-.01,1]);
            return
            
        case 'gui_results_wholebrain',
            %if ~CONN_x.Setup.normalized, warndlg('Second-level voxel-level analyses not available for non-normalized data'); return; end
            if CONN_x.Results.xX.modeltype==2, uiwait(warndlg('Second-level fixed-effects voxel-level analyses not implemented')); return; end
            CONN_x.Results.foldername='';
            conn_process('results_voxel','readsingle','seed-to-voxel');
            set(CONN_h.screen.hfig,'pointer','arrow');
            return;
            
        case 'gui_results_graphtheory',
            conn_displaynetwork('init',CONN_x.Results.xX.nsources);
            return;
            
		case 'gui_results_done',
			%if isempty(CONN_x.filename), conn gui_setup_save; end
            if conn_questdlg('Ready to Compute results for all sources',false,[0 1 0],false,true); 
                conn_menumanager clf;
                conn_menuframe;
                conn_menumanager([CONN_h.menus.m_setup_06,CONN_h.menus.m0],'on',1);
                CONN_x.Results.foldername='';
                drawnow;
                conn_process('results_voxel','doall','seed-to-voxel');
                CONN_x.gui=1;
                %conn gui_setup_save;
                conn gui_results;
            end
			%conn_menumanager clf;
			%axes('units','norm','position',[0,.935,1,.005]); image(shiftdim([0 0 0]+.4+.2*(mean(CONN_gui.backgroundcolorA)<.5),-1)); axis off;
			%conn_menumanager([CONN_h.menus.m0],'on',1);
			%conn gui_setup_save;
%             CONN_x.gui=0;
%             CONN_x.Results.foldername='';
%             conn_process('results');
%             if CONN_x.Setup.steps(1)&&~CONN_x.Setup.steps(2),% || ~CONN_x.Setup.normalized, 
%                 conn_process('results_roi');
%             else
%                 conn_process('results');
%             end
%             CONN_x.gui=1;
% 			conn gui_setup_save;
%             set(CONN_h.screen.hfig,'pointer','arrow')
            return;

        case 'gui_results_searchseed'
            if ~CONN_x.Setup.steps(1), disp('need to select ''voxel-to-voxel'' checkbox in Setup->Options and run Setup/Denoising/first-level Analyses'); return;
            elseif ~isfield(CONN_x.vvAnalyses,'measures'), disp('need to run first-level voxel-to-voxel analyses first'); return;
            end
            sources=CONN_x.vvAnalyses.measures;
            iroi=zeros(size(sources));isnew=iroi;ncomp=iroi;
            for n1=1:numel(sources),[iroi(n1),isnew(n1),ncomp(n1)]=conn_v2v('match_extended',sources{n1});end
            idx=strmatch('connectome-MVPA',sources);
            if isempty(idx), disp('need to run first-level voxel-to-voxel analyses first'); 
            else
                idx=find(iroi==iroi(idx(find(~isnew(idx),1))));
                CONN_x.Results.xX.nmeasures=idx;
                CONN_x.Results.xX.cmeasures=eye(numel(idx));
                CONN_x.Results.foldername='';
                conn_process('results_voxel','readsingle','voxel-to-voxel');
            end 
            set(CONN_h.screen.hfig,'pointer','arrow');
            return;
            
        case 'gui_results_wholebrain_vv',
            CONN_x.Results.foldername='';
            conn_process('results_voxel','readsingle','voxel-to-voxel');
            set(CONN_h.screen.hfig,'pointer','arrow');
            return;

%         case 'gui_results_done_vv',
% 			%if isempty(CONN_x.filename), conn gui_setup_save; end
%             %if conn_questdlg('Ready to Compute results for all sources',false,[0 1 0],false);
%                 conn_menumanager clf;
%                 conn_menuframe;
%                 conn_menumanager([CONN_h.menus.m_setup_06,CONN_h.menus.m0],'on',1);
%                 CONN_x.Results.foldername='';
%                 conn_process('results_voxel','doall','voxel-to-voxel');
%                 CONN_x.gui=1;
%                 %conn gui_setup_save;
%                 conn gui_results;
%             %end
%             return;
            
        otherwise,
            if ~isempty(which(sprintf('conn_%s',varargin{1}))),
                fh=eval(sprintf('@conn_%s',varargin{1}));
                [varargout{1:nargout}]=feval(fh,varargin{2:end});
            else
                disp(sprintf('unrecognized option %s or conn_%s function',varargin{1},varargin{1}));
            end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%			

    end
end

catch me
    if dodebug
        if isempty(me), error(lasterror); %Matlab<=2007a
        else me.rethrow; 
        end
    else
        if ~isfield(CONN_gui,'font_offset'), CONN_gui.font_offset=0; end
        if isfield(CONN_x,'filename'), filename=CONN_x.filename; else filename=[]; end
        [str,PrimaryMessage]=conn_errormessage(me,filename);
        checkdesktop=true;
        try, checkdesktop=usejava('awt'); end
        if ~checkdesktop
            fprintf(2,'%s\n',str{:});
        else
            h=[];
            set(findobj(0,'tag','conn_timedwaitbar'),'windowstyle','normal');
            h.fig=dialog('windowstyle','normal','name','CONN could not complete this action','color','w','resize','on','units','norm','position',[.2 .4 .4 .2],'handlevisibility','callback','windowstyle','modal');
            h.button1=uicontrol(h.fig,'style','pushbutton','units','norm','position',[.1 .75 .8 .2],'fontsize',9+CONN_gui.font_offset,'string',PrimaryMessage);
            h.edit1=uicontrol(h.fig,'style','edit','units','norm','position',[.1 .30 .8 .65],'backgroundcolor','w','max',2,'fontsize',9+CONN_gui.font_offset,'horizontalalignment','left','string',str,'visible','off');
            h.edit2=uicontrol(h.fig,'style','edit','units','norm','position',[.1 .3 .8 .4],'backgroundcolor','w','max',2,'fontsize',8+CONN_gui.font_offset,'fontangle','italic','string',{'For support information see HELP->SUPPORT or HELP->FAQ','To check for patches and updates see HELP->UPDATES','If requesting support about this error please provide the full error message'});
            h.button2=uicontrol(h.fig,'style','pushbutton','units','norm','position',[.1 .05 .25 .2],'string','Visit support forum','callback',@(varargin)conn('gui_help','url','http://www.nitrc.org/forum/forum.php?forum_id=1144'),'tooltipstring','http://www.nitrc.org/forum/forum.php?forum_id=1144');
            h.button3=uicontrol(h.fig,'style','pushbutton','units','norm','position',[.4 .05 .25 .2],'string','Visit FAQ website','callback',@(varargin)conn('gui_help','url','http://www.alfnie.com/software/conn'),'tooltipstring','http://www.alfnie.com/software/conn');
            h.button4=uicontrol(h.fig,'style','pushbutton','units','norm','position',[.7 .05 .2 .2],'string','Close','callback','delete(gcbf)');
            set(h.button1,'userdata',h,'callback','h=get(gcbo,''userdata'');set(h.fig,''position'',get(h.fig,''position'')+[0,0,0,.3]);set(h.button1,''visible'',''off'');set(h.edit1,''position'',[.1 .30 .8 .65],''visible'',''on'');set(h.edit2,''position'',[.1 .12 .8 .18]);set(h.button2,''position'',[.1 .025 .25 .07]);set(h.button3,''position'',[.4 .025 .25 .07]);set(h.button4,''position'',[.7 .025 .2 .07]);');
        end
    end
end

    function conn_orthogonalizemenuupdate(varargin)
        tnl2covariates_other=nl2covariates_other(get(ht1,'value'));
        if get(ht2,'value'), tnl2covariates_subjects=find(any(X(:,nl2covariates)~=0,2)&~any(isnan(X(:,nl2covariates)),2)&~any(isnan(X(:,tnl2covariates_other)),2)); 
        else tnl2covariates_subjects=find(~any(isnan(X(:,nl2covariates)),2)&~any(isnan(X(:,tnl2covariates_other)),2)); end
        x=X;
        x(tnl2covariates_subjects,nl2covariates)=X(tnl2covariates_subjects,nl2covariates)-X(tnl2covariates_subjects,tnl2covariates_other)*(pinv(X(tnl2covariates_subjects,tnl2covariates_other))*X(tnl2covariates_subjects,nl2covariates));
        t=x(:,nl2covariates)';
        set(ht3,'string',mat2str(t,max([0,ceil(log10(max(1e-10,abs(t(:)'))))])+6));
        %k=t; for n=0:6, if abs(round(k)-k)<1e-6, break; end; k=k*10; end;
        %set(ht3,'string',num2str(t,['%0.',num2str(n),'f ']));
    end

end


function ok=conn_questdlg(str,stepsoption,steps,condsoption,dispoption,paroption,multipleoption)
global CONN_x CONN_gui;
if nargin<7||isempty(multipleoption), multipleoption=false; end
if nargin<6||isempty(paroption), paroption=false; end
if nargin<5||isempty(dispoption), dispoption=[]; end
if nargin<4||isempty(condsoption), condsoption=true; end
if nargin<3||isempty(steps), steps=CONN_x.Setup.steps(1:3); end
if nargin<2||isempty(stepsoption), stepsoption=true; end
thfig=figure('units','norm','position',[.4,.5,.4,.3],'color','w','name','CONN data processing pipeline','numbertitle','off','menubar','none');
ht3=uicontrol('style','text','units','norm','position',[.1,.8,.8,.15],'string',str,'backgroundcolor','w','fontsize',9+CONN_gui.font_offset,'fontweight','bold');
ht2a=uicontrol('style','checkbox','units','norm','position',[.1,.7,.4,.10],'string','ROI-to-ROI','value',steps(1),'fontsize',8+CONN_gui.font_offset,'backgroundcolor','w');
ht2b=uicontrol('style','checkbox','units','norm','position',[.1,.6,.4,.10],'string','Seed-to-Voxel','value',steps(2),'fontsize',8+CONN_gui.font_offset,'backgroundcolor','w');
ht2c=uicontrol('style','checkbox','units','norm','position',[.1,.5,.4,.10],'string','Voxel-to-Voxel','value',steps(3),'fontsize',8+CONN_gui.font_offset,'backgroundcolor','w');
if numel(steps)>3, 
    ht2d=uicontrol('style','checkbox','units','norm','position',[.1,.4,.4,.10],'string','Dynamic FC','value',steps(4),'fontsize',8+CONN_gui.font_offset,'backgroundcolor','w');
else ht2d=[]; 
end
ht4b=uicontrol('style','listbox','units','norm','position',[.5,.5,.4,.2],'string',CONN_x.Setup.conditions.names(1:end-1),'value',1,'fontsize',8+CONN_gui.font_offset,'max',2);
ht4a=uicontrol('style','checkbox','units','norm','position',[.5,.7,.4,.10],'string','All conditions','value',all(islogical(condsoption)),'fontsize',8+CONN_gui.font_offset,'backgroundcolor','w','userdata',ht4b,'callback','h=get(gcbo,''userdata'');if get(gcbo,''value''), set(h,''visible'',''off''); else set(h,''visible'',''on''); end');
ht4d=uicontrol('style','listbox','units','norm','position',[.5,.5,.4,.2],'string',{'Setup step','Denoising step','First-level analysis step'},'value',1,'fontsize',8+CONN_gui.font_offset,'max',2);
ht4c=uicontrol('style','checkbox','units','norm','position',[.5,.7,.4,.10],'string','All Steps','value',0,'fontsize',8+CONN_gui.font_offset,'backgroundcolor','w','userdata',ht4d,'callback','h=get(gcbo,''userdata'');if get(gcbo,''value''), set(h,''visible'',''off''); else set(h,''visible'',''on''); end');
if multipleoption, condsoption=false; end
if ~stepsoption, set([ht2a,ht2b,ht2c,ht2d],'enable','off'); end
if ~all(islogical(condsoption)), set(ht4b,'value',condsoption); 
elseif condsoption, set([ht4b],'visible','off'); 
else set([ht4a,ht4b],'visible','off'); 
end
if ~all(islogical(multipleoption)), set(ht4d,'value',multipleoption); 
elseif multipleoption, %set([ht4d],'visible','off'); 
else set([ht4c,ht4d],'visible','off'); 
end
if ~isempty(dispoption), ht5=uicontrol('style','popupmenu','units','norm','position',[.1,.32,.8,.08],'string',{'do not display GUI','display GUI'},'value',1+dispoption,'fontsize',8+CONN_gui.font_offset,'backgroundcolor','w'); else ht5=[]; end
ht1=uicontrol('style','popupmenu','units','norm','position',[.1,.24,.8,.08],'string',{'proceed for all subjects/seeds (overwrite existing results)','skip already-processed subjects/seeds (do not overwrite)','ask user on each individual analysis step'},'value',1,'fontsize',8+CONN_gui.font_offset);
if paroption, 
    [tstr,tidx]=conn_jobmanager('profiles'); 
    tstr=cellfun(@(x)sprintf('distributed processing: %s',x),tstr,'uni',0);
    tstr{tidx}=sprintf('<HTML><b>%s</b></HTML>',tstr{tidx});
    ht0=uicontrol('style','popupmenu','units','norm','position',[.1,.16,.8,.08],'string',[{'local processing'} tstr],'value',1,'fontsize',8+CONN_gui.font_offset); 
end
uicontrol('style','pushbutton','string','Start','units','norm','position',[.1,.01,.38,.13],'callback','uiresume','fontsize',9+CONN_gui.font_offset);
uicontrol('style','pushbutton','string','Cancel','units','norm','position',[.51,.01,.38,.13],'callback','delete(gcbf)','fontsize',9+CONN_gui.font_offset);
uiwait(thfig);
ok=ishandle(thfig);
if ok
    switch get(ht1,'value')
        case 1, CONN_x.gui=struct('overwrite','Yes','display',1,'parallel',0);
        case 2, CONN_x.gui=struct('overwrite','No','display',1,'parallel',0);
        case 3, CONN_x.gui=struct('display',1,'parallel',0);
    end
    if ~isempty(ht5)&&isequal(get(ht5,'value'),1), CONN_x.gui.display=0; end
    if stepsoption
        CONN_x.gui.steps=CONN_x.Setup.steps;
        CONN_x.gui.steps(1)=get(ht2a,'value');
        CONN_x.gui.steps(2)=get(ht2b,'value');
        CONN_x.gui.steps(3)=get(ht2c,'value');
        if ~isempty(ht2d), CONN_x.gui.steps(4)=get(ht2d,'value'); end
    end
    if get(ht4a,'value'), CONN_x.gui.conditions=1:numel(CONN_x.Setup.conditions.names)-1;
    else CONN_x.gui.conditions=get(ht4b,'value');
    end
    if multipleoption
        if get(ht4c,'value'), CONN_x.gui.processes=1:3;
        else CONN_x.gui.processes=get(ht4d,'value');
        end
    end
    if paroption, 
        temp=get(ht0,'value'); 
        if temp>1, CONN_x.gui.display=0; CONN_x.gui.parallel=temp-1; end
        if temp>1&&~isfield(CONN_x.gui,'overwrite'), 
            ok=false;
            uiwait(errordlg('Sorry, parallelization jobs cannot depend on user-input. Select explicit ''proceed for all subjects/seeds'' or ''skip already-processed subjects/seeds'' options',''));
        end
    end
    delete(thfig);
end
end

function [hpatches1,hpatches2]=conn_plotbars(cbeta,CI,M)
if nargin<3||isempty(M), M=[0 0 0 1 1 1]; end
dx=size(cbeta,1)/(numel(cbeta)+.5*size(cbeta,1));
xx=1*repmat((1:size(cbeta,1))',[1,size(cbeta,2)])+repmat((-(size(cbeta,2)-1)/2:(size(cbeta,2)-1)/2)*dx,[size(cbeta,1),1]);
hax=gca;
color=get(hax,'colororder');
color(all(color==1,2),:)=[];%xxd=.4/size(cbeta,2)/2;
hpatches1=zeros(size(cbeta));
hpatches2=zeros(size(cbeta));
for n1=1:numel(xx),
    color0=color(1+rem(ceil(n1/size(cbeta,1))-1,size(color,1)),:);
    h=patch(M(1)+M(4)*(xx(n1)+dx*[-1,-1,1,1]/2.25),M(2)+M(5)*(cbeta(n1)*[0,1,1,0]),M(3)+M(6)*[1 1 1 1], 'k','facecolor',1-(1-color0)/4,'edgecolor','none');
    set(h,'facecolor',color0);
    hpatches1(n1)=h;
    h=line(M(1)+M(4)*(xx(n1)+[1,-1,0,0,1,-1]*dx/8),M(2)+M(5)*(cbeta(n1)+CI(n1)*[-1,-1,-1,1,1,1]),M(3)+M(6)*[2 2 2 2 2 2],'linewidth',2,'color',1-(1-color0)/4);
    hpatches2(n1)=h;
    set(h,'color','k');
end
end

function conn_menuframe(varargin)
global CONN_gui CONN_x;
axes('units','norm','position',[0,0,1,1]); 
ok=false;
if isfield(CONN_gui,'background')
    try
        if isnumeric(CONN_gui.background)&&size(CONN_gui.background,3)==3, CONN_gui.background_handle=image(CONN_gui.background); ok=true;
        elseif isnumeric(CONN_gui.background)&&~isempty(CONN_gui.background), CONN_gui.background_handle=image(max(0,min(1, conn_bsxfun(@times,(double(CONN_gui.background)-double(min(CONN_gui.background(:))))/(double(max(CONN_gui.background(:)))-double(min(CONN_gui.background(:)))),2*shiftdim(CONN_gui.backgroundcolor,-1))))); ok=true;
        end
    end
end
if ~ok, CONN_gui.background_handle=[]; end; 
%if ~ok, CONN_gui.background_handle=image(max(0,min(1,conn_bsxfun(@plus,(.85-mean(CONN_gui.backgroundcolor))*.2*[zeros(1,128) sin(linspace(0,pi,128)).^2 zeros(1,128)]',shiftdim(CONN_gui.backgroundcolor,-1))))); end
%if ~ok, CONN_gui.background_handle=image(max(0,min(1,conn_bsxfun(@plus,conn_bsxfun(@times,max(.05,(1-mean(CONN_gui.backgroundcolor))*.1)*[zeros(1,128) sin(linspace(0,pi,128)).^4 zeros(1,128)]',shiftdim(CONN_gui.backgroundcolor/max(.01,mean(CONN_gui.backgroundcolor)),-1)),shiftdim(CONN_gui.backgroundcolor,-1))))); end
hc1=uicontextmenu; uimenu(hc1,'label','<HTML>Change GUI font size (<i>Tools.GUI settings</i>)</HTML>','callback','conn(''gui_settings'');'); set(CONN_gui.background_handle,'uicontextmenu',hc1);
axis tight off;
if isfield(CONN_x,'filename')
%     try
        if isempty(CONN_x.filename), a=java.io.File(pwd);
        else a=java.io.File(fileparts(CONN_x.filename));
        end
        k1=a.getUsableSpace;
        k2=a.getTotalSpace;
        k0=a.canWrite;
        clear a;
        k=max(0,min(1, 1-k1/k2));
        c=ones(10,100);
        if k2==0
            c(:)=2;
            str='Storage disconnected or unavailable';
        else
            c(2:end-1,1:round(k*100))=2;
            if k0, str0=''; else str0='(read-only)'; end
            str=sprintf('storage: %.1fGb available (%d%%) %s',(k1*1e-9),round((1-k)*100),str0);
        end
        d=max(0,min(1, mod(conn_bsxfun(@times,1+1*c,shiftdim(CONN_gui.backgroundcolor,-1)),1.1) ));
        d(conn_bsxfun(@plus,[0 2]*numel(c),find(c==2)))=d(conn_bsxfun(@plus,[2 0]*numel(c),find(c==2)));
        axes('units','norm','position',[.425,.0,.05,.020]); ht=image(d); axis tight off; set(ht,'tag','infoline:bar');
        ht=conn_menu('text2',[.485,.00,.25,.025],'',str);
        set(ht,'horizontalalignment','left','fontsize',8+CONN_gui.font_offset,'color',CONN_gui.fontcolorA,'tag','infoline:text');
        %text(120,(size(c,1))/2,str,'horizontalalignment','left','fontsize',5+CONN_gui.font_offset,'color',[.5 .5 .5]+.0*(mean(CONN_gui.backgroundcolor)<.5));
%     end
end
c=zeros(36,62);
c([149:176 185:212 221:248 257:284 293:320 329:356 509:528 545:564 581:600 617:636 653:672 689:708 869:896 905:932 941:968 977:1004 1013:1040 1049:1076 1229:1234 1239:1256 1265:1270 1275:1292 1301:1306 1311:1328 1337:1342 1347:1364 1373:1378 1383:1400 1409:1414 1419:1436 1589:1594 1599:1616 1625:1630 1635:1652 1661:1666 1671:1688 1697:1702 1707:1724 1733:1738 1743:1760 1769:1774 1779:1796 1805:1810 1841:1846 1877:1882 1913:1918 1949:1954 1985:1990 2021:2026 2057:2062])=1;
c([1239:1256 1275:1292 1311:1328 1347:1364 1383:1400 1419:1436])=2;
c=[[zeros(2,32); kron([0 0 1 1 1 1 1 1;1 1 2 2 2 2 1 1;1 2 3 2 2 3 2 1;1 2 2 0 0 2 2 1;1 2 2 0 0 2 2 1;1 2 2 2 2 3 2 1;1 2 2 2 2 2 1 0;0 1 1 1 1 1 1 0]*2/3,ones(4)); zeros(2,32)] zeros(36,12) c];
b0=shiftdim(CONN_gui.backgroundcolor,-1); 
ha=axes('units','norm','position',[.94,.001,.06,.06],'units','pixels'); 
if isfield(CONN_gui,'background'), b0=conn_guibackground('get',get(ha,'position'),size(c)); end
d=max(0,min(1, conn_bsxfun(@plus,conn_bsxfun(@times,.2*conn_bsxfun(@times,sign(.5-mean(b0,3)),rand*ones([1,1,3])),c),b0) ));
hi=image(d); axis equal off;
axis equal tight;
%hb=uicontrol('units','norm','position',[.8 .001 .2 .10],'style','text','string',{'The Gabrieli Lab at MIT. McGovern Institute for Brain Research'},'fontsize',7+CONN_gui.font_offset,'foregroundcolor','k','backgroundcolor','w','visible','off','horizontalalignment','left');
%hext=get(hb,'extent'); hext=hext(end-1:end); set(hb,'position',[1-hext(1) .001 hext(1) hext(2)]);
%conn_menumanager('onregion',hb,1,[.95 .001 .04 .05]);

%set(gca,'units','pixels'); pos=get(gca,'position'); set(gca,'position',[pos(1)+pos(3)-size(c,2) pos(2) size(c,2) size(c,1)]);
end

function conn_closerequestfcn(varargin)
global CONN_gui;
answ=questdlg({'Closing this figure will exit CONN and loose any unsaved progress','Do you want to:'},'Warning','Exit CONN','Continue','Exit CONN');
if isempty(answ), answ='Continue'; end
switch(answ)
    case 'Exit CONN',
        CONN_gui.status=1;
        delete(gcbf);
        CONN_x.gui=0;
        try
            if isfield(CONN_gui,'originalCOMB'),javax.swing.UIManager.put('ComboBoxUI',CONN_gui.originalCOMB); end
            if isfield(CONN_gui,'originalBORD'),javax.swing.UIManager.put('ToggleButton.border',CONN_gui.originalBORD); end
            if isfield(CONN_gui,'originalLAF'), javax.swing.UIManager.setLookAndFeel(CONN_gui.originalLAF); end
        end
    otherwise
        conn gui_setup;
end
end

function conn_deletefcn(varargin)
global CONN_gui;
try
    if ~CONN_gui.status
        conn('save',sprintf('CONN_autorecovery_project_%s.mat',datestr(now,'dd-mmm-yyyy-HH-MM-SS')));
        uiwat(warndlg({'CONN has been closed unexpectedly',' ',sprintf('Autorecovery project created at %s/CONN_autorecovery_project_%s.mat\n',pwd,datestr(now,'dd-mmm-yyyy-HH-MM-SS'))}));
    end
end
end

function conn_resizefcn(varargin)
global CONN_h CONN_gui;
try
    tstate=conn_menumanager(CONN_h.menus.m0,'state');
    switch(find(tstate))
        case 1, conn gui_setup;
        case 2, conn gui_preproc;
        case 3, conn gui_analyses;
        case 4, conn gui_results;
    end
end
end