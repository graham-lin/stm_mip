%Introducing ADV: a, denoting if path x is used
%The rows is 2 times ndv because for each ndv there are 2 constraints
% -Mx + a <= 0
% x - Ma <= 0


% -Mx + a <= 0
A_AdvIntro_a1 = zeros(nw.no_class*nw.no_path,ndv+nadv);
b_AdvIntro_a1 = zeros(nw.no_class*nw.no_path,1);

for m = 1:nw.no_class
    for p = 1:nw.no_path
        A_AdvIntro_a1((m-1)*nw.no_path+p, (m-1)*nw.no_path+p) = -M;  %x
        A_AdvIntro_a1((m-1)*nw.no_path+p, ndv+(m-1)*nw.no_path+p) = 1;% a
    end
end


% x - Ma <= 0
A_AdvIntro_a2 = zeros(nw.no_class*nw.no_path,ndv+nadv);
b_AdvIntro_a2 = zeros(nw.no_class*nw.no_path,1);

for m = 1:nw.no_class
    for p = 1:nw.no_path
        A_AdvIntro_a2((m-1)*nw.no_path+p, (m-1)*nw.no_path+p) = 1;  %x
        A_AdvIntro_a2((m-1)*nw.no_path+p, ndv+(m-1)*nw.no_path+p) = -M;% a
    end
end



A_AdvIntro_a = [A_AdvIntro_a1;A_AdvIntro_a2];
b_AdvIntro_a = [b_AdvIntro_a2;b_AdvIntro_a2];

if exist('A')
    A = [A' A_AdvIntro_a']';
    b = [b' b_AdvIntro_a']';
else
    A = A_AdvIntro_a;
    b = b_AdvIntro_a;
end
if debug_mode == 0
clear A_AdvIntro_a b_AdvIntro_a A_AdvIntro_a1 A_AdvIntro_a2 b_AdvIntro_a2 b_AdvIntro_a2
end