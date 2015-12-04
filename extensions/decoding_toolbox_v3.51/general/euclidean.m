% function dist = euclidean(X)
% 
% A function to calculate the Euclidean distance between multiple vectors.
% Usually faster than squareform(pdist(X,'euclidean')), unless we are
% dealing with lots of patterns and very little data. Takes the input like
% pdist, i.e. columns and rows are flipped w.r.t. correlations. No checks
% included in order to keep speed high.
%
% 2015/04/14 Martin Hebart

% TODO: check if sqrt(max(...,0)) can be replaced by real(sqrt(...)) which
% could be faster

function dist = euclidean(X)


ssq = sum(X.*X,2); % faster than diag(x'*x)
sz = size(X,1);

try % if exist('bsxfun','builtin')
    dist = sqrt(max(bsxfun(@plus,ssq,ssq')-2*(X*X'),0));
catch
    dist = sqrt(max(repmat(ssq,[1 sz]) + repmat(ssq',[sz 1]) - 2*(X*X'),0));
end

% set all values along diagonal to 0
dist(1:sz+1:end) = 0;