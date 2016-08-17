function [edge,node] = basco_CreateNodeEdgeFiles(idx,compos,shortlabel,nwmatrix,basename)
edge = '';
node = '';
if nargin<5, basename='';end


disp('To save .node and .edge files, specify base filename...');
[fname, fdir, fidx] = uiputfile('*.*','save .node and .edge files...',basename);
if isequal(fname,0),disp('User Cancelled'); return; end
fprintf('Number of edges: %d \n',nnz(nwmatrix));
dlmwrite(fullfile(fdir,[fname '.edge']),nwmatrix,'\t');
fileID = fopen(fullfile(fdir,[fname '.node']),'w');
for iroi=idx
    fprintf(fileID,'%.2f\t%.2f\t%.2f\t1.0\t0.3\t%s\n',compos(1,iroi),compos(2,iroi),compos(3,iroi),shortlabel{iroi});
end
fclose(fileID);

edge = fullfile(fdir,[fname '.edge']);
node = fullfile(fdir,[fname '.node']);
end

