function [D] = TEETH_compute_distance_graph(A,tind)
%calculate shortest path from point indices tind in a graph described by
%adj list A

n=size(A,2);
m=length(tind);

D = zeros(m,n);
curGraph = graph(sparse(A));
disp('using Dijkstra to determine image of boundary...')
for k=1:m
    progressbar(k,m,40);
    dists=distances(curGraph,tind(k));
    D(k,:) = dists;    
end