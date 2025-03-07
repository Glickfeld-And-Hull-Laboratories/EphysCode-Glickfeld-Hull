function [meanCV2, isi, CV2] = CV2_TG_timeLim(unit_index, struct, TGA, TGB, TimeLim)

binW = .1;
timestamps = [struct(unit_index).timestamps]; 
isi = [];
if ~isempty(TimeLim)
if isinf(TimeLim(2))
    TimeLim(2) = timestamps(end)+.00001;
end
binTimes = [TimeLim(1):binW:TimeLim(2)].';
if ~isnan(TGA)
binTimes = TimeGridUnit(TGA, TGB-binW, binTimes);
end
binTimes = [binTimes binTimes + binW];
for n = 1:length(binTimes)
    section = timestamps(timestamps > binTimes(n,1));
    section = section(section < binTimes(n,2));
    isi = [isi; diff(section)];
end
if ~isempty(isi)
% for j=1:(length(isi))-1   
%    CV(j) = std(isi)/mean(isi);
% end
for j=1:(length(isi)-1)   
   CV2(j) = 2*abs(isi(j+1)-isi(j))/(isi(j+1) + isi(j));
end
meanCV2 = nanmean(CV2);
% meanCV = nanmean(CV);
else
     meanCV2 = [];
    isi = [];
    CV2 = [];  
end
else
   meanCV2 = [];
    isi = [];
    CV2 = [];
end