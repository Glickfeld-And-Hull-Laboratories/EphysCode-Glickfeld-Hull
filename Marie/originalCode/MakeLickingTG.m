function [tester] = MakeLickingTG(AllLicksAdj, EpochOnsetsAdj, maxInterval)


Licking_TGA = EpochOnsetsAdj;

for n = 1:length(Licking_TGA)-1
    NextLicks = AllLicksAdj(AllLicksAdj > Licking_TGA(n));
    for k = 1:length(NextLicks)
        if NextLicks(k+1)-NextLicks(k) > maxInterval
        Licking_TGB(n) = NextLicks(k);
        tester(n).A = Licking_TGA(n);
        tester(n).B = Licking_TGB(n);
        NextLicks = [];
        break
        end
    end
end
end
