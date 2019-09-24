initialize;
MappingSetup;
disp('Setting Paths');

disp('Initializing Data Collection')
if ~exist([workingPath 'Flags.mat'])
    Flags = containers.Map;
    save([workingPath 'Flags.mat'],'Flags');
else
    load([workingPath 'Flags.mat']);
end
if exist([workingPath 'Names.mat'])
    load ([workingPath 'Names.mat'])
    if length(Names) > 0
        disp('Data already exists in working folder');
    else
        MoveDataToOutputFolder;
    end
else
    MoveDataToOutputFolder;
end
disp('Checking validity of Surfaces');
if isfield(Flags,'AreHomeomorphic')
    if Flags('AreHomeomorphic') == 0
        rslt = HomeomorphismCheck(workingPath);
    else
        disp('Already verified homeomorphisms');
    end
else
    rslt = HomeomorphismCheck(workingPath);
end

if rslt.isDisc == -1
    Flags('AreHomeomorphic') = 0;
    error('Script stopping, please fix problems with meshes and then try again.');
else
    Flags('AreHomeomorphic') = 1;
    Flags('isDisc') = rslt.isDisc;
end

save([workingPath 'Flags.mat'],'Flags');

disp('Computing Necessary Mesh Features');

if ~isfield(Flags,'FeaturesComputed') || ForceFeatureRecomputation
    if isfield(Flags,'FeaturesComputed')
        disp('Features are already computed, you may safely abort');
    end
    ComputeFeatures;
end
Flags('FeaturesComputed') = 1;
save([workingPath 'Flags.mat'],'Flags');
disp('Finished preparing meshes, you may begin mapping now');