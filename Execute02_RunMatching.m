initialize;
MappingSetup;
load([workingPath 'Flags.mat'])
ExtractInitialMappings;
ComputeFeatureMatching;
Flows = ComputeDirectedFlows(GPDists);
save([workingPath 'Flows.mat'],'Flows');
MatchesPairsWrapper;

disp('If correspondences are not good, abort and tune parameters via Ctrl+C.')
pause(20);
if Flags('isDisc') == 0
    SetupHypOrb;
    CreateFinalMappingsSphere;
else
    CreateFinalMappingsDisc;
end
%Plotting vertex correspondences for reparametrized meshes
plotColorMap;
