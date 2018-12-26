%% The following parameters should definitely be tuned: basePath, dataPath,
%% workingPath, maxDistTol, minAlignMatches, startPathWt, maxNumMatches
%% All other parameters may be tuned but are up to discretion.

%% Data path
basePath = 'D://Work/ToothAndClaw/ToothAndClawData/AnkleWrist/FeetOFFOutput/';
dataPath = 'D://Work/ToothAndClaw/ToothAndClawData/AnkleWrist/FeetOFFOutput/aligned/OFF/';
workingPath = 'D://Dropbox/TeethData/AnkleWrist/Ankles/';

%% Feature information. Set ad-hoc based on discrete distance.
ConfMaxLocalWidth = 8;              %Nghbrd to detect local max of conformal factor
GaussMaxLocalWidth = 10;            %Nghbrd to detect local max of Gauss curvature
MeanMinLocalWidth = 8;              %Nghbrd to detect a local min of absolute mean curvature
DNEMaxLocalWidth = 8;               %Nghbrd to detect a local max of DNE field
SmoothCurvatureFields = 3;          %How much smoothing applied to curvature functions
NumDensityPts = 100;                %Number of FPS landmarks to store, will be deprecated
numGPLmks = 500;                    %number of GP Landmarks to store

%% Mapping parameters. Set and test based on visual output.
maxDistTol = 0.2;       %Parameter for projection + feature matching.
baseLmks = 150;         %Initial number of landmarks needed to find alignment correspondences
lmkIter = 50;           %How many landmarks to add per iteration if not 
                        %sufficient number of correspondences
maxNumLmks = 500;       %Do not make this above numGPLmks
minAlignMatches = 20;   %The minimum number of correspondence matches
maxNumMatches = 20;     %maximum number of landmarks chosen
pathWtTemp = 1;         %Parameter governing how much emphasis to give to low
                        %path weight. The larger, the more uniform the
                        %distribution
startPathWt = .984;     %Initial minimum path weight for acceptance
nbrSize = 1;            %Defines uncertainty neighborhood of matching. Should
                        %be small integer value, probably 1 but is tunable.
pathWtDecr = .001;      %Decrement of path weight if no valid paths at least
                        %startPathWt found.
percDecr = 0.05;        %Parameter governing how gradual landmark matching goes
                        %Must be above 0, the lower the better.
minPerc = 0.5;          %Minimum mass of propagated distribution required to 
                        %constitute a match. For theoretical reasons must
                        %be between 0.5 and 1.
