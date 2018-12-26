touch([workingPath 'ProcessedMAT/']);
output_path = [workingPath 'ProcessedMAT/'];
touch([workingPath 'MappingData/']);
load([workingPath 'Names.mat']);
load([workingPath 'isDisc.mat']);
%% The below curvature options are ad hoc. Similar tuning must be done on any data

options.isDisc = isDisc;



%% Get meshes and do initial, quick feature computations
meshList = cell(1,length(Names));
auxList = cell(1,length(Names));

for i = 1:length(Names)
    load([workingPath 'RawMAT/' Names{i} '.mat']);       %load mesh
    G.Nf = G.ComputeFaceNormals;
    G.Nv = G.F2V'*G.Nf';
    G.Nv = G.Nv'*diag(1./sqrt(sum((G.Nv').^2,1)));
    G.NF = size(G.F,2);
    meshList{i} = G;
end


for i = 1:length(Names)
    disp(i)
    [meshList{i},auxList{i}] = meshList{i}.ComputeAuxiliaryInformation(options);
end

for i = 1:length(Names)
    G = meshList{i};
    meshList{i}.Aux = auxList{i};
    save([output_path Names{i} '.mat'],'G');
end