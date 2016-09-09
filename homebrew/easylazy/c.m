% use xjview to open all/specified contrasts in SPM.mat in working directory
% conseq: [30:-1:1] the contrast sequence to open
%         if not provided, default is all contrasts

function varargout = main(conseq)
    % ez.clean();
    % close previous xjview windows
    figs = sort(findobj(0,'type','figure'));
    for iii = 1:ez.len(figs);
        fig = figs(iii);
        if strfind(fig.Name,'xjView')
            ez.print(['closing previous ' fig.Name ' ...']);
            close(fig); 
        end
    end

    load('SPM.mat');
    ncons = length(SPM.xCon);
    names = {SPM.xCon.name};

    if ~exist('conseq','var') 
        conseq = [ncons:-1:1];
    else
        if isstr(conseq); conseq = str2num(conseq); end;
    end
    
    % these variables may interefer with xjview
    evalin('base','clear hReg SPM TabDat xSPM');
    for i = conseq; eval(sprintf('xjview spmT_00%02d.nii',i)); set(gcf,'numbertitle','off','name',[get(gcf,'name') '  ' names{i}]); end
    % close all warning dialog
    warnings = findall(0,'type','figure','name','Warning Dialog');
    close(warnings);
end