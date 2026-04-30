function [channelMatrix, indexMatrix] = getChannelMatrix(chCenter)
    globals;

    %channelMatrix = CHANNEL_ORGANIZATION_NP_1;
    
    channelMatrix = ones(PLOT_MATRIX_ROWS,PLOT_MATRIX_COLUMNS)*UNDEFINED;
    indexMatrix = cell(PLOT_MATRIX_ROWS,PLOT_MATRIX_COLUMNS);

    if chCenter>=0 && chCenter<=MAX_CHANNELS                
        %diffId = floor(CHANNEL_MATRIX_LENGTH/2);
        [chCenterX, chCenterY] = find(CHANNEL_ORGANIZATION == chCenter);
        
        for i=1:PLOT_MATRIX_ROWS % along the rows
            for j=1:PLOT_MATRIX_COLUMNS % along the columns
                newX = chCenterX-floor(PLOT_MATRIX_ROWS/2)+i-1;
                %newY = mod(chCenterY-floor(PLOT_MATRIX_COLUMNS/2)+j,PLOT_MATRIX_COLUMNS)+1;
                if newX>0 && newX<=NUM_ROWS %&& newY>0 && newY<=NUM_COLUMNS
                    indexMatrix{i, j} = [newX, j];
                    channelMatrix(i, j) = CHANNEL_ORGANIZATION(newX, j); %newY
                end
            end
        end
    end
end