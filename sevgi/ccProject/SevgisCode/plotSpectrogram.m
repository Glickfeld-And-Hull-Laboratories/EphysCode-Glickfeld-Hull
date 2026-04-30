% https://www.dsprelated.com/showarticle/1221.php

function maxPowValue = plotSpectrogram(spikeRates, sTitle, sFile, sXLabel, flagPlot)
    globals;

    maxPowValue = 0;
    edgesPlt = EDGES(1:end-1)+(EDGES(2)-EDGES(1))/2;
    
    if isempty(sXLabel)
        if MODE_ALIGNMENT == MODE_ALIGNMENT_TO_CLICK
            sXLabel = 'click';
        elseif MODE_ALIGNMENT == MODE_ALIGNMENT_TO_LICK
            sXLabel = 'lick';
        end
    end

    if size(spikeRates,1)>1
        spikeRates = mean(spikeRates,1);
    end

    if ~isempty(spikeRates) && ~all(all(isnan(spikeRates)))
        %%%%% HOW TO CALCULATE FFT %%%%%%%%% https://mark-kramer.github.io/Case-Studies-Python/03.html
%         x = spikeRates;
        dt = edgesPlt(2)-edgesPlt(1);   % Define the sampling interval
        N = length(spikeRates);         % Define the total number of data points
        T = N * dt;                     % Define the total duration of the data
        df = 1 / max(T);                % Determine frequency resolution
%         fNQ = 1 / dt / 2;               % Determine Nyquist frequency
%         faxis = [0:df:fNQ-df];             % Construct frequency axis
% 
%         xf = fft(x - mean(x));                     % Compute Fourier transform of x
%         Sxx = 2 * dt ^ 2 / T * (xf .* conj(xf));    % Compute spectrum
%         Sxx = Sxx(:,1:floor(length(x)/2));
% 
%         plot(faxis, real(Sxx));         % Plot spectrum vs frequency
% %         xlim([0 100])                  % Select frequency range
%         xlabel('Frequency [Hz]')        % Label the axes
%         ylabel('Power [$\mu V^2$/Hz]')
% 
%         figure;
%         plot(faxis, 10 * log10(Sxx / max(Sxx)));   % Plot the spectrum in decibels => Other, weaker rhythmic activity may occur in the data, but these features remain hidden from visual inspection. One technique to emphasize lower-amplitude rhythms hidden by large-amplitude oscillations is to change the scale of the spectrum to decibels 
% %         xlim([0, 100]);                            % Select the frequency range.
%         ylim([-60, 0]);                            % Select the decibel range.
%         xlabel('Frequency [Hz]');                  % Label the axes.
%         ylabel('Power [dB]');
% 
%         figure;
%         semilogx(faxis, 10 * log10(Sxx / max(Sxx)));  % Log-log scale
%         xlim([df, 100]);                              % Select frequency range
%         ylim([-60, 0]);                               % ... and the decibel range.
%         xlabel('Frequency [Hz]');                     % Label the axes.
%         ylabel('Power [dB]');

        Fs = 1 / dt;               % Define the sampling frequency,
        interval = int32(Fs);        % ... the interval size,
        overlap = int32(Fs * 0.95);  % ... and the overlap intervals
        
        %%%%% SPECTROGRAM %%%%%%%%%

        %         detrendedSpikeRates = spikeRates(2:end-1)-mean(spikeRates(2:end-1));
        % Fs = 1/BIN_SIZE_PSTH;

%         [S,freq,T,P] = spectrogram(detrendedSpikeRates,PWELCH_WINDOW_SAMPLE_SIZE,PWELCH_WINDOW_OVERLAP_SIZE,[],Fs,'yaxis');

        
        if NORMALIZE_X_AXIS_FOR_EACH_LICK==0
            % smtSpikeRates = smooth(edgesPlt,spikeRates, SPIKE_SPAN, SMOOTH_TYPE_L);
            detrendedSpikeRates = detrend(spikeRates(2:end-1),1); % removes linear trend to get rid of 0 freq peak

            [Sxx,freq,T, P] = spectrogram(detrendedSpikeRates,interval,overlap,[],Fs,'yaxis');
            loggedP = 10*log10(P);

            indsFreq = find(4<freq & freq<=10); % since we're only interested in [4-10] Hz freq range for licking
            inds = floor(size(loggedP,2)/2); % since it is lick onset aligned, start looking from [0-end] which means get the second half of the time window
            roiP = loggedP(indsFreq,inds:end);
            thrsld = -12;
            if strcmp(NEURON_TYPE,NEURON_TYPE_SS)
                thrsld = -10; % SS needed laxer threshold
            end
        else
            detrendedSpikeRates = detrend(spikeRates(2:end-1),1); % removes linear trend to get rid of 0 freq peak

            [Sxx,freq,T, P] = spectrogram(detrendedSpikeRates,interval,overlap,[],Fs,'yaxis');
            % [Sxx,freq,T, P] = spectrogram(spikeRates,2000,1800,[],Fs,'yaxis');
            loggedP = 10*log10(P);

            indsFreq = find(0<freq & freq<=10);
            roiP = loggedP(indsFreq,:); % cos if lick cycle aligned, we're interested in all freq along the whole time axis
            thrsld = -8;
            if strcmp(NEURON_TYPE,NEURON_TYPE_SS)
                thrsld = -11; % SS needed laxer threshold
            end
        end

        if any(any(roiP>thrsld)) % if we see any power value bigger than -5 dB

            maxPowValue = max(max(roiP));

            if flagPlot
                f = prePlot();
                f.Position = [globalX globalY 800 500];        
                surf(T,freq,loggedP,'edgecolor','none');
                % T is the center of each segment. 4000 length of the signal, k=# of segments (4000-800(overlapSize))/(1000(window_size)-800)=16 segments
                % First segment starts from 0-1000 (window size) and 500 (0.5 sec) being the center and shifts with 200 samples cos 800 is the # of overlapping samples
                colorbar;
                view(0,270);
                ylim([0 10]);
                
                % set(gca,'YScale','log','TickDir','out');
                clim([-15 0]);
                zlabel('Power/frequency (dB/Hz)');
                ylabel(colorbar,'Power/frequency (dB/Hz)','VerticalAlignment','bottom','Rotation',270,'FontSize',12);
                xLabels = xticklabels;
                nXLabels = cellfun(@(x) str2double(x),xLabels);
        %         xlim([-PRE_BEHAVIORAL_EVENT_PLOT+mean(nXLabels) POST_BEHAVIORAL_EVENT_PLOT+mean(nXLabels)]);
                xNewLabels = nXLabels-PRE_BEHAVIORAL_EVENT; 
                xNewLabels = num2cell(xNewLabels);
                xNewLabels{1}=[];
                xNewLabels{3}=[];
                xNewLabels{5}=[];
                xNewLabels{7}=[];
                xticklabels(xNewLabels);
                postPlot(f, ['Time from ' sXLabel], 'Frequency (Hz)', [], [], [], [], sTitle, [sFile '_spectrogram']); % -PRE_BEHAVIORAL_EVENT_PLOT, POST_BEHAVIORAL_EVENT_PLOT
            end
        end
    end
end