function outTesting = rfTrainSplit(curExp, learnedParams)
% outTesting.inferedLabels: Labels inferred by the algorithm
% outTesting.trueLabels: True Labels of the Samples

B = learnedParams;

TestingSet = curExp.testSet;

inferedLabels = [];
for i = 1:length(curExp.testSet)
    tmp = [TestingSet{i}.PF(1) TestingSet{i}.PF(2)  TestingSet{i}.Speed];  
    predictedClass = str2double(B.predict(tmp));
    inferedLabels = [inferedLabels predictedClass];
end

%%%%% Fix Format Output  %%%%%%
outTesting.inferedLabels = inferedLabels;

trueLabels = [];
for i=1:length(curExp.testSet)
    trueLabels = [trueLabels curExp.testSet{i}.Label];
end

outTesting.trueLabels = trueLabels;