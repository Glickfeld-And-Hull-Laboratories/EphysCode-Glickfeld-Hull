function [First, Second, Third, Fourth, Fifth] = BurstOrdered(unit, bursttime, resttime, TimeGridA, TimeGridB)
k=1;
k3 = 1;
k4 = 1;
k5 = 1;
if ~isnan(TimeGridA)
    unit = TimeGridUnit(TimeGridA, TimeGridB, unit);
end
for i = 2:length(unit)-5
    if unit(i)-unit(i-1) >= resttime
    if (unit(i+1) - unit(i)) <= bursttime
        First(k,:)= unit(i);
        Second(k, :) = unit(i+1);
        k = k + 1;
        if (unit(i+2) - unit(i+1)) < bursttime
        Third(k3, :) = unit(i+2);
        k3 = k3+1;
            if (unit(i+3) - unit(i+2)) < bursttime
            Fourth(k4,:) = unit(i+3);
            k4 = k4+1;
                if (unit(i+4) - unit(i+3)) < bursttime
                Fifth(k5,:) = unit(i+4);
                k5 = k5+1;
                end
            end
        end
    end
    end
end

if ~exist('First')
    First = NaN;
end
if ~exist('Second')
    Second = NaN;
end
if ~exist('Third')
    Third = NaN;
end
if ~exist('Fourth')
    Fourth = NaN;
end
if ~exist('Fifth')
    Fifth = NaN;
end

end