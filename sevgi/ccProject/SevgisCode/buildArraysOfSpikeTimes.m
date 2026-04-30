function [dayCSResponsiveAllMice, dayCSNonResponsiveAllMice, ...
    daySSJuiceRespCueRespCSAllMice, daySSJuiceRespCueNonRespCSAllMice, ...
    daySSJuiceNonRespCueRespCSAllMice, daySSJuiceNonRespCueNonRespCSAllMice, ...
    daySSAllLicksJuiceRespCueRespCSAllMice, daySSAllLicksJuiceRespCueNonRespCSAllMice, ...
    daySSAllLicksJuiceNonRespCueRespCSAllMice, daySSAllLicksJuiceNonRespCueNonRespCSAllMice] = ...
    buildArraysOfSpikeTimes(miceVSSelectedDay, cellCSResponsivePerMouse, cellCSNonResponsivePerMouse, ...
    cellSSJuiceRespCueRespCSPerMouse, cellSSJuiceRespCueNonRespCSPerMouse, ...
    cellSSJuiceNonRespCueRespCSPerMouse, cellSSJuiceNonRespCueNonRespCSPerMouse, ...
    cellSSAllLicksJuiceRespCueRespCSPerMouse, cellSSAllLicksJuiceRespCueNonRespCSPerMouse, ...
    cellSSAllLicksJuiceNonRespCueRespCSPerMouse, cellSSAllLicksJuiceNonRespCueNonRespCSPerMouse, ...
    dayAll)

    if ~dayAll
        dayCSResponsiveAllMice = {};
        dayCSNonResponsiveAllMice = {};

        daySSJuiceRespCueRespCSAllMice = {};
        daySSJuiceRespCueNonRespCSAllMice = {};
        daySSJuiceNonRespCueRespCSAllMice = {};
        daySSJuiceNonRespCueNonRespCSAllMice = {};

        daySSAllLicksJuiceRespCueRespCSAllMice = {};
        daySSAllLicksJuiceRespCueNonRespCSAllMice = {};
        daySSAllLicksJuiceNonRespCueRespCSAllMice = {};
        daySSAllLicksJuiceNonRespCueNonRespCSAllMice = {};
        
        for i=1:length(miceVSSelectedDay)
            csResponseForMouse = cellCSResponsivePerMouse{miceVSSelectedDay(i,1)}{miceVSSelectedDay(i,2)};
            dayCSResponsiveAllMice = [dayCSResponsiveAllMice csResponseForMouse];

            csNonResponseForMouse = cellCSNonResponsivePerMouse{miceVSSelectedDay(i,1)}{miceVSSelectedDay(i,2)};
            dayCSNonResponsiveAllMice = [dayCSNonResponsiveAllMice csNonResponseForMouse];
            
            if ~isempty(cellSSJuiceRespCueRespCSPerMouse)
                ssRespForMouse = cellSSJuiceRespCueRespCSPerMouse{miceVSSelectedDay(i,1)}{miceVSSelectedDay(i,2)};
                daySSJuiceRespCueRespCSAllMice = [daySSJuiceRespCueRespCSAllMice ssRespForMouse];
            end
    
            if ~isempty(cellSSJuiceRespCueNonRespCSPerMouse)
                ssRespForMouse = cellSSJuiceRespCueNonRespCSPerMouse{miceVSSelectedDay(i,1)}{miceVSSelectedDay(i,2)};
                daySSJuiceRespCueNonRespCSAllMice = [daySSJuiceRespCueNonRespCSAllMice ssRespForMouse];
            end
            
            if ~isempty(cellSSJuiceNonRespCueRespCSPerMouse)
                ssRespForMouse = cellSSJuiceNonRespCueRespCSPerMouse{miceVSSelectedDay(i,1)}{miceVSSelectedDay(i,2)};
                daySSJuiceNonRespCueRespCSAllMice = [daySSJuiceNonRespCueRespCSAllMice ssRespForMouse];
            end
    
            if ~isempty(cellSSJuiceNonRespCueNonRespCSPerMouse)
                ssRespForMouse = cellSSJuiceNonRespCueNonRespCSPerMouse{miceVSSelectedDay(i,1)}{miceVSSelectedDay(i,2)};
                daySSJuiceNonRespCueNonRespCSAllMice = [daySSJuiceNonRespCueNonRespCSAllMice ssRespForMouse];
            end


            if ~isempty(cellSSAllLicksJuiceRespCueRespCSPerMouse)
                ssAllLicksRespForMouse = cellSSAllLicksJuiceRespCueRespCSPerMouse{miceVSSelectedDay(i,1)}{miceVSSelectedDay(i,2)};
                daySSAllLicksJuiceRespCueRespCSAllMice = [daySSAllLicksJuiceRespCueRespCSAllMice ssAllLicksRespForMouse];
            end
    
            if ~isempty(cellSSAllLicksJuiceRespCueNonRespCSPerMouse)
                ssAllLicksRespForMouse = cellSSAllLicksJuiceRespCueNonRespCSPerMouse{miceVSSelectedDay(i,1)}{miceVSSelectedDay(i,2)};
                daySSAllLicksJuiceRespCueNonRespCSAllMice = [daySSAllLicksJuiceRespCueNonRespCSAllMice ssAllLicksRespForMouse];
            end
            
            if ~isempty(cellSSAllLicksJuiceNonRespCueRespCSPerMouse)
                ssAllLicksRespForMouse = cellSSAllLicksJuiceNonRespCueRespCSPerMouse{miceVSSelectedDay(i,1)}{miceVSSelectedDay(i,2)};
                daySSAllLicksJuiceNonRespCueRespCSAllMice = [daySSAllLicksJuiceNonRespCueRespCSAllMice ssAllLicksRespForMouse];
            end
    
            if ~isempty(cellSSAllLicksJuiceNonRespCueNonRespCSPerMouse)
                ssAllLicksRespForMouse = cellSSAllLicksJuiceNonRespCueNonRespCSPerMouse{miceVSSelectedDay(i,1)}{miceVSSelectedDay(i,2)};
                daySSAllLicksJuiceNonRespCueNonRespCSAllMice = [daySSAllLicksJuiceNonRespCueNonRespCSAllMice ssAllLicksRespForMouse];
            end
        end
    else
        dayCSResponsiveAllMice = {};
        dayCSNonResponsiveAllMice = {};

        daySSJuiceRespCueRespCSAllMice = {};
        daySSJuiceRespCueNonRespCSAllMice = {};
        daySSJuiceNonRespCueRespCSAllMice = {};
        daySSJuiceNonRespCueNonRespCSAllMice = {};

        daySSAllLicksJuiceRespCueRespCSAllMice = {};
        daySSAllLicksJuiceRespCueNonRespCSAllMice = {};
        daySSAllLicksJuiceNonRespCueRespCSAllMice = {};
        daySSAllLicksJuiceNonRespCueNonRespCSAllMice = {};

        for i=1:length(cellCSResponsivePerMouse)
            csResponseForMouse = cellCSResponsivePerMouse{i};
            ssJuiceRespCueRespForMouse = [];
            ssJuiceRespCueNonRespForMouse = [];
            ssJuiceNonRespCueRespForMouse = [];
            ssJuiceNonRespCueNonRespForMouse = [];

            ssAllLicksJuiceRespCueRespForMouse = [];
            ssAllLicksJuiceRespCueNonRespForMouse = [];
            ssAllLicksJuiceNonRespCueRespForMouse = [];
            ssAllLicksJuiceNonRespCueNonRespForMouse = [];
    
            if ~isempty(cellSSJuiceRespCueRespCSPerMouse)
                ssJuiceRespCueRespForMouse = cellSSJuiceRespCueRespCSPerMouse{i};
            end
            if ~isempty(cellSSJuiceRespCueNonRespCSPerMouse)
                ssJuiceRespCueNonRespForMouse = cellSSJuiceRespCueNonRespCSPerMouse{i};
            end
            if ~isempty(cellSSJuiceNonRespCueRespCSPerMouse)
                ssJuiceNonRespCueRespForMouse = cellSSJuiceNonRespCueRespCSPerMouse{i};
            end
            if ~isempty(cellSSJuiceNonRespCueNonRespCSPerMouse)
                ssJuiceNonRespCueNonRespForMouse = cellSSJuiceNonRespCueNonRespCSPerMouse{i};
            end


            if ~isempty(cellSSAllLicksJuiceRespCueRespCSPerMouse)
                ssAllLicksJuiceRespCueRespForMouse = cellSSAllLicksJuiceRespCueRespCSPerMouse{i};
            end
            if ~isempty(cellSSAllLicksJuiceRespCueNonRespCSPerMouse)
                ssAllLicksJuiceRespCueNonRespForMouse = cellSSAllLicksJuiceRespCueNonRespCSPerMouse{i};
            end
            if ~isempty(cellSSAllLicksJuiceNonRespCueRespCSPerMouse)
                ssAllLicksJuiceNonRespCueRespForMouse = cellSSAllLicksJuiceNonRespCueRespCSPerMouse{i};
            end
            if ~isempty(cellSSAllLicksJuiceNonRespCueNonRespCSPerMouse)
                ssAllLicksJuiceNonRespCueNonRespForMouse = cellSSAllLicksJuiceNonRespCueNonRespCSPerMouse{i};
            end
    
            for j=1:length(csResponseForMouse)           
                dayCSResponsiveAllMice = [dayCSResponsiveAllMice csResponseForMouse{j}];
                
                if ~isempty(ssJuiceRespCueRespForMouse)
                    daySSJuiceRespCueRespCSAllMice = [daySSJuiceRespCueRespCSAllMice ssJuiceRespCueRespForMouse{j}];
                end
                if ~isempty(ssJuiceRespCueNonRespForMouse)
                    daySSJuiceRespCueNonRespCSAllMice = [daySSJuiceRespCueNonRespCSAllMice ssJuiceRespCueNonRespForMouse{j}];
                end

                if ~isempty(ssJuiceNonRespCueRespForMouse)
                    daySSJuiceNonRespCueRespCSAllMice = [daySSJuiceNonRespCueRespCSAllMice ssJuiceNonRespCueRespForMouse{j}];
                end
                if ~isempty(ssJuiceNonRespCueNonRespForMouse)
                    daySSJuiceNonRespCueNonRespCSAllMice = [daySSJuiceNonRespCueNonRespCSAllMice ssJuiceNonRespCueNonRespForMouse{j}];
                end


                if ~isempty(ssAllLicksJuiceRespCueRespForMouse)
                    daySSAllLicksJuiceRespCueRespCSAllMice = [daySSAllLicksJuiceRespCueRespCSAllMice ssAllLicksJuiceRespCueRespForMouse{j}];
                end
                if ~isempty(ssAllLicksJuiceRespCueNonRespForMouse)
                    daySSAllLicksJuiceRespCueNonRespCSAllMice = [daySSAllLicksJuiceRespCueNonRespCSAllMice ssAllLicksJuiceRespCueNonRespForMouse{j}];
                end

                if ~isempty(ssAllLicksJuiceNonRespCueRespForMouse)
                    daySSAllLicksJuiceNonRespCueRespCSAllMice = [daySSAllLicksJuiceNonRespCueRespCSAllMice ssAllLicksJuiceNonRespCueRespForMouse{j}];
                end
                if ~isempty(ssAllLicksJuiceNonRespCueNonRespForMouse)
                    daySSAllLicksJuiceNonRespCueNonRespCSAllMice = [daySSAllLicksJuiceNonRespCueNonRespCSAllMice ssAllLicksJuiceNonRespCueNonRespForMouse{j}];
                end
            end
        end
        
        for i=1:length(cellCSNonResponsivePerMouse)
            csNonResponseForMouse = cellCSNonResponsivePerMouse{i};
            for j=1:length(csNonResponseForMouse)           
                dayCSNonResponsiveAllMice = [dayCSNonResponsiveAllMice csNonResponseForMouse{j}];
            end
        end
    end
end