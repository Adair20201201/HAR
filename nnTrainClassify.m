function net = nnTrainClassify(curExp)
TrainingSet = curExp.trainSet;
%TrainingSet = TrainSet;

% input and output matrix
tmpState = [];
input = [];
for i = 1:length(TrainingSet)
    tmp = TrainingSet{i}.State;
    if tmp~=0 && ~isnan(tmp)
        input=[input TrainingSet{i}.Data'];
        %tmpState(tmp,end+1)= TrainingSet{i}.State;
        tmpState(tmp,end+1)= 1;
    end
end

% build network
%net = newff( minmax(input) , [10 10 ] , { 'logsig' 'purelin' } , 'traingd' );
net = newff(input,tmpState,[70 30 5],{ 'purelin'  'purelin' 'purelin'} , 'traingdx' ); % { 'logsig' 'purelin' }

%training para
net.trainparam.show = 15 ;
net.trainparam.epochs = 1000 ;
net.trainparam.goal = 0.001 ;
net.trainParam.lr = 0.001 ;

net = train(net,input,tmpState);
%outputs = net(input);

% [ net, tr, Y1, E ] = train( net, input , output ) ;
