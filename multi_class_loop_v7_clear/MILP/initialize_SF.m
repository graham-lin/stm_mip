%The initialization loads data and feeds it to the constraint-building
%process.
mu = 1; alpha = 0.15; beta = 4;
nw.BPR_piece_l = 1; nw.BPR_piece_r = 4;nw.BPR_piece = nw.BPR_piece_l+nw.BPR_piece_r;
nw.pce = [1 2.5];
test_id = [1:10];% Partially considering the network demand
k_paths = 3; 
no_class = 2; % Number of classes

% Number of Paths between Each OD
% path_vector =  [8;6;1;6;2;2];%Hard coded, 6 OD pair
nw.xi = [9, 38];
no_OD_on = length(test_id);
path_vector =  ones(no_OD_on,1).*k_paths;
%Load network
nw.network = readtable('Tilburg_Network.txt');
nw.demand = readtable('Tilburg_Demand.txt');
nw.node = readtable('Tilburg_Node.txt');
nw.network.spd_range_c1(:) = 0.4;
nw.network.spd_range_c2(:) = 1.1; % regulates the upper bound of designed speed limit

% nw.network = readtable('SiouxFall_network.txt');
% nw.demand = readtable('SiouxFall_Demand_manual.txt');
% nw.node = readtable('SiouxFall_Node.txt');
nw.network.spdlimit_c = nw.network.spdlimit_c;
nw.network.spdlimit_t = nw.network.spdlimit_t;

nw.node.Properties.VariableNames{1} = 'id';
nw.network.id = [1:length(nw.network.fromNode)]';

%Start:Scale better
Scale_factor = 1;

nw.demand.demand_c = nw.demand.demand_c.*Scale_factor;
nw.demand.demand_t = nw.demand.demand_t.*Scale_factor;
%End:Scale better


nw.link_list = [nw.network.fromNode,...
                nw.network.toNode,...
                nw.network.length,...
                nw.network.spdlimit_c,...
                nw.network.spdlimit_t,...
                nw.network.capacity];
nw.no_link = length(nw.link_list(:,1));
nw.no_node = max(nw.link_list(:,1));
nw.OD_list = [nw.demand.fromNode(test_id),nw.demand.toNode(test_id),nw.demand.demand_c(test_id),nw.demand.demand_t(test_id)];
% nw.no_class = length(nw.OD_list(1,:))-2;
nw.no_class = no_class;

%% Calculate Path List from Kth-Dijkstra

source = nw.demand.fromNode(test_id);
destination = nw.demand.toNode(test_id);
% nw.no_desti = length(unique(destination));
% Shortest paths for car
shortestPaths_c = cell(no_OD_on, max(path_vector));
link_costff_c = ones(nw.no_node, nw.no_node)*inf;

for i = 1:nw.no_node
    for j = 1:nw.no_node
        for m = 1:nw.no_link
            if i == nw.network.fromNode(m) && j == nw.network.toNode(m)
                link_costff_c(i,j) = nw.network.length(m) ./ nw.network.spdlimit_c(m);
            end
        end
    end
end
if re_assign == 0
    for w = 1:no_OD_on
        [shortestPaths_c(w,1:path_vector(w)), totalCosts(w,1:path_vector(w))] = kShortestPath(link_costff_c, source(w), destination(w), path_vector(w));
    end
elseif re_assign == 1
    load('pre_assign');
    for w = 1:no_OD_on
        [shortestPaths_c(w,1:path_vector(w)), totalCosts(w,1:path_vector(w))] = kShortestPath(pre_assign, source(w), destination(w), path_vector(w));
    end
end

%
% Shortest paths for truck
shortestPaths_t = cell(no_OD_on, max(path_vector));
link_costff_t = ones(nw.no_node, nw.no_node)*inf;

for i = 1:nw.no_node
    for j = 1:nw.no_node
        for m = 1:nw.no_link
            if i == nw.network.fromNode(m) && j == nw.network.toNode(m)
                link_costff_t(i,j) = nw.network.length(m) ./ nw.network.spdlimit_t(m);
            end
        end
    end
end
if re_assign == 0
    for w = 1:no_OD_on
        [shortestPaths_t(w,1:path_vector(w)), totalCosts(w,1:path_vector(w))] = kShortestPath(link_costff_t, source(w), destination(w), path_vector(w));
    end
elseif re_assign == 1
    load('pre_assign');
    for w = 1:no_OD_on
        [shortestPaths_t(w,1:path_vector(w)), totalCosts(w,1:path_vector(w))] = kShortestPath(pre_assign, source(w), destination(w), path_vector(w));
    end
end
%% Fit the found shortestPaths into the nw.path_list_c for cars
nw.path_list_c = [];
for w = 1:no_OD_on
        for p = 1:path_vector(w)
            if isempty(nw.path_list_c)
                nw.path_list_c = [nw.demand.fromNode(test_id(w)) nw.demand.toNode(test_id(w)) zeros(1,nw.no_link)];
            else
                nw.path_list_c = [nw.path_list_c; [nw.demand.fromNode(test_id(w)) nw.demand.toNode(test_id(w)) zeros(1, nw.no_link)]];
            end
        end
%     end
end
for w = 1:no_OD_on
        for p = 1:path_vector(w)
            for r = 1:length(shortestPaths_c{w,p})-1
                for l = 1:nw.no_link
                	if nw.network.fromNode(l) == shortestPaths_c{w,p}(r) && nw.network.toNode(l) == shortestPaths_c{w,p}(r+1)
                        nw.path_list_c(sum(path_vector(1:w-1))+p,2 + nw.network.id(l))=1;
                    end
                end
            end
        end
%     end
end
nw.no_path = sum(path_vector(1:no_OD_on));

% nw.no_OD = no_OD_on;


%% Fit the found shortest paths to nw.path_list_t for trucks
nw.path_list_t = [];
for w = 1:no_OD_on
        for p = 1:path_vector(w)
            if isempty(nw.path_list_t)
                nw.path_list_t = [nw.demand.fromNode(test_id(w)) nw.demand.toNode(test_id(w)) zeros(1,nw.no_link)];
            else
                nw.path_list_t = [nw.path_list_t; [nw.demand.fromNode(test_id(w)) nw.demand.toNode(test_id(w)) zeros(1, nw.no_link)]];
            end
        end
%     end
end
for w = 1:no_OD_on
        for p = 1:path_vector(w)
            for r = 1:length(shortestPaths_t{w,p})-1
                for l = 1:nw.no_link
                	if nw.network.fromNode(l) == shortestPaths_t{w,p}(r) && nw.network.toNode(l) == shortestPaths_t{w,p}(r+1)
                        nw.path_list_t(sum(path_vector(1:w-1))+p,2 + nw.network.id(l))=1;
                    end
                end
            end
        end
%     end
end
% nw.no_path_t = sum(path_vector(1:no_OD_on));
nw.no_OD = no_OD_on;


% nw.no_path = nw.no_path_c;
nw.path_list(:,:,1) = nw.path_list_c;
nw.path_list(:,:,2) = nw.path_list_t;
