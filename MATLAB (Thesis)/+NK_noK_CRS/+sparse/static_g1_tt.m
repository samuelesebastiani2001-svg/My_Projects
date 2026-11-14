function [T_order, T] = static_g1_tt(y, x, params, T_order, T)
if T_order >= 1
    return
end
[T_order, T] = NK_noK_CRS.sparse.static_resid_tt(y, x, params, T_order, T);
T_order = 1;
if size(T, 1) < 15
    T = [T; NaN(15 - size(T, 1), 1)];
end
T(13) = getPowerDeriv(y(6),params(3),1);
T(14) = getPowerDeriv(T(9),1-params(9),1);
T(15) = getPowerDeriv(y(11)/y(15),params(8),1);
end
