clear all; close all

%% Create 3 grating tuning curves
% 2 gaussians and 1 difference of gaussians

% x range
x = linspace(-180,150,12); % sample only 12 directions

% parameters 
A1 = 3.5;    % amplitude of g1 (center peak)
s1 = 25;     % width of g1
c1 = -20;    % center of g1

A2 = 1.2;    % amplitude of g2 (will be subtracted from g1 to form DoG)
s2 = 60;     % width of g2
c2 = -20;    % center of g2

baseline = 0.2; % vertical shift

% Gaussians
g1 = A1 * exp(-(x - c1).^2 / (2*s1^2));
g2 = A2 * exp(-(x - c2).^2 / (2*s2^2));

% Difference of Gaussians
y = g1 - g2 + baseline;

% Plot grating tuning curves
figure; 
movegui('center')
    subplot 421
        plot(x, y, 'LineWidth', 2); hold on;
        plot(x, g1, '--');
        plot(x, g2, '--');
        grid on;
        
        legend('DoG', 'Gaussian 1', 'Gaussian 2');
        xlabel('x'); ylabel('y');
        title('Grating tuning curves');


%% Generate component predictions

    int = 30;   %direction step size
    compPred_g1 = circshift(g1,+60./int,2)+circshift(g1,-60./int,2);
    pattPred_g1 = g1;
    compPred_g2 = circshift(g2,+60./int,2)+circshift(g2,-60./int,2);
    pattPred_g2 = g2;
    compPred_y = circshift(y,+60./int,2)+circshift(y,-60./int,2);
    pattPred_y = y;


% Plot component predictions
    subplot 422
        plot(x, compPred_y, 'LineWidth', 2); hold on;
        plot(x, compPred_g1, '--');
        plot(x, compPred_g2, '--');
        grid on;
        
        legend('DoG', 'Gaussian 1', 'Gaussian 2');
        xlabel('x'); ylabel('y');
        title('Component predictions');


%% Generate plaid responses, vary width

% Parameters (vectorized)
    A = [3 3 3 3];
    s = [20 30 40 50];
    c = [-20 -20 -20 -20];
    baseline = 0.2;
    nCond = numel(A);

% Colormap (gradient)
    colors = parula(nCond);   % or: lines(nCond), turbo(nCond)

% Preallocate
    plaidResp = cell(1,nCond);
    Zp_g1 = zeros(1,nCond); Zc_g1 = zeros(1,nCond);
    Zp_g2 = zeros(1,nCond); Zc_g2 = zeros(1,nCond);
    Zp_y  = zeros(1,nCond); Zc_y  = zeros(1,nCond);

%Plaid responses 
subplot(4,2,3); hold on;
    for i = 1:nCond
        plaidResp{i} = A(i) * exp(-(x - c(i)).^2 / (2*s(i)^2));
        plot(x, plaidResp{i}, 'LineWidth', 2, 'Color', colors(i,:));
    end
    grid on;
    legend(arrayfun(@(i) sprintf('s%d',i),1:nCond,'UniformOutput',false));
    xlabel('x'); ylabel('y');
    title('Plaid responses');

% Loop over conditions
for i = 1:nCond
    
    pr = plaidResp{i};
    
    % ---- g1 ----
    comp_corr      = triu2vec(corrcoef(pr, compPred_g1));
    patt_corr      = triu2vec(corrcoef(pr, g1));
    comp_patt_corr = triu2vec(corrcoef(compPred_g1, g1));
    Rp = ((patt_corr)-(comp_corr.*comp_patt_corr)) ./ sqrt((1-comp_corr.^2).*(1-comp_patt_corr.^2));
    Rc = ((comp_corr)-(patt_corr.*comp_patt_corr)) ./ sqrt((1-patt_corr.^2).*(1-comp_patt_corr.^2));
    Zp_g1(i) = (0.5.*log((1+Rp)./(1-Rp))) ./ sqrt(1/(12-3));
    Zc_g1(i) = (0.5.*log((1+Rc)./(1-Rc))) ./ sqrt(1/(12-3));
    
    % ---- g2 ----
    comp_corr      = triu2vec(corrcoef(pr, compPred_g2));
    patt_corr      = triu2vec(corrcoef(pr, g2));
    comp_patt_corr = triu2vec(corrcoef(compPred_g2, g2));
    Rp = ((patt_corr)-(comp_corr.*comp_patt_corr)) ./ sqrt((1-comp_corr.^2).*(1-comp_patt_corr.^2));
    Rc = ((comp_corr)-(patt_corr.*comp_patt_corr)) ./ sqrt((1-patt_corr.^2).*(1-comp_patt_corr.^2));
    Zp_g2(i) = (0.5.*log((1+Rp)./(1-Rp))) ./ sqrt(1/(12-3));
    Zc_g2(i) = (0.5.*log((1+Rc)./(1-Rc))) ./ sqrt(1/(12-3));
    
    % ---- y ----
    comp_corr      = triu2vec(corrcoef(pr, compPred_y));
    patt_corr      = triu2vec(corrcoef(pr, y));
    comp_patt_corr = triu2vec(corrcoef(compPred_y, y));
    Rp = ((patt_corr)-(comp_corr.*comp_patt_corr)) ./ sqrt((1-comp_corr.^2).*(1-comp_patt_corr.^2));
    Rc = ((comp_corr)-(patt_corr.*comp_patt_corr)) ./ sqrt((1-patt_corr.^2).*(1-comp_patt_corr.^2));
    Zp_y(i) = (0.5.*log((1+Rp)./(1-Rp))) ./ sqrt(1/(12-3));
    Zc_y(i) = (0.5.*log((1+Rc)./(1-Rc))) ./ sqrt(1/(12-3));
