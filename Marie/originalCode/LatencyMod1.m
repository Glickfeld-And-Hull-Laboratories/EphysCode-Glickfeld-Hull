
function [LatLow, LatHigh, modBoo, Dir, doubleBoo] = LatencyMod1(StDevLim, N, edges, SD, AccRespWindow, plotBoo)
%function [LatLow, LatHigh] = LatencyMod(StDevLim, N, edges, SD, minRespLat)
minRespLat = AccRespWindow(1);
maxRespLat = AccRespWindow(2);
%binwidth = edges(2)-edges(1);
%if you want to do mean/st all the way to the trigger, cutoff = 0,
%otherwise set cutoff= some bin value before zero
[meanLine, stdevLine] = StDevLine(N, edges, StDevLim);
crossingsLow = edges(N<(meanLine - SD*stdevLine));
if ~isempty(crossingsLow)
LatLow = crossingsLow(1);
else
    LatLow = NaN;
end
crossingsHigh = edges(N>(meanLine + SD*stdevLine));
if ~isempty(crossingsHigh)
LatHigh = crossingsHigh(1);
else
    LatHigh = NaN;
end

if LatLow < minRespLat
    LatLow = NaN;
end
if LatHigh < minRespLat
    LatHigh = NaN;
end
if LatLow > maxRespLat
    LatLow = NaN;
end
if LatHigh > maxRespLat
    LatHigh = NaN;
end

if isnan(LatHigh) & ~isnan(LatLow) %if decrease is only or only accepted crossing
    Dir = -1;
    doubleBoo = 0;
end
if isnan(LatLow) & ~isnan(LatHigh) %if increase is only or only accepted crossing
    Dir = 1;
    doubleBoo = 0;
end
if ~isnan(LatHigh) & ~isnan(LatLow) % if there are two accepted crossings
    if LatLow < LatHigh
        Dir = -1;
    elseif LatHigh < LatLow
        Dir = 1;
    end
    doubleBoo = 1;
else
    doubleBoo = 0;
end

if isnan(LatLow) & isnan(LatHigh)
    modBoo = 0;
    Dir = NaN;
else
    modBoo = 1;
end

if plotBoo == 1
    if length(edges) == length(N)+1
        edges = edges(1:end-1);
    end
plot(edges, N)
hold on
yline(meanLine - SD*stdevLine, 'y');
yline(meanLine + SD*stdevLine, 'g');
if ~isnan(LatLow)
    xline(LatLow, 'y');
end
if ~isnan(LatHigh)
    xline(LatHigh, 'g');
end
end
      






