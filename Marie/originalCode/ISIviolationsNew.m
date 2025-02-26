% created to make cross-correlograms on data presented as structs. unit1
% and unit2 are particular units in a list of many units. struct contains 2
% fields= .unitID, which is a string identifying which unit, and
% .timestamps, which is a vector of timestamps where that unit fires.
% Adapted from iter_crosscorr
% MEH 3/3/21
%Change limits to change window the funtion operates on MEH 3/16/21

function reportViolations = ISIviolationsNew(TimeGridA, TimeGridB, struct, unit, TimeLim) %times in seconds, n unit of interest for struct (.unitID= string, .timestamps= vector 

xmin = -.001;
xmax = .001;
bwidth = .001;


unit1 = unit;
unit2 = unit;
if isnan(TimeLim)
    TimeLim = [0 inf]
end
range = [xmin, xmax];                       % designate x-axis range in sec, xmin should be negative
trange = abs(xmin);
if trange < xmax
    trange = xmax;
end

% if you are passing a particular unit, n, instead of using n/for loop to cycle
%through many:
Iunit1 = find([struct.unitID] == unit1);        % find index for units of interest
Iunit2 = find([struct.unitID] == unit2);
Unit1 = [struct(Iunit1).timestamps];         %% Unit 1 is timestamps where unit one fires
Unit2 = [struct(Iunit2).timestamps]; 
title1 = [struct(Iunit1).unitID];           % collect unitIDs as strings for titling the graph
title2 = [struct(Iunit2).unitID];
title3 = [num2str(TimeLim(1))];
title4 = [num2str(TimeLim(2))];

%%%%%%%%
%limit examined area to particular epoch
Unit1 = Unit1((TimeLim(1) < Unit1) & (Unit1 < TimeLim(2)));
Unit2 = Unit2((TimeLim(1) < Unit2) & (Unit2 < TimeLim(2)));


% remake time grid within time limits
if ~isnan(TimeGridA)
TimeGridWindow = TimeGridB(1)-TimeGridA(1);         
TimeGridB = TimeGridB((TimeGridB < TimeLim(2)) & (TimeGridB > TimeLim(1)));
TimeGridA = TimeGridB - TimeGridWindow;
if (TimeGridB(1)-TimeGridWindow)< TimeLim(1)
    TimeGridA(1) = TimeLim(1);
end

%select timestamps within timegrid
Unit1 = TimeGridUnit(TimeGridA, TimeGridB, Unit1);
Unit2 = TimeGridUnit(TimeGridA, TimeGridB, Unit2);
%
end

L1 = (length(Unit1));           % L = number of spikes
L2 = (length(Unit2));
useDeltas = NaN;

k = 1;                                              %create counter for output vector index
for j = 1:L1                                           % for every element in the first spiketime vector
    for i=1:L2                                    % for every element in the second (or mirror) spiketime vector
       test = Unit2(i,:)- Unit1(j,:);             % get difference between spiketimes
       if test == 0
           test = nan;                               % eliminate zeros
       end
       if ((test <= trange) & (test >= -trange))   % Check if difference is in histogram range
           useDeltas (k,1) = test;                  % If yes, add difference to vector that will create histogram
           k = k+1;                                 % update index
       end
           
    end  
end
%tester = useDeltas;

if isnan(useDeltas)
    reportViolations = 0;
end
    
%figure

%histogram (useDeltas, 'BinLimits', range, 'Binwidth', bwidth, 'Facecolor', 'k', 'Linestyle', 'none', 'Facealpha', 1);
%figure
[N, edges] = histcounts(useDeltas, 'BinLimits', range, 'Binwidth', bwidth);
%FreqHist(N, edges, length(Unit1), color);
%strTitle = [num2str(title1) ' vs ' num2str(title2)];
%title([num2str(title1) ' & ' num2str(title2) ' between ' title3 ' and ' title4]);
%if ~isnan(TimeGridA)
%title([num2str(title1) ' & ' num2str(title2) ' between ' title3 ' and ' title4 ' TG']);
%end
%box off;
%xline(0,'b');
%ax.TickDir = 'out'
%ax = gca; 
%ax.TickDir = 'out';
%ax.FontName = 'Calibri';
%ax.FontSize = 18;
%yticklabels(yticks/L1/bwidth);
%tiledlayout(flow);
%else
%    fprintf('%d has no spikes in window\n',title2)
    
%end
if ~isnan(useDeltas)
examine = [edges(1:end-1).' N.']
ISIindex = (examine(:,1) == 0);% find the bin to the right of zero
violations = examine(ISIindex, 2);
reportViolations = (violations/L1)*100; %report violations as percentage for easier reading
%if violations == 0
%    reportViolations = 'none';
%end
%if ((violations ~=0) & (violations/L1 < .01))
%    violations/L1
%    reportViolations = '<1%';
%end
%if violations/L1 >= .01
    
%    reportViolations = 'more than 1%';
%end
end
end
