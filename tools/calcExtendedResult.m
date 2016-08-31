function [statStruct] = calcExtendedResult(ModelName, ModelOutput)

%ModelOutput = outputHMM

trueLabels = []; % all true labels
inferedLabels = []; % all infered labels
predict_loglik = []; % all predict loglik

for i=1:length(ModelOutput) %number of cross validations
    this_trueLabels = ModelOutput{i}.testing.trueLabels; % for this cross valication
    this_inferedLabels = ModelOutput{i}.testing.inferedLabels;
    if isfield(ModelOutput{i}.testing,'loglik')
        this_predict_loglik = ModelOutput{i}.testing.loglik;
    end
    
    
    % Precisio/Recall/Accuracy
    tempPrec(i) = calcPrecision(this_trueLabels, this_inferedLabels);
    tempRec(i) = calcRecall(this_trueLabels, this_inferedLabels);
    tempAcc(i) = calcTimeSliceAccuracy(this_trueLabels, this_inferedLabels);
    
    % all true labels/all infered labels
    trueLabels = [trueLabels this_trueLabels];
    inferedLabels = [inferedLabels this_inferedLabels];
    if isfield(ModelOutput{i}.testing,'loglik')
        predict_loglik = [predict_loglik;this_predict_loglik];
    end
end

%%% Confusion Matrix
modelConfMat = calcConfMat(trueLabels', inferedLabels')

statStruct.ConfMat = modelConfMat;

save modelConfMat modelConfMat;

statStruct.Prec = mean(tempPrec);
statStruct.stdPrec = std(tempPrec);
statStruct.Rec = mean(tempRec);
statStruct.stdRec = std(tempRec);
statStruct.Acc = mean(tempAcc);
statStruct.stdAcc = std(tempAcc);

%%% Calculate and Visualize ROC and AUC
if isfield(ModelOutput{i}.testing,'loglik')
    [tpr,fpr,auc] = calcROC_AUC(trueLabels', predict_loglik');
    color = ['y','m','c','r','g','b','w','k'];
    marker = ['+','*','x','s','^','p','h','d'];

    figure; 
    hold on;
    for j = 1:length(auc)
        plot(fpr{j},tpr{j},'Color',color(j),'Marker',marker(j));
    end
    hold off;
    title('ROC curve');
    xlabel(' False Positive Ratio ');
    ylabel('True Positive Ratio ');
    legend('Lying','Lie-to-sit','Sit- to-lie','Sitting','Sit-to-stand','Stand-to-sit',...
                  'Standing','Walking','Location','NorthEastOutside');

    statStruct.Auc = auc;
    auc = cell2mat(auc);
    statStruct.mAuc = mean(auc);
    statStruct.stAuc = std(auc);
    
end


