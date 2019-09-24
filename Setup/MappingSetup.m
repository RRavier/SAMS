
%% Set input and output paths

% Path of aligned input data. Below structure assumes PuenteAlignment output format
basePath = 'D://Work/ToothAndClaw/ToothAndClawData/TimeSeriesTeeth/aligned_output/';
dataPath = [basePath 'aligned/'];

%% Set paths and organization of output

%Base path for everything in a project, may include multiple groups
MetaGroupBasePath = 'D://dummyRun/';

%The list of groups for project
MetaGroups = {'Default'};

%The path of the current group you are working on
workingPath = 'D://dummyRun/Default/';

%Path to previously computed distance matrix; if not specified or does not
%exist, will compute one at later stage but NOT RECOMMENDED
distancePath = [basePath 'GPDMat_high.mat'];
%Path of Excel file containing taxa information. Leave empty if none. 
%PLEASE FOLLOW PRESCRIBED FORMATTING OR YOU WILL HAVE TO MANUALLY EDIT CODE
infoPath = '';

%% Feature information. May need to tune.

%Force recomputation of features, default to 0 (false)
ForceFeatureRecomputation = 0;

%Amount of smoothing to apply to curvatures. Lower priority for tuning
SmoothCurvatureFields = 3;          

%Size of neighborhood required to declare local extrema of curvatures
%All neighborhoods set on discrete distance and may need to be tuned
%MUST BE INTEGER VALUED
ConfMaxLocalWidth = 8;              %Conformal factor maxima
GaussMaxLocalWidth = 10;            %Gauss curvature maxima
MeanMinLocalWidth = 8;              %Absolute mean curvature minima
DNEMaxLocalWidth = 8;               %DNE v1 maxima

%Number of subsamples to draw on each mesh for different subsampling types
%MUST BE POSITIVE INTEGER, should be 1-2 percent of number of mesh vertices
NumDensityPts = 100;                %FPS (Farthest-point sampling)
numGPLmks = 200;                    %Gaussian Process (GP)

%% Initial feature mapping parameters. Set and test based on visual output.

%Feature to use for mapping. Options are Conf = conformal factor,
%Gauss = Gaussian curvature, Mean = absolute mean curvature, DNE = DNE v2
featureMap = 'Conf';

%Error tolerance for feature matching. Must be nonnegative
%Smaller = more conservative
maxDistTol = 0.2;

%% Landmark parameters for propagation refinement. May require heavy tuning

%Force refinement even if already computed. Default to 0 (false)
ForceRefinement = 0;
%Initial number of GP landmarks used. Use more for more complex surfaces
baseLmks = 50;

%How many landmarks to add per iteration of refinement process
lmkIter = 40;

%Maximum number of GP landmarks to use. Do not make this above numGPLmks
maxNumLmks = 200;

%Minimum number of matches required to break refinment procedure
minAlignMatches = 15;   

%% Distribution parameters for propagation refinement. MAY REQUIRE HEAVY TUNING

%Nonnegative parameter governing uniformity of distribution of initial maps 
%Higher values = more uniformity
pathWtTemp = 1;

%Starting minimum path weight for acceptance, should not be greater than 1
startPathWt = .99;   

%Decrement of path weight if no valid paths at least startPathWt found.
pathWtDecr = .001;      

%% Accuracy threshold parameters for refinement procedure. TUNE LAST.
%Defines uncertainty neighborhood of matching. Must be integer.      
nbrSize = 1;
%Minimum mass of propagated distribution required to constitute a match.
%Must be between 0.5 and 1, though should almost never be 1
minPerc = 0.5;
%Parameter governing how gradual landmark matching goes
%Must be positive, smaller = more gradual
percDecr = 0.05;        


%% Parameters for final landmarking procedure
maxNumMatches = 10;     %Maximum number of landmarks used
                        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DO NOT EDIT BELOW
MappingSetupInternal;

