function outTesting = svmTestClassify(curExp, svmStruct)

trueState = [];
for i=1:length(curExp.testSet)
    trueState = [trueState curExp.testSet{i}.State];
end
outTesting.trueState = trueState;
%State = unique(tmpState);

inferedState = [];
%prob_estimates = [];
for i=1:length(curExp.testSet)
    inferedState(i,1) = svmclassify(svmStruct,curExp.testSet{i}.Data);
    %[inferedState(i,1), accuracy, prob_estimates] = svmpredict(State(randi(1,[1,size(State,2)])), curExp.testSet{i}.Data, svmStruct,...
    %    '-b', 1);
    %  [predicted_label, accuracy, decision_values/prob_estimates] = svmpredict(testing_label_vector, testing_instance_matrix, model [, 'libsvm_options']);
    % testing_label_vector --> An m by 1 vector of prediction labels. If labels of test data are unknown, simply use any random values. (type must be double)
%     prob_estimates(i,inferedState(i,1)) = prob_estimates;
%     [~, index]= setdiff(State,inferedState(i,1));
%     prob_estimates(i,State(index)) = 1 - prob_estimates;
    
end

outTesting.inferedState = inferedState';
%outTesting.loglik = prob_estimates;