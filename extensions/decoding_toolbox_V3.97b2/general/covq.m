% function out = covq(x)
% 
% Slightly faster, but less general version of cov(x). When passing a row
% vector to covq, it will return a matrix of NaNs. We always calculate the
% sample covariance.
%
% 2015/04/21 Martin Hebart

function out = covq(x)

n = size(x,1);

try % if exist('bsxfun','builtin')
    x = bsxfun(@minus,x,1/n * sum(x,1));
catch
    % for small matrices this solution might even be faster
    mx = 1/n * sum(x,1);
    x = x - mx(ones(1,n),:);
end
out = 1/(n-1) * (x'*x);