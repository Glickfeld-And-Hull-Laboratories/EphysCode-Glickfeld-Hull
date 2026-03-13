function export_RF_validation_allCells( ...
        indLoop, ind_DS, STA_cropped, modelRegistry, omitCells)

outputPDF = 'RF_validation_all_cells.pdf';

% delete existing file so pages append cleanly
if exist(outputPDF,'file')
    delete(outputPDF)
end

for ii = indLoop
    
    cellID = ind_DS(ii);
    
    % skip unwanted cells
    if ismember(cellID, omitCells)
        continue
    end
    
    fprintf('Processing cell %d\n', cellID)
    
    STA = STA_cropped(:,:,ii);
    
    %% run model from registry
    [params, modelRF, fitInfo] = modelRegistry(1).fitFcn(STA);
    
    %% plot validation figure
    fig = visualize_RF_validation(STA, modelRF, params);
    
    sgtitle(sprintf('Cell %d  |  RSS = %.3f', cellID, fitInfo.RSS))
    
    %% append to PDF
    exportgraphics(fig, outputPDF, 'Append', true)
    
    close(fig)
    
end

fprintf('Saved results to %s\n', outputPDF)

end