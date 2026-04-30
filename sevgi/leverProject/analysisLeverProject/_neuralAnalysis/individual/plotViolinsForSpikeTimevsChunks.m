%%%% PLOT VIOLINS %%%%%%%%%%%%
% chunks: It is developed for 4 chunks of data, could be developed more for
% dynamic range of chunks
%
% SO 3/16/2023 Hull Lab

function plotViolinsForSpikeTimevsChunks(spikesEvents, behavEvents, chunks, chunkCatNames, minYLim, maxYLim, sTitle, sXLabel, sYLabel, sGeneralTitle, sFolder, sFileName, strTrialType)

        globals;

        spikes = cell(1, length(spikesEvents));
        categs = cell(1,length(spikesEvents));

        for indInputs=1:length(spikesEvents)            
            spikesEvent = spikesEvents{indInputs};
            behavEvent = behavEvents{indInputs};
            arrSpikes = [];
            categ = {};
            for indChunk=1:length(chunks)-1
                trialInds = find(behavEvent>chunks(indChunk) & behavEvent<=chunks(indChunk+1)); % which trials to include in that chunk                
                arrTemp = cell2mat(spikesEvent(trialInds))';
                if isempty(arrTemp)
                    arrTemp=0;
                end
                arrSpikes = [arrSpikes arrTemp];
                categTemp = cell(1,length(arrTemp));
                categTemp(:) = chunkCatNames(indChunk);% multiply category name as many spikes as in the chunk
                categ = {categ{:} categTemp{:}};
            end
            spikes(indInputs) = {arrSpikes};
            categs(indInputs) = {categ};
        end

        %***************************** PLOTTING ***************************************

        f = figure;
        f.Position = [globalX globalY globalW globalH];
        
        subplot(2,2,1)
        hold on
        grid on
        
        if ~isempty(spikes{1})
            vs = violinplot(spikes{1}, categs{1});
            xlabel(sXLabel)
            ylabel(sYLabel{1});
            ylim([minYLim*1.1 maxYLim*1.1]);
            title(sTitle{1});
        end

        subplot(2,2,2)
        hold on
        grid on
        
        if ~isempty(spikes{2})
            vs = violinplot(spikes{2}, categs{2});
            xlabel(sXLabel)
            ylabel(sYLabel{2});
            ylim([minYLim*1.1 maxYLim*1.1]);
            title(sTitle{2});
        end

        subplot(2,2,3)
        hold on
        grid on

        if ~isempty(spikes{3})
            vs = violinplot(spikes{3}, categs{3});
            xlabel(sXLabel)
            ylabel(sYLabel{3});
            ylim([minYLim*1.1 maxYLim*1.1]);
            title(sTitle{3});
        end

        subplot(2,2,4)
        hold on
        grid on
        
        if ~isempty(spikes{4})
            vs = violinplot(spikes{4}, categs{4});
            xlabel(sXLabel)
            ylabel(sYLabel{4});
            ylim([minYLim*1.1 maxYLim*1.1]);
            title(sTitle{4});
        end

        sgtitle([sGeneralTitle ' ' strTrialType ' trials'])  
        print([pathToFigureFolder sFolder '/' sFileName '_' strTrialType '_ylim_' num2str(minYLim) '_' num2str(maxYLim) '.tif'], '-dtiff', '-r200');
end