function main(folder)
% delete all old SPM analysis files in a folder
if nargin<1, folder=pwd; end

files = {'^mask\..{3}$','^ResMS\..{3}$','^RPV\..{3}$',...
            '^beta_.{4}\..{3}$','^con_.{4}\..{3}$','^ResI_.{4}\..{3}$',...
            '^ess_.{4}\..{3}$', '^spm\w{1}_.{4}\..{3}$', 'SPM.mat'};

for i=1:length(files)
    j = spm_select('FPList',fullfile(folder),files{i});
    for k=1:size(j,1)
        spm_unlink(deblank(j(k,:)));
    end
end

end

