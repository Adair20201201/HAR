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
B1 = TreeBagger(nTrees,features,classLabels, 'Method', 'classification');

%%%%%%%%%  Activity Recognition  %%%%

predictedClass = [];
for i = 1:length(TrainingSet)
    tmp = [TrainingSet{i}.PF(1) TrainingSet{i}.PF(2)  TrainingSet{i}.Speed];  
    predictedClass = [predictedClass;str2double(B1.predict(tmp))];
end

% for CRF++
%save Selfpredicted predictedClass

seg = [];
for sam_idx = 2:length(TrainingSet)
    if predictedClass(sam_idx) ~= predictedClass(sam_idx-1) || ...
            sam_idx == length(TrainingSet)
        
        tmp_idx = sam_idx;
        
        if sam_idx == length(TrainingSet)
            seg = [tmp_idx; tmp_idx-1];
        else
            seg = tmp_idx-1;
        end
        
        if tmp_idx ==2
            seg = 1;
        else            
            while tmp_idx>2
                if predictedClass(tmp_idx-1) == predictedClass(tmp_idx-2)
                    seg = [seg;tmp_idx-2];
                    tmp_idx = tmp_idx-1;
                else
                    break;
                end
            end
        end
        seg;
        count = sum(seg>0);
        for i = 1:count
            TrainingSet{seg(i)}.Last = count;
        end
    end        
end

features = [];
for i = 1:length(TrainingSet)
    % Features
    tmp = [TrainingSet{i}.PF(1) TrainingSet{i}.PF(2) TrainingSet{i}.Speed TrainingSet{i}.Last];    
    features = [features;tmp];    
end

% Train the TreeBagger (Decision Forest).
B2 = TreeBagger(nTrees,features,classLabels, 'Method', 'classification');

predictedClass = [];
for i = 1:length(TrainingSet)
    tmp = [TrainingSet{i}.PF(1) TrainingSet{i}.PF(2)  TrainingSet{i}.Speed TrainingSet{i}.Last];  
    predictedClass = [predictedClass;str2double(B2.predict(tmp))];
end

% for CRF++
save Selfpredicted predictedClass


if isfield(curExp,'try_HMM')
    output2 = hmmTrainSplit2(curExp);
end


output.B1 = B1;
output.B2 = B2;