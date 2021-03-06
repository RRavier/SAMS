function Distributions = GetConnectedComponentsDistribution(G,f,niter_averaging)

if nargin <3
    options.niter_averaging = 1;
else
    options.niter_averaging = niter_averaging;
end

%Start by averaging the distribution

smooth_f = G.PerformMeshSmoothing(f,options);

%Make submesh for support vertices
suppV = find(smooth_f);
subFaces = G.F(:,sum(ismember(G.F,suppV))==3);
inds = reshape(subFaces,1,3*size(subFaces,2));
[sortInds,idx] = sort(unique(subFaces));
for i = 1:length(sortInds)
    subFaces(subFaces==sortInds(i))=i;
end
subMesh = Mesh('VF',G.V(:,suppV),subFaces);

A = subMesh.A;
subgraph = graph(subMesh.A);
connectedComp = conncomp(subgraph,'OutputForm','cell');
Distributions = cell(length(connectedComp),1);
for i = 1:length(Distributions)
    Distributions{i} = zeros(G.nV,1);
    Distributions{i}(sortInds(connectedComp{i})) = f(sortInds(connectedComp{i}));
end
end

