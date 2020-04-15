%% Threshold matches
load([workingPath '/MappingData/matchesPairs.mat']);
load([workingPath 'MappingData/FeatureMatches.mat']);


frechMesh = meshList{frechMean};
progressbar
for i = 1:length(Names)
    if i ~= frechMean
        curMesh = meshList{i};
        
        [bd_i,~] = meshList{i}.FindOrientedBoundaries;
        rowsToDel = [];
        for j = 1:size(featureMatchesPairs{i})
            if ismember(featureMatchesPairs{i}(j,1),bd_i) || ismember(featureMatchesPairs{i}(j,2),bd_f)
                rowsToDel = [rowsToDel j];
            end
        end
        
        if size(featureMatchesPairs{i},1) > 0
            featureMatchesPairs{i}(rowsToDel,:) = [];
            newMatches = featureMatchesPairs{i}(1,:);
        end
        oldMatches = [featureMatchesPairs{i};matchesPairs{i}];
        possibleMatches = [matchesPairs{i};featureMatchesPairs{i}];
        possibleMatches(1,:) = [];
        
        %newMatches = matchesPairs{i}(1,:);
        
        numMatches = size(newMatches,1);
        while numMatches <= maxNumMatches
            if isempty(possibleMatches)
                break;
            end
            totalDists = zeros(size(possibleMatches,1),1);
            [D_cur,~,~] = meshList{i}.PerformFastMarching(newMatches(:,1));
            [D_frech,~,~] = meshList{frechMean}.PerformFastMarching(newMatches(:,2));
            for k = 1:size(possibleMatches,1)
                totalDists(k)= D_cur(possibleMatches(k,1))+D_frech(possibleMatches(k,2));
            end
            [~,nextInd] = max(totalDists);
            nextInd = nextInd(1);
            if min(D_cur(possibleMatches(nextInd,1)),...
                    D_frech(possibleMatches(nextInd,2))) > minMatchDist ...
                    || minMatchDist <= 0
                newMatches = [newMatches;possibleMatches(nextInd,:)];
                numMatches = numMatches+1;
            end
            possibleMatches(nextInd,:) = [];
        end
        matchesPairs{i} = newMatches;
    end 
    progressbar(i/length(Names));
end
save([workingPath '/MappingData/MatchesPairs_Thresheld.mat'],'matchesPairs');