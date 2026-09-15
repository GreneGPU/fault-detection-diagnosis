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

%% ---------------- Fault Detection for New Data ----------------
% Load the new dataset (FaultyCase3)
load('FaultyCase3.mat'); % This should load Set3_1

% Normalize Set3_1 exactly like the training data
Set3_1_norm = (Set3_1 - data_mean(ones(size(Set3_1,1),1),:)) ./ data_std(ones(size(Set3_1,1),1),:);

% Project the new data onto the principal components
T_new = Set3_1_norm * P;

% Calculate the T² statistic for Set3_1
T2_new = sum((T_new.^2) ./ diag(Sigma(1:num_components, 1:num_components))', 2);

% Identify faulty samples (T² > upper threshold)
faulty_samples = find(T2_new > upper_threshold);
num_faulty = length(faulty_samples);

% Display results
disp('T² Statistic for new dataset:');
disp(T2_new);
disp(['Number of faulty samples: ', num2str(num_faulty)]);
if num_faulty > 0
    disp('Fault detected in samples:');
    disp(faulty_samples');
else
    disp('No faults detected.');
end

% ---- Plot T² values on logarithmic scale and mark fault regions ----
figure;

% First, plot the T² values using semilogy
semilogy(T2_new, 'b', 'LineWidth', 1.5);
hold on;
yline(upper_threshold, 'r--', 'Upper Threshold', 'LineWidth', 2);

% Now get Y-axis limits
y_limits = ylim;

% Overlay transparent gray patches using fill (this works in log scale)
for i = 1:length(faulty_samples)
    x = faulty_samples(i);
    x_patch = [x-0.5 x+0.5 x+0.5 x-0.5];
    y_patch = [y_limits(1) y_limits(1) y_limits(2) y_limits(2)];
    fill(x_patch, y_patch, [0.85 0.85 0.85], ...
         'EdgeColor', 'none', ...
         'FaceAlpha', 0.4, ...
         'HandleVisibility', 'off'); % Keeps legend clean
end
%% ---------------- Fault Detection for New Data ----------------
% Load the new dataset (FaultyCase3)
load('FaultyCase3.mat'); % This should load Set3_1

% Normalize Set3_1 exactly like the training data
Set3_1_norm = (Set3_1 - data_mean(ones(size(Set3_1,1),1),:)) ./ data_std(ones(size(Set3_1,1),1),:);

% Project the new data onto the principal components
T_new = Set3_1_norm * P;

% Calculate the T² statistic for Set3_1
T2_new = sum((T_new.^2) ./ diag(Sigma(1:num_components, 1:num_components))', 2);

% Identify faulty samples (T² > upper threshold)
faulty_samples = find(T2_new > upper_threshold);
num_faulty = length(faulty_samples);

% Display results
disp('T² Statistic for new dataset:');
disp(T2_new);
disp(['Number of faulty samples: ', num2str(num_faulty)]);
if num_faulty > 0
    disp('Fault detected in samples:');
    disp(faulty_samples');
else
    disp('No faults detected.');
end

% ---- Plot T² values on logarithmic scale and mark fault regions ----
figure;

% First, plot the T² values using semilogy
semilogy(T2_new, 'b', 'LineWidth', 1.5);
hold on;
yline(upper_threshold, 'r--', 'Upper Threshold', 'LineWidth', 2);

% Now get Y-axis limits
y_limits = ylim;

% Overlay transparent gray patches using fill (this works in log scale)
for i = 1:length(faulty_samples)
    x = faulty_samples(i);
    x_patch = [x-0.5 x+0.5 x+0.5 x-0.5];
    y_patch = [y_limits(1) y_limits(1) y_limits(2) y_limits(2)];
    fill(x_patch, y_patch, [0.85 0.85 0.85], ...
         'EdgeColor', 'none', ...
         'FaceAlpha', 0.4, ...
         'HandleVisibility', 'off'); % Keeps legend clean
end
%% ---------------- Fault Detection for New Data ----------------
% Load the new dataset (FaultyCase3)
load('FaultyCase3.mat'); % This should load Set3_1

% Normalize Set3_1 exactly like the training data
Set3_1_norm = (Set3_1 - data_mean(ones(size(Set3_1,1),1),:)) ./ data_std(ones(size(Set3_1,1),1),:);

% Project the new data onto the principal components
T_new = Set3_1_norm * P;

% Calculate the T² statistic for Set3_1
T2_new = sum((T_new.^2) ./ diag(Sigma(1:num_components, 1:num_components))', 2);

% Identify faulty samples (T² > upper threshold)
faulty_samples = find(T2_new > upper_threshold);
num_faulty = length(faulty_samples);

% Display results
disp('T² Statistic for new dataset:');
disp(T2_new);
disp(['Number of faulty samples: ', num2str(num_faulty)]);
if num_faulty > 0
    disp('Fault detected in samples:');
    disp(faulty_samples');
else
    disp('No faults detected.');
end

% ---- Plot T² values on logarithmic scale and mark fault regions ----
figure;

% First, plot the T² values using semilogy
semilogy(T2_new, 'b', 'LineWidth', 1.5);
hold on;
yline(upper_threshold, 'r--', 'Upper Threshold', 'LineWidth', 2);

% Now get Y-axis limits
y_limits = ylim;

% Overlay transparent gray patches using fill (this works in log scale)
for i = 1:length(faulty_samples)
    x = faulty_samples(i);
    x_patch = [x-0.5 x+0.5 x+0.5 x-0.5];
    y_patch = [y_limits(1) y_limits(1) y_limits(2) y_limits(2)];
    fill(x_patch, y_patch, [0.85 0.85 0.85], ...
         'EdgeColor', 'none', ...
         'FaceAlpha', 0.4, ...
         'HandleVisibility', 'off'); % Keeps legend clean
end





%% ---------------- Fault Detection for New Data ----------------
% Load the new dataset (FaultyCase5)
load('FaultyCase5.mat'); % This should load Set5_2

% Normalize Set5_2 **exactly** like the training data
Set5_2_norm = (Set5_2 - data_mean(ones(size(Set5_2,1),1),:)) ./ data_std(ones(size(Set5_2,1),1),:);

% Project the new data onto the principal components
T_new = Set5_2_norm * P;

% Calculate the T² statistic for Set5_2
T2_new = sum((T_new.^2) ./ diag(Sigma(1:num_components, 1:num_components))', 2);

% Identify faulty samples (T² > upper threshold)
faulty_samples = find(T2_new > upper_threshold);
num_faulty = length(faulty_samples);

% Display results
disp('T² Statistic for new dataset:');
disp(T2_new);
disp(['Number of faulty samples: ', num2str(num_faulty)]);
if num_faulty > 0
    disp('Fault detected in samples:');
    disp(faulty_samples');
else
    disp('No faults detected.');
end

% Plot the T² statistic with thresholds
figure;
semilogy(T2_new, 'b', 'LineWidth', 1.5); % Logarithmic Y-axis
hold on;
yline(upper_threshold, 'r--', 'Upper Threshold', 'LineWidth', 2);
title('T² Statistic for Fault Detection in Set5_2');
xlabel('Sample');
ylabel('T² (Log Scale)');
legend('T² values', 'Upper Threshold');
hold off;

