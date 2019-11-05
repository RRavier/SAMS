initialize;
StatisticsSetup;
% CLUSTER_CSC - Carry out consistent spectral clustering analysis on cluster

touch([workingDir 'Hecate/']);
hecateDir = [workingDir 'Hecate/'];
CreateSoftMaps;
GetVertexOrganization;
BuildDiffusionMatrix
EigenDecomp;
SpectralClustering;

cfg.dirCollate = dirCollate;
cfg.colorSegments = colorSegments;
cfg.out = hecateDir;
segRes = SegResult(meshList, kIdx, vIdxCumSum, cfg);
segRes.calc_data();
segRes.export(cfg.param.alignTeeth);


