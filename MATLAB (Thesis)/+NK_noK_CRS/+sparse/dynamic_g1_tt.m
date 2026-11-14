function [T_order, T] = dynamic_g1_tt(y, x, params, steady_state, T_order, T)
if T_order >= 1
    return
end
[T_order, T] = NK_noK_CRS.sparse.dynamic_resid_tt(y, x, params, steady_state, T_order, T);
T_order = 1;
if size(T, 1) < 23
    T = [T; NaN(23 - size(T, 1), 1)];
end
T(20) = getPowerDeriv(y(39)/y(20),(-params(2)),1);
T(21) = getPowerDeriv(T(16),1-params(9),1);
T(22) = getPowerDeriv(y(30)/y(34),params(8),1);
T(23) = (-(exp(y(55))*exp(y(36))))/(exp(y(36))*exp(y(36)));
end
