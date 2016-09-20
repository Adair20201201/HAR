a = dlmread('result2.txt');
outputRF2{1}.testing.trueLabels=a(:,2);
outputRF2{1}.testing.inferedLabels=a(:,3);
res2 = calcExtendedResult(outputRF2);
res2.ConfMat