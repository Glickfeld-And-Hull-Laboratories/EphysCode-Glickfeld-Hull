        figure
        hold on
for n = 1:length(MLIsB)
        for k = 1:length(SumSt)
            if SumSt(k).unitID == MLIsB(n).unitID
                if SumSt(k).RecorNum == MLIsB(n).RecorNum
                    index = k;
                end
            end
        end
    for m = 1:length(SumSt)
        if SumSt(m).RecorNum == MLIsB(n).RecorNum
        if Cell2CellDistINDEX(SumSt, m, index, MEH_chanMap) <= 60
        if strcmp(SumSt(m).CellType, 'CS')
            [N, edges] = XcorrRateCorrect(SumSt, -.025, .025, .001, m, index, NaN, NaN, 0, inf, 'g', 1, SD, 0);
            title([num2str(index)])
        end
        end
        end
    end
end
FigureWrap('MLIsB resp to CS < 60 um', 'MLIsB_CS_60um', 'ms from CS', 'delta MLI2 sp/s', [-.02 .02], [-35 350]);
        
        figure
        hold on
for n = 1:length(MLIsA)
        for k = 1:length(SumSt)
            if SumSt(k).unitID == MLIsA(n).unitID
                if SumSt(k).RecorNum == MLIsA(n).RecorNum
                    index = k;
                end
            end
        end
    for m = 1:length(SumSt)
        if SumSt(m).RecorNum == MLIsA(n).RecorNum
        if Cell2CellDistINDEX(SumSt, m, index, MEH_chanMap) <= 60
        if strcmp(SumSt(m).CellType, 'CS')
            [N, edges] = XcorrRateCorrect(SumSt, -.025, .025, .001, m, index, NaN, NaN, 0, inf, 'm', 1, SD, 0);
            title([num2str(index)])
        end
        end
        end
    end
end
FigureWrap('MLIsA resp to CS < 60 um', 'MLIsA_CS_60um', 'ms from CS', 'delta MLI1 sp/s', [-.02 .02], [-35 350]);


            