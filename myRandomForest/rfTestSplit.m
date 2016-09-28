function outTesting = rfTrainSplit(curExp, learnedParams)
% outTesting.inferedLabels: Labels inferred by the algorithm
% outTesting.trueLabels: True Labels of the Samples

B1 = learnedParams.B1;
B2 = learnedParams.B2;

TestingSet = curExp.testSet;

inferedLabels = [];
for i = 1:length(curExp.testSet)
    tmp = [TestingSet{i}.PF(1) TestingSet{i}.PF(2)  TestingSet{i}.Speed];  
    predictedClass = str2double(B1.predict(tmp));
    inferedLabels = [inferedLabels predictedClass];
end

%%% Second Stage

seg = [];
for sam_idx = 2:length(TestingSet)
    if inferedLabels(sam_idx) ~= inferedLabels(sam_idx-1) || ...
            sam_idx == length(TestingSet)
        
        tmp_idx = sam_idx;
        
        if sam_idx == length(TestingSet)
            seg = [tmp_idx; tmp_idx-1];
        else
            seg = tmp_idx-1;
        end
        
        if tmp_idx ==2
            seg = 1;
        else            
            while tmp_idx>2
                if inferedLabels(tmp_idx-1) == inferedLabels(tmp_idx-2)
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
            TestingSet{seg(i)}.Last = count;
        end
    end        
end

inferedLabels = [];
for i = 1:length(curExp.testSet)
    tmp = [TestingSet{i}.PF(1) TestingSet{i}.PF(2)  TestingSet{i}.Speed TestingSet{i}.Last];  
    predictedClass = str2double(B2.predict(tmp));
    inferedLabels = [inferedLabels predictedClass];
end

%%%%% Fix Format Output  %%%%%%
outTesting.inferedLabels = inferedLabels;

trueLabels = [];
for i=1:length(curExp.testSet)
    trueLabels = [trueLabels curExp.testSet{i}.Label];
end

outTesting.trueLabels = trueLabels;