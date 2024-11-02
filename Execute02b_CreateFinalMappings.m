disp('Interpolating sparse correspondences...')
load([workingPath 'Flags.mat']);
if ~isKey(Flags,'isDisc')
    disp('Not all meshes have the same topology. Determining errors...')
    load([workingPath 'Names.mat']);
    meshList = cell(length(Names),1);
    for i = 1:length(Names)
        load([workingPath 'ProcessedMAT/' Names{i} '.mat']);
        meshList{i} = G;
    end
    sphereList = []; discList = []; otherList = [];
    for i = 1:length(meshList)
        bd = meshList{i}.FindOrientedBoundaries();
        if isempty(bd)
            sphereList = [sphereList i];
        elseif size(bd,1) == 1
            discList = [discList i];
        else
            otherList = [otherList i];
        end
    end
    
    disp(['There are ' num2str(length(sphereList)) ' sphere topology meshes.']);
    disp(['There are ' num2str(length(discList)) ' disc topology meshes.']);
    disp(['There are ' num2str(length(discList)) ' non simply connected meshes.']);
    
    if length(sphereList) <= 10 && length(sphereList) > 0
        disp('The sphere topology meshes are:');
        for j = 1:length(sphereList)
            disp(Names{sphereList(j)});
        end
    end
    if length(discList) <= 10 && length(discList) > 0
        disp('The disc topology meshes are:');
        for j = 1:length(discList)
            disp(Names{discList(j)});
        end
    end
    if length(otherList) <= 10 && length(otherList) > 0
        disp('The non simply connected meshes are:');
        for j = 1:length(otherList)
            disp(Names{otherList(j)});
        end
    end
    disp('Mappings can only be created by meshes of the same topology.')
    disp('Please run the pipeline with meshes of the same topology')
end
if Flags('isDisc') == 0
    SetupHypOrb;
    CreateFinalMappingsSphere;
else
    CreateFinalMappingsDisc2;
end

disp('Mappings computed. Please visualize with plotColorMap before continuing');