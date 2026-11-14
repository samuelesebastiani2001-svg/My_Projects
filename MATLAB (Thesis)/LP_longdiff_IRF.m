function IRFs = LP_longdiff_IRF(y, exo, ctrl, p, horz, longdiff, lineardetrend, N, variables, controls)
%LP_LONGDIFF_IRF  Local-projection IRFs (long-difference specification)
%
%
%   Inputs
%     y             T x N    variables for which IRFs are computed
%     exo           T x 1    shock / instrument (regressor of interest)
%     ctrl          T x K    control variables (lags 1:p are built inside)
%     p             scalar   number of lags
%     horz          scalar   IRF horizon
%     longdiff      T/F      if true, long-difference LP specification
%     lineardetrend T/F      if true, adds a linear trend regressor
%     N             scalar   number of variables (= size(y,2))
%     variables     1xN cell names of the y columns
%     controls      1xK cell names of the ctrl columns
%
%   Output
%     IRFs          horz x N matrix of point-estimate IRFs
%                    (column iV = IRF of variable iV to "exo")

if ~isvector(exo)
    error('LP_longdiff_IRF: exo must be a single instrument/shock (vector)')
end
exo = exo(:);

% Drop rows with any NaNs across y, exo, ctrl (TIME is not used here)
rnan = ~any(isnan([y, exo, ctrl]), 2);
y    = y(rnan,:);
exo  = exo(rnan,:);
ctrl = ctrl(rnan,:);

IRFs = NaN(horz, N);

for iV = 1:N
    Y  = y(:,iV);
    ss = exo;

    % Controls for this regression: ctrl + Y itself (unless Y already in ctrl)
    dep_in_ctrl = ismember(variables{iV}, controls);
    if dep_in_ctrl
        ctrl_full = ctrl;
    else
        ctrl_full = [ctrl, Y];
    end

    for iH = 1:horz
        if longdiff
            Yy        = [NaN; Y(iH+1:end,:) - Y(1:end-iH,:)]; % y(t+h) - y(t-1)
            ctrl_diff = [NaN(1,size(ctrl_full,2)); diff(ctrl_full)]; % controls in first differences
            X         = [ss, lagmatrix(ctrl_diff,1:p)];
            X         = X(1:end-iH+1,:);
        else
            Yy = Y(iH:end); % y(t+h)
            X  = [ss, lagmatrix(ctrl_full,1:p)];
            X  = X(1:end+1-iH,:);
        end
        % NOTE: only the CONTEMPORANEOUS shock ss enters (not lags 0:p).
        % The monetary shock is i.i.d. (rho_m = 0 in the .mod), so its lags
        % add no information beyond the lagged controls. Worse, with
        % rho_m = 0 the lagged shock is an EXACT linear combination of the
        % lagged variables via the Taylor rule, which made X rank-deficient
        % (smallest singular value ~1e-15) and fired the singularity warning
        % at every horizon. Dropping the shock lags removes the warning;

        if lineardetrend
            X = [X, (1:size(X,1))'];
        end

        X = [ones(size(X,1),1), X]; % add constant

        % Point estimate via OLS
        ok   = ~any(isnan([Yy, X]),2);
        Xok  = X(ok,:);
        Yyok = Yy(ok,:);

        % Diagnostic: flag rank-deficient design matrices so we can see
        % exactly which variable/horizon is problematic, and which
        % column(s) are redundant.
        r = rank(Xok);
        if r < size(Xok,2)
            [~,~,perm] = qr(Xok,0);
            redundant  = perm(r+1:end);
            % Column map (longdiff, p=2): 1=const, 2=exo (lag 0),
            % 3-8 = lag1:2 of [ctrl col1,...,ctrl colK] (lag-major order)
            warning('LP_longdiff_IRF:rankDeficient', ...
                'Variable %d (%s), horizon %d: rank=%d, columns=%d, rows=%d, redundant col(s)=%s', ...
                iV, variables{iV}, iH, r, size(Xok,2), size(Xok,1), mat2str(redundant));
        end

        b = Xok \ Yyok;

        IRFs(iH,iV) = b(2); % coefficient on contemporaneous (lag-0) "exo"
    end
end
end
