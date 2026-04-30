%%%% PLOT CORRELOGRAM (AUTO/CROSS) %%%%%%%%%%%%
% unitMasterID: Master Unit ID that is modulating the Slave unit
% unitSlaveID: Slave Unit ID that is modulated by Master unit
% unitMasterSpikeTimesSec: Reference Unit Spike Times (s)
% unitSlaveSpikeTimesSec: Slave Unit Spike Times (s)
% sTitle: Title for different types of correlogram
% see https://www.med.upenn.edu/mulab/crosscorrelation.html to learn about shift predictor
% SO 1/5/2023 Hull Lab
function [singleUnit] = correlogram(pairs, pairType, unitsMaster, unitsSlave, laserOnsetTimes, laserOffsetTimes, startTimeSecs, endTimeSecs, sFileName)
    globals;

    nPairs = size(pairs,1);
    suppressedPairs = zeros(1,nPairs);
    if pairType == PAIR_TYPE_ACG
        edges = -X_MAX_ACG-BIN_SIZE_ACG:BIN_SIZE_ACG:X_MAX_ACG+BIN_SIZE_ACG; % first and last bins are to be deleted later
        binSize = BIN_SIZE_ACG;
    else
        edges = -X_MAX_CCG-BIN_SIZE_CCG:BIN_SIZE_CCG:X_MAX_CCG+BIN_SIZE_CCG; % first and last bins are to be deleted later
        binSize = BIN_SIZE_CCG;
    end
    
    if pairType == PAIR_TYPE_ACG
        ccgType = ACG;
    elseif pairType == PAIR_TYPE_CS_SS
        ccgType = CS_SS;        
    elseif pairType == PAIR_TYPE_MF_SS
        ccgType = MF_SS;
    elseif pairType == PAIR_TYPE_MF_GO
        ccgType = MF_GO;
    elseif pairType == PAIR_TYPE_GO_SS
        ccgType = GO_SS;
    elseif pairType == PAIR_TYPE_MLI_SS
        ccgType = MLI_SS;
    elseif pairType == PAIR_TYPE_SS_DCN
        ccgType = SS_DCN;
    elseif pairType == PAIR_TYPE_SS_SS
        ccgType = SS_SS;
    elseif pairType == PAIR_TYPE_MLI_MLI
        ccgType = MLI_MLI;
    elseif pairType == PAIR_TYPE_GO_GO
        ccgType = GO_GO;  
    elseif pairType == PAIR_TYPE_OTHER_SS
        ccgType = OTHER_SS;
    elseif pairType == PAIR_TYPE_OTHER_CS
        ccgType = OTHER_CS;
    elseif pairType == PAIR_TYPE_OTHER_MF
        ccgType = OTHER_MF;
    elseif pairType == PAIR_TYPE_OTHER_GO
        ccgType = OTHER_GO;
    elseif pairType == PAIR_TYPE_OTHER_MLI
        ccgType = OTHER_MLI;
    elseif pairType == PAIR_TYPE_OTHER_OTHER
        ccgType = OTHER_OTHER;
    elseif pairType == PAIR_TYPE_MF_OTHER
        ccgType = MF_OTHER;
    end

    singleUnit = 0;
    if ~isempty(pairs)        
        for iPair=1:nPairs
            unitMaster = unitsMaster(find([unitsMaster.id]==pairs(iPair,1)));
            unitSlave = unitsSlave(find([unitsSlave.id]==pairs(iPair,2)));
            
            if ~isempty(unitMaster) && ~isempty(unitSlave)

                unitMasterID = unitMaster.id;
                unitSlaveID = unitSlave.id;

                % Get spikes within a pre-defined interval
                sPreHeader = '';
                if nargin>6 && ~isempty(startTimeSecs) && ~isempty(endTimeSecs)
                    unitMasterSpikeTimesSecWhole = unitMaster.spikeTimesSecs(startTimeSecs<unitMaster.spikeTimesSecs & unitMaster.spikeTimesSecs<endTimeSecs)';
                    unitSlaveSpikeTimesSecWhole = unitSlave.spikeTimesSecs(startTimeSecs<unitSlave.spikeTimesSecs & unitSlave.spikeTimesSecs<endTimeSecs)'; 
                    sPreHeader = sFileName;
                else                    
                    unitMasterSpikeTimesSecWhole = unitMaster.spikeTimesSecs';
                    unitSlaveSpikeTimesSecWhole = unitSlave.spikeTimesSecs'; 
                end
                                                       
                if ~isempty(unitMasterSpikeTimesSecWhole) && ~isempty(unitSlaveSpikeTimesSecWhole)
                    
                    startTimesSecLaser = [0 laserOffsetTimes+EXCLUDE_POST_LASER_EFFECT_DUR];
                    endTimesSecLaser = [laserOnsetTimes-EXCLUDE_PRE_LASER_EFFECT_DUR Inf];
                    limits = [startTimesSecLaser' endTimesSecLaser'];

                    unitMasterSpikeTimesSec = [];
                    unitSlaveSpikeTimesSec = [];
                    for indLaser = 1:size(limits,1)
                        idMaster = find(limits(indLaser,1)<unitMasterSpikeTimesSecWhole & limits(indLaser,2)>unitMasterSpikeTimesSecWhole);
                        if ~isempty(idMaster)
                            unitMasterSpikeTimesSec = [unitMasterSpikeTimesSec unitMasterSpikeTimesSecWhole(idMaster)];
                        end

                        idSlave = find(limits(indLaser,1)<unitSlaveSpikeTimesSecWhole & limits(indLaser,2)>unitSlaveSpikeTimesSecWhole);
                        if ~isempty(idSlave)
                            unitSlaveSpikeTimesSec = [unitSlaveSpikeTimesSec unitSlaveSpikeTimesSecWhole(idSlave)];
                        end
                    end

                    if ~isempty(unitMasterSpikeTimesSec) && ~isempty(unitSlaveSpikeTimesSec)
                        meanSlaveSpikeRate = length(unitSlaveSpikeTimesSec)/(unitSlaveSpikeTimesSec(end)-unitSlaveSpikeTimesSec(1));
        
                        unitSlaveSpikeTimesMSec = unitSlaveSpikeTimesSec*1000; % convert to ms
                        unitMasterSpikeTimesMSec = unitMasterSpikeTimesSec*1000; % convert to ms
                        if length(unitSlaveSpikeTimesMSec)>MAX_ARRAY_LENGTH % Check if max array size is not exceeded!
                            unitSlaveSpikeTimesMSec = unitSlaveSpikeTimesMSec(randperm(length(unitSlaveSpikeTimesMSec), MAX_ARRAY_LENGTH));
                        end
                        if length(unitMasterSpikeTimesMSec)>MAX_ARRAY_LENGTH % Check if max array size is not exceeded!
                            unitMasterSpikeTimesMSec = unitMasterSpikeTimesMSec(randperm(length(unitMasterSpikeTimesMSec), MAX_ARRAY_LENGTH));
                        end
                        relativeSpkTimesMs = unitSlaveSpikeTimesMSec' - unitMasterSpikeTimesMSec;
                        %relativeSpkTimesMs = 1000*relativeSpkTimes;
                        if pairType == PAIR_TYPE_ACG
                            relativeSpkTimesMs(eye(size(relativeSpkTimesMs))==1) = NaN; % set diagonal to NaN, cos its the difference with the spike itself, ACG is not interested in self-difference of the very same spike! It emerges as if there is a contamination at t=0!
                        end
        
                        % constrain it within the ROI
                        % These two lines were crashing Matlab
            %                 relativeSpkTimesMs(relativeSpkTimesMs<=edges(1) & relativeSpkTimesMs>=edges(end))=NaN; 
            %                 relativeSpkTimesMs = relativeSpkTimesMs(~isnan(relativeSpkTimesMs));
                        % So swapped with this line
                        relativeSpkTimesMs = relativeSpkTimesMs(relativeSpkTimesMs>=edges(1) & relativeSpkTimesMs<=edges(end));
                            
                        % ************* Decide whether plot or not depending on the suppression ******************************
                        
                        binCounts = histcounts(relativeSpkTimesMs,edges);
                        slaveSpikeRates = binCounts/(sum(binCounts)*binSize/1000); % divide by 1000 if binSize in ms  % sum(binCounts)==length(relativeSpkTimes) cos we added up that many times (as many as Master.unit's spikes), average over number of spikes of master unit (to reveal y-axis be the firing rate of Slave neuron itself) and specified bin size
                    
                        indsRefractory = find(edges>REFRACTORY_RANGE(1) & edges<REFRACTORY_RANGE(2)); % get the edges between -1 and 1 (-1 inclusive 1 exclusive since smaller than 1 ms spikes contained in the previous bin)
                        if pairType == PAIR_TYPE_ACG && strcmp(unitMaster.neuronType,NEURON_TYPE_MF)
                            indsRefractory = find(edges>REFRACTORY_RANGE_MF(1) & edges<REFRACTORY_RANGE_MF(2));
                        end
                        indsRefractory = indsRefractory-1; % cos SlaveSpikeRates has 1 less bins
                        refractoryViolation = slaveSpikeRates(indsRefractory);
                        refractoryViolationRate = mean(refractoryViolation)/mean(slaveSpikeRates);
                        
                        % If the unit is MF but we cannot classify at the moment, what would be the refractory period
                        indsRefractoryMF = find(edges>REFRACTORY_RANGE_MF(1) & edges<REFRACTORY_RANGE_MF(2));
                        indsRefractoryMF = indsRefractoryMF-1; % cos SlaveSpikeRates has 1 less bins
                        refractoryViolationMF = slaveSpikeRates(indsRefractoryMF);
                        refractoryViolationRateMF = mean(refractoryViolationMF)/mean(slaveSpikeRates);
        
                        singleUnit = 0;
                        if pairType == PAIR_TYPE_ACG && ~strcmp(unitMaster.neuronType,NEURON_TYPE_MF) && refractoryViolationRate<=.05 % Refractory violation is 5 % for all cell types except MF
                            singleUnit = 1;
                        elseif pairType == PAIR_TYPE_ACG && strcmp(unitMaster.neuronType,NEURON_TYPE_MF) && refractoryViolationRate<=.1 % Refractory violation is 10 % for MFs
                            singleUnit = 1;        
                        end
                    
                        deviationValue = 10; %abs(sum(corrCounts(find(edges>=-CCG_DEVIATION_RANGE&edges<=CCG_DEVIATION_RANGE)))); % Find the suppression around zero
                    
                        % Plot CCGs that only have higher deviation OR plot all ACGs
                        if (deviationValue > CCG_DEVIATION_CRITERION || pairType == PAIR_TYPE_ACG) && ~isempty(slaveSpikeRates) && any(~isnan(slaveSpikeRates))
                            sHeader = [sPreHeader ' CCG for Unit ' num2str(unitSlaveID) ' (' unitSlave.neuronType ') wrt Unit ' num2str(unitMasterID) ' (' unitMaster.neuronType ')'];
                            if pairType == PAIR_TYPE_ACG
                                sSingle = 'Multi';
                                if singleUnit
                                    sSingle = 'Single';
                                end
                                sHeader = [sPreHeader ' ACG for ' sSingle ' Unit ' num2str(unitSlaveID) ' (' unitSlave.neuronType ') ContamRate=' num2str(refractoryViolationRate*100,'%.2f') ' % (MF ContamRate=' num2str(refractoryViolationRateMF*100,'%.2f') ' %)'];
                            end
                    
                            f = figure;    
                            f.Position = [globalX globalY globalW globalH];  
                            
                            hstRaw = histogram(relativeSpkTimesMs,edges);
                            if ~all(isnan(slaveSpikeRates))
                                hstRaw.BinCounts = slaveSpikeRates; 
                            end          
                            grid on;
                            set(gca,'box','off');
                            xlabel('lag (ms)'); 
                            ylabel('Spikes/s');
                            ylim([0 max(slaveSpikeRates)*1.3]);                        
                            set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE); %,'LineWidth',1.5)
                            title([sHeader ' mean FR=' num2str(meanSlaveSpikeRate,'%.2f') ' spk/s']);
                            
                            if pairType == PAIR_TYPE_ACG
                                sPrintFolder = [pathToFigureFolder num2str(unitSlaveID)];
                                print([sPrintFolder '/ACG_' num2str(unitSlaveID) '_' sPreHeader '.tif'], '-dtiff', '-r120');
                                exportgraphics(f,[sPrintFolder '/ACG_' num2str(unitSlaveID) '_' sPreHeader '.pdf'], 'ContentType', 'vector', 'Resolution', 1000);
                            else
                                print([pathToFigureFolder ccgType '/CCG_' num2str(unitSlaveID) 'wrt' num2str(unitMasterID) '_' sPreHeader '.tif'], '-dtiff', '-r120');
                                exportgraphics(f,[pathToFigureFolder ccgType '/CCG_' num2str(unitSlaveID) 'wrt' num2str(unitMasterID) '_' sPreHeader '.pdf'], 'ContentType', 'vector', 'Resolution', 1000);
                            end
                    
                            % exportgraphics(f,[pathToFigureFolder ccgType '/' sHeader '_' num2str(unitMasterID) '_' num2str(unitSlaveID) '_' sTitle '_' num2str(X_MAX_ACG) 'sec_xlim_' num2str(PRE_TIME_RELEASE) '_' num2str(PRE_TIME_RELEASE) '.pdf'], 'ContentType', 'vector', 'Resolution', 200);
                    
                            close all
                            logger.info('correlogram',[ccgType ' ' num2str(unitSlaveID) ' wrt ' num2str(unitMasterID) ' plotted for ' sPreHeader ':' ccgType '/CCG_' num2str(unitSlaveID) 'wrt' num2str(unitMasterID) '_' sPreHeader '.tif']);
        %                     deviated = 1;
                        else
                            logger.info('correlogram',[ccgType ' ' num2str(unitSlaveID) ' wrt ' num2str(unitMasterID) ' had no spikes for ' sPreHeader ':' ccgType '/CCG_' num2str(unitSlaveID) 'wrt' num2str(unitMasterID) '_' sPreHeader '.tif']);
                        end
                    else
                        logger.info('correlogram',[ccgType ' ' num2str(unitSlaveID) ' wrt ' num2str(unitMasterID) ' had no spikes for ' sPreHeader ':' ccgType '/CCG_' num2str(unitSlaveID) 'wrt' num2str(unitMasterID) '_' sPreHeader '.tif']);
                    end
                else
                    logger.info('correlogram',[ccgType ' ' num2str(unitSlaveID) ' wrt ' num2str(unitMasterID) ' had no spikes for ' sPreHeader ':' ccgType '/CCG_' num2str(unitSlaveID) 'wrt' num2str(unitMasterID) '_' sPreHeader '.tif']);
                end
%                 else
%                     logger.info('correlogram',[ccgType '_' num2str(unitMasterID) '_' num2str(unitSlaveID) ' could NOT pass the deviation criterion or spikes are empty! deviationValue=' num2str(deviationValue)]);  
%                     deviated = 0;
%                 end
            end
        end
    end
end