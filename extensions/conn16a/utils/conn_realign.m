

warning off;
for nses=1:nsess,V{nses}=spm_vol(CONN_x.Setup.functional{nsub}{nses}{1}); end
warning on;
flags=struct('rtm',0);
spm_realign(V,flags);
flags=struct('mask',1,'mean',1,'which',0);
for nses=1:nsess,spm_reslice(V{nses},flags);end

for nses=1:nsess,
	[pathname,filename,extname]=fileparts(deblank(CONN_x.Setup.functional{nsub}{nses}{1}));
	filename=fullfile(pathname,['rp_',filename,'.txt']);
	[V,str,icon]=conn_getinfo(filename);
	name='realignment';
	idx=strmatch(name,CONN_x.Setup.l1covariates.names,'exact');
	if isempty(idx), idx=length(CONN_x.Setup.l1covariates.names); CONN_x.Setup.l1covariates.names{end+1}=' '; end
	CONN_x.Setup.l1covariates.names{idx}=name;
	CONN_x.Setup.l1covariates.files{nsub}{idx}{nses}={filename,str,icon};
end
