%% Start off by making directories for each group
clear k
metaDir = dir(MetaGroupBasePath);
SpecimenTypes = {};
if length(metaDir) == 3
    if exist([MetaGroupBasePath metaDir(3).name '/Groups.mat']) > 0
        SpecimenTypes = [SpecimenTypes metaDir(3).name];
        if ~exist('keys')
            load([MetaGroupBasePath metaDir(3).name '/Groups.mat']);
            keys = Groups.keys;
        end
    end
else
    for k = 3:length(metaDir)
        if isdir([MetaGroupBasePath metaDir(k).name])
            if exist([MetaGroupBasePath metaDir(k).name '/Groups.mat']) > 0
                SpecimenTypes = [SpecimenTypes metaDir(k).name];
                if ~exist('keys')
                    load([MetaGroupBasePath metaDir(k).name '/Groups.mat']);
                    keys = Groups.keys;
                end
            end


        end
    end
end
statPath = [MetaGroupBasePath 'Statistics/'];
interStatPath = [statPath 'InterGroup/'];
intraStatPath = [statPath 'IntraGroup/'];
touch(statPath); touch(interStatPath); touch(intraStatPath);

for k = 1:length(keys)
    touch([interStatPath keys{k} '/']);
end
touch([interStatPath 'Total/']);

%% Now do analysis
disp('Performing global analysis on MDS');
MDSGlobalAnalysis;
WeightedMeanMDSGlobalAnalysis;
disp('Performing global analysis on mean shapes');
SampleMeanGlobalAnalysis;
WeightedMeanShapeGlobalAnalysis;
disp('Performing global analysis on Frechet mean');
SampleFrechetMeanGlobalAnalysis;
WeightedFrechetMeanGlobalAnalysis

disp('Writing all MDS Diagrams');
for i = 1:length(SpecimenTypes)
    curDir = [MetaGroupBasePath SpecimenTypes{i} '/'];
    PlotMDS(curDir,0); PlotMDS(curDir,1);
end
close all
