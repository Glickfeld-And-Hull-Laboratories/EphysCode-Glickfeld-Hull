function ruiStats = CV2script2(TimeGridA, TimeGridB, struct, isirange, bwidth, TimeLim, unit, color);
                            % designate cluster of interest 

if isirange(2) > TimeGridB(1)-TimeGridA(1)
    fprintf('error')
end
%%%%

n = find([struct.unitID] == unit); %% n changes to index in struct pointing to specified unit
TS2 = [struct(n).timestamps];  %% Make vector, TimeStamps2, that has timestamps from unit.


TS2 = TS2(TS2 < TimeLim(2)); %time limit timestamps
TS2 = TS2(TS2 > TimeLim(1));

TimeGridWindow = TimeGridB(1)-TimeGridA(1);         % Will Remake time grid within time limits
TimeGridB = TimeGridB((TimeGridB < TimeLim(2)) & (TimeGridB > TimeLim(1)));
TimeGridA = TimeGridB - TimeGridWindow;
if (TimeGridB(1)-TimeGridWindow)< TimeLim(1)
    TimeGridA(1) = TimeLim(1);
end

TS2 = TimeGridUnit(TimeGridA, TimeGridB, TS2);
TotalTime = (TimeGridB(1)-TimeGridA(1))+ TimeGridWindow*(length(TimeGridB)-1);      %First window can be artifically shortened from remaking time grid



title_ = [struct(n).unitID];
title_ = num2str(title_);                     % create a vector of timestamps for cluster of interest
title3 = [num2str(TimeLim(1))];
title4 = [num2str(TimeLim(2))];


L1 = (length(TS2));                           % L = number of spikes

k = 1;                                  %create counter for output vector index
for w = 1:length(TimeGridB)
    TGts2 =  TS2(TS2 < TimeGridB(w));        %time limit timestamps to this timegrid interval
    TGts2 = TGts2(TGts2 > TimeGridA(w));
                                        
for i=1:(length(TGts2) - 1)                                     % for every element in the first spiketime vector
    
       test = TGts2(i+1,:)- TGts2(i,:);             % get difference between spiketimes
       useDeltas (k,1) = test;                  % If yes, add difference to vector that will create histogram
           k = k+1;                                 % update index    
          
end
end

[N, edges] = histcounts(useDeltas, 'BinLimits', isirange, 'Binwidth', bwidth);
length(useDeltas)
length(N)
figure
FreqHist(N, edges, L1-1, 'k', 0.5, 1);
title([' ISI ' num2str(unit) ' between ' title3 ' and ' title4 'TG'])

box off;
%ax.TickDir = 'out'
ax = gca; 
ax.TickDir = 'out';
ax.FontName = 'Calibri'; 'FixedWidth';
ax.FontSize = 18;





%average Frequency
avgHz = (L1/TotalTime);
%windowAvgHz = (length(useDeltas)/60)

%median ISI
medISI = median(useDeltas);

%CVlog ISI
msecISI = 100*useDeltas;
logISI = log(msecISI);
CVlog = std(logISI)/mean(logISI);

%CV2
L2 = length(useDeltas);
m = 1;
for j=1:(L2-1) 
    if (abs(useDeltas(j+1)-useDeltas(j))) <= [TimeGridB(1)-TimeGridA(1)]
   CV2(m) = (sqrt(2)*(abs(useDeltas(j+1)-useDeltas(j))))/(useDeltas(j+1) + useDeltas(j));
   m = m+1;
    end
end
meanCV2 = mean(CV2)

% Fifth percentile of the ISI distribution
fvpctISI = prctile(useDeltas,5)

% % print values on chart
% gtext(['avg Hz = ' num2str(avgHz)])
% gtext(['median ISI = ' num2str(medISI)])
% gtext(['CVlog = ' num2str(CVlog)])
 gtext(['CV2 = ' num2str(meanCV2)], 'Color', color)
% gtext(['fifthISI = ' num2str(fvpctISI)])
% gtext(['TotalTime = ' num2str(TotalTime)])

ruiStats = [avgHz medISI CVlog meanCV2 fvpctISI TotalTime];
    

end

%tiledlayout(flow);


