[~,basePath,workingPath] = PathSetting('Wrists');
load([workingPath 'GenusList.mat']);
load([workingPath 'MDSEmbedding.mat']);
%Y = mdscale(distMatrix([1:20 22:49],[1:20 22:49]),2);
unGenus = unique(GenusList);
colors = colormap(colorcube(4+length(unGenus)));

figure; hold on;
for i = 1:length(unGenus)
    if strcmp(unGenus{i},'Hylobates')
        continue;
    end
    inds = find(strcmp(GenusList,unGenus{i}));
    scatter3(Y(inds,1),Y(inds,2),Y(inds,3),100,colors(i,:),'filled');
    
end

for i = 1:length(unGenus)
    if strcmp(unGenus{i},'Hylobates')
        continue;
    end
    inds = find(strcmp(GenusList,unGenus{i}));
    if(length(inds)>2)
        [coeffs,~,latent] = pca(Y(inds,:));
        if(length(latent) <3)
            coeffs = [coeffs, cross(coeffs(:,1),coeffs(:,2))];
            [x,y,z] = ellipsoid(0,0,0,sqrt(latent(1)),sqrt(latent(2)),eps);
        else
            [x,y,z] = ellipsoid(0,0,0,sqrt(latent(1)),sqrt(latent(2)),sqrt(latent(3)));
        end
        newX = reshape(x,1,21^2);
        newY = reshape(y,1,21^2);
        newZ = reshape(z,1,21^2);
        coords = [newX;newY;newZ];
        for j = 1:size(coords,2)
            coords(:,j) = coeffs*coords(:,j);
        end
        center = mean(Y(inds,:));
        coords = coords+repmat(center',1,21^2);
        x = reshape(coords(1,:),21,21);
        y = reshape(coords(2,:),21,21);
        z = reshape(coords(3,:),21,21);
        surf(x,y,z,'EdgeColor','none','FaceColor',colors(i,:),'FaceAlpha',.5);
    else
        plot3(Y(inds,1),Y(inds,2),Y(inds,3),'Color',colors(i,:));
    end
end
legend(unGenus([1:7 9:end]));
