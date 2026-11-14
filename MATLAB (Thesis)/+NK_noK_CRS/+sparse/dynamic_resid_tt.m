function [T_order, T] = dynamic_resid_tt(y, x, params, steady_state, T_order, T)
if T_order >= 0
    return
end
T_order = 0;
if size(T, 1) < 19
    T = [T; NaN(19 - size(T, 1), 1)];
end
T(1) = exp(y(55))/exp(y(36));
T(2) = params(1)*y(29)*T(1);
T(3) = (y(39)/y(20))^(-params(2));
T(4) = T(2)*T(3);
T(5) = 1/y(44);
T(6) = params(17)*y(21)^params(5);
T(7) = y(20)^params(2);
T(8) = T(1)*params(1)*params(4)*y(20)/y(39);
T(9) = y(44)^params(3);
T(10) = y(44)^(params(3)-1);
T(11) = params(4)*y(25)^params(3);
T(12) = (1-(1-params(4))*y(24)^(1-params(3)))/params(4);
T(13) = y(10)^params(9);
T(14) = params(10)*y(25)^params(7);
T(15) = (y(30)/y(34))^params(8);
T(16) = T(14)*T(15);
T(17) = T(16)^(1-params(9));
T(18) = params(17)*y(32)^params(5);
T(19) = y(31)^params(2);
end
