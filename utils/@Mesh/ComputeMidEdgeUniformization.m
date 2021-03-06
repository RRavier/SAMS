function [uniV,uniF,vertArea] = ComputeMidEdgeUniformization(G)
%COMPUTEMIDEDGEUNIFORMIZATION Summary of this function goes here
%   Detailed explanation goes here


% SmoothCurvatureFields = getoptions(options,'SmoothCurvatureFields',10);
% DensityLocalWidth = getoptions(options,'DensityLocalWidth',5);
% ExcludeBoundary = getoptions(options,'ExcludeBoundary',1);

[~,TriAreas] = G.ComputeSurfaceArea;
G.Aux.VertArea = (TriAreas'*G.F2V)/3;
vertArea = G.Aux.VertArea;
%%% compute mid-edge mesh
[mV,mF,M,E2Vmap] = G.ComputeMidEdge;

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% 1) decide where to cut the surface (for flattening/uniformization)
disp('Find a face to cut the surface for uniformization...');
v_max_V = CORR_spread_points_euclidean(G.V',[],200);

GeoField = pdist2(real(G.V(:,v_max_V)'),real(G.V'));

medianGeoField = mean(GeoField,2);
[~, minplc] = min(medianGeoField);
cut_vertex = v_max_V(minplc);
cut_face = find(G.F2V(:,cut_vertex),1);
disp('Found.');
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% 2) flatten the mesh conformally 
disp('Flattening the mid-edge mesh...')
unmV = CORR_map_mesh_to_plane_nonconforming(G.V',G.F',mF',cut_face,M,E2Vmap,G.nE,0);

unmF = mF';
unmF(cut_face,:) = []; %% it is the same face number as the original mesh

center_ind = cut_vertex;
tind = find(G.F2V(:,center_ind),1);%v_max_V1(kk);
center_ind = mF(1,tind);
disp('Flattened.');
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% 3) map domain to disk (add the infinity point back as sample point)
% transfer the indices of center point to the mid-edge
unmV = CORR_transform_to_disk_new_with_dijkstra(unmV,mF,E2Vmap,center_ind);
unmF = mF';
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% 4) map the original mesh to the disk using the mid-edge structure
disp('Flattening the ORIGINAL mesh using the mid-edge flattening...')
uniV = CORR_flatten_mesh_by_COT_using_midedge(G.V',G.F',M,mV,unmF,unmV,cut_face)';
uniV = [uniV;zeros(1,size(uniV,2))];
uniF = G.F;

end

