function SummaryStruct = SumStMaker(unitList, ID_label, IDtype, MLIexpertType, figName, TimeGridA, TimeGridB, Struct, Struct_Phyllum, TimeLim, LaserStimAdj, MEH_chanMap, DrugLinesStruct)
ACGxlim = [-.3 .3];
ISIxlim = [0 .1];
WFlength = .003;
catchTime = .001;

counter = 1;
for n = 1:length(unitList)
SummaryStruct(counter).handID = ID_label;
[FR, channel, TimeLim1, wfStructStruct, Nisi, edgesISI, Nacg, edgesACG] = ACGandWFTL(unitList(n), Struct, TimeGridA, TimeGridB, WFlength, catchTime, ACGxlim(1), ACGxlim(2), ISIxlim, [0 TimeLim], .001, 'k', figName, MEH_chanMap, 1);
SummaryStruct(counter).unit = unitList(n);
SummaryStruct(counter).channel = channel;
SummaryStruct(counter).FR = FR;
SummaryStruct(counter).wfStructStruct = wfStructStruct.TGlim1WFs;
SummaryStruct(counter).TimeLimit = TimeLim1;
SummaryStruct(counter).Nisi = Nisi;
SummaryStruct(counter).edgesISI = edgesISI;
SummaryStruct(counter).Nacg= Nacg;
SummaryStruct(counter).edgesACG = edgesACG;
SummaryStruct(counter).recordingID = pwd;
SummaryStruct(counter).LaserStimAdj = LaserStimAdj;
SummaryStruct(counter).DrugLinesStruct = DrugLinesStruct;
index = find([Struct.unitID] == unitList(n));
SummaryStruct(counter).timestamps = Struct(index).timestamps;
if isa(Struct_Phyllum, 'struct')
    SummaryStruct(counter).PC_dist = Struct_Phyllum(index).PC_dist;
    SummaryStruct(counter).DCS_dist = Struct_Phyllum(index).DCS_dist;
    SummaryStruct(counter).MF_dist = Struct_Phyllum(index).MF_dist;
    SummaryStruct(counter).layer = Struct_Phyllum(index).layer;
    SummaryStruct(counter).snr = Struct_Phyllum(index).snr;
end
SummaryStruct(counter).IDtype = IDtype;
SummaryStruct(counter).MLIexpertID = MLIexpertType;
counter = counter + 1
end

for n = 1:length(SummaryStruct)
 struct = SummaryStruct(n).wfStructStruct;
    for s = 1:length(struct)
            Sizer(1,s) = max(struct(s).AvgWf) - min(struct(s).AvgWf);
    end
    [Dist, I] = max(Sizer);
    BiggestChan = struct(I).Chan;
    WF = struct(I).AvgWf; %WF = biggest WF
    BiggestWFstruct.WF = WF;
    if length(WF) == 90
        lowlim = 20;
        highlim = 40;
    end
    if length(WF) ==180
        lowlim = 50;
        highlim = 70;
    end
        
    [~ ,MAXi] = max(WF);
    [~, MINi] = min(WF);
    if MAXi < MINi
        if abs(max(WF)) > abs(min(WF))
        WF = -WF;
        BiggestWFstruct.flipped = 1;
        BiggestWFstruct.MAXIMINI = [MAXi, MINi];
        end
    end
    [~, mini] = min(WF);
if mini <lowlim || mini > highlim
    fprintf(['alignment error unit ' num2str(SummaryStruct(n).unit) '\n'])
    BiggestWFstruct.aligned = 0;
    [~, mini] = min(WF(lowlim:highlim));
    mini = mini + lowlim-1;
    WFaligned = WF(mini-(lowlim-1):mini+highlim+10);
else
    WFaligned = WF(mini-lowlim:mini+highlim+10); %minimum of normalized waveform is at index 21
    BiggestWFstruct.aligned = 1;
end
    
    BiggestWFstruct.unit = SummaryStruct(n).unit;
    BiggestWFstruct.chan = BiggestChan;
    BiggestWFstruct.WF = WF;
    BiggestWFstruct.NormWF = normalize(WF);
    BiggestWFstruct.NormBiggestAligned = normalize(WFaligned);
    BiggestWFstruct.alignedWF = WFaligned;
    
    [maxNorm, maxIndex] = max([BiggestWFstruct.NormBiggestAligned(21:end)]);
    [minNorm, ~] = min([BiggestWFstruct.NormBiggestAligned]);
    BiggestWFstruct.NormalSize = maxNorm-minNorm;
    BiggestWFstruct.MaxLoc = maxIndex;
    
    SummaryStruct(n).BiggestWFstruct= BiggestWFstruct;
end

end