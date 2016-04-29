function [newfoldername,foldername]=conn_resultsfolder(ftype,state,varargin)
global CONN_x;

switch(ftype)
    case 'subjectsconditions'
        % backwards compatible folder names
        if ismember(state,[1 2])
            foldername={[CONN_x.Analyses(CONN_x.Analysis).name,'.']};
            newfoldername={[CONN_x.Analyses(CONN_x.Analysis).name,filesep]};
            foldername{end+1}=['SUBJECT_EFFECTS_'];
        else
            foldername={'SUBJECT_EFFECTS_'};
            newfoldername={['VoxeltoVoxel',filesep]};
        end
        if ~isempty(varargin)
            [nsubjecteffects,csubjecteffects,nconditions,cconditions]=deal(varargin{1:4});
            for n1=1:length(nsubjecteffects),
                if ~any(diff(csubjecteffects)),
                    foldername{end+1}=[CONN_x.Setup.l2covariates.names{nsubjecteffects(n1)},'.'];
                    newfoldername{end+1}=[CONN_x.Setup.l2covariates.names{nsubjecteffects(n1)},'.'];
                else, 
                    foldername{end+1}=[CONN_x.Setup.l2covariates.names{nsubjecteffects(n1)},'(',num2str(csubjecteffects(:,n1)','%2.1f'),')','.'];
                    newfoldername{end+1}=[CONN_x.Setup.l2covariates.names{nsubjecteffects(n1)},'(',mat2str(csubjecteffects(:,n1)',3),')','.'];
                end
            end
            newfoldername{end+1}=filesep;
            if isequal(cconditions,'var'), 
                foldername{end+1}=['CONDITIONS_var_'];
                newfoldername{end+1}=['var_'];
            else foldername{end+1}=['CONDITIONS_'];
            end
            for n1=1:length(nconditions),
                if isequal(cconditions,'var')||~any(diff(cconditions(:))),
                    foldername{end+1}=[CONN_x.Setup.conditions.names{nconditions(n1)},'.'];
                    newfoldername{end+1}=[CONN_x.Setup.conditions.names{nconditions(n1)},'.'];
                else, 
                    foldername{end+1}=[CONN_x.Setup.conditions.names{nconditions(n1)},'(',num2str(cconditions(:,n1)','%2.1f'),')','.'];
                    newfoldername{end+1}=[CONN_x.Setup.conditions.names{nconditions(n1)},'(',mat2str(cconditions(:,n1)',3),')','.'];
                end
            end
        end
        foldername=strcat(foldername{:});
        foldername(foldername==' '|foldername==filesep)='_';
        n=numel(foldername);
        newfoldername=strcat(newfoldername{:});
        newfoldername=regexprep(newfoldername,'\.(\\)|\.(\/)','$1');
        newfoldername=regexprep(newfoldername,'[^\w\d\s\.\(\)\\\/\-_@&]+|^\.|\.$','');
        newfoldername=regexprep(deblank(newfoldername),'\s+','_');
        %newfoldername=char('0'+mod(foldername*sign(sin(6*(1:n)'*(1:16)/n)),10));
        if ismember(state,[2,3])&&numel(foldername)>100, foldername=foldername(1:100); end
        if numel(newfoldername)>250, newfoldername=newfoldername(1:250); end
        %newfoldername=foldername; % comment this line to solve 'folder name too long' errors

    case 'sources'
        [sources,nsources,csources]=deal(varargin{1:3});
        REDUCENAMES=(state==2);
        foldername={};
        if state==3
            fullsources={};for n2=1:length(sources),fullsources{end+1}=conn_v2v('pcleartext',sources{n2}); end
            [nill,idxcharstart]=max(any(diff(double(char(fullsources(nsources))),1,1),1));
        else
            fullsources=sources;
            [nill,idxcharstart]=max(any(diff(double(char(sources(nsources))),1,1),1));
        end
        if REDUCENAMES
            redsources=regexprep(fullsources,{'^BA\.(\d+) \(([LR])\)\. .*','^\((-?\d+),(-?\d+),(-?\d+)\)$','^SLrois\.|^aal\.|^atlas\.','^([^\(\)]+)\(.+)\s*$','\s+$'},{'$1$2','($1 $2 $3)','','$1',''});
            [nill,nill,i2]=unique(redsources);
            validreduced=ismember(i2,find(accumarray(i2(:),1)==1));
            redsources(~validreduced)=fullsources(~validreduced);
        end
        newfoldername=foldername;
        for n2=1:length(nsources),
            if REDUCENAMES, txttmp=redsources{nsources(n2)}; 
            else txttmp=fullsources{nsources(n2)}; 
            end
            if ~REDUCENAMES&&n2>1&&idxcharstart>1
                txttmp=txttmp(idxcharstart:end);
            end            
            if ~any(diff(csources(:))),
                foldername{end+1}=[txttmp,'.'];
                newfoldername{end+1}=[txttmp,'.'];
            else, 
                foldername{end+1}=[txttmp,'(',num2str(csources(:,n2)','%2.1f'),')','.'];
                newfoldername{end+1}=[txttmp,'(',mat2str(csources(:,n2)',3),')','.'];
            end
        end
        foldername=strcat(foldername{:});
        foldername(foldername==' '|foldername==filesep|foldername=='*')='_';
        n=numel(foldername);
        %newfoldername=char('0'+mod(foldername*sign(sin(6*(1:n)'*(1:16)/n)),10));
        if numel(foldername)>100, foldername=foldername(1:100); end
        newfoldername=strcat(newfoldername{:});
        newfoldername=regexprep(newfoldername,'[^\w\d\s\.\(\)\-_@&]+|^\.|\.$','');
        newfoldername=regexprep(deblank(newfoldername),'\s+','_');
        if numel(newfoldername)>250, newfoldername=newfoldername(1:250); end
end

