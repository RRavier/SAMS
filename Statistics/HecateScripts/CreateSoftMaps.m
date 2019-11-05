%% Load relevant details
load([workingPath 'Names.mat'])
meshList = cell(length(Names),1);
for i = 1:length(Names)
    load([workingPath 'ProcessedMAT/' Names{i} '.mat']);
    meshList{i} = G;
end

load([workingPath 'TextureCoordsSource.mat']);
load([workingPath 'TextureCoordsTarget.mat']);

%% Create full soft maps matrix
softMapsMatrix = cell(length(meshList),length(meshList));
progressbar
disp('Creating soft maps matrix');
AugKernel12 = cell(length(meshList),1);
AugKernel21 = AugKernel12;
for i = 1:length(meshList)
    G1 = meshList{i};
    parfor j = 1:length(meshList)  
        [~,~,AugKernel12{j},~] = MapSoftenKernel(TextureCoordsSource{i,j}...
            ,TextureCoordsTarget{i,j},meshList{j}.F,G1.V,meshList{j}.V,fiberEps);
        [~,~,AugKernel21{j},~] = MapSoftenKernel(TextureCoordsTarget{i,j}...
            ,TextureCoordsSource{i,j},G1.F,meshList{j}.V,G1.V,fiberEps);
        softMapsMatrix{i,j} = max(AugKernel12{j},AugKernel21{j}');
        
    end
    progressbar(i/length(meshList));
end
save([workingPath 'softMapsMatrix.mat'],'softMapsMatrix');


