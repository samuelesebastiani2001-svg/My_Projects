function [residual, T_order, T] = static_resid(y, x, params, T_order, T)
if nargin < 5
    T_order = -1;
    T = NaN(12, 1);
end
[T_order, T] = NK_noK_CRS.sparse.static_resid_tt(y, x, params, T_order, T);
residual = NaN(19, 1);
    residual(1) = (1) - (params(1)*y(10)*1/y(6));
    residual(2) = (y(3)) - (T(1)*T(2));
    residual(3) = (y(1)) - (y(2)*y(16)/y(4));
    residual(4) = (y(11)) - (y(1));
    residual(5) = (y(5)) - (params(3)/(params(3)-1)*y(8)/y(9));
    residual(6) = (y(8)) - (y(1)*y(7)+y(8)*params(1)*params(4)*T(3));
    residual(7) = (y(9)) - (y(1)+y(9)*T(4));
    residual(8) = (y(4)) - (y(4)*params(4)*T(3)+(1-params(4))*y(5)^(-params(3)));
    residual(9) = (y(6)) - (T(5)^(1/(params(3)-1)));
    residual(10) = (y(7)) - (y(3)*(1-params(6))/y(16));
    residual(11) = (y(10)) - (T(6)*T(10)*exp(y(18)));
    residual(12) = (y(14)) - (T(11)*T(12));
    residual(13) = (y(12)) - (y(16)*y(13));
    residual(14) = (y(16)*(params(3)-1)/params(3)) - ((1-params(6))*y(14));
    residual(15) = (y(15)) - (y(12));
    residual(16) = (y(19)) - (y(11)/y(15));
    residual(17) = (log(y(16))) - (log(y(16))*params(11)+params(12)*x(1));
    residual(18) = (y(17)) - (y(17)*params(13)+params(14)*x(2));
    residual(19) = (y(18)) - (y(18)*params(15)+params(16)*x(3));
end
