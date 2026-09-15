% Load the training data
load('training.mat'); % This should load T1, T2, and T3

% Combine the datasets T1, T2, and T3
data_combined = [T1; T2; T3];

% Normalize the combined data
data_mean = mean(data_combined);
data_std = std(data_combined);
data_norm = (data_combined - data_mean) ./ data_std;

% Calculate the covariance matrix
cov_matrix = cov(data_norm);

% Perform Singular Value Decomposition (SVD)
[U, Sigma, V] = svd(cov_matrix);

% Select the number of principal components to retain
num_components = 3; % Example: Retaining 3 principal components
P = V(:, 1:num_components);

% Calculate the score matrix
T = data_norm * P;

% Calculate the T² statistic for each sample
T2 = sum((T.^2) ./ diag(Sigma(1:num_components, 1:num_components))', 2);

% Calculate the upper and lower thresholds
upper_threshold = max(T2);
lower_threshold = min(T2); % Alternatively, use a percentile: prctile(T2, 5)

% Display the results
disp('Principal Components:');
disp(P);
disp('T² Statistic:');
disp(T2);
disp(['Upper Threshold to include all data points: ', num2str(upper_threshold)]);
disp(['Lower Threshold: ', num2str(lower_threshold)]);

% Plot the T² statistic with the thresholds
figure;
plot(T2);
hold on;
yline(upper_threshold, 'r', 'Upper Threshold');
yline(lower_threshold, 'b', 'Lower Threshold');
title('T² Statistic for Fault Detection');
xlabel('Sample');
ylabel('T²');
hold off;

% Load the training data
load('training.mat'); % This should load T1, T2, and T3

% Combine the datasets T1, T2, and T3
data_combined = [T1; T2; T3];

% Normalize the combined data
data_mean = mean(data_combined);
data_std = std(data_combined);
data_norm = (data_combined - data_mean(ones(size(data_combined,1),1),:)) ./ data_std(ones(size(data_combined,1),1),:);

% Calculate the covariance matrix
cov_matrix = cov(data_norm);

% Perform Singular Value Decomposition (SVD)
[U, Sigma, V] = svd(cov_matrix);

% Select the number of principal components to retain
num_components = 3; % Example: Retaining 3 principal components
P = V(:, 1:num_components);

% Calculate the score matrix
T = data_norm * P;

% Calculate the T² statistic for each sample
T2 = sum((T.^2) ./ diag(Sigma(1:num_components, 1:num_components))', 2);

% Define the upper threshold (use max or 95th percentile)
upper_threshold = max(T2);
lower_threshold = min(T2); % Alternatively, use a percentile: prctile(T2, 5)

% Display threshold values
disp(['Upper Threshold: ', num2str(upper_threshold)]);
disp(['Lower Threshold: ', num2str(lower_threshold)]);

% Plot the T² statistic with the threshold
figure;
semilogy(T2, 'b', 'LineWidth', 1.5); % Use semilogy for logarithmic Y-axis
hold on;
yline(upper_threshold, 'r--', 'Upper Threshold', 'LineWidth', 2);
title('T² Statistic for Fault Detection (Training Data)');
xlabel('Sample');
ylabel('T² (Log Scale)');
legend('T² values', 'Upper Threshold');
hold off;

function detectFaultsPCA(new_data, data_mean, data_std, P, Sigma, num_components, upper_threshold, dataset_name)
% detectFaultsPCA Detects faults in new data using PCA T² statistic.
%
% Parameters:
%   new_data         - New dataset (matrix) to test
%   data_mean        - Mean from training data (row vector)
%   data_std         - Std deviation from training data (row vector)
%   P                - Principal component matrix from training
%   Sigma            - Singular values (from SVD of covariance matrix)
%   num_components   - Number of retained principal components
%   upper_threshold  - T² threshold (scalar)
%   dataset_name     - (string) Name of the dataset for labeling

    % Normalize new data using training parameters
    n_samples = size(new_data,1);
    new_data_norm = (new_data - data_mean(ones(n_samples,1), :)) ./ data_std(ones(n_samples,1), :);

    % Project onto PCA space
    T_new = new_data_norm * P;

    % Compute T² statistic
    T2_new = sum((T_new.^2) ./ diag(Sigma(1:num_components, 1:num_components))', 2);

    % Find faulty samples
    faulty_samples = find(T2_new > upper_threshold);
    num_faulty = length(faulty_samples);

    % Display
    fprintf('T² values for new data:\n');
    disp(T2_new);
    fprintf('Number of faulty samples: %d\n', num_faulty);
    if num_faulty > 0
        fprintf('Faulty sample indices: ');
        disp(faulty_samples');
    else
        disp('No faults detected.');
    end

    % Plot
    figure;
    semilogy(T2_new, 'b', 'LineWidth', 1.5);
    hold on;
    yline(upper_threshold, 'r--', 'Upper Threshold', 'LineWidth', 2);

    % Shade faulty samples
    y_limits = ylim;
    for i = 1:length(faulty_samples)
        x = faulty_samples(i);
        fill([x-0.5 x+0.5 x+0.5 x-0.5], ...
             [y_limits(1) y_limits(1) y_limits(2) y_limits(2)], ...
             [0.85 0.85 0.85], ...
             'EdgeColor', 'none', ...
             'FaceAlpha', 0.4, ...
             'HandleVisibility', 'off');
    end

    % Redraw on top
    semilogy(T2_new, 'b', 'LineWidth', 1.5);
    yline(upper_threshold, 'r--', 'Upper Threshold', 'LineWidth', 2);

    % Title includes dataset name
    title(['T² Statistic for Fault Detection in ', dataset_name], 'Interpreter', 'none');
    xlabel('Sample');
    ylabel('T² (Log Scale)');
    legend('T² values', 'Upper Threshold', 'Location', 'best');
    ylim(y_limits);
    hold off;
end


% Step 2: Load new dataset
load('FaultyCase3.mat'); % Contains Set3_1

% Step 3: Call the function to detect faults
detectFaultsPCA(Set3_1, data_mean, data_std, P, Sigma, num_components, upper_threshold, 'Set3_1');
detectFaultsPCA(Set3_2, data_mean, data_std, P, Sigma, num_components, upper_threshold, 'Set3_2');
detectFaultsPCA(Set3_3, data_mean, data_std, P, Sigma, num_components, upper_threshold, 'Set3_3');



