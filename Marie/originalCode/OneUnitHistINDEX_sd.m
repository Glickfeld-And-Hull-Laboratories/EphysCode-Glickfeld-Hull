% Creates histogram using a vector of triggers and a struct containing unitID
% and timstamps. Modified from iter_crosscor. MEH 2/25/21
%
% go to folder of interest!!!  & call this function
%
%
% TS1 = TimeStampOne, a vector of timestamps that will be used to trigger
% the histogram.
%
% n = unit of interest for the histogram, then index pointing to specified
% unit.
%
% struct = structure of units (field: unitID, as a string) and associated vectors containing
% timestamps for each unit (field: timstamps).
% xmin, smax, and bwidth for the histogram in seconds

function  [N_sd, edges, useDeltas] = OneUnitHistINDEX_sd(TS1, n, struct, xmin, xmax, bwidth, timeLim)
%Pass in INDEX of unit in structure
%n = find([struct.unitID] == n); %% n changes to index in struct pointing to specified unit

range = [xmin, xmax];                       % designate x-axis range in sec

trange = abs(xmin);                         % define a range that is used to find timestamps for histogram
if trange < xmax
    trange = xmax;
end

title2 = [num2str(n)];

%n = find([struct.unitID] == n); %% n changes to index in struct pointing to specified unit

TS2 = struct(n).timestamps;  %% Make vector, TimeStamps2, that has timestamps from unit.
%length(TS2)

title_ = [struct(n).unitID];
title_ = num2str(title_);
titleTr_ = inputname(1);

%titleTr =[num2str(titleTr)];
title3 = [num2str(timeLim(1))];
title4 = [num2str(timeLim(2))];
title_ = ['index ' title2 ' resp to ' titleTr_ ' between ' title3 ' and ' title4];


TS2 = TS2(TS2 < timeLim(2)); %time limit timestamps
TS2 = TS2(TS2 > timeLim(1));

TS1 = TS1(TS1 < timeLim(2)); %time limit triggers
TS1 = TS1(TS1 > timeLim(1));

L1 = (length(TS1));                          % L1 = number of triggers
L2 = (length(TS2));                            %L2 = number of spikes


%deltaT = tall(zeros(L*L,1));
%column = zeros(100)

reporter = 0;
                                             %create counter for output vector index
for  i=1:L1                                           % for every element in the first spiketime vector (trigger)
     state = 0;   % state machine to see if there are any spikes in the window for this trigger
     k = 1; 
    for j = 1:L2                                 % for every element in the second (or mirror) spiketime vector (spike timestamp)
       test = TS2(j,:)- TS1(i,:); 
       if test == 0
           test= nan;                               % eliminate zeros
       end
       if ((test <= trange) && (test >= -trange))    % Check if difference is in histogram range
           useDeltas{k,i} = test;                  % If yes, add difference to vector that will create histogram
           k = k + 1;                               % update index
           
           state = 1;                              % yes there are spikes in this window
       end
           
    end
    if (state == 0 )                          % add in a blank trial if there were no hits for this TS1 element
        useDeltas{k,i} = NaN;
        k = k+1;
    end
    
end


if exist ('useDeltas')                              % As long as there are spikes in the range, create the histogram.

for i=1:L1 
[N(:,i), edges] = histcounts([useDeltas{:,i}], 'BinLimits', range, 'Binwidth', bwidth);
N(:,i) = N(:,i)/(bwidth); % convert bars to firing rates
end

N_sd = std(N, 0, 2);
N_sd = N_sd/sqrt(L1);

else
    fprintf('index %s has no spikes in window\n',title_) % Alert user if no spikes in range.
    N = NaN(1,(range(end)-range(1))/bwidth);
    edges = NaN(1,(range(end)-range(1))/bwidth+1);
    L1 = NaN;
end

end

