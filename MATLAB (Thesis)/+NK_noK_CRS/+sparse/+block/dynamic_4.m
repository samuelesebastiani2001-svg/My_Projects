function [y, T, residual, g1] = dynamic_4(y, x, params, steady_state, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(1, 1);
  y(31)=y(35)*y(32);
  T(1)=params(17)*y(32)^params(5);
  T(2)=y(31)^params(2);
  residual(1)=(y(33))-(T(1)*T(2));
  T(3)=getPowerDeriv(y(31),params(2),1);
if nargout > 3
    g1_v = NaN(1, 1);
g1_v(1)=(-(T(2)*params(17)*getPowerDeriv(y(32),params(5),1)+T(1)*y(35)*T(3)));
    if ~isoctave && matlab_ver_less_than('9.8')
        sparse_rowval = double(sparse_rowval);
        sparse_colval = double(sparse_colval);
    end
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 1, 1);
end
end
