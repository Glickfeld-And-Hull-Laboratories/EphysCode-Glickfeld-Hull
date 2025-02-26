% created to make cross-correlograms on data presented as structs. unit1
% and unit2 are particular units in a list of many units. struct contains 2
% fields= .unitID, which is a string identifying which unit, and
% .timestamps, which is a vector of timestamps where that unit fires.
% Adapted from iter_crosscorr
% MEH 3/3/21
%Change limits to change window the funtion operates on MEH 3/16/21

function [N, edges] = XcorrFast(struct, xmin, xmax, bwidth, unit1, unit2, limMin, limMax, color, plotBoo, SD, SDboo) %times in seconds, n unit of interest for struct (.unitID= string, .timestamps= vector 
%THIS FUNCTION TAKES INDEX INSTEAD OF UNIT ID TO FIND CELL IN STRUCT

range = [xmin, xmax];                       % designate x-axis range in sec, xmin should be negative
%trange = abs(xmin);
%if trange < xmax
%    trange = xmax;
%end

% if you are passing a particular unit, n, instead of using n/for loop to cycle
%through many:
Iunit1 = find([struct.unitID] == unit1);        % find index for units of interest
Iunit2 = find([struct.unitID] == unit2);
Unit1 = [struct(Iunit1).timestamps];         %% Unit 1 is timestamps where unit one fires
Unit2 = [struct(Iunit2).timestamps]; 
title1 = [struct(Iunit1).unitID];           % collect unitIDs as strings for titling the graph
title2 = [struct(Iunit2).unitID];
%%%%%%%%
%limit examined area to particular epoch
if isinf(limMax)
    limMax = max(Unit1(end), Unit2(end));
end
Unit1 = Unit1((limMin < Unit1) & (Unit1 < limMax));
Unit2 = Unit2((limMin < Unit2) & (Unit2 < limMax));
%


reporter = Unit1;


L1 = (length(Unit1));           % L = number of spikes
L2 = (length(Unit2));

ValuesEdges = [xmin:bwidth:xmax];
Values = zeros(length(ValuesEdges),1);
if Unit1(end)>=Unit2(end)
edges = [0:bwidth:Unit1(end)];
else
edges = [0:bwidth:Unit2(end)];
end
edges(end+1)= edges(end)+bwidth;
[Nt, edgest, bint] = histcounts(Unit1, edges);
[Nf, edgesf, binf]=histcounts(Unit2, edges);
for n = 1:length(bint)
    if bint(n)+xmin/bwidth <1
        min = 1;
    else
        min = bint(n)+xmin/bwidth;
    end
    if bint(n)+xmax/bwidth > length(Nf)
        max = length(Nf);
    else
        max = bint(n)+xmax/bwidth;
    end
    AddThis = Nf(min:max).';
    if ~(length(AddThis) == length(Values))
        if bint(n)+xmin/bwidth <1
            padding = zeros(abs(bint(n)+xmin/bwidth)+1,1);
            AddThis = [padding; AddThis];
        end
        if  bint(n)+xmax/bwidth > length(Nf)
            padding = zeros(bint(n)+xmax/bwidth - length(Nf),1);
            AddThis = [AddThis; padding];
        end
    end
    Values = Values + AddThis;
end
Values = Values/(length(Unit1)*bwidth);


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
xline(0,'b');
%ax.TickDir = 'out'
ax = gca; 
ax.TickDir = 'out';
ax.FontName = 'Calibri';%, 'FixedWidth';
ax.FontSize = 18;
%yticklabels(yticks/L1/bwidth);
%tiledlayout(flow);
end

if ~SDboo == 0
[meanLine, stdevLine] = StDevLine(N, edges, 0);
yline(meanLine + SD*stdevLine, 'g', 'LineWidth', 2);
if (meanLine - SD*stdevLine) >0
yline((meanLine - SD*stdevLine), 'y', 'LineWidth', 2);
end
end




end
