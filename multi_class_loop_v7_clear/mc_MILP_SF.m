% Version 7 13/12/2022
% Update the objective function to linear form
% demand * c*
% Now it's MILP instead of MIQP. Hooray!

% Version 6 22/9/2022
% Tested that Gurobi can solve non-convex MIQP.
% Post-processing results that shows the hidden decision on speed limit

% Version 5 29/8/2022
% Traffic managment:
% Adding speed limit as traffic management measure
% No DVs are added. Speed limit is added by means of relaxing some
% equalities to inequalities
% - Input files specifies the upper bound & lower bound of speed limit of
% each link
% - Add calculation after optimization to see how each link adapts their
% individual speed limit for each class.
% - Change objective function to sum up the class-specific utility
% - Now using Gurobi solver for non-convex (objective) MIQP

% Version 4 22/8/2022
% Add options to experiment in a single class setting.
% 


% Version 3 29/7/2022
% Add speed variation DVs as traffic management measures
% This becomes MIQCP, BPR is linearized by SOS2.
% The QC is believed to be non-concave (false). Solution: move it to
% objective function.
% Consider adding "indicator constraints" instead of big M method.
% 

% Version 2 - 8/7/2022
% Added SOS 2 to see if the code runs faster. (1:7 uses 78.2s)
% Debug in Agap calculation. Now the C_link value is correctly calculated.
%Try to code plug-and-play, to compare with original codes.
% Next step: add decision variable for traffic manangement
% Next step: put volume * cost at objective function (MIQP)

clear
addpath(genpath(pwd));
debug_mode = 1;%neq_UE only has c>=c* active
re_assign = 0;
%This is the entrance file for modulized, multi-class, UE STA. 
%The key toolbox used in this assignment is the mixed integer linear
%programming solver, Cplex

%% Initialization, building the constraints and the objective function
%Choose the input of network/demand specifications
% initialize_5nodes;%Load matrices and contain the format, calculate some basic parameters for optimization.
% initialize_4nodes;
% initialize_4nodes_1class;
initialize_SF;

%constraints
constraints;

%objective function
objective_function;
% objective_Q;
% Print empty network
plotNetwork(nw.node, nw.network, 'Tilburg network', 1);

%% This section solves the problem using OptiToolbox = scip
% Options
% opts = optiset('solver','scip','display','iter','maxnodes', 99999);

% Create OPTI Object
% Opt = opti('f',f,'bounds',lb,[],'xtype',xtype,'options',opts, 'ineq', A, b, 'eq', Aeq, beq, 'H', Q);
% Opt = opti('fun',f,'bounds',lb,[],'xtype',xtype,'options',opts, 'ineq', A, b, 'eq', Aeq, beq, 'mix', A_mix, cl, cu)

% Solve the MILP/MINLP problem
% [x,fval,exitflag,info] = solve(Opt);

%% This section solves the problem using Cplex
% if ~ exist('sostype')
%     sostype = []; sosind = []; soswt = [];
% end
% options = cplexoptimset('cplex');
% options.mip.tolerances.mipgap= 0.0001 ; % 0-1 default 0.0001
% % [x,fval,exitflag,output] = cplexmilp(f,A,b,Aeq,beq,sostype,sosind,soswt,lb,[],xtype,[],options)
% 
% cplex_model = Cplex('STA_SOS');
% cplex_model.Model.sense = 'minimize';
% % cplex.addCols(f, A, lb, ub, xtype);
% % cplex.addRows(lhs, A, rhs, rowname);
% % cplex.addSOSs (type, ind, wt, name);
% cplex_model.Model.lb = lb;
% cplex_model.Model.ub = ones(length(lb),1)*inf;
% cplex_model.Model.obj = f;
% cplex_model.Model.A = [Aeq; A];
% [Ah Aw] = size(A); 
% cplex_model.Model.lhs = [beq;ones(Ah,1)*-inf];
% cplex_model.Model.rhs = [beq;b];
% cplex_model.Model.ctype = xtype;
% cplex_model.Model.Q = Q;
% cplex_model.Param.optimalitytarget.Cur = 3; % Solving non-convex obj fun
% sos.wt = soswt;
% sos.ind= sosind;
% sos.type= sostype;
% for i = 1:1
%     cplex_model.addSOSs('22',{[1121; 1122; 1123; 1124; 1125] [1126; 1127; 1128; 1129; 1110]},{[35 36 40 62 120]' [35 36 40 62 120]'});
% end
% cplex_model.addSOSs(sostype,sosind,soswt);
% cplex_model.solve();



