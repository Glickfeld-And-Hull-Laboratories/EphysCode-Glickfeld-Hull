% created to make cross-correlograms on data presented as structs. unit1
% and unit2 are particular units in a list of many units. struct contains 2
% fields= .unitID, which is a string identifying which unit, and
% .timestamps, which is a vector of timestamps where that unit fires.
% Adapted from iter_crosscorr
% MEH 3/3/21
%Change limits to change window the funtion operates on MEH 3/16/21

function [N, edges, Nf, Nf_orig] = XcorrFastINDEX_CorCorrect(struct, xmin, xmax, bwidth, unit1, unit2, TimeGridA, TimeGridB, limMin, limMax, color, plotBoo, SD, SDboo) %times in seconds, n unit of interest for struct (.unitID= string, .timestamps= vector 
%THIS FUNCTION TAKES INDEX INSTEAD OF UNIT ID TO FIND CELL IN STRUCT
range = [xmin, xmax];                       % designate x-axis range in sec, xmin should be negative
TimeLim = [limMin limMax];
%trange = abs(xmin);
%if trange < xmax
%    trange = xmax;
%end
Iunit1 = unit1;        % find index for units of interest
Iunit2 = unit2;
% if you are passing a particular unit, n, instead of using n/for loop to cycle
%through many:
Unit1 = [struct(Iunit1).timestamps];         %% Unit 1 is timestamps where unit one fires
Unit2 = [struct(Iunit2).timestamps]; 
title1 = [struct(Iunit1).unitID];           % collect unitIDs as strings for titling the graph
title2 = [struct(Iunit2).unitID];
%%%%%%%%
%limit examined area to particular epoch
Unit1 = Unit1((limMin+xmin < Unit1) & (Unit1 < limMax-xmax)); %limit trigger unit to avoid edge effects (minimal here, but still)
Unit2 = Unit2((limMin < Unit2) & (Unit2 < limMax));
%
%Remake TimeGrid In Limits
if ~isnan(TimeGridA)
%TimeGridWindow = TimeGridB(1)-TimeGridA(1);         % Will Remake time grid within time limits

TimeGridB = TimeGridB(TimeGridB <= TimeLim(2));
TimeGridA = TimeGridA(1:length(TimeGridB));
[~, start] = find(TimeGridA >=  TimeLim(1), 1);
TimeGridA = TimeGridA(start:end);
TimeGridB = TimeGridB(start:end);



Unit1 = TimeGridUnit(TimeGridA+xmin, TimeGridB-xmax, Unit1); % only timegrid trigger unit, follower unit will be 'jittered' to get corrected ccg
%Unit2 = TimeGridUnit(TimeGridA+xmin, TimeGridB-xmax, Unit2);
end

L1 = (length(Unit1));           % L = number of spikes
L2 = (length(Unit2));

ValuesEdges = [xmin:bwidth:xmax];
Values = zeros(length(ValuesEdges),1);
if ~isempty(Unit1)
if Unit1(end)>=Unit2(end)           %make empty bins, 1 per binwidth, covering total experimental time considered
edges = [0:bwidth:Unit1(end)];
else
edges = [0:bwidth:Unit2(end)];
end
edges(end+1)= edges(end)+bwidth;
[Nt, edgest, bint] = histcounts(Unit1, edges); %binarize spiketimes
[Nf, edgesf, binf] = histcounts(Unit2, edges);
%CorrCorrection - 'jitter' follower unit per David Herzfeld's biorxiv paper 'Rate
%versus synchrony codes for cerebellar control of motor behavior' MEH 2023
Nf_orig = Nf;
NNZindex = find(Nf);

for n = 1:length(NNZindex)   % spread probability of spike over interspike interval (window around each spike)
        if n ==1
            min_ccInd = 1;
        else
            min_ccInd = floor((NNZindex(n) - NNZindex(n-1))/2) + NNZindex(n-1)+1; % time halfway between ISI previous
        end
        if n == length(NNZindex)
            max_ccInd = length(Nf);
        else
            max_ccInd =floor((NNZindex(n+1) - NNZindex(n))/2)+NNZindex(n); % time halfway between ISI next
        end
        Nf(min_ccInd:max_ccInd) = Nf_orig(NNZindex(n))/(length(Nf_orig(min_ccInd:max_ccInd))); % fill all these bins with the probability of a spike
end

%bint = which bin each spike is in;
for n = 1:length(bint)                          %sliding window to for trigger to build N
    if bint(n)+xmin/bwidth <1 
        min = 1;
    else
        min = bint(n)+xmin/bwidth;                           % for every spike, back up the number of bins you want to include and this is your min bin.
    end
    if bint(n)+xmax/bwidth > length(Nf)
        max = length(Nf);
    else
        max = bint(n)+xmax/bwidth;
    end
    AddThis = Nf(min:max).';
    
    if ~(length(AddThis) == length(Values))
        %'error'
        if bint(n)+xmin/bwidth <1
            padding = zeros(abs(bint(n)+xmin/bwidth)+1,1);  % fill in the rest of the vector with zeros.
            AddThis = [padding; AddThis];
        end
        if  bint(n)+xmax/bwidth > length(Nf)
            padding = zeros(bint(n)+xmax/bwidth - length(Nf),1);
            AddThis = [AddThis; padding];
        end
    end
    Values = Values + AddThis;
end
Values1 = Values;
Values = Values/(length(Unit1)*bwidth); % normalize to sp/sec

N = Values;
edges = ValuesEdges.';
if unit1 == unit2
index0 = find(edges == 0);
N(index0)=0;
end

if ~plotBoo==0
    %figure
    plot(edges,N, 'Color', color);
strTitle = [num2str(title1) ' vs ' num2str(title2)];
title([num2str(title1) ' & ' num2str(title2) ' from ' num2str(limMin) ' to ' num2str(limMax)]);
box off;
%xline(0,'b');
%ax.TickDir = 'out'
ax = gca; 
ax.TickDir = 'out';
ax.FontName = 'Calibri';%, 'FixedWidth';
ax.FontSize = 18;
%yticklabels(yticks/L1/bwidth);
%tiledlayout(flow);
end

if ~SDboo == 0
[meanLine, stdevLine] = StDevLine(N, edges, -.005);
yline(meanLine + SD*stdevLine, 'g', 'LineWidth', 2);
if (meanLine - SD*stdevLine) >0
yline((meanLine - 2*stdevLine), 'y', 'LineWidth', 2);
end
end
else
    N = [];
    edges = [xmin:bwidth:xmax].';
    Nf = [];
    Nf_orig = [];
end
