%function starts filling in new working directory and extracts basic info
dataDir = dir(dataPath);
rawOFFPath = [workingPath '/RawOFF/'];
rawMATPath = [workingPath '/RawMAT/'];
touch(rawOFFPath);
touch(rawMATPath);
Names = {}; options.pointCloud = 0;
progressbar
for i = 3:length(dataDir)
    if strcmp(dataDir(i).name(end-2:end),'off') ...
            || strcmp(dataDir(i).name(end-2:end),'obj') ...
            || strcmp(dataDir(i).name(end-2:end),'ply')
        Names = [Names dataDir(i).name(1:end-4)];
        switch dataDir(i).name(end-2:end)
            case 'off'
                G = Mesh('off',[dataPath dataDir(i).name]);
            case 'obj'
                G = Mesh('obj',[dataPath dataDir(i).name]);
            case 'ply'
                G = Mesh('ply',[dataPath dataDir(i).name]);
        end
        G.Write([rawOFFPath dataDir(i).name(1:end-4) '.off'],'off',options);
        save([rawMATPath dataDir(i).name(1:end-4) '.mat'],'G');
    end
    progressbar((i-2)/(length(dataDir)-2))
end
save([workingPath 'Names.mat'],'Names');
if isfile(distancePath)
    S = load(distancePath);
    distName = fieldnames(S);
    GPDists = getfield(S,distName{1});
    Flags('hasDists') = 1;
    save([workingPath 'GPDists.mat'],'GPDists');
    save([workingPath 'Flags.mat'],'Flags');
else
    Flags('hasDists') = 0;
end
save([workingPath 'Flags.mat'],'Flags');

