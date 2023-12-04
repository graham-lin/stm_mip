function c = BPR(x, nw, e, m)
link_length = nw.link_list(e, 3);
ffspeed =nw.link_list(e, 3+m);
capacity = nw.network.capacity(e);
alpha = 0.15;
beta = 4;

c = (link_length/ffspeed)*(1+alpha*(x/capacity).^beta);