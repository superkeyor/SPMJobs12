function main(in)
%  Wrapper for Checking Registration one by one
%
% USAGE: (in)
%
% ARGUMENTS
%   in: an array of cells, with each cell containing paths for images
%   to loop over (one at a time)
%

% ------------------------ Copyright (C) 2014 ------------------------
%	Author: Bob Spunt
%	Affilitation: Caltech
%	Email: spunt@caltech.edu
%
%	$Revision Date: Aug_20_2014

if nargin<1, disp('USAGE: (in)'); return; end
if ~iscell(in), in1 = cellstr(in); end
nim = length(in);
for i = 1:nim
    check_reg(in{i})
    input(sprintf('%d of %d -- Press Enter key to move on.', i, nim));
end
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
