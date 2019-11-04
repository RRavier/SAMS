%% Set and create paths
touch([workingPath 'ProcessedMAT/']);
output_path = [workingPath 'ProcessedMAT/'];
touch([workingPath 'MappingData/']);
load([workingPath 'Names.mat']);
load([workingPath 'Flags.mat']);
%% Get parameters into approrpriate form

options.isDisc = Flags('isDisc');
options.ConfMaxLocalWidth = ConfMaxLocalWidth;              
options.GaussMaxLocalWidth = GaussMaxLocalWidth;           
options.MeanMinLocalWidth = MeanMinLocalWidth;              
options.DNEMaxLocalWidth = DNEMaxLocalWidth;               
options.SmoothCurvatureFields = SmoothCurvatureFields;       
options.NumDensityPts = NumDensityPts;                
options.numGPLmks = numGPLmks;                    

%% Get meshes and do initial, quick feature computations
meshList = cell(1,length(Names));
auxList = cell(1,length(Names));

for i = 1:length(Names)
    load([workingPath 'RawMAT/' Names{i} '.mat']);       %load mesh
    G.Nf = G.ComputeFaceNormals;
    G.Nv = G.F2V'*G.Nf';
    G.Nv = G.Nv'*diag(1./sqrt(sum((G.Nv').^2,1)));
    G.nF = size(G.F,2);
    G.nV = size(G.V,2);     %needed in case deletion after check
    meshList{i} = G;
end

%% Do complex feature computations and save
disp('Computing surface features');
%progressbar
parfor i = 1:length(Names)
    disp(i)
    %progressbar(i/length(Names));
    [meshList{i},auxList{i}] = meshList{i}.ComputeAuxiliaryInformation(options);
end
close all
disp('Saving')
for i = 1:length(Names)
    G = meshList{i};
    meshList{i}.Aux = auxList{i};
    meshList{i}.Aux.Name = Names{i};
    save([output_path Names{i} '.mat'],'G');
end