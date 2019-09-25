try
    load([workingPath 'MappingData/MatchesPairs_Thresheld.mat']);
catch
    error('Please compute landmark correspondences before running this method');
end
disp('Visualizing all distilled correspondences');
disp('Press any key to switch pairs of meshes');
for i = 1:length(Names)
    if i ~= frechMean
        figure
        clear h
        disp(i)
        h(1) = subplot(1,2,1);
        meshList{i}.draw; hold on;
        curV = meshList{i}.V;
        curCube = colorcube(size(matchesPairs{i},1));
        scatter3(curV(1,matchesPairs{i}(:,1)),curV(2,matchesPairs{i}(:,1)),curV(3,matchesPairs{i}(:,1)),100,curCube,'filled');

        h(2) = subplot(1,2,2);
        meshList{frechMean}.draw; hold on;
        curV = meshList{frechMean}.V;
        curCube = colorcube(size(matchesPairs{i},1));
        scatter3(curV(1,matchesPairs{i}(:,2)),curV(2,matchesPairs{i}(:,2)),curV(3,matchesPairs{i}(:,2)),100,curCube,'filled');
        Link = linkprop(h, {'CameraUpVector', 'CameraPosition', 'CameraTarget', 'CameraViewAngle'});
        setappdata(gcf, 'StoreTheLink', Link);
        pause()
        close all
    end
end