
clear
addpath(genpath(pwd));


nw.network = readtable('SiouxFall_network.txt');
nw.demand = readtable('SiouxFall_Demand_manual.txt');
nw.node = readtable('SiouxFall_Node.txt');

fig = plotLoadedLinks(nw.node,nw.network,round(nw.network.capacity),true,[],[],[],'Link Capacity');