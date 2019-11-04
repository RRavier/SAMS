initialize;
StatisticsSetup;
disp('Performing Global Analysis');
PerformGlobalAnalysis
TTestType = {'EqualCovariance','UnequalCovariance'};
if runPermutations
    TTestType = [TTestType {'EqualCovariance_Permutation','UnequalCovariance_Permutation'}];
end
PerformLocalAnalysis;
PerformLocalAnalysisPatches;

