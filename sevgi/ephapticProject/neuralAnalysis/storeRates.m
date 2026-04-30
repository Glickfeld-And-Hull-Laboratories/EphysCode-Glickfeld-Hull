function units = storeRates(sWhichPhase, units, masterId, slaveId, unitMasterID, unitSlaveID, slaveSpikeRates, semSpikeRates, doRateCorrected)
        globals;

        sIsRunning = '';
        if FLAG_STATIONARY_VS_RUNNING
            sIsRunning = 'Running';
        end

        if doRateCorrected   
            if strcmp(sWhichPhase,CLASSIC)
                % Initialize field for the whole array
                sFieldName = ['rateCorrectedCCGPairs' sIsRunning];
            elseif strcmp(sWhichPhase,BASELINE)
                % Initialize field for the whole array
                sFieldName = ['rateCorrectedCCGPairs0' sIsRunning];
            elseif strcmp(sWhichPhase,FIRST_DRUG)
                sFieldName = ['rateCorrectedCCGPairs1' sIsRunning];  
            elseif strcmp(sWhichPhase,SECOND_DRUG)
                sFieldName = ['rateCorrectedCCGPairs2' sIsRunning];  
            end
        else
            if strcmp(sWhichPhase,CLASSIC)
                sFieldName = ['regularCCGSpikeRates' sIsRunning]; 
                elseif strcmp(sWhichPhase,BASELINE)
                % Initialize field for the whole array
                sFieldName = ['regularCCGSpikeRates0' sIsRunning];
            elseif strcmp(sWhichPhase,FIRST_DRUG)
                sFieldName = ['regularCCGSpikeRates1' sIsRunning];  
            elseif strcmp(sWhichPhase,SECOND_DRUG)
                sFieldName = ['regularCCGSpikeRates2' sIsRunning];
            end
        end
            
        if ~isfield(units,sFieldName)
            for ind=1:length(units)
%                         units(ind).rateCorrectedCCGPairs = struct([]);
                eval(['units(ind).' sFieldName ' = struct([]);']);
            end
        end
        
        eval(['len = length(units(slaveId).' sFieldName ');']);
%                 len = length(units(slaveId).rateCorrectedCCGPairs);
        eval(['units(slaveId).' sFieldName '(len+1).id = unitMasterID;']);
%                 units(slaveId).rateCorrectedCCGPairs(len+1).id = unitMasterID;
        eval(['units(slaveId).' sFieldName '(len+1).spikeRates = slaveSpikeRates;']);
%                 units(slaveId).rateCorrectedCCGPairs(len+1).spikeRates = slaveSpikeRates; % CCG Spike Rate values WRT Master unit spike time     
        eval(['units(slaveId).' sFieldName '(len+1).semSpikeRates = semSpikeRates;']);
%                 units(slaveId).rateCorrectedCCGPairs(len+1).semSpikeRates = semSpikeRates;

        if unitMasterID~= unitSlaveID % to check if it is not an ACG, if so there is no need to save the reflection of it
            eval(['len = length(units(masterId).' sFieldName ');']);
%                     len = length(units(masterId).rateCorrectedCCGPairs);
            eval(['units(masterId).' sFieldName '(len+1).id = unitSlaveID;']);
%                     units(masterId).rateCorrectedCCGPairs(len+1).id = unitSlaveID;
            eval(['units(masterId).' sFieldName '(len+1).spikeRates = flip(slaveSpikeRates);']);
%                     units(masterId).rateCorrectedCCGPairs(len+1).spikeRates = flip(slaveSpikeRates); % to save time & energy, for master unit it's gonna be flipped version of the same CCG
            eval(['units(masterId).' sFieldName '(len+1).semSpikeRates = flip(semSpikeRates);']);
%                     units(masterId).rateCorrectedCCGPairs(len+1).semSpikeRates = flip(semSpikeRates);
        end
            

