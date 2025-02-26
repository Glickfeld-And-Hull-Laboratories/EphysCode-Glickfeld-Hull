close all
unit =609;
index = find([GoodUnitStructSorted.unitID] == unit)
m = index
     figure
for n = 1:length(GoodUnitStructSorted)
    if abs(GoodUnitStructSorted(n).depth - GoodUnitStructSorted(index).depth) < 1000
        if strcmp(GoodUnitStructSorted(n).layer, 'GrC_layer')
        else
        if GoodUnitStructSorted(n).FR>3
        figure
        %XcorrFastINDEX_TG(GoodUnitStructSorted, -.05, .05, .001, n, m, NaN, NaN, 0, 300, 'k', 1, 4, 1);        
        %xCorrStructNewLimitsLine(AllUnitStruct, -.02, .02, .001, GoodUnitStructSorted(n).unitID, unit, 0, inf, 'k', 3, 1);
        [N, edges] = XcorrRateCorrect(GoodUnitStructSorted, -.05, .05, .001, n, m, NaN, NaN, 0, 300, 'k', 1, 4, 1);
        [N, edges] = XcorrRateCorrect(GoodUnitStructSorted, -.05, .05, .001, n, m, NaN, NaN, 5000, inf, 'r', 1, 4, 1);
        title([num2str(GoodUnitStructSorted(n).unitID) ' & ' num2str(GoodUnitStructSorted(m).unitID)])
        end
        %end
    end
    end
end

close all
%SS_pairs_from_phyllum = phyllum guess of SS_CS
for n = 1:length(SS_pairs_from_phyllum)
index = find([GoodUnitStructSorted.unitID] == SS_pairs_from_phyllum(n,1))
if ~isempty(index)
if ~isempty(find([GoodUnitStructSorted.unitID] == SS_pairs_from_phyllum(n,2)))
xCorrStructNewLimits(AllUnitStruct, -.02, .02, .001, SS_pairs_from_phyllum(n,2), SS_pairs_from_phyllum(n,1), 0, 1000, 'k');
end
end
end


close all
unit =10;
m = find([GoodUnitStructSorted.unitID] == unit)
% m = 479
     figure
for n = 1:length(GoodUnitStructSorted)
    if abs(GoodUnitStructSorted(n).depth - GoodUnitStructSorted(index).depth) < 1000
        if strcmp(GoodUnitStructSorted(n).layer, 'GrC_layer')
        else
        if GoodUnitStructSorted(n).FR<3
        figure
        XcorrFastINDEX_TG(GoodUnitStructSorted, -.05, .05, .001, n, m, NaN, NaN, 0, 600, 'k', 1, 4, 1);        
        %xCorrStructNewLimitsLine(AllUnitStruct, -.02, .02, .001, GoodUnitStructSorted(n).unitID, unit, 0, inf, 'k', 3, 1);
%         [N, edges] = XcorrRateCorrect(GoodUnitStructSorted, -.05, .05, .001, n, m, NaN, NaN, 0, 300, 'k', 1, 4, 1);
% %         [N, edges] = XcorrRateCorrect(GoodUnitStructSorted, -.05, .05, .001, n, m, NaN, NaN, 5000, inf, 'r', 1, 4, 1);
        title([num2str(GoodUnitStructSorted(n).unitID) ' & ' num2str(GoodUnitStructSorted(m).unitID)])
        end
        %end
    end
    end
end
