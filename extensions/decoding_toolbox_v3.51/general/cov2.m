% function out = cov2(x,y)
% 
% Unlike cov(x,y) it assumes that x and y columns belong to pairs, i.e. we
% calculate a quadrant of cov([x y]), equivalent to corr(x,y) for
% correlations. cov(x,y) would calculate cov(x(:),y(:)). We always
% calculate the sample covariance.
%
% 2015/04/15 Martin Hebart

function out = cov2(x,y)

n = size(x,1);
n2 = size(y,1);
if n ~= n2
    error('the first dimension of x and y need to be the same')
end

try % if exist('bsxfun','builtin')
    x = bsxfun(@minus,x,1/n * sum(x,1));
    y = bsxfun(@minus,y,1/n * sum(y,1));
catch
    mx = 1/n * sum(x,1);
    my = 1/n * sum(y,1);
    o = ones(1,n);
    x = x - mx(o,:);
    y = y - my(o,:);
end
out = 1/(n-1) * (x'*y);