function varargout = main(df, idcol, ids, covars, matname)
    % make covariates mat file for 2nd level
    % (df, idcol, ids, covars, matname)
    % df: table, like df in R
    % idcol: col name as unique id to match rows
    % ids: a cell array containing ids in certain order
    % covars: a cell array containing col names as covariates (not include idcol)
    % matname: path to covariate mat, default covar2ndlvl.mat in pwd

    if nargin==4, matname='covar2ndlvl.mat'; end

    % https://www.mathworks.com/matlabcentral/answers/22926-finding-the-indices-of-the-elements-of-one-array-in-another
    [~,idx] = ismember(ids, eval(sprintf('df.%s',idcol)));
    R = df(idx,covars);
    R = table2array(R);
    names = covars;
    save(matname,'R','names')
end

