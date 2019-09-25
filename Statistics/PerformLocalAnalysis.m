close all

FPC = {'None','FWER','Bonferroni'};
options.mode = 'native';
%alpha = significance level
%method = type of T-test to use. Values are
%FPC = method of false positive correction
for s = 1:length(SpecimenTypes)
    curPath = [MetaGroupBasePath SpecimenTypes{s} '/'];
    load([curPath 'Groups.mat']);
    load([curPath 'newMeshList.mat']);
    keys = Groups.keys;
    for g = 1:length(Groups.keys)
        curLabels = Groups(keys{g});
        unLabels = unique(curLabels);
        labelGroups = cell(size(unLabels));
        for i = 1:length(unLabels)
            inds = find(strcmp(curLabels,unLabels{i}));
            labelGroups{i} = cell(size(inds));
            for j = 1:length(inds)
                labelGroups{i}{j} = newMeshList{inds(j)};
            end
        end
        labelMeans = cell(size(unLabels));
        for i = 1:length(unLabels)
            len = length(labelGroups{i});
            verts = zeros(size(labelGroups{1}{1}.V));
            for j = 1:length(labelGroups{i})
                verts = verts + labelGroups{i}{j}.V/len;
            end
            labelMeans{i} = Mesh('VF',verts,labelGroups{1}{1}.F);
        end
        for p = 1:length(pValues)
            exp = 0;
            while true
                if rem(pValues(p)*10^(exp),1) == 0
                    break;
                else
                    exp = exp+1;
                end
            end
            %set all folders
            touch([curPath 'HeatMaps/']);
            touch([curPath 'HeatMaps/' keys{g} '/']);
            touch([curPath 'HeatMaps/' keys{g} '/One_Sample/']);
            for c = 1:length(FPC)
                touch([curPath 'HeatMaps/' keys{g} '/One_Sample/' FPC{c} '/']);
                touch([curPath 'HeatMaps/' keys{g} '/One_Sample/' FPC{c} '/'...
                    num2str(pValues(p)*10^(exp)) 'e-' num2str(exp) '/']);
            end
            for t = 1:length(TTestType)
                touch([curPath 'HeatMaps/' keys{g} '/' TTestType{t} '/']);
                for c = 1:length(FPC)
                    touch([curPath 'HeatMaps/' keys{g} '/' TTestType{t} '/' FPC{c} '/']);
                    touch([curPath 'HeatMaps/' keys{g} '/' TTestType{t} '/' FPC{c} '/'...
                        num2str(pValues(p)*10^(exp)) 'e-' num2str(exp) '/']);
                end
            end
        end
        for i = 1:length(labelGroups)
            for j = (i+1):length(labelGroups)
                %Setup data for analysis: align with respect to average
                %mean, and create models needed for plots
                disp([unLabels{i} ' vs ' unLabels{j}]);
                curMeanVerts = .5*(labelMeans{i}.V+labelMeans{j}.V);
                curMeanVerts = curMeanVerts - repmat(mean(curMeanVerts,2),1,labelMeans{i}.nV);
                curMeanVerts = curMeanVerts/norm(curMeanVerts,'fro');
                curMeanMesh = Mesh('VF',curMeanVerts,labelMeans{i}.F);
                groups1 = labelGroups{i}; groups2 = labelGroups{j};
                g1MeanVerts = zeros(size(groups1{1}.V));
                for q = 1: length(groups1)
                    [U,~,V] = svd(groups1{q}.V*(curMeanMesh.V'));
                    R = V*U';
                    newVerts = groups1{q}.V;
                    for s = 1:size(newVerts,2)
                        newVerts(:,s) = R*newVerts(:,s);
                    end
                    groups1{q}.V = newVerts;
                    g1MeanVerts = g1MeanVerts+groups1{q}.V;
                end
                g1MeanVerts = g1MeanVerts/length(groups1);
                g1MeanVerts = g1MeanVerts - repmat(mean(g1MeanVerts,2),1,groups1{1}.nV);
                g1MeanVerts = g1MeanVerts/norm(g1MeanVerts,'fro');
                g1Mean = Mesh('VF',g1MeanVerts,groups1{1}.F);

                g2MeanVerts = zeros(size(groups2{1}.V));
                for q = 1: length(groups2)
                    [U,~,V] = svd(groups2{q}.V*(curMeanMesh.V'));
                    R = V*U';
                    newVerts = groups2{q}.V;
                    for s = 1:size(newVerts,2)
                        newVerts(:,s) = R*newVerts(:,s);
                    end
                    groups2{q}.V = newVerts;
                    g2MeanVerts = g2MeanVerts+groups2{q}.V;
                end
                g2MeanVerts = g2MeanVerts/length(groups2);
                g2MeanVerts = g2MeanVerts - repmat(mean(g2MeanVerts,2),1,groups2{1}.nV);
                g2MeanVerts = g2MeanVerts/norm(g2MeanVerts,'fro');
                g2Mean = Mesh('VF',g2MeanVerts,groups2{1}.F);
                %Perform tests is able
                if length(groups1) == 1 || length(groups2) == 1
                    if max(length(groups1),length(groups2)) <= size(groups1{1}.V,1)
                        disp(['Too few samples to do statistical test, skipping']);
                    continue;
                    else
                        disp(['Performing 1-sample T-test'])
                        [~,pVal] = TTest_OneSample(groups1,groups2);
                        [sortP,idx] = sort(pVal);
                        for p = 1:length(pValues)
                            disp([unLabels{i} ' vs. ' unLabels{j} ' ' TTestType{t} ' ' num2str(pValues(p))]);
                            for c = 1:length(FPC)
                                curFPC = FPC{c};
                                switch curFPC
                                    case 'FWER'
                                        maxP = sortP(max(find(sortP<(pValues(p)*(1:length(sortP))/length(sortP)))));
                                    case 'Bonferroni'
                                        maxP = sortP(max(find(sortP<(pValues(p)/g1Mean.nV))));
                                    case 'None'
                                        maxP = sortP(max(find(sortP<pValues(p))));
                                end
                                if isempty(maxP)
                                    disp(['No significant points detected for ' curFPC ' FPC, skipping']);
                                    continue;
                                end
                                extrPts = double((1-pVal) >= (1-maxP));
                                heatMap = zeros(1,length(extrPts));
                                for k = 1:length(extrPts)
                                    heatMap(idx(k)) = extrPts(idx(k))*(0.2+0.8*(maxP-pVal(idx(k)))/(maxP+0.00001));
                                end
                                clear h
                                clear Link
                                figure
                                h(1) = subplot(1,2,1);
                                g1Mean.ViewFunctionOnMesh(heatMap',options);
                                hold on
                                axis off
                                if viewDisplace
                                    if size(extrPts,1) ~=1
                                        extrPts = extrPts';
                                    end
                                    displace = g2Mean.V - g1Mean.V;
                                    displace(1,:) = displace(1,:).*extrPts;
                                    displace(2,:) = displace(2,:).*extrPts;
                                    displace(3,:) = displace(3,:).*extrPts;
                                    displaceColor = dot(displace,g1Mean.ComputeNormal)/sqrt(sum(displace.^2));
                                    displaceColor = .5*displaceColor+.5;
                                    displaceColorMat = [];
                                    for k = 1:length(displaceColor)
                                        displaceColorMat = [displaceColorMat; [1 1 1]*displaceColor(k)];
                                    end
                                    quiver3(g1Mean.V(1,:),g1Mean.V(2,:),g1Mean.V(3,:),...
                                        displace(1,:),displace(2,:),displace(3,:),'Color','k');
                                end
                                h(2) = subplot(1,2,2);
                                g2Mean.ViewFunctionOnMesh(heatMap',options);
                                hold on
                                axis off
                                if viewDisplace
                                    displace = g1Mean.V - g2Mean.V;
                                    displace(1,:) = displace(1,:).*extrPts;
                                    displace(2,:) = displace(2,:).*extrPts;
                                    displace(3,:) = displace(3,:).*extrPts;
                                    displaceColor = dot(displace,g2Mean.ComputeNormal)/sqrt(sum(displace.^2));
                                    displaceColor = .5*displaceColor+.5;
                                    displaceColorMat = [];
                                    for k = 1:length(displaceColor)
                                        displaceColorMat = [displaceColorMat; [1 1 1]*displaceColor(k)];
                                    end
                                    quiver3(g2Mean.V(1,:),g2Mean.V(2,:),g2Mean.V(3,:),...
                                        displace(1,:),displace(2,:),displace(3,:),'Color','k');
                                end
                                Link = linkprop(h, {'CameraUpVector',...
                                    'CameraPosition', 'CameraTarget', 'CameraViewAngle'});
                                %Quick Conversion To Scientific Notation
                                setappdata(gcf, 'StoreTheLink', Link);
                                figPath = [curPath 'HeatMaps/' keys{g} '/OneSample/' FPC{c} '/' ...
                                    num2str(pValues(p)*10^(exp)) ...
                                    'e-' num2str(exp) '/'];
                                saveas(gcf,[figPath unLabels{i} '_' unLabels{j}]);  
                                close all
                            end
                        end
                    end
        %         elseif length(labelGroups{i}) == 1 || length(labelGroups{j}) == o 1
        %             disp(['Too few samples to do family test, must do one sample']);
        %             [~,pVal] = TTest_Standard(labelGroups{i},labelGroups{j});
                elseif length(groups1)+length(groups2) <= (size(groups1{1}.V,1)+1)
                    disp('Not enough samples to do two-sample comparison, skipping');
                else
                    for t = 1:length(TTestType)
                        curTest = TTestType{t};
                        switch curTest
                            case 'EqualCovariance'
                                [~,pVal] = TTest_Standard(groups1,groups2);
                            case 'UnequalCovariance'
                                [~,pVal] = TTest_Unequal(groups1,groups2);
                            case 'EqualCovariance_Permutation'
                                numPerm = ceil(.25/(localAlpha^2));
                                [~,pVal] = TTest_Standard_Permutation(groups1,groups2,numPerm);
                            case 'UnequalCovariance_Permutation'
                                numPerm = ceil(.25/(localAlpha^2));
                                [~,pVal] = TTest_Unequal_Permutation(groups1,groups2,numPerm);
                        end
                        [sortP,idx] = sort(pVal);
                        for p = 1:length(pValues)
                            disp([unLabels{i} ' vs. ' unLabels{j} ' ' TTestType{t} ' ' num2str(pValues(p))]);
                            for c = 1:length(FPC)
                                curFPC = FPC{c};
                                switch curFPC
                                    case 'FWER'
                                        maxP = sortP(max(find(sortP<(pValues(p)*(1:length(sortP))/length(sortP)))));
                                    case 'Bonferroni'
                                        maxP = sortP(max(find(sortP<(pValues(p)/g1Mean.nV))));
                                    case 'None'
                                        maxP = sortP(max(find(sortP<pValues(p))));
                                end
                                if isempty(maxP)
                                    disp(['No significant points detected for ' curFPC ' FPC, skipping']);
                                    continue;
                                end
                                extrPts = double((1-pVal) >= (1-maxP));
                                heatMap = zeros(1,length(extrPts));
                                for k = 1:length(extrPts)
                                    heatMap(idx(k)) = extrPts(idx(k))*(0.2+0.8*(maxP-pVal(idx(k)))/(maxP+0.00001));
                                end
                                clear h
                                clear Link
                                figure
                                h(1) = subplot(1,2,1);
                                g1Mean.ViewFunctionOnMesh(heatMap',options);
                                hold on
                                axis off
                                if viewDisplace
                                    if size(extrPts,1) ~=1
                                        extrPts = extrPts';
                                    end
                                    displace = g2Mean.V - g1Mean.V;
                                    displace(1,:) = displace(1,:).*extrPts;
                                    displace(2,:) = displace(2,:).*extrPts;
                                    displace(3,:) = displace(3,:).*extrPts;
                                    displaceColor = dot(displace,g1Mean.ComputeNormal)/sqrt(sum(displace.^2));
                                    displaceColor = .5*displaceColor+.5;
                                    displaceColorMat = [];
                                    for k = 1:length(displaceColor)
                                        displaceColorMat = [displaceColorMat; [1 1 1]*displaceColor(k)];
                                    end
                                    quiver3(g1Mean.V(1,:),g1Mean.V(2,:),g1Mean.V(3,:),...
                                        displace(1,:),displace(2,:),displace(3,:),'Color','k');
                                end
                                h(2) = subplot(1,2,2);
                                g2Mean.ViewFunctionOnMesh(heatMap',options);
                                hold on
                                axis off
                                if viewDisplace
                                    displace = g1Mean.V - g2Mean.V;
                                    displace(1,:) = displace(1,:).*extrPts;
                                    displace(2,:) = displace(2,:).*extrPts;
                                    displace(3,:) = displace(3,:).*extrPts;
                                    displaceColor = dot(displace,g2Mean.ComputeNormal)/sqrt(sum(displace.^2));
                                    displaceColor = .5*displaceColor+.5;
                                    displaceColorMat = [];
                                    for k = 1:length(displaceColor)
                                        displaceColorMat = [displaceColorMat; [1 1 1]*displaceColor(k)];
                                    end
                                    quiver3(g2Mean.V(1,:),g2Mean.V(2,:),g2Mean.V(3,:),...
                                        displace(1,:),displace(2,:),displace(3,:),'Color','k');
                                end
                                Link = linkprop(h, {'CameraUpVector',...
                                    'CameraPosition', 'CameraTarget', 'CameraViewAngle'});
                                %Quick Conversion To Scientific Notation
                                setappdata(gcf, 'StoreTheLink', Link);
                                figPath = [curPath 'HeatMaps/' keys{g} '/' ...
                                    TTestType{t} '/' FPC{c} '/' ...
                                    num2str(pValues(p)*10^(exp)) ...
                                    'e-' num2str(exp) '/'];
                                saveas(gcf,[figPath unLabels{i} '_' unLabels{j}]);  
                                close all
                            end
                        end      
                    end
                end
            end
        end
    end
end

