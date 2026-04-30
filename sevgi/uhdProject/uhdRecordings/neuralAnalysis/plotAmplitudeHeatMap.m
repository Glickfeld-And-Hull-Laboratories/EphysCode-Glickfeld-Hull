%%%% Amplitude distribution for spatial foot print the unit %%%%%%%%%%%%
% unit: its amplitudes to be plotted per channel as a heat map 
% 
% SO 8/16/2024 Hull Lab
function plotAmplitudeHeatMap(unit)
    globals;


    f = figure;
    f.Position = [globalX globalY floor(globalW/2) floor(globalH/2)];
    xvalues = [0:NUM_OF_COLUMNS_IN_PROBE-1];
    yvalues = NUM_OF_COLUMNS_IN_PROBE*[NUM_OF_ROWS_IN_PROBE-1:-1:0];
    % excludeFunkyCh = [unit.amplitudePerChannel(1:FUNKY_CHANNEL) unit.amplitudePerChannel(FUNKY_CHANNEL+2:end)]; % NO NEED, it's excluded while reading the data

    % Removed from here, added into findBestChannel_Amplitudes() for consistency % Add Funky channel back for visualization purposes
%     if FUNKY_CHANNEL~=-1
%         thresholdedAmplitudes = [thresholdedAmplitudes(1:FUNKY_CHANNEL-1) mean(thresholdedAmplitudes) thresholdedAmplitudes(FUNKY_CHANNEL:end)];
%     end
    reshapedArr = reshape(unit.amplitudePerChannel, NUM_OF_COLUMNS_IN_PROBE, NUM_OF_ROWS_IN_PROBE)';
    cdata = reshapedArr(NUM_OF_ROWS_IN_PROBE:-1:1,:);
    h = heatmap(xvalues,yvalues,cdata,'CellLabelColor', 'none', 'Colormap',parula); %winter parula jet

    h.Title = {['Amplitude Heat Map for unit=' num2str(unit.id)], ['best ch=' num2str(unit.ch)]};
%     h.XLabel = 'X';
%     h.YLabel = 'Y';
    h.FontSize = PLOT_FONT_SIZE;
    sFolder = [pathToFigureFolder num2str(unit.id)];    
    print([sFolder '/' FILE_NAME_AMPLITUDE_HEAT_MAP '_' num2str(unit.id) '.tif'], '-dtiff', '-r100'); 
    exportgraphics(f,[sFolder '/' FILE_NAME_AMPLITUDE_HEAT_MAP '_' num2str(unit.id) '.pdf'], 'ContentType', 'vector', 'Resolution', 1000);
    logger.info('plotAmplitudeHeatMap', ['Amplitude heatmap is plotted for unit=' num2str(unit.id)]);
    close all;
end