

%% Set paths and organization of output, probably same as in MappingSetup
%Base path for everything in a project, may include multiple groups
MetaGroupBasePath = 'D://dummyRun/';

%The list of groups for project
MetaGroups = {'Default'};

%The path of the current group you are working on
workingPath = 'D://dummyRun/Default/';

%Path of Excel file containing taxa information. Leave empty if none. 
%PLEASE FOLLOW PRESCRIBED FORMATTING OR YOU WILL HAVE TO MANUALLY EDIT CODE
infoPath = '';

                        
%% Local Statistical Analysis Parameters

%Array of p-values to plot significance maps for
pValues = [0.01];

%View displacement field between mean samples, set 1 (true) for yes
viewDisplace = 1;

%% Permutation Test Parameters
% NOTE: EVERY PERMUTATION REQUIRES THOUSANDS OF INDIVIDUAL TESTS AND CAN
% GET QUITE COSTLY TO RUN WITHOUT APPROPRIATE METHODS

%Whether to run permutation tests, should set to 0 (false) unless necessary
%as computations can be quite large
runPermutations = 0;

%Number of permutations to run; choose based on desired guidelines for
%accuracy of p-value
numSamples = 20000;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DO NOT EDIT BELOW
StatisticsSetupInternal;


%% Global Statistical Analysis Parameters
Category = 'Default'; %Default = no distinction, or input invidual taxon from taxon file
