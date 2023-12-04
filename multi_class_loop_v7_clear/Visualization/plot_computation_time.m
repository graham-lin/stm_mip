xsos = [20 40 80 120 140 158 170 180 216 219];
ysos = [0.11 1.83 3.92 30.45 66.91 257.31 337.39 675 1354 12410];
ysoslog = log10(ysos);

xori = [20 40 60 80 100 126 131];
yori = [0.187 6.08 20.67 73.84 374.34 4615 24231];
yorilog = log10(yori);

% plot(xori, yori, 'b-*','LineWidth',1.5);hold on
% plot(xsos, ysos, 'r-x','LineWidth',1.5);

plot(xori, yorilog, 'b-*','LineWidth',1.5);hold on
plot(xsos, ysoslog, 'r-x','LineWidth',1.5);

xlabel('Number of OD pairs');
ylabel('Computation time (log10)');

legend('MILP','MILP-SOS','Location','northwest')