end

% ZpZc plot
subplot(4,2,4); hold on;
    h = gobjects(nCond,1); % for legend handles
    for i = 1:nCond
        % plot all 3 points for this condition with SAME color
        scatter(Zc_y(i),  Zp_y(i),  70, colors(i,:), 'filled');
        scatter(Zc_g1(i), Zp_g1(i), 70, colors(i,:), 'o');
        h(i) = scatter(Zc_g2(i), Zp_g2(i), 70, colors(i,:), 'd'); % store handle
    end
    legend(h, arrayfun(@(i) sprintf('s%d',i),1:nCond,'UniformOutput',false));
    title('Plaid responses (all conditions)');
    plotZcZpBorders;
    axis square;
    set(gca,'TickDir','out');



subplot(4,2,4); hold on;
    for i = 1:nCond
        scatter(Zc_y(i),  Zp_y(i),  70, colors(i,:), 'filled', 'o');
        scatter(Zc_g1(i), Zp_g1(i), 70, colors(i,:), 'o', 'LineWidth', 1.5);
        scatter(Zc_g2(i), Zp_g2(i), 70, colors(i,:), 'd', 'LineWidth', 1.5);
    end
    
    % --- Legend: ONLY marker types (black) ---
    h_y  = scatter(nan,nan,70,'k','filled','o');
    h_g1 = scatter(nan,nan,70,'k','o','LineWidth',1.5);
    h_g2 = scatter(nan,nan,70,'k','d','LineWidth',1.5);
    
    legend([h_y, h_g1, h_g2], {'y','g1','g2'}, 'Location','eastoutside');
    
    title('Plaid responses (all conditions)');
    plotZcZpBorders;
    axis square;
    set(gca,'TickDir','out');


%% Generate plaid responses, vary amplitude

% Parameters (vectorized)
    A = [1 2 4 6];
    s = [30 30 30 30];
    c = [-20 -20 -20 -20];
    baseline = 0.2;
    nCond = numel(A);

% Colormap (gradient)
    colors = parula(nCond);   % or: lines(nCond), turbo(nCond)

% Preallocate
    plaidResp = cell(1,nCond);
    Zp_g1 = zeros(1,nCond); Zc_g1 = zeros(1,nCond);
    Zp_g2 = zeros(1,nCond); Zc_g2 = zeros(1,nCond);
    Zp_y  = zeros(1,nCond); Zc_y  = zeros(1,nCond);

%Plaid responses 
subplot(4,2,5); hold on;
    for i = 1:nCond
        plaidResp{i} = A(i) * exp(-(x - c(i)).^2 / (2*s(i)^2));
        plot(x, plaidResp{i}, 'LineWidth', 2, 'Color', colors(i,:));
    end
    grid on;
    legend(arrayfun(@(i) sprintf('s%d',i),1:nCond,'UniformOutput',false));
    xlabel('x'); ylabel('y');
    title('Plaid responses');

