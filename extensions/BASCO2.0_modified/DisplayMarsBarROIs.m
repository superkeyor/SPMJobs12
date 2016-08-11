function DisplayMarsBarROIs(ListOfROIFiles,selection)
if nnz(selection)==0
    disp('No nodes selected.');
    return;
end
NumROIs = length(selection);
k=0;
for j=1:NumROIs,
    if selection(j)==1
        k=k+1;
        ROIFiles{k} = ListOfROIFiles{j};
    end
end
spmpath = fileparts(which('spm'));
mars_display_roi('display',ROIFiles,fullfile(spmpath,'canonical','avg152T1.nii'));
end
