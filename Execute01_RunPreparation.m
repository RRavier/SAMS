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
        disp('Data already exists in working folder, will only reprocess if forced');
    else
        MoveDataToOutputFolder;
    end
else
    MoveDataToOutputFolder;
end
disp('Checking validity of Surfaces');
if exist([workingPath 'Flags.mat'])
    load([workingPath 'Flags.mat']);
    if isKey(Flags,'AreHomeomorphic')
        if Flags('AreHomeomorphic') == 0
            rslt = HomeomorphismCheck(workingPath);
            if rslt.isDisc == -1
                Flags('AreHomeomorphic') = 0;
                save([workingPath 'Flags.mat'],'Flags');
                error('Script stopping, please fix problems with meshes and then try again.');
            else
                Flags('AreHomeomorphic') = 1;
                save([workingPath 'Flags.mat'],'Flags');
                Flags('isDisc') = rslt.isDisc;
            end
        else
            disp('Already verified homeomorphisms');
        end
    else
        rslt = HomeomorphismCheck(workingPath);
        if rslt.isDisc == -1
            Flags('AreHomeomorphic') = 0;
            save([workingPath 'Flags.mat'],'Flags');
            error('Script stopping, please fix problems with meshes and then try again.');
        else
            Flags('AreHomeomorphic') = 1;
            Flags('isDisc') = rslt.isDisc;
            save([workingPath 'Flags.mat'],'Flags');
        end
    end
else
    rslt = HomeomorphismCheck(workingPath);
    if rslt.isDisc == -1
        Flags('AreHomeomorphic') = 0;
        save([workingPath 'Flags.mat'],'Flags');
        error('Script stopping, please fix problems with meshes and then try again.');
    else
        Flags('AreHomeomorphic') = 1;
        Flags('isDisc') = rslt.isDisc;
        save([workingPath 'Flags.mat'],'Flags');
    end
end


disp('Computing Necessary Mesh Features');

if ~isKey(Flags,'FeaturesComputed') || ForceFeatureRecomputation
    if isKey(Flags,'FeaturesComputed')
        disp('Features are already computed, you may safely abort');
    end
    ComputeFeatures;
end
Flags('FeaturesComputed') = 1;
save([workingPath 'Flags.mat'],'Flags');
disp('Finished preparing meshes, you may begin mapping now');