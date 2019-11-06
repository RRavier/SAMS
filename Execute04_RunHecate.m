initialize;
StatisticsSetup;
% CLUSTER_CSC - Carry out consistent spectral clustering analysis on cluster
load([workingPath 'Flags.mat']);
touch([workingPath 'Hecate/']);
hecateDir = [workingPath 'Hecate/'];

if Flags('isDisc') == 0
    CreateSoftMapsSphere;
    meshList = newMeshList;
    for i = 1:length(Names)
        meshList{i}.Aux.Name = Names{i};
    end
else
    CreateSoftMaps;
end
GetVertexOrganization;
BuildDiffusionMatrix;
EigenDecomp;
SpectralClustering;

cfg.dirCollate = dirCollate;
cfg.colorSegments = colorSegments;
cfg.out = hecateDir;
cfg.numMeshDisplay = numMeshDisplay;
segRes = SegResult(meshList, kIdx, vIdxCumSum);
segRes.calc_data();
segRes.export(cfg);


