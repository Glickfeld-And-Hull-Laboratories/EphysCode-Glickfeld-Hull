%load all Summary_NoWF fields
addpath(genpath('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\marie\originalCode'));
addpath(genpath('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\marie\Kilosort\Kilosort2-noCAR'));

load('SummaryDay1.mat')
load('SummaryDay2.mat')
load('SummaryDay3.mat')
load('SummaryDay7.mat')
load('SummaryDay10.mat')
load('SummaryDay13.mat')
load('SummaryDay18.mat')
load('SummaryDay21.mat')
load('SummaryDay23.mat')

%remove fields not present in every summary
Summary_noWF_1694_day2 = rmfield(Summary_noWF_1694_day2, {'JuiceModDir', 'LickOnsetsDir', 'JuiceResp', 'LickOnsets', 'JuiceOnset'});
%Summary_noWF_1694_day1 = rmfield(Summary_noWF_1694_day1, {'CellType1', 'CellType2'});

for n = 1:length(Summary_noWF_1694_day1)
    Summary_noWF_1694_day1(n).RecorNum = 1;
end 
for n = 1:length(Summary_noWF_1694_day2)
    Summary_noWF_1694_day2(n).RecorNum = 2;
end
for n = 1:length(Summary_noWF_1694_day3)
    Summary_noWF_1694_day3(n).RecorNum = 3;
end
    for n = 1:length(Summary_noWF_1694_day7)
        Summary_noWF_1694_day7(n).RecorNum = 4;
    end    
for n = 1:length(Summary_noWF_1694_day10)
    Summary_noWF_1694_day10(n).RecorNum = 5;
end
for n = 1:length(Summary_noWF_1694_day13)
    Summary_noWF_1694_day13(n).RecorNum = 6;
end
for n = 1:length(Summary_noWF_1694_day18)
    Summary_noWF_1694_day18(n).RecorNum = 7;
end
for n = 1:length(Summary_noWF_1694_day21)
    Summary_noWF_1694_day21(n).RecorNum = 8;
end
for n = 1:length(Summary_noWF_1694_day23)
    Summary_noWF_1694_day23(n).RecorNum = 9;
end
Summary = [Summary_noWF_1694_day1; Summary_noWF_1694_day2; Summary_noWF_1694_day3; ...
    Summary_noWF_1694_day7; Summary_noWF_1694_day10; Summary_noWF_1694_day13; Summary_noWF_1694_day18; Summary_noWF_1694_day21; Summary_noWF_1694_day23];
    
RecordingList_1694_day1.NoJuiceClk = [];
RecordingList_1694_day2.NoJuiceClk = [];
RecordingList = [RecordingList_1694_day1; RecordingList_1694_day2; ...
    RecordingList_1694_day3; RecordingList_1694_day7; RecordingList_1694_day10; ...
    RecordingList_1694_day13; RecordingList_1694_day18; RecordingList_1694_day21; RecordingList_1694_day23];

RecordingList(1).day = 1;
RecordingList(2).day = 2;
RecordingList(3).day = 3;
RecordingList(4).day = 7;
RecordingList(5).day = 10;
RecordingList(6).day = 13;
RecordingList(7).day = 18;
RecordingList(8).day = 21;
RecordingList(9).day = 23;

load MEH_chanMap
CS = Summary(strcmp({Summary.c4_label}, 'PkC_cs'));
CS = CS([CS.c4_confidence] > 2);
SS = Summary(strcmp({Summary.c4_label}, 'PkC_ss'));
SS = SS([SS.c4_confidence] > 2);
MF = Summary(strcmp({Summary.c4_label}, 'MFB'));
MF = MF([MF.c4_confidence] > 2);
MLI = Summary(strcmp({Summary.c4_label}, 'MLI'));
MLI = MLI([MLI.c4_confidence] > 2);
Gol = Summary(strcmp({Summary.c4_label}, 'GoC'));
Gol = Gol([Gol.c4_confidence] > 2);
['CS is ' num2str(length(CS))]
['SS is ' num2str(length(SS))]
['MF is ' num2str(length(MF))]
['MLI is ' num2str(length(MLI))]
['Gol is ' num2str(length(Gol))]

for n = 1:length(Summary)
    if isempty(Summary(n).PC_pair)
        Summary(n).PC_pair = NaN;
    end
end
Summary_paired = Summary(~isnan([Summary.PC_pair]));
%Summary_paired(43) = []; % a mistake here

