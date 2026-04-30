% =========================================================
% Directly transferred from DemoReadSGLXData.m (SpikeGLX_Datafile_Tools https://billkarsh.github.io/SpikeGLX/#post-processing-tools)
% =========================================================
% Having acquired a block of raw imec data using ReadBin(),
% convert values to gain-corrected voltages. The conversion
% is only applied to the saved-channel indices in chanList.
% Remember saved-channel indices are in range [1:nSavedChans].
% The dimensions of the dataArray remain unchanged. ChanList
% examples:
%
%   [1:AP]      % all AP chans (AP from ChannelCountsIM)
%   [2,6,20]    % just these three channels
%
function dataArray = gainCorrectIM(dataArray, meta)

    % Look up gain with acquired channel ID
    chans = originalChans(meta);
    [APgain,LFgain] = chanGainsIM(meta);
    nAP = length(APgain);
    nNu = nAP * 2;

    % Common conversion factor
    fI2V = int2Volts(meta);

    if length(size(dataArray)) == 3
        for i = 1:length(chans)-1 % exclude Synch channel
            k = chans(i);       % acquisition index 
            if k <= nAP
                conv = fI2V / APgain(k);
            elseif k <= nNu
                conv = fI2V / LFgain(k - nAP);
            else
                continue;
            end        
            dataArray(:,i,:) = dataArray(:,i,:) * conv; % dataArray is 3D (3000 randomInstances X 385 channels X 180 sample points around the spike time)        
        end
    elseif length(size(dataArray)) == 2 % No channel detail, just 2D (3000 randomInstances X 180 sample points around the spike time)
        conv = fI2V / APgain(1); % Since the gain is same for all channels
        dataArray = dataArray * conv;
    end
end