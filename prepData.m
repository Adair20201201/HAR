clear all
close all
%clc
%projectDir =  'G:\ActionDataColection\ActionData\0716';
%projectDir = '/Users/xiaomuluo/Win7/E/kuaipan/sourcecode/MyDBank/new(20140330)';
projectDir = '/Users/xiaomuluo/Win7/E/kuaipan/sourcecode/MyDBank/HAR(20160727)';
cd(projectDir);
%DataDir='./SensorData_labeled/Tan/';
%DataDir = 'G:\ActionDataColection\ActionData\SensorData_labled\Tan\';
DataDir='/Users/xiaomuluo/Win7/E/kuaipan/sourcecode/MyDBank/new(20140330)/SensorData_labeled/Tan/';
filetype='.csv';
%filetype='.xls';
files = dir([DataDir '*' filetype]);
%files = dir('.\SensorData_labled\Tan\*.xls');
file_num = size(files,1);
%DataIdx=1:file_num;
DataIdx=1:3; % Just for testing

%%%%%%% Load Data %%%%%%%%%%%%%%%%%%%%%
win = 30;
gap = 15;

index = 1;
%for k=1:length(DataIdx)
for k=1:2
    % k is the Index for testing
    TrainSet = [];
    TestSet = [];
    for i=1:length(DataIdx)
        label_file=[DataDir num2str(DataIdx(i)) filetype];
        data_file=[DataDir num2str(DataIdx(i)) '.txt'];
        Samples = SegData(label_file,data_file,win,gap);
        
        if i~=k % Training DataSet            
            TrainSet = [TrainSet Samples];
        else % Testing DataSet
            TestSet = [TestSet Samples];
        end
    end
    
    
    curExp.trainSet = TrainSet;
    curExp.testSet = TestSet;
    %%%%%%%% Algorithms %%%%%%%%%%
    curExp. try_HMM = 2; %differebt initial values
    curExp.M = 2; %Number of mixtures (array)
    curExp.Q = 4; %Number of states (array)
    curExp.MAX_ITER = 5;%Max Iteration for HMM
    curExp.cov_type = 'diag';
    outputHMM{index} = TrainTestSplit('hmm', curExp);
    
    index = index+1;
end

%%%%%%% Results %%%%%%%%%%%%%%%%%%%%%
%%
if (exist('outputHMM'))
    res.statHMM = calcExtendedResult('hmm', outputHMM);
end