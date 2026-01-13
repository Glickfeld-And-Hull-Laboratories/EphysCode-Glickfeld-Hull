



function [data_cropped] = cropRFtoCenter(az, el, data, sideLength)

    if isnan(az) || isnan(el)
        data_cropped = NaN(sideLength,sideLength);
        return
    end

    [yDim, xDim] = size(data);
    
    halfSide = floor(sideLength / 2);

    % Initial centered crop bounds
    xStart = az - halfSide;
    xEnd   = xStart + sideLength - 1;

    yStart = el - halfSide;
    yEnd   = yStart + sideLength - 1;

    % Shift crop if it exceeds image boundaries (x direction)
    if xStart < 1
        xStart = 1;
        xEnd   = sideLength;
    elseif xEnd > xDim
        xEnd   = xDim;
        xStart = xDim - sideLength + 1;
    end

    % Shift crop if it exceeds image boundaries (y direction)
    if yStart < 1
        yStart = 1;
        yEnd   = sideLength;
    elseif yEnd > yDim
        yEnd   = yDim;
        yStart = yDim - sideLength + 1;
    end

    % Final crop
    data_cropped = data(yStart:yEnd, xStart:xEnd);

end