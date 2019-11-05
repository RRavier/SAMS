%% Load relevant details
load([workingPath 'Names.mat'])
meshList = cell(length(Names),1);
for i = 1:length(Names)
    load([workingPath 'ProcessedMAT/' Names{i} '.mat']);
    meshList{i} = G;
end

load([workingPath 'TextureCoordsSource.mat']);
load([workingPath 'TextureCoordsTarget.mat']

%% Create full soft maps matrix
softMapsMatrix = cell(length(meshList),length(meshList));
progressbar
for i = 1:length(meshList)
    G1 = meshList{i};
    for j = 1:length(meshList)  
        G2 = meshList{j};
        [~,~,AugKernel12,~] = MapSoftenKernel(TextureCoordsSource{i}...
            ,TextureCoordsTarget{j},G2.F,G1.V,G2.V,fiberEps);
        [~,~,AugKernel21,~] = MapSoftenKernel(TextureCoordsFinal{j}...
            ,TextureCoordsSource{i},G1.F,G2.V,G1.V,fiberEps);
        softMapsMatrix{i,j} = max(AugKernel12,AugKernel21');
        progressbar(((i-1)*length(meshList)+j)/(length(meshList)^2));
    end
end
save([workingPath 'softMapsMatrix.mat'],'softMapsMatrix');


