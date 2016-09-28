function output = templateTrainSplit(curExp)
%%% Train for each activity/each node
%%% Totally output 8*5 = 40 Templates

TrainingSet = curExp.trainSet;

% Calculate the num of Actions
classLabels = [];
for i =1:length(TrainingSet)
    classLabels=[classLabels TrainingSet{i}.Label];
end

Labels = unique(classLabels); % Find Unique Labels (0 for no action, discarded)
ActionType = cell (length(Labels),1);

% Seperate Training Samples into different type
for i = 1:length(TrainingSet)
    tmp = TrainingSet{i}.Label;
    if tmp~=0 && ~isnan(tmp)
        ActionType{tmp}=[ActionType{tmp} num2cell(TrainingSet{i}.Data,[1 2])];
    end
end

%% Prepare data for each activity/each node
Dataset = cell(8,5);% row: activity type  ; col: node id
for i = 1:length(TrainingSet)    
    tmp_act = TrainingSet{i}.Label;
    TrainingSet{i}.Fired;
    for j_node = 1:length(TrainingSet{i}.Fired)
        if TrainingSet{i}.Fired(j_node) ~= 0
            tmp_data = TrainingSet{i}.Data((j_node-1)*9+1:j_node*9,:);
            Dataset{tmp_act,j_node} = [Dataset{tmp_act,j_node};mat2cell(tmp_data,size(tmp_data,1))]; 
        end
    end
end

% Template
for i = 1:size(Dataset,1) % Activity
    for j = 1:size(Dataset,2) % Node
        tmp = []; % Template
        for k = 1:length(Dataset{i,j})
            tmp = [tmp;data2fft(Dataset{i,j}{k})];
        end
        Act_template{i,j} = mean(tmp,1);
    end
end

output = Act_template;