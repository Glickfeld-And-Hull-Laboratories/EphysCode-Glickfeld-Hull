function printRefractorinessInterruptionNormalcy(unitAll, leverHoldTimes, leverReleaseTimesGLX, allTrials, fixedHoldStartsAtTrial)
    globals;
    
    BIN_SIZE_CORRELOGRAM = 1; % ms
    acg_edges = -X_MAX_CORRELOGRAM-BIN_SIZE_CORRELOGRAM:BIN_SIZE_CORRELOGRAM:X_MAX_CORRELOGRAM+BIN_SIZE_CORRELOGRAM;
    trialCount = length(leverHoldTimes)-fixedHoldStartsAtTrial+1;
    % Parse the corresponding metafile
    imecBinFiles = dir([pathToRecFolder '*imec*ap.bin']);
    imecBinFile = imecBinFiles(1);
    imecMeta = readMeta(imecBinFile.name, pathToRecFolder);
    recordingTimeSec = str2double(imecMeta.fileTimeSecs);

    predictionStartTimeSec = leverHoldTimes(fixedHoldStartsAtTrial);

    if SOFT_CUT~=Inf % Check only region of interest - not whole recording time
        if SOFT_CUT_PARTITION==1 % Get first part
            plotStartTime = 0;
            roiStartTimeSec = predictionStartTimeSec;
            roiEndTimeSec = SOFT_CUT;
        elseif SOFT_CUT_PARTITION==2
            plotStartTime = SOFT_CUT;
            roiStartTimeSec = SOFT_CUT;
            roiEndTimeSec = recordingTimeSec;
        end
    else
        plotStartTime = 0;
        roiStartTimeSec = predictionStartTimeSec;
        roiEndTimeSec = recordingTimeSec;
    end

    logger.info('printRefractoriness', '********************** GOOD UNITS WITH NO INTERRUPTION ***************************');

    unitIdsSingle = [];
    for uid=1:length(unitAll)
        unit = unitAll(uid);
        %%%%% CALCULATE REFRACTORINESS and DECIDE IF IT IS A SINGLE OR MULTI UNIT
        [singleUnit, refractoryViolationRate, refractoryViolationRateMF, relativeSpkTimesMsec, targetSpikeRates] = calculateRefractoryViolation(unit.spikeTimesSecs',allTrials, leverHoldTimes, leverReleaseTimesGLX, unit.neuronType, acg_edges);
        [isInterrupted, interruptionMoments] = isUniformlyDistributed(unit.spikeTimesSecs, roiStartTimeSec, roiEndTimeSec, trialCount);
        %[h_half, p_half, h_normal, p_normal, chiResult, skewnessResult, kurtosisResult, ksResult, lilliesResult, hSmaller, hLarger, skewData, skewNormal] = isNormallyDistributed(unit.amplitudes);       

        if singleUnit && ~isInterrupted           
            unitIdsSingle = [unitIdsSingle unit.id];            
            logger.info('printRefractoriness', [' Id=' num2str(unit.id) ' refrViol=%' num2str(refractoryViolationRate*100,'%.2f') ' (%' num2str(refractoryViolationRateMF*100,'%.2f') ' for MF) type=' unit.neuronType ]);
        end

        %%%%%%%%%%%%%%% PLOT AMPLITUDE DISTRIBUTION TO CHECK CONTINUITY %%%%%%%%%%%%%%%%%%%%%%%
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
        title(['Unit=' num2str(unit.id) ' Single=' num2str(singleUnit) ' refrViol=%' num2str(refractoryViolationRate*100,'%.2f') ' (%' num2str(refractoryViolationRateMF*100,'%.2f') ' for MF)']);
        if any(~isnan(targetSpikeRates))
            ylim([0 max(targetSpikeRates)*1.1]);
        end
        set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE); %,'LineWidth',1.5)
        
        %s2 = subplot(1,2,2)  
        u2 = uipanel(f, 'position', [0.5, 0, .5, 1]);
        s = scatterhist(unit.spikeTimesSecs,unit.amplitudes,'Location','SouthEast', 'Direction','out','Parent',u2);
        edges = plotStartTime:BIN_SIZE_CONTINUITY:roiEndTimeSec;
        if length(edges)>2
            edgesPlt = edges(1:end-1)+(edges(2)-edges(1))/2;
            s(2).Children(1).BinEdges = edgesPlt;
        end
        xline(roiStartTimeSec,'-', ['Pred. starts at:' num2str(roiStartTimeSec,'%.2f') ' s'],'LineWidth',1.5, 'FontWeight','bold', 'Color', [1 .2 0 0.9]);
        xline(roiEndTimeSec,'-', ['Ends at:' num2str(roiEndTimeSec,'%.2f') ' s'],'LineWidth',1.5, 'FontWeight','bold', 'Color', [1 .2 0 0.9]);
        
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
    
    logger.info('printRefractoriness', '********************** GOOD UNITS WITH INTERRUPTION: Check if they are really interrupted! If so, these are potential NOISE UNITS ***************************');
    unitIdsNoise = [];
    for uid=1:length(unitAll)
        unit = unitAll(uid);
        %%%%% CALCULATE REFRACTORINESS and DECIDE IF IT IS A SINGLE OR MULTI UNIT
        [singleUnit, refractoryViolationRate, refractoryViolationRateMF] = calculateRefractoryViolation(unit.spikeTimesSecs',allTrials, leverHoldTimes, leverReleaseTimesGLX, unit.neuronType, acg_edges);
        [isInterrupted, interruptionMoments] = isUniformlyDistributed(unit.spikeTimesSecs, roiStartTimeSec, roiEndTimeSec, trialCount);

        if singleUnit && isInterrupted
            unitIdsNoise = [unitIdsNoise unit.id];   
            logger.info('printRefractoriness', [' Id=' num2str(unit.id) ' refrViol=%' num2str(refractoryViolationRate*100,'%.2f') ' (%' num2str(refractoryViolationRateMF*100,'%.2f') ' for MF) type=' unit.neuronType ]);            
        end
    end

    logger.info('printRefractoriness', '********************** MULTI UNITS WITH REFRACTORY VIOLATIONS ***************************');
    unitIdsMulti = [];
    for uid=1:length(unitAll)
        unit = unitAll(uid);
        %%%%% CALCULATE REFRACTORINESS and DECIDE IF IT IS A SINGLE OR MULTI UNIT
        [singleUnit, refractoryViolationRate, refractoryViolationRateMF] = calculateRefractoryViolation(unit.spikeTimesSecs',allTrials, leverHoldTimes, leverReleaseTimesGLX, unit.neuronType, acg_edges);
        [isInterrupted, interruptionMoment] = isUniformlyDistributed(unit.spikeTimesSecs, roiStartTimeSec, roiEndTimeSec, trialCount);

        if ~singleUnit
            unitIdsMulti = [unitIdsMulti unit.id];   
            logger.info('printRefractoriness', [' Id=' num2str(unit.id) ' refrViol=%' num2str(refractoryViolationRate*100,'%.2f') ' (%' num2str(refractoryViolationRateMF*100,'%.2f') ' for MF) type=' unit.neuronType ]);            
        end
    end

    % DO NOT CURATE UNTIL you figure out how to do it with Francisco
    curate(unitIdsSingle, unitIdsMulti, unitIdsNoise);
end