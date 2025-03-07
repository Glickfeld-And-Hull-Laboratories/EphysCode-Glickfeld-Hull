function LickOnsets = FindLickOnsets(licks, threshold)
LickOnsets = [];
k = 1;
for i = 2:(length(licks)-2)
    if ((licks(i) - licks(i-1)) > threshold) 
            LickOnsets(k) = licks(i);
            k = k+1;
    end
end
LickOnsets = LickOnsets.';
end