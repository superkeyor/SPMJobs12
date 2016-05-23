% (conditions, ROIs);
% 
% author = jerryzhujian9@gmail.com
% date: Fri, May 13 2016, 04:47:12 PM EDT(-0400)

ez.clean();

conditions = {'comp_e','nc_e','comp_mce','nc_mce'};
% conditions = {'comp_e'};
conditionsPath = ez.pwd;

startTime = ez.moment();
cd(conditionsPath);

data = {};
data{1,1} = 'SUBJID';
data{2,end+1} = ;
total = 2; % total columns in data in addition to SUBJID
for n = 1:ez.len(conditions)
    condition = conditions{n};
    conditionPath = ez.joinpath(conditionsPath,condition);
    cd(conditionPath);
    mats = ez.ls(conditionPath,'voi_.*_[LR].mat',0);

    for m = 1:ez.len(mats)
        mat = mats{m};
        matstr = strrep(mat,'voi_(+)','plus_');
        matstr = strrep(matstr,'voi_(-)','minus_');
        matstr = strrep(matstr,'.mat','');
        data{2,end+1} = matstr;
        load(mat);
        Y =num2cell(Y);
        data(2:length(Y)+1,total)= Y(:);
        total = total + 1;
        ez.pprint('****************************************'); % pretty colorful print
    end

    cd(conditionsPath);
end
cd(conditionsPath);
ez.cell2csv('VOIs.csv',data);

ez.pprint('Done!');
finishTime = ez.moment();
%------------- END OF CODE --------------