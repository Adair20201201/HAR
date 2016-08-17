function [statStruct] = calcExtendedResultClassifyState(ModelName, ModelOutput)

%ModelOutput = outputHMM

trueState = []; % all true labels
inferedState = []; % all infered labels
predict_loglik = []; % all predict loglik

for i=1:length(ModelOutput) %number of cross validations
    this_trueState = ModelOutput{i}.testing.trueState; % for this cross valication
    this_inferedState = ModelOutput{i}.testing.inferedState;
    if isfield(ModelOutput{i}.testing,'loglik')
        this_predict_loglik = ModelOutput{i}.testing.loglik;
    end
    
    
    % Precisio/Recall/Accuracy
    tempPrec(i) = calcPrecision(this_trueState, this_inferedState);
    tempRec(i) = calcRecall(this_trueState, this_inferedState);
    tempAcc(i) = calcTimeSliceAccuracy(this_trueState, this_inferedState);
    
    % all true labels/all infered labels
    trueState = [trueState this_trueState];
    inferedState = [inferedState this_inferedState];
    if isfield(ModelOutput{i}.testing,'loglik')
        predict_loglik = [predict_loglik;this_predict_loglik];
    end
    
end

%%% Confusion Matrix
modelConfMat = calcConfMat(trueState', inferedState');
statStruct.ConfMat = modelConfMat;

statStruct.Prec = mean(tempPrec);
statStruct.stdPrec = std(tempPrec);
statStruct.Rec = mean(tempRec);
statStruct.stdRec = std(tempRec);
statStruct.Acc = mean(tempAcc);
statStruct.stdAcc = std(tempAcc);

%%% Calculate and Visualize ROC and AUC
if isfield(ModelOutput{i}.testing,'loglik')
    [tpr,fpr,auc] = calcROC_AUC(trueState', predict_loglik');
    color = ['y','m'];
    marker = ['+','*'];

    figure; 
    hold on;
    for j = 1:length(auc)
        plot(fpr{j},tpr{j},'Color',color(j),'Marker',marker(j));
    end
    hold off;
    title('ROC curve');
    xlabel(' False Positive Ratio ');
    ylabel('True Positive Ratio ');
    legend('Walking','Others','Location','NorthEastOutside');
    %legend('stationary','active','Location','NorthEastOutside');

    statStruct.Auc = auc;
    auc = cell2mat(auc);
    statStruct.mAuc = mean(auc);
    statStruct.stAuc = std(auc);
    
end


