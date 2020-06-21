rmpath(genpath([SAMSPath '/utils/']));
addpath(genpath([SAMSPath 'Mapping/external/']));



NamesPath = [workingPath 'Names.mat'];
load(NamesPath);
load([workingPath 'GPDists.mat']);
frechMean = find(min(sum(GPDists.^2))==sum(GPDists.^2));
flatteners = {};
flag = 0;

DataDir = [workingPath 'OrbifoldData/'];
badMeshList = [];
badMeshV = {};
badMeshF = {};
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
        try
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
        catch
            flattener1.cut()
            badMeshList = [badMeshList i];
            badMeshV = [badMeshV flattener1.M_cut.V];
            if isfield(flattener1.M_cut,'F')
                badMeshF = [badMeshF flattener1.M_cut.F];
            else
                badMeshF = [badMeshF flattener1.M_cut.T];
            end
        end
    end
end
if length(badMeshList) > 0
    rmpath(genpath([SAMSPath 'Mapping/external/']));
    addpath(genpath([SAMSPath 'utils/']));
    badOFFPath = [workingPath 'badMeshOFFs/'];
    touch(badOFFPath);
    options.pointCloud = 0;
    for j = 1:length(badMeshList)
        curMesh = Mesh('VF',badMeshV{j}',badMeshF{j}');
        curMesh.Write([badOFFPath Names{badMeshList(j)} '.off'],'off',options);
    end
    disp('ALERT: Some of the meshes were not correctly cut. Please see the badMeshOFFs folder.')
    disp('Use the output to edit the corresponding meshes in the RawOFF folder, and rerun from Execute01');
    save([workingPath 'badCutMeshes.mat'],'badMeshList');
    save([workingPath 'curMapList.mat'],'mapList','-v7.3');
    error('Cannot continue mapping progress, algorithm failure')
end
        
barCoordsList = cell(length(Names),1);
barCoordsListRev = cell(length(Names),1);
for i = 1:length(Names)
    if i ~=frechMean
        barCoordsList{i} = mapList{i}.barCoords{2,1};
        barCoordsListRev{i} = mapList{i}.barCoords{1,2};
    end
end
save([workingPath 'barCoordsList.mat'],'barCoordsList');
save([workingPath 'barCoordsListRev.mat'],'barCoordsListRev');
addpath(genpath([SAMSPath '/utils/']));
rmpath(genpath([SAMSPath 'Matching/external/']));
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
save([workingPath 'newMeshList.mat'],'newMeshList');
%save('barCoordsList.mat','barCoordsList');
%save('mapList.mat','mapList');
dists = zeros(length(Names),length(Names));


for i = 1:length(Names)
    for j = 1:length(Names)
        dists(i,j) = norm(newMeshList{i}.V - newMeshList{j}.V,'fro');
    end
end
[Y,~] = mdscale(dists,3);
save([workingPath 'FinalDists.mat'],'dists'); save([workingPath 'MDSEmbedding.mat'],'Y');

disp('Finished mapping surfaces');
        