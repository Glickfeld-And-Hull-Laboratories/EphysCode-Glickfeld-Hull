function [phaseCS, radiusCS, indTunedAndHasPower] = plotPairedPolar(lengths, arrModulationsCS, arrHasPowerRewAlignedCS,...
    arrMaxIndicesCS, arrMaxValuesCS, ...
    arrModulationsSS, arrHasPowerRewAlignedSS, arrMaxIndicesSS, arrMaxValuesSS, ...
    flagPlotOnlyModulatedOnes, flagPlotOnlyPowerOnes, flagPlotOnlyNarrowlyTuningOnes, ...
    sTitle, sFile)

    globals;

    % Define the cycle duration (e.g., 1 second trial or oscillation)
    cycleDuration = 1.0;
    indTunedAndHasPower = [];
    
    % if any(arrHasPowerRewAligned~=0)        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        spikeTimesCS = arrMaxIndicesCS;
        spikeMagnitudesCS = arrMaxValuesCS;
                    
        % Convert spike times to phase (0–2pi)
        phaseCS = mod(spikeTimesCS, cycleDuration) / cycleDuration * 2*pi;
        radiusCS = spikeMagnitudesCS./max(abs(spikeMagnitudesCS));
    
        if flagPlotOnlyModulatedOnes && flagPlotOnlyPowerOnes && flagPlotOnlyNarrowlyTuningOnes
            % Plot units with power signal for licking and narrowly tuned
            isModTunedAndHasPower = abs(arrModulationsCS) & (arrHasPowerRewAlignedCS~=0) ...
                & (abs(min(phaseCS,[],2)-max(phaseCS,[],2))<pi/2)';
        elseif flagPlotOnlyModulatedOnes && flagPlotOnlyPowerOnes && ~flagPlotOnlyNarrowlyTuningOnes
            % Plot units with power signal for licking and narrowly tuned
            isModTunedAndHasPower = abs(arrModulationsCS) & (arrHasPowerRewAlignedCS~=0) ...
                & (abs(min(phaseCS,[],2)-max(phaseCS,[],2))>=pi/2)';
        elseif flagPlotOnlyModulatedOnes && ~flagPlotOnlyPowerOnes && flagPlotOnlyNarrowlyTuningOnes
            % Plot units with no power signal for licking and narrowly tuned
            isModTunedAndHasPower = abs(arrModulationsCS) ...% & ~arrHasPowerRewAligned ...
                & (abs(min(phaseCS,[],2)-max(phaseCS,[],2))<pi/2)';
        elseif flagPlotOnlyModulatedOnes && ~flagPlotOnlyPowerOnes && ~flagPlotOnlyNarrowlyTuningOnes
            % Plot units with no power signal for licking and narrowly tuned
            isModTunedAndHasPower = abs(arrModulationsCS) ...% & ~arrHasPowerRewAligned ...
                & (abs(min(phaseCS,[],2)-max(phaseCS,[],2))>=pi/2)';
        end
        indTunedAndHasPower = find(isModTunedAndHasPower);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        spikeTimesSS = arrMaxIndicesSS;
        spikeMagnitudesSS = arrMaxValuesSS;

        % Radius - Get only tuned ones and Normalize based on max spike
        radiusSelectedCS = radiusCS; %(isModTunedAndHasPower,:);
        phaseSelectedCS = phaseCS; %(isModTunedAndHasPower, :);


        % Convert spike times to phase (0–2pi)
        phaseSS = mod(spikeTimesSS, cycleDuration) / cycleDuration * 2*pi;
        radiusSS = spikeMagnitudesSS./max(abs(spikeMagnitudesSS));

        if flagPlotOnlyModulatedOnes && flagPlotOnlyPowerOnes && flagPlotOnlyNarrowlyTuningOnes
            % Plot units with power signal for licking and narrowly tuned
            isModTunedAndHasPower = abs(arrModulationsSS) & (arrHasPowerRewAlignedSS~=0) ...
                & (abs(min(phaseSS,[],2)-max(phaseSS,[],2))<pi/2)';
        elseif flagPlotOnlyModulatedOnes && flagPlotOnlyPowerOnes && ~flagPlotOnlyNarrowlyTuningOnes
            % Plot units with power signal for licking and narrowly tuned
            isModTunedAndHasPower = abs(arrModulationsSS) & (arrHasPowerRewAlignedSS~=0) ...
                & (abs(min(phaseSS,[],2)-max(phaseSS,[],2))>=pi/2)';
        elseif flagPlotOnlyModulatedOnes && ~flagPlotOnlyPowerOnes && flagPlotOnlyNarrowlyTuningOnes
            % Plot units with no power signal for licking and narrowly tuned
            isModTunedAndHasPower = abs(arrModulationsSS) ...% & ~arrHasPowerRewAligned ...
                & (abs(min(phaseSS,[],2)-max(phaseSS,[],2))<pi/2)';
        elseif flagPlotOnlyModulatedOnes && ~flagPlotOnlyPowerOnes && ~flagPlotOnlyNarrowlyTuningOnes
            % Plot units with no power signal for licking and narrowly tuned
            isModTunedAndHasPower = abs(arrModulationsSS) ...% & ~arrHasPowerRewAligned ...
                & (abs(min(phaseSS,[],2)-max(phaseSS,[],2))>=pi/2)';
        end

        radiusSelectedSS = radiusSS; %(isModTunedAndHasPower,:);
        phaseSelectedSS = phaseSS; %(isModTunedAndHasPower, :);

        % % Polar plot
        % f = figure;
        % f.Position = [globalX globalY globalW globalH];
        % ax = polaraxes; %gca;
        % ax.ThetaZeroLocation = 'top';    % 0 at top
        % ax.ThetaDir = 'clockwise';       % clockwise direction
        % hold(ax,"on");
        % 
        % for ind=1:size(phaseSelected,1)
        %     % colorInd = mod(ind, size(COLORS,1)-1)+1;
        %     color = randperm(20,3)/20;
        %     p = polarplot(phaseSelected(ind,:), radiusSelected(ind, :), 'Marker', 'o', 'MarkerFaceColor', color, 'MarkerEdgeColor', 'k');
        % end
        % 
        % rlim([0 1]);
        % %     ax.RTick = [];                   % remove radial ticks
        % 
        % set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5);
        % title([sTitle ' ratioOfCells=' num2str(round(100*sum(isModTunedAndHasPower)/length(arrHasPowerRewAligned))) '%']);
        % print([sFile '.tif'], '-dtiff', '-r200');       
        % exportgraphics(f,[sFile '.pdf'], 'ContentType', 'vector', 'Resolution', 1200);
        % savefig(f,[sFile '.fig']);
        % close all;
        
        lengthsReshaped = lengths; %reshape(lengths',1,[]);

        indA = 1;
        for indDays=1:length(lengthsReshaped)

            if indDays>1
                indA = sum(lengthsReshaped(1:indDays-1))+1;
            end
            indB = indA+lengthsReshaped(indDays)-1;

            if indB>indA
                phaseSelectedCSRange = phaseSelectedCS(indA:indB,:);
                radiusSelectedCSRange = radiusSelectedCS(indA:indB,:);

                phaseSelectedSSRange = phaseSelectedSS(indA:indB,:);
                radiusSelectedSSRange = radiusSelectedSS(indA:indB,:);

                %%%%%%%%%%%%%%%%% EACH DAY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Polar plot
                f = figure;
                f.Position = [globalX globalY globalW globalH];
                ax = polaraxes; %gca;
                ax.ThetaZeroLocation = 'top';    % 0 at top
                ax.ThetaDir = 'clockwise';       % clockwise direction
                hold(ax,"on");

                %%%%%%%%% Plot CS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                N = size(phaseSelectedCSRange,1);  % number of colors
                R = rand(N, 1) * 0.3;           % 0.0 – 0.3
                G = 0.4 + rand(N, 1) * 0.6;    % 0.4 – 1.0
                B = rand(N, 1) * 0.3;           % 0.0 – 0.3

                colorsGreen = [R, G, B];  % N x 3 matrix

                for ind=1:size(phaseSelectedCSRange,1)
                    % get averages of degrees using atan2, which is immune to boundary(0,2pi) issues
                    meanPhase = atan2(mean(sin(phaseSelectedCSRange(ind,:))), mean(cos(phaseSelectedCSRange(ind,:))));            
                    if meanPhase<0
                        meanPhase = meanPhase + 2*pi; % Adjust meanPhase to be in the range [0, 2*pi]
                    end            
                    meanRadius = mean(radiusSelectedCSRange(ind,:));
                    polarplot([0, meanPhase], [0, meanRadius], '-o', 'Color', [colorsGreen(ind,:) .5], ...
                        'LineWidth', 1.5 , 'MarkerSize', 7, 'MarkerFaceColor', colorsGreen(ind,:));
                end

                %%%%%%%%% Plot SS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                N = size(phaseSelectedSSRange,1);  % number of colors
                R = 0.4 + rand(N, 1) * 0.6;    % 0.4 – 1.0
                G = rand(N, 1) * 0.3;           % 0.0 – 0.3
                B = rand(N, 1) * 0.3;           % 0.0 – 0.3

                colorsRed = [R, G, B];  % N x 3 matrix

                for ind=1:size(phaseSelectedSSRange,1)
                    % get averages of degrees using atan2, which is immune to boundary(0,2pi) issues
                    meanPhase = atan2(mean(sin(phaseSelectedSSRange(ind,:))), mean(cos(phaseSelectedSSRange(ind,:))));            
                    if meanPhase<0
                        meanPhase = meanPhase + 2*pi; % Adjust meanPhase to be in the range [0, 2*pi]
                    end            
                    meanRadius = mean(radiusSelectedSSRange(ind,:));
                    polarplot([0, meanPhase], [0, meanRadius], '-o', 'Color', [colorsRed(ind,:) .5], ...
                        'LineWidth', 1.5 , 'MarkerSize', 7, 'MarkerFaceColor', colorsRed(ind,:));
                end


                rlim([0 1]);

                set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5);
                title([sTitle ' day=' num2str(indDays)]); % ' ratioOfCells=' num2str(round(100*sum(isModTunedAndHasPower)/length(arrHasPowerRewAlignedCS))) '%']);
                print([sFile '_day' num2str(indDays) '.tif'], '-dtiff', '-r200');       
                exportgraphics(f,[sFile '_day' num2str(indDays) '.pdf'], 'ContentType', 'vector', 'Resolution', 1200);
                % savefig(f,[sFile '_day' num2str(indDays) '.fig']);
                close all;
            end
        end

        %%%%%%%%%%%%%%%%% AVERAGES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Polar plot
        f = figure;
        f.Position = [globalX globalY globalW globalH];
        ax = polaraxes; %gca;
        ax.ThetaZeroLocation = 'top';    % 0 at top
        ax.ThetaDir = 'clockwise';       % clockwise direction
        hold(ax,"on");

        %%%%%%%%% Plot SS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        N = size(phaseSelectedSS,1);  % number of colors
        R = 0.4 + rand(N, 1) * 0.6;    % 0.4 – 1.0
        G = rand(N, 1) * 0.3;           % 0.0 – 0.3
        B = rand(N, 1) * 0.3;           % 0.0 – 0.3
        
        colorsRed = [R, G, B];  % N x 3 matrix

        for ind=1:size(phaseSelectedSS,1)
            % get averages of degrees using atan2, which is immune to boundary(0,2pi) issues
            meanPhase = atan2(mean(sin(phaseSelectedSS(ind,:))), mean(cos(phaseSelectedSS(ind,:))));            
            if meanPhase<0
                meanPhase = meanPhase + 2*pi; % Adjust meanPhase to be in the range [0, 2*pi]
            end            
            meanRadius = mean(radiusSelectedSS(ind,:));
            polarplot([0, meanPhase], [0, meanRadius], '-o', 'Color', [colorsRed(ind,:) .5], ...
                'LineWidth', 1.5 , 'MarkerSize', 7, 'MarkerFaceColor', colorsRed(ind,:));
        end

        %%%%%%%%% Plot CS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        N = size(phaseSelectedCS,1);  % number of colors
        R = rand(N, 1) * 0.3;           % 0.0 – 0.3
        G = 0.4 + rand(N, 1) * 0.6;    % 0.4 – 1.0
        B = rand(N, 1) * 0.3;           % 0.0 – 0.3
        
        colorsGreen = [R, G, B];  % N x 3 matrix

        for ind=1:size(phaseSelectedCS,1)
            % get averages of degrees using atan2, which is immune to boundary(0,2pi) issues
            meanPhase = atan2(mean(sin(phaseSelectedCS(ind,:))), mean(cos(phaseSelectedCS(ind,:))));            
            if meanPhase<0
                meanPhase = meanPhase + 2*pi; % Adjust meanPhase to be in the range [0, 2*pi]
            end            
            meanRadius = mean(radiusSelectedCS(ind,:));
            polarplot([0, meanPhase], [0, meanRadius], '-o', 'Color', [colorsGreen(ind,:) .5], ...
                'LineWidth', 1.5 , 'MarkerSize', 7, 'MarkerFaceColor', colorsGreen(ind,:));
        end

        rlim([0 1]);

        set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5);
        title([sTitle]); % ' ratioOfCells=' num2str(round(100*sum(isModTunedAndHasPower)/length(arrHasPowerRewAlignedCS))) '%']);
        print([sFile 'Avg.tif'], '-dtiff', '-r200');       
        exportgraphics(f,[sFile 'Avg.pdf'], 'ContentType', 'vector', 'Resolution', 1200);
        savefig(f,[sFile 'Avg.fig']);
        close all;
    % end
end