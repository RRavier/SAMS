initialize;
StatisticsSetup;
disp('Performing Global Analysis');
PerformGlobalAnalysis
TTestType = {'EqualCovariance','UnequalCovariance'};
PerformLocalAnalysis;
if runPermutations
    TTestType = {'EqualCovariance_Permutation','UnequalCovariance_Permutation'};
    PerformLocalAnalysis;
end