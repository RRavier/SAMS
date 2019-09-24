%% Start off by making directories for each group
clear k
metaDir = dir(MetaGroupBasePath);
SpecimenTypes = {};
if length(metaDir) == 3
    if exist([MetaGroupBasePath metaDir(3).name '/Groups.mat']) > 0
        SpecimenTypes = [SpecimenTypes metaDir(3).name];
        if ~exist('keys')
            load([MetaGroupBasePath metaDir(3).name '/Groups.mat']);
            keys = Groups.keys;
        end
    end
else
    for k = 3:length(metaDir)
        if isdir([MetaGroupBasePath metaDir(k).name])
            if exist([MetaGroupBasePath metaDir(k).name '/Groups.mat']) > 0
                SpecimenTypes = [SpecimenTypes metaDir(k).name];
                if ~exist('keys')
                    load([MetaGroupBasePath metaDir(k).name '/Groups.mat']);
                    keys = Groups.keys;
                end
            end


        end
    end
end
for k = 1:length(keys)
    touch([MetaGroupBasePath 'Statistics/' keys{k} '/']);
end
touch([MetaGroupBasePath 'Statistics/' 'Total/'])


    %All tests assume convexity of individual groups!!!
 if strcmp(TemplateShape,'MDS')  
        MDSCollection = cell(1,length(SpecimenTypes));
        MeanCoord = cell(1,length(SpecimenTypes));
        for i = 1:length(SpecimenTypes)
            load([MetaGroupBasePath SpecimenTypes{i} '/MDSEmbedding.mat']);
            MDSCollection{i} = Y;
        end
        
        %% Total Analysis
        dists = cell(1,length(SpecimenTypes));
        for i = 1:length(SpecimenTypes)
            curMean = mean(MDSCollection{i});
            curDists = zeros(size(MDSCollection{i},1),1);
            for j = 1:size(MDSCollection{i},1)
                curDists(j) = norm(MDSCollection{i}(j,:)-curMean);
            end
            dists{i} = curDists;
        end
        for i = 1:length(SpecimenTypes)-1
            for j = (i+1):length(SpecimenTypes)
                if length(dists{i}) > length(dists{j})
                    dists_i = dists{i};
                    dists_j = [dists{j};NaN*ones(length(dists{i})...
                        -length(dists{j}),1)];
                    Specimen1 = SpecimenTypes{i};
                    Specimen2 = SpecimenTypes{j};
                else
                    dists_j = dists{j};
                    dists_i = [dists{i};NaN*ones(length(dists{j})...
                        -length(dists{i}),1)];
                    Specimen1 = SpecimenTypes{j};
                    Specimen2 = SpecimenTypes{i};
                end
                P = vartestn([dists_i dists_j],'TestType','LeveneQuadratic',...
                    'Display','off');
                touch([MetaGroupBasePath 'Statistics/' 'Total/' TemplateShape '/Quad/']);
                save([MetaGroupBasePath 'Statistics/' 'Total/' TemplateShape '/Quad/'...
                    Specimen1 '_' Specimen2 '.mat'],'P');
                P = vartestn([dists_i dists_j],'TestType','LeveneAbsolute',...
                    'Display','off');
                touch([MetaGroupBasePath 'Statistics/' 'Total/' TemplateShape '/Abs/']);
                save([MetaGroupBasePath 'Statistics/' 'Total/' TemplateShape '/Abs/'...
                    Specimen1 '_' Specimen2 '.mat'],'P');
            end
        end
        dists = cell(length(keys),length(SpecimenTypes));
        totalLabels = cell(length(keys),length(SpecimenTypes));
        
        
        %% Group Analysis
        % First step: Obtain different group labels and the lists of unique
        % labels
        for k = 1:length(keys)
            currentKey = keys{k};
            totalUnLabels = {};
            for i = 1:length(SpecimenTypes)
                load([MetaGroupBasePath SpecimenTypes{i} '/Groups.mat']);
                totalLabels{k,i} = lower(Groups(currentKey));
                totalUnLabels = unique([totalUnLabels;unique(totalLabels{k,i})]);
            end
            %Need to extract labels before moving on with analysis so as to
            %make everything consistent
            dists = cell(length(SpecimenTypes),length(totalUnLabels));
            for i = 1:length(SpecimenTypes)
                curMDS = MDSCollection{i};
                for j = 1:length(totalUnLabels)
                    inds = find(strcmp(totalUnLabels{j},totalLabels{k,i}));
                    if isempty(inds)
                        disp(['No ' totalUnLabels{j} ' found in collection of ' ...
                            SpecimenTypes{i}]);
                        continue;
                    end
                    curMean = mean(curMDS(inds,:));
                    curDists = zeros(length(inds),1);
                    for m = 1:length(inds)
                        curDists(m) = norm(MDSCollection{i}(inds(m),:)-curMean);
                    end
                    dists{i,j} = curDists;
                end
            end
            writePath = [MetaGroupBasePath 'Statistics/' keys{k} '/' TemplateShape '/'];
            touch(writePath);
            touch([writePath 'Quad/']); touch([writePath 'Abs/']);
            quadid = fopen([writePath 'Quad/LeveneVals.tsv'],'w');
            absid = fopen([writePath 'Abs/LeveneVals.tsv'],'w');
            for i = 1:length(SpecimenTypes)-1
                for j = (i+1):length(SpecimenTypes)
                    
                    quadDict = {}; absDict = {}; quadP = []; absP = [];
                    for m = 1:length(totalUnLabels)
                        if isempty(dists{i,m}) || isempty(dists{j,m})
                            continue;
                        end
                        touch([writePath 'Quad/' totalUnLabels{m}]); 
                        touch([writePath 'Abs/' totalUnLabels{m}]); 
                        if length(dists{i,m}) > length(dists{j,m})
                            dists_i = dists{i,m};
                            dists_j = [dists{j,m};NaN*ones(length(dists{i,m})...
                                -length(dists{j,m}),1)];
                            Specimen1 = SpecimenTypes{i};
                            Specimen2 = SpecimenTypes{j};
                        else
                            dists_j = dists{j,m};
                            dists_i = [dists{i,m};NaN*ones(length(dists{j,m})...
                                -length(dists{i,m}),1)];
                            Specimen1 = SpecimenTypes{j};
                            Specimen2 = SpecimenTypes{i};
                        end
                        P = vartestn([dists_i dists_j],'TestType','LeveneQuadratic',...
                        'Display','off');
                        save([writePath 'Quad/' totalUnLabels{m} '/' ...
                            SpecimenTypes{i} '_' SpecimenTypes{j} '.mat'],'P');
                        quadDict = [quadDict [totalUnLabels{m} '\t' SpecimenTypes{i} '\t'...
                            SpecimenTypes{j} '\t'  num2str(P) '\n']];
                        quadP = [quadP P];
                        P = vartestn([dists_i dists_j],'TestType','LeveneAbsolute',...
                        'Display','off');
                        absDict = [absDict [totalUnLabels{m} '\t' SpecimenTypes{i} '\t'...
                            SpecimenTypes{j} '\t'  num2str(P) '\n']];
                        absP = [absP P];
                        save([writePath 'Abs/' totalUnLabels{m} '/' ...
                            SpecimenTypes{i} '_' SpecimenTypes{j} '.mat'],'P');
                    end
                    [~,quadInd] = sort(quadP); [~,absInd] = sort(absP);
                    for q = quadInd
                        fprintf(quadid,quadDict{q});
                    end
                    for q = absInd
                        fprintf(absid,absDict{q});
                    end
                end
            end
        end

        
 elseif strcmp(TemplateShape,'SampleMean')
        meshCollection = cell(1,length(SpecimenTypes));
        for i = 1:length(SpecimenTypes)
            load([MetaGroupBasePath SpecimenTypes{i} '/newMeshList.mat']);
            
            for j = 1:length(newMeshList)
                newMeshList{j}.V = newMeshList{j}.V - ...
                    repmat(mean(newMeshList{j}.V')',1,newMeshList{j}.nV);
                newMeshList{j}.V = newMeshList{j}.V/norm(newMeshList{j}.V,'fro');
            end
            meshCollection{i} = newMeshList;
        end
        
        %% Total Analysis
        dists = cell(1,length(SpecimenTypes));
        for i = 1:length(SpecimenTypes)
            curMeanVerts = zeros(3,meshCollection{i}{1}.nV);
            for j = 1:length(meshCollection{i})
                curMeanVerts = curMeanVerts + meshCollection{i}{j}.V;
            end
            curMeanVerts = curMeanVerts/length(meshCollection{i});
            %Project back to Procrustes space
            curMeanVerts = curMeanVerts - repmat(mean(curMeanVerts')',1,size(curMeanVerts,2));
            curMeanVerts = curMeanVerts/norm(curMeanVerts,'fro');
            curDists = zeros(length(meshCollection{i}),1);
            for j = 1:length(meshCollection{i})
                curDists(j) = norm(meshCollection{i}{j}.V-curMeanVerts,'fro');
            end
            dists{i} = curDists;
        end
        for i = 1:length(SpecimenTypes)-1
            for j = (i+1):length(SpecimenTypes)
                if length(dists{i}) > length(dists{j})
                    dists_i = dists{i};
                    dists_j = [dists{j};NaN*ones(length(dists{i})...
                        -length(dists{j}),1)];
                    Specimen1 = SpecimenTypes{i};
                    Specimen2 = SpecimenTypes{j};
                else
                    dists_j = dists{j};
                    dists_i = [dists{i};NaN*ones(length(dists{j})...
                        -length(dists{i}),1)];
                    Specimen1 = SpecimenTypes{j};
                    Specimen2 = SpecimenTypes{i};
                end
                P = vartestn([dists_i dists_j],'TestType','LeveneQuadratic',...
                    'Display','off');
                touch([MetaGroupBasePath 'Statistics/' 'Total/' TemplateShape '/Quad/']);
                save([MetaGroupBasePath 'Statistics/' 'Total/' TemplateShape '/Quad/'...
                    Specimen1 '_' Specimen2 '.mat'],'P');
                P = vartestn([dists_i dists_j],'TestType','LeveneAbsolute',...
                    'Display','off');
                touch([MetaGroupBasePath 'Statistics/' 'Total/' TemplateShape '/Abs/']);
                save([MetaGroupBasePath 'Statistics/' 'Total/' TemplateShape '/Abs/'...
                    Specimen1 '_' Specimen2 '.mat'],'P');
            end
        end
        dists = cell(length(keys),length(SpecimenTypes));
        totalLabels = cell(length(keys),length(SpecimenTypes));
        
        
        %% Group Analysis
        % First step: Obtain different group labels and the lists of unique
        % labels
        for k = 1:length(keys)
            currentKey = keys{k};
            totalUnLabels = {};
            for i = 1:length(SpecimenTypes)
                load([MetaGroupBasePath SpecimenTypes{i} '/Groups.mat']);
                totalLabels{k,i} = lower(Groups(currentKey));
                totalUnLabels = unique([totalUnLabels;unique(totalLabels{k,i})]);
            end
            %Need to extract labels before moving on with analysis so as to
            %make everything consistent
            dists = cell(length(SpecimenTypes),length(totalUnLabels));
            for i = 1:length(SpecimenTypes)
                for j = 1:length(totalUnLabels)
                    inds = find(strcmp(totalUnLabels{j},totalLabels{k,i}));
                    if isempty(inds)
                        disp(['No ' totalUnLabels{j} ' found in collection of ' ...
                            SpecimenTypes{i}]);
                        continue;
                    end
                    curMeanVerts = zeros(3,meshCollection{i}{1}.nV);
                    for m = inds
                        curMesh =meshCollection{i}{m};
                        curMeanVerts = curMeanVerts + curMesh.V;
                    end
                    curMeanVerts = curMeanVerts/length(inds);
                    %Project back to Procrustes space
                    curMeanVerts = curMeanVerts - repmat(mean(curMeanVerts')',1,size(curMeanVerts,2));
                    curMeanVerts = curMeanVerts/norm(curMeanVerts,'fro');
                    curDists = zeros(length(inds),1);
                    for m = 1:length(inds)
                        curDists(m) = norm(meshCollection{i}{inds(m)}.V-curMeanVerts,'fro');
                    end
                    
                    dists{i,j} = curDists;
                end
            end
            writePath = [MetaGroupBasePath 'Statistics/' keys{k} '/' TemplateShape '/'];
            touch(writePath);
            touch([writePath 'Quad/']); touch([writePath 'Abs/']);
            quadid = fopen([writePath 'Quad/LeveneVals.tsv'],'w');
            absid = fopen([writePath 'Abs/LeveneVals.tsv'],'w');
            for i = 1:length(SpecimenTypes)-1
                for j = (i+1):length(SpecimenTypes)
                    
                    quadDict = {}; absDict = {}; quadP = []; absP = [];
                    for m = 1:length(totalUnLabels)
                        if isempty(dists{i,m}) || isempty(dists{j,m})
                            continue;
                        end
                        touch([writePath 'Quad/' totalUnLabels{m}]); 
                        touch([writePath 'Abs/' totalUnLabels{m}]); 
                        if length(dists{i,m}) > length(dists{j,m})
                            dists_i = dists{i,m};
                            dists_j = [dists{j,m};NaN*ones(length(dists{i,m})...
                                -length(dists{j,m}),1)];
                            Specimen1 = SpecimenTypes{i};
                            Specimen2 = SpecimenTypes{j};
                        else
                            dists_j = dists{j,m};
                            dists_i = [dists{i,m};NaN*ones(length(dists{j,m})...
                                -length(dists{i,m}),1)];
                            Specimen1 = SpecimenTypes{j};
                            Specimen2 = SpecimenTypes{i};
                        end
                        P = vartestn([dists_i dists_j],'TestType','LeveneQuadratic',...
                        'Display','off');
                        save([writePath 'Quad/' totalUnLabels{m} '/' ...
                            SpecimenTypes{i} '_' SpecimenTypes{j} '.mat'],'P');
                        quadDict = [quadDict [totalUnLabels{m} '\t' SpecimenTypes{i} '\t'...
                            SpecimenTypes{j} '\t'  num2str(P) '\n']];
                        quadP = [quadP P];
                        P = vartestn([dists_i dists_j],'TestType','LeveneAbsolute',...
                        'Display','off');
                        absDict = [absDict [totalUnLabels{m} '\t' SpecimenTypes{i} '\t'...
                            SpecimenTypes{j} '\t'  num2str(P) '\n']];
                        absP = [absP P];
                        save([writePath 'Abs/' totalUnLabels{m} '/' ...
                            SpecimenTypes{i} '_' SpecimenTypes{j} '.mat'],'P');
                    end
                    [~,quadInd] = sort(quadP); [~,absInd] = sort(absP);
                    for q = quadInd
                        fprintf(quadid,quadDict{q});
                    end
                    for q = absInd
                        fprintf(absid,absDict{q});
                    end
                end
            end
        end
 elseif strcmp(TemplateShape,'WeightedMean')
        meshCollection = cell(1,length(SpecimenTypes));
        for i = 1:length(SpecimenTypes)
            load([MetaGroupBasePath SpecimenTypes{i} '/newMeshList.mat']);
            
            for j = 1:length(newMeshList)
                newMeshList{j}.V = newMeshList{j}.V - ...
                    repmat(mean(newMeshList{j}.V')',1,newMeshList{j}.nV);
                newMeshList{j}.V = newMeshList{j}.V/norm(newMeshList{j}.V,'fro');
            end
            meshCollection{i} = newMeshList;
        end
        
        %% Total Analysis
        dists = cell(1,length(SpecimenTypes));
        for i = 1:length(SpecimenTypes)
            curMeanVerts = zeros(3,meshCollection{i}{1}.nV);
            for j = 1:length(meshCollection{i})
                curMeanVerts = curMeanVerts + meshCollection{i}{j}.V;
            end
            curMeanVerts = curMeanVerts/length(meshCollection{i});
            %Project back to Procrustes space
            curMeanVerts = curMeanVerts - repmat(mean(curMeanVerts')',1,size(curMeanVerts,2));
            curMeanVerts = curMeanVerts/norm(curMeanVerts,'fro');
            curDists = zeros(length(meshCollection{i}),1);
            for j = 1:length(meshCollection{i})
                curDists(j) = norm(meshCollection{i}{j}.V-curMeanVerts,'fro');
            end
            dists{i} = curDists;
        end
        for i = 1:length(SpecimenTypes)-1
            for j = (i+1):length(SpecimenTypes)
                if length(dists{i}) > length(dists{j})
                    dists_i = dists{i};
                    dists_j = [dists{j};NaN*ones(length(dists{i})...
                        -length(dists{j}),1)];
                    Specimen1 = SpecimenTypes{i};
                    Specimen2 = SpecimenTypes{j};
                else
                    dists_j = dists{j};
                    dists_i = [dists{i};NaN*ones(length(dists{j})...
                        -length(dists{i}),1)];
                    Specimen1 = SpecimenTypes{j};
                    Specimen2 = SpecimenTypes{i};
                end
                P = vartestn([dists_i dists_j],'TestType','LeveneQuadratic',...
                    'Display','off');
                touch([MetaGroupBasePath 'Statistics/' 'Total/' TemplateShape '/Quad/']);
                save([MetaGroupBasePath 'Statistics/' 'Total/' TemplateShape '/Quad/'...
                    Specimen1 '_' Specimen2 '.mat'],'P');
                P = vartestn([dists_i dists_j],'TestType','LeveneAbsolute',...
                    'Display','off');
                touch([MetaGroupBasePath 'Statistics/' 'Total/' TemplateShape '/Abs/']);
                save([MetaGroupBasePath 'Statistics/' 'Total/' TemplateShape '/Abs/'...
                    Specimen1 '_' Specimen2 '.mat'],'P');
            end
        end
        dists = cell(length(keys),length(SpecimenTypes));
        totalLabels = cell(length(keys),length(SpecimenTypes));
        
        
        %% Group Analysis
        % First step: Obtain different group labels and the lists of unique
        % labels
        for k = 1:length(keys)
            currentKey = keys{k};
            totalUnLabels = {};
            for i = 1:length(SpecimenTypes)
                load([MetaGroupBasePath SpecimenTypes{i} '/Groups.mat']);
                totalLabels{k,i} = lower(Groups(currentKey));
                totalUnLabels = unique([totalUnLabels;unique(totalLabels{k,i})]);
            end
            %Need to extract labels before moving on with analysis so as to
            %make everything consistent
            dists = cell(length(SpecimenTypes),length(totalUnLabels));
            for i = 1:length(SpecimenTypes)
                for j = 1:length(totalUnLabels)
                    inds = find(strcmp(totalUnLabels{j},totalLabels{k,i}));
                    if isempty(inds)
                        disp(['No ' totalUnLabels{j} ' found in collection of ' ...
                            SpecimenTypes{i}]);
                        continue;
                    end
                    curMeanVerts = zeros(3,meshCollection{i}{1}.nV);
                    for m = inds
                        curMesh =meshCollection{i}{m};
                        curMeanVerts = curMeanVerts + curMesh.V;
                    end
                    curMeanVerts = curMeanVerts/length(inds);
                    %Project back to Procrustes space
                    curMeanVerts = curMeanVerts - repmat(mean(curMeanVerts')',1,size(curMeanVerts,2));
                    curMeanVerts = curMeanVerts/norm(curMeanVerts,'fro');
                    curDists = zeros(length(inds),1);
                    for m = 1:length(inds)
                        curDists(m) = norm(meshCollection{i}{inds(m)}.V-curMeanVerts,'fro');
                    end
                    
                    dists{i,j} = curDists;
                end
            end
            writePath = [MetaGroupBasePath 'Statistics/' keys{k} '/' TemplateShape '/'];
            touch(writePath);
            touch([writePath 'Quad/']); touch([writePath 'Abs/']);
            quadid = fopen([writePath 'Quad/LeveneVals.tsv'],'w');
            absid = fopen([writePath 'Abs/LeveneVals.tsv'],'w');
            for i = 1:length(SpecimenTypes)-1
                for j = (i+1):length(SpecimenTypes)
                    
                    quadDict = {}; absDict = {}; quadP = []; absP = [];
                    for m = 1:length(totalUnLabels)
                        if isempty(dists{i,m}) || isempty(dists{j,m})
                            continue;
                        end
                        touch([writePath 'Quad/' totalUnLabels{m}]); 
                        touch([writePath 'Abs/' totalUnLabels{m}]); 
                        if length(dists{i,m}) > length(dists{j,m})
                            dists_i = dists{i,m};
                            dists_j = [dists{j,m};NaN*ones(length(dists{i,m})...
                                -length(dists{j,m}),1)];
                            Specimen1 = SpecimenTypes{i};
                            Specimen2 = SpecimenTypes{j};
                        else
                            dists_j = dists{j,m};
                            dists_i = [dists{i,m};NaN*ones(length(dists{j,m})...
                                -length(dists{i,m}),1)];
                            Specimen1 = SpecimenTypes{j};
                            Specimen2 = SpecimenTypes{i};
                        end
                        P = vartestn([dists_i dists_j],'TestType','LeveneQuadratic',...
                        'Display','off');
                        save([writePath 'Quad/' totalUnLabels{m} '/' ...
                            SpecimenTypes{i} '_' SpecimenTypes{j} '.mat'],'P');
                        quadDict = [quadDict [totalUnLabels{m} '\t' SpecimenTypes{i} '\t'...
                            SpecimenTypes{j} '\t'  num2str(P) '\n']];
                        quadP = [quadP P];
                        P = vartestn([dists_i dists_j],'TestType','LeveneAbsolute',...
                        'Display','off');
                        absDict = [absDict [totalUnLabels{m} '\t' SpecimenTypes{i} '\t'...
                            SpecimenTypes{j} '\t'  num2str(P) '\n']];
                        absP = [absP P];
                        save([writePath 'Abs/' totalUnLabels{m} '/' ...
                            SpecimenTypes{i} '_' SpecimenTypes{j} '.mat'],'P');
                    end
                    [~,quadInd] = sort(quadP); [~,absInd] = sort(absP);
                    for q = quadInd
                        fprintf(quadid,quadDict{q});
                    end
                    for q = absInd
                        fprintf(absid,absDict{q});
                    end
                end
            end
        end
 elseif strcmp(TemplateShape,'FrechetMean')
        meshCollection = cell(1,length(SpecimenTypes));
        for i = 1:length(SpecimenTypes)
            load([MetaGroupBasePath SpecimenTypes{i} '/newMeshList.mat']);
            meshCollection{i} = newMeshList;
        end
 end
