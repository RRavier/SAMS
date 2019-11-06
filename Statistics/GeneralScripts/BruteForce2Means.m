function [minVal,minGroupA,pVal] = BruteForce2Means(x,inds1,inds2)

N = size(x,2);
len=length(inds1);
totalComb = combnk(1:N,len);
numPerm = size(totalComb,1);
disp(['Number of Permutations: ' num2str(numPerm)]);
values = zeros(1,numPerm);
H = zeros(numPerm,1);

disp('Brute force computing clustering...');
progressbar
for i=1:numPerm
    H(i) = max(sum(ismember(totalComb(i,:),length(inds1)))/length(inds1)...
        ,sum(ismember(totalComb(i,:),length(inds2)))/length(inds2));
    values(i) = KMeans_Cost(x,p);
    progressbar(i/numPerm);
end
[minVal,minInd] = min(values);
minGroupA = totalComb(minInd,:);
pVal = sum(H>H(minInd))/numPerm;
end