% Loop over conditions
for i = 1:nCond
    
    pr = plaidResp{i};
    
    % ---- g1 ----
    comp_corr      = triu2vec(corrcoef(pr, compPred_g1));
    patt_corr      = triu2vec(corrcoef(pr, g1));
    comp_patt_corr = triu2vec(corrcoef(compPred_g1, g1));
    Rp = ((patt_corr)-(comp_corr.*comp_patt_corr)) ./ sqrt((1-comp_corr.^2).*(1-comp_patt_corr.^2));
    Rc = ((comp_corr)-(patt_corr.*comp_patt_corr)) ./ sqrt((1-patt_corr.^2).*(1-comp_patt_corr.^2));
    Zp_g1(i) = (0.5.*log((1+Rp)./(1-Rp))) ./ sqrt(1/(12-3));
    Zc_g1(i) = (0.5.*log((1+Rc)./(1-Rc))) ./ sqrt(1/(12-3));
    
    % ---- g2 ----
    comp_corr      = triu2vec(corrcoef(pr, compPred_g2));
    patt_corr      = triu2vec(corrcoef(pr, g2));
    comp_patt_corr = triu2vec(corrcoef(compPred_g2, g2));
    Rp = ((patt_corr)-(comp_corr.*comp_patt_corr)) ./ sqrt((1-comp_corr.^2).*(1-comp_patt_corr.^2));
    Rc = ((comp_corr)-(patt_corr.*comp_patt_corr)) ./ sqrt((1-patt_corr.^2).*(1-comp_patt_corr.^2));
    Zp_g2(i) = (0.5.*log((1+Rp)./(1-Rp))) ./ sqrt(1/(12-3));
    Zc_g2(i) = (0.5.*log((1+Rc)./(1-Rc))) ./ sqrt(1/(12-3));
    
    % ---- y ----
    comp_corr      = triu2vec(corrcoef(pr, compPred_y));
    patt_corr      = triu2vec(corrcoef(pr, y));
    comp_patt_corr = triu2vec(corrcoef(compPred_y, y));
    Rp = ((patt_corr)-(comp_corr.*comp_patt_corr)) ./ sqrt((1-comp_corr.^2).*(1-comp_patt_corr.^2));
    Rc = ((comp_corr)-(patt_corr.*comp_patt_corr)) ./ sqrt((1-patt_corr.^2).*(1-comp_patt_corr.^2));
    Zp_y(i) = (0.5.*log((1+Rp)./(1-Rp))) ./ sqrt(1/(12-3));
    Zc_y(i) = (0.5.*log((1+Rc)./(1-Rc))) ./ sqrt(1/(12-3));
end

% ZpZc plot
subplot(4,2,6); hold on;
    h = gobjects(nCond,1); % for legend handles
    for i = 1:nCond
        % plot all 3 points for this condition with SAME color
        scatter(Zc_y(i),  Zp_y(i),  70, colors(i,:), 'filled');
        scatter(Zc_g1(i), Zp_g1(i), 70, colors(i,:), 'o');
        h(i) = scatter(Zc_g2(i), Zp_g2(i), 70, colors(i,:), 'd'); % store handle
    end
    legend(h, arrayfun(@(i) sprintf('s%d',i),1:nCond,'UniformOutput',false));
    title('Plaid responses (all conditions)');
    plotZcZpBorders;
    axis square;
    set(gca,'TickDir','out');



subplot(4,2,6); hold on;
    for i = 1:nCond
        scatter(Zc_y(i),  Zp_y(i),  70, colors(i,:), 'filled', 'o');
        scatter(Zc_g1(i), Zp_g1(i), 70, colors(i,:), 'o', 'LineWidth', 1.5);
        scatter(Zc_g2(i), Zp_g2(i), 70, colors(i,:), 'd', 'LineWidth', 1.5);
    end
    
    % --- Legend: ONLY marker types (black) ---
    h_y  = scatter(nan,nan,70,'k','filled','o');
    h_g1 = scatter(nan,nan,70,'k','o','LineWidth',1.5);
    h_g2 = scatter(nan,nan,70,'k','d','LineWidth',1.5);
    
    legend([h_y, h_g1, h_g2], {'y','g1','g2'}, 'Location','eastoutside');
    
    title('Plaid responses (all conditions)');
    plotZcZpBorders;
    axis square;
    set(gca,'TickDir','out');



%% Generate plaid responses, vary center

% Parameters (vectorized)
    A = [3 3 3 3];
    s = [30 30 30 30];
    c = [-10 -25 -40 -60];
    baseline = 0.2;
    nCond = numel(A);

% Colormap (gradient)
    colors = parula(nCond);   % or: lines(nCond), turbo(nCond)

% Preallocate
    plaidResp = cell(1,nCond);
    Zp_g1 = zeros(1,nCond); Zc_g1 = zeros(1,nCond);
    Zp_g2 = zeros(1,nCond); Zc_g2 = zeros(1,nCond);
    Zp_y  = zeros(1,nCond); Zc_y  = zeros(1,nCond);

%Plaid responses 
subplot(4,2,7); hold on;
    for i = 1:nCond
        plaidResp{i} = A(i) * exp(-(x - c(i)).^2 / (2*s(i)^2));
        plot(x, plaidResp{i}, 'LineWidth', 2, 'Color', colors(i,:));
    end
    grid on;
    legend(arrayfun(@(i) sprintf('s%d',i),1:nCond,'UniformOutput',false));
    xlabel('x'); ylabel('y');
    title('Plaid responses');

% Loop over conditions
for i = 1:nCond
    
    pr = plaidResp{i};
    
    % ---- g1 ----
    comp_corr      = triu2vec(corrcoef(pr, compPred_g1));
    patt_corr      = triu2vec(corrcoef(pr, g1));
    comp_patt_corr = triu2vec(corrcoef(compPred_g1, g1));
    Rp = ((patt_corr)-(comp_corr.*comp_patt_corr)) ./ sqrt((1-comp_corr.^2).*(1-comp_patt_corr.^2));
    Rc = ((comp_corr)-(patt_corr.*comp_patt_corr)) ./ sqrt((1-patt_corr.^2).*(1-comp_patt_corr.^2));
    Zp_g1(i) = (0.5.*log((1+Rp)./(1-Rp))) ./ sqrt(1/(12-3));
    Zc_g1(i) = (0.5.*log((1+Rc)./(1-Rc))) ./ sqrt(1/(12-3));
    
    % ---- g2 ----
    comp_corr      = triu2vec(corrcoef(pr, compPred_g2));
    patt_corr      = triu2vec(corrcoef(pr, g2));
    comp_patt_corr = triu2vec(corrcoef(compPred_g2, g2));
    Rp = ((patt_corr)-(comp_corr.*comp_patt_corr)) ./ sqrt((1-comp_corr.^2).*(1-comp_patt_corr.^2));
    Rc = ((comp_corr)-(patt_corr.*comp_patt_corr)) ./ sqrt((1-patt_corr.^2).*(1-comp_patt_corr.^2));
    Zp_g2(i) = (0.5.*log((1+Rp)./(1-Rp))) ./ sqrt(1/(12-3));
    Zc_g2(i) = (0.5.*log((1+Rc)./(1-Rc))) ./ sqrt(1/(12-3));
    
    % ---- y ----
    comp_corr      = triu2vec(corrcoef(pr, compPred_y));
    patt_corr      = triu2vec(corrcoef(pr, y));
    comp_patt_corr = triu2vec(corrcoef(compPred_y, y));
    Rp = ((patt_corr)-(comp_corr.*comp_patt_corr)) ./ sqrt((1-comp_corr.^2).*(1-comp_patt_corr.^2));
    Rc = ((comp_corr)-(patt_corr.*comp_patt_corr)) ./ sqrt((1-patt_corr.^2).*(1-comp_patt_corr.^2));
    Zp_y(i) = (0.5.*log((1+Rp)./(1-Rp))) ./ sqrt(1/(12-3));
    Zc_y(i) = (0.5.*log((1+Rc)./(1-Rc))) ./ sqrt(1/(12-3));
end

% ZpZc plot
subplot(4,2,6); hold on;
    h = gobjects(nCond,1); % for legend handles
    for i = 1:nCond
        % plot all 3 points for this condition with SAME color
        scatter(Zc_y(i),  Zp_y(i),  70, colors(i,:), 'filled');
        scatter(Zc_g1(i), Zp_g1(i), 70, colors(i,:), 'o');
        h(i) = scatter(Zc_g2(i), Zp_g2(i), 70, colors(i,:), 'd'); % store handle
    end
    legend(h, arrayfun(@(i) sprintf('s%d',i),1:nCond,'UniformOutput',false));
    title('Plaid responses (all conditions)');
    plotZcZpBorders;
    axis square;
    set(gca,'TickDir','out');



subplot(4,2,8); hold on;
    for i = 1:nCond
        scatter(Zc_y(i),  Zp_y(i),  70, colors(i,:), 'filled', 'o');
        scatter(Zc_g1(i), Zp_g1(i), 70, colors(i,:), 'o', 'LineWidth', 1.5);
        scatter(Zc_g2(i), Zp_g2(i), 70, colors(i,:), 'd', 'LineWidth', 1.5);
    end
    
    % --- Legend: ONLY marker types (black) ---
    h_y  = scatter(nan,nan,70,'k','filled','o');
    h_g1 = scatter(nan,nan,70,'k','o','LineWidth',1.5);
    h_g2 = scatter(nan,nan,70,'k','d','LineWidth',1.5);
    
    legend([h_y, h_g1, h_g2], {'y','g1','g2'}, 'Location','eastoutside');
    
    title('Plaid responses (all conditions)');
    plotZcZpBorders;
    axis square;
    set(gca,'TickDir','out');
