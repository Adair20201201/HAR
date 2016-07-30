clear all
close all
%clc
%projectDir =  'G:\ActionDataColection\ActionData\0716';
projectDir =  'G:\HAR';
%projectDir = '/Users/xiaomuluo/Win7/E/kuaipan/sourcecode/MyDBank/new(20140330)';
%projectDir = '/Users/xiaomuluo/Win7/E/kuaipan/sourcecode/MyDBank/HAR(20160727)';
cd(projectDir);
%DataDir='./SensorData_labeled/Tan/';
DataDir = 'G:\ActionDataColection\ActionData\SensorData_labled\Tan\';
%DataDir='/Users/xiaomuluo/Win7/E/kuaipan/sourcecode/MyDBank/new(20140330)/SensorData_labeled/Tan/';
filetype='.csv';
%filetype='.xls';
files = dir([DataDir '*' filetype]);
%files = dir('.\SensorData_labled\Tan\*.xls');
file_num = size(files,1);
%DataIdx=1:file_num;
%DataIdx=1:3; % Just for testing
DataIdx=1:2; % Just for testing

%%%%%%% Load Data %%%%%%%%%%%%%%%%%%%%%
win = 30;
gap = 15;

%index = 1;
%for k=1:length(DataIdx)
%conf = cell(2,1);
conf = cell(1,1);
for k=1:2
    disp(sprintf('Cross Validation : %d', k));
    
    % k is the Index for testing

    TrainSet = [];
    TestSet = []; 
    Samples = [];
    label_file = [];
    data_file = [];
    
    %%%%%%%%% Add Features %%%%%%%%%%%%%
    %%
    for i=1:length(DataIdx)
        label_file=[DataDir num2str(DataIdx(i)) filetype];
        data_file=[DataDir num2str(DataIdx(i)) '.txt'];
        %Samples = SegData(label_file,data_file,win,gap);
        %Samples = SegData(label_file,data_file,win,gap,'k-means',5);
        Samples = SegData(label_file,data_file,win,gap,'fft');
        if i~=k % Training DataSet            
            TrainSet = [TrainSet Samples];
        else % Testing DataSet
            TestSet = [TestSet Samples];
        end
    end
    conf{1,1} = [];
    conf{1,1}.trainSet = TrainSet;
    conf{1,1}.testSet = TestSet;
    
    TrainSet = [];
    TestSet = []; 
    Samples = []; 
    label_file = [];
    data_file = [];
    for i=1:length(DataIdx)
        label_file=[DataDir num2str(DataIdx(i)) filetype];
        data_file=[DataDir num2str(DataIdx(i)) '.txt'];
        %Samples = SegData(label_file,data_file,win,gap);
        Samples = SegData(label_file,data_file,win,gap,'k-means',5);
        %Samples = SegData(label_file,data_file,win,gap,'fft');
        if i~=k % Training DataSet            
            TrainSet = [TrainSet Samples];
        else % Testing DataSet
            TestSet = [TestSet Samples];
        end
    end
    conf{2,1} = [];
    conf{2,1}.trainSet = TrainSet;
    conf{2,1}.testSet = TestSet;
    
    
    for i = 1:size(conf,1)
        curExp.trainSet = conf{i,1}.trainSet;
        curExp.testSet = conf{i,1}.testSet;
        %%%%%%%%%%% Algorithms %%%%%%%%%%
        disp('Training and Testing NB');
        outputNB{i,k} = TrainTestSplit('nb', curExp);
         
        disp('Training and Testing HMM');
        curExp. try_HMM = 2; %differebt initial values
        curExp.M = 2; %Number of mixtures (array)
        curExp.Q = 4; %Number of states (array)
        curExp.MAX_ITER = 5;%Max Iteration for HMM
        curExp.cov_type = 'diag';
        outputHMM{i,k} = TrainTestSplit('hmm', curExp);
        %index = index+1;
        
    end
    
end

%%%%%%% Results %%%%%%%%%%%%%%%%%%%%%
%%

if (exist('outputNB'))
    for i = size(outputNB,1)
        res.statNB{i} = calcExtendedResult('nb', outputNB(i,:));
    end
end

if (exist('outputHMM'))
    for i = size(outputHMM,1)
        res.statHMM{i} = calcExtendedResult('hmm', outputHMM(i,:));
    end
end