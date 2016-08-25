clear all
close all
 
projectDir =  'G:\HAR';
 
cd(projectDir);
 
DataDir = 'G:\ActionDataColection\ActionData\SensorData_labled\Tan\';
 
filetype='.csv';
 
files = dir([DataDir '*' filetype]);
 
file_num = size(files,1);
%DataIdx=1:file_num;
DataIdx=1:2; % Just for testing

%%%%%%% Load Data %%%%%%%%%%%%%%%%%%%%%
win = 30;
gap = 15;

% index = 1;
% conf = cell(2,1);
conf = cell(1,1);
for k=1:length(DataIdx)
%for k=1:2
    disp(sprintf('Cross Validation : %d', k));
    
    % k is the Index for testing

    TrainSet = [];
    TestSet = []; 
     
    %%%%%%%%% Add Features %%%%%%%%%%%%%
    %%
    for j=1:length(DataIdx)
        Samples = [];
        label_file = [];
        data_file = [];
        
        data_file=[DataDir num2str(DataIdx(j)) '.txt'];
        label_file_new2 = [DataDir num2str(DataIdx(j)) '_new2' filetype];% new label file
        
        %Samples = SegData(label_file,data_file,win,gap);
%         clusterNum = 5;
%         centroid = calcuCentroid(win,gap,clusterNum,projectDir,DataDir);
%         Samples = SegData(label_file,data_file,win,gap,'k-means',centroid);
        Samples = SegData(data_file,win,gap,'fft');
               
        % Read the label file
        fprintf('Read "%s"\n', label_file_new2);
        A = dlmread(label_file_new2);
        label_mat = A(:,3);
        for i = 1:length(Samples) 
            if label_mat(i) > 0
                Samples{i}.Label = label_mat(i);
                if label_mat(i) == 8  % Walking vs others
                    Samples{i}.State = 1;
                else
                     Samples{i}.State = 2;
                end
            else
                Samples{i} = [];
            end
        end
        Samples(cellfun('isempty',Samples)) = []; % Remove the Samples whose labels are zeros
        
        
        %save Samples Samples;
        if j~=k % Training DataSet            
            TrainSet = [TrainSet Samples];
        else % Testing DataSet
            TestSet = [TestSet Samples];
        end
    end
    conf{1,1} = [];
    conf{1,1}.trainSet = TrainSet;
    conf{1,1}.testSet = TestSet;
    
%     TrainSet = [];
%     TestSet = []; 
%     Samples = []; 
%     label_file = [];
%     data_file = [];
%     for i=1:length(DataIdx)
%         label_file=[DataDir num2str(DataIdx(i)) filetype];
%         data_file=[DataDir num2str(DataIdx(i)) '.txt'];
%         Samples = SegData(label_file,data_file,win,gap);
%         %Samples = SegData(label_file,data_file,win,gap,'fft');
%         if i~=k % Training DataSet            
%             TrainSet = [TrainSet Samples];
%         else % Testing DataSet
%             TestSet = [TestSet Samples];
%         end
%     end
%     conf{2,1} = [];
%     conf{2,1}.trainSet = TrainSet;
%     conf{2,1}.testSet = TestSet;
%     
    
    for i = 1:size(conf,1)
        curExp.trainSet = conf{i,1}.trainSet;
        curExp.testSet = conf{i,1}.testSet;
        %%%%%%%%%%% Algorithms %%%%%%%%%%
         
%         disp('Training and Testing HMM');
%         curExp. try_HMM = 2; %differebt initial values
%         curExp.M = 2; %Number of mixtures (array)
%         curExp.Q = 8; %Number of states (array)
%         curExp.MAX_ITER = 10;%Max Iteration for HMM
%         curExp.cov_type = 'diag';
%         outputHMM{i,k} = TrainTestClassify('hmm', curExp);
%         %index = index+1;
%         
        disp('Training and Testing  Neural Network');
        outputNN{i,k} = TrainTestClassify('nn', curExp);
        
        disp('Training and Testing  SVM');
        outputSVM{i,k} = TrainTestClassify('svm', curExp);
        
    end
    
end

%%%%%%% Results %%%%%%%%%%%%%%%%%%%%%
%%
if (exist('outputHMM'))
    for i = 1:size(outputHMM,1)
        res.statHMM{i} = calcExtendedResultClassifyState('hmm', outputHMM(i,:));
    end
end

if (exist('outputNN'))
    for i = 1:size(outputNN,1)
        res.statNN{i} = calcExtendedResultClassifyState('nn', outputNN(i,:));
    end
end

if (exist('outputSVM'))
    for i = 1:size(outputSVM,1)
        res.statSVM{i} = calcExtendedResultClassifyState('svm', outputSVM(i,:));
    end
end