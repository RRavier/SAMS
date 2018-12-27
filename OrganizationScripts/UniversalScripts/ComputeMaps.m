ExtractInitialMappings;
ComputeFeatureMatching;
load([workingPath 'GPDists.mat']);
Flows = ComputeDirectedFlowsTo(GPDists);      %Will take a while, need to make new method
save([workingPath 'Flows.mat'],'Flows');
MatchesPairsWrapper;
load([workingPath 'isDisc.mat']);
CreateFinalMappingsDisc;
if isDisc == 0
    setupHypOrb;
    CreateFinalMappingsSphere;
else
    
end
