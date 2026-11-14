function residual = static_resid(T, y, x, params, T_flag)
% function residual = static_resid(T, y, x, params, T_flag)
%
% File created by Dynare Preprocessor from .mod file
%
% Inputs:
%   T         [#temp variables by 1]  double   vector of temporary terms to be filled by function
%   y         [M_.endo_nbr by 1]      double   vector of endogenous variables in declaration order
%   x         [M_.exo_nbr by 1]       double   vector of exogenous variables in declaration order
%   params    [M_.param_nbr by 1]     double   vector of parameter values in declaration order
%                                              to evaluate the model
%   T_flag    boolean                 boolean  flag saying whether or not to calculate temporary terms
%
% Output:
%   residual
%

if T_flag
    T = NK_noK_CRS.static_resid_tt(T, y, x, params);
end
residual = zeros(19, 1);
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
