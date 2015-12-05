function filename=conn_mgh2nii(filename)

ischarfilename=ischar(filename);
filename=cellfun(@strtrim,cellstr(filename),'uni',0);
filenameout=regexprep(filename,'\.mgh\s*$|\.mgz\s*$','.nii');
redo=~cellfun(@conn_existfile,filenameout);
if ~any(redo), filename=filenameout; if ischarfilename, filename=char(filename); end; return; end

fprintf('converting mgh files to nifti format...');
[pathname,name,ext]=spm_fileparts(filename{1});
if strcmp(ext,'.mgz')
    filename(redo)=gunzip(filename(redo));
    if ispc, [ok,msg]=cellfun(@(x)system(sprintf('move "%s" "%s.mgh"',x,x)),filename(redo),'uni',0);
    else     [ok,msg]=cellfun(@(x)system(sprintf('mv ''%s'' ''%s.mgh''',x,x)),filename(redo),'uni',0);
    end
    if ~all(cellfun(@(x)isequal(x,0),ok)), error(['error converting mgh to nifti format. Please check file permissions in folder ',pathname]); end
    filename(redo)=cellfun(@(x)sprintf('%s.mgh',x),filename(redo),'uni',0);
end
for n=find(redo(:)')
    a=conn_freesurfer_MRIread(filename{n});
    b=permute(a.vol,[2,1,3]);
    dt=[spm_type('float32') spm_platform('bigend')];
    if ~nnz(rem(b,1)~=0)
        if ~nnz(b<0),
            if ~nnz(b>255),         dt(1)=spm_type('uint8');
            elseif ~nnz(b>65535),   dt(1)=spm_type('uint16');
            end
        end
    end
    V=struct('mat',a.vox2ras1,'dim',a.volsize([2 1 3]),'dt',dt,'fname',filenameout{n},'pinfo',[1;0;0]);
    try
        spm_write_vol(V,b);
    catch
        error(['error writing nifti file. Please check file permissions in folder ',pathname]); 
    end
end
filename=filenameout; 
if ischarfilename, filename=char(filename); end; 
fprintf('done\n');

