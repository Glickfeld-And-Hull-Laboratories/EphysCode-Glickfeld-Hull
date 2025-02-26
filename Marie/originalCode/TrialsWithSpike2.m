function [Trials_with_spike, TrialStructMask] = TrialsWithSpike2(SpikeIndex,structure, Trials, window)
timestamps = structure(SpikeIndex).timestamps;
counter = 1;
Trials_with_spike = [];
for n = 1:length(Trials)
    tester = timestamps(timestamps>(Trials(n)+window(1)));
    tester = tester(tester<(Trials(n)+window(2)));
    if ~isempty(tester)
        Trials_with_spike(counter) = Trials(n);
        TrialStructMask(n) = 1;
        counter = counter +1;
    else
        TrialStructMask(n) = 0;
    end
end

Trials_with_spike = Trials_with_spike.';
Trials_with_spike = Trials(logical(TrialStructMask));
end
    
    