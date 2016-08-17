%  Buid a DBN for each Node(We have five Nodes which are same to each
%  other. )
clear all
close all
clc

% Creat BNET
bnet = [];
str = 'node';
for i = 1:5
    bnet{i} = buildNodeBnet(strcat(str,num2str(i)));
     
end

 % Creat Nodes sample
 onodes = 3;
 hnode = [1 2];
 T = 30;
 sampleNum = 50;
 modelObserved = [];
 ev = [];
state = [];
 for i = 1:sampleNum
     for j = 1: length(bnet)
         ev{i,j} = sample_dbn(bnet{j},T);
         modelObserved{i,j} =  ev{i,j}{onodes,:} ;
         state(i,j) = ev{i,j}{hnode} ;
     end
 end
 
 % Inference
 engine = smoother_engine(jtree_2TBN_inf_engine(bnet));
 
% % Visual the samples
%  for i = 1:ns(1)
%      figure
%      for j = 1:size(modelObserved,2)
%          plot(cell2mat(modelObserved{i,j}(onodes,:))');
%      end
%  end
