load([workingPath 'GPDists.mat']);
load([workingPath 'Names.mat']);
load([workingPath 'MappingData/MatchesPairs_Thresheld.mat']);

rmpath(genpath([SAMSPath 'Mapping/external']));
addpath(genpath([SAMSPath 'utils/']));
%% Make directories if needed
orbDataPath = [workingPath 'OrbifoldData/'];
options.pointCloud = 0;
touch(orbDataPath);
meshList = cell(length(Names),1);
for i = 1:length(Names)
    load([workingPath 'ProcessedMAT/' Names{i} '.mat']);
    meshList{i} = G;
end
[~, frechMean] = min(sum(GPDists.^2));

disp(['Names length: ' num2str(length(Names))])
disp(['frechMean: ' num2str(frechMean)])
disp(['GPDists size: ' mat2str(size(GPDists))])
disp(['matchesPairs length: ' num2str(length(matchesPairs))])
for i = 1:length(Names)
    fprintf('Processing %d / %d: %s\n', i, length(Names), Names{i});
    if i ~= frechMean
        % --- Build target directory ---
        dirString = fullfile(orbDataPath, [Names{i} '__To__' Names{frechMean}]);
        
        % --- Ensure directory exists ---
        [status, msg, msgID] = mkdir(dirString);
        if status
            fprintf('Directory exists or created: %s\n', dirString);
        else
            warning('Failed to create directory: %s\nReason: %s', dirString, msg);
        end
        
        % --- Diagnostic write test ---
        testFile = fullfile(dirString, 'write_test.txt');
        fidTest = fopen(testFile, 'w');
        if fidTest == -1
            warning('Cannot write in directory: %s', dirString);
        else
            fprintf(fidTest,'Test write successful\n');
            fclose(fidTest);
            delete(testFile); % clean up
            fprintf('Write test passed for directory: %s\n', dirString);
        end
        
        % --- Actual writing ---
        try
            % Write mesh files
            meshList{i}.Write(fullfile(dirString, [Names{i} '.off']),'off',options);
            meshList{frechMean}.Write(fullfile(dirString, [Names{frechMean} '.off']),'off',options);

            % Write matchesPairs text files
            fid = fopen(fullfile(dirString, [Names{i} '.txt']),'w');
            frechid = fopen(fullfile(dirString, [Names{frechMean} '.txt']),'w');
            
            if fid == -1 || frechid == -1
                warning('Failed to open output files in: %s', dirString);
            else
                curMatches = matchesPairs{i};
                for j = 1:size(curMatches,1)
                    fprintf(fid,'%d\n',curMatches(j,1));
                    fprintf(frechid,'%d\n',curMatches(j,2));
                end
                fclose(fid); fclose(frechid);
            end
        catch ME
            warning('Error writing files in %s: %s', dirString, ME.message);
        end
        
        % --- Optional: display path length ---
        fprintf('Full path length: %d\n', strlength(fullfile(dirString, [Names{i} '.txt'])));
    end
end
