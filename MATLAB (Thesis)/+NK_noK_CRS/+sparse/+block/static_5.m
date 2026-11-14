function [y, T, residual, g1] = static_5(y, x, params, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(2, 1);
  T(2)=params(17)*y(13)^params(5);
  T(3)=y(12)^params(2);
  residual(1)=(y(14))-(T(2)*T(3));
  residual(2)=(y(12))-(y(16)*y(13));
if nargout > 3
    g1_v = NaN(4, 1);
g1_v(1)=(-(T(3)*params(17)*getPowerDeriv(y(13),params(5),1)));
g1_v(2)=(-y(16));
g1_v(3)=(-(T(2)*getPowerDeriv(y(12),params(2),1)));
g1_v(4)=1;
    if ~isoctave && matlab_ver_less_than('9.8')
        sparse_rowval = double(sparse_rowval);
        sparse_colval = double(sparse_colval);
    end
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 2, 2);
end
end
