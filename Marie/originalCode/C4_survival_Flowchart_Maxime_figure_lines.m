fid = fopen('LaserStimAdj.txt');
LaserStimAdj = fscanf(fid, '%f');
fclose(fid);

[cluster_struct, GoodUnits, MultiUnits, GoodANDmua, AllUnits, AllUnitStruct, GoodUnitStruct, MultiUnitStruct, GoodANDmuaStruct] = ImportKSdataKSLabel();
SpikeTimes = SampToSec();         % use SampToSec funtion to get spiketimes and convert them to seconds using exact sampling rate
clustersAllST = double(readNPY('spike_clusters.npy'));           % For every spiketime, the cluster associated with it
spike_amplitudes = double(readNPY('amplitudes.npy'));               % For every spiketime, the amplituded associated with it
KSgood = cluster_struct(strcmp({cluster_struct.KSLabel}, 'good'));
for n = 1:length(KSgood)
KSgood(n).unitID = str2num(KSgood(n).cluster);
end
[KSgood] = CreateGoodStruct([KSgood.unitID], SpikeTimes, clustersAllST, spike_amplitudes);
STDEV = 4;
for n = 1:length(KSgood)
    figure
[N, edges] = OneUnitHistStructTimeLimLine(LaserStimAdj, KSgood(n).unitID, KSgood, -.1, .1, .001, [0 inf], 4, 'b', NaN, 0);
[meanLine, stdevLine] = StDevLine(N, edges, 0);
 yline(meanLine-STDEV*stdevLine, 'y');
if length(N(N<meanLine - STDEV*stdevLine))>=1
KSgood(n).LaserResp = 1;
end
end
close all
FlowChart.KSunit = length(KSgood);
FlowChart.LaserResp = length(rmmissing([KSgood.LaserResp]));
save FlowChart FlowChart;