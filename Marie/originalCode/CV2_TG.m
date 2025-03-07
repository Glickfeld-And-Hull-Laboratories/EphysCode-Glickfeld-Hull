function [meanCV2, isi] = CV2_TG(unit_index, struct, TGA, TGB)
timestamps = [struct(unit_index).timestamps]; 
isi = [];
for n = 1:length(TGA)
    section = timestamps(timestamps > TGA(n));
    section = section(section < TGB(n));
    isi = [isi; diff(section)];
end

for j=1:(length(isi)-1)   
   CV2(j) = 2*abs(isi(j+1)-isi(j))/(isi(j+1) + isi(j));
end
meanCV2 = nanmean(CV2)