% =========================================================================
%
%  a Monte Carlo experiment for SVAR-IV method (using external instrument)
%  the Instrument is generated internally with noise and relevance added. 
%  Monte Carlo evaluation of the external-instrument (proxy) SVAR.
%  DGP: NK model with calvo pricing mechanics (NK_noK_CRS.mod).
%
%  Identification strategy
%  -----------------------
%  1. Estimate a VAR(2) on each simulated sample of T observations.
%  2. Identify the Monetary Policy impact vector via the external instrument z_t,
%  3. Reconstruct the structural shock and measure its correlation with
%     the true shock across replications.
%  4. build IRFs recursively through the VAR coefficient matrices.
%
%  IRFs are kept in raw level-deviation units, directly comparable to the
%  Dynare True IRFs.
%
%  Outputs
%  -------
%  Figure 1  True vs mean-estimated IRFs with MC quantile bands
%  Figure 2  Distribution of corr(em_hat, em) across simulations
%  part1_workspace.mat  full workspace for Part 2
% =========================================================================

clear
close all
if ~isfile('oo_.mat') || ~isfile('M_.mat')
    dynare NK_noK_CRS.mod noclearall
    save oo_.mat oo_
    save M_.mat M_
end
if isempty(which('dynare'))
    addpath('/Applications/Dynare/6.5-x86_64/matlab'); % <- Edit this path with your dynare
end


% =========================================================================
%  PARAMETERS
% =========================================================================

% --- Sample / DGP ---
T            = 250;     % observations per simulation
simulations  = 2000;    % number of Monte Carlo replications
p            = 2;       % VAR lag order
H            = 33;      % IRF horizon (number of periods)
nvar         = 3;       % endogenous variables: y, R, Pi

% --- Instrument ---
params.zt_rel   = 1;    % relevance: weight on the true shock
params.zt_noise = 0.5;    % added-noise weight (relative to signal std)
params.zeros    = 0;    % fraction of z_t obs randomly set to zero  in [0,1)

% --- MC confidence bands (quantiles of the point-estimate distribution) ---
q_outer = [0.05, 0.95];   % outer (wider) band
q_inner = [0.16, 0.84];   % inner (tighter) band

% ---- local projection parameters (using "LP_longdiff_IRF.m"), PART 2 ----
horz          = H;     % = 33, IRF horizon
longdiff      = false;
lineardetrend = false;
N             = 3;     % number of variables: y, R, Pi
alpha         = 0.5; % alpha = Ratio of short over long method observation. 
variables     = {'y','R','Pi'};
controls      = {'y','R','Pi'};  % same set as variables -> ctrl_full = ctrl (lags of Y)

% =========================================================================
%  INPUT CHECKS
% =========================================================================
assert(params.zeros >= 0  && params.zeros < 1, 'params.zeros must be in [0,1).');
assert(params.zt_rel   >  0, 'params.zt_rel must be positive.');
assert(params.zt_noise >= 0, 'params.zt_noise must be non-negative.');
assert(T > p, 'T must be greater than the lag order p.');

% =========================================================================
%  LOAD DYNARE OUTPUT
% =========================================================================
load oo_.mat
load M_.mat

% steady-state variables
ys = oo_.steady_state;             

% True IRFs are IRFs taken from Dynare
True.IRF_y  = oo_.irfs.y_em;
True.IRF_R  = oo_.irfs.R_em;
True.IRF_Pi = oo_.irfs.Pi_em;

% Endogenous panel and variable indices
Y     = oo_.endo_simul;
names = cellstr(M_.endo_names);
index.gap = find(strcmp('gap', names));
index.y   = find(strcmp('y',   names));
index.Pi  = find(strcmp('Pi',  names));
index.R   = find(strcmp('R',   names));

y_ss  = ys(index.y);
R_ss  = ys(index.R);
Pi_ss = ys(index.Pi);

% Structural MP shocks
index.sigm = find(strcmp('sig_m', cellstr(M_.param_names)));
exo_names  = cellstr(M_.exo_names);
index.em   = find(strcmp('em', exo_names));

sig_m = M_.params(index.sigm);     % std of monetary policy shock

