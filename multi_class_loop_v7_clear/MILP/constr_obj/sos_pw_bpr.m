% 2 sets of sos because BPR value (weight) is class-specific.

sostype = '';
for n=1:nw.no_class*nw.no_link % number of sos constraint is nw.no_class*nw.no_link
    sostype = append(sostype, '2');
end

till_sosind = nw.ndv+nw.nadv - nw.no_class*nw.no_link*(nw.BPR_piece+1);
sosind = cell(1,nw.no_class*nw.no_link);
for m = 1:nw.no_class
    for i = 1:nw.no_link
        for l = 1:nw.BPR_piece+1
            sosind{(m-1)*nw.no_link+i} = ...
                [sosind{(m-1)*nw.no_link+i}; till_sosind + (m-1)*nw.no_link*(nw.BPR_piece+1) + (i-1)*(nw.BPR_piece+1) + l];
        end
    end
end


soswt = cell(1,nw.no_class*nw.no_link);
for m = 1:nw.no_class
    for i = 1:nw.no_link
        step_capa = nw.link_list(i,6) / nw.BPR_piece_l; % determine the step-length of link i
        for l = 1:nw.BPR_piece+1
            soswt{(m-1)*nw.no_link+i} = [soswt{(m-1)*nw.no_link+i}; step_capa*(l-1)];
        end
    end
end


% sos_sumbs;
% b_1 + b_2 + ... + b_L+1 = 1; for all m & e
Aeq_sos_sumbs = zeros(nw.no_class*nw.no_link, nw.ndv+nw.nadv);
beq_sos_sumbs = ones(nw.no_class*nw.no_link,1);

for m = 1:nw.no_class
    for e = 1:nw.no_link
        for l = 1:nw.BPR_piece+1
        Aeq_sos_sumbs((m-1)*nw.no_link+e, till_sosind + (m-1)*nw.no_link*(nw.BPR_piece+1) + (e-1)*(nw.BPR_piece+1) + l) = 1;
        end
    end
end

if exist('Aeq')
    Aeq = [Aeq;Aeq_sos_sumbs];
    beq = [beq;beq_sos_sumbs];
else 
    Aeq = Aeq_sos_sumbs;
    beq = beq_sos_sumbs;
end
% sos_sumx;
% x1b1 + x2b2 + ... + xL+1bL+1 = x^link_e;
Aeq_sos_sumx = zeros(nw.no_class*nw.no_link, nw.ndv+nw.nadv);
beq_sos_sumx = zeros(nw.no_class*nw.no_link,1);
for m = 1:nw.no_class
    for e = 1:nw.no_link
            step_capa = nw.link_list(e,6) / nw.BPR_piece_l;
            for l = 1:nw.BPR_piece+1
                Aeq_sos_sumx((m-1)*nw.no_link+e, ...
                                till_sosind+(m-1)*nw.no_link*(nw.BPR_piece+1) + (e-1)*(nw.BPR_piece+1) + l) ...
                                = step_capa*(l-1);%x_l
            end
            for m2 = 1:nw.no_class % link flow (e) = path flow (m,p)
                for p = 1:nw.no_path
                    Aeq_sos_sumx((m-1)*nw.no_link+e, (m-1)*nw.no_path+p) =...
                        -nw.path_list(p,e+2,m2)*nw.pce(m2);%x^link_e, aggregated link flows
                end
            end
    end
end
Aeq = [Aeq;Aeq_sos_sumx];
beq = [beq;beq_sos_sumx];


% sos_sumc; v5 modification: from equation to inequality
% BPR(x1)*b1 + BPR(x2)*b2 + ... BPR(xL+1)*bL+1 \in [c^link_me-, c^link_me+]

% BPR(x1)*b1 + BPR(x2)*b2 + ... BPR(xL+1)*bL+1 >= c^link_me*rho-
A_sos_sumc1 = zeros(nw.no_class*nw.no_link, nw.ndv+nw.nadv);
b_sos_sumc1 = zeros(nw.no_class*nw.no_link,1);
for m = 1:nw.no_class
    for e = 1:nw.no_link
        step_capa = nw.link_list(e,6) / nw.BPR_piece_l;
        for l = 1:nw.BPR_piece+1
                A_sos_sumc1((m-1)*nw.no_link+e, till_sosind+(m-1)*nw.no_link*(nw.BPR_piece+1) + (e-1)*(nw.BPR_piece+1) + l) = -BPR(step_capa*(l-1),nw,e,m);%BPR(x_l)
        end
        if m == 1
            A_sos_sumc1((m-1)*nw.no_link+e, till_clink+(m-1)*nw.no_link+e) = nw.network.spd_range_c1(e).*nw.network.spdlimit_c(e);%c^link_me-
        elseif m == 2
            A_sos_sumc1((m-1)*nw.no_link+e, till_clink+(m-1)*nw.no_link+e) = nw.network.spd_range_t1(e).*nw.network.spdlimit_t(e);%c^link_me-
        end
    end
end
if exist('A')
A = [A;A_sos_sumc1];
b = [b;b_sos_sumc1];
else
    A = A_sos_sumc1;
    b = b_sos_sumc1;
end
% BPR(x1)*b1 + BPR(x2)*b2 + ... BPR(xL+1)*bL+1 <= c^link_me*rho+
A_sos_sumc2 = zeros(nw.no_class*nw.no_link, nw.ndv+nw.nadv);
b_sos_sumc2 = zeros(nw.no_class*nw.no_link,1);
for m = 1:nw.no_class
    for e = 1:nw.no_link
        step_capa = nw.link_list(e,6) / nw.BPR_piece_l;
        for l = 1:nw.BPR_piece+1
                A_sos_sumc2((m-1)*nw.no_link+e, till_sosind+(m-1)*nw.no_link*(nw.BPR_piece+1) + (e-1)*(nw.BPR_piece+1) + l) = BPR(step_capa*(l-1),nw,e,m);%b_l*BPR(x_l)
        end
        if m == 1
            A_sos_sumc2((m-1)*nw.no_link+e, till_clink+(m-1)*nw.no_link+e) = -nw.network.spd_range_c2(e).*nw.network.spdlimit_c(e);%c^link_me+
        elseif m == 2
            A_sos_sumc2((m-1)*nw.no_link+e, till_clink+(m-1)*nw.no_link+e) = -nw.network.spd_range_t2(e).*nw.network.spdlimit_t(e);%c^link_me+
        end
    end
end
A = [A;A_sos_sumc2];
b = [b;b_sos_sumc2];