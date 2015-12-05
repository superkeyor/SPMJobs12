% function dist = cveuclidean2(X,Y)
% 
% A function to calculate the cross-validated version of the squared
% Euclidean distance between multiple matrices. This is equivalent to
% d(i,j) = (X(:,i)-X(:,j))'*(Y(:,i)-Y(:,j)) for all pairs of i and j.
% Negative squared distances are possible because of cross-validation.
%
% 2015/04/15 Martin Hebart

function dist = cveuclidean2(X,Y)

szx = size(X);
szy = size(Y);

if ~isequal(szx,szy)
    error('Size of both inputs needs to match.')
end
XY = X'*Y;
dist = zeros(szx(2),szx(2));
dXY = diag(XY);
for i = 1:szx(2)
    dist(:,i) = XY(i,i) + dXY - XY(i,:)' - XY(:,i);
end

% alternative (possibly in some cases faster, but usually slower)
% dXY = diag(XY);
% dist = bsxfun(@plus,dXY,dXY') - XY - XY';