c = 1;
for n = 1:length(Summary_1694_paired)
    if Summary_1694_paired(n).FR > 10
        SS_paired(c) = Summary_1694_paired(n);
        index = find([Summary_1694_paired.unitID] == [Summary_1694_paired(n).PC_pair] & Summary_1694_paired(n).RecorNum == [Summary_1694_paired.RecorNum]);
        CS_paired(c) = Summary_1694_paired(index);
        c = c + 1;
    end
end


% start with pre-calculations: calc different triggers
for n = 1:length(RecordingList)
    [RecordingList(n).LickOnsets, ~, ~] = FindLickOnsets_epochs(RecordingList(n).AllLicks, 0.5, .21, 1);
    [RecordingList(n).EpochOnsets, ~, ~] = FindLickOnsets_epochs(RecordingList(n).AllLicks, 0.5, .21, 3);
    [~, RecordingList(n).JuiceAlone, RecordingList(n).ToneAlone, RecordingList(n).JuiceAfterTone, RecordingList(n).ToneBeforeJuice, ~] = JuiceToneCreateTrialSt(RecordingList(n).JuiceTimes, RecordingList(n).ToneTimes);
        [RecordingList(n).TrialStruct_clk, RecordingList(n).JuiceAlone_clk, ~, RecordingList(n).JuiceAfterTone_clk, ~, ~] = JuiceToneCreateTrialSt(RecordingList(n).JuiceTimes_clk, RecordingList(n).ToneTimes);
        if ~isempty(RecordingList(n).JuiceTimes_sil)
        [RecordingList(n).TrialStruct_sil, RecordingList(n).JuiceAlone_sil, ~, RecordingList(n).JuiceAfterTone_sil, ~, ~] = JuiceToneCreateTrialSt(RecordingList(n).JuiceTimes_sil, RecordingList(n).ToneTimes);
        end
        [RecordingList(n).RewardLickOnset, RecordingList(n).RewardEpochOnset] = ExtractRewardLicks(RecordingList(n).TrialStruct, RecordingList(n).LickOnsets, RecordingList(n).EpochOnsets);
end
     
% find Tone & Juice during 100% paired block
for n = 1:length(RecordingList)
    if any(strcmp({RecordingList(n).TrialStruct.TrialType}, 'b'))
        StartAllPaired = find(strcmp({RecordingList(n).TrialStruct.TrialType}, 'b'), 1);
        Unpaired = find(~strcmp({RecordingList(n).TrialStruct.TrialType}, 'b'));
        Unpaired = Unpaired(Unpaired > firstPairedTrial); %unpaired that come after the paired block
        if ~isempty(Unpaired) & Unpaired(1) > StartAllPaired
            EndAllPaired = Unpaired(1);
            RecordingList(n).AllPairedBlock = RecordingList(n).TrialStruct(StartAllPaired:Unpaired-1);
        else
          RecordingList(n).AllPairedBlock = RecordingList(n).TrialStruct(StartAllPaired:end);
        end
    end
end

for q = 1:length(RecordingList) %extract epoch onsets first after juice for silent juice deliveries
     if ~isempty(RecordingList(q).JuiceAlone_sil)
    EpochOnsets = RecordingList(q).EpochOnsets;
    JuiceAlone_sil = RecordingList(q).JuiceAlone_sil;
    AllLicks = RecordingList(q).AllLicks;
clear EpochOnsetsFirstAfterJuice
counter = 1;
for n = 1:length(EpochOnsets)
    [i, k] = find (JuiceAlone_sil < EpochOnsets(n), 1, 'last');
    if ~isempty(i)
    if isempty(AllLicks(AllLicks < EpochOnsets(n) & AllLicks> JuiceAlone_sil(i)))
        EpochOnsetsFirstAfterJuice(counter) = EpochOnsets(n);
        counter = counter + 1;
    end
    end
end
RecordingList(q).EpochOnsetsFirstAfterJuice_sil = EpochOnsetsFirstAfterJuice;
     end
end


for q = 1:length(RecordingList) %extract epoch onsets first after juice for audible juice deliveries
    EpochOnsets = RecordingList(q).EpochOnsets;
    JuiceAlone_clk = RecordingList(q).JuiceAlone_clk;
    AllLicks = RecordingList(q).AllLicks;
