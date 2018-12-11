function [names, R] = main(df, idcol, ids, covars, matname)
    % make covariates mat file for 2nd level
    % (df, idcol, ids, covars, matname)
    % df: table, like df in R
    % idcol: col name as unique id to match rows
    % ids: a cell array containing ids in certain order
    % covars: a cell array containing col names as covariates (not include idcol), if {''}, no file will be generated
    % matname: path to covariate mat, default covar2ndlvl.mat in pwd
    % 
    % example, typical usage: 
    % CN = nbk(strcmp(nbk.dx,'CN'),:);
    % SCD = nbk(strcmp(nbk.dx,'SCD'),:);
    % MCI = nbk(strcmp(nbk.dx,'MCI'),:);
    % ids = [CN.linkid; SCD.linkid; MCI.linkid];
    % do_make_covariates_2ndlevel(nbk,'linkid',ids,{'ageMRI','sex','educ'});
    
    % no file will be generated
    if strcmp(covars{1},''), return; end
    
    if nargin==4, matname='covar2ndlvl.mat'; end

    % https://www.mathworks.com/matlabcentral/answers/22926-finding-the-indices-of-the-elements-of-one-array-in-another
    [~,idx] = ismember(ids, eval(sprintf('df.%s',idcol)));
    R = df(idx,covars);
    R = table2array(R);
    names = covars;
    save(matname,'names','R');
end

