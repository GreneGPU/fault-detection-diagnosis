clear all
close all
clc

load('training.mat'); 

data_combined = [T1; T2; T3];

% Normalize the combined data
data_mean = mean(data_combined);
data_std = std(data_combined);
data_norm = (data_combined - data_mean(ones(size(data_combined,1),1),:)) ./ data_std(ones(size(data_combined,1),1),:);

% Calculate covariance matrix and perform SVD
cov_matrix = cov(data_norm);
[U, Sigma, V] = svd(cov_matrix);

% Number of principal components
num_components = 3;
P = V(:, 1:num_components);

% PCA score matrix
T = data_norm * P;

% ---------------------- T² Statistic ----------------------
T2 = sum((T.^2) ./ diag(Sigma(1:num_components, 1:num_components))', 2);

% T² thresholds
upper_threshold = max(T2); 
lower_threshold = min(T2);

% ---------------------- Q Statistic (SPE) ----------------------
singular_vals = diag(Sigma);
residual_singular_vals = singular_vals(num_components+1:end);

I = eye(size(P*P'));
residual = data_norm * (I - P*P');
Q = sum(residual.^2, 2);

Q_threshold = max(Q);

% ---------------------- Combined Plot ----------------------
 figure('Name', ['PCA Training Data'], 'NumberTitle', 'off');

% --- T² Plot ---
subplot(2,1,1);
semilogy(T2, 'b', 'LineWidth', 1.5);
hold on;
yline(upper_threshold, 'r--', 'Upper Threshold', 'LineWidth', 2);
title('T² Statistic for Fault Detection (Training Data)');
xlabel('Sample');
ylabel('T² (Log Scale)');
legend('T² values', 'Upper Threshold');
grid on;
hold off;

% --- Q Plot ---
subplot(2,1,2);
semilogy(Q, 'b', 'LineWidth', 1.5);
hold on;
yline(Q_threshold, 'r--', 'Q Threshold', 'LineWidth', 2);
title('Q Statistic (SPE) for Fault Detection (Training Data)');
xlabel('Sample');
ylabel('Q (Log Scale)');
legend('Q values', 'Q Threshold');
grid on;
hold off;

%% function
function detectFaultsPCA(new_data, data_mean, data_std, P, Sigma, num_components, T2_threshold, Q_threshold, dataset_name)
% detectFaultsPCA Detects faults in new data using PCA T² and Q statistics with proper log-scale plotting.
%
% Parameters:
%   new_data         - New dataset (matrix) to test
%   data_mean        - Mean from training data (row vector)
%   data_std         - Std deviation from training data (row vector)
%   P                - Principal component matrix from training
%   Sigma            - Singular values (from SVD of covariance matrix)
%   num_components   - Number of retained principal components
%   T2_threshold     - T² threshold (scalar)
%   Q_threshold      - Q (SPE) threshold (scalar)
%   dataset_name     - (string) Name of the dataset for labeling

    % Normalize new data
    n_samples = size(new_data, 1);
    new_data_norm = (new_data - data_mean(ones(n_samples,1), :)) ./ data_std(ones(n_samples,1), :);

    % Project onto PCA space
    T_new = new_data_norm * P;

    % T² statistic
    T2_new = sum((T_new.^2) ./ diag(Sigma(1:num_components, 1:num_components))', 2);
    faulty_T2 = find(T2_new > T2_threshold);

    % Q-statistic (SPE)
    I = eye(size(P * P'));
    residual = new_data_norm * (I - P * P');
    Q_new = sum(residual.^2, 2);
    faulty_Q = find(Q_new > Q_threshold);

    % --- Plotting ---
    figure('Name', ['PCA ', dataset_name], 'NumberTitle', 'off');


    % ---- T² subplot ----
    subplot(2,1,1);
    semilogy(T2_new, 'b', 'LineWidth', 1.5); hold on;
    yline(T2_threshold, 'r--', 'T² Threshold', 'LineWidth', 2);
    yl = ylim;
    for i = 1:length(faulty_T2)
        x = faulty_T2(i);
        patch([x-0.5 x+0.5 x+0.5 x-0.5], [yl(1) yl(1) yl(2) yl(2)], ...
              [0.4 0.4 0.4], 'EdgeColor', 'none', 'FaceAlpha', 0.4);
    end
    semilogy(T2_new, 'b', 'LineWidth', 1.5); % Redraw line over patches
    yline(T2_threshold, 'r--', 'T² Threshold', 'LineWidth', 2);
    ylim(yl);
    title(['T² Statistic - ', dataset_name], 'Interpreter', 'none');
    xlabel('Sample');
    ylabel('T² (Log Scale)');
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
              [0.4 0.4 0.4], 'EdgeColor', 'none', 'FaceAlpha', 0.4);
    end
    semilogy(Q_new, 'b', 'LineWidth', 1.5); % Redraw line
    yline(Q_threshold, 'r--', 'Q Threshold', 'LineWidth', 2);
    ylim(ylq);
    title(['Q Statistic (SPE) - ', dataset_name], 'Interpreter', 'none');
    xlabel('Sample');
    ylabel('Q (Log Scale)');
    legend('Q values', 'Q Threshold');
    grid on;
end

%% case 1
load('FaultyCase1.mat');
detectFaultsPCA(Set1_1, data_mean, data_std, P, Sigma, num_components, upper_threshold, Q_threshold, 'Set1_1');
detectFaultsPCA(Set1_2, data_mean, data_std, P, Sigma, num_components, upper_threshold, Q_threshold, 'Set1_2');
detectFaultsPCA(Set1_3, data_mean, data_std, P, Sigma, num_components, upper_threshold, Q_threshold, 'Set1_3');

%% case 2
load('FaultyCase2.mat');
detectFaultsPCA(Set2_1, data_mean, data_std, P, Sigma, num_components, upper_threshold, Q_threshold, 'Set2_1');
detectFaultsPCA(Set2_2, data_mean, data_std, P, Sigma, num_components, upper_threshold, Q_threshold, 'Set2_2');
detectFaultsPCA(Set2_3, data_mean, data_std, P, Sigma, num_components, upper_threshold, Q_threshold, 'Set2_3');

%% case 3
load('FaultyCase3.mat');
detectFaultsPCA(Set3_1, data_mean, data_std, P, Sigma, num_components, upper_threshold, Q_threshold, 'Set3_1');
detectFaultsPCA(Set3_2, data_mean, data_std, P, Sigma, num_components, upper_threshold, Q_threshold, 'Set3_2');
detectFaultsPCA(Set3_3, data_mean, data_std, P, Sigma, num_components, upper_threshold, Q_threshold, 'Set3_3');

%% case 4
load('FaultyCase4.mat');
detectFaultsPCA(Set4_1, data_mean, data_std, P, Sigma, num_components, upper_threshold, Q_threshold, 'Set4_1');
detectFaultsPCA(Set4_2, data_mean, data_std, P, Sigma, num_components, upper_threshold, Q_threshold, 'Set4_2');
detectFaultsPCA(Set4_3, data_mean, data_std, P, Sigma, num_components, upper_threshold, Q_threshold, 'Set4_3');

%% case 5
load('FaultyCase5.mat');
detectFaultsPCA(Set5_1, data_mean, data_std, P, Sigma, num_components, upper_threshold, Q_threshold, 'Set5_1');
detectFaultsPCA(Set5_2, data_mean, data_std, P, Sigma, num_components, upper_threshold, Q_threshold, 'Set5_2');


%% case 6
load('FaultyCase6.mat');
detectFaultsPCA(Set6_1, data_mean, data_std, P, Sigma, num_components, upper_threshold, Q_threshold, 'Set6_1');
detectFaultsPCA(Set6_2, data_mean, data_std, P, Sigma, num_components, upper_threshold, Q_threshold, 'Set6_2');
