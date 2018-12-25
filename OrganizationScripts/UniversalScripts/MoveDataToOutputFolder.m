%function starts filling in new working directory and extracts basic info
dataDir = dir(dataPath);
rawOFFPath = [workingPath '/RawOFF/'];
rawMATPath = [workingPath '/RawMAT/'];
touch(rawOFFPath);
touch(rawMATPath);
Names = {};
for i = 3:length(dataDir)
    if strcmp(dataDir(i).name(end-2:end),'off')
        Names = [Names dataDir(i).name(1:end-4)];
        G = Mesh('off',[dataPath dataDir(i).name]);
        G.Write([rawOFFPath dataDir(i).name(1:end-4) '.off'],'off');
        save([rawMATPath dataDir(i).name(1:end-4) '.mat'],'G');
    end
end
save([workingPath 'Names.mat'],'Names');
load([basePath 'GPDMat_high.mat']);
GPDists = proc_d;
save([workingPath 'GPDists.mat'],'GPDists');