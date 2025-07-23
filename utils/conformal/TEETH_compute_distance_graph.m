function [D] = TEETH_compute_distance_graph(A,tind)
%calculate shortest path from point indices tind in a graph described by
%adj list A

n=size(A,2);
m=length(tind);

D = zeros(m,n);
graphA = graph(sparse(A));
disp('using Dijkstra to determine image of boundary...')
progressbar
for k=1:m
    
    dists=distances(graphA,tind(k));
    D(k,:) = dists; 
    progressbar(k/m);
end
close all