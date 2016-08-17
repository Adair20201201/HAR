%% Calculate ROC and AUC
function [tpr,fpr,auc] = calcROC_AUC(orgLabels, predict_loglik)
labels = unique(orgLabels);
orglabels_tmp = zeros(length(labels),length(orgLabels));
for i = 1:length(orgLabels)
    orglabels_tmp(orgLabels(i),i) = 1;
end
[tpr, fpr,thresholds] = roc(orglabels_tmp, predict_loglik);
for i = 1:length(tpr)
    auc{i} = trapz(fpr{i},tpr{i});
    %plot(fpr{i},tpr{i});
end
%plotroc(orglabels_tmp,predict_loglik);
