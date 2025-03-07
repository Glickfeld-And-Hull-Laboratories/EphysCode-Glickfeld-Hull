for n = 1:length(still_TGA)
if ~isempty(find(still_TGA(n) < AllLicksAdj & AllLicksAdj < still_TGB(n)))
qsc_TGA(n) = NaN;
qsc_TGB(n) = NaN;
else
qsc_TGA(n) = still_TGA(n);
qsc_TGB(n) = still_TGB(n);
end
end
qsc_TGA = rmmissing(qsc_TGA);
qsc_TGB = rmmissing(qsc_TGB);