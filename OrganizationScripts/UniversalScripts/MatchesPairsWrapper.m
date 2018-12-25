load([workingPath 'GPDists.mat']);
load([workingPath 'isDisc.mat']);
meshList = cell(length(Names),1);
for i = 1:length(Names)
    load([workingPath 'ProcessedMAT/' Names{i} '.mat']);
    meshList{i}=G;
end
frechMean = find(sum(GPDists.^2)==min(sum(GPDists.^2)));
matchesPairs = cell(length(Names),1);
baseLmks = 150;     %Tuned
lmkIter = 50;       %Tuned
disp('Computing Pairwise Matchings for Mesh:');
for i = 1:length(Names)
    disp(i)
    if i ~=frechMean
        numLmks = baseLmks;
        while true
        
            [testMatches,~] = ExtractMatchesPairs(1,.984,.001,i,frechMean,numLmks,1,.05,.5,workingPath,isDisc);
            testMatches = unique(testMatches,'rows');
            if size(testMatches,1) >= 20 || numLmks == 500
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
load([workingPath 'MappingData/ConformalMatches.mat']);
maxNumMatches = 20;

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
%         curMeshDists = pdist2(curMesh.V(:,oldMatches(:,1))',curMesh.V(:,oldMatches(:,1))');
%         frechMeshDists = pdist2(frechMesh.V(:,oldMatches(:,2))',frechMesh.V(:,oldMatches(:,2))');
%         newMatches = 1:size(confMatchesPairs{i},1);
%         lmkInds = 1:size(matchesPairs{i},1);
%         for j = size(newMatches,2)+1:maxNumMatches
%             testInds = lmkInds(~ismember(lmkInds,newMatches));
%             testDists = sum(curMeshDists(newMatches,:).^2,1)+sum(frechMeshDists(newMatches,:).^2,1);
%             testDists(newMatches) = 0;
%             newMatches = [newMatches find(testDists == max(testDists))];
%         end
%         matchesPairs{i} = oldMatches(newMatches,:);
        matchesPairs{i} = newMatches;
    end
end
save([workingPath '/MappingData/MatchesPairs_Thresheld.mat'],'matchesPairs');