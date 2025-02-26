function [avgHz, medISI, CVlog, meanCV2] = RuigrokStatsNew( struct, isirange, bwidth, TimeLim, unit)
                            % designate cluster of interest 


%%%%

n = find([struct.unitID] == unit); %% n changes to index in struct pointing to specified unit
TS2 = [struct(n).timestamps];  %% Make vector, TimeStamps2, that has timestamps from unit.



TS2 = TS2(TS2 < TimeLim(2)); %time limit timestamps
TS2 = TS2(TS2 > TimeLim(1));


TotalTime = TS2(end)-TS2(1);



title_ = [struct(n).unitID];
title_ = num2str(title_);                     % create a vector of timestamps for cluster of interest
title3 = [num2str(TimeLim(1))];
title4 = [num2str(TimeLim(2))];


L1 = (length(TS2));                           % L = number of spikes

k = 1;                                  %create counter for output vector index
                                        
for i=1:(length(TS2) - 1)                                     % for every element in the first spiketime vector
    
       test = TS2(i+1,:)- TS2(i,:);             % get difference between spiketimes
       useDeltas (k,1) = test;                  % If yes, add difference to vector that will create histogram
           k = k+1;                                 % update index         

end

[N, edges] = histcounts(useDeltas, 'BinLimits', isirange, 'Binwidth', bwidth);
FreqHist(N, edges, L1-1, 'k', 1, 0);
title([' ISI ' num2str(unit) ' between ' title3 ' and ' title4])

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
    CV2(m) = 2*(abs(useDeltas(j+1)-useDeltas(j)))/(useDeltas(j+1)+ useDeltas(j));
    m = m+1;
end
meanCV2 = mean(CV2);

% Fifth percentile of the ISI distribution
%fvpctISI = prctile(useDeltas,5)

% print values on chart
%gtext(['avg Hz = ' num2str(avgHz)])
%gtext(['median ISI = ' num2str(medISI)])
%gtext(['CVlog = ' num2str(CVlog)])
%gtext(['CV2 = ' num2str(meanCV2)])
%gtext(['fifthISI = ' num2str(fvpctISI)])

%ruiStats = [avgHz medISI CVlog meanCV2]% fvpctISI];
    

end

%tiledlayout(flow);


