%% DO NOT EDIT; SETS PATHS AND GUARANTEES PARAMETERS AS REQUIRED

%Set and make relevant paths
workingPath = [projectDir specimenGroup '/'];
touch([workingPath '\MappingData\']);
rmpath(genpath([SAMSPath 'Alignment']));
rmpath(genpath([SAMSPath 'Statistics']));
path(path, genpath([SAMSPath 'Mapping/']));
path(path, genpath([SAMSPath 'utils/']));
path(path, genpath([SAMSPath 'VisualizationScripts']));
rmpath(genpath([SAMSPath 'Mapping/external']));  %this is only called for spheres

%Sanity check for parameters, fix if needed
nullFaceBound = 1e-10;
ConfMaxLocalWidth = max(1,ceil(ConfMaxLocalWidth));
GaussMaxLocalWidth = max(1,ceil(GaussMaxLocalWidth));
MeanMinLocalWidth = max(1,ceil(MeanMinLocalWidth));
DNEMaxLocalWidth = max(1,ceil(DNEMaxLocalWidth));


nbrSize = 1;

if minPerc < 0.5
    minPerc = 0.5;
elseif minPerc > 1
    minPerc = 1;
end
if percDecr < 0
    percDecr = 0.001;   %otherwise infinite loop
end

