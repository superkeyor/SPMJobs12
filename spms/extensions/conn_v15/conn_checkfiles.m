function filenames=conn_checkfiles(filenames)

% CONN_CHECKFILES check if files exist and ask the user to locate them if they are not found
% Useful for adapting file names after a given directory structure has been moved to a different location
%
% conn_checkfiles; % initializes (forgets previous filename transformations)
% FILENAMES=conn_checkfiles(FILENAMES); % perform transformation of FILENAMES (and attempt to learn filename transformation from last user specified file)
%
persistent changed fullname1 fullname2

if isempty(changed), changed=0; end
if nargin<1, changed=0; return; end

begin=1;
switch(filesep),case '\',idx=find(filenames=='/');case '/',idx=find(filenames=='\');end; filenames(idx)=filesep;
n=0; while n<size(filenames,1),
	ok=dir(deblank(filenames(n+1,:)));
	if ~isempty(ok), n=n+1;
	else,
		if begin && changed, begin=0;
		else,
			fullname1=deblank(filenames(n+1,:));
			[pathname1,name1,ext1]=fileparts(fullname1);
			[name2,pathname2]=uigetfile(['*.',ext1],['File not found: ',name1,ext1],['*',name1,ext1]);
			fullname2=fullfile(pathname2,name2);
			changed=1;begin=0;
		end
		% if file [string1][string0] is found at location [string2][string0] 
		% adapts the rest of file names to change [string1] to [string2]
		fullnamematch=strvcat(fliplr(fullname1),fliplr(fullname2)); 
		m=sum(cumsum(fullnamematch(1,:)~=fullnamematch(2,:))==0);
		m1=max(0,length(fullname1)-m); m2=max(0,length(fullname2)-m);
		filenames=strvcat(filenames(1:n,:),[repmat(fullname2(1:m2),[size(filenames,1)-n,1]),filenames(n+1:end,m1+1:end)]);
	end
end
