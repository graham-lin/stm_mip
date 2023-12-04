%This file introduces constraints

%Number of DV(x)(C)
ndv = nw.no_class*nw.no_path;% 
%ADV:a_mwp(C),c*_mw(C),c_me^link_(C),b_me^l-1(B)
nadv= ndv + ... %a_mwp(B)
    nw.no_class*nw.no_OD + ...%c*_mw(C)
    nw.no_class*nw.no_link + ... %c_me^link(C) 
    nw.no_class*nw.no_link*(nw.BPR_piece+1); %bs_me^l(C) SOS for BPR PW selector 
nw.ndv = ndv;
nw.nadv = nadv;
lb = zeros(ndv+nadv,1);
ub = ones(ndv+nadv,1)*inf;


M = 300000;Mc = 500000;
till_clink = 2*ndv+nw.no_class*nw.no_OD;
till_cstar = 2*ndv;
% Continuous/Binary DVs
xtype = '';
for k = 1:ndv %x
    xtype = append(xtype, 'C');
end
for k = 1:ndv %a
    xtype = append(xtype, 'B');
end   
for k = 1:nw.no_class*nw.no_OD % c*
    xtype = append(xtype, 'C');
end
for k = 1:nw.no_class*nw.no_link %c^link
    xtype = append(xtype, 'C');
end
for k = 1:nw.no_class*nw.no_link*(nw.BPR_piece+1)
    xtype = append(xtype, 'C');%bs_e^l
end
%% Functional constraints
%Flow conservation for each class
eq_flow_conservation;

%Introducing auxillary DV *a*
neq_AdvIntro_a;% -Mx + a <= 0; x - Ma <= 0

%UE condition with C*
neq_UE;%c_mwp - c*_mw >= 0; % c_mwp - c*mw <= M(1-a_mwp); %M(c_mwp - c*_mw) >= 1-a_mwp


%% This part is for adding SOS2
sos_pw_bpr;

%% This part is for debugging
if ~exist('Aeq')
    Aeq = [];
    beq = [];
end

if ~exist('A')
    A = [];
    b = [];
end