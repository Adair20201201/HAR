function net = nnTrainClassify(curExp)
TrainingSet = curExp.trainSet;
%TrainingSet = TrainSet;

% Calculate the num of Actions
tmpState = [];
for i =1:length(TrainingSet)
    tmpState=[tmpState TrainingSet{i}.State];
end

State = unique(tmpState);
ActionType = cell (length(State),1);
% Seperate Training Samples into different type
for i = 1:length(TrainingSet)
    tmp = TrainingSet{i}.State;
    if tmp~=0 && ~isnan(tmp)
        ActionType{tmp}=[ActionType{tmp} TrainingSet{i}.Data'];
    end
end

%% =======================================================
% output matrix
%output = zeros(length(tmpState),size(State,2));
output = zeros(size(State,2),length(tmpState));
for i = 1:length(tmpState)
    output(tmpState(i),i) = 1;
end
% input matrix
S = ActionType{State(1)};
A = ActionType{State(2)};
input = [S A];
% build network
%net = newff( minmax(input) , [10 10 ] , { 'logsig' 'purelin' } , 'traingd' );
net = newff(input,output,[4 3]);

net.trainparam.show = 50 ;
net.trainparam.epochs = 2 ;
net.trainparam.goal = 0.01 ;
net.trainParam.lr = 0.01 ;

net = train(net,input,output);
%outputs = net(input);
%training para


% [ net, tr, Y1, E ] = train( net, input , output ) ;

%% =======================================================

% %% Define output coding
% s = [1 0]';
% a = [0 1]';
% 
% %% Prepare inputs & outputs for network training
% % define inputs (combine samples from all four classes)
% S = ActionType{State(1)};
% A = ActionType{State(2)};
% P = [S A];
% % define targets
% T = [repmat(s,1,size(S,2)) repmat(a,1,size(A,2))];
% 
% %% Create and train a multilayer perceptron
% % create a neural network
% net = feedforwardnet([4 3]);
% % train net
% net.divideParam.trainRatio = 1; % training set [%]
% net.divideParam.valRatio = 0; % validation set [%]
% net.divideParam.testRatio = 0; % test set [%]
% % train a neural network
% [net,tr,Y,E] = train(net,P,T,'TS',2);
% 
% % show network
% view(net)
% 
% %% Evaluate network performance and plot results
% 
% % evaluate performance: decoding network response
% [m,i] = max(T); % target class
% [m,j] = max(Y); % predicted class
% N = length(Y); % number of all samples
% k = 0; % number of missclassified samples
% if find(i-j), % if there exist missclassified samples
% k = length(find(i-j)); % get a number of missclassified samples
% end
% fprintf('Correct classified samples: %.1f%% samples\n', 100*(N-k)/N)
% % plot network output
% figure;
% subplot(211)
% plot(T')
% title('Targets')
% ylim([-2 2])
% grid on
% subplot(212)
% plot(Y')
% title('Network response')
% xlabel('# sample')
% ylim([-2 2])
% grid on