function t = structn(obj)
% Convert a NIFTI-1 object into a form of struct
% _______________________________________________________________________
% Copyright (C) 2005 Wellcome Department of Imaging Neuroscience

%
% $Id: structn.m 253 2005-10-13 15:31:34Z guillaume $


if numel(obj)~=1,
    error('Too many elements to convert');
end;
fn = fieldnames(obj);
for i=1:length(fn)
    tmp = subsref(obj,struct('type','.','subs',fn{i}));
    if ~isempty(tmp)
        t.(fn{i}) = tmp;
    end;
end;
return;
