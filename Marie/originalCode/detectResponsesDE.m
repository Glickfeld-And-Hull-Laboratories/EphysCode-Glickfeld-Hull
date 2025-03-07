function [state, units] = detectResponsesDE(ZERO, N, SDline, msbins, firstCutoff, reqBinH)

state = '0';
units = struct('Lat1',[], 'Lat2',[]);
checker1 = find(N(ZERO:(ZERO+firstCutoff/msbins)) > SDline); %does resp exceed stdev cutoff within first time window
if checker1
for k = 1:length(checker1)
    %scatter(checker1(k)/10000,SDline)
checker11 = find(N(checker1(k)+ZERO:end) < SDline, 1);  %check when it falls back below the SD line
        if checker11 > (reqBinH-1)
            units.Lat1 = checker1(k)*msbins*1000;
            state = 'response';
            break
        end
end
end

end

