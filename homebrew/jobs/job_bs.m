% (inputDir, outputDir, seedROINII, parameters);
% 
% 
% original author: http://mypage.iu.edu/~ajahn/docs/DoBetaSeries.m
% downloading date: April 16 2015, 09:52:52 PM CDT
% Jerry's notes:
% the general logic is like this:
% 1) instead of lumping together the betas for one condition in traditional GLM
%    beta series analysis generates a series of betas for each trial in one condition
%    if the condition is called "TapLeft"
%    then during the beta series GLM, each trial in that condition should be called TapLeft_n where n = 1 to n
%    the required SPM.mat should be generated this way
% 2) find and load SPM.mat file for each subject
% 3) extract beta weights for a particular roi and average the betas for voxels in that roi
%       there seems to be a mapping from ROI xyz MNI coordinates to XYZ location matrix? 
% 4) perform correlation, generate relevant .hdr .img files by calling spm functions
%    convert r map (correlation) to z map
%       this part is a bit complex to me to grasp now as of April 16 2015, 10:03:42 PM CDT
% 5) Once you have z-maps, these can be entered into a 2nd-level
%    1-sample t-test, or contrasts can be taken between z-maps and these
%    contrasts can be taken to a 1-sample t-test as well.
% 
%
% inputDir ='.../xxx/'; trailing filesep does not matter
% outputDir = '.../xxx/'; % trailing filesep does not matter
%      output p, r, z maps, e.g., s0215_mapName1_p.nii, s0215_mapName1_r.nii, s0215_mapName1_z.nii
%      if output nii files exist with same name, overwrite without any prompt
%      a pdf with these r, p, z maps for each subject
%      the output files are organized by subFolder in outputDir with mapName
% seedROINII = '.../.../xxx.nii';  
%               a path to the ROI in nifti format (cannot accept .mat format)
%               can be exported from MARSBAR, can be a voxel roi, a sphere roi
% parameters = {cond1, mapName1;
%               cond2, mapName2};
%               cond    - a condition for beta series analysis
%               mapName - a name for the output file/map
%       
%       e.g., 
%       parameters = {'TapLeft', 'TapLeft_RightM1'};

%       conditions to be averaged together should be placed together in a cell
%       parameters = {'Incongruent', 'Incongruent_Map';
%                     'Congruent', 'Congruent_Map';
%                     {'Error', 'Late'}, 'Error_Late_Map'}; 
%
% 
% note: 
%   uses SPM functions; SPM must be added to your matlab path: File -> Set Path... -> add with subfolders. 
%   tested under SPM 12-6225 (with mac lion 10.7.5 and matlab 2012b)
%   if you use this job_function for the first time, consider running only one subject and check the results before processing all 
%
% author = jerryzhujian9@gmail.com
% date: December 10 2014, 11:13:30 AM CST
% inspired by http://www.aimfeld.ch/neurotools/neurotools.html
% https://www.youtube.com/playlist?list=PLcNEqVlhR3BtA_tBf8dJHG2eEcqitNJtw

%------------- BEGIN CODE --------------
function [output1,output2] = main(inputDir, outputDir, seedROINII, parameters, email)
% email is optional, if not provided, no email sent
% (re)start spm
spm('fmri');

startTime = ez.moment();
% spm folder names for all subjects, like {'s0215_SPM'; 's0216_SPM'}
spmFolders = ez.lsd(inputDir,'s\d\d\d\d_SPM$', false); % false: not fullpath
spmFolders = cellfun(@(e) regexp(e,'_', 'split'),spmFolders,'UniformOutput',false);
subjects = cellfun(@(e) e{end-1},spmFolders,'UniformOutput',false);  
subjects = ez.unique(subjects); % returns {'s0215';'s0216'}

