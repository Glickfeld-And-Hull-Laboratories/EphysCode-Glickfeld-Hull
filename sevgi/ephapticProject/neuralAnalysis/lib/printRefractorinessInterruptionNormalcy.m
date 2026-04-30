function printRefractorinessInterruptionNormalcy(unitAll) %, leverHoldTimes, leverReleaseTimesGLX, allTrials, fixedHoldStartsAtTrial)
    globals;
    
    BIN_SIZE_CORRELOGRAM = 1; % ms
    acg_edges = -X_MAX_CORRELOGRAM-BIN_SIZE_CORRELOGRAM:BIN_SIZE_CORRELOGRAM:X_MAX_CORRELOGRAM+BIN_SIZE_CORRELOGRAM;
%     trialCount = length(leverHoldTimes)-fixedHoldStartsAtTrial+1;
    % Parse the corresponding metafile
    imecMetaFiles = dir([pathToRecFolder '*imec*ap.meta']);
    imecMetaFile = imecMetaFiles(1);
    imecMeta = readMeta(imecMetaFile.name, pathToRecFolder);
    recordingTimeSec = str2double(imecMeta.fileTimeSecs);
    
    plotStartTime = 0;
    roiStartTimeSec = 0;
    if HARD_CUT~=Inf
        roiEndTimeSec = HARD_CUT;
    else
        roiEndTimeSec = recordingTimeSec;
    end

    unitIdsSingle = [];
    unitIdsNoise = [];
    unitIdsMulti = [];

    strSingle = newline;
    strNoise = newline;
    strMulti = newline;
    strDCN = newline;
    strOut = newline;

    for uid=1:length(unitAll)
        unit = unitAll(uid);
        
        %%%%% CALCULATE REFRACTORINESS and DECIDE IF IT IS A SINGLE OR MULTI UNIT
        [singleUnit, refractoryViolationRate, refractoryViolationRateMF, relativeSpkTimesMsec, targetSpikeRates] = calculateRefractoryViolation(unit.spikeTimesSecs',unit.neuronType, acg_edges);
        refractoryViolationRateLlobet = refViolations(unit.spikeTimesSecs, []);
        [isInterrupted, interruptionMoments] = isUniformlyDistributed(unit.spikeTimesSecs, roiStartTimeSec, roiEndTimeSec);
        %[h_half, p_half, h_normal, p_normal, chiResult, skewnessResult, kurtosisResult, ksResult, lilliesResult, hSmaller, hLarger, skewData, skewNormal] = isNormallyDistributed(unit.amplitudes);       

        plotAmplDistribution_Curation(relativeSpkTimesMsec, targetSpikeRates, acg_edges, unit, singleUnit, refractoryViolationRate, refractoryViolationRateMF, refractoryViolationRateLlobet, isInterrupted, plotStartTime, roiEndTimeSec, interruptionMoments);
        
        if refractoryViolationRate>REFRACTORY_VIOLATION_LIMIT
            refStr = ' REFRVIOL=%';
        else
            refStr = ' refrViol=%';
        end

        if unit.depth < 0 && unit.depth >= DEPTH_OF_CEREBELLAR_CORTEX % In the cerebellar cortex
           
            if singleUnit 
                if ~isInterrupted           
                    unitIdsSingle = [unitIdsSingle unit.id]; 
                    strSingle = [strSingle ' Id=' num2str(unit.id) refStr ' Llobet=' num2str(refractoryViolationRateLlobet*100,'%.2f') ' mine=' num2str(refractoryViolationRate*100,'%.2f') ' (%' num2str(refractoryViolationRateMF*100,'%.2f') ' for MF) type=' unit.neuronType newline];
                else
                    unitIdsNoise = [unitIdsNoise unit.id];
                    sMoments = '';
                    if length(interruptionMoments)<4
                        sMoments = ['CHECK THIS --> INTERRUPT (LESS THAN 4) = ' num2str(length(interruptionMoments))];
                    end
                    strNoise = [strNoise sMoments ' Id=' num2str(unit.id) refStr ' Llobet=' num2str(refractoryViolationRateLlobet*100,'%.2f') ' mine=' num2str(refractoryViolationRate*100,'%.2f') ' (%' num2str(refractoryViolationRateMF*100,'%.2f') ' for MF) type=' unit.neuronType newline];
                end                
            else
                unitIdsMulti = [unitIdsMulti unit.id];   
                strMulti = [strMulti ' Id=' num2str(unit.id) ' refrViol=%' ' Llobet=' num2str(refractoryViolationRateLlobet*100,'%.2f') ' mine=' num2str(refractoryViolationRate*100,'%.2f') ' (%' num2str(refractoryViolationRateMF*100,'%.2f') ' for MF) type=' unit.neuronType newline];            
            end
        
        % In the cerebellar nuclei
        elseif (unit.depth < DEPTH_OF_CEREBELLAR_CORTEX && unit.depth >= DEPTH_OF_DCN)            
            strGood = '';
            if singleUnit
                if ~isInterrupted           
                    unitIdsSingle = [unitIdsSingle unit.id];
                    strGood = 'GOOD DCN UNIT';
                else
                    unitIdsNoise = [unitIdsNoise unit.id];
                end                
            else
                unitIdsMulti = [unitIdsMulti unit.id];
            end
            strDCN = [strDCN strGood ' Id=' num2str(unit.id) ' refrViol=%' ' Llobet=' num2str(refractoryViolationRateLlobet*100,'%.2f') ' mine=' num2str(refractoryViolationRate*100,'%.2f') ' (%' num2str(refractoryViolationRateMF*100,'%.2f') ' for MF) type=' unit.neuronType newline];            
        
        % Outside of the brain or deeper than the cerebellar nuclei
        elseif (unit.depth >= 0 || unit.depth < DEPTH_OF_DCN)
            unitIdsNoise = [unitIdsNoise unit.id];            
            strOut = [strOut 'OUTSIDE Id=' num2str(unit.id) ' refrViol=%' ' Llobet=' num2str(refractoryViolationRateLlobet*100,'%.2f') ' mine=' num2str(refractoryViolationRate*100,'%.2f') ' (%' num2str(refractoryViolationRateMF*100,'%.2f') ' for MF) type=' unit.neuronType newline];            
        end
    end

    logger.info('printRefractoriness', '********************** GOOD UNITS WITH NO INTERRUPTION ***************************');
    logger.info('printRefractoriness', strSingle);
    logger.info('printRefractoriness', '********************** GOOD UNITS WITH INTERRUPTION: Check if they are really interrupted! If so, these are potential NOISE UNITS ***************************');
    logger.info('printRefractoriness', strNoise);
    logger.info('printRefractoriness', '********************** MULTI UNITS WITH REFRACTORY VIOLATIONS ***************************');
    logger.info('printRefractoriness', strMulti);
    logger.info('printRefractoriness', '********************** DCN UNITS FOR FUTURE PROJECTS ***************************');
    logger.info('printRefractoriness', strDCN);
    logger.info('printRefractoriness', '********************** OUTSIDE UNITS (PUT INTO NOISE) ***************************');
    logger.info('printRefractoriness', strOut);
    
    % DO NOT CURATE UNTIL you figure out how to do it with Francisco
    curate(unitIdsSingle, unitIdsMulti, unitIdsNoise);
end