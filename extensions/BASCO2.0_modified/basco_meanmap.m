function basco_meanmap(handles)
% get data
tmppath = pwd;
cd(fullfile(handles.anaobj{1}.Ana{1}.AnaDef.DataPath,handles.anaobj{1}.Ana{1}.AnaDef.OutDir));
[file] = uigetfile('*.nii','Select maps.','MultiSelect','on');
cd(tmppath);
thedir = uigetdir('Select output directory');  
fname1 = file;
cd(thedir);
idxsubj   = str2num(get(handles.editsubjectselection,'String'));
Nsubj     = length(idxsubj); % number of selected subjects
NumSubj   = handles.NumJobs;
thefiles1 = cell(1,NumSubj);
vol1      = [];
for isubj=1:NumSubj % loop over subjects
   data_path  = handles.anaobj{isubj}.Ana{1}.AnaDef.DataPath;
   outdirname = handles.anaobj{isubj}.Ana{1}.AnaDef.OutDir;
   thefiles1{isubj} = fullfile(data_path,outdirname,fname1);
   % get volumes
   vol1 = [vol1 spm_vol(thefiles1{isubj})];
end % end loop over subjects
% calculate mean image
flags{1} = 1;
fname1 = strrep(fname1,'.img','.nii');
fprintf('Mean image saved to: %s \n',['mean_' fname1]);
volout = vol1(1);
volout.fname = ['mean_' fname1];
spm_imcalc(vol1,volout,'mean(X)',flags);
