
%% Set input and output paths

% Path of aligned input data. Below structure assumes PuenteAlignment output format
dataPath = 'D:\Work\ToothAndClaw\ToothAndClawData\KMeansSampleTeeth\aligned_output\aligned\';
distancePath = 'D:\Work\ToothAndClaw\ToothAndClawData\KMeansSampleTalus\aligned_output\GPDMat_High.mat';

%Base path for everything in a project, may include multiple groups
projectDir = 'D://Dropbox/SAMSResults/KMeansSampleTeeth/';

%The path of the current group you are working on
specimenGroup = 'Default';

%% Feature information. May need to tune.

%Force recomputation of features, default to 0 (false)
ForceFeatureRecomputation = 1;
%Number of Gaussian Process landmarks to draw; these are candidate
%pseudolandmarks. Choose based on collection, about 4-5 percent of number
%of vertices sufficient
numGPLmks = 200;    

%% Pseudolandmark matching parameters. Set and test based on visual output.

%Geometric features used to extract initial matches.
%Options are Conf = conformal factor, Gauss = Gaussian curvature, 
%Mean = absolute mean curvature, DNE = DNE.
%Gauss recommended to start
featureMap = 'Gauss';

ForcePutativeMatching = 0;    %Force recomputation of putative matches
maxDepth = 3;           %Maximum number of links in path, keep between 3-5
maxNbrSize = 3;         %Amount of uncertainty tolerated in pseudolandmark matching
                        %Should be an integer at least 1


%% Parameters for final landmarking procedure
maxNumMatches = 10;     %Maximum number of landmarks matches used
                        %Set based on intuition for number of Type II/III
                        %landmarks usually required for analysis
minMatchDist = 0.1;     %Minimum distance needed between any landmarks to establish matching
                        %Landmarks not added if below this. Set negative if
                        %no error required.

%% Visualization Parameters
visNumRow = 8;          %When visualizing landmark correspondences,
                        %the number of surfaces to view at once.
%% Parameters for spherical Hecate only
numGPLmksHecate = 200;
featureMapHecate = 'Gauss';
numLmksHecate = 15;
hecateFeatureInds = 10;

%% The following parameters are less likely to need to change

%Feature computation parameters, MUST BE INTEGER VALUED
%Amount of smoothing to apply to curvatures. Lower priority for tuning
SmoothCurvatureFields = 3;          %Amount of smoothing applied to curvatures          
ConfMaxLocalWidth = 8;              %Conformal factor maxima radius
GaussMaxLocalWidth = 10;            %Gauss curvature maxima radius
MeanMinLocalWidth = 8;              %Absolute mean curvature minima radius
DNEMaxLocalWidth = 8;               %DNE v1 maxima radius

%Putative Matching Parameters
minPerc = 0.5;          %Minimum relative likelihood needed to establish match.
                        %Set between 0.5 and 1
percDecr = 0.05;        %Decrement parameter for lowering required relative likelihood
                        %Should be positive, at most minPerc. Smalelr = more
                        %gradual decrement
pathWtDecr = .995;      %Decrement minimum weight of path considered
                        %Set between 0 and 1, numbers closer to one result
                        %in slower, higher precision computation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DO NOT EDIT BELOW
MappingSetupInternal;

