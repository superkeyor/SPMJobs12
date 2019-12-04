function do_img_t2z(folders)
    % input a folder or folders, look for spmT_xxx.nii
    % read for df from the T image decription
    % call built-in spm_t2z to convert from T to Z image
    % save in the same folder (overwrite existing Z images without prompt)
    % the results are the same as the ones calculated from do_imcalc_custom('zscore'), as Jerry tested.

    % https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=spm;612452f0.02
    % spm_select(1,'spmT.*\.nii')
    if ~iscell(folders), folders = {folders}; end
    for j = 1:length(folders)
        folder = folders{j};
        timgs = ez.ls(folder,'^spmT_\d+\.nii$',1);
        P = spm_vol(timgs);
        for i = 1:length(P)
            oP = P{i};
            oP.fname = strrep(oP.fname, 'spmT_', 'spmZ_');
            oP.descrip = ['Z: ', oP.descrip];
            t = spm_read_vols(P{i});
            % df can be found in P.descrip, I think.
            df = regexp(oP.descrip,'\{T_\[\d+\.\d+\]\}','once','match');
            df = regexp(df,'\d+\.\d+','once','match');
            df = str2double(df);
            z = spm_t2z(t,df);
            oP = spm_create_vol(oP);
            spm_write_vol(oP,z);
        end %i timgs
        ez.print([int2str(length(P)), ' T images converted to Z.']);
    end %j folders
end

% % not tested
% % https://andysbrainblog.blogspot.com/2015/07/converting-t-maps-to-z-maps.html
% %
% % Usage:  convert_spm_stat(conversion, infile, outfile, dof)
% %
% % This script uses a template .mat batch script object to
% % convert an SPM (e.g. SPMT_0001.hdr,img) to a different statistical rep.
% % (Requires matlab stats toolbox)
% %
% %  Args:
% %  conversion -- one of 'TtoZ', 'ZtoT', '-log10PtoZ', 'Zto-log10P',
% %               'PtoZ', 'ZtoP'
% %  infile -- input file stem (may include full path)
% %  outfile -- output file stem (may include full pasth)
% %  dof -- degrees of freedom
% %
% % Created by:           Josh Brown 
% % Modification date:    Aug. 3, 2007
% % Modified: 8/21/2009 Adam Krawitz - Added '-log10PtoZ' and 'Zto-log10P'
% % Modified: 2/10/2010 Adam Krawitz - Added 'PtoZ' and 'ZtoP'

% function completed=convert_spm_stat(conversion, infile, outfile, dof)

% old_dir = cd();

% if strcmp(conversion,'TtoZ')
%     expval = ['norminv(tcdf(i1,' num2str(dof) '),0,1)'];
% elseif strcmp(conversion,'ZtoT')
%     expval = ['tinv(normcdf(i1,0,1),' num2str(dof) ')'];
% elseif strcmp(conversion,'-log10PtoZ')
%     expval = 'norminv(1-10.^(-i1),0,1)';
% elseif strcmp(conversion,'Zto-log10P')
%     expval = '-log10(1-normcdf(i1,0,1))';
% elseif strcmp(conversion,'PtoZ')
%     expval = 'norminv(1-i1,0,1)';
% elseif strcmp(conversion,'ZtoP')
%     expval = '1-normcdf(i1,0,1)';
% else
%     disp(['Conversion "' conversion '" unrecognized']);
%     return;
% end
    
% if isempty(outfile)
%     outfile = [infile '_' conversion];
% end

% if strcmp(conversion,'ZtoT')
%     expval = ['tinv(normcdf(i1,0,1),' num2str(dof) ')'];
% elseif strcmp(conversion,'-log10PtoZ')
%     expval = 'norminv(1-10.^(-i1),0,1)';
% end

% %%% Now load into template and run
% jobs{1}.util{1}.imcalc.input{1}=[infile '.img,1'];
% jobs{1}.util{1}.imcalc.output=[outfile '.img'];
% jobs{1}.util{1}.imcalc.expression=expval;

% % run it:
% spm_jobman('run', jobs);

% cd(old_dir)
% disp(['Conversion ' conversion ' complete.']);
% completed = 1;
% end