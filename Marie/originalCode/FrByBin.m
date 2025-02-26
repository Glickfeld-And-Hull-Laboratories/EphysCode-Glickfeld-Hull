function [N, edges] = FrByBin(struct, bwidth, unit1, TimeGridA, TimeGridB, limMin, limMax) 

TimeLim = [limMin limMax];
%trange = abs(xmin);
%if trange < xmax
%    trange = xmax;
%end
Iunit1 = unit1;        % find index for units of interest (index)

Unit1 = [struct(Iunit1).timestamps];         %% Unit 1 is timestamps where unit one fires

         % collect unitIDs as strings for titling the graph

%%%%%%%%
%limit examined area to particular epoch
Unit1 = Unit1((limMin < Unit1) & (Unit1 < limMax)); %limit trigger unit to avoid edge effects (minimal here, but still)

%
%Remake TimeGrid In Limits
if ~isnan(TimeGridA) %recommended here, unpredictable results if use TG
%TimeGridWindow = TimeGridB(1)-TimeGridA(1);         % Will Remake time grid within time limits

Unit1 = TimeGridUnit(TimeGridA+xmin, TimeGridB-xmax, Unit1);
end

if TimeLim(2) == inf
    TimeLim(2) = Unit1(end);
end
edges = [TimeLim(1):bwidth:TimeLim(2)];

[N,edges] = histcounts(Unit1, edges);
N = N/bwidth;
end