% =========================================================================
%  BUILD SIMULATION PANELS  (T x simulations)
% =========================================================================
simul.y   = Y(index.y,:)  - y_ss;     % output
simul.gap = Y(index.gap,:);           % output gap
simul.Pi  = Y(index.Pi,:) - Pi_ss;    % inflation
simul.R   = Y(index.R,:)  - R_ss;     % interest rate

em        = oo_.exo_simul(:,index.em);  % exogenous variations in MP
simul.em  = sig_m * em;                 % actual MP shocks

Total_information = T * simulations;    % obs to keep from the model
assert(numel(simul.em) >= Total_information, ...
    'Not enough simulated observations for T * simulations.');

% Keep the first T*simulations obs and reshape into T x simulations
vars = {'y','gap','Pi','R','em'};
for i = 1:length(vars)
    simul.(vars{i}) = simul.(vars{i})(1:Total_information);
    simul.(vars{i}) = reshape(simul.(vars{i}), T, simulations);
end

% =========================================================================
%  INSTRUMENT CONSTRUCTION  (T x simulations)
%  z_t = zt_rel * em  +  zt_noise * eta * std(zt_rel * em),  eta ~ N(0,1)
% =========================================================================
noise_scale = std(params.zt_rel * simul.em, 0, 1);
zt          = params.zt_rel  * simul.em ...
            + params.zt_noise * randn(size(simul.em)) .* noise_scale;

% Zero out a random fraction of instrument obs (instrument unavailable)
K = round(params.zeros * size(zt,1));
if K > 0
    for col = 1:size(zt,2)
        idx = randperm(size(zt,1), K);
        zt(idx,col) = 0;
    end
end

% =========================================================================
%  MONTE CARLO LOOP
% =========================================================================
corr_str_shock = zeros(1, simulations);
simul.IRF      = zeros(nvar, H, simulations);
corr_inst_shock = zeros(1, simulations);

