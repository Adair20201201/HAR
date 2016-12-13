function inferedLabels = rfPredict_Online(Samples, learnedParams)
% outTesting.inferedLabels: Labels inferred by the algorithm

B = learnedParams;
inferedLabels = [];
for i = 1:length(Samples)
    tmp = [Samples{i}.PF(1) Samples{i}.PF(2)  Samples{i}.Speed];  
    predictedClass = str2double(B.predict(tmp));
    inferedLabels = [inferedLabels predictedClass];
end
