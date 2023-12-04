%This function indicates the relation between c_mwp and x_mwp
Aeq_volume_time = zeros(ndv, ndv+nadv);
beq_volume_time = zeros(ndv, 1);
diag_a = zeros(nw.no_link, nw.no_link, nw.no_class);%diag matrix for cost coeficient a 
for m = 1:nw.no_class
    diag_a(:,:,m) = diag(link_cost_para(:,(2*m-1))); 
end
coex = zeros(nw.no_path, nw.no_path, nw.no_class);%Phi*diag_a*Phi.'
for m = 1:nw.no_class
    coex(:,:,m) = nw.path_list(:,3:2+nw.no_link)*diag_a(:,:,m)*nw.path_list(:,3:2+nw.no_link).';
end
coeb = zeros(nw.no_path,nw.no_class);
for m = 1:nw.no_class%coefficient for constant term (b)
    coeb(:,m) = nw.path_list(:,3:2+nw.no_link)*link_cost_para(:,2*m);
end

for m = 1:nw.no_class
    for p = 1:nw.no_path
        Aeq_volume_time((m-1)*nw.no_path+p, ndv*3+(m-1)*nw.no_path+p)=1;%c
        Aeq_volume_time((m-1)*nw.no_path+p, (m-1)*nw.no_path + p)= Aeq_volume_time((m-1)*nw.no_path+p, (m-1)*nw.no_path + p)...
            -pce(m).*sum(coex(:,p,m));%x^path
        beq_volume_time((m-1)*nw.no_path+p) = beq_volume_time((m-1)*nw.no_path+p)...
            + coeb(p,m);
    end
end

            
if exist('Aeq')
    Aeq = [Aeq' Aeq_volume_time']';
    beq = [beq' beq_volume_time']';
else 
    Aeq = Aeq_volume_time;
    beq = beq_volume_time;
end
if debug_mode == 0
clear Aeq_volume_time beq_volume_time
end