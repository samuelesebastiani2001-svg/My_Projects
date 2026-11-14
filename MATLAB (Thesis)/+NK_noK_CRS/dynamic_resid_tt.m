function T = dynamic_resid_tt(T, y, x, params, steady_state, it_)
% function T = dynamic_resid_tt(T, y, x, params, steady_state, it_)
%
% File created by Dynare Preprocessor from .mod file
%
% Inputs:
%   T             [#temp variables by 1]     double  vector of temporary terms to be filled by function
%   y             [#dynamic variables by 1]  double  vector of endogenous variables in the order stored
%                                                    in M_.lead_lag_incidence; see the Manual
%   x             [nperiods by M_.exo_nbr]   double  matrix of exogenous variables (in declaration order)
%                                                    for all simulation periods
%   steady_state  [M_.endo_nbr by 1]         double  vector of steady state values
%   params        [M_.param_nbr by 1]        double  vector of parameter values in declaration order
%   it_           scalar                     double  time period for exogenous variables for which
%                                                    to evaluate the model
%
% Output:
%   T           [#temp variables by 1]       double  vector of temporary terms
%

assert(length(T) >= 19);

T(1) = exp(y(29))/exp(y(22));
T(2) = params(1)*y(15)*T(1);
T(3) = (y(25)/y(6))^(-params(2));
T(4) = T(2)*T(3);
T(5) = 1/y(26);
T(6) = params(17)*y(7)^params(5);
T(7) = y(6)^params(2);
T(8) = T(1)*params(1)*params(4)*y(6)/y(25);
T(9) = y(26)^params(3);
T(10) = y(26)^(params(3)-1);
T(11) = params(4)*y(11)^params(3);
T(12) = (1-(1-params(4))*y(10)^(1-params(3)))/params(4);
T(13) = y(2)^params(9);
T(14) = params(10)*y(11)^params(7);
T(15) = (y(16)/y(20))^params(8);
T(16) = T(14)*T(15);
T(17) = T(16)^(1-params(9));
T(18) = params(17)*y(18)^params(5);
T(19) = y(17)^params(2);

end
