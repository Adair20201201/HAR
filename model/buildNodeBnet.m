function bnetParameter = buildNodeBnet(nodeName)
nodeSample = strcat(nodeName,'_build');
bnetParameter = feval(nodeSample);