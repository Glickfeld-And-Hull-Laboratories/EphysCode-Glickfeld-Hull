%%%% Raster core function %%%%%%%%%%%%
% spikeTimes (s): Spike times in sec
% markRelevantTimes (s): Mark behaviorally relevant times on the plot
% startTime, endTime: To calculate spike rate within a given period of time
% 
% SO 12/14/2022 Hull Lab
function spikeRates=raster(spikeTimes, arrMarkRelevantTimes, startTime, endTime, fixedHoldStartsAtTrial, colors)

    globals;
    stepSize=3;
    tickSize=5;    % distance between trials on y-axis in the plot
        
    trialCount = length(spikeTimes);
    spikeRates = zeros(trialCount,1);

    lineTriplet = [.3 .3 .3]; % gray line for spikes

    alpha = 0.5;
    rgbQuartet = {};
    for iColor=1:length(colors)
        if colors{iColor}=='r'
            rgbQuartet{iColor} = [1 0 0 alpha];
        elseif colors{iColor}=='b'
            rgbQuartet{iColor} = [0 0 1 alpha];
        elseif colors{iColor}=='m'
            rgbQuartet{iColor} = [1 0 1 alpha];
        end
    end

    for indTrial=1:trialCount 
        if ~isempty(spikeTimes{indTrial})
            numspikes=length(spikeTimes{indTrial});
            xx=ones(stepSize*numspikes,1)*nan;
            yy=ones(stepSize*numspikes,1)*nan;

            %scale the time axis to ms
            xx(1:stepSize:stepSize*numspikes)=spikeTimes{indTrial};
            xx(2:stepSize:stepSize*numspikes)=spikeTimes{indTrial};
            yy(1:stepSize:stepSize*numspikes)=(indTrial-1)*tickSize;
            yy(2:stepSize:stepSize*numspikes)=yy(1:stepSize:stepSize*numspikes)+tickSize;
            plot(xx, yy, 'color', lineTriplet, 'LineWidth',1.2); % plot spikes  in dark gray [.4 .4 .4]

            sz = size(arrMarkRelevantTimes); % could mark n events
            for iMark=1:sz(1)
                markRelevantTimes = arrMarkRelevantTimes(iMark,:);                
                if ~isempty(markRelevantTimes) && indTrial<=length(markRelevantTimes) && ~isempty(markRelevantTimes{indTrial})
                    numMarkers=length(markRelevantTimes{indTrial});
                    xxMarkers=ones(stepSize*numMarkers,1)*nan;
                    yyMarkers=ones(stepSize*numMarkers,1)*nan;
                    xxMarkers(1:stepSize:stepSize*numMarkers)=markRelevantTimes{indTrial};
                    xxMarkers(2:stepSize:stepSize*numMarkers)=markRelevantTimes{indTrial};
                    yyMarkers(1:stepSize:stepSize*numMarkers)=(indTrial-1)*tickSize;
                    yyMarkers(2:stepSize:stepSize*numMarkers)=yyMarkers(1:stepSize:stepSize*numMarkers)+tickSize;
                    plot(xxMarkers, yyMarkers, 'color', rgbQuartet{iMark}, 'LineWidth',4); % plot behavioral events
                end
            end
            spikeRates(indTrial)=numspikes/(endTime(indTrial)-startTime(indTrial)); % endOfTrial-startOfTrial
        end
    end
    
    if fixedHoldStartsAtTrial>0
        yline(fixedHoldStartsAtTrial*tickSize,'k', 'LineWidth',3, 'alpha',0.5);
    end
    xt = get(gca,'ytick');    
    set(gca,'YTick',xt, 'yticklabel',xt/tickSize) % normalize back again to actual trial numbers
end