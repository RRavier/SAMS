touch([workingPath '\Default\MappingData']);
ExtractInitialMappings;
ComputeFeatureMatching;
load([workingPath 'GPDists.mat']);
Flows = ComputeDirectedFlows(GPDists);      %Will take a while, need to make new method
save([workingPath 'Flows.mat'],'Flows');
MatchesPairsWrapper;
load([workingPath 'isDisc.mat']);

disp('If correspondences are not good, abort and tune parameters via Ctrl+C.')
pause(60);
if isDisc == 0
    setupHypOrb;
    CreateFinalMappingsSphere;
else
    CreateFinalMappingsDisc;
end

