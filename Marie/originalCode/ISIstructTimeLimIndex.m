% go to folder of interest!!!  & set these variables
function [N, edges, medianISI, meanISI, useDeltas] = ISIstructTimeLimIndex(struct, unit, range, TimeLim, bwidth, color, FaceAlpha, plotboo)

%n = find([struct.unitID] == unit); %% n changes to index in struct pointing to specified unit
n = unit;
unitTS = struct(n).timestamps;  %% Make vector, TimeStamps2, that has timestamps from unit.                    % create a vector of timestamps for cluster of interest

title3 = [num2str(TimeLim(1))];
title4 = [num2str(TimeLim(2))];


unitTS = unitTS(unitTS < TimeLim(2)); %time limit timestamps
unitTS = unitTS(unitTS > TimeLim(1));

%selectCL_ts = cast(selectCL_ts,'uint32');      % recast ts as a double instead of uint64
L1 = (length(unitTS));                           % L = number of spikes




k = 1;                                              %create counter for output vector index
for i=1:(L1-1)                                           % for every element in the first spiketime vector
       test = unitTS(i+1,:)- unitTS(i,:);             % get difference between spiketimes
       useDeltas (k,1) = test;                  % If yes, add difference to vector that will create histogram
           k = k+1;                                 % update index
     
           
    
end
% figure
% histogram (useDeltas, 'BinLimits', range, 'Binwidth', bwidth, 'Facecolor', 'k', 'Linestyle', 'none', 'Facealpha', 1) %'Normalization', 'probability', 
% title([' ISI ' num2str(unit)])
% box off
% ax = gca; 
% ax.TickDir = 'out';
% ax.FontName = 'Calibri', 'FixedWidth';
% ax.FontSize = 18;
% %tiledlayout(flow);
if exist('useDeltas')
meanISI = mean(useDeltas);
medianISI = median(useDeltas);

[N, edges] = histcounts(useDeltas, 'BinLimits', range, 'Binwidth', bwidth);
[N, edges] = FreqHist(N, edges, L1-1, color, FaceAlpha, 0);
if plotboo == 1
    plot(edges, N, color);
end
else 
    meanISI = NaN;
    medianISI = NaN;
    fprintf('\n %i Had no spikes in ISI window. meanISI and median ISI = NaN.\n', unit)
    f = warndlg('No spikes in ISI window. ');
end
title([' ISI ' num2str(struct(n).unitID) ' between ' title3 ' and ' title4 'TG'])

box off;
%ax.TickDir = 'out'
ax = gca; 
ax.TickDir = 'out';
ax.FontName = 'Calibri'; 'FixedWidth';
ax.FontSize = 18;


end


