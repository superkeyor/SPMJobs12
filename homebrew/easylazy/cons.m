% use xjview to open all contrasts in SPM.mat in working directory
% accepts no arg

function varargout = main(varargin)
    % ez.clean();
    load('SPM.mat');
    ncons = length(SPM.xCon);
    names = {SPM.xCon.name};
    for i = [ncons:-1:1]; eval(sprintf('xjview spmT_00%02d.nii',i)); set(gcf,'numbertitle','off','name',[get(gcf,'name') '  ' names{i}]); end

    % close all warning dialog
    warnings = findall(0,'type','figure','name','Warning Dialog');
    close(warnings);
end