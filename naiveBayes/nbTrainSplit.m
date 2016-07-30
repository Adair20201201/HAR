%%
function [ learnedParams ] = nbTrainSplit(curExp) 
trainSet = curExp.trainSet;
data = [];
lable = [];
for i = 1:length(trainSet)
    data(i,:) = trainSet{1,i}.Data;
    lable(i,1) = trainSet{1,i}.Label;
end
% orgLable = zeros(size(lable,1),length(unique(lable)));
% for i = 1:size(lable,1)
%     orgLable(i,lable(i,1)) = 1;
% end
learnedParams = NaiveBayes.fit(data,lable);
%learnedParams = NaiveBayes.fit(data,lable,'dist','kernel');