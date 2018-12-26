load([workingPath 'GPDists.mat']);
load([workingPath 'isDisc.mat']);
meshList = cell(length(Names),1);
for i = 1:length(Names)
    load([workingPath 'ProcessedMAT/' Names{i} '.mat']);
    meshList{i}=G;
end
frechMean = find(sum(GPDists.^2)==min(sum(GPDists.^2)));
matchesPairs = cell(length(Names),1);

disp('Computing Pairwise Matchings for Mesh:');
for i = 1:length(Names)
    disp(i)
    if i ~=frechMean
        numLmks = baseLmks;
        while true
        
            [testMatches,~] = ExtractMatchesPairs(pathWtTemp,minPathWt,pathWtDecr,...
                i,frechMean,numLmks,nbrSize,percDecr,minPerc,workingPath);
            testMatches = unique(testMatches,'rows');
            if size(testMatches,1) >= minAlignMatches || numLmks == maxNumLmks
                matchesPairs{i} = testMatches;
                break;
            else
                numLmks = numLmks+lmkIter;
            end
        end
    end
end
save([workingPath '/MappingData/matchesPairs.mat'],'matchesPairs');
%pare down to at most 30 via euclidean FPS; start with first landmark as
%seed as that is among most likely matches
load([workingPath '/MappingData/matchesPairs.mat']);
load([workingPath 'MappingData/FeatureMatches.mat']);


frechMesh = meshList{frechMean};
for i = 1:length(Names)
    if i ~= frechMean
        if size(matchesPairs{i},1) <= maxNumMatches
            continue;
        end
        curMesh = meshList{i};
        oldMatches = [ConformalMatches{i,frechMean};matchesPairs{i}];
        possibleMatches = [matchesPairs{i};ConformalMatches{i,frechMean}];
        newMatches = ConformalMatches{i,frechMean};
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