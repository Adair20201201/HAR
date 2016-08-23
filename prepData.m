%clear all
close all
%clc
%projectDir =  'G:\ActionDataColection\ActionData\0716';
%projectDir =  'G:\HAR';
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
%DataIdx=1:3; % Just for testing
%DataIdx=1:2; % Just for testing
DataIdx=2; % Just for testing

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
        %label_file=[DataDir num2str(DataIdx(i)) filetype];
        data_file=[DataDir num2str(DataIdx(i)) '.txt'];
        mp4_file=[DataDir num2str(DataIdx(i)) '.mp4'];
        label_file_new = [DataDir num2str(DataIdx(i)) '_new' filetype];% new label file
        label_file_new2 = [DataDir num2str(DataIdx(i)) '_new2' filetype];% new label file
        
        fprintf('open ''%s''\n', label_file);
        fprintf('open "%s"\n', mp4_file);
        
        %Samples = SegData(label_file,data_file,win,gap);
        Samples = SegData(data_file,win,gap);
        
        % Create the label file %        
        tmp_label_file = [];
        for i = 1:length(Samples)
            tmp_label_file = [tmp_label_file; Samples{i}.Time Samples{i}.Speed];            
        end
        dlmwrite(label_file_new, tmp_label_file, 'delimiter', ';');
        
        % Read the label file
        A = dlmread(label_file_new2);
        label_mat = A(:,3);
        for i = 1:length(Samples)
            Samples{i}.Label = label_mat(i);
        end
        
       save Samples Samples;
        
       fprintf('cd "%s"\n', DataDir);
       
       if 1
           figure(1);
           hold on
           STE_tmp = [];
           for i = 1:length(Samples)
               STE_tmp = [STE_tmp Samples{i}.STE'];
           end
           
           for j=1:5
               plot(STE_tmp(j,:));
           end
           set(gca,'XTick',[5:5:length(Samples)]) %改变x轴坐标间隔显示 这里间隔为2
           legend('PIR1','PIR2','PIR3','PIR4','PIR5')
       end
        
        if 1
            %color = ['y','m','c','r','g','b','r','k'];
            %markertype = ['+','*','x','s','o','p','h','>'];
            figure(2);
            hold on;
            axis([-4 4 -4 4])
            last_location = [];
            last_mark = [];
            last_location_mean = [];
            for i = 1:length(Samples)
                location = Samples{i}.Location
                speed = Samples{i}.Speed
                label = Samples{i}.Label;
                PF = Samples{i}.PF;

                if i>1
                    scatter(last_location(1,:),last_location(2,:),[],'w','o');
                    plot(last_PF(1),last_PF(2),'w+','markersize',20,'linewidth',2);
                end
                
                if speed>0
                    scatter(location(1,:),location(2,:),[],'r','o');
                    plot(PF(1),PF(2),'m+','markersize',20,'linewidth',2);
               else
                    plot(PF(1),PF(2),'k+','markersize',20,'linewidth',2);
                end
                
                if label > 0                    
                    title(['Samples:\{' num2str(i) '\}' '   Time: ' num2str(Samples{i}.Time)...
                        '    Action: ' cell2mat(Action_name(label)) ' (' num2str(label) ')' '   Speed: '  num2str(speed) ])
                else
                    title(['Samples:\{' num2str(i) '\}' '   Time: ' num2str(Samples{i}.Time)...
                        '    Action: Null' '   Speed: '  num2str(speed) ])
                end

                 last_location = location;
                 last_PF = PF;
                pause;  
            end
            hold off;
        end
        
        %Samples = SegData(label_file,data_file,win,gap);
        %Samples = SegData(label_file,data_file,win,gap,'k-means',5);
        %Samples = SegData(label_file,data_file,win,gap,'fft');
        %save Samples Samples;

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
%     for i=1:length(DataIdx)
%         label_file=[DataDir num2str(DataIdx(i)) filetype];
%         data_file=[DataDir num2str(DataIdx(i)) '.txt'];
%         %Samples = SegData(label_file,data_file,win,gap);
%         Samples = SegData(label_file,data_file,win,gap,'k-means',5);
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
        disp('Training and Testing NB');
        outputNB{i,k} = TrainTestSplit('nb', curExp);
         
%         disp('Training and Testing HMM');
%         curExp. try_HMM = 2; %differebt initial values
%         curExp.M = 2; %Number of mixtures (array)
%         curExp.Q = 4; %Number of states (array)
%         curExp.MAX_ITER = 5;%Max Iteration for HMM
%         curExp.cov_type = 'diag';
%         outputHMM{i,k} = TrainTestSplit('hmm', curExp);
%         %index = index+1;
        
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