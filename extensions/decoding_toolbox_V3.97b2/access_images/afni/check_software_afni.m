function checked = check_software_afni(software)

if strcmpi(software(1:4),'afni')
    if ~isempty(which('BrikInfo.m'))
        checked = true;
    else
        error('afni_matlab is not on your Matlab path! Please add a version of afni_matlab (http://afni.nimh.nih.gov/afni/matlab/) to your path using e.g. addpath or change cfg.software to another software')
    end
else 
    % software does not start with AFNI, should not happen here
    error('cfg.software does not start with AFNI. This should not happen here')
end