function [V,str,icon,filename]=conn_getinfo(filename)

[pathname,name,ext]=spm_fileparts(filename(1,:));
if any(strcmp(ext(1:min(4,length(ext))),{'.mgh','.mgz'}))
    filename=conn_mgh2nii(filename);
    [pathname,name,ext]=spm_fileparts(filename(1,:));
end
if any(strcmp(ext(1:min(3,length(ext))),{'.gz'}))
    filename=conn_gz2nii(filename);
    [pathname,name,ext]=spm_fileparts(filename(1,:));
end
if any(strcmp(ext(1:min(6,length(ext))),{'.annot'}))
    filename=conn_annot2nii(filename);
    [pathname,name,ext]=spm_fileparts(filename(1,:));
end
switch(ext(1:min(4,length(ext)))),
	case {'.img','.hdr','.nii'},
        V=spm_vol(filename);
        if length(V)==1, icon=V;
        else icon=V([1,end]); 
        end
	case {'.tal','.mat','.txt','.par'},
		icon=[];
		for n1=1:size(filename,1),
			x=load(deblank(filename(n1,:)));
			if isstruct(x), names=fieldnames(x); names=names{1}; x=x.(names); else names=''; end
            tok=false;
            try
                if strcmp(names,'CONN_x')&&isstruct(x)
                    V(n1).dim=x.Setup.nsubjects;
                    V(n1).fname=deblank(filename(n1,:));
                    temp=spm_vol(x.Setup.structural{1}{1}{1});
                    if x.Setup.nsubjects>1, temp=[temp spm_vol(x.Setup.structural{x.Setup.nsubjects}{1}{1})]; end
                    icon=cat(2,icon,temp);
                    tok=true;
                elseif strcmp(names,'SPM')&&isstruct(x)
                    V(n1).dim=size(x.xX.X);
                    V(n1).fname=deblank(filename(n1,:));
                    temp=x.xX.X;
                    icon=cat(2,icon,temp(round(linspace(1,size(temp,1),128)),:));
                    tok=true;
                end
            end
            if ~tok
                V(n1).dim=size(x);
                V(n1).fname=deblank(filename(n1,:));
                if isnumeric(x) && (n1==1 || n1==size(filename,1)),
                    icon=cat(2,icon,x(:,:));
                end
            end
		end
	otherwise,
		error(['File type ',ext,' not implemented']);
end
if isempty(V), str=[]; icon=[];
else
	str=['[',num2str(length(V)), ' file']; if length(V)>1, str=[str,'s']; end; str={[str,']']};
	if length(V)>1 && any(any(detrend(cat(1,V(:).dim),0))),str{end}=[str{end} ' Dimensions: NOT MATCHED'];
	else str{end}=[str{end} ' x [size',sprintf(' %1.0f ',V(1).dim),']']; end
	if length(V)==1, str{end+1}=V(1).fname;
	else str{end+1}=['First: ',V(1).fname]; str{end+1}=['Last : ',V(end).fname];  end
	for n1=1:length(str), if length(str{n1})>30+9, str{n1}=[str{n1}(1:4),' ... ',str{n1}(end-30+1:end)]; end; end; %str{n1}=[str{n1}(1:17),' ... ',str{n1}(end-17+1:end)]; end; end
end


