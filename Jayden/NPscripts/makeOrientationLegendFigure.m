figure('Color', 'w', 'Position', [300 500 600 260]);
hold on;
axis equal;
axis off;

% Darker colors
redCol    = [0.65 0.00 0.00];
yellowCol = [0.75 0.55 0.00];
blueCol   = [0.00 0.25 0.70];
greenCol  = [0.00 0.45 0.00];
purpleCol = [0.45 0.00 0.55];

t = linspace(0, 2*pi, 300);

% Example ellipses
plot(1.2*cos(t), 0.6*sin(t), ...
    'Color', greenCol, 'LineWidth', 3);

plot(1.7*cos(t), 0.9*sin(t), ...
    'Color', purpleCol, 'LineWidth', 3);

% Example orientation lines
plot([-1.4 1.4], [0.5 -0.5], ...
    'Color', redCol, 'LineWidth', 4);

plot([-0.6 0.6], [-1.1 1.1], ...
    'Color', yellowCol, 'LineWidth', 4);

plot([-1.0 1.0], [-1.0 1.0], ...
    'Color', blueCol, 'LineWidth', 4);

% Labels
text(2.4,  0.65, 'Center envelope', ...
    'Color', greenCol, 'FontSize', 14, 'FontWeight', 'bold');

text(2.4,  0.30, 'Surround envelope', ...
    'Color', purpleCol, 'FontSize', 14, 'FontWeight', 'bold');

text(2.4, -0.10, 'Envelope orientation', ...
    'Color', redCol, 'FontSize', 14, 'FontWeight', 'bold');

text(2.4, -0.50, 'Carrier orientation', ...
    'Color', yellowCol, 'FontSize', 14, 'FontWeight', 'bold');

text(2.4, -0.90, 'Grating tuning data orientation', ...
    'Color', blueCol, 'FontSize', 14, 'FontWeight', 'bold');

xlim([-2 7]);
ylim([-1.5 1.5]);

title('Legend for RF and Tuning Orientation Overlay', ...
    'FontSize', 16, 'FontWeight', 'bold');