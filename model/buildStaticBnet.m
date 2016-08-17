function bnet = buildStaticBnet()
dag = zeros(7,7);
dag(1,2:7) = 1;
discrete_nodes = [1:7];
nodes = [1 : 7];
node_sizes=9*ones(1,7);
node_sizes(1,7) = 4;
bnet = mk_bnet(dag, node_sizes, 'discrete', discrete_nodes);

for i=1:7
  bnet.CPD{i} = tabular_CPD(bnet, i);
end