function jitterSD = RespJitter(RasterMatrix, latencyInSec)
% RasterMatrix = OrganizeRasterSpikesNew(AllUnitStruct, LaserStimAdj,265, .1, .2);
for n = 1:length(RasterMatrix)
    trial = RasterMatrix{n,1}.';
    trial = trial>=latencyInSec;
    FirstSpikes(n,1) = trial(1)- latencyInSec;
end
jitterSD = std(FirstSpikes);
    
    
