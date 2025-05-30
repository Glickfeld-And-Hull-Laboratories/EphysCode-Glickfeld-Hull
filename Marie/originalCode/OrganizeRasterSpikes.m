function RasterMatrix = OrganizeRasterSpikesNew(struct, NewTrig, unit, xmin, xmax)

unit = GetUnitVector(unit, struct);
% restructure JuiceLicks, a cell containing JuiceTimes and LickTimes generated by FindLicksNew, into a
% nx1 cell (n = # of juicetimes) for use with plotSpikeRaster.m
% MEH 3/2/21
%title1_ = inputname(1);
%title2_ = inputname(2);
%title_ = strcat(title1_, ', ', title2_);

stop = length(NewTrig);     %get number of Juice deliveries
%LickTimesCell = cell(1,stop);
RasterMatrix = cell(stop, 1);       % make an output cell that is right length- one row for each juice delivery

for m = 1:stop
    clear k;
    n = [NaN];
    lickWin = ((unit > (NewTrig(m)- xmin)) & (unit < (NewTrig(m)+ xmax)));
    %upper = NewTrig(m) + xmax;
    %lower = NewTrig(m) + xmin;
   %licksWinLog = find(xmin <allLicks <xmax)
   c = 1;
    for j = 1:length(unit)
        if(lickWin(j))
            k = (unit(j)- NewTrig(m));
            if (isnan(k) || k == 0)
                n(c)=NaN;
                c = c +1;
            else
                n(c)=k;
                c = c +1;
            end
        end
    end
RasterMatrix{m,1}=n;  % for every juice delivery, convert the times of licks to times to plot on the raster by centering them at 0 = time of juice delivery
end
%figure
plotSpikeRaster(RasterMatrix, 'PlotType', 'vertline')%, 'FigHandle', 'gcf'); % create the raster plot using a function someone else wrote.
box off;
%ax.TickDir = 'out'
ax = gca; 
ax.TickDir = 'out';
ax.FontName = 'Calibri'; 'FixedWidth';
ax.FontSize = 18;

%useDeltas = [];
%for m = 1:stop
%    useDeltas = [useDeltas RasterMatrix{m}];
%end
%figure
%range = [xmin, xmax];
%bwidth = abs(xmin)/10;
%histogram (useDeltas, 'BinLimits', range, 'Binwidth', bwidth, 'Facecolor', 'k', 'Linestyle', 'none', 'Facealpha', 1, 'Normalization', 'probability');
%xline(0,'b');
%title(title_);
%box off;
%%ax.TickDir = 'out'
%ax = gca; 
%ax.TickDir = 'out';
%ax.FontName = 'Calibri'; 'FixedWidth';
%ax.FontSize = 18;
end