% Wrapper for Nicholas' function, rfSingleCycleStaticFigure4PhasePolarThreshold
% 
% Parameters are:
%   1 - spatial offset
%   2 - wavelength of stimulus
%   3 - sigma_x
%   4 - sigma_y
%   5 - phase offset
%   6 - threshold

% patterny cell
    pdfDir = fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', 'sara', 'Papers', 'CrossOri_FeedforwardV1','figures');
    if ~exist(pdfDir, 'dir'); mkdir(pdfDir); end
    
    pdfFile = fullfile(pdfDir, 'rfSingleCycleStaticFigure4PhasePolarThreshold_cell1.pdf');
    if isfile(pdfFile); delete(pdfFile); end
    
    rfSingleCycleStaticFigure4PhasePolarThreshold_SG(2, 20, 3, 3.5, 36, 0.12)
    
    exportgraphics(gcf, pdfFile,'ContentType', 'vector','Append', true);
    close(gcf)

% componenty cell
    pdfDir = fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', 'sara', 'Papers', 'CrossOri_FeedforwardV1','figures');
    if ~exist(pdfDir, 'dir'); mkdir(pdfDir); end
    
    pdfFile = fullfile(pdfDir, 'rfSingleCycleStaticFigure4PhasePolarThreshold_cell2.pdf');
    if isfile(pdfFile); delete(pdfFile); end

    rfSingleCycleStaticFigure4PhasePolarThreshold_SG(2, 20, 3, 5, 36, 0.12)
    
    exportgraphics(gcf, pdfFile,'ContentType', 'vector','Append', true);
    close(gcf)







