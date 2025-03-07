for n = 73:78%length(SumSt)
    if strcmp(SumSt(n).handID, 'MLI')
        for k = n+1:length(SumSt)
            if strcmp(SumSt(n).recordingID, SumSt(k).recordingID)
                    if strcmp(SumSt(k).handID, 'MLI')
                        figure
                        hold on
                        xCorrStructNewLimitsLineINDEX(SumSt, -.02, .02, .001, n, k, 0, inf, ParulaColors(k-72,:), 1, 4, 1);
                        %x = SumSt(n).recordingID;
                        %I = find(x == '\', 1, 'last');
                        %x = x(I:end);
                
                        title(['MLI indices ' num2str(n) ' and ' num2str(k) ' from ' x])
                        FormatFigure
                        saveas(gca, ['MLI indices ' num2str(n) ' and ' num2str(k) ' from ' x])
                        print(['MLI indices ' num2str(n) ' and ' num2str(k) ' from ' x], '-dpsc', '-painters');
                    end
            end
        end
    end
end
                  