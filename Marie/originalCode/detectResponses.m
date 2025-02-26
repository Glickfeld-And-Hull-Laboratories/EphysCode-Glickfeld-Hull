function [state, MFunits] = detectResponses(ZERO, N, SDline, BinCounts, msbins, firstCutoff, secondCutoff, reqBinH)

state = '0';
MFunits = struct('Lat1',[], 'Lat2',[]);
checker1 = find(N(ZERO:(ZERO+firstCutoff/msbins)) > SDline); %does resp exceed stdev cutoff within first time window
if checker1
for k = 1:length(checker1)
    scatter(checker1(k)/10000,SDline)
checker11 = find(N(checker1(k)+ZERO:end) < SDline, 1);  %does it exceed for at least 2 consecutive bins
if checker11 >1
    checkBinCounts = find(BinCounts((ZERO+checker1(k)):(ZERO+checker1(k)+checker11)) >(reqBinH-1), 1 ); %if there are at least two spikes in at least one bin
    if checkBinCounts
        checker2 = find(N((ZERO+checker1(k)+checker11):(ZERO+secondCutoff/msbins)) > SDline)+checker1(k)+checker11; %does resp exceed stdev cutoff within second time window
        if checker2
        for s = 1:length(checker2)
            scatter((checker2(s))/10000,SDline, '*')
        checker22 = find(N((ZERO+checker2(s)):end) < SDline, 1);  %does it exceed for at least 2 consecutive bins
        if checker22 >1
            checkBinCounts2 = find(BinCounts((ZERO+checker2(s)):(ZERO+checker2(s)+checker22))>(reqBinH-1),1);
            if checkBinCounts2
            MFunits.Lat1 = checker1(k)*msbins*1000;
            MFunits.Lat2 = (checker1(k)+checker2(s))*msbins*1000;
            state = 'response';
            
            break
        end
        end
        end
    end
end
end
if state == 'response'
    break
end
end
end
end
