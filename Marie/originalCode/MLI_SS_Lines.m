for n = 403:404%length(SumSt)
    if strcmp(SumSt(n).handID, 'MLI')
        figure
        hold on
        for k = 385:387%:length(SumSt)
            if strcmp(SumSt(n).recordingID, SumSt(k).recordingID)
                if n ~= k
                    if strcmp(SumSt(k).handID, 'SSpause')
                        xCorrStructNewLimitsLineINDEX(SumSt, -.02, .02, .001, n, k, 0, inf, 'k', 1, 4, 1);
                        %x = SumSt(n).recordingID;
                        %I = find(x == '\', 1, 'last');
                        %x = x(I:end);
                        title(['index MLI ' num2str(n) ' and SS_pause ' num2str(k) ])
                        FormatFigure
                        saveas(gca, ['index MLI ' num2str(n) ' and SS_pause ' num2str(k)])
                         print( ['index MLI ' num2str(n) ' and SS_pause ' num2str(k)], '-dpsc', '-painters');
                    end
                end
            end
        end
         FormatFigure
                        saveas(gca, ['index MLI ' num2str(n) ' and SS_pause ' num2str(k)])
                         print( ['index MLI ' num2str(n) ' and SS_pause ' num2str(k)], '-dpsc', '-painters');
    end
end