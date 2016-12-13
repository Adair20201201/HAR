function svmStruct = svmTrainClassify(curExp)
TrainingSet = curExp.trainSet;
%TrainingSet = TrainSet;

% input and output matrix
tmpState = [];
input = [];
for i = 1:length(TrainingSet)
    tmp = TrainingSet{i}.State;
    if tmp~=0 && ~isnan(tmp)
        input=[input ; TrainingSet{i}.Data];
        %tmpState(tmp,end+1)= TrainingSet{i}.State;
        tmpState = [tmpState ; TrainingSet{i}.State];
    end
end

% New versions in Malab2016a
% SVMModel  = fitcsvm(input,tmpState,'KernelFunction','gaussian',...
%     'BoxConstraint',Inf,'ClassNames',[1,2]);
% ScoreSVMModel = fitPosterior(SVMModel,input,tmpState);

% Old versions may be discarded
svmStruct = svmtrain(input,tmpState,'kernel_function','mlp'); % 'rbf'  quadratic  'linear'    'polynomial'   'mlp' 

% libsvm 
%svmStruct = svmtrain(tmpState, input, '-b', 1);