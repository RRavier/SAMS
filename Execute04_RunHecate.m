initialize;
StatisticsSetup;
% CLUSTER_CSC - Carry out consistent spectral clustering analysis on cluster

touch([workingPath 'Hecate/']);
hecateDir = [workingPath 'Hecate/'];
CreateSoftMaps;
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


