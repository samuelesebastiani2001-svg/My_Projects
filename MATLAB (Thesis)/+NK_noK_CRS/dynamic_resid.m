function residual = dynamic_resid(T, y, x, params, steady_state, it_, T_flag)
% function residual = dynamic_resid(T, y, x, params, steady_state, it_, T_flag)
%
% File created by Dynare Preprocessor from .mod file
%
% Inputs:
%   T             [#temp variables by 1]     double   vector of temporary terms to be filled by function
%   y             [#dynamic variables by 1]  double   vector of endogenous variables in the order stored
%                                                     in M_.lead_lag_incidence; see the Manual
%   x             [nperiods by M_.exo_nbr]   double   matrix of exogenous variables (in declaration order)
%                                                     for all simulation periods
%   steady_state  [M_.endo_nbr by 1]         double   vector of steady state values
%   params        [M_.param_nbr by 1]        double   vector of parameter values in declaration order
%   it_           scalar                     double   time period for exogenous variables for which
%                                                     to evaluate the model
%   T_flag        boolean                    boolean  flag saying whether or not to calculate temporary terms
%
% Output:
%   residual
%

if T_flag
    T = NK_noK_CRS.dynamic_resid_tt(T, y, x, params, steady_state, it_);
end
residual = zeros(19, 1);
    residual(1) = (1) - (T(4)*T(5));
    residual(2) = (y(8)) - (T(6)*T(7));
    residual(3) = (y(6)) - (y(7)*y(21)/y(9));
    residual(4) = (y(16)) - (y(6));
    residual(5) = (y(10)) - (params(3)/(params(3)-1)*y(13)/y(14));
    residual(6) = (y(13)) - (y(6)*y(12)+T(8)*T(9)*y(27));
    residual(7) = (y(14)) - (y(6)+T(8)*T(10)*y(28));
    residual(8) = (y(9)) - (T(11)*y(1)+(1-params(4))*y(10)^(-params(3)));
    residual(9) = (y(11)) - (T(12)^(1/(params(3)-1)));
    residual(10) = (y(12)) - (y(8)*(1-params(6))/y(21));
    residual(11) = (y(15)) - (T(13)*T(17)*exp(y(23)));
    residual(12) = (y(19)) - (T(18)*T(19));
    residual(13) = (y(17)) - (y(21)*y(18));
    residual(14) = (y(21)*(params(3)-1)/params(3)) - ((1-params(6))*y(19));
    residual(15) = (y(20)) - (y(17));
    residual(16) = (y(24)) - (y(16)/y(20));
    residual(17) = (log(y(21))) - (params(11)*log(y(3))+params(12)*x(it_, 1));
    residual(18) = (y(22)) - (params(13)*y(4)+params(14)*x(it_, 2));
    residual(19) = (y(23)) - (params(15)*y(5)+params(16)*x(it_, 3));

end
