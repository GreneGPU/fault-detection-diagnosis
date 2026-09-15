clear all
close all
clc

%% Load training data
load('training.mat'); 
data_combined = [T1; T2; T3];

%% Normalize for PCA
data_mean = mean(data_combined);
data_std = std(data_combined);
data_norm = (data_combined - data_mean) ./ data_std;

%% PCA
cov_matrix = cov(data_norm);
[U, Sigma, V] = svd(cov_matrix);
num_components = 3;
P_pca = V(:, 1:num_components);
T_pca = data_norm * P_pca;
T2_pca = sum((T_pca.^2) ./ diag(Sigma(1:num_components, 1:num_components))', 2);
Q_pca = sum((data_norm - T_pca * P_pca').^2, 2);
T2_threshold_pca = max(T2_pca);
Q_threshold_pca = max(Q_pca);

%% DPCA
num_lags = 2;
data_lagged = [];
for lag = 0:num_lags
    data_lagged = [data_lagged circshift(data_combined, lag)];
end
data_lagged = data_lagged(num_lags+1:end, :);
data_mean_dpca = mean(data_lagged);
data_std_dpca = std(data_lagged);
data_norm_dpca = (data_lagged - data_mean_dpca) ./ data_std_dpca;
cov_matrix_dpca = cov(data_norm_dpca);
[U_dpca, Sigma_dpca, V_dpca] = svd(cov_matrix_dpca);
P_dpca = V_dpca(:, 1:num_components);
T_dpca = data_norm_dpca * P_dpca;
T2_dpca = sum((T_dpca.^2) ./ diag(Sigma_dpca(1:num_components, 1:num_components))', 2);
Q_dpca = sum((data_norm_dpca - T_dpca * P_dpca').^2, 2);
T2_threshold_dpca = max(T2_dpca);
Q_threshold_dpca = max(Q_dpca);

%% Load FaultyCase1 data
load('FaultyCase3.mat');
new_data = Set3_1;

%% PCA statistics on new data
new_data_norm = (new_data - data_mean) ./ data_std;
T_new_pca = new_data_norm * P_pca;
T2_new_pca = sum((T_new_pca.^2) ./ diag(Sigma(1:num_components, 1:num_components))', 2);
Q_new_pca = sum((new_data_norm - T_new_pca * P_pca').^2, 2);

%% DPCA statistics on new data
data_lagged_new = [];
for lag = 0:num_lags
    data_lagged_new = [data_lagged_new circshift(new_data, lag)];
end
data_lagged_new = data_lagged_new(num_lags+1:end, :);
new_data_norm_dpca = (data_lagged_new - data_mean_dpca) ./ data_std_dpca;
T_new_dpca = new_data_norm_dpca * P_dpca;
T2_new_dpca = sum((T_new_dpca.^2) ./ diag(Sigma_dpca(1:num_components, 1:num_components))', 2);
Q_new_dpca = sum((new_data_norm_dpca - T_new_dpca * P_dpca').^2, 2);

%% Highlighting index where PCA ≠ DPCA (fault detection difference)
% Align PCA outputs to DPCA size
T2_new_pca_trimmed = T2_new_pca(num_lags+1:end);
Q_new_pca_trimmed = Q_new_pca(num_lags+1:end);

% Compute difference mask
diff_t2 = xor(T2_new_pca_trimmed > T2_threshold_pca, T2_new_dpca > T2_threshold_dpca);
diff_q = xor(Q_new_pca_trimmed > Q_threshold_pca, Q_new_dpca > Q_threshold_dpca);

%% Plot T² Statistic Comparison
figure('Name', 'T² Statistic Comparison with Differences', 'NumberTitle', 'off');

subplot(2,1,1);
semilogy(T2_new_pca, 'b', 'LineWidth', 1.5); hold on;
yline(T2_threshold_pca, 'r--', 'PCA Threshold', 'LineWidth', 2);
title('PCA T² Statistic Case3.1');
xlabel('Sample'); ylabel('T² (Log Scale)'); grid on;
yl1 = ylim;
for x = find(diff_t2)'
    patch([x-0.5 x+0.5 x+0.5 x-0.5], [yl1(1) yl1(1) yl1(2) yl1(2)], ...
        [0.2 0.2 0.2], 'EdgeColor', 'none', 'FaceAlpha', 0.3);
end
semilogy(T2_new_pca, 'b', 'LineWidth', 1.5); % Redraw line

subplot(2,1,2);
semilogy(T2_new_dpca, 'g', 'LineWidth', 1.5); hold on;
yline(T2_threshold_dpca, 'r--', 'DPCA Threshold', 'LineWidth', 2);
title('DPCA T² Statistic Case3.1');
xlabel('Sample'); ylabel('T² (Log Scale)'); grid on;
yl2 = ylim;
for x = find(diff_t2)'
    patch([x-0.5 x+0.5 x+0.5 x-0.5], [yl2(1) yl2(1) yl2(2) yl2(2)], ...
        [0.2 0.2 0.2], 'EdgeColor', 'none', 'FaceAlpha', 0.3);
end
semilogy(T2_new_dpca, 'g', 'LineWidth', 1.5); % Redraw line

%% Plot Q Statistic Comparison
figure('Name', 'Q Statistic Comparison with Differences', 'NumberTitle', 'off');

subplot(2,1,1);
semilogy(Q_new_pca, 'b', 'LineWidth', 1.5); hold on;
yline(Q_threshold_pca, 'r--', 'PCA Threshold', 'LineWidth', 2);
title('PCA Q Statistic Case3.1');
xlabel('Sample'); ylabel('Q (Log Scale)'); grid on;
yl3 = ylim;
for x = find(diff_q)'
    patch([x-0.5 x+0.5 x+0.5 x-0.5], [yl3(1) yl3(1) yl3(2) yl3(2)], ...
        [0.2 0.2 0.2], 'EdgeColor', 'none', 'FaceAlpha', 0.3);
end
semilogy(Q_new_pca, 'b', 'LineWidth', 1.5); % Redraw line

subplot(2,1,2);
semilogy(Q_new_dpca, 'g', 'LineWidth', 1.5); hold on;
yline(Q_threshold_dpca, 'r--', 'DPCA Threshold', 'LineWidth', 2);
title('DPCA Q Statistic Case3.1');
xlabel('Sample'); ylabel('Q (Log Scale)'); grid on;
yl4 = ylim;
for x = find(diff_q)'
    patch([x-0.5 x+0.5 x+0.5 x-0.5], [yl4(1) yl4(1) yl4(2) yl4(2)], ...
        [0.2 0.2 0.2], 'EdgeColor', 'none', 'FaceAlpha', 0.3);
end
semilogy(Q_new_dpca, 'g', 'LineWidth', 1.5); % Redraw line