% fprintf ('\nSolution status = %s\n', cplex_model.Solution.statusstring);
% 
% fprintf    ('\n   Cost = %f\n', cplex_model.Solution.objval);
% x = cplex_model.Solution.x;

%% Solving the problem using Gurobi
% names = {'x', 'y', 'z'};
% model.varnames = names;
% model.Q = sparse(Q);
model.A = sparse([Aeq;A]);
model.obj = f;
model.rhs = [beq;b];
% model.lhs
[d1_Aeq, d2_Aeq] = size(Aeq); [d1_A, d2_A] = size(A);
sense = '';
for i = 1:d1_Aeq
    sense = [sense, '='];
end
for i = 1:d1_A
    sense = [sense, '<'];
end
model.sense = sense;
model.vtype = xtype;
% gurobi_write(model, 'qp.lp');
sos_length = length(sosind);

for i = 1:sos_length
    model.sos(i).type   = 2;
    model.sos(i).index  = cell2mat(sosind(i))';
    model.sos(i).weight = cell2mat(soswt(i))';
end
% params.nonconvex = 2;
params.timelimit = 2000;
solutionx = gurobi(model, params);
% solutionx = gurobi(model);
x = solutionx.x;
%% This section displays the solutions
show_results_mc;


%% Calculate link / path costs using BPR and link flows
x_link_total = zeros(nw.no_link,1);
for m = 1:nw.no_class
    x_link_total = x_link_total + x_link(:,m).*nw.pce(m);
end


real_link_cost = zeros(nw.no_link, nw.no_class);%This is designed for 2 classes
for l = 1:nw.no_link
    real_link_cost(l, 1) = nw.network.length(l)/rho(l,1)*(1+0.15*(x_link_total(l)/nw.network.capacity(l)).^4);%Car
    if no_class >= 2
    real_link_cost(l, 2) = nw.network.length(l)/rho(l,2)*(1+0.15*(x_link_total(l)/nw.network.capacity(l)).^4);%Truck
    end
end
real_path_cost = zeros(nw.no_path, nw.no_class);
for p = 1:nw.no_path
    for l = 1:nw.no_link
            real_path_cost(p,1) = real_path_cost(p,1) + real_link_cost(l,1)*nw.path_list(p,2+l,1);%car
            if no_class >= 2
            real_path_cost(p,2) = real_path_cost(p,2) + real_link_cost(l,2)*nw.path_list(p,2+l,2);%truck
            end
    end
end
for m = 1:nw.no_class
    results(:,6+m) = real_path_cost(:,m);
end

%% added in V6 Total veh*hour car and veh*hour truck
vh = zeros(1, nw.no_class);
for m = 1:nw.no_class
    vh(m) = sum(results(:,m).*results(:,m+6));
end
vot = [9 38];
vh_value = vh.*vot; % vechicle*hour*VOT
vh_value_total = sum(vh_value);
%% Visualize
% fig = plotLoadedLinks(nw.node,nw.network,round(x_link_total),true,[],[],[],'UE total flow');
fig2 = plotLoadedLinks(nw.node,nw.network,round(x_link(:,1)),true,[],[],[],'UE car flow (STM)');
fig3 = plotLoadedLinks(nw.node,nw.network,round(x_link(:,2)),true,[],[],[],'UE truck flow (STM)');
MILP_cal_Agap;


%% Looping for next round
% pre_assign = link_costff_postassignment;
% save('pre_assign.mat', 'pre_assign');