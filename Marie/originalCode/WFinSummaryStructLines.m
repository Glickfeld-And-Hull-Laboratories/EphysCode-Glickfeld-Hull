for n = 1:length(SummaryStruct)
SummaryStruct(n).BiggestWFstruct = BestWFfinderPlotter2(SummaryStruct(n), 0);
end
for n = 1:length(SummaryStruct)
WF = SummaryStruct(n).BiggestWFstruct.WF;
[~ ,MAXi] = max(WF);
[~, MINi] = min(WF);
if MAXi < MINi
WF = -WF;
end
[~, mini] = min(WF);
if mini <20 || mini > 40
fprint('error error error')
else
WFaligned = WF(mini-20:mini+50); %minimum of normalized waveform is at index 21
end
SummaryStruct(n).BiggestWFstruct.alignedWF = WFaligned;
end


for n = 1:length(SummaryStruct)
SummaryStruct(n).forPCA = [SummaryStruct(n).BiggestWFstruct.NormBiggestAligned; [SummaryStruct(n).Nacg/mean(SummaryStruct(n).Nacg(1:5))].'];
end

for n=1:length(SummaryStruct)
    if find(isnan(SummaryStruct(n).forPCA))
        n
        find(isnan(SummaryStruct(n).forPCA))
    end
end
    
