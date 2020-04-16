close all
load([workingPath 'Flags.mat']);
if ~exist([workingPath 'newMeshList.mat'])
    error('Reparametrized meshes do not exist, do not call until finished');
elseif ~Flags('isDisc')
    error('This method only works for surfaces with disk topology, aborting...')
end
    
load([workingPath 'newMeshList.mat']);
load([workingPath 'FinalDists.mat']);
frechMean = find(sum(dists.^2) == min(sum(dists.^2)));
frechMean = frechMean(1);
frechMesh = newMeshList{frechMean};

if ~isfield(frechMesh.Aux,'UniformizationV')
    disp('Template mesh does not have texture coordinates')
    disp('Computing texture coordinates and other features')
    options.isDisc = 1; options.numGPLmks=200;
    frechMesh.ComputeAuxiliaryInformation(options);
end
TextureCoords = frechMesh.Aux.UniformizationV(1:2,:)';

clear h
numRows = ceil(length(newMeshList)/visNumRow);
disp('Drawing texture maps...')
figure; hold on;
for i = 1:length(newMeshList)
    disp([num2str(i) '/' num2str(length(newMeshList))])
    h(i) = subplot(numRows,visNumRow,i);
    DrawTextureMap(TextureCoords,newMeshList{i}.V',uv_grid);
end
Link = linkprop(h, {'CameraUpVector', 'CameraPosition', 'CameraTarget', 'CameraViewAngle'});
setappdata(gcf, 'StoreTheLink', Link);
touch([workingPath 'MapFigures/']);
touch([workingPath 'MapFigures/FullMaps/']);
disp('Saving Texture Maps...')
savefig(h,[workingPath 'MapFigures/FullMaps/TextureMaps.fig']);
saveas(gcf,[workingPath 'MapFigures/FullMaps/TextureMaps.png']);
disp('Done!')