function outTesting = nnTestClassify(curExp, net)
inferedState = [];
loglik_all = [];
for i=1:length(curExp.testSet)
    outputs = mk_stochastic(net(curExp.testSet{i}.Data'))';
    [C,Index]=max(outputs);
    inferedState = [inferedState Index];
    loglik_all(i,:) = outputs;   
end

outTesting.inferedState = inferedState;
outTesting.loglik = loglik_all;

trueState = [];
for i=1:length(curExp.testSet)
    trueState = [trueState curExp.testSet{i}.State];
end

outTesting.trueState = trueState;
