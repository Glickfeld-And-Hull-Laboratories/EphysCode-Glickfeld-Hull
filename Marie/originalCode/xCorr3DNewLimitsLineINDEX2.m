% created to make cross-correlograms on data presented as structs. unit1
% and unit2 are particular units in a list of many units. struct contains 2
% fields= .unitID, which is a string identifying which unit, and
% .timestamps, which is a vector of timestamps where that unit fires.
% Adapted from iter_crosscorr
% MEH 3/3/21
%Change limits to change window the funtion operates on MEH 3/16/21

function ThreeDstruct = xCorr3DNewLimitsLineINDEX2(struct, xmin, xmax, bwidth, unit1, unit2, limMin, limMax, color, SD, SDboo) %times in seconds, n unit of interest for struct (.unitID= string, .timestamps= vector 

range = [xmin, xmax];                       % designate x-axis range in sec, xmin should be negative
trange = abs(xmin);
if trange < xmax
    trange = xmax;
end
 [medianISI, meanISI, ISIdeltas] = ISIstructTimeLimIndex(struct, unit1, [xmin xmax], [limMin limMax], bwidth, color, 1, 0);
Pct = prctile(ISIdeltas,10);
 yscale = [0 1/Pct];
ystep = (yscale(2)-yscale(1))/10;
FRbins = flipud([yscale(1):ystep:yscale(2)].');Pct
ParulaColors = colormap(parula(length(FRbins)));
ThreeDstruct(1).LowFR = FRbins(1);
ThreeDstruct(1).HighFR = inf;
ThreeDstruct(1).k = 1;  
for n = 2:length(FRbins)
ThreeDstruct(n).LowFR = FRbins(n);
ThreeDstruct(n).HighFR = FRbins(n-1);
ThreeDstruct(n).k = 1;  
end


% if you are passing a particular unit, n, instead of using n/for loop to cycle
%through many:
Iunit1 = unit1;        % find index for units of interest
Iunit2 = unit2;
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

                                            %create counter for output vector index
for j = 2:(L1)-1                                           % for every element in the first spiketime vector
preIntervalFR = 2/(Unit1(j+1) - Unit2(j-1));
FRbinIndex = find(([ThreeDstruct.HighFR] > round(preIntervalFR)), 1, 'last');
    for i=2:L2-1                                   % for every element in the second (or mirror) spiketime vector
       test = Unit2(i,:)- Unit1(j,:);             % get difference between spiketimes
       if test == 0
           test= nan;                               % eliminate zeros
       end
       if ((test <= trange) & (test >= -trange))   % Check if difference is in histogram range
           ThreeDstruct(FRbinIndex).useDeltas(ThreeDstruct(FRbinIndex).k ,1) = test;                  % If yes, add difference to vector that will create histogram
           ThreeDstruct(FRbinIndex).k = ThreeDstruct(FRbinIndex).k + 1;                                 % update index
       end 
    end  
end


if isfield(ThreeDstruct, 'useDeltas')

binCount = 1;
for n = 1:length(FRbins)
if length(ThreeDstruct(n).useDeltas) > 25
FullFRbins(binCount) = n;
    binCount = binCount+1;
%histogram (useDeltas, 'BinLimits', range, 'Binwidth', bwidth, 'Facecolor', 'k', 'Linestyle', 'none', 'Facealpha', 1);
[N, edges] = histcounts([ThreeDstruct(n).useDeltas], 'BinLimits', range, 'Binwidth', bwidth);
ThreeDstruct(n).edges = edges(1:end-1);
[ThreeDstruct(n).N, ~] = FreqLine(N, edges, length(Unit1), ParulaColors(n,:), NaN, 0);
if ~SDboo == 0
[meanLine, stdevLine] = StDevLine(N, edges, 0);
yline(meanLine + SD*stdevLine, 'g', 'LineWidth', 2);
if (meanLine - SD*stdevLine) >0
yline((meanLine - 2*stdevLine), 'y', 'LineWidth', 2);
end
end

strTitle = [num2str(title1) ' vs ' num2str(title2)];
%title([num2str(title1) ' & ' num2str(title2) ' from ' num2str(limMin) ' to ' num2str(limMax)]);
%box off;
%xline(0,'b');
%ax.TickDir = 'out'
%ax = gca; 
%ax.TickDir = 'out';
%ax.FontName = 'Calibri';%, 'FixedWidth';
%ax.FontSize = 18;
%yticklabels(yticks/L1/bwidth);
%tiledlayout(flow);
    
end
end
else
    fprintf('%d has no spikes in window\n',title2)
end
x = [ThreeDstruct(FullFRbins(1)).edges];
y = ([ThreeDstruct(FullFRbins).LowFR].');
for n = 1:length(FullFRbins)
Array(n,:)= [ThreeDstruct(FullFRbins(n)).N];
end
figure
imagesc('XData',x,'YData', y,'CData',Array)
title([num2str(title1) ' & ' num2str(title2) ' from ' num2str(limMin) ' to ' num2str(limMax)]);
box off;
FormatFigure;
end
