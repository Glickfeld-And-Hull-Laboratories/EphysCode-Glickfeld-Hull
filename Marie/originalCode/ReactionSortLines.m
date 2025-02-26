trials = [1:127];
trials  = trials.';
TrialRT = [trials RTs_OneSecGood];
[B,I] = sort(RTs_OneSecGood);
JuiceByReaction = JuiceTimesAdj(I);
RasterMatrix = OrganizeRasterSpikesNew(AllUnitStruct, JuiceByReaction-.699, 586, .2, 2);