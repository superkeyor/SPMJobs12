% display a or many marbar roi.mat
% main(mat), mat could be a str or cellstr, returns nothing
% if marsbar not in searchpath, auto add

function main(mat)
    if (isempty(which('marsbar'))||isempty(which('spm_get')))
        ez.print('addpath marsbar...')
        extsPath = ez.joinpath(ez.parentdir(ez.parentdir(ez.csd())), 'extensions');
        thePath = ez.lsd(extsPath,'^marsbar');
        thePath = ez.joinpath(extsPath,thePath{1});
        addpath(thePath,'-end');
        % additional path that would be added by marsbar
        addpath(ez.joinpath(thePath,'spm5'),'-end');
    end

    outname = char(mat);
    spmpath = fileparts(which('spm'));

    % mars_display_roi('display',outname,fullfile(spmpath,'canonical','avg152T1.nii'));
    mars_display_roi('display',outname,fullfile(spmpath,'canonical','single_subj_T1.nii'));
end