for j = 1:simulations   % each j is one model with T observations

    Yj = [simul.y(:,j), simul.R(:,j), simul.Pi(:,j)];   % order [y R Pi]

    % Dependent variable
    Ydep = Yj(p+1:T, :);     

    % Build lagged regressor matrix X = [Y(t-1), Y(t-2), ..., Y(t-p)]
    X = zeros(T-p, nvar*p);
    for lag = 1:p
        X(:, (lag-1)*nvar+1 : lag*nvar) = Yj(p+1-lag : T-lag, :);
    end

    % VAR(p) estimation: coefficients and reduced-form residuals
    B  = X \ Ydep;            % Beta coefficients 
    Uj = Ydep - X * B;        % VAR residuals 
    zj = zt(p+1:end, j);       

    % IV step: impact vector b = cov(u,z) / sig_m
    cov_uz_zj = (Uj' * zj) / length(zj);
    impact    = cov_uz_zj / sig_m;

% =========================================================================
%  Impulse resposne functions
% =========================================================================

    % Companion blocks A1, ..., Ap
    A = zeros(nvar, nvar, p);
    for lag = 1:p
        A(:,:,lag) = B((lag-1)*nvar+1 : lag*nvar, :)';
    end

    % IRF propagation via the VAR(p) recursion
    simul.IRF(:,1,j) = impact;
    for h = 2:H
        acc = zeros(nvar,1);
        for lag = 1:min(p, h-1)
            acc = acc + A(:,:,lag) * simul.IRF(:, h-lag, j);
        end
        simul.IRF(:,h,j) = acc;
    end

    scale_p1         = True.IRF_R(1) / simul.IRF(2, 1, j);
    simul.IRF(:,:,j) = simul.IRF(:,:,j) * scale_p1;

    % Reconstructed structural shock and its correlation with the true one
    proj_zt_ut    = Uj * ((zj' * Uj) / (Uj' * Uj))';
    simul.em_hat  = (sig_m^2 / params.zt_rel) * proj_zt_ut;
    corr_str_shock(j) = corr(simul.em(p+1:end,j), simul.em_hat);

    % Raw instrument's correlation with the true shock (relevance diagnostic)
    corr_inst_shock(j) = corr(simul.em(p+1:end,j), zj);
end

% Compute the mean across simulated IRFs
corr_mean      = mean(corr_str_shock);
corr_inst_mean = mean(corr_inst_shock);
simul.IRF_mean = mean(simul.IRF, 3);
simul.IRF_y    = simul.IRF_mean(1, :);
simul.IRF_R    = simul.IRF_mean(2, :);
simul.IRF_Pi   = simul.IRF_mean(3, :);

% =========================================================================
%  SUMMARY STATISTICS
% =========================================================================
% Quantile bands across the simulation distribution of the point estimate
probs       = [q_outer(1), q_inner(1), q_inner(2), q_outer(2)];
simul.IRF_q = quantile(simul.IRF, probs, 3);          % nvar x H x 4

% Bias and RMSE of the estimated IRFs against the Dynare truth (1:H)
% we stack True_IRFs up to have the same dimension as simul_IRF
True_IRFs = [True.IRF_y(1:H); True.IRF_R(1:H); True.IRF_Pi(1:H)];   
simul.bias = mean(simul.IRF_mean - True_IRFs, 2);                      
simul.rmse = sqrt(mean(mean((simul.IRF - True_IRFs).^2, 2), 3)); 

var_labels = {'Output ($y$)', 'Interest rate ($R$)', 'Inflation ($\Pi$)'};

fprintf('\n=== External SVAR  Monte Carlo Summary ===\n')
fprintf('T = %d   simulations = %d   p = %d   H = %d\n', T, simulations, p, H)
fprintf('Instrument: relevance = %.2f,  noise = %.2f,  zeros = %.0f%%\n\n', ...
        params.zt_rel, params.zt_noise, params.zeros*100)
fprintf('%-22s  %10s  %10s\n', 'Variable', 'Avg bias', 'Avg RMSE')
fprintf('%s\n', repmat('-',1,46))
for iV = 1:nvar
    lbl = strrep(strrep(var_labels{iV}, '$',''), '\','');
    fprintf('%-22s  %10.4f  %10.4f\n', lbl, simul.bias(iV), simul.rmse(iV))
end
fprintf('%s\n', repmat('-',1,46))
fprintf('%-22s  %10.4f  (std = %.4f)\n\n', 'Shock correlation', ...
        corr_mean, std(corr_str_shock))
fprintf('%-22s  %10.4f  (std = %.4f)\n\n', 'Instrument correlation', ...
        corr_inst_mean, std(corr_inst_shock))


%----------------------------
% PART 2
%----------------------------
short_sample = round((T-p) * alpha);
t_short      = (p+1 : p+short_sample);

IRF_short = NaN(horz, N, simulations);
IRF_long = NaN(horz, N, simulations);

for j = 1:simulations % representative simulation draw (change this to inspect another draw)
    if j/100 == round(j/100)
        disp(['Simulations: ',num2str(j)])
    end
    Yj = [simul.y(:,j), simul.R(:,j), simul.Pi(:,j)];

    %% ---- Method 1 (Short): exo = the instrument, restricted to t_short ----
    Y_short    = Yj(t_short,:);
    ctrl_short = Yj(t_short,:);
    exo_short  = zt(t_short,j) / sig_m; % instrument is "exo" for the Short method

    IRF_short(:,:,j) = LP_longdiff_IRF(Y_short, exo_short, ctrl_short, ...
        p, horz, longdiff, lineardetrend, N, variables, controls);

    % --- Normalize: rescale so the Short method's own impact response on R
    %     matches the true impact response on R ---
    scale_short       = True.IRF_R(1) / IRF_short(1, 2, j);
    IRF_short(:,:,j)  = IRF_short(:,:,j) * scale_short;

    %% ---- Method 2 (Long): reconstructed structural shock, full sample ----
    Ydep  = Yj(p+1:end, :);
    X_var = zeros(T-p, N*p);
    for lag = 1:p
        X_var(:, (lag-1)*N+1 : lag*N) = Yj(p+1-lag : T-lag, :);
    end
    B      = X_var \ Ydep;
    Uj     = Ydep - X_var * B;
    
 
    zj_short = zt(t_short, j) / sig_m;
    Uj_short = Uj(t_short - p, :);
    b_proj   = Uj_short \ zj_short;

    simul_em_hat = Uj * b_proj;        % the regressor is the estimated mp shock      
    
    Y_long    = Ydep;
    ctrl_long = Ydep;
    long_exo  = simul_em_hat;

    IRF_long(:,:,j) = LP_longdiff_IRF(Y_long, long_exo, ctrl_long, ...
        p, horz, longdiff, lineardetrend, N, variables, controls);

    % --- Normalize: rescale so the Long method's own impact response on R
    %     matches the true impact response on R ---
    scale_long      = True.IRF_R(1) / IRF_long(1, 2, j);
    IRF_long(:,:,j) = IRF_long(:,:,j) * scale_long;
end

%---------------------------------------------------%
% OBTAINING INFORMATION
%---------------------------------------------------%
Short.IRF_mean = mean(IRF_short, 3, 'omitnan');
Short.IRF_y = Short.IRF_mean(:, 1);
Short.IRF_R = Short.IRF_mean(:, 2);
Short.IRF_Pi = Short.IRF_mean(:, 3);
Long.IRF_mean = mean(IRF_long, 3,  'omitnan');
Long.IRF_y = Long.IRF_mean(:,1);
Long.IRF_R = Long.IRF_mean(:,2);
Long.IRF_Pi = Long.IRF_mean(:,3);


% =========================================================================
%  FIGURE 1 — True vs estimated IRFs  +  MC quantile bands
% =========================================================================
h_grid    = 1:H;
x2        = [h_grid, fliplr(h_grid)];
true_irfs = {True.IRF_y(1:H), True.IRF_R(1:H), True.IRF_Pi(1:H)};
est_irfs  = {simul.IRF_y, simul.IRF_R, simul.IRF_Pi};

fig1 = figure('Color','w', 'Position', [80 80 1500 560]);
tl   = tiledlayout(1, nvar, 'TileSpacing','compact', 'Padding','loose');

for iV = 1:nvar
    nexttile; hold on

    % Outer quantile band
    yo = [squeeze(simul.IRF_q(iV,:,1)), fliplr(squeeze(simul.IRF_q(iV,:,4)))];
    fill(x2, yo, [0.82 0.82 0.82], 'LineStyle','none', 'FaceAlpha', 0.55);

    % Inner quantile band
    yi = [squeeze(simul.IRF_q(iV,:,2)), fliplr(squeeze(simul.IRF_q(iV,:,3)))];
    fill(x2, yi, [0.55 0.55 0.55], 'LineStyle','none', 'FaceAlpha', 0.55);

    % Mean estimated IRF and true IRF
    h_est  = plot(h_grid, est_irfs{iV},  'b-', 'LineWidth', 2.2);
    h_true = plot(h_grid, true_irfs{iV}, 'r-', 'LineWidth', 2.2);

    yline(0, 'k:', 'LineWidth', 0.8);
    xlim([1, H]);
    title(var_labels{iV}, 'Interpreter','latex', 'FontSize', 13);
    xlabel('Horizon', 'Interpreter','latex', 'FontSize', 11);
    if iV == 1
        ylabel('Response', 'Interpreter','latex', 'FontSize', 11);
    end
    legend([h_est, h_true], {'Mean estimated', 'True IRF'}, ...
           'Interpreter','latex', 'FontSize', 10, 'Location','best');
    set(gca, 'FontSize', 10, 'TickLabelInterpreter','latex');
    box on; grid on;
end

title(tl, { ...
    sprintf('External SVAR $\\;-\\;$ $T=%d$, $%d$ simulations, $p=%d$, relevance $=%.2f$', ...
            T, simulations, p, params.zt_rel), ...
    sprintf('bands: [$%.0f\\%%$--$%.0f\\%%$] and [$%.0f\\%%$--$%.0f\\%%$]', ...
            q_outer(1)*100, q_outer(2)*100, q_inner(1)*100, q_inner(2)*100) ...
    }, 'Interpreter','latex', 'FontSize', 11);

% =========================================================================
%  FIGURE 2 — Distribution of shock-recovery correlation
%  (estimated shock vs. true shock, and instrument vs. true shock)
% =========================================================================
fig2 = figure('Color','w', 'Position', [80 80 680 460]);
hold on

n_bins    = 40;
corr_pool = [corr_str_shock(:); corr_inst_shock(:)];
pad       = max(range(corr_pool) * 0.02, 1e-6);   % avoid a zero-width range
edges     = linspace(min(corr_pool)-pad, max(corr_pool)+pad, n_bins+1);

h_est = histogram(corr_str_shock, ...
          'BinEdges', edges, ...
          'FaceColor', [0.25 0.45 0.75], ...
          'EdgeColor', 'w', ...
          'FaceAlpha', 0.65, ...
          'Normalization', 'probability');

h_inst = histogram(corr_inst_shock, ...
          'BinEdges', edges, ...
          'FaceColor', [0.85 0.45 0.10], ...
          'EdgeColor', 'w', ...
          'FaceAlpha', 0.55, ...
          'Normalization', 'probability');

xl_est = xline(corr_mean, '-', 'Color', [0.10 0.25 0.55], 'LineWidth', 2.2, ...
      'Label', sprintf('Mean $\\hat\\varepsilon$ corr $= %.3f$', corr_mean), ...
      'LabelHorizontalAlignment','left', ...
      'LabelOrientation', 'horizontal', ...
      'FontSize', 10, 'Interpreter','latex');

xl_inst = xline(corr_inst_mean, '-', 'Color', [0.65 0.30 0.05], 'LineWidth', 2.2, ...
      'Label', sprintf('Mean $z_t$ corr $= %.3f$', corr_inst_mean), ...
      'LabelHorizontalAlignment','left', ...
      'LabelOrientation', 'horizontal', ...
      'FontSize', 10, 'Interpreter','latex');

xlabel('Correlation with true shock $\varepsilon_{1t}$', ...
       'Interpreter','latex', 'FontSize', 13);
ylabel('Fraction of simulations', 'Interpreter','latex', 'FontSize', 11);
legend([h_est, h_inst], ...
       {'$\mathrm{corr}(\hat\varepsilon_{1t},\,\varepsilon_{1t})$ (estimated shock)', ...
        '$\mathrm{corr}(z_t,\,\varepsilon_{1t})$ (instrument)'}, ...
       'Interpreter','latex', 'FontSize', 10, 'Location','best');
title(sprintf('Shock recovery vs.\\ instrument relevance $=%.2f$', ...
              params.zt_rel), ...
      'Interpreter','latex', 'FontSize', 13);
set(gca, 'FontSize', 10, 'TickLabelInterpreter','latex');
box on; grid on;
hold off

fprintf('correlation between estimated and true structural shocks: %.4f\n', corr_mean)
fprintf('correlation between instrument and true structural shocks: %.4f\n', corr_inst_mean)


%---------------------------------------------------%
% Variance, Bias and MSE for both methods
%---------------------------------------------------%
Short.IRF_var = var(IRF_short, 0, 3, 'omitnan');
Short.IRF_var_y  = Short.IRF_var(:, 1);
Short.IRF_var_R  = Short.IRF_var(:, 2);
Short.IRF_var_Pi = Short.IRF_var(:, 3);
%---------------------------------------------------%
Short.bias_y = mean(Short.IRF_y(:) - True.IRF_y(:));
Short.bias_R = mean(Short.IRF_R(:) - True.IRF_R(:));
Short.bias_Pi = mean(Short.IRF_Pi(:) - True.IRF_Pi(:));
Short.MSE_y = mean((Short.IRF_y(:) - True.IRF_y(:)).^2);
Short.MSE_R = mean((Short.IRF_R(:) - True.IRF_R(:)).^2);
Short.MSE_Pi = mean((Short.IRF_Pi(:) - True.IRF_Pi(:)).^2);
%---------------------------------------------------%
Long.IRF_var = var(IRF_long, 0, 3, 'omitnan');
Long.IRF_var_y  = Long.IRF_var(:, 1);
Long.IRF_var_R  = Long.IRF_var(:, 2);
Long.IRF_var_Pi = Long.IRF_var(:, 3);
%---------------------------------------------------%
Long.bias_y = mean(Long.IRF_y(:) - True.IRF_y(:));
Long.bias_R = mean(Long.IRF_R(:) - True.IRF_R(:));
Long.bias_Pi = mean(Long.IRF_Pi(:) - True.IRF_Pi(:));
Long.MSE_y = mean((Long.IRF_y(:) - True.IRF_y(:)).^2);
Long.MSE_R = mean((Long.IRF_R(:) - True.IRF_R(:)).^2);
Long.MSE_Pi = mean((Long.IRF_Pi(:) - True.IRF_Pi(:)).^2);
%---------------------------------------------------%
% Per-horizon Bias and MSE for both methods
%---------------------------------------------------%
Short.bias_h_y  = Short.IRF_y - True.IRF_y(1:horz)';
Short.bias_h_R  = Short.IRF_R  - True.IRF_R(1:horz)';
Short.bias_h_Pi = Short.IRF_Pi - True.IRF_Pi(1:horz)';

Long.bias_h_y  = Long.IRF_y  - True.IRF_y(1:horz)';
Long.bias_h_R  = Long.IRF_R  - True.IRF_R(1:horz)';
Long.bias_h_Pi = Long.IRF_Pi - True.IRF_Pi(1:horz)';

Short.MSE_h_y  = mean((squeeze(IRF_short(:,1,:)) - True.IRF_y(1:horz)').^2, 2);
Short.MSE_h_R  = mean((squeeze(IRF_short(:,2,:)) - True.IRF_R(1:horz)').^2, 2);
Short.MSE_h_Pi = mean((squeeze(IRF_short(:,3,:)) - True.IRF_Pi(1:horz)').^2, 2);

Long.MSE_h_y  = mean((squeeze(IRF_long(:,1,:)) - True.IRF_y(1:horz)').^2, 2);
Long.MSE_h_R  = mean((squeeze(IRF_long(:,2,:)) - True.IRF_R(1:horz)').^2, 2);
Long.MSE_h_Pi = mean((squeeze(IRF_long(:,3,:)) - True.IRF_Pi(1:horz)').^2, 2);
% Variance Ratio
% if VR > 1, short method is better, if VR < 1, long method is better
VarianceRatio.y  = mean(Long.IRF_var_y  ./ Short.IRF_var_y);
VarianceRatio.R  = mean(Long.IRF_var_R  ./ Short.IRF_var_R);
VarianceRatio.Pi = mean(Long.IRF_var_Pi ./ Short.IRF_var_Pi);
%---------------------------------------------------%
% Bias
%---------------------------------------------------%
fprintf('Long bias for output: %.6f\n', Long.bias_y)
fprintf('Short bias for output: %.6f\n', Short.bias_y)
fprintf('Long bias for Interest Rates: %.6f\n', Long.bias_R)
fprintf('Short bias for Interest Rates: %.6f\n', Short.bias_R)
fprintf('Long bias for Inflation: %.6f\n', Long.bias_Pi)
fprintf('Short bias for Inflation: %.6f\n', Short.bias_Pi)
%---------------------------------------------------%
% MSE
%---------------------------------------------------%
fprintf('Long MSE for output: %.6f\n', Long.MSE_y)
fprintf('Short MSE for output: %.6f\n', Short.MSE_y)
fprintf('Long MSE for Interest Rates: %.6f\n', Long.MSE_R)
fprintf('Short MSE for Interest Rates: %.6f\n', Short.MSE_R)
fprintf('Long MSE for Inflation: %.6f\n', Long.MSE_Pi)
fprintf('Short MSE for Inflation: %.6f\n', Short.MSE_Pi)
%---------------------------------------------------%



%% ---- Plot against the True IRF ----
horzs = 0:horz-1;
%---------------------------------------------------%
% Plotting Average IRFs for simulations
%---------------------------------------------------%
figure
subplot(3,1,1)
plot(horzs, True.IRF_y(1:horz), 'LineWidth',2); hold on
plot(horzs, Short.IRF_y, '--', 'LineWidth',2)
plot(horzs, Long.IRF_y, ':', 'LineWidth',2)
legend('True IRF','Short LP (long-diff)','Long LP (long-diff)')
title('Output')
xlabel('Horizon'); ylabel('Response')
grid on

subplot(3,1,2)
plot(horzs, True.IRF_R(1:horz), 'LineWidth',2); hold on
plot(horzs, Short.IRF_R, '--', 'LineWidth',2)
plot(horzs, Long.IRF_R, ':', 'LineWidth',2)
legend('True IRF','Short LP (long-diff)','Long LP (long-diff)')
title('Interest Rate')
xlabel('Horizon'); ylabel('Response')
grid on

subplot(3,1,3)
plot(horzs, True.IRF_Pi(1:horz), 'LineWidth',2); hold on
plot(horzs, Short.IRF_Pi, '--', 'LineWidth',2)
plot(horzs, Long.IRF_Pi, ':', 'LineWidth',2)
legend('True IRF','Short LP (long-diff)','Long LP (long-diff)')
title('Inflation')
xlabel('Horizon'); ylabel('Response')
grid on


%---------------------------------------------------%
% Plotting Variance of IRFs for simulations
%---------------------------------------------------%
figure
subplot(3,1,1)
plot(Short.IRF_var_y,'LineWidth',2); hold on
plot(Long.IRF_var_y, 'LineWidth', 2);
legend ('Short method', 'Long method')
title ('Short vs Long: IRFs Variance for output')
grid on

subplot(3,1,2)
plot(Short.IRF_var_R,'LineWidth',2); hold on
plot(Long.IRF_var_R, 'LineWidth', 2);
legend ('Short method', 'Long method')
title ('Short vs Long: IRFs Variance for Interest rates')
grid on


subplot(3,1,3)
plot(Short.IRF_var_Pi,'LineWidth',2); hold on
plot(Long.IRF_var_Pi, 'LineWidth', 2);
legend ('Short method', 'Long method')
title ('Short vs Long: IRFs Variance for Inflation')
grid on


%---------------------------------------------------%
% Multiplots: Variance / Bias / MSE, one figure per variable
%---------------------------------------------------%
figure('Color','w','Position',[80 80 1400 900]);
tl = tiledlayout(3, N, 'TileSpacing','compact', 'Padding','loose');
sgtitle('Short vs Long LP: Variance, Bias, and MSE by Variable', ...
        'FontSize', 14, 'Interpreter','latex')
%-------------------------------%
%----------------OUTPUT---------------%
%-------------------------------%
% --- Variance ---
subplot(3,3,1)
plot(horzs, Short.IRF_var_y, 'LineWidth', 2); hold on
plot(horzs, Long.IRF_var_y,  'LineWidth', 2);
legend('Short method', 'Long method', 'Location','best')
title('Variance of IRF estimates: Output')
xlabel('Horizon'); ylabel('Variance')
grid on; box on

% --- Bias ---
subplot(3,3,2)
plot(horzs, Short.bias_h_y, 'LineWidth', 2); hold on
plot(horzs, Long.bias_h_y,  'LineWidth', 2);
yline(0, 'k:', 'LineWidth', 0.8);
legend('Short method', 'Long method', 'Location','best')
title('Bias vs True IRF: Output')
xlabel('Horizon'); ylabel('Bias')
grid on; box on

% --- MSE ---
subplot(3,3,3)
plot(horzs, Short.MSE_h_y, 'LineWidth', 2); hold on
plot(horzs, Long.MSE_h_y,  'LineWidth', 2);
legend('Short method', 'Long method', 'Location','best')
title('MSE vs True IRF: Output')
xlabel('Horizon'); ylabel('MSE')
grid on; box on


%-------------------------------%
%----------------INTEREST RATES---------------%
%-------------------------------%
% --- Variance ---
subplot(3,3,4)
plot(horzs, Short.IRF_var_R, 'LineWidth', 2); hold on
plot(horzs, Long.IRF_var_R,  'LineWidth', 2);
legend('Short method', 'Long method', 'Location','best')
title('Variance of IRF estimates: Interest rates')
xlabel('Horizon'); ylabel('Variance')
grid on; box on

% --- Bias ---
subplot(3,3,5)
plot(horzs, Short.bias_h_R, 'LineWidth', 2); hold on
plot(horzs, Long.bias_h_R,  'LineWidth', 2);
yline(0, 'k:', 'LineWidth', 0.8);
legend('Short method', 'Long method', 'Location','best')
title('Bias vs True IRF: Interest Rates')
xlabel('Horizon'); ylabel('Bias')
grid on; box on

% --- MSE ---
subplot(3,3,6)
plot(horzs, Short.MSE_h_R, 'LineWidth', 2); hold on
plot(horzs, Long.MSE_h_R,  'LineWidth', 2);
legend('Short method', 'Long method', 'Location','best')
title('MSE vs True IRF: Interest rates')
xlabel('Horizon'); ylabel('MSE')
grid on; box on


%-------------------------------%
%----------------INFLATION---------------%
%-------------------------------%
% --- Variance ---
subplot(3,3,7)
plot(horzs, Short.IRF_var_Pi, 'LineWidth', 2); hold on
plot(horzs, Long.IRF_var_Pi,  'LineWidth', 2);
legend('Short method', 'Long method', 'Location','best')
title('Variance of IRF estimates: Inflation')
xlabel('Horizon'); ylabel('Variance')
grid on; box on

% --- Bias ---
subplot(3,3,8)
plot(horzs, Short.bias_h_Pi, 'LineWidth', 2); hold on
plot(horzs, Long.bias_h_Pi,  'LineWidth', 2);
yline(0, 'k:', 'LineWidth', 0.8);
legend('Short method', 'Long method', 'Location','best')
title('Bias vs True IRF: Inflation')
xlabel('Horizon'); ylabel('Bias')
grid on; box on

% --- MSE ---
subplot(3,3,9)
plot(horzs, Short.MSE_h_Pi, 'LineWidth', 2); hold on
plot(horzs, Long.MSE_h_Pi,  'LineWidth', 2);
legend('Short method', 'Long method', 'Location','best')
title('MSE vs True IRF: Inflation')
xlabel('Horizon'); ylabel('MSE')
grid on; box on
sgtitle(sprintf('Short vs Long LP: Variance, Bias, and MSE (obs. in short method = %d, T = %d, simulations = %d, instrument noise = %.2f)', ...
        alpha*T, T, simulations, params.zt_noise), 'FontSize', 14)

%---------------------------------------------------%
% Scalar bias & MSE summaries (analogous to VarianceRatio)
%   ratio < 1 -> Long method better
%---------------------------------------------------%
vars = {'y','R','Pi'};
for k = 1:numel(vars)
    v = vars{k};
    bS = Short.(['bias_h_' v]);   bL = Long.(['bias_h_' v]);
    mS = Short.(['MSE_h_'  v]);   mL = Long.(['MSE_h_'  v]);

    % Root-mean-squared bias (level, in IRF units)
    RMSB_short.(v) = sqrt(mean(bS.^2));
    RMSB_long.(v)  = sqrt(mean(bL.^2));

    % Peak absolute bias (captures the impact-horizon spike)
    PeakBias_short.(v) = max(abs(bS));
    PeakBias_long.(v)  = max(abs(bL));

    % Ratios (ratio of aggregates -> stable)
    BiasRatio.(v) = RMSB_long.(v) / RMSB_short.(v);   % <1 -> Long less biased
    MSERatio.(v)  = mean(mL) / mean(mS);              % <1 -> Long lower total error

    % Optional: share of each method's MSE coming from bias
    BiasShare_short.(v) = mean(bS.^2) / mean(mS);
    BiasShare_long.(v)  = mean(bL.^2) / mean(mL);
end

fprintf('\n%-12s %10s %10s %10s\n', ...
        'Variable','BiasRatio','VarRatio','MSERatio');
for k = 1:numel(vars)
    v = vars{k};
    fprintf('%-12s %10.3f %10.3f %10.3f\n', ...
        v, ...
        BiasRatio.(v), VarianceRatio.(v), MSERatio.(v));
end


