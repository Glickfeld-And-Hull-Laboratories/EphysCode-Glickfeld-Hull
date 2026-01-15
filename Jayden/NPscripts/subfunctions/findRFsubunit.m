%
%
%
% Inputs:
%   data    - [xDim,yDim], STA image
%   subtype - 1 or 2, for on (1) or off (2) subunit search

function [bw2] = findRFsubunit(data,subtype)
    
    if subtype == 2         % If looking for off subunit, invert data
        data = data.*-1;
    end

    xDim = size(data,1);
    yDim = size(data,2);
    
    xmask = zeros(xDim,yDim);
    
    [m, max_linidx] = max(data(:));     % Find the maximum value and its linear index
    [row, col] = ind2sub(size(data), max_linidx);   % Convert the linear index to row and column subscripts

    
    % Create mask for approximate location of RF

    if (row-10 > 0) && (row+10 < xDim)
        row_min = row-10;
        row_max = row+10;
    elseif (row-10 < 1)
        extraRows = abs(row-10)+1; 
        row_min = row-(10-extraRows);
        row_max = row+10+extraRows;
    elseif (row+10 > xDim)
        extraRows = row+10-xDim; 
        row_min = row-10-extraRows;
        row_max = row+10-extraRows;
    else    % row may == xDim
        row_min = row-10;
        row_max = row+10;
    end


    if (col-15 > 0) && (col+15 < yDim)
        col_min = col-15;
        col_max = col+15;
    elseif (col-15 < 1)
        extraCols = abs(col-15)+1; 
        col_min = col-(15-extraCols);
        col_max = col+15+extraCols;
    elseif (col+15 > yDim)
        extraCols = col+15-yDim; 
        col_min = col-15-extraCols;
        col_max = col+15-extraCols;
    else        % col may == yDim
        col_min = col-15;
        col_max = col+15;
    end


    xmask(row_min:row_max,col_min:col_max) = 1;


    maskOn = data;
    maskOn(maskOn<0) = 0;
    bw2 = activecontour(maskOn,xmask);
    cc = bwconncomp(bw2);

    % initialize
    bestRsq = -inf;
    bestIdx = NaN;
    
    for iObj = 1:cc.NumObjects
        % build mask for this object
        tmpMask = false(size(data));
        tmpMask(cc.PixelIdxList{iObj}) = true;
    
        rsq = getRsqLinearRegress_SG(data, tmpMask);
        
        if rsq > bestRsq
            bestRsq = rsq;
            bestIdx = iObj;
        end
    end
    
    % keep the mask with highest R^2
    bw2 = false(size(data));
    bw2(cc.PixelIdxList{bestIdx}) = true;



end

    % 
    % maskOn = data;
    % maskOn(maskOn<0) = 0;
    % bw = activecontour(maskOn,xmask);
    % cc = bwconncomp(bw);
    % p = regionprops(cc,"Area");
    % [maxArea,maxIdx] = max([p.Area]);
    % bw2 = cc2bw(cc,ObjectsToKeep=maxIdx);


    % 
    % figure;        
    %     subplot(4,4,1); imagesc(data); colormap('gray'); subtitle('Zscore'); clim([-7 7])
    %     subplot(4,4,2); imagesc(maskOn); colormap('gray'); subtitle('Zscore'); clim([-7 7])
    %     subplot(4,4,3); imshow(bw)
    %     subplot(4,4,4); imshow(label2rgb(L, @jet, [.5 .5 .5]))
