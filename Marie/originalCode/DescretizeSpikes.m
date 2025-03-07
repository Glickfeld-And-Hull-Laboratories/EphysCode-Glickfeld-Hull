function [RasterMatrix] = DescretizeSpikes(struct, NewTrig, unit, xmin, xmax, TimeLim)
timeResolution = .001; % in seconds
sampRate = (1/timeResolution); %set this if you want/have a different sampling rate

unit = GetUnitVector(unit, struct); %get vector of timestamps for unit

if ~isnan(TimeLim)
    NewTrig = NewTrig((NewTrig < TimeLim(2)) & (NewTrig > TimeLim(1))); %Limit time to certain triggers if you want
end
stop = length(NewTrig);     %get number of Juice deliveries
binsPerTrial = floor(((NewTrig(1) + xmax) - (NewTrig(1) - xmin))*sampRate); % one extra bin to try and not run out of space in the salt code
RasterMatrix = zeros(stop, binsPerTrial);       % make an output cell that is right length- one row for each juice delivery
SizeRasterMatrix = size(RasterMatrix)
for j = 1:stop %for every trial
       lickWin = unit((unit > (NewTrig(j)- xmin)) & (unit < (NewTrig(j)+ xmax))) - (NewTrig(j) - xmin); % spikes for trial j reset so Trigj-xmin = 0;    
       if ~isempty(lickWin)
                for k = 1:length(lickWin)
                    bintick = floor(lickWin(k)/timeResolution) + 1; %Because time starts at 0 and matrix indices start at 1
                    RasterMatrix(j,bintick)= RasterMatrix(j,bintick) +1;
                    %RasterMatrix(j,bintick)= RasterMatrix(j,bintick) +1;
                    %if RasterMatrix(j,bintick) >1
                    %    tester = 'problems'
                    %end
                end
           
       end
end
    
