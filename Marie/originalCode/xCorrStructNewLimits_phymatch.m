% created to make cross-correlograms on data presented as structs. unit1
% and unit2 are particular units in a list of many units. struct contains 2
% fields= .unitID, which is a string identifying which unit, and
% .timestamps, which is a vector of timestamps where that unit fires.
% Adapted from iter_crosscorr
% MEH 3/3/21
%Change limits to change window the funtion operates on MEH 3/16/21

function xCorrStructNewLimits_phymatch(struct, xmin, xmax, bwidth, unit1, unit2, limMin, limMax, color) %times in seconds, n unit of interest for struct (.unitID= string, .timestamps= vector 

range = [(xmin), (xmax)];                       % designate x-axis range in sec, xmin should be negative
binnum = (xmax - xmin)/bwidth;
bwidth = (xmax-xmin)/(binnum +1);
trange = abs(range(1));
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
Unit1 = Unit1((limMin < Unit1) & (Unit1 < limMax));
Unit2 = Unit2((limMin < Unit2) & (Unit2 < limMax));
%

L1 = (length(Unit1));           % L = number of spikes
L2 = (length(Unit2));

k = 1;                                              %create counter for output vector index
for j = 1:L1                                           % for every element in the first spiketime vector
    for i=1:L2                                    % for every element in the second (or mirror) spiketime vector
       test = Unit2(i,:)- Unit1(j,:);             % get difference between spiketimes
       if test == 0
           test= nan;                               % eliminate zeros
       end
       if ((test <= trange) & (test >= -trange));    % Check if difference is in histogram range
           useDeltas (k,1) = test;                  % If yes, add difference to vector that will create histogram
           k = k+1;                                 % update index
       end
           
    end  
end

if exist ('useDeltas');
    
figure

%histogram (useDeltas, 'BinLimits', range, 'Binwidth', bwidth, 'Facecolor', 'k', 'Linestyle', 'none', 'Facealpha', 1);
%[N, edges] = histcounts(useDeltas, 'BinLimits', range, 'Binwidth', bwidth)
%FreqHist(N, edges, length(Unit1), color, 1);
histogram(useDeltas, 'BinLimits', range, 'Binwidth', bwidth)
strTitle = [num2str(title1) ' vs ' num2str(title2)];
title([num2str(title1) ' & ' num2str(title2) ' from ' num2str(limMin) ' to ' num2str(limMax)]);
box off;
xline(0,'b');
%ax.TickDir = 'out'
ax = gca; 
ax.TickDir = 'out';
ax.FontName = 'Calibri', 'FixedWidth';
ax.FontSize = 18;
%yticklabels(yticks/L1/bwidth);
%tiledlayout(flow);
fprintf('hello');
else
    fprintf('%d has no spikes in window\n',title2)
    
end


end
