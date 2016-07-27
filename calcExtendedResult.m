function [statStruct] = calcExtendedResult(ModelName, ModelOutput)

%ModelOutput = outputHMM

trueLabels = []; % all true labels
inferedLabels = []; % all infered labels
for i=1:length(ModelOutput) %number of cross validations
    this_trueLabels = ModelOutput{i}.testing.trueLabels; % for this cross valication
    this_inferedLabels = ModelOutput{i}.testing.inferedLabels;
    
    % Precisio/Recall/Accuracy
    tempPrec(i) = calcPrecision(this_trueLabels, this_inferedLabels);
    tempRec(i) = calcRecall(this_trueLabels, this_inferedLabels);
    tempAcc(i) = calcTimeSliceAccuracy(this_trueLabels, this_inferedLabels);
    
    % all true labels/all infered labels
    trueLabels = [trueLabels this_trueLabels];
    inferedLabels = [inferedLabels this_inferedLabels];
end

%%% Confusion Matrix
modelConfMat = calcConfMat(trueLabels', inferedLabels');
statStruct.ConfMat = modelConfMat;

statStruct.Prec = mean(tempPrec);
statStruct.stdPrec = std(tempPrec);
statStruct.Rec = mean(tempRec);
statStruct.stdRec = std(tempRec);
statStruct.Acc = mean(tempAcc);
statStruct.stdAcc = std(tempAcc);

