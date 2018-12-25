numLmks = 300;      %Number of landmarks, editable parameter
namesPath = [workingPath 'Names.mat'];
MATPath = [workingPath 'ProcessedMAT/'];
mappingPath = [workingPath 'MappingData/'];
load(namesPath);


meshList = cell(length(Names),1);
GPLmkList = cell(length(Names),1);
GPPtClouds = cell(length(Names),1);
for i = 1:length(Names)
    load([MATPath Names{i} '.mat']);
    meshList{i} = G;
    GPLmkList{i} = G.Aux.GPLmkInds;
    GPPtClouds{i} = G.V;
    %centralize point clouds
    GPPtClouds{i} = GPPtClouds{i} - repmat(mean(GPPtClouds{i}'),size(GPPtClouds{i},2),1)';
    GPPtClouds{i} = GPPtClouds{i}/norm(GPPtClouds{i});
end

procDists = zeros(length(Names),length(Names));
procMaps = cell(length(Names),length(Names));

for i = 1:length(Names)
    disp(['Computing Maps for ' Names{i}]);
    for j = 1:length(Names)
        if i ~=j
            %[P,procDists(i,j),~] = linassign(ones(size(GPPtClouds{i},2),size(GPPtClouds{i},2)),D);
            %Get map from permutation
            indMap = knnsearch(GPPtClouds{j}',...
                GPPtClouds{i}');
            procMaps{i,j} = indMap;
        end
    end
end


save([mappingPath 'procMaps.mat'],'procMaps');
            
            