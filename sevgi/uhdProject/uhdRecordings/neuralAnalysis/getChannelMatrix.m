function channelMatrix = getChannelMatrix(chCenter)
    globals;

    channelMatrix = CHANNEL_ORGANIZATION_UHD_TYPE_3;
    
%     channelMatrix = ones(CHANNEL_MATRIX_LENGTH,CHANNEL_MATRIX_LENGTH)*UNDEFINED;
% 
%     if chCenter>0 && chCenter<MAX_CHANNELS
%         if rem(CHANNEL_MATRIX_LENGTH,2) == 0
%            error(['Set CHANNEL_MATRIX_LENGTH to an odd number! It is now ' num2str(CHANNEL_MATRIX_LENGTH)]) ;
%         end
%         
%         diffId = floor(CHANNEL_MATRIX_LENGTH/2);
%         [chCenterX, chCenterY] = find(CHANNEL_ORGANIZATION_UHD_TYPE_3 == chCenter);
%         
%         for i=1:CHANNEL_MATRIX_LENGTH % along the rows
%             for j=1:CHANNEL_MATRIX_LENGTH % along the columns
%                 newX = chCenterX-diffId+i-1;
%                 newY = chCenterY-diffId+j-1;
%                 if newX>0 && newX<=NUM_OF_ROWS_IN_PROBE && newY>0 && newY<=NUM_OF_COLUMNS_IN_PROBE
%                     channelMatrix(i, j) = CHANNEL_ORGANIZATION_UHD_TYPE_3(newX, newY);
%                 end
%             end
%         end
%     end
end