for n = 1:ez.len(subjects)
    subject = subjects{n};
    ez.print(['Processing ' subject ' ...']);

    % change the parameters format to pass to the original function
    rootdir = inputDir;
    subjectDir = [subject '_SPM'];  % s0215_SPM
    spmdir = ''; % SPM.mat in the s0215_SPM dir, no further subdir
    seedroi = seedROINII;
    Conds = parameters(:,1)';
    MapNames = parameters(:,2)';
    % though original function can process multiple subjects
    % here pass a subject (in a cell) each time with my own loop without major modification of the original function
    DoBetaSeries(rootdir, {subjectDir}, spmdir, seedroi, Conds, MapNames);
    % the original function saves the output files in the same folder where SPM.mat is
    % the original function saves as .img/.hdr formats, convert to .nii and move to outputdir
    % http://www.nemotos.net/?p=890
    % https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=spm;3671aad3.1110
    ez.cd(ez.joinpath(inputDir,subjectDir));
    for iii = 1:ez.len(MapNames)
        mapName = MapNames{iii};
        imgs = ez.ls('.', [mapName '_(p|r|z)\.img$']);
        for jjj = 1:ez.len(imgs)
            img = imgs{jjj};
            V = spm_vol(img);
            ima = spm_read_vols(V);
            [pathstr, filename] = ez.splitpath(img);
            V.fname = [subject '_' filename '.nii'];
            spm_write_vol(V,ima);
        end
        % delete hrd/img
        files = ez.ls('.',[mapName '_(p|r|z)\.(img|hdr)$']);
        ez.rm(files);
        % plot files
        files = ez.ls('.',[mapName '_(p|r|z)\.nii$']);
        spm_check_registration(char(files));
        fig = spm_figure('FindWin','Graphics');
        % ready dir
        outputSubDir = ez.joinpath(outputDir, mapName);
        ez.mkdir(outputSubDir);
        % save pdf and move files
        ez.export(ez.joinpath(outputSubDir,[subject '_' mapName '_bs.pdf']),fig);
        ez.mv(files, outputSubDir);
    end

    ez.pprint('****************************************'); % pretty colorful print
end
ez.cd(outputDir);
ez.pprint('Done!');
finishTime = ez.moment();
if exist('email','var'), try, jobmail(mfilename, startTime, finishTime); end; end;
end % of main function
%------------- END OF CODE --------------


% the original function requires a folder structure like:
% rootdir
%     |__ 101 (subjectDir)
%           |__ spmdir
%                    |__ SPM.dat
function DoBetaSeries(rootdir, subjects, spmdir, seedroi, Conds, MapNames)
% function BetaSeries(rootdir, subjects, spmdir, seedroi, Conds, MapNames)
% INPUT:
%  rootdir  - Path to where subjects are stored
%  subjects - List of subjects (can concatenate with brackets)
%  spmdir   - Path to folder containing SPM file
%  seedroi  - Absolute path to file containing ROI in NIFTI format
%  Conds    - List of conditions for beta series analysis
%  MapNames - Output for list of maps, one per Conds cell
%       
%   Example use:
%       BetaSeries('/data/study1/fmri/', [101 102 103],
%       'model/BetaSeriesDir/', '/data/study1/Masks/RightM1.nii',
%       {'TapLeft'}, {'TapLeft_RightM1'})
%
%       conditions to be averaged together should be placed together in a cell
%       separate correlation maps will be made for each cell
%       Conds = {'Incongruent' 'Congruent' {'Error' 'Late'}}; 
%
%       For MapNames, there should be one per Conds cell above
%       e.g., with the Conds above, MapNames = {'Incongruent_Map',
%       'Congruent_Map', 'Error_Late_Map'}
%
%       Once you have z-maps, these can be entered into a 2nd-level
%       1-sample t-test, or contrasts can be taken between z-maps and these
%       contrasts can be taken to a 1-sample t-test as well.
%


if nargin < 5
    disp('Need rootdir, subjects, spmdir, seedroi, Conds, MapNames. See "help BetaSeries" for more information.')
    return
end


%Find XYZ coordinates of ROI
Y = spm_read_vols(spm_vol(seedroi),1);
indx = find(Y>0);
[x,y,z] = ind2sub(size(Y),indx);
XYZ = [x y z]';


%Find each occurrence of a trial for a given condition
%These will be stacked together in the Betas array
for i = 1:length(subjects)
    % subj = num2str(subjects(i));
    % disp(['Loading SPM for subject ' subj]);
    % Can change the following line of code to CD to the directory
    % containing your SPM file, if your directory structure is different
    % cd([rootdir subj filesep spmdir]);
    subj = subjects{i};
    disp(['Loading SPM in ' subj]); 
    cd([rootdir filesep subj filesep spmdir]); % jerry April 17 2015, 10:38:04 AM CDT
    load SPM;
    
    for cond = 1:length(Conds)
        Betas = [];
        currCond = Conds{cond};
        if ~iscell(currCond)
            currCond = {currCond};
        end
        for j = 1:length(SPM.Vbeta) 
            for k = 1:length(currCond)
                if ~isempty(strfind(SPM.Vbeta(j).descrip,[currCond{k} '_'])) 
                    Betas = strvcat(Betas,SPM.Vbeta(j).fname);
                end
            end
        end
              

        %Extract beta series time course from ROI
        %This will be correlated with every other voxel in the brain
        if ischar(Betas)
            P = spm_vol(Betas);
        end

        est = spm_get_data(P,XYZ);
        est = nanmean(est,2);

        
        
        %----Do beta series correlation between ROI and rest of brain---%

        MapName = MapNames{cond};
        disp(['Performing beta series correlation for ' MapName]);

        Vin = spm_vol(Betas);
        nimgo = size(Vin,1);
        nslices = Vin(1).dim(3);

        % create new header files
        Vout_r = Vin(1);   
        Vout_p = Vin(1);
        [pth,nm,xt] = fileparts(deblank(Vin(1).fname));
        Vout_r.fname = fullfile(pth,[MapNames{cond} '_r.img']);
        Vout_p.fname = fullfile(pth,[MapNames{cond} '_p.img']);

        Vout_r.descrip = ['correlation map'];
        Vout_p.descrip = ['p-value map'];

        Vout_r.dt(1) = 16;
        Vout_p.dt(1) = 16;

        Vout_r = spm_create_vol(Vout_r);
        Vout_p = spm_create_vol(Vout_p);

        % Set up large matrix for holding image info
        % Organization is time by voxels
        slices = zeros([Vin(1).dim(1:2) nimgo]);
        stack = zeros([nimgo Vin(1).dim(1)]);
        out_r = zeros(Vin(1).dim);
        out_p = zeros(Vin(1).dim);


        for i = 1:nslices
            B = spm_matrix([0 0 i]);
            %creates plane x time
            for j = 1:nimgo
                slices(:,:,j) = spm_slice_vol(Vin(j),B,Vin(1).dim(1:2),1);
            end

            for j = 1:Vin(1).dim(2)
                stack = reshape(slices(:,j,:),[Vin(1).dim(1) nimgo])';
                [r p] = corr(stack,est);
                out_r(:,j,i) = r;
                out_p(:,j,i) = p;

            end

            Vout_r = spm_write_plane(Vout_r,out_r(:,:,i),i);
            Vout_p = spm_write_plane(Vout_p,out_p(:,:,i),i);

        end


        %Convert correlation maps to z-scores
        %NOTE: If uneven number of trials in conditions you are
        %comparing, leave out the "./(1/sqrt(n-3)" term in the zdata
        %variable assignment, as this can bias towards conditions which
        %have more trials

        % disp(['Converting correlation maps for subject ' subj ', condition ' MapNames{cond} ' to z-scores']) % jerry commented out
        disp(['Converting correlation maps to z-scores for condition ' MapNames{cond}])
        P = [MapNames{cond} '_r.img'];
        n = size(Betas,1);
        Q = MapNames{cond};
        Vin = spm_vol([MapNames{cond} '_r.img']);

        % create new header files
        Vout = Vin;   

        [pth,nm,xt] = fileparts(deblank(Vin(1).fname));
        Vout.fname = fullfile(pth,[Q '_z.img']);

        Vout.descrip = ['z map'];

        Vout = spm_create_vol(Vout);

        data = spm_read_vols(Vin);
        zdata = atanh(data)./(1/sqrt(n-3));

        spm_write_vol(Vout,zdata);

    end
end
end % end internal function
