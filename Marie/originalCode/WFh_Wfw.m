for n = 1:length(MLI_nullFR)
MLI_nullFR(n).BiggestWFstruct2 = BestWFfinderPlotter2(MLI_nullFR(n), 0);
end
for n = 1:length(MLI_nullFR)
WF = MLI_nullFR(n).BiggestWFstruct.WF;

if length(WF)>91
WF = WF(31:end-30);
end

[~ ,MAXi] = max(WF);
[~, MINi] = min(WF);
if MAXi < MINi
WF = -WF;
end
[~, mini] = min(WF);
if mini <20 || mini > 40
fprint('hello')
MLI_nullFR(n).NormWFAlignError = 1;
else
WFaligned = WF(mini-20:mini+50); %minimum of normalized waveform is at index 21
end
MLI_nullFR(n).BiggestWFstruct2.alignedWF = WFaligned;
end

for n = 1:length(MLI_nullFR)
MLI_nullFR(n).NormBiggestAligned2 = [MLI_nullFR(n).BiggestWFstruct.NormBiggestAligned];
[MAX, maxi] = max(MLI_nullFR(n).NormBiggestAligned2(20:end));
maxi = maxi + 20;
[MIN, mini] = min(MLI_nullFR(n).NormBiggestAligned2);
MLI_nullFR(n).WFh = MAX-MIN;
MLI_nullFR(n).WFw = maxi-mini;
end