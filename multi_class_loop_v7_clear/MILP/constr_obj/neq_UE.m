%Specifies how c*_mw respond to a_mwp


%c_mwp - c*_mw >= 0
A_UE1 = zeros(nw.no_class*nw.no_path,ndv+nadv);
b_UE1 = zeros(nw.no_class*nw.no_path,1);
%if nw.path_list(p,[1, 2]) == nw.OD_list(w, [1, 2])
for m = 1:nw.no_class
    for p = 1:nw.no_path
        for w = 1:nw.no_OD
            for e = 1:nw.no_link
                if nw.path_list(p,(1:2),m) == nw.OD_list(w, (1:2))
                    A_UE1((m-1)*nw.no_path+p, till_cstar+ (m-1)*nw.no_OD+w) = 1; %c*_mw
                    A_UE1((m-1)*nw.no_path+p, till_clink+ (m-1)*nw.no_link+e) = -nw.path_list(p,e+2,m); %sum(c_link) = c_path
                end
            end
        end
    end
end

% c_mwp - c*mw <= M(1-a_mwp)
A_UE2 = zeros(nw.no_class*nw.no_path,ndv+nadv);
b_UE2 = zeros(nw.no_class*nw.no_path,1);

for m = 1:nw.no_class
    for p = 1:nw.no_path
        for e = 1:nw.no_link
            for w = 1:nw.no_OD
                if nw.path_list(p,(1:2),m) == nw.OD_list(w, (1:2))
                    A_UE2((m-1)*nw.no_path+p, ndv+(m-1)*nw.no_path+p) = Mc; %a_mwp
                    A_UE2((m-1)*nw.no_path+p, till_cstar+ (m-1)*nw.no_OD+w) = -1; %c*_mw
                    A_UE2((m-1)*nw.no_path+p, till_clink+ (m-1)*nw.no_link+e) = nw.path_list(p,e+2,m); %sum(c_link) = c_path
                    b_UE2((m-1)*nw.no_path+p) = Mc;
                end
            end  
        end
    end
end

%M(c_mwp - c*_mw) >= 1-a_mwp
A_UE3 = zeros(nw.no_class*nw.no_path,ndv+nadv);
b_UE3 = zeros(nw.no_class*nw.no_path,1);

for m = 1:nw.no_class
    for p = 1:nw.no_path
        for e = 1:nw.no_link
            for w = 1:nw.no_OD
                if nw.path_list(p,(1:2),m) == nw.OD_list(w, (1:2))
                    A_UE3((m-1)*nw.no_path+p, ndv+(m-1)*nw.no_path+p) = -1; %a_mwp
                    A_UE3((m-1)*nw.no_path+p, till_cstar+ (m-1)*nw.no_OD+w) = Mc; %c*_mw
                    A_UE3((m-1)*nw.no_path+p, till_clink+ (m-1)*nw.no_link+e) = -nw.path_list(p,e+2,m)*Mc; %sum(c_link) = c_path
                    b_UE3((m-1)*nw.no_path+p) = -1;
                end
            end
        end
    end
end

% A_UE = [A_UE1;A_UE2;A_UE3];
% b_UE = [b_UE1;b_UE2;b_UE3];

A_UE = [A_UE1;A_UE2]; % UE3 constraint is proved not necessary.
b_UE = [b_UE1;b_UE2];

if exist('A')
    A = [A' A_UE']';
    b = [b' b_UE']';
else
    A = A_UE;
    b = b_UE;
end
if debug_mode == 0
clear A_UE A_UE1 A_UE2 A_UE3 b_UE b_UE1 b_UE2 b_UE3
end