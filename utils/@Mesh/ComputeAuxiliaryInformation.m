function [newG,Aux] = ComputeAuxiliaryInformation(G,options)
%Wrapper function to compute relevant quantitative auxilliary quantities. Needed in
%order to do in parallel fashion. This will set all auxiliary data except
%for the name.

%% Get aux field if already exists, should only be if observer landmarks were computed
if isfield(G,'Aux')
    Aux = G.Aux;
else
    Aux = {};
end

%centralize
[Aux.Area,Aux.Center] = G.Centralize('ScaleArea');

%uniformizae and compute conformal factor
switch options.isDisc
    case 1
        [Aux.UniformizationV,~,Aux.VertArea] = G.ComputeMidEdgeUniformization();
    case 0
        [~,TriAreas] = G.ComputeSurfaceArea;
        Aux.VertArea = (TriAreas'*G.F2V)/3;
        Aux.UniformizationV = spherical_conformal_map(G.V',G.F')';
end

Aux = G.ComputeCurvatureFeatures(Aux,options);
Aux.LB = G.ComputeCotanLaplacian;
G.Aux = Aux;


minds = [Aux.GaussMaxInds;Aux.GaussMinInds;Aux.ConfMaxInds];
minds = unique(minds);

numDensityPts = getoptions(options,'NumDensityPts',100);
[G.Aux.GPLmkInds,~] = G.GetGPLmk(options.numGPLmks);
G.Aux.DensityPnts = G.GeodesicFarthestPointSampling(numDensityPts,minds);
newG = G;
Aux = G.Aux;
end