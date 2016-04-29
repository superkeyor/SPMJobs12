function [bb,vx] = bbvox_from_V(V)
vx = sqrt(sum(V.mat(1:3,1:3).^2));
if det(V.mat(1:3,1:3))<0, vx(1) = -vx(1); end;

o  = V.mat\[0 0 0 1]';
o  = o(1:3)';
bb = [-vx.*(o-1) ; vx.*(V.dim(1:3)-o)]; 
return;
