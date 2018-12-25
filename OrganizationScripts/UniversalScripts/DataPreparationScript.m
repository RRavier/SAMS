

disp('Setting Paths');
[basePath,dataPath,workingPath] = PathSetting('Ankles');
disp('Initializing Data Collection')
if exist([workingPath 'Names.mat'])
    disp('Data already exists in working folder');
else
    MoveDataToOutputFolder;
end
disp('Checking validity of Surfaces');
if exist([workingPath 'isDisc.mat'])
    load([workingPath 'isDisc.mat'])
    if isDisc == -1
        rslt = HomeomorphismCheck(workingPath);
    else
        disp('Already verified homeomorphisms');
    end
else
    rslt = HomeomorphismCheck(workingPath);
end

if rslt.isDisc == -1
    error('Script stopping, please fix problems with meshes and then try again.');
else
    isDisc = rslt.isDisc;
    save([workingPath 'isDisc.mat'],'isDisc');
end

disp('Preparing meshes');
switch isDisc
    case 0      %Nondisc, assuming spheres for now
        PrepareSpheres;
    case 1
        PrepareDiscs;
end

disp('Finished preparing meshes, you may begin mapping now');