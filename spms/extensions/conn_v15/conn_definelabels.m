function lfilename=conn_definelabels(filename)
[filename_path,filename_name,filename_ext]=fileparts(deblank(filename));
lfilename=fullfile(filename_path,[filename_name,'.csv']);
if ~isempty(dir(lfilename)),
    answ=questdlg(sprintf('Warning: labels file %s already exists. Overwrite?',lfilename),'Warning','Yes','No','No');
    if ~strcmp(answ,'Yes'), return; end
end
[tvalues,tnames]=conn_rex(filename,filename,'summary_measure','mean','level','clusters','select_clusters',0,'output_type','none');
for n1=1:numel(tnames), if ~isempty(strmatch(filename_path,tnames{n1})), tnames{n1}=[tnames{n1}(numel(filename_path)+2:end)]; end; end
fh=fopen(lfilename,'wt');
fprintf(fh,'%s,%s\n','ROIname','ROIid');
for n1=1:numel(tnames),
    fprintf(fh,'%s,%d\n',tnames{n1},tvalues(n1));
end
fclose(fh);
fprintf('Created labels file %s with default ROI labels. Edit this file to modify these labels\n',lfilename);
end
