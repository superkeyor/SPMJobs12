function dist = euclidean2(x,y)

% what corr(x',y') is, but using euclidean distance

ssqx = sum(x.*x,2);
ssqy = sum(y.*y,2);

try % if exist('bsxfun','builtin')
    dist = sqrt(max(bsxfun(@plus,ssqx,ssqy')-2*(x*y'),0));
catch
    szx = size(x,1);
    szy = size(y,1);
    dist = sqrt(max(repmat(ssqx,[1 szy]) + repmat(ssqy',[szx 1]) - 2*(x*y'),0));
end