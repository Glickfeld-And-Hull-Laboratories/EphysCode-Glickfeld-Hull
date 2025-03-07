%Based on Maxime Beau's Neuropyxels code, which is
%Based on metric described in Hill et al. (2011) J Neurosci 31: 8699-8705
%modified by Dan Denman from cortex-lab/sortingQuality GitHub by Nick Steinmetz

function [fpRate, num_violations] = isi_violations(n, struct, TimeGridA, TimeGridB, TimeLim, isi_threshold)
min_isi=0;

    %does not remove duplicate spikes, but could
    Unit1 = [struct(n).timestamps];
    title1 = [struct(n).unitID];   
    Unit1 = Unit1((TimeLim(1) < Unit1) & (Unit1 < TimeLim(2)));
    
    if ~isnan(TimeGridA)
TimeGridB = TimeGridB(TimeGridB <= TimeLim(2));
TimeGridA = TimeGridA(1:length(TimeGridB));
[~, start] = find(TimeGridA >=  TimeLim(1), 1);
TimeGridA = TimeGridA(start:end);
TimeGridB = TimeGridB(start:end);

Unit1 = TimeGridUnit(TimeGridA+xmin, TimeGridB-xmax, Unit1);

end
    
    isis = diff(Unit1);
    num_spikes = length(Unit1);
    num_violations = sum(isis < isi_threshold);
    violation_time = 2*num_spikes*(isi_threshold - min_isi);
    [total_rate, ~] = FRstructTimeGridTimeLimitINDEX2(TimeGridA, TimeGridB, TimeLim, struct, n, 'k', 0, .01);
    violation_rate = num_violations/violation_time;
    fpRate = violation_rate/total_rate;
end

