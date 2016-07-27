function outTesting = hmmTestSplit(curExp, learnedParams)

%[inferedLabels, fwProbs] = hmmInferenceDaysSplit(curExp.modelInfo, learnedParams, curExp.testFeatMat);
% [fwbkProbs,pOfObservations] = hmmFwBkDaysSplit(curExp.modelInfo, learnedParams, curExp.testFeatMat);
action_mhmm = learnedParams;
inferedLabels = [];
for i=1:length(curExp.testSet)
    loglik = [];
    for act=1:length(learnedParams)%
        tmp = mhmm_logprob(curExp.testSet{i}.Data, action_mhmm(act).prior, action_mhmm(act).transmat,...
            action_mhmm(act).mu,action_mhmm(act).Sigma,action_mhmm(act).mixmat);
        loglik = [loglik tmp];
    end
    
    [C,Index]=max(loglik);
    
    inferedLabels = [inferedLabels Index];
    
end

outTesting.inferedLabels = inferedLabels;

trueLabels = [];
for i=1:length(curExp.testSet)
    trueLabels = [trueLabels curExp.testSet{i}.Label];
end

outTesting.trueLabels = trueLabels;
 
%outTesting.fwProbs = fwProbs;

% outTesting.fwbkProbs = fwbkProbs;
% outTesting.pOfObservations = pOfObservations;
