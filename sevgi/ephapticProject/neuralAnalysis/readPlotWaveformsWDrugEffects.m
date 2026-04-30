function [unitGood,unitMua,unitNoise] = readPlotWaveformsWDrugEffects(unitsList)

    globals;
    samplingRate = str2double(getMetaFile().imSampRate);

    readForTheFirstTime = 0;
    for iList = 1:length(unitsList)        
        for uid=1:length(unitsList{iList})
            if ~iscell(unitsList{iList}(uid).waveFormsBaseline) && unitsList{iList}(uid).waveFormsBaseline == UNDEFINED
                [waveFormsBaseline, samplingRate] = readWaveForm(unitsList{iList}(uid), 0, MOMENT_OF_1ST_DRUG_PUT_IN);
                unitsList{iList}(uid).waveFormsBaseline = waveFormsBaseline;
                readForTheFirstTime = 1;
            end
%             if ~all(all(cellfun(@isempty,unitsList{iList}(uid).waveFormsBaseline)))
%                 plotSpikeWaveForm(unitsList{iList}(uid), unitsList{iList}(uid).waveFormsBaseline, samplingRate, BASELINE);
%             end
    
            if isempty(MOMENT_OF_2ND_DRUG_PUT_IN) % Only one drug applied during recording
                secondMoment = Inf;
            else
                secondMoment = MOMENT_OF_2ND_DRUG_PUT_IN;
            end
    
            if ~iscell(unitsList{iList}(uid).waveForms1stDrug) && unitsList{iList}(uid).waveForms1stDrug == UNDEFINED
                [waveForms1stDrug, samplingRate] = readWaveForm(unitsList{iList}(uid), MOMENT_OF_1ST_DRUG_WASH_IN, secondMoment);
                unitsList{iList}(uid).waveForms1stDrug = waveForms1stDrug;
                readForTheFirstTime = 1;
            end
%             if ~all(all(cellfun(@isempty,unitsList{iList}(uid).waveForms1stDrug)))
%                 plotSpikeWaveForm(unitsList{iList}(uid), unitsList{iList}(uid).waveForms1stDrug, samplingRate, FIRST_DRUG);
%             end            
    
            if ~isempty(MOMENT_OF_2ND_DRUG_PUT_IN) 
                if ~iscell(unitsList{iList}(uid).waveForms2ndDrug) && unitsList{iList}(uid).waveForms2ndDrug == UNDEFINED
                    [waveForms2ndDrug, samplingRate] = readWaveForm(unitsList{iList}(uid), MOMENT_OF_2ND_DRUG_WASH_IN, Inf);
                    unitsList{iList}(uid).waveForms2ndDrug = waveForms2ndDrug;
                    readForTheFirstTime = 1; 
                end
%                 if ~all(all(cellfun(@isempty,unitsList{iList}(uid).waveForms2ndDrug)))
%                     plotSpikeWaveForm(unitsList{iList}(uid), unitsList{iList}(uid).waveForms2ndDrug, samplingRate, SECOND_DRUG);
%                 end
    
                allWaveForms = {unitsList{iList}(uid).waveFormsBaseline, unitsList{iList}(uid).waveForms1stDrug, unitsList{iList}(uid).waveForms2ndDrug};
                plotMultipleSpikeWaveForm(unitsList{iList}(uid), allWaveForms, samplingRate, {BASELINE, FIRST_DRUG, SECOND_DRUG});
            elseif isempty(MOMENT_OF_2ND_DRUG_PUT_IN)
                allWaveForms = {unitsList{iList}(uid).waveFormsBaseline, unitsList{iList}(uid).waveForms1stDrug};
                plotMultipleSpikeWaveForm(unitsList{iList}(uid), allWaveForms, samplingRate, {BASELINE, FIRST_DRUG});
            end
            close all;
        end        
    end

    if readForTheFirstTime % New data appeared, needs to be saved!
        if length(unitsList)==3 % unitGood
%             [unitGood,unitMua,unitNoise] = saveUnits({unitsList{1}, unitsList{2}, unitsList{3}});  % decided not to save, takes so long time and so much
%             space! And I'm not using these waveForms anywhere else other than plotting here
        elseif length(unitsList)==1
            [unitGood,unitMua,unitNoise] = saveUnits(unitsList{iList}(uid));
        end
    else
        if length(unitsList)==3 % unitGood
            unitGood = unitsList{1};
            unitMua = unitsList{2};
            unitNoise = unitsList{3};
        elseif length(unitsList)==1
            unitGood = unitsList{1}(uid);
            unitMua = unitsList{1}(uid);
            unitNoise = unitsList{1}(uid);
        end        
    end
end