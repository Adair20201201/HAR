function outTesting = templateTestSplit(curExp, learnedParams)
% outTesting.inferedLabels: Labels inferred by the algorithm
% outTesting.trueLabels: True Labels of the Samples

Act_template = learnedParams;
TestingSet = curExp.testSet;

for i = 1:size(Act_template,1)
    for j = 1:size(Act_template,2)
        if isempty(Act_template{i,j})
            Act_template{i,j} = zeros(1,153);        
        end
    end
end

inferedLabels = [];
for i = 1:length(TestingSet)
    %tmp = [TestingSet{i}.PF(1) TestingSet{i}.PF(2)  TestingSet{i}.Speed];  
    %predictedClass = str2double(B.predict(tmp));
    %Act_mat = zeros(8,5);
    Act_mat_d = 999*ones(8,5);
    for j_node = 1:length(TestingSet{i}.Fired)
        if TestingSet{i}.Fired(j_node) ~= 0
            tmp_data = TestingSet{i}.Data((j_node-1)*9+1:j_node*9,:);
            %data2fft(tmp_data);
            tmp_dist = dist(cell2mat(Act_template(:,j_node)),data2fft(tmp_data)');
            [Y,Idx] = min(tmp_dist);
            %Act_mat(Idx, j_node) = 1;
            Act_mat_d(Idx, j_node) = Y;
        end
    end
    
    [Y,I] = min(min(Act_mat_d,[],2),[],1);    
    predictedClass = I;
    
    inferedLabels = [inferedLabels predictedClass];
end


%%%%% Fix Format Output  %%%%%%
outTesting.inferedLabels = inferedLabels;

trueLabels = [];
for i=1:length(curExp.testSet)
    trueLabels = [trueLabels curExp.testSet{i}.Label];
end

outTesting.trueLabels = trueLabels;