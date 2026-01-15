
%% plotting grating and plaid tuning curves

% Extract responses
respgrat = avg_resp_dir(:,:,1,1,1); % nCells x nDir
respplaid = avg_resp_dir(:,:,:,2,1); % nCells x nDir x nPhas

% Find preferred grating direction for each neuron
[~, prefdir] = max(respgrat, [], 2); % Preferred direction indices (nCells x 1)

% Compute shifts to align to preferred direction
vecshift = 6 - prefdir; % Align preferred direction to index 6

% Compute average step size (ensure it's correct)
dir_step = mode(diff(sort(unique(stimStruct.stimDirection))));

% Compute plaid shift in index units (force integer)
plaid_shift = round(45 / dir_step);

% Initialize aligned response matrices
avg_resp_grat = zeros(size(respgrat)); % nCells x nDir
avg_resp_plaid = zeros(size(respplaid)); % nCells x nDir x nPhas

% Align grating and plaid responses
for iCell = 1:size(respgrat,1)
    % Align gratings to preferred direction
    avg_resp_grat(iCell,:) = circshift(respgrat(iCell,:), vecshift(iCell), 2);
    
    % Align plaids to perceived direction
    for iPhas = 1:size(respplaid,3)
        total_shift = round(vecshift(iCell) + plaid_shift); % Ensure integer
        avg_resp_plaid(iCell,:,iPhas) = circshift(respplaid(iCell,:,iPhas), total_shift, 2);
    end
end


figure;
start = 1;
x_grat = 0:30:330; % Grating directions (12 angles)
x_plaid = 0:45:360-45; % Plaid perceived directions (8 angles)
x_grat_rad = deg2rad(x_grat);
x_plaid_rad = deg2rad(x_plaid);

% Correct plaid indexing (extract 8 directions instead of 7)
plaid_idx = 1:1:8; % Now correctly has 8 elements
avg_resp_plaid_corrected = avg_resp_plaid(:,plaid_idx,:);

for iCell = ind'
    ax = subplot(5,4,start, polaraxes); % Create polar axes
    hold on;
    
    % Plot plaid responses for each phase (corrected)
    for iPhas = 1:nPhas
        polarplot(ax, [x_plaid_rad x_plaid_rad(1)], ...
                      [avg_resp_plaid_corrected(iCell,:,iPhas) avg_resp_plaid_corrected(iCell,1,iPhas)], ...
                      '-'); % Plaid responses
    end

    % Plot grating responses
    polarplot(ax, [x_grat_rad x_grat_rad(1)], ...
                  [avg_resp_grat(iCell,:) avg_resp_grat(iCell,1)], ...
                  'k', 'LineWidth', 1.5); % Grating responses (black)

    title(['cell ' num2str(iCell)]);
    start = start + 1;    
end

sgtitle([mouse ' ' date ', visually resp cells']);
movegui('center');
fig = gcf; % Get current figure
    set(fig, 'PaperPositionMode', 'auto'); % Auto scale the figure to the page
    set(fig, 'PaperSize', [8.5 11]); % Set the paper size to standard letter size (8.5 x 11 inches)
    set(fig, 'PaperPosition', [0 0 8.5 11]); % Adjust the position and size of the figure on the page
print(fullfile(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\' loc '\Analysis\Neuropixel\' date '\' mouse '-' date '-TuningCurves.pdf']),'-dpdf')



