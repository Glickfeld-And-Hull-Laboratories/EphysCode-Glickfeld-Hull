for n = 1:length(MLIsFav)
chan = MLIsFav(n).BiggestWFstruct.chan;
index = find([MLIsFav(n).wfStructStruct.Chan] == chan);
WFmain = [MLIsFav(n).wfStructStruct(index).AvgWf-mean(MLIsFav(n).wfStructStruct(index).AvgWf(1:5))];
if length(WFmain)>91
WFmain = WFmain(31:end-30);
end
MLIsFav(n).WFmain = WFmain;
sizeMain = max(WFmain)-min(WFmain);
lowlim = 20;
highlim = 40;
[~, mini] = min(WFmain);
if mini <lowlim || mini > highlim
WFaligned = WFmain;
else
WFaligned = WFmain(mini-lowlim:mini+highlim+10);
end
MLIsFav(n).WFmainAligned = WFaligned;
%if max(WFmain/-min(WFmain))<.5
plot(WFaligned/-min(WFaligned), 'Color', 'k', 'LineWidth', .5)
%for m = 1:length([MLIsFav(n).wfStructStruct])
%    WF_m = [MLIsFav(n).wfStructStruct(m).AvgWf-MLIsFav(n).wfStructStruct(m).AvgWf(1)];
%size_m = max(WF_m) - min(WF_m);
%if size_m/sizeMain > .5
%plot([MLIsFav(n).wfStructStruct(m).AvgWf]/-min([MLIsFav(n).wfStructStruct(m).AvgWf]), 'Color', colors(n,1:3))
%end
end

for n = 1:length(MLIsFav)
height = max([MLIsFav(n).WFmainAligned(21:end)]/-min([MLIsFav(n).WFmainAligned]));
MLIsFav(n).height = height;
end

SummaryStruct(1).LaserStimAdj = [];
SummaryStruct(1).DrugLinesStruct = [];
SumSt = [SumSt SummaryStruct];

%delete all but MLIs
SummaryStruct(1).height = [];
SummaryStruct(1).SyncBoo4SD = [];
SummaryStruct(1).WFmain = [];
SummaryStruct(1).WFmainAligned = [];
MLIsFav = [MLIsFav SummaryStruct];
