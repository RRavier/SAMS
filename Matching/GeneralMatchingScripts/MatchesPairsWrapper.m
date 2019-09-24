load([workingPath 'GPDists.mat']);
load([workingPath 'Flags.mat']);
load([workingPath 'Names.mat']);
meshList = cell(length(Names),1);
for i = 1:length(Names)
    load([workingPath 'ProcessedMAT/' Names{i} '.mat']);
    meshList{i}=G;
end
frechMean = find(sum(GPDists.^2)==min(sum(GPDists.^2)));
matchesPairs = cell(length(Names),1);

if ~isfield(Flags,'RefinementComputed') || ForceRefinement
    disp('Computing Pairwise Matchings for Mesh:');
    for i = 1:length(Names)
        disp(i)
        if i ~=frechMean
            numLmks = baseLmks;
            while true

                [testMatches,~] = ExtractMatchesPairs(pathWtTemp,startPathWt,pathWtDecr,...
                    i,frechMean,numLmks,nbrSize,percDecr,minPerc,workingPath);
                testMatches = unique(testMatches,'rows');
                if size(testMatches,1) >= minAlignMatches || numLmks + lmkIter > maxNumLmks
                    matchesPairs{i} = testMatches;
                    break;
                else
                    numLmks = numLmks+lmkIter;
                end
            end
        end
    end
    [bd_f,~] = meshList{frechMean}.FindOrientedBoundaries;
    for i = 1:length(Names)
        rowsToDel = [];
        if i ~= frechMean
            [bd_i,~] = meshList{i}.FindOrientedBoundaries;
            for j = 1:size(matchesPairs{i})
                if ismember(matchesPairs{i}(j,1),bd_i) || ismember(matchesPairs{i}(j,2),bd_f)
                    rowsToDel = [rowsToDel j];
                end
            end
            matchesPairs{i}(rowsToDel,:) = [];
        end
    end
    save([workingPath '/MappingData/matchesPairs.mat'],'matchesPairs');
    Flags('RefinementComputed') = 1;
    save([workingPath 'Flags.mat'],'Flags');
end
%above save step done in case of errors
load([workingPath '/MappingData/matchesPairs.mat']);
load([workingPath 'MappingData/FeatureMatches.mat']);


frechMesh = meshList{frechMean};
for i = 1:length(Names)
    if i ~= frechMean
        if (size(matchesPairs{i},1)+size(featureMatchesPairs{i},1)) <= maxNumMatches
            matchesPairs{i} = [matchesPairs{i};featureMatchesPairs{i}];
            continue;
        end
        curMesh = meshList{i};
        
        [bd_i,~] = meshList{i}.FindOrientedBoundaries;
        rowsToDel = [];
        for j = 1:size(featureMatchesPairs{i})
            if ismember(featureMatchesPairs{i}(j,1),bd_i) || ismember(featureMatchesPairs{i}(j,2),bd_f)
                rowsToDel = [rowsToDel j];
            end
        end
        
        featureMatchesPairs{i}(rowsToDel,:) = [];
        oldMatches = [featureMatchesPairs{i};matchesPairs{i}];
        possibleMatches = [matchesPairs{i};featureMatchesPairs{i}];
        newMatches = featureMatchesPairs{i};
        %newMatches = matchesPairs{i}(1,:);
        
        for j = size(newMatches,1)+1:maxNumMatches
            totalDists = zeros(size(possibleMatches,1),1);
            [D_cur,~,~] = meshList{i}.PerformFastMarching(newMatches(:,1));
            [D_frech,~,~] = meshList{frechMean}.PerformFastMarching(newMatches(:,2));
            for k = 1:size(possibleMatches,1)
                totalDists(k)= D_cur(possibleMatches(k,1))+D_frech(possibleMatches(k,2));
            end
            [~,nextInd] = max(totalDists);
            nextInd = nextInd(1);
            newMatches = [newMatches;possibleMatches(nextInd,:)];
            possibleMatches(nextInd,:) = [];
        end
        matchesPairs{i} = newMatches;
    end
end
save([workingPath '/MappingData/MatchesPairs_Thresheld.mat'],'matchesPairs');