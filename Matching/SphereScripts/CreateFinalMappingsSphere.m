rmpath([codePath '/utils/']);
addpath(genpath([codePath '/external/hyperbolic_orbifolds/']));



NamesPath = [workingPath 'Names.mat'];
load(NamesPath);
load([workingPath 'GPDists.mat']);
frechMean = find(min(sum(GPDists.^2))==sum(GPDists.^2));
flatteners = {};
flag = 0;

DataDir = [workingPath 'OrbifoldData/'];
%mapList = cell(24,1);
for i = 1:length(Names)
    if i ~= frechMean
        curDir = [DataDir Names{i} '__To__' Names{frechMean} '/'];
        flatteners = {};
        flag = 0;
        [V,T]=read_off([curDir Names{frechMean} '.off']);
        inds=load([curDir Names{frechMean} '.txt']);
        flattener1=Flattener(V,T,inds);
        flattener1.orderTS();
        leadFlattener=flattener1;
        flattener1.flatten_orbifold();
        %fix numerical errors if exist
        flattener1.fixFlipsNew();
            %add to the cell array of flatteners
        flatteners{end+1}=flattener1;

        [V,T]=read_off([curDir Names{i} '.off']);
        inds=load([curDir Names{i} '.txt']);
        flattener1=Flattener(V,T,inds);
        flattener1.uncut_cone_inds=flattener1.uncut_cone_inds(leadFlattener.reorder_cones);
        flattener1.flatten_orbifold();
        %fix numerical errors if exist
        flattener1.fixFlipsNew();
            %add to the cell array of flatteners
        flatteners{end+1}=flattener1;
        map=UncutSurfMap(flatteners);
        map.compute(1,2);
        map.compute(2,1);
        mapList{i} = map;
    end
end
barCoordsList = cell(length(Names),1);
for i = 1:length(Names)
    if i ~=frechMean
        barCoordsList{i} = mapList{i}.barCoords{2,1};
    end
end
addpath(genpath([codePath '/utils/']));
rmpath([codePath '/external/hyperbolic_orbifolds/']);
meshList = cell(length(Names),1);
for i = 1:length(Names)
    load([workingPath 'ProcessedMAT/' Names{i} '.mat']);
    meshList{i} = G;
end

curMeshes = meshList;
newMeshList = cell(length(Names),1);
for i = 1:length(Names)
    if i ~=frechMean
        curMeshVerts = curMeshes{i}.V';
        newMeshVerts = barCoordsList{i}*curMeshVerts;
        newMeshList{i} = Mesh('VF',newMeshVerts',meshList{frechMean}.F);
    else
        newMeshList{i} = meshList{i};
    end
end
for i = 1:length(newMeshList)
    newMeshList{i}.V = newMeshList{i}.V-mean(newMeshList{i}.V')';
    newMeshList{i}.V = newMeshList{i}.V/norm(newMeshList{i}.V,'fro');
end
save('newMeshList.mat','newMeshList');
%save('barCoordsList.mat','barCoordsList');
%save('mapList.mat','mapList');
dists = zeros(length(Names),length(Names));


for i = 1:length(Names)
    for j = 1:length(Names)
        dists(i,j) = norm(newMeshList{i}.V - newMeshList{j}.V,'fro');
    end
end
[Y,~] = mdscale(dists,3);
save('FinalDists.mat','dists'); save('MDSEmbedding.mat','Y');
        