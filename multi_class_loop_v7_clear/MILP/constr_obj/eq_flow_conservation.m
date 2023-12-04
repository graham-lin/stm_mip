%Equality constraint: flow conservation

Aeq_flow_conservation = zeros(nw.no_class*nw.no_OD,ndv+nadv);
beq_flow_conservation = zeros(nw.no_class*nw.no_OD, 1 );
for c = 1:nw.no_class%Scan each class
    for p = 1:nw.no_OD%Scan each OD
        for q = 1:nw.no_path%Scan each path
            if nw.path_list(q,[1, 2],c) == nw.OD_list(p, [1, 2])%see if path q is between OD p
                Aeq_flow_conservation((c-1)*nw.no_OD+p,(c-1)*nw.no_path+q) = 1;%
                %                      Constraint No.   DV No.
            end
        end
    end
end
for c = 1:nw.no_class
    for p = 1:nw.no_OD
        beq_flow_conservation((c-1)*nw.no_OD+p) = nw.OD_list(p,2+c);
    end
end

if exist('Aeq')
    Aeq = [Aeq' Aeq_flow_conservation']';
    beq = [beq' beq_flow_conservation']';
else
    Aeq = Aeq_flow_conservation;
    beq = beq_flow_conservation;
end
if debug_mode == 0
clear Aeq_flow_conservation beq_flow_conservation
end