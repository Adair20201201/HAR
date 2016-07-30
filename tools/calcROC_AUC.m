%% Calculate ROC and AUC
function [tpr,fpr,auc] = calcROC_AUC(orgLabels, predict_loglik)
labels = unique(orgLabels);
orglabels = zeros(length(labels),length(orgLabels));
for i = 1:length(orgLabels)
    orglabels(orgLabels,i) = 1;
end
[tpr, fpr,thresholds] = roc(orglabels, predict_loglik);
for i = 1:length(tpr)
    auc{i} = trapz(fpr{i},tpr{i});
    %plot(fpr{i},tpr{i});
end
%plotroc(orglabels,predict_loglik);
