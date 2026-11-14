function g1 = static_g1(T, y, x, params, T_flag)
% function g1 = static_g1(T, y, x, params, T_flag)
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
%   g1
%

if T_flag
    T = NK_noK_CRS.static_g1_tt(T, y, x, params);
end
g1 = zeros(19, 19);
g1(1,6)=(-(params(1)*y(10)*(-1)/(y(6)*y(6))));
g1(1,10)=(-(params(1)*1/y(6)));
g1(2,1)=(-(T(1)*getPowerDeriv(y(1),params(2),1)));
g1(2,2)=(-(T(2)*params(17)*getPowerDeriv(y(2),params(5),1)));
g1(2,3)=1;
g1(3,1)=1;
g1(3,2)=(-(y(16)/y(4)));
g1(3,4)=(-(y(2)*(-y(16))/(y(4)*y(4))));
g1(3,16)=(-(y(2)*1/y(4)));
g1(4,1)=(-1);
g1(4,11)=1;
g1(5,5)=1;
g1(5,8)=(-(params(3)/(params(3)-1)*1/y(9)));
g1(5,9)=(-(params(3)/(params(3)-1)*(-y(8))/(y(9)*y(9))));
g1(6,1)=(-y(7));
g1(6,6)=(-(y(8)*params(1)*params(4)*T(13)));
g1(6,7)=(-y(1));
g1(6,8)=1-params(1)*params(4)*T(3);
g1(7,1)=(-1);
g1(7,6)=(-(y(9)*params(1)*params(4)*getPowerDeriv(y(6),params(3)-1,1)));
g1(7,9)=1-T(4);
g1(8,4)=1-params(4)*T(3);
g1(8,5)=(-((1-params(4))*getPowerDeriv(y(5),(-params(3)),1)));
g1(8,6)=(-(y(4)*params(4)*T(13)));
g1(9,5)=(-((-((1-params(4))*getPowerDeriv(y(5),1-params(3),1)))/params(4)*getPowerDeriv(T(5),1/(params(3)-1),1)));
g1(9,6)=1;
g1(10,3)=(-((1-params(6))/y(16)));
g1(10,7)=1;
g1(10,16)=(-((-(y(3)*(1-params(6))))/(y(16)*y(16))));
g1(11,6)=(-(exp(y(18))*T(6)*T(8)*params(10)*getPowerDeriv(y(6),params(7),1)*T(14)));
g1(11,10)=1-exp(y(18))*T(10)*getPowerDeriv(y(10),params(9),1);
g1(11,11)=(-(exp(y(18))*T(6)*T(14)*T(7)*1/y(15)*T(15)));
g1(11,15)=(-(exp(y(18))*T(6)*T(14)*T(7)*T(15)*(-y(11))/(y(15)*y(15))));
g1(11,18)=(-(T(6)*T(10)*exp(y(18))));
g1(12,12)=(-(T(11)*getPowerDeriv(y(12),params(2),1)));
g1(12,13)=(-(T(12)*params(17)*getPowerDeriv(y(13),params(5),1)));
g1(12,14)=1;
g1(13,12)=1;
g1(13,13)=(-y(16));
g1(13,16)=(-y(13));
g1(14,14)=(-(1-params(6)));
g1(14,16)=(params(3)-1)/params(3);
g1(15,12)=(-1);
g1(15,15)=1;
g1(16,11)=(-(1/y(15)));
g1(16,15)=(-((-y(11))/(y(15)*y(15))));
g1(16,19)=1;
g1(17,16)=1/y(16)-params(11)*1/y(16);
g1(18,17)=1-params(13);
g1(19,18)=1-params(15);

end
