function plotAmplDistribution_Curation(relativeSpkTimesMsec, targetSpikeRates, acg_edges, unit, singleUnit, refractoryViolationRate, refractoryViolationRateMF, refractoryViolationRateLlobet, isInterrupted, plotStartTime, roiEndTimeSec, interruptionMoments)
        globals;
        
        %%%%%%%%%%%%%% PLOT AMPLITUDE DISTRIBUTION TO CHECK CONTINUITY %%%%%%%%%%%%%%%%%%%%%%%
        f = figure;
        f.Position = [globalX globalY 1.5*globalW globalH*.5];        
        %u1 = uipanel(f, 'position', [0, 0, .1, 1]); 
        subplot(1,2,1)  
        hstRaw = histogram(relativeSpkTimesMsec,acg_edges);
        if ~all(isnan(targetSpikeRates))
            hstRaw.BinCounts = targetSpikeRates; 
        end          
        grid on;
        grid minor;
        set(gca,'box','off');
        xlabel('lag (ms)'); 
        ylabel('Normalized (au)');
        title(['Unit=' num2str(unit.id) ' Single=' num2str(singleUnit) ' refrViol=%' num2str(refractoryViolationRate*100,'%.2f') ' (%' num2str(refractoryViolationRateMF*100,'%.2f') ' for MF and %' num2str(refractoryViolationRateLlobet*100,'%.2f') ' for Llobet)']);
        if any(~isnan(targetSpikeRates))
            ylim([0 max(targetSpikeRates)*1.1]);
        end
        set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',SMALL_PLOT_FONT_SIZE); %,'LineWidth',1.5)
        
        %s2 = subplot(1,2,2)  
        u2 = uipanel(f, 'position', [0.5, 0, .5, 1]);
        s = scatterhist(unit.spikeTimesSecs,unit.amplitudes,'Location','SouthEast', 'Direction','out','Parent',u2);
        edges = plotStartTime:BIN_SIZE_CONTINUITY:roiEndTimeSec;
        if length(edges)>2
            edgesPlt = edges(1:end-1)+(edges(2)-edges(1))/2;
            s(2).Children(1).BinEdges = edgesPlt;
        end
        xline(MOMENT_OF_1ST_DRUG_PUT_IN,'-', [FIRST_DRUG ' put in at:' num2str(MOMENT_OF_1ST_DRUG_PUT_IN,'%.2f') ' s'],'LineWidth',1.5, 'FontWeight','bold', 'Color', [1 .2 0 0.9]);
        xline(MOMENT_OF_1ST_DRUG_WASH_IN,'-', [FIRST_DRUG ' wash in at:' num2str(MOMENT_OF_1ST_DRUG_WASH_IN,'%.2f') ' s'],'LineWidth',1.5, 'FontWeight','bold', 'Color', [1 .2 0 0.9]);
    
        if ~isempty(MOMENT_OF_2ND_DRUG_PUT_IN)
            xline(MOMENT_OF_2ND_DRUG_PUT_IN,'-', [SECOND_DRUG ' put in at:' num2str(MOMENT_OF_2ND_DRUG_PUT_IN,'%.2f') ' s'],'LineWidth',1.5, 'FontWeight','bold', 'Color', [1 .2 0 0.9]);
            xline(MOMENT_OF_2ND_DRUG_WASH_IN,'-', [SECOND_DRUG ' wash in at:' num2str(MOMENT_OF_2ND_DRUG_WASH_IN,'%.2f') ' s'],'LineWidth',1.5, 'FontWeight','bold', 'Color', [1 .2 0 0.9]);
        end
        
        xlabel('Time (s)');
        sMoment = '';
        if singleUnit && isInterrupted
            if length(interruptionMoments)>5
                interruptionMoments = interruptionMoments(1:5);
            end
            xline(interruptionMoments,'--', 'Color', [1 .2 0 0.7]);
            sMoment = [' at ' num2str(interruptionMoments,'%.0f ') ' s'];
        end
        title(['Intrrptd=' num2str(isInterrupted) sMoment]);
        set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE, 'LineWidth',1.5); %'FontSize',PLOT_FONT_SIZE,
        print([pathToCurationHelperFolder num2str(unit.id) '.tif'], '-dtiff', '-r100');            
        close all;
end