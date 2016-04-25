% use xjview to open all/specified contrasts in SPM.mat in working directory
% conseq: [30:-1:1] the contrast sequence to open
%         if not provided, default is all contrasts

function varargout = main(conseq)
    % ez.clean();
    load('SPM.mat');
    ncons = length(SPM.xCon);
    names = {SPM.xCon.name};

    if ~exist('conseq','var') 
        conseq = [ncons:-1:1];
    else
        if isstr(conseq); conseq = str2num(conseq); end;
    end

    for i = conseq; eval(sprintf('xjview spmT_00%02d.nii',i)); set(gcf,'numbertitle','off','name',[get(gcf,'name') '  ' names{i}]); end
    % close all warning dialog
    warnings = findall(0,'type','figure','name','Warning Dialog');
    close(warnings);
end