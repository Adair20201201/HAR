%% 
function [outTesting] = nbTestSplit(curExp, learnedParams)
testSet = curExp.testSet;
for i = 1:length(testSet)
    test_data(i,:) = testSet{1,i}.Data;
    trueLabels(i,1) = testSet{1,i}.Label;
end

%inferedLabels = predict(learnedParams, test_data);
[post,inferedLabels] = posterior(learnedParams,test_data);

% for i = 1:size(cpre,1)
%     colu = find(cpre(i,:) == 1);
%     inferedLabels(i) = colu;
% end

outTesting.inferedLabels = inferedLabels';
outTesting.loglik = post;
outTesting.trueLabels = trueLabels';
