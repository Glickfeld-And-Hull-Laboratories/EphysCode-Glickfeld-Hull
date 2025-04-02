function get12Dir4PhaseFits(resp,base)

    mouse   = exptStruct.mouse;
    date    = exptStruct.date;
    base    = ['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\' exptStruct.loc];

    nCells  = size(resp,1);
    nDirs   = size(resp,2);
    nPhas   = size(resp,3);
    nStim   = (nDirs*(nPhas+1));
    
    % Initialize output arrays
    avg_resp_dir    = NaN(nCells, nDirs, nPhas, 2, 2); % Last dim: 1 = mean, 2 = SEM
    h_resp          = NaN(nCells, nDirs, nPhas, 2);
    p_resp          = NaN(nCells, nDirs, nPhas, 2);
    
    % Loop over all conditions
    for ic = 1:nCells
        for id = 1:nDirs
            for ip = 1:nPhas
                for is = 1:2 % Grating/Plaid
                    % Get current condition's trial count
                    nTrials = size(resp{ic,id,ip,is}, 1);
    
                    if nTrials > 0
                        % Compute mean and SEM for response period
                        avg_resp_dir(ic,id,ip,is,1) = mean(sum(resp{ic,id,ip,is}, 2)); % Avg response in Hz
                        avg_resp_dir(ic,id,ip,is,2) = std(sum(resp{ic,id,ip,is}, 2)) / sqrt(nTrials); % Avg response in Hz
    
                        % Convert response and baseline data into spike rates (Hz)
                        resp_cell_trials = sum(resp{ic,id,ip,is}, 2);  % Responses in Hz
                        base_cell_trials = sum(base{ic,id,ip,is}, 2) * 5; % Baselines in Hz
    
                        % Perform t-test between response and baseline
                        [h_resp(ic,id,ip,is), p_resp(ic,id,ip,is)] = ttest2(resp_cell_trials, base_cell_trials, 'dim', 1, 'tail', 'right', 'alpha', 0.05 / nStim);

                    else
                        % Assign NaNs when no trials exist
                        avg_resp_dir(ic,id,ip,is,:) = NaN;
                        h_resp(ic,id,ip,is)         = NaN;
                        p_resp(ic,id,ip,is)         = NaN;
                    end
                end
            end
        end
    end
    
    % Find cells significantly responsive to gratings
    resp_ind_dir = find(sum(h_resp(:,:,1,1), 2)); 
    
    % Determine direction selectivity
     DSIstruct = getDSIstruct(avg_resp_dir);
        DSI         = DSIstruct.DSI;
        DSI_ind     = DSIstruct.DS_ind;
        DSI_maxInd  = DSIstruct.prefDir;

    
    % Direction tuning curve fit
    gratingFitStruct = getGratingTuningCurveFit(avg_resp_dir);
        b_hat_all           = gratingFitStruct.b;
        k1_hat_all          = gratingFitStruct.k1;
        R1_hat_all          = gratingFitStruct.R1;
        R2_hat_all          = gratingFitStruct.R2;
        u1_hat_all          = gratingFitStruct.u1;
        u2_hat_all          = gratingFitStruct.u2;
        dir_sse_all         = gratingFitStruct.sse;
        dir_R_square_all    = gratingFitStruct.Rsq;
        dir_yfit_all        = gratingFitStruct.yfit;

    % Run partial correlations
     ZpZcStruct = getZpZcStruct(avg_resp_dir);
        Zp = ZpZcStruct.Zp;
        Zc = ZpZcStruct.Zc;
        Rp = ZpZcStruct.Rp;
        Rc = ZpZcStruct.Rc;

    % Find correlations between plaid tuning curves
     plaid_corr = getPlaidTuningCorrelations(avg_resp_dir);

    % Calculate pairwise dist between Zp Zc points
    ZpZcPWdist = getZpZcPWdist(ZpZcStruct);

    % Calculate PCI fit, get amplitude and baseline
    PCI = (Zp-Zc);
    phase = [0 90 180 270];
    phase_range = 0:1:359;

    for iCell = 1:nCells
        [b_hat_all(iCell,1), amp_hat_all(iCell,1), per_hat_all(iCell,1),pha_hat_all(iCell,1),sse_all(iCell,1),R_square_all(iCell,1)] = sinefit_PCI(deg2rad(phase),PCI(:,iCell));
        yfit_all(iCell,:,1) = b_hat_all(iCell,1)+amp_hat_all(iCell,1).*(sin(2*pi*deg2rad(phase_range)./per_hat_all(iCell,1) + 2.*pi/pha_hat_all(iCell,1)));
    end

    save(fullfile(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\' date], [mouse '_' date '_fitsSG.mat']), 'resp_ind_dir','nCells','nTrials','nDirs','avg_resp_dir','DSI','plaid_corr','Rp','Rc','Zp','Zc','ZpZcPWdist','yfit_all','amp_hat_all','b_hat_all','sse_all','R_square_all','dir_yfit_all','k1_hat_all','dir_sse_all','dir_R_square_all');
    save(fullfile(base, 'Analysis\Neuropixel', [date], [date '_' mouse '_' run_str '_respData.mat']), 'resp', 'base', 'resp_ind', 'h_resp', 'avg_resp_dir','p_anova_dir','p_anova_plaid', 'trialInd');
    save(fullfile(base, 'Analysis\Neuropixel', [date], [date '_' mouse '_' run_str '_stimData.mat']), 'resp_cell_trials', 'base_cell_trials', 'trialsperstim','DSI_ind','OSI_ind','resp_ind_dir','p_dir');

%% set inclusion criteria
resp_ind = intersect(resp_ind_dir,find(DSI>0.5));

ind = ZpZcStruct.PDSind_byphase;


%%
[avg_resp_grat, avg_resp_plaid] = getAlignedGratPlaidTuning(avg_resp_dir);

if doPlot == 1
%%
figure; 
movegui('center')
for i = 1:4
    subplot(4,4,i)
    scatter(Zc(i,resp_ind), Zp(i,resp_ind),'.')
    hold on
    scatter(Zc(i,ind{1}),Zp(i,ind{1}),'.');
    xlabel('Zc')
    ylabel('Zp')
    ylim([-4 8])
    xlim([-4 8])
    hold on
    if i==1; title('pattern cells at 0'); end
    plotZcZpBorders; axis square
end
for i = 1:4
    subplot(4,4,i+4)
    scatter(Zc(i,resp_ind), Zp(i,resp_ind),'.')
    hold on
    scatter(Zc(i,ind{2}),Zp(i,ind{2}),'.');
    xlabel('Zc')
    ylabel('Zp')
    ylim([-4 8])
    xlim([-4 8])
    hold on
    if i==1; title('pattern cells at 90'); end
    plotZcZpBorders; axis square
end
for i = 1:4
    subplot(4,4,i+8)
    scatter(Zc(i,resp_ind), Zp(i,resp_ind),'.')
    hold on
    scatter(Zc(i,ind{3}),Zp(i,ind{3}),'.');
    xlabel('Zc')
    ylabel('Zp')
    ylim([-4 8])
    xlim([-4 8])
    hold on
    if i==1; title('pattern cells at 180'); end
    plotZcZpBorders; axis square
end
for i = 1:4
    subplot(4,4,i+12)
    scatter(Zc(i,resp_ind), Zp(i,resp_ind),'.')
    hold on
    scatter(Zc(i,ind{4}),Zp(i,ind{4}),'.');
    xlabel('Zc')
    ylabel('Zp')
    ylim([-4 8])
    xlim([-4 8])
    hold on
    if i==1; title('pattern cells at 270'); end
    plotZcZpBorders; axis square
end
sgtitle('Pattern direction selective cells at four phases')
print(fullfile(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\' date], [mouse '_' date '_ZpZcPopulation.pdf']),'-dpdf', '-fillpage') 


%% Plot pattern index modulation by cell


PCI = (Zp-Zc);

%fit sinusoid
phase = [0 90 180 270];
phase_range = 0:1:359;
figure;
start=1;
n=1;
for iCell = 1:nCells
    ic=iCell;
    subplot(5,4,start)
        scatter(phase,PCI(:,ic),8,'filled');
        hold on
        [b_hat_all(ic,1), amp_hat_all(ic,1), per_hat_all(ic,1),pha_hat_all(ic,1),sse_all(ic,1),R_square_all(ic,1)] = sinefit_PCI(deg2rad(phase),PCI(:,ic));
        yfit_all(ic,:,1) = b_hat_all(ic,1)+amp_hat_all(ic,1).*(sin(2*pi*deg2rad(phase_range)./per_hat_all(ic,1) + 2.*pi/pha_hat_all(ic,1)));
        plot(phase_range, yfit_all(ic,:,1),'k:');
        subtitle(['cell ' num2str(ic) ', Rsq ' num2str(R_square_all(ic),'%.2f'), ', SSE ' num2str(sse_all(ic),'%.2f')])
        ylabel('Zp-Zc'); xlabel('Mask phase'); ylim([-7 7])
        xlim([0 360]); xticks([0 180 360]); axis square
    start = start+1;
    if start >20
        sgtitle([mouse '_' date ' PCI modulation across mask phase by cell'])
        print(fullfile(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\' date], [mouse '_' date '_PCImodulation_' num2str(n) '.pdf']),'-dpdf', '-fillpage')       
        figure;
        movegui('center')
        start = 1;
        n = n+1;
    end
    if iCell == nCells
        sgtitle([mouse '_' date ' PCI modulation across mask phase by cell'])
        print(fullfile(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\' date], [mouse '_' date '_PCImodulation_' num2str(n) '.pdf']),'-dpdf', '-fillpage')  
    end        
end
close all


%% Plot polar plots by cell

figure;
start   = 1;
n       = 1;
x       = [-150:30:180];
x_rad   = deg2rad(x);

for iCell = 1:nCells
    ic = iCell;
    subplot(5,4,start)
        for im = 1:nPhas
            polarplot([x_rad x_rad(1)], [avg_resp_plaid(ic,:,im) avg_resp_plaid(ic,1,im)])
            hold on
        end
        polarplot([x_rad x_rad(1)], [avg_resp_grat(ic,:) avg_resp_grat(ic,1)],'k', 'LineWidth',2) 
        subtitle(['cell ' num2str(ic) ', ' num2str([-2000 + goodUnitStruct(iCell).depth])])
    start = start+1;    
    if start>20
        sgtitle([mouse ' ' date ' - Polar plots'])
        print(fullfile(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\' date], [mouse '_' date '_PolarPlots_' num2str(n) '.pdf']), '-dpdf','-fillpage')
        figure;
        movegui('center')
        start = 1;
        n = n+1;
    end
    if iCell == nCells
        sgtitle([mouse ' ' date ' - Polar plots'])
        print(fullfile(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\' date], [mouse '_' date '_PolarPlots_' num2str(n) '.pdf']), '-dpdf','-fillpage')
    end
end     
close all

%% Plot Zp Zc classifications by cell

figure;
start = 1;
n = 1;

for iCell = 1:nCells
    ic = iCell;
    subplot(5,4,start)
        for im = 1:nPhas
            scatter(Zc(im,ic), Zp(im,ic),8,'filled')
            hold on
        end
        ylabel('Zp'); ylim([-4 8]);
        xlabel('Zc'); xlim([-4 8]);
        if ic ==1; legend('0 deg','90 deg','180 deg', '270 deg'); end;
        subtitle(['cell ' num2str(ic)])
        plotZcZpBorders; axis square
    start = start+1;    
    if start>20
        sgtitle([mouse '_' date ' - Zp Zc by cell'])
        print(fullfile(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\' date], [mouse '_' date '_ZcZpByCell_' num2str(n) '.pdf']), '-dpdf','-fillpage')
        figure;
        movegui('center')
        start = 1;
        n = n+1;
    end
    if iCell == nCells
        sgtitle([mouse '_' date ' - Zp Zc by cell'])
        print(fullfile(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\' date], [mouse '_' date '_ZcZpByCell_' num2str(n) '.pdf']), '-dpdf','-fillpage')
    end        
end
close all




end