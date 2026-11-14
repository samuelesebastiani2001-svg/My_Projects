function [residual, T_order, T] = dynamic_resid(y, x, params, steady_state, T_order, T)
if nargin < 6
    T_order = -1;
    T = NaN(19, 1);
end
[T_order, T] = NK_noK_CRS.sparse.dynamic_resid_tt(y, x, params, steady_state, T_order, T);
residual = NaN(19, 1);
    residual(1) = (1) - (T(4)*T(5));
    residual(2) = (y(22)) - (T(6)*T(7));
    residual(3) = (y(20)) - (y(21)*y(35)/y(23));
    residual(4) = (y(30)) - (y(20));
    residual(5) = (y(24)) - (params(3)/(params(3)-1)*y(27)/y(28));
    residual(6) = (y(27)) - (y(20)*y(26)+T(8)*T(9)*y(46));
    residual(7) = (y(28)) - (y(20)+T(8)*T(10)*y(47));
    residual(8) = (y(23)) - (T(11)*y(4)+(1-params(4))*y(24)^(-params(3)));
    residual(9) = (y(25)) - (T(12)^(1/(params(3)-1)));
    residual(10) = (y(26)) - (y(22)*(1-params(6))/y(35));
    residual(11) = (y(29)) - (T(13)*T(17)*exp(y(37)));
    residual(12) = (y(33)) - (T(18)*T(19));
    residual(13) = (y(31)) - (y(35)*y(32));
    residual(14) = (y(35)*(params(3)-1)/params(3)) - ((1-params(6))*y(33));
    residual(15) = (y(34)) - (y(31));
    residual(16) = (y(38)) - (y(30)/y(34));
    residual(17) = (log(y(35))) - (params(11)*log(y(16))+params(12)*x(1));
    residual(18) = (y(36)) - (params(13)*y(17)+params(14)*x(2));
    residual(19) = (y(37)) - (params(15)*y(18)+params(16)*x(3));
end
