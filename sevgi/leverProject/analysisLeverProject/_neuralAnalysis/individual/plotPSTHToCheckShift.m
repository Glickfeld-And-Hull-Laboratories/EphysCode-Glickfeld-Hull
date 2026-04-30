% cellSpkTimes can be one cell array at a time as opposed to classical
% plotPSTH(), in which sometimes there can be multiple cell arrays for
% Hit,Fa, Miss. Here we already chunk trials into 3 and superimpose them on
% the same psth
function plotPSTHToCheckShift(unitID, neuronType, layer, channel, allTrialCount, cellSpkTimes, fixedHoldStartsAtTrial, targetVisStim, preTime, postTime, edges, sTitle, sFileName, strTrialType, colors)
        globals;
        
        if fixedHoldStartsAtTrial>0 % if session is mixed with random/fixed trials
            randomTrials = cellSpkTimes(1:fixedHoldStartsAtTrial-1)';
            fixedTrials = cellSpkTimes(fixedHoldStartsAtTrial:end)';
        else % fixedHoldStartsAtTrial==0 means only random trials
            randomTrials = cellSpkTimes'; % All random trials
        end
        
        [randomTrials1, randomTrials2, randomTrials3] = trialDivider(randomTrials);
        [fixedTrials1, fixedTrials2, fixedTrials3] = trialDivider(fixedTrials);

        arrSpksRandom1 = cell2mat(randomTrials1)';
        arrSpksRandom2 = cell2mat(randomTrials2)';
        arrSpksRandom3 = cell2mat(randomTrials3)';
        arrSpksFixed1 = cell2mat(fixedTrials1)';
        arrSpksFixed2 = cell2mat(fixedTrials2)';
        arrSpksFixed3 = cell2mat(fixedTrials3)';

        %%%%%%%%%%%%%%%%%%%%%% Check if there is any shift throughout trial time course - PSTH - Random/Fixed Delay Spikes %%%%%%%%%%%%%%%%%%%        

        plotPSTHShiftEachChunk(unitID, neuronType, layer, arrSpksRandom1, arrSpksRandom2, length(randomTrials1), length(randomTrials2), preTime, postTime, edges, sTitle, 'Rand', '1st', '2nd', sFileName, 'Rand_1vs2' , strTrialType, colors);
        plotPSTHShiftEachChunk(unitID, neuronType, layer, arrSpksRandom1, arrSpksRandom3, length(randomTrials1), length(randomTrials3), preTime, postTime, edges, sTitle, 'Rand', '1st', '3rd', sFileName, 'Rand_1vs3' , strTrialType, colors);
        plotPSTHShiftEachChunk(unitID, neuronType, layer, arrSpksRandom2, arrSpksRandom3, length(randomTrials2), length(randomTrials3), preTime, postTime, edges, sTitle, 'Rand', '2nd', '3rd', sFileName, 'Rand_2vs3' , strTrialType, colors);
        plotPSTHShiftEachChunk(unitID, neuronType, layer, arrSpksFixed1, arrSpksFixed2, length(fixedTrials1), length(fixedTrials2), preTime, postTime, edges, sTitle, 'Fixed', '1st', '2nd', sFileName, 'Fixed_1vs2' , strTrialType, colors);
        plotPSTHShiftEachChunk(unitID, neuronType, layer, arrSpksFixed1, arrSpksFixed3, length(fixedTrials1), length(fixedTrials3), preTime, postTime, edges, sTitle, 'Fixed', '1st', '3rd', sFileName, 'Fixed_1vs3' , strTrialType, colors);
        plotPSTHShiftEachChunk(unitID, neuronType, layer, arrSpksFixed2, arrSpksFixed3, length(fixedTrials2), length(fixedTrials3), preTime, postTime, edges, sTitle, 'Fixed', '2nd', '3rd', sFileName, 'Fixed_2vs3' , strTrialType, colors);
end