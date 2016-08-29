% display a marbar roi.mat
% main(mat), returns nothing
% if marsbar not in searchpath, auto add

function main(mat)
    if isempty(which('marsbar'))
        ez.print('addpath marsbar...')
        extsPath = ez.joinpath(ez.parentdir(ez.parentdir(ez.csd())), 'extensions');
        thePath = ez.lsd(extsPath,'^marsbar');
        thePath = ez.joinpath(extsPath,thePath{1});
        addpath(thePath);
    end

    outname = mat;
    spmpath = fileparts(which('spm'));

    mars_display_roi('display',outname,fullfile(spmpath,'canonical','avg152T1.nii'));
end