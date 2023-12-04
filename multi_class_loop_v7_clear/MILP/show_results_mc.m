%
%% x_path => x_link, link flow is aggreggated
x_link = zeros(nw.no_link,nw.no_class);

for m = 1:nw.no_class
    for p = 1:nw.no_path
        for e = 1:nw.no_link
            x_link(e,m) = x_link(e,m) + nw.path_list(p,e+2,m)*x((m-1)*nw.no_path+p);
        end
    end
end

%% Results matrix
results = zeros(nw.no_path, 4*nw.no_class+2);
results(:,1:2*nw.no_class) = reshape(x(1:2*ndv), [nw.no_path, 2*nw.no_class]);%path flow and a
% till_clink = 3*ndv + nw.no_class*nw.no_OD;
for p = 1:nw.no_path % path cost by class?
    for m = 1:nw.no_class
        for e = 1:nw.no_link
            results(p,4+m) = results(p,4+m) + x(till_clink+(m-1)*nw.no_link+e)*nw.path_list(p,e+2,m);
        end
    end
end


%% added in V6: calculate speed limit for each link, each mode
rho = zeros(nw.no_link,nw.no_class);
for e = 1:nw.no_link
    step_capa = nw.link_list(e,6) / nw.BPR_piece_l;
    for m = 1:nw.no_class
        for l = 1:nw.BPR_piece+1
            rho(e,m) = rho(e,m) + (BPR(step_capa*(l-1),nw,e,m) * x(till_sosind+(m-1)*nw.no_link*(nw.BPR_piece+1) + (e-1)*(nw.BPR_piece+1) + l) / x(till_clink+(m-1)*nw.no_link+e));
        end
    end
end



%% added in V6: calculate speed limit percent for each link (car) and visualize
fig3 = plotLinksSpeedLimitChange(nw.node,nw.network,round((rho(:,1)./nw.network.spdlimit_c-1)*100),true,[],[],[],'Optimal Speed Limit Change in %');