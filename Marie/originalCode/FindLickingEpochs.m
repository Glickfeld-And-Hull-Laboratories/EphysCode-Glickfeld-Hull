function FirstLicksEpochs = FindLickingEpochs(licks, n, m)
%I had been using 1 as n and .21 as m
%at least three licks with < .21 inter-lick interval
FirstLicksEpochs = [];
k = 1;
for i = 2:(length(licks)-2)
    if (((licks(i) - licks(i-1)) > n) || isnan(licks(i) - licks(i-1)))     % sets 1 as "reset" after which I would consider a potential new onset of licking
        if (((licks(i+1)-licks(i)) < m) && ((licks(i+2)-licks(i+1)) < m)) % sets boundary between licks to consider as onset of epoch
            FirstLicksEpochs(k) = licks(i);
            k = k+1;
        end
    end
end
FirstLicksEpochs = FirstLicksEpochs.';
end

