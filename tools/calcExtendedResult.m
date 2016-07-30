function [statStruct] = calcExtendedResult(ModelName, ModelOutput)

%ModelOutput = outputHMM

trueLabels = []; % all true labels
inferedLabels = []; % all infered labels

tprTotal = [];
fprTotal = [];
aucTotal = [];

for i=1:length(ModelOutput) %number of cross validations
    this_trueLabels = ModelOutput{i}.testing.trueLabels; % for this cross valication
    this_inferedLabels = ModelOutput{i}.testing.inferedLabels;
    this_predict_loglik = ModelOutput{i}.testing.loglik;
    
    % Precisio/Recall/Accuracy
    tempPrec(i) = calcPrecision(this_trueLabels, this_inferedLabels);
    tempRec(i) = calcRecall(this_trueLabels, this_inferedLabels);
    tempAcc(i) = calcTimeSliceAccuracy(this_trueLabels, this_inferedLabels);
    
    % all true labels/all infered labels
    trueLabels = [trueLabels this_trueLabels];
    inferedLabels = [inferedLabels this_inferedLabels];
    
    % Calculate ROC and AUC
    [tpr,fpr,auc] = calcROC_AUC(this_trueLabels', this_predict_loglik');
    color=[0 0 1
                0 1 0
                0 1 1
                1 0 0
                1 0 1
                1 1 0
                0 .5 0
                0 .75 .75
                ] ; %�Զ�����ɫ
    figure(i); 
    hold on;
    for j = 1:length(auc)
%        tprTotal{j}(i,:) = tpr{1,j};  % Demation are different
%        fprTotal{j}(i,:) = fpr{1,j};
        aucTotal{j}(i,:) = auc{1,j};
        plot(fpr{j},tpr{j},'color',color(j,:));
       
    end
    
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

%%% Calculate and Visualize ROC and AUC
 
for i = 1:length(aucTotal)
%      tpr{i} = mean(tprTotal{i},1);
%      fpr{i} = mean(fprTotal{i},1);
%      statStruct.tpr{i} = tpr{i};
%      statStruct.fpr{i} = fpr{i};
     statStruct.Auc{i} = mean(aucTotal{i},1);
     statStruct.stAuc{i} = std(aucTotal{i},0,1);
end

