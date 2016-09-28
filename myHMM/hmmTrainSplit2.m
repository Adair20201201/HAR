%function output = hmmTrainSplit2(curExp)
%%% Train for each activity/each node
%%% Totally output 8*5 = 40 HMMs

TrainingSet = curExp.trainSet;

if ~isfield(curExp,'try_HMM')
    try_HMM = 2;
else
    try_HMM = curExp.try_HMM; % differebt initial values
end

if ~isfield(curExp,'M')
    M = 2;
else
    M = curExp.M; % Number of mixtures (array)
end

if ~isfield(curExp,'Q')
    Q = 4;
else
    Q = curExp.Q; % Number of states (array)
end

if ~isfield(curExp,'MAX_ITER')
    MAX_ITER = 10;
else
    MAX_ITER = curExp.MAX_ITER;% Max Iteration for HMM
end

if ~isfield(curExp,'cov_type')
    cov_type =  'diag';
else
    cov_type = curExp.cov_type;
end

%%%%%%%%%%%%%%%%%%%%%%

% Calculate the num of Actions
classLabels = [];
for i =1:length(TrainingSet)
    classLabels=[classLabels TrainingSet{i}.Label];
end

Labels = unique(classLabels); % Find Unique Labels (0 for no action, discarded)
ActionType = cell (length(Labels),1);

% Seperate Training Samples into different type
for i = 1:length(TrainingSet)
    tmp = TrainingSet{i}.Label;
    if tmp~=0 && ~isnan(tmp)
        ActionType{tmp}=[ActionType{tmp} num2cell(TrainingSet{i}.Data,[1 2])];
    end
end

%% Prepare data for each activity/each node
Dataset = cell(8,5);% row: activity type  ; col: node id
for i = 1:length(TrainingSet)    
    tmp_act = TrainingSet{i}.Label;
    TrainingSet{i}.Fired;
    for j_node = 1:length(TrainingSet{i}.Fired)
        if TrainingSet{i}.Fired(j_node) ~= 0
            tmp_data = TrainingSet{i}.Data((j_node-1)*9+1:j_node*9,:);
            Dataset{tmp_act,j_node} = [Dataset{tmp_act,j_node};mat2cell(tmp_data,size(tmp_data,1))]; 
        end
    end
end

% Template
for i = 1:size(Dataset,1) % Activity
    for j = 1:size(Dataset,2) % Node
        tmp = []; % Template
        for k = 1:length(Dataset{i,j})
            tmp = [tmp;data2fft(Dataset{i,j}{k})];
        end
        Act_template{i,j} = mean(tmp,1);
    end
end


here1122

%%% Training HMM %%%
%rand('state', 5);

for i=1:length(ActionType)
    % nex = l;%Number of sequences
    % initial guess of parameters
    prior0 = normalise(rand(Q,1));
    transmat0 = mk_stochastic(rand(Q,Q));
    
    tmp_mhmm=[];
    tmp_LL=[];
    for j=1:try_HMM
        disp(sprintf('Action Type: %d (out of %d) Try_HMM: %d', i, length(ActionType), j));
        if 0
            Sigma0 = repmat(eye(size(O,2)), [1 1 Q M]);
            % Initialize each mean to a random data point
            indices = randperm(T*nex);
            mu0 = reshape(data_action(:,indices(1:(Q*M))), [size(O,2) Q M]);
            mixmat0 = mk_stochastic(rand(Q,M));
        else
            [mu0, Sigma0] = mixgauss_init(Q*M, cell2mat(ActionType{i}), cov_type);
            mu0 = reshape(mu0, [size(ActionType{i}{1},1) Q M]);
            Sigma0 = reshape(Sigma0, [size(ActionType{i}{1},1) size(ActionType{i}{1},1) Q M]);
            mixmat0 = mk_stochastic(rand(Q,M));
        end
        [LL, prior1, transmat1, mu1, Sigma1, mixmat1] = ...
            mhmm_em(ActionType{i}, prior0, transmat0, mu0, Sigma0, mixmat0, 'max_iter', MAX_ITER);
        tmp_mhmm(j).prior=prior1; % save the model parameter
        tmp_mhmm(j).transmat=transmat1;
        tmp_mhmm(j).mu=mu1;
        tmp_mhmm(j).Sigma=Sigma1;
        tmp_mhmm(j).mixmat=mixmat1;
        tmp_LL(j)=LL(end);
        if (LL(end) == -inf) && (j ~= 1)
            j=j-1;
        end
    end
    
    [Y,I]=max(tmp_LL);
    
    assert(Y~= -inf);
    
    action_mhmm(i).prior=tmp_mhmm(I).prior; % save the model parameter
    action_mhmm(i).transmat=tmp_mhmm(I).transmat;
    action_mhmm(i).mu=tmp_mhmm(I).mu;
    action_mhmm(i).Sigma=tmp_mhmm(I).Sigma;
    action_mhmm(i).mixmat=tmp_mhmm(I).mixmat;
    
end

output = action_mhmm;