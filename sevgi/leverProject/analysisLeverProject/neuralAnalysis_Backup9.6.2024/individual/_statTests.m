% Assuming data is a column vector
data = abs(randn(1000,1)); % Example half-normal data

% Fit a half-normal distribution
pd_half_normal = fitdist(data, 'HalfNormal');

% Compare with a normal distribution
pd_normal = fitdist(data, 'Normal');

% Compare with a normal distribution
pd_wb = fitdist(data, 'Weibull');

% Plot fitted distributions
x = linspace(min(data), max(data), 100);
y_half_normal = pdf(pd_half_normal, x);
y_normal = pdf(pd_normal, x);
y_wb = pdf(pd_wb, x);

plot(x, y_half_normal, 'b', 'LineWidth', 2);
hold on;
plot(x, y_normal, 'r--', 'LineWidth', 2);
plot(x, y_wb, 'k--', 'LineWidth', 2);
hold off;
legend('Half-Normal Fit', 'Normal Fit','Weibull');

% Kolmogorov-Smirnov test for half-normal fit
[h_half, p_half] = kstest(data, 'CDF', pd_half_normal)

% Kolmogorov-Smirnov test for normal fit
[h_normal, p_normal] = kstest(data, 'CDF', pd_normal)

% Kolmogorov-Smirnov test for normal fit
[h_wb, p_wb] = kstest(data, 'CDF', pd_wb)

% Display results
fprintf('KS Test p-value for Half-Normal: %f %f\n', h_half, p_half);
fprintf('KS Test p-value for Normal: %f %f\n', h_normal, p_normal);
fprintf('KS Test p-value for Weibull: %f %f\n', h_wb, p_wb);
