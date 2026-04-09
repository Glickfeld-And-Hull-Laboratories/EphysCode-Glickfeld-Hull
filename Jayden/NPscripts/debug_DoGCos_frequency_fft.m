function debug_DoGCos_frequency_fft(params, gridSize)
% debug_DoGCos_frequency_fft
%
% Visualize spatial-domain model pieces and their FFTs for the
% nonconcentric DoG x cosine model.
%
% params = [Ac, As, sigmaC, deltaSigma, tau, theta, ...
%           x0, y0, f, phi, dx, dy]
%
% gridSize: default 20
%
% Shows:
%   1) full model
%   2) center term
%   3) surround term
%   4) full FFT magnitude
%   5) center FFT magnitude
%   6) surround FFT magnitude
%
% Also prints the dominant FFT peak location and radial frequency.

    if nargin < 2 || isempty(gridSize)
        gridSize = 20;
    end

    [fullRF, centerRF, surroundRF, X, Y] = ...
        build_DoGCos_components(params, gridSize);

    % FFT magnitudes
    [F_full, fx, fy] = compute_fft2_mag(fullRF);
    [F_center, ~, ~] = compute_fft2_mag(centerRF);
    [F_surround, ~, ~] = compute_fft2_mag(surroundRF);

    % Find dominant non-DC peaks
    peak_full = find_fft_peak(F_full, fx, fy);
    peak_center = find_fft_peak(F_center, fx, fy);
    peak_surround = find_fft_peak(F_surround, fx, fy);

    fprintf('\n===== Frequency Debug =====\n');
    fprintf('Input f parameter = %.6f cycles/pixel\n', params(9));
    fprintf('Input period      = %.6f pixels/cycle\n', 1 / max(abs(params(9)), eps));

    fprintf('\nFull model peak:\n');
    print_peak_info(peak_full);

    fprintf('\nCenter term peak:\n');
    print_peak_info(peak_center);

    fprintf('\nSurround term peak:\n');
    print_peak_info(peak_surround);

    % Plot
    figure;

    subplot(2, 3, 1);
    imagesc(X(1, :), Y(:, 1), fullRF);
    axis image;
    colormap gray;
    colorbar;
    title('Full model');

    subplot(2, 3, 2);
    imagesc(X(1, :), Y(:, 1), centerRF);
    axis image;
    colormap gray;
    colorbar;
    title('Center Gabor term');

    subplot(2, 3, 3);
    imagesc(X(1, :), Y(:, 1), surroundRF);
    axis image;
    colormap gray;
    colorbar;
    title('Surround Gabor term');

    subplot(2, 3, 4);
    imagesc(fx, fy, log1p(F_full));
    axis image;
    colormap gray;
    colorbar;
    hold on;
    plot(peak_full.fx, peak_full.fy, 'ro', 'MarkerSize', 8, ...
        'LineWidth', 1.5);
    plot(-peak_full.fx, -peak_full.fy, 'ro', 'MarkerSize', 8, ...
        'LineWidth', 1.5);
    title(sprintf('FFT Full | peak r = %.3f', peak_full.fr));
    xlabel('f_x (cycles/pixel)');
    ylabel('f_y (cycles/pixel)');

    subplot(2, 3, 5);
    imagesc(fx, fy, log1p(F_center));
    axis image;
    colormap gray;
    colorbar;
    hold on;
    plot(peak_center.fx, peak_center.fy, 'ro', 'MarkerSize', 8, ...
        'LineWidth', 1.5);
    plot(-peak_center.fx, -peak_center.fy, 'ro', 'MarkerSize', 8, ...
        'LineWidth', 1.5);
    title(sprintf('FFT Center | peak r = %.3f', peak_center.fr));
    xlabel('f_x (cycles/pixel)');
    ylabel('f_y (cycles/pixel)');

    subplot(2, 3, 6);
    imagesc(fx, fy, log1p(F_surround));
    axis image;
    colormap gray;
    colorbar;
    hold on;
    plot(peak_surround.fx, peak_surround.fy, 'ro', 'MarkerSize', 8, ...
        'LineWidth', 1.5);
    plot(-peak_surround.fx, -peak_surround.fy, 'ro', 'MarkerSize', 8, ...
        'LineWidth', 1.5);
    title(sprintf('FFT Surround | peak r = %.3f', peak_surround.fr));
    xlabel('f_x (cycles/pixel)');
    ylabel('f_y (cycles/pixel)');
end