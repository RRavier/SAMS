initialize;
MappingSetup;
load([workingPath 'Flags.mat'])
load([workingPath 'Names.mat'])
addpath(genpath('./VisualizationScripts/'));
mappingPath = [workingPath 'MappingData/'];

MappingSetupAndFlowExtraction;

if ~isKey(Flags,'featureMappings')
    ComputeFeatureMatching;
else
    disp('Feature mappings already computed');
    load([mappingPath 'FeatureMatches.mat']);
end

MatchesPairsOnFlyWrapper;
RefineInitialMatches;
disp(['Sparse correspondences computed. Please visualize with ' ...
    'visualizeLandmarkCorrespondences before continuing']);


