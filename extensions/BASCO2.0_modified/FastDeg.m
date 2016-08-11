function [degvec, strvec] = FastDeg(A,th,fast)
% Degree centrality for large matrices. 
% input  : 
%           A    : matrix (Npt,Nvox)
%           th   : threshold on correlation coefficients
%           fast : not accurate but fast calculation of a strength-map
% output :  
%           strength/degree for all voxels (Nvox)
%

fprintf('Calculating degree/strength ...\n');

An     = bsxfun(@minus,A,mean(A,1));
An     = bsxfun(@times,An,1./sqrt(sum(An.^2,1)));
Nvox   = size(A,2);
degvec = zeros(1,Nvox);
strvec = zeros(1,Nvox);

if fast==true
    n      = ones(Nvox,1);
    strvec = An'*(An*n);
    return;
end

tic
for i=1:Nvox
  C          = sum(repmat(An(:,i),1,Nvox).*An,1);
  C(i)       = 0;
  C          = atanh(C);
  strvec(i)  = sum(C);
  degvec(i)  = sum(C>th);
  if mod(i,10000)==0
     fprintf('#');
  end
end
toc

% tic;
% cmat   = An'*An; % high memory consumption
% cmat   = double(cmat>th);
% degvec = sum(cmat)-1;
% toc;

end

