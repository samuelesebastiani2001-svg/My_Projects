function [T_order, T] = static_resid_tt(y, x, params, T_order, T)
if T_order >= 0
    return
end
T_order = 0;
if size(T, 1) < 12
    T = [T; NaN(12 - size(T, 1), 1)];
end
T(1) = params(17)*y(2)^params(5);
T(2) = y(1)^params(2);
T(3) = y(6)^params(3);
T(4) = params(1)*params(4)*y(6)^(params(3)-1);
T(5) = (1-(1-params(4))*y(5)^(1-params(3)))/params(4);
T(6) = y(10)^params(9);
T(7) = params(10)*y(6)^params(7);
T(8) = (y(11)/y(15))^params(8);
T(9) = T(7)*T(8);
T(10) = T(9)^(1-params(9));
T(11) = params(17)*y(13)^params(5);
T(12) = y(12)^params(2);
end
