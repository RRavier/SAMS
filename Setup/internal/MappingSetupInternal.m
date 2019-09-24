%% DO NOT EDIT; SETS PATHS AND GUARANTEES PARAMETERS AS REQUIRED

%Set and make relevant paths
touch([workingPath '\Default\MappingData']);
rmpath(genpath([SAMSPath 'Alignment']));
rmpath(genpath([SAMSPath 'Statistics']));
path(path, genpath([SAMSPath 'Matching/']));
path(path, genpath([SAMSPath 'utils/'])); 
rmpath(genpath([SAMSPath 'Matching/external']));  %this is only called for spheres

%Sanity check for parameters, fix if needed
ConfMaxLocalWidth = max(1,ceil(ConfMaxLocalWidth));
GaussMaxLocalWidth = max(1,ceil(GaussMaxLocalWidth));
MeanMinLocalWidth = max(1,ceil(MeanMinLocalWidth));
DNEMaxLocalWidth = max(1,ceil(DNEMaxLocalWidth));

NumDensityPts = max(1,ceil(NumDensityPts));                %FPS (Farthest-point sampling)
numGPLmks = max(1,ceil(NumDensityPts));                    %Gaussian Process (GP)

maxDistTol = max(0,maxDistTol);
maxNumLmks = max(maxNumLmks,numGPLmks);

baseLmks = max(10,ceil(baseLmks));
lmkIter = max(10,ceil(lmkIter));
maxNumLmks = min(numGPLmks,ceil(maxNumLmks));
minAlignMatches = max(10,ceil(minAlignMatches));

nbrSize = max(0,ceil(nbrSize));
if minPerc < 0.5
    minPerc = 0.5;
elseif minPerc > 1
    minPerc = 1;
end
if percDecr < 0
    percDecr = 0.001;   %otherwise infinite loop
end
