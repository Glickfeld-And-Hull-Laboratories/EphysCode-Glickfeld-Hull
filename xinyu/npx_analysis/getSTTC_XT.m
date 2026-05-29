function sttc_vector = getSTTC(TS_a,TS_b,exptWindow,dT,winSize,overlap)
% STTC_vector = getSTTC(timeSeries1,timeSeries2,deltaT,windowSize)
%   timeSeriesA and timeSeriesB: raw data vectors containing timestamps
%   of spiking events for 2 neurons to be compared.
%   dT: coincidence window in seconds. full window is ± dT (so 2 dT).
%   windowSize: sliding window for STTC calculation, in seconds.
%   P_a: proportion of spikes from A that lie within ± dT of any spike from
%   TS_b.
%   T_a: porportion of total reocrding time that lie within ± dT of any
%   spike from A.
%   STTC = 1/2 * ((P_a - T_b) / (1 - P_a * T_b) + (P_b - T_a) / (1 - P_b *
%   T_a))
%
%   Intuitioin: we want to know if A's spikes tend to lend in B's tiles
%   more than you would expect from the density of B tiles by chance, or
%   vice versa.

if nargin < 4
    disp('No dT/windowSize/overlap specified. STTC using default dT = 5ms windowSize = 20s overlap = 20%')
end

if isempty(dT) == 1
    dT = 0.005;
end

if isempty(winSize) == 1
    winSize = 20; % 20s window
end
if isempty(overlap) == 1
    overlap = 0.2; % 4s overlap between kernels
end

exptStart = exptWindow(1);
exptEnd = exptWindow(2);
exptLength = exptEnd - exptStart;
nKer = getNKernels(exptLength,winSize,winSize*overlap);
stride = winSize - winSize*overlap;

sttc_vector = nan(nKer,1);
for i = 1:nKer
    thisKerStart = exptStart + (i-1)*stride;
    thisKerEnd = thisKerStart + winSize;

    eventsA = TS_a(TS_a > thisKerStart & TS_a <thisKerEnd);
    starts_a = eventsA - dT;
    ends_a = eventsA + dT;
    starts_a(starts_a < thisKerStart) = thisKerStart;
    ends_a(ends_a > thisKerEnd) = thisKerEnd;
    tilesRaw_a = [starts_a ends_a];
    merged_a = mergeIntervals(tilesRaw_a);
    
    eventsB = TS_b(TS_b > thisKerStart & TS_b <thisKerEnd);
    starts_b = eventsB - 1/2 * dT;
    ends_b = eventsB + 1/2 * dT;
    starts_b(starts_b < thisKerStart) = thisKerStart;
    ends_b(ends_b > thisKerEnd) = thisKerEnd;
    tilesRaw_b = [starts_b ends_b];
    merged_b = mergeIntervals(tilesRaw_b);
    
    dur_a = sum(merged_a(:,2)-merged_a(:,1));
    dur_b = sum(merged_b(:,2)-merged_b(:,1));
    T_a = dur_a / winSize;
    T_b = dur_b / winSize;
    
    counts_ab = sum(eventsA(:)' >= merged_b(:,1) & eventsA(:)' < merged_b(:,2), 2); % # of spikes of A in each tile of B
    P_a = sum(counts_ab)/length(eventsA);

    counts_ba = sum(eventsB(:)' >= merged_a(:,1) & eventsB(:)' < merged_a(:,2), 2); % # of spikes of B in each tile of A
    P_b = sum(counts_ba)/length(eventsB);

    sttc_vector(i) = 1/2 * ((P_a - T_b)/(1-P_a*T_b) + (P_b - T_a)/(1-P_b*T_a));
end


end