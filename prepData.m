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

%%%%%%% Action Type %%%%%%%%%%%%%%%%%%
Action_name = cell(1,8);
Action_name(1) = {'Lying'};
Action_name(2) = {'Lie-to-sit'};
Action_name(3) = {'Sit-to-lie'};
Action_name(4) = {'Sitting'};
Action_name(5) = {'Sit-to-stand'};
Action_name(6) = {'Stand-to-sit'};
Action_name(7) = {'Standing'};
Action_name(8) = {'Walking'};

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
        
        %fprintf('label_file = %s\n', label_file);
        fprintf('open ''%s''\n', label_file);
        %fprintf('data_file = %s\n', data_file);
        
        if 1
            color = ['y','m','c','r','g','b','r','k'];
            markertype = ['+','*','x','s','o','p','h','>'];
            figure;
            hold on;
            axis([-4 4 -4 4])
            last_location = [];
            last_mark = [];
            for i = 1:length(Samples)
                location = Samples{i}.Location;
                label = Samples{i}.Label;                
                %scatter(location(1,:),location(2,:),[],color(label),markertype(label));
                if ~isempty(last_location)
                    scatter(last_location(1,:), last_location(2,:),[], ... 
                        'w',last_mark);
                end
                scatter(location(1,:),location(2,:),[],'r',markertype(label));
                title(['Time: ' num2str(Samples{i}.Time) ' (' num2str(i) ')    Action: ' cell2mat(Action_name(label)) ' (' num2str(label) ')'])
                last_location = location;
                last_mark= markertype(label);
                pause;  
            end
            hold off;
        end
        
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