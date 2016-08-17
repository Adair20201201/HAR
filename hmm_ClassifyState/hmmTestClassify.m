function outTesting = hmmTestClassify(curExp, learnedParams)

%[inferedLabels, fwProbs] = hmmInferenceDaysSplit(curExp.modelInfo, learnedParams, curExp.testFeatMat);
% [fwbkProbs,pOfObservations] = hmmFwBkDaysSplit(curExp.modelInfo, learnedParams, curExp.testFeatMat);
action_mhmm = learnedParams;
inferedState = [];
loglik_all = [];
for i=1:length(curExp.testSet)
    loglik = [];
    for act=1:length(learnedParams)%
        tmp = mhmm_logprob(curExp.testSet{i}.Data, action_mhmm(act).prior, action_mhmm(act).transmat,...
            action_mhmm(act).mu,action_mhmm(act).Sigma,action_mhmm(act).mixmat);
        loglik = [loglik tmp];
    end
    
    [C,Index]=max(loglik);
    
    inferedState = [inferedState Index];
    loglik_all(i,:) = loglik;
    
end

outTesting.inferedState = inferedState;
outTesting.loglik = loglik_all;


trueState = [];
for i=1:length(curExp.testSet)
    trueState = [trueState curExp.testSet{i}.State];
end

outTesting.trueState = trueState;
 
%outTesting.fwProbs = fwProbs;

% outTesting.fwbkProbs = fwbkProbs;
% outTesting.pOfObservations = pOfObservations;
