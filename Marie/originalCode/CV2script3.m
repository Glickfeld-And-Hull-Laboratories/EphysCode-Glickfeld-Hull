function [useDeltas, ruiStats, CV2] = CV2script3(struct, isirange, bwidth, unit, color);
                            % designate cluster of interest 


n = find([struct.unitID] == unit); %% n changes to index in struct pointing to specified unit
TS2 = [struct(n).timestamps];  %% Make vector, TimeStamps2, that has timestamps from unit.


title_ = [struct(n).unitID];
title_ = num2str(title_);                     % create a vector of timestamps for cluster of interest



L1 = (length(TS2))                           % L = number of spikes
TotalTime = TS2(end);
k = 1;                                  %create counter for output vector index
for w = 1:(length(TS2)-1)
            % get difference between spiketimes
       useDeltas (k,1) = TS2(w+1,:)- TS2(w,:);                  % If yes, add difference to vector that will create histogram
           k = k+1;                                 % update index    
end

[N, edges] = histcounts(useDeltas, 'BinLimits', isirange, 'Binwidth', bwidth);
figure
FreqHist(N, edges, L1-1, 'k', 0.5, 1);
title([' ISI ' num2str(unit)])

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
medISI = median(useDeltas)

%CVlog ISI
msecISI = 100*useDeltas;
% logISI = log(msecISI);
CV = std(useDeltas)/mean(useDeltas)
CVlog = std(useDeltas)/mean(useDeltas);

%CV2
for j=1:(length(useDeltas)-1)   
   CV2(j) = 2*abs(useDeltas(j+1)-useDeltas(j))/(useDeltas(j+1) + useDeltas(j));
end
meanCV2 = nanmean(CV2)

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


