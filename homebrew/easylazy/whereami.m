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
            ez.cell2csv('TempTal.txt', num2cell(icbm_spm2tal(xyz)));
            % call talairach demo to get labels
                % awk '{print $2}' prints only the 2nd column of the output (in this case the PID)
                % $(...) is command substitution. Basically the result from the inner command will be used as an argument to kill
            % cmd = sprintf(['java -cp "%s" org.talairach.AtlasServer 1600 & java -cp "%s" org.talairach.ExcelToTD 2, ' '"%s"' ' host=127.0.0.1:1600 && kill $(ps -A|grep java|grep org.talairach.AtlasServer|awk "{print $1}")'],ez.joinpath(thePath,'talairach.jar'),ez.joinpath(thePath,'talairach.jar'),ez.joinpath(ez.pwd(),'TempTal.txt'));
            % cmd = sprintf(['java -cp "%s" org.talairach.AtlasServer 1600 & java -cp "%s" org.talairach.PointToTD 2, ' '"%s"' ' host=127.0.0.1:1600 && kill $(ps -A|grep java|grep org.talairach.AtlasServer|awk "{print $1}")'],ez.joinpath(thePath,'talairach.jar'),ez.joinpath(thePath,'talairach.jar'),ez.join(',',[-26.9051,-36.1621,-8.6124]));
            % command line bug, won't work, call gui to manually select
            ez.pprint('Select 1) Nearest grey matter; 2) From file TempTal.txt; 3) Search');
            cmd = sprintf(['java -jar %s'],ez.joinpath(thePath,'talairach.jar'));
            [sts, res] = system(cmd);
            
            result2 = ez.csv2cell('TempTal.td.txt');
            result2 = result2(2:end,:);
            result2 = regexp(result2, '\t', 'split');
            result2 = vertcat(result2{:});
            % ez.rm('TempTal.txt');
            % ez.rm('TempTal.td.txt');
            
            % final combine
            header = {'x','y','z','Z score','k','xjView','url','Number','x_tal','y_tal','z_tal','Tal1','Tal2','Tal3','Tal4','Tal5','Extended_Range_mm','','Cluster_p_FWE','Cluster_p_FDR','Cluster_p','Peak_p_FWE','Peak_p_FDR','T','Peak_p'};
            result = [result1, result2, c3, c4, c6, p7, p8, t, p11];
            result = [header;result];
            ez.cell2csv('TabDat.csv',result);
            ez.pprint('Done! Check TabDat.csv.');
            return
        catch
            ez.pprint('Please extract table data structure from SPM results table to get ''TabDat''.');
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