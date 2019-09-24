%function starts filling in new working directory and extracts basic info
dataDir = dir(dataPath);
rawOFFPath = [workingPath '/RawOFF/'];
rawMATPath = [workingPath '/RawMAT/'];
touch(rawOFFPath);
touch(rawMATPath);
Names = {};
progressbar
for i = 3:length(dataDir)
    if strcmp(dataDir(i).name(end-2:end),'off') || strcmp(dataDir(i).name(end-2:end),'obj')
        Names = [Names dataDir(i).name(1:end-4)];
        switch dataDir(i).name(end-2:end)
            case 'off'
                G = Mesh('off',[dataPath dataDir(i).name]);
            case 'obj'
                G = Mesh('obj',[dataPath dataDir(i).name]);
        end
        G.Write([rawOFFPath dataDir(i).name(1:end-4) '.off'],'off');
        save([rawMATPath dataDir(i).name(1:end-4) '.mat'],'G');
    end
    progressbar((i-2)/(length(dataDir)-2))
end
save([workingPath 'Names.mat'],'Names');
load([basePath 'GPDMat_high.mat']);
GPDists = proc_d;
save([workingPath 'GPDists.mat'],'GPDists');