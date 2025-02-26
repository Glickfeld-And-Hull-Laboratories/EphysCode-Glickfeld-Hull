%Make C4 Struct
fid = fopen('LaserOffAdj.txt');
LaserStimOffAdj = fscanf(fid, '%f');
fclose(fid);
fid = fopen("LaserStimAdj.txt");
LaserStimAdj = fscanf(fid, '%f');
fclose(fid);
optostims = [LaserStimAdj LaserStimOffAdj];
load MEH_chanMap
TimeGridC= LaserStimAdj;
TimeGridD= LaserStimAdj + 5;

%switch folders

TimeLim = [0 30];
[cluster_struct, GoodUnits, MultiUnits, GoodANDmua, AllUnits, AllUnitStruct, GoodUnitStruct, MultiUnitStruct, GoodANDmuaStruct] = ImportKSdataC4();

%switch to filtered data folder

BinaryFilt0_30 = ReadInAllBinary([TimeLim]); %aka BinaryStruct/AllBinaryFilt
[StDevCH] = NoiseOnEveryChannel(BinaryFilt0_30, MEH_chanMap); %rez);

TimeLim2 = [0 DrugLinesStruct(1).time];
BinaryFiltTimeLim2 = ReadInAllBinary(TimeLim2);

for k = 1:length(SummaryStruct)
    I = find([GoodUnitStruct.unitID] == SummaryStruct(k).unit);
    K = k
    C4struct(k).lab_id = 'Hull';
    C4struct(k).dataset_id = '1648_220406g0';
    C4struct(k).neuruon_id = GoodUnitStruct(I).unitID;
    C4struct(k).sampling_rate = 3000;
    C4struct(k).spike_indices = [GoodUnitStruct(I).timestamps];  
    C4struct(k).optostims = [LaserStimAdj LaserStimOffAdj];
    SaneSpikes = SaneSpikesC4(GoodUnitStruct, [0 DrugLinesStruct(1).time], TimeGridC, TimeGridD, GoodUnitStruct(I).unitID);
    C4struct(k).sane_spikes = SaneSpikes(:,2);
    C4struct(k).mean_waveform_preprocessed = WaveFormAvgSetChan2(TimeGridC, TimeGridD, BinaryFiltTimeLim2, GoodUnitStruct, MEH_chanMap, TimeLim2, GoodUnitStruct(I).unitID);
    C4struct(k).consensus_waveform = NaN(180,1);
    C4struct(k).channelmap = ChannelMapC4(GoodUnitStruct, GoodUnitStruct(I).unitID, MEH_chanMap);
    C4struct(k).channel_noise_std = ArrayOfNoise([GoodUnitStruct(I).channel], StDevCH, MEH_chanMap);
    C4struct(k).amplitudes = [GoodUnitStruct(I).amplitudes];
    C4struct(k).phyllum_layer = 0;
    C4struct(k).human_layer = 0;
    C4struct(k).human_label = 0;
    C4struct(k).optotagged_label = SummaryStruct(k).handID;
    C4struct(k).lisberger_label = 0;
    C4struct(k).hausser_label = 0;
    C4struct(k).medina_label = 0;
end
 
