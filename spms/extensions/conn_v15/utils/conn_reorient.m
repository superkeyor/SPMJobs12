
clear a;for nsub=1:CONN_x.Setup.nsubjects, a(nsub)=spm_vol(CONN_x.Setup.structural{nsub}{1});end;
spm_check_orientations(a);

clear a;for nsub=1:CONN_x.Setup.nsubjects, a(nsub)=spm_vol(CONN_x.Setup.structural{nsub}{1});end;
do=[1,15,31,37];%[1:16,31:41];
filename=fullfile(fileparts(which('spm')),'canonical','avg152T1.nii');
b=spm_vol(filename);
for nsub=do,
    spm_check_registration([b,a(nsub)]);
    pause;
end


do=[1,15,31,37];%[1:16,31:41];
%do=1:CONN_x.Setup.nsubjects; [2:30,32:36,38:41]
transM=CONN_x.Setup.reorient;
if any(any(transM~=eye(4))),
	for nsub=do,%1:CONN_x.Setup.nsubjects,	
		file=deblank(CONN_x.Setup.structural{nsub}{1});
		M = spm_get_space(file);
		spm_get_space(file,transM*M);
        if 0,
            for nses=1:length(CONN_x.Setup.functional{nsub}),
                file=deblank(CONN_x.Setup.functional{nsub}{nses}{1});
                M = spm_get_space(file);
                spm_get_space(file,transM*M);
            end
        end
	end
end