%         else
%             if strcmp(sWhichPhase,CLASSIC)
%                 if ~isfield(units,'regularCCGSpikeRates')
%                     for ind=1:length(units)
%                         units(ind).regularCCGSpikeRates = struct([]);
%                     end
%                 end
% 
%                 len = length(units(slaveId).regularCCGSpikeRates);
%                 units(slaveId).regularCCGSpikeRates(len+1).id = unitMasterID;
%                 units(slaveId).regularCCGSpikeRates(len+1).spikeRates = slaveSpikeRates; % CCG Spike Rate values WRT Master unit spike time                                
%                 units(slaveId).regularCCGSpikeRates(len+1).semSpikeRates = semSpikeRates;
% 
%                 if unitMasterID~= unitSlaveID % to check if it is not an ACG, if so there is no need to save the reflection of it
%                     len = length(units(masterId).regularCCGSpikeRates);
%                     units(masterId).regularCCGSpikeRates(len+1).id = unitSlaveID;
%                     units(masterId).regularCCGSpikeRates(len+1).spikeRates = flip(slaveSpikeRates); % to save time & energy, for master unit it's gonna be flipped version of the same CCG
%                     units(masterId).regularCCGSpikeRates(len+1).semSpikeRates = flip(semSpikeRates);
%                 end
%             elseif strcmp(sWhichPhase,BASELINE)
%                 if ~isfield(units,'regularCCGSpikeRates0')
%                     for ind=1:length(units)
%                         units(ind).regularCCGSpikeRates0 = struct([]);
%                     end
%                 end
% 
%                 len = length(units(slaveId).regularCCGSpikeRates0);
%                 units(slaveId).regularCCGSpikeRates0(len+1).id = unitMasterID;
%                 units(slaveId).regularCCGSpikeRates0(len+1).spikeRates = slaveSpikeRates; % CCG Spike Rate values WRT Master unit spike time                                
%                 units(slaveId).regularCCGSpikeRates0(len+1).semSpikeRates = semSpikeRates;
%     
%                 if unitMasterID~= unitSlaveID % to check if it is not an ACG, if so there is no need to save the reflection of it
%                     len = length(units(masterId).regularCCGSpikeRates0);
%                     units(masterId).regularCCGSpikeRates0(len+1).id = unitSlaveID;
%                     units(masterId).regularCCGSpikeRates0(len+1).spikeRates = flip(slaveSpikeRates); % to save time & energy, for master unit it's gonna be flipped version of the same CCG
%                     units(masterId).regularCCGSpikeRates0(len+1).semSpikeRates = flip(semSpikeRates);
%                 end
%             elseif strcmp(sWhichPhase,FIRST_DRUG)
%                 if ~isfield(units,'regularCCGSpikeRates1')
%                     for ind=1:length(units)
%                         units(ind).regularCCGSpikeRates1 = struct([]);
%                     end
%                 end
% 
%                 len = length(units(slaveId).regularCCGSpikeRates1);
%                 units(slaveId).regularCCGSpikeRates1(len+1).id = unitMasterID;
%                 units(slaveId).regularCCGSpikeRates1(len+1).spikeRates = slaveSpikeRates; % CCG Spike Rate values WRT Master unit spike time                                
%                 units(slaveId).regularCCGSpikeRates1(len+1).semSpikeRates = semSpikeRates;
% 
%                 if unitMasterID~= unitSlaveID % to check if it is not an ACG, if so there is no need to save the reflection of it
%                     len = length(units(masterId).regularCCGSpikeRates1);
%                     units(masterId).regularCCGSpikeRates1(len+1).id = unitSlaveID;
%                     units(masterId).regularCCGSpikeRates1(len+1).spikeRates = flip(slaveSpikeRates); % to save time & energy, for master unit it's gonna be flipped version of the same CCG
%                     units(masterId).regularCCGSpikeRates1(len+1).semSpikeRates = flip(semSpikeRates);
%                 end                
%             elseif strcmp(sWhichPhase,SECOND_DRUG)
%                 if ~isfield(units,'regularCCGSpikeRates2')
%                     for ind=1:length(units)
%                         units(ind).regularCCGSpikeRates2 = struct([]);
%                     end
%                 end
% 
%                 len = length(units(slaveId).regularCCGSpikeRates2);
%                 units(slaveId).regularCCGSpikeRates2(len+1).id = unitMasterID;
%                 units(slaveId).regularCCGSpikeRates2(len+1).spikeRates = slaveSpikeRates; % CCG Spike Rate values WRT Master unit spike time                                
%                 units(slaveId).regularCCGSpikeRates2(len+1).semSpikeRates = semSpikeRates;
%     
%                 if unitMasterID~= unitSlaveID % to check if it is not an ACG, if so there is no need to save the reflection of it
%                     len = length(units(masterId).regularCCGSpikeRates2);
%                     units(masterId).regularCCGSpikeRates2(len+1).id = unitSlaveID;
%                     units(masterId).regularCCGSpikeRates2(len+1).spikeRates = flip(slaveSpikeRates); % to save time & energy, for master unit it's gonna be flipped version of the same CCG
%                     units(masterId).regularCCGSpikeRates2(len+1).semSpikeRates = flip(semSpikeRates);
%                 end
%             end
%         end
end