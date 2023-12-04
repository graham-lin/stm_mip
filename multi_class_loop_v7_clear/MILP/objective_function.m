%This document sets the objective function.
f = zeros(ndv+nadv,1);

% Updated v7: Demand * Cstar instead of the quadratic c*x 
for m = 1:nw.no_class
    for w = 1:nw.no_OD
        f(till_cstar + nw.no_OD*(m-1)+w) = f(till_cstar + nw.no_OD*(m-1)+w) + nw.xi(m)*nw.demand{w,2+m};
    end
end

% f(ndv*2+1:ndv*3) = ones(ndv,1);