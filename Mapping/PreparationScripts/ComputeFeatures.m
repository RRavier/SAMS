%% Set and create paths
touch([workingPath 'ProcessedMAT/']);
output_path = [workingPath 'ProcessedMAT/'];
touch([workingPath 'MappingData/']);
load([workingPath 'Names.mat']);
load([workingPath 'Flags.mat']);
addpath(genpath('./Mapping/external/AQP_toolbox/'));
%% Get parameters into approrpriate form

options.isDisc = Flags('isDisc');
options.ConfMaxLocalWidth = ConfMaxLocalWidth;              
options.GaussMaxLocalWidth = GaussMaxLocalWidth;           
options.MeanMinLocalWidth = MeanMinLocalWidth;              
options.DNEMaxLocalWidth = DNEMaxLocalWidth;               
options.SmoothCurvatureFields = SmoothCurvatureFields;                   
options.numGPLmks = numGPLmks;                    
options.pointCloud = 0;

%% Get meshes and do initial, quick feature computations

disp('Loading Meshes...')
progressbar
badMeshes = {};
badInds = [];
for i = 1:length(Names)
    G = Mesh('off',[workingPath 'RawOFF/' Names{i} '.off']);       %load mesh
    [~,TriAreas] = G.ComputeSurfaceArea;
    while true
        delInds = [];
        if max(abs(imag(TriAreas))) > 0
            delInds = [delInds find(abs(imag(TriAreas))>0)];
        end
        if min(TriAreas)<nullFaceBound
            delInds = [delInds find(TriAreas < 1e-10)];
        end
        if isempty(delInds)
            break;
        else
            G.F(:,delInds) = [];
            G = Mesh('VF',G.V,G.F);
            delInds = find(~ismember(1:G.nV,reshape(G.F,1,3*G.nF)));
            G.DeleteVertex(delInds);
            [bd,~] = G.FindOrientedBoundaries;
            if min(size(bd)>1)
                badMeshes = [badMeshes Names{i}];
                badInds = [badInds i];
                break;
            end
            [~,TriAreas] = G.ComputeSurfaceArea;
        end
    end

    G.Write([workingPath 'RawOFF/' Names{i} '.off'],'off',options);
    save([workingPath 'RawMAT/' Names{i} '.mat'],'G');
    G.Nf = G.ComputeFaceNormals;
    G.Nv = G.F2V'*G.Nf';
    G.Nv = G.Nv'*diag(1./sqrt(sum((G.Nv').^2,1)));
    G.nF = size(G.F,2);
    G.nV = size(G.V,2);     %needed in case deletion after check
    progressbar(i/length(Names));
end
if ~isempty(badMeshes)
    disp('The following meshes have problems that need to be fixed before proceeding')
    for i = 1:length(badMeshes)
        disp(badMeshes{i});
    end
    error('Cannot complete, must fix listed meshes');
end

%% Do complex feature computations and save
disp('Computing surface features');
%progressbar
problemMeshes = zeros(length(Names),1);
badMeshList = {};
badMeshInds = [];

%% Loop over meshes to extract features
for i = 1:length(Names)%1:length(Names)
    G = Mesh('off',[workingPath 'RawOFF/' Names{i} '.off']);
    %progressbar(i/length(Names));
    try
        [G,Aux] =G.ComputeAuxiliaryInformation(options);
        G.Aux = Aux;
        G.Aux.Name = Names{i};
        save([output_path Names{i} '.mat'],'G');
    catch
        disp(['Error in mesh ' num2str(i)]);
        badMeshInds = [badMeshInds i];
        badMeshList = [badMeshList Names{i}];
    end
end

%% Repeat computations
%% Abort if errors exist
if length(badMeshList) > 0
    disp('ALERT: The following meshes require manual cleaning to continue')
    for i = 1:length(badMeshList)
        disp(badMeshList{i})
    end
    error('Terminating, listed surfaces must be cleaned')
end
%% Saving
