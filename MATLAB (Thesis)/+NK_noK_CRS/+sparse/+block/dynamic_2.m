function [y, T] = dynamic_2(y, x, params, steady_state, sparse_rowval, sparse_colval, sparse_colptr, T)
  y(36)=params(13)*y(17)+params(14)*x(2);
  y(37)=params(15)*y(18)+params(16)*x(3);
end
