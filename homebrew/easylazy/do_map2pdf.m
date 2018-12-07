function varargout = main(nii_stats_map,pdfpath)
    % call xjview to show an activation map (eg, spmT, spmF map), append the map to a pdf file
    % (nii_stats_map,pdfpath)
    % nii_stats_map: file path to nii stats map
    % pdfpath: file path to pdf. if exisit, would append with bookmark; otherwise new pdf file
    xjview(nii_stats_map)
    warningdlgs = findall(0,'type','figure','name','Warning Dialog');
    close(warningdlgs);
    errordlgs = findall(0,'type','figure','name','error');
    close(warningdlgs);
    ez.export(pdfpath,'nocrop','bookmark','append');
    close all;
end