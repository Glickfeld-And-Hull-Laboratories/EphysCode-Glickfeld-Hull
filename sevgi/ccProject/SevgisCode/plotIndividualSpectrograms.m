function [arrHasPowerCueAligned, arrHasPowerRewAligned] = plotIndividualSpectrograms(spikeRates, arrModulationMagnitudeCue, arrModulationMagnitudeRew, sTitle, dayDepths)

    globals;

%     edgesPlt = EDGES(1:end-1)+(EDGES(2)-EDGES(1))/2;
        
    if MODE_ALIGNMENT == MODE_ALIGNMENT_TO_CLICK
        pathToSSPsdFolder = pathToSSToClickPsdFolder;
    elseif MODE_ALIGNMENT == MODE_ALIGNMENT_TO_LICK
        pathToSSPsdFolder = pathToSSToLickPsdFolder;
    end

    arrHasPowerCueAligned = zeros(1,size(spikeRates,1));
    arrHasPowerRewAligned = zeros(1,size(spikeRates,1));
    
    for ind=1:size(spikeRates,1)
        smtSpikeRates = spikeRates(ind,:); %smooth(edgesPlt,spikeRates(ind,:), SPIKE_SPAN, SMOOTH_TYPE_L);

        sDepth = '';
        if ~isempty(dayDepths)
            sDepth = num2str(dayDepths(ind),'%.0f');
        end

        if MODE_ALIGNMENT == MODE_ALIGNMENT_TO_CLICK
            if arrModulationMagnitudeCue(ind)~=0               
                sFilePSD = [pathToSSPsdFolder num2str(ind) '_CueMod_dep' sDepth '_' sTitle '_' TRIALOUTCOMES_TO_INCLUDE_TITLE];
                arrHasPowerCueAligned(ind) = plotSpectrogram(smtSpikeRates, ['i=' num2str(ind) ' ' sTitle], sFilePSD, [], FLAG_PLOT_INDIVIDUAL_SPECTROGRAMS);
            end
        end

        if arrModulationMagnitudeRew(ind)~=0
            sFilePSD = [pathToSSPsdFolder num2str(ind) '_RewMod_dep' sDepth '_' sTitle '_' TRIALOUTCOMES_TO_INCLUDE_TITLE];
            arrHasPowerRewAligned(ind) = plotSpectrogram(smtSpikeRates, ['i=' num2str(ind) ' ' sTitle], sFilePSD, [], FLAG_PLOT_INDIVIDUAL_SPECTROGRAMS);
        end
    end
end