% Find anatomical location of a list of mni coordinates
%
% if no input, search TabDat that is table data structure extracted from
% SPM results table (right click mouse)
%
% example: 
% ([20 6 10; 30 9 12])
% ([20 6 10])
% command line: [20 6 10]
% returns nothing

% also: check out Neurosynth (http://neurosynth.org)
% wrapper of http://www.alivelearn.net/?p=1456 

function main(varargin)
    if nargin==0
        try
            TabDat = evalin('base','TabDat');
            
            % only tell main clusters
            ind = find(~cellfun(@isempty,TabDat.dat(:,6)));

            % potentially useful output
            c3 = TabDat.dat(ind,3);
            c4 = TabDat.dat(ind,4);
            c6 = TabDat.dat(ind,6);

            p7 = TabDat.dat(ind,7);
            p8 = TabDat.dat(ind,8);
            t = TabDat.dat(ind,9);
            p11 = TabDat.dat(ind,11);

            % main output part 1 from cuixuFindStructure
            xyz = TabDat.dat(ind,12);
            z = TabDat.dat(ind,10);
            k = TabDat.dat(ind,5);

            xyz = [xyz{:}]';
            % [oneline, cellarray]=cuixuFindStructure([20 6 10; 30 9 12])
            % [oneline, cellarray]=cuixuFindStructure([20 6 10])
            if isempty(which('cuixuFindStructure'))
                extsPath = ez.joinpath(ez.parentdir(ez.parentdir(ez.csd())), 'extensions');
                thePath = ez.lsd(extsPath,'^xjview');
                thePath = ez.joinpath(extsPath,thePath{1});
                addpath(thePath,'-end');
            end
            oneline = cuixuFindStructure(xyz);
            result1 = [num2cell(xyz), z, k, oneline];
    
            for i = 1:length(oneline)
                url = sprintf('http://neurosynth.org/locations/%d_%d_%d/',xyz(i,1),xyz(i,2),xyz(i,3));
                result1{i,7} = url;
            end
               
            % part 2: talairach demo
            if isempty(which('icbm_spm2tal'))
                extsPath = ez.joinpath(ez.parentdir(ez.parentdir(ez.csd())), 'extensions');
                thePath = ez.lsd(extsPath,'^Talairach');
                thePath = ez.joinpath(extsPath,thePath{1});
                addpath(thePath,'-end');
            else
                thePath = ez.splitpath(which('icbm_spm2tal'));
            end
            % convert to talairach
            ez.cell2csv('TempTalairach.txt', num2cell(icbm_spm2tal(xyz)));
            % call talairach demo to get labels
                % awk '{print $2}' prints only the 2nd column of the output (in this case the PID)
                % $(...) is command substitution. Basically the result from the inner command will be used as an argument to kill
                % code: seems like 1 returns no data, 2 = single point in the GUI, 4 = nearest grey matter, 3 cube range
                        % 1 - SPMap data
                        % 2 - Talairach Label Data
                        % 3 - mm x mm x mm cube search area
                        %     use [:Cubesize] for sizes of 3, 5, 7, 9, or 11. Default is 5.
                        % 4 - Talairach Label Data, gray matter only
            % cmd = sprintf(['java -jar %s'],ez.joinpath(thePath,'talairach.jar'));
            % cmd = sprintf(['java -cp "%s" org.talairach.AtlasServer 1600 & java -cp "%s" org.talairach.PointToTD 2, ' '"%s"' ' host=127.0.0.1:1600 && kill $(ps -A|grep java|grep org.talairach.AtlasServer|awk "{print $1}")'],ez.joinpath(thePath,'talairach.jar'),ez.joinpath(thePath,'talairach.jar'),ez.join(',',[-26.9051,-36.1621,-8.6124]));
            cmd = sprintf(['java -cp "%s" org.talairach.AtlasServer 1600 & java -cp "%s" org.talairach.ExcelToTD 2, ' '"%s"' ' host=127.0.0.1:1600 && kill $(ps -A|grep java|grep org.talairach.AtlasServer|awk "{print $1}")'],ez.joinpath(thePath,'talairach.jar'),ez.joinpath(thePath,'talairach.jar'),ez.joinpath(ez.pwd(),'TempTalairach.txt'));
            [sts, res] = system(cmd);
            result21 = ez.csv2cell('TempTalairach.txt.td');
            result21 = regexp(result21, '\t', 'split');
            result21 = vertcat(result21{:});
            result21(:,8) = cellfun(@(x) x(1), result21(:,4),'UniformOutput',false);
            
            cmd = sprintf(['java -cp "%s" org.talairach.AtlasServer 1600 & java -cp "%s" org.talairach.ExcelToTD 4, ' '"%s"' ' host=127.0.0.1:1600 && kill $(ps -A|grep java|grep org.talairach.AtlasServer|awk "{print $1}")'],ez.joinpath(thePath,'talairach.jar'),ez.joinpath(thePath,'talairach.jar'),ez.joinpath(ez.pwd(),'TempTalairach.txt'));
            [sts, res] = system(cmd);
            result22 = ez.csv2cell('TempTalairach.txt.td');
            result22 = regexp(result22, '\t', 'split');
            result22 = vertcat(result22{:});
            result22(:,8) = regexprep(result22(:,8),'Brodmann area ','');
            result22 = result22(:,[8,6]);

            ez.rm('TempTalairach.txt');
            ez.rm('TempTalairach.txt.td');
            result2 = [result21,result22];
            
            % part 3: spm Neuromorphometrics
            result3 = cell(size(xyz,1),2);
            for i=1:size(xyz,1)
                result3{i,2} = i;
                result3{i,1} = spm_atlas('query','Neuromorphometrics',xyz(i,:)');
            end    
            
            % final combine
            header = {'x','y','z','Z score','k','xjView','url','x_tal','y_tal','z_tal','Hemisphere','Lobe','Anatomy','Anatomy_Matter','Hem','BA','Anatomy_GreyMatter','Cluster_p_FWE','Cluster_p_FDR','Cluster_p','Peak_p_FWE','Peak_p_FDR','T','Peak_p','SPM','Number'};
            result = [result1, result2, c3, c4, c6, p7, p8, t, p11, result3];
            result = [header;result];
            newheader = {'Lobe','Hemisphere','xjView','SPM','Anatomy_GreyMatter','Number','Anatomy','Hem','BA','x','y','z','Z score','k','url','x_tal','y_tal','z_tal','Anatomy_Matter','Cluster_p_FWE','Cluster_p_FDR','Cluster_p','Peak_p_FWE','Peak_p_FDR','T','Peak_p'};
            newheaderind = cellfun(@(x) find(strcmp(header,x)), newheader, 'UniformOutput', false);
            result = result(:,cell2mat(newheaderind));
            
            resultFile = sprintf('TabDat_%s.csv',evalin('base','xSPM.title'));
            ez.cell2csv(resultFile,result);
            ez.pprint(['Done! Check ' resultFile '. Sort by Lobe/BA/Hemisphere. BA refers to BA of nearest grey matter if not found.']);
            ez.pprint('AAL labeling should be less weighted(?). One should also look at the activation map to see where the cluster is.');
            return
        catch
            ez.pprint('Something wrong. Did you extract table data structure from SPM results table to get ''TabDat''?');
            return
        end
    end







    % if  [20 6 10]
    if iscellstr(varargin); varargin = {str2num(varargin{:})}; end;
    
    % [oneline, cellarray]=cuixuFindStructure([20 6 10; 30 9 12])
    % [oneline, cellarray]=cuixuFindStructure([20 6 10])
    if isempty(which('cuixuFindStructure'))
        extsPath = ez.joinpath(ez.parentdir(ez.parentdir(ez.csd())), 'extensions');
        thePath = ez.lsd(extsPath,'^xjview');
        thePath = ez.joinpath(extsPath,thePath{1});
        addpath(thePath,'-end');
    end
    oneline = cuixuFindStructure(varargin{:});
    
    for i = 1:length(oneline)
        disp(' ----------------------------');
        % varargin{1} is the passed matrix
        disp(varargin{1}(i,:));
        disp(oneline{i});

        url = sprintf('http://neurosynth.org/locations/%d_%d_%d/',varargin{1}(i,1),varargin{1}(i,2),varargin{1}(i,3));
        disp(sprintf('\n <a href="%s">%s</a>\n',url,url));
    end
        
end