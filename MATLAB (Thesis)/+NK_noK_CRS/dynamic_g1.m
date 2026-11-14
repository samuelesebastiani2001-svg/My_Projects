function g1 = dynamic_g1(T, y, x, params, steady_state, it_, T_flag)
% function g1 = dynamic_g1(T, y, x, params, steady_state, it_, T_flag)
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
%   g1
%

if T_flag
    T = NK_noK_CRS.dynamic_g1_tt(T, y, x, params, steady_state, it_);
end
g1 = zeros(19, 32);
g1(1,6)=(-(T(5)*T(2)*(-y(25))/(y(6)*y(6))*T(20)));
g1(1,25)=(-(T(5)*T(2)*T(20)*1/y(6)));
g1(1,26)=(-(T(4)*(-1)/(y(26)*y(26))));
g1(1,15)=(-(T(5)*T(3)*params(1)*T(1)));
g1(1,22)=(-(T(5)*T(3)*params(1)*y(15)*T(23)));
g1(1,29)=(-(T(4)*T(5)));
g1(2,6)=(-(T(6)*getPowerDeriv(y(6),params(2),1)));
g1(2,7)=(-(T(7)*params(17)*getPowerDeriv(y(7),params(5),1)));
g1(2,8)=1;
g1(3,6)=1;
g1(3,7)=(-(y(21)/y(9)));
g1(3,9)=(-(y(7)*(-y(21))/(y(9)*y(9))));
g1(3,21)=(-(y(7)*1/y(9)));
g1(4,6)=(-1);
g1(4,16)=1;
g1(5,10)=1;
g1(5,13)=(-(params(3)/(params(3)-1)*1/y(14)));
g1(5,14)=(-(params(3)/(params(3)-1)*(-y(13))/(y(14)*y(14))));
g1(6,6)=(-(y(12)+y(27)*T(9)*T(1)*params(1)*params(4)*1/y(25)));
g1(6,25)=(-(y(27)*T(9)*T(1)*params(1)*params(4)*(-y(6))/(y(25)*y(25))));
g1(6,26)=(-(y(27)*T(8)*getPowerDeriv(y(26),params(3),1)));
g1(6,12)=(-y(6));
g1(6,13)=1;
g1(6,27)=(-(T(8)*T(9)));
g1(6,22)=(-(y(27)*T(9)*y(6)/y(25)*params(1)*params(4)*T(23)));
g1(6,29)=(-(T(8)*T(9)*y(27)));
g1(7,6)=(-(1+y(28)*T(10)*T(1)*params(1)*params(4)*1/y(25)));
g1(7,25)=(-(y(28)*T(10)*T(1)*params(1)*params(4)*(-y(6))/(y(25)*y(25))));
g1(7,26)=(-(y(28)*T(8)*getPowerDeriv(y(26),params(3)-1,1)));
g1(7,14)=1;
g1(7,28)=(-(T(8)*T(10)));
g1(7,22)=(-(y(28)*T(10)*y(6)/y(25)*params(1)*params(4)*T(23)));
g1(7,29)=(-(T(8)*T(10)*y(28)));
g1(8,1)=(-T(11));
g1(8,9)=1;
g1(8,10)=(-((1-params(4))*getPowerDeriv(y(10),(-params(3)),1)));
g1(8,11)=(-(y(1)*params(4)*getPowerDeriv(y(11),params(3),1)));
g1(9,10)=(-((-((1-params(4))*getPowerDeriv(y(10),1-params(3),1)))/params(4)*getPowerDeriv(T(12),1/(params(3)-1),1)));
g1(9,11)=1;
g1(10,8)=(-((1-params(6))/y(21)));
g1(10,12)=1;
g1(10,21)=(-((-(y(8)*(1-params(6))))/(y(21)*y(21))));
g1(11,11)=(-(exp(y(23))*T(13)*T(15)*params(10)*getPowerDeriv(y(11),params(7),1)*T(21)));
g1(11,2)=(-(exp(y(23))*T(17)*getPowerDeriv(y(2),params(9),1)));
g1(11,15)=1;
g1(11,16)=(-(exp(y(23))*T(13)*T(21)*T(14)*1/y(20)*T(22)));
g1(11,20)=(-(exp(y(23))*T(13)*T(21)*T(14)*T(22)*(-y(16))/(y(20)*y(20))));
g1(11,23)=(-(T(13)*T(17)*exp(y(23))));
g1(12,17)=(-(T(18)*getPowerDeriv(y(17),params(2),1)));
g1(12,18)=(-(T(19)*params(17)*getPowerDeriv(y(18),params(5),1)));
g1(12,19)=1;
g1(13,17)=1;
g1(13,18)=(-y(21));
g1(13,21)=(-y(18));
g1(14,19)=(-(1-params(6)));
g1(14,21)=(params(3)-1)/params(3);
g1(15,17)=(-1);
g1(15,20)=1;
g1(16,16)=(-(1/y(20)));
g1(16,20)=(-((-y(16))/(y(20)*y(20))));
g1(16,24)=1;
g1(17,3)=(-(params(11)*1/y(3)));
g1(17,21)=1/y(21);
g1(17,30)=(-params(12));
g1(18,4)=(-params(13));
g1(18,22)=1;
g1(18,31)=(-params(14));
g1(19,5)=(-params(15));
g1(19,23)=1;
g1(19,32)=(-params(16));

end
