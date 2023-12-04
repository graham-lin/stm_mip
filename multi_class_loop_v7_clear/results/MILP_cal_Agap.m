%% AGap on original paths
total_miss_assign_original = 0;
for m = 1:nw.no_class
    for w = 1:nw.no_OD
        for p = 1:path_vector(w)
           total_miss_assign_original = total_miss_assign_original...
               + results(sum(path_vector(1:w-1))+p,m)*nw.pce(m)*...% x_path
                    (results(sum(path_vector(1:w-1))+p,2*nw.no_class+m)-... c_path
                        min(results(sum(path_vector(1:w-1))+1:sum(path_vector(1:w)),2*nw.no_class+m))); % c_*
        end
    end
end

%% AGap with Real costs
total_miss_assign_real_cost = 0;
for m = 1:nw.no_class
    for w = 1:nw.no_OD
        for p = 1:path_vector(w) % select paths in OD pair w
           total_miss_assign_real_cost = total_miss_assign_real_cost...
               + results(sum(path_vector(1:w-1))+p,m)*nw.pce(m)*... % pi_m*X_mwp
               (real_path_cost(sum(path_vector(1:w-1))+p,m)-min(real_path_cost(sum(path_vector(1:w-1))+1:sum(path_vector(1:w)),m)));
        end
    end
end





%% AGap on re-assigned paths
%Shortest pash post assignment
link_costff_postassignment = ones(nw.no_node, nw.no_node)*inf;
for i = 1:nw.no_node
    for j = 1:nw.no_node
        for m = 1:nw.no_link
            if i == nw.network.fromNode(m) && j == nw.network.toNode(m)
                link_costff_postassignment(i,j) = real_link_cost(m,1);
            end
        end
    end
end

for w = 1:height(nw.demand)
    [shortestPaths_post(w,:), totalCosts_post(w,:)] = kShortestPath(link_costff_postassignment, nw.demand.fromNode(w), nw.demand.toNode(w), 1);
end

%Shortest path on nodes => shortest paths on links
shortestPaths_post_link = cell(height(nw.demand),1);
for w = 1:height(nw.demand)
    for k = 1:1
        for n = 1:numel(shortestPaths_post{w,k})-1
            for id = 1:height(nw.network)
                if nw.network.fromNode(id) == shortestPaths_post{w,k}(n)
                    if nw.network.toNode(id) == shortestPaths_post{w,k}(n+1)
                       shortestPaths_post_link{w,k} =  [shortestPaths_post_link{w,k} id];
                    end
                end
            end
        end
    end
end

% Shortest path cost
%% Kth Shortest Path Post Link => Path Costs
%Adding all link costs from the shortest path,
%K-Dijkstra could be inaccurate 
sppl=shortestPaths_post_link;
shortest_path_cost = zeros(no_OD_on, nw.no_class);
for m = 1:nw.no_class
    for w = 1:no_OD_on

            for e = 1:numel(sppl{w,1})
                shortest_path_cost(w,m) = shortest_path_cost(w,m)...
                    + real_link_cost(sppl{w,1}(e),m);
            end

    end
end

%Total miss schedule
total_miss_schedule = 0;
for m = 1:nw.no_class
    for w = 1:nw.no_OD
        for k = 1:path_vector(w)
            total_miss_schedule = total_miss_schedule...
                                 + (real_path_cost(sum(path_vector(1:w-1))+k,m)*nw.pce(m)...
                                 - shortest_path_cost(w,m)*nw.pce(m))*...
                                 results(sum(path_vector(1:w-1))+k,m);
        end
    end
end


%Calculate total flow
total_flow=0;
for m = 1:nw.no_class
    total_flow = total_flow+sum(results(:,m))*nw.pce(m);
end
%Calculate AGap
agap = total_miss_schedule / total_flow;
agap_ori = total_miss_assign_original / total_flow;
agap_real= total_miss_assign_real_cost/ total_flow;