function [prepauseSpikes, k] = PauseFinder(unit, time)
k=1;
for i = 1:length(unit)-1
    if (((unit(i+1) - unit(i)) >= time))
        prepauseSpikes(k,:)= unit(i);
        k = k + 1;
        %i = i+2;
    end
end
end