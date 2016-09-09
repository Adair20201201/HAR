function output = rfTrainSplit(curExp)

TrainingSet = curExp.trainSet;
nTrees = curExp.nTrees;

classLabels = [];
for i = 1:length(TrainingSet)
    classLabels = [classLabels; TrainingSet{i}.Label];
end

features = [];
for i = 1:length(TrainingSet)
    % Features
    tmp = [TrainingSet{i}.PF(1) TrainingSet{i}.PF(2) TrainingSet{i}.Speed];    
    features = [features;tmp];    
end

% Train the TreeBagger (Decision Forest).
B = TreeBagger(nTrees,features,classLabels, 'Method', 'classification');

%%%%%%%%%  Activity Recognition  %%%%
for i = 1:length(TrainingSet)
    
 
end



if isfield(curExp,'try_HMM')
    output2 = hmmTrainSplit2(curExp);
end


output = B;