% created to make cross-correlograms on data presented as structs. unit1
% and unit2 are particular units in a list of many units. struct contains 2
% fields= .unitID, which is a string identifying which unit, and
% .timestamps, which is a vector of timestamps where that unit fires.
% Adapted from iter_crosscorr
% MEH 3/3/21
%Change limits to change window the funtion operates on MEH 3/16/21

function [N, edges, Values1] = psthINDEX_TG(struct, xMin, xmax, bwidth, trigger, unit2, TimeGridA, TimeGridB, limMin, limMax, color, plotBoo, SD, SDboo) %times in seconds, n unit of interest for struct (.unitID= string, .timestamps= vector 
%THIS FUNCTION TAKES INDEX INSTEAD OF UNIT ID TO FIND CELL IN STRUCT

range = [xMin, xmax];                       % designate x-axis range in sec, xMin should be negative
TimeLim = [limMin limMax];
%trange = abs(xMin);
%if trange < xmax
%    trange = xmax;
%end

% if you are passing a particular unit, n, instead of using n/for loop to cycle
%through many:
%Iunit1 = unit1;        % find index for units of interest
Iunit2 = unit2;
%Unit1 = [struct(Iunit1).timestamps];         %% Unit 1 is timestamps where unit one fires
Unit1 = trigger;
Unit2 = [struct(Iunit2).timestamps]; 
% title1 = [struct(Iunit1).unitID];           % collect unitIDs as strings for titling the graph
title1 = 'trigger';
title2 = [struct(Iunit2).unitID];
%%%%%%%%
%limit exaMined area to particular epoch
Unit1 = Unit1((limMin+xMin < Unit1) & (Unit1 < limMax-xmax));
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

Unit1 = TimeGridUnit(TimeGridA+xMin, TimeGridB-xmax, Unit1);
%Unit2 = TimeGridUnit(TimeGridA+xMin, TimeGridB-xmax, Unit2);
end


reporter = Unit1;


%L1 = (length(Unit1))           % L = number of spikes
%L2 = (length(Unit2))

ValuesEdges = [xMin:bwidth:xmax];
Values = zeros(length(ValuesEdges),1);
if ~isempty(Unit1)
    start = min(Unit1(1), Unit2(1));
    start = start - bwidth;
    if Unit1(end)>= Unit2(end)
        edges = [start:bwidth:Unit1(end)];
    else
        edges = [start:bwidth:Unit2(end)];
    end
edges(end+1)= edges(end)+bwidth;
[Nt, edgest, bint] = histcounts(Unit1, edges);
[Nf, edgesf, binf]=histcounts(Unit2, edges);

for n = 1:length(bint)
    if bint(n)+xMin/bwidth <1
        Min = 1;
    else
        Min = bint(n)+xMin/bwidth;
    end
    if bint(n)+xmax/bwidth > length(Nf)
        max = length(Nf);
    else
        max = bint(n)+xmax/bwidth;
    end
    AddThis = Nf(Min:max).';
    if ~(length(AddThis) == length(Values))

        if bint(n)+xMin/bwidth <1
            padding = zeros(abs(bint(n)+xMin/bwidth)+1,1);
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
Values = Values/(length(Unit1)*bwidth);

N = Values;
edges = ValuesEdges.';
% if unit1 == unit2
% index0 = find(edges == 0);
% N(index0)=0;
% end

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
    edges = [xMin:bwidth:xmax].';
    Values1 = [];

end