clear EpochOnsetsFirstAfterJuice
counter = 1;
counter2 = 1;
for n = 1:length(EpochOnsets)
    [i, k] = find (JuiceAlone_clk < EpochOnsets(n), 1, 'last');
    if ~isempty(i)
    if isempty(AllLicks(AllLicks < EpochOnsets(n) & AllLicks> JuiceAlone_clk(i)))
        EpochOnsetsFirstAfterJuice(counter) = EpochOnsets(n);
        counter = counter + 1;
    end
    end
end
RecordingList(q).EpochOnsetsFirstAfterJuice_clk = EpochOnsetsFirstAfterJuice;
end

%precaluclate N's for individual cell response determination
SD = 4;
for n = 1:length(Summary)
[Summary(n).JuiceAlone.JuiceAloneResp.N, Summary(n).JuiceAlone.JuiceAloneResp.edges, ~] =OneUnitHistStructTimeLimLineINDEX(RecordingList(Summary(n).RecorNum).JuiceAlone, n, Summary, -.3, .65, .005, [0 inf], 4, 'b', NaN, 0, 0);
end

for n = 1:length(Summary)
[Summary(n).AllJuice.JuiceResp.N, Summary(n).AllJuice.JuiceResp.edges, ~] =OneUnitHistStructTimeLimLineINDEX(RecordingList(Summary(n).RecorNum).JuiceTimes, n, Summary, -.3, .65, .005, [0 inf], 4, 'b', NaN, 0, 0);
end

for n = 1:length(Summary)
[Summary(n).AllTone.ToneResp.N, Summary(n).AllTone.ToneResp.edges, ~] =OneUnitHistStructTimeLimLineINDEX(RecordingList(Summary(n).RecorNum).ToneTimes, n, Summary, -.3, .65, .005, [0 inf], 4, 'b', NaN, 0, 0);
end

for n = 1:length(Summary)
    [addthis(1,:), edges] = OneUnitHistStructTimeLimLineINDEX(RecordingList(Summary(n).RecorNum).RewardLickOnset, n, Summary, -1, 1, .01, [0 inf], 4, 'k', NaN, 0, 0);
        [meanLine, stdevLine] = StDevLine(addthis, edges, -.7);           % calc for z-score
        addthis = (addthis - meanLine)/stdevLine;                               % z-score
            addthis = abs(addthis);                                             % abs val
            addthis = smoothdata(addthis, 'sgolay', 11);
    Summary(n,:).RewardLickResp_zscore_abs_sgolay = addthis;
end

%determine responsiveness of cells
SD = 4;
for n = 1:length(Summary)
[struct.LatLow, struct.LatHigh, struct.modBoo, struct.Dir, struct.doubleBoo] = LatencyMod(0, Summary(n).JuiceAlone.JuiceAloneResp.N,  Summary(n).JuiceAlone.JuiceAloneResp.edges, SD, [0 .4], 0);
Summary(n).JuiceAlone.modLatStruct = struct;
Summary(n).JuiceAlone.Dir = struct.Dir;
end

for n = 1:length(Summary)
[struct.LatLow, struct.LatHigh, struct.modBoo, struct.Dir, struct.doubleBoo] = LatencyMod(0, Summary(n).AllJuice.JuiceResp.N,  Summary(n).AllJuice.JuiceResp.edges, SD, [0 .4], 0);
Summary(n).AllJuice.modLatStruct = struct;
Summary(n).AllJuice.Dir = struct.Dir;
end

for n = 1:length(Summary)
[struct.LatLow, struct.LatHigh, struct.modBoo, struct.Dir, struct.doubleBoo] = LatencyMod(0, Summary(n).AllTone.ToneResp.N,  Summary(n).AllTone.ToneResp.edges, SD, [0 .4], 0);
Summary(n).AllTone.modLatStruct = struct;
Summary(n).AllTone.Dir = struct.Dir;
end

CS = Summary(strcmp({Summary.c4_label}, 'PkC_cs'));
CS = CS([CS.c4_confidence] > 2);
SS = Summary(strcmp({Summary.c4_label}, 'PkC_ss'));
SS = SS([SS.c4_confidence] > 2);
MF = Summary(strcmp({Summary.c4_label}, 'MFB'));
MF = MF([MF.c4_confidence] > 2);
MLI = Summary(strcmp({Summary.c4_label}, 'MLI'));
MLI = MLI([MLI.c4_confidence] > 2);
Gol = Summary(strcmp({Summary.c4_label}, 'GoC'));
Gol = Gol([Gol.c4_confidence] > 2);

