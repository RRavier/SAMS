function [basePath,dataPath,workingPath] = PathSetting(dataset)
%% Private method. Feel free to edit for convenience but not necessary and not called
%  You may edit the other methods but please be aware they are meant for 
%  private use.

basePath = 'D://Work/ToothAndClaw/ToothAndClawData/AnkleWrist/FeetOFFOutput/';
dataPath = 'D://Work/ToothAndClaw/ToothAndClawData/AnkleWrist/FeetOFFOutput/aligned/OFF/';
workingPath = 'D://Dropbox/TeethData/AnkleWrist/Ankles/';
if nargin > 0       %This conditional is private and intended for author but can be edited and used
    disp(['Setting paths for ' dataset ' Dataset.']);
    if ismac
        error('Private method called when Mac directory never set');
    end
    switch dataset
        case 'PNAS'
            if isunix     
            else
                dataPath = 'D://Dropbox/TeethData/PNAS/OFF/';
                workingPath = 'D://Dropbox/TeethData/AnkleWrist/Wrists/';
            end
        case 'Teilhardina'
            if isunix     
            else
                dataPath = 'D://Dropbox/TeethData/Teilhardina/clean_off/';
                workingPath = 'D://Dropbox/TeethData/Teil2/';
            end
        case 'Ankles'
            if isunix     
            else
                basePath = 'D://Work/ToothAndClaw/ToothAndClawData/AnkleWrist/FeetOFFOutput/';
                dataPath = 'D://Work/ToothAndClaw/ToothAndClawData/AnkleWrist/FeetOFFOutput/aligned/OFF/';
                workingPath = 'D://Dropbox/TeethData/AnkleWrist/Ankles/';
            end
        case 'Wrists'
            if isunix     
            else
                basePath = 'D://Work/ToothAndClaw/ToothAndClawData/AnkleWrist/HandOFFOutput/';
                dataPath = 'D://Work/ToothAndClaw/ToothAndClawData/AnkleWrist/HandOFFOutput/aligned/OFF/';
                workingPath = 'D://Dropbox/TeethData/AnkleWrist/Wrists/';
            end
        case 'HDM'
            if isunix
            else
                basePath = 'D://Dropbox/TeethData/HDM/';
            end
        case 'Prime'
        case 'Tali'
    end
end

touch(workingPath);   %subfunction that makes workingDir if not already created
end