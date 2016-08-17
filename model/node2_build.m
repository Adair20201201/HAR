function  bnet = node2_build()
%% Common parameter 
ss = 3;
intra = zeros(ss);
intra(1,[2,3]) = 1;
intra(2,3) = 1;

inter = zeros(ss);
inter(1,1) = 1;

onodes = 3;
dnodes = [1,2];

ns = [9,2,9];
eclass1 = [1 2 3];
eclass2 = [4 2 3];
%eclass2 = [1 2 3];
eclass = [eclass1 eclass2];
%% ==================== Node two ===================== %%
 bnet = mk_dbn(intra, inter, ns, 'discrete', dnodes,'eclass1', eclass1, 'eclass2', eclass2);
 bnet.CPD{1} = tabular_CPD(bnet,1);
 bnet.CPD{2} = tabular_CPD(bnet,2);
 bnet.CPD{3} = gaussian_CPD(bnet, 3);
 bnet.CPD{4} = tabular_CPD(bnet,4);