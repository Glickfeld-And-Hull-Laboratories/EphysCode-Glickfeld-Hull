
    function [TrialsSpike, TrialsNoSpike] = TrialsWith_outTimestamps(Trials, timestamps, WindowTrialTime)

for n = 1:length(Trials)
    tester = timestamps(timestamps>(Trials(n)+WindowTrialTime(1)));
    tester = tester(tester<(Trials(n)+WindowTrialTime(2)));
    if ~isempty(tester)
        MaskFire(n) = 1;
    else
        MaskFire(n) = 0;
    end
end

TrialsSpike = Trials(logical(MaskFire));
TrialsNoSpike = Trials(logical(abs(MaskFire)-1));
    end
