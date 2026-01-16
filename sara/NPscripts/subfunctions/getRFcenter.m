

% ===== INPUTS =====
%  data - [xDim x yDim x nCells]
% 

% For troubleshooting:
% data = squeeze(localConMap_data_all([990],4,:,:));
%
% data=zscoreSTA_filt;

function [azs, els] = getRFcenter(data)
    
    nCells = size(data,3);

    for i = 1:nCells
        if i == 1
            dataCell = data;
        else
            dataCell = data(:,:,i);
        end
        
        dataAbs = abs(dataCell);
        dataMask = dataAbs;
        dataMask(dataAbs < 1)     = 0;

    % Calculate weighted mean
        xVec = 1:size(dataCell,1);
        yVec = 1:size(dataCell,2);
        [X, Y] = meshgrid(yVec, xVec);
        total = sum(dataMask(:));
        az = sum(Y(:) .* dataMask(:)) / total;
        el = sum(X(:) .* dataMask(:)) / total;

        if i>2
            azs(i)      = az;
            els(i)      = el;
        else
            azs         = az;
            els         = el;

        end

    end
    figure; % all code should be inside function
            subplot 321; imagesc(dataCell); colormap('gray');
            subplot 322; imagesc(dataAbs); 
            subplot 323; imagesc(dataMask) 
            % subplot 324; imagesc(dataMaskSmooth)
            % subplot 325; imagesc(rfCenter); hold on; plot(elWM, azWM, 'c.', 'MarkerSize', 10) 
end