clear all
close all
clc

%% Load training data
load('training.mat'); 

% Combine training data
data_combined = [T1; T2; T3];

% Parameters
num_components = 3; % Number of principal components
num_lags = 2;       % Number of lags for DPCA

%% Construct lagged matrix
data_lagged = [];
for lag = 0:num_lags
    data_lagged = [data_lagged circshift(data_combined, lag)];
end
data_lagged = data_lagged(num_lags+1:end, :);  % Remove initial lagged rows

% Normalize
data_mean = mean(data_lagged);
data_std = std(data_lagged);
data_norm = (data_lagged - data_mean) ./ data_std;

% Covariance and SVD
cov_matrix = cov(data_norm);
[U, Sigma, V] = svd(cov_matrix);

P = V(:, 1:num_components); % Principal components
T = data_norm * P;          % DPCA scores

%% T² Statistic
T2 = sum((T.^2) ./ diag(Sigma(1:num_components, 1:num_components))', 2);
upper_threshold = max(T2);

%% Q Statistic (SPE)
I = eye(size(P,1));
residual = data_norm * (I - P*P');
Q = sum(residual.^2, 2);
Q_threshold = max(Q);

%% Plot training T² and Q statistics
figure('Name', 'DPCA Training Data', 'NumberTitle', 'off');

subplot(2,1,1);
semilogy(T2, 'b', 'LineWidth', 1.5);
yline(upper_threshold, 'r--', 'Upper Threshold', 'LineWidth', 2);
title('T² Statistic for Fault Detection (Training Data - DPCA)');
xlabel('Sample'); ylabel('T² (Log Scale)'); grid on;

subplot(2,1,2);
semilogy(Q, 'b', 'LineWidth', 1.5);
yline(Q_threshold, 'r--', 'Q Threshold', 'LineWidth', 2);
title('Q Statistic (SPE) for Fault Detection (Training Data - DPCA)');
xlabel('Sample'); ylabel('Q (Log Scale)'); grid on;

%% Function DPCA
function detectFaultsDPCA(new_data, data_mean, data_std, P, Sigma, num_components, T2_threshold, Q_threshold, dataset_name, num_lags)
    % Create lagged matrix for test data
    data_lagged = [];
    for lag = 0:num_lags
        data_lagged = [data_lagged circshift(new_data, lag)];
    end
    data_lagged = data_lagged(num_lags+1:end, :);

    % Normalize
    new_data_norm = (data_lagged - data_mean) ./ data_std;

    % DPCA scores
    T_new = new_data_norm * P;

    % T² statistic
    T2_new = sum((T_new.^2) ./ diag(Sigma(1:num_components, 1:num_components))', 2);
    faulty_T2 = find(T2_new > T2_threshold);

    % Q statistic
    I = eye(size(P,1));
    residual = new_data_norm * (I - P*P');
    Q_new = sum(residual.^2, 2);
    faulty_Q = find(Q_new > Q_threshold);

    % Plot
    figure('Name', ['DPCA ', dataset_name], 'NumberTitle', 'off');

    % ---- T² subplot ----
    subplot(2,1,1);
    semilogy(T2_new, 'b', 'LineWidth', 1.5); hold on;
    yline(T2_threshold, 'r--', 'T² Threshold', 'LineWidth', 2);
    yl = ylim;
    for i = 1:length(faulty_T2)
        x = faulty_T2(i);
        patch([x-0.5 x+0.5 x+0.5 x-0.5], [yl(1) yl(1) yl(2) yl(2)], ...
              [0.8 0.8 0.8], 'EdgeColor', 'none', 'FaceAlpha', 0.4);
    end
    semilogy(T2_new, 'b', 'LineWidth', 1.5); % Redraw line over patches
    title(['T² Statistic - ', dataset_name], 'Interpreter', 'none');
    xlabel('Sample'); ylabel('T² (Log Scale)');
    legend('T² values', 'T² Threshold');
    grid on;

    % ---- Q subplot ----
    subplot(2,1,2);
    semilogy(Q_new, 'b', 'LineWidth', 1.5); hold on;
    yline(Q_threshold, 'r--', 'Q Threshold', 'LineWidth', 2);
    ylq = ylim;
    for i = 1:length(faulty_Q)
        x = faulty_Q(i);
        patch([x-0.5 x+0.5 x+0.5 x-0.5], [ylq(1) ylq(1) ylq(2) ylq(2)], ...
              [0.8 0.8 0.8], 'EdgeColor', 'none', 'FaceAlpha', 0.4);
    end
    semilogy(Q_new, 'b', 'LineWidth', 1.5); % Redraw line
    title(['Q Statistic (SPE) - ', dataset_name], 'Interpreter', 'none');
    xlabel('Sample'); ylabel('Q (Log Scale)');
    legend('Q values', 'Q Threshold');
    grid on;
end
%% Case 1
 load('FaultyCase1.mat');
 detectFaultsDPCA(Set1_1, data_mean, data_std, P, Sigma, num_components, upper_threshold, Q_threshold, 'Set1_1', num_lags);
 detectFaultsDPCA(Set1_2, data_mean, data_std, P, Sigma, num_components, upper_threshold, Q_threshold, 'Set1_2', num_lags);
 detectFaultsDPCA(Set1_3, data_mean, data_std, P, Sigma, num_components, upper_threshold, Q_threshold, 'Set1_3', num_lags);

 %% Case 2
 load('FaultyCase2.mat');
 detectFaultsDPCA(Set2_1, data_mean, data_std, P, Sigma, num_components, upper_threshold, Q_threshold, 'Set2_1', num_lags);
 detectFaultsDPCA(Set2_2, data_mean, data_std, P, Sigma, num_components, upper_threshold, Q_threshold, 'Set2_2', num_lags);
 detectFaultsDPCA(Set2_3, data_mean, data_std, P, Sigma, num_components, upper_threshold, Q_threshold, 'Set2_3', num_lags);

 %% Case 3
 load('FaultyCase3.mat');
 detectFaultsDPCA(Set3_1, data_mean, data_std, P, Sigma, num_components, upper_threshold, Q_threshold, 'Set3_1', num_lags);
 detectFaultsDPCA(Set3_2, data_mean, data_std, P, Sigma, num_components, upper_threshold, Q_threshold, 'Set3_2', num_lags);
 detectFaultsDPCA(Set3_3, data_mean, data_std, P, Sigma, num_components, upper_threshold, Q_threshold, 'Set3_3', num_lags);

 %% Case 4
 load('FaultyCase4.mat');
 detectFaultsDPCA(Set4_1, data_mean, data_std, P, Sigma, num_components, upper_threshold, Q_threshold, 'Set4_1', num_lags);
 detectFaultsDPCA(Set4_2, data_mean, data_std, P, Sigma, num_components, upper_threshold, Q_threshold, 'Set4_2', num_lags);
 detectFaultsDPCA(Set4_3, data_mean, data_std, P, Sigma, num_components, upper_threshold, Q_threshold, 'Set4_3', num_lags);

 %% Case 5
 load('FaultyCase5.mat');
 detectFaultsDPCA(Set5_1, data_mean, data_std, P, Sigma, num_components, upper_threshold, Q_threshold, 'Set5_1', num_lags);
 detectFaultsDPCA(Set5_2, data_mean, data_std, P, Sigma, num_components, upper_threshold, Q_threshold, 'Set5_2', num_lags);

 %% Case 6
 load('FaultyCase6.mat');
 detectFaultsDPCA(Set6_1, data_mean, data_std, P, Sigma, num_components, upper_threshold, Q_threshold, 'Set6_1', num_lags);
 detectFaultsDPCA(Set6_2, data_mean, data_std, P, Sigma, num_components, upper_threshold, Q_threshold, 'Set6_2', num_lags);
 