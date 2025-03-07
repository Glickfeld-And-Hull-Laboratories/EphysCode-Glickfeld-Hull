function struct = MultiChan_sig2noise(struct, NoiseAnalysis)
%struct is data like AllUnitStruct with field MultiChanWF, NoiseAnalysis is struct with fields
%channel, Median (noise) and OneStDev (noise)
%be sure any time limit is the same for waveforms in struct and
%noiseAnalysis

for n = 1:length(struct)
    WFstruct = struct(n).MultiChanWF;
    for k = 1:length(WFstruct)
        channel = (WFstruct(k).Chan);
        NoiseStruct(k).channel = channel;
        NoiseStruct(k).Median = NoiseAnalysis(find([NoiseAnalysis.chan] == channel)).Median;
        NoiseStruct(k).OneStDev = NoiseAnalysis(find([NoiseAnalysis.chan] == channel)).OneStDev;
        Sig(k,1) = max(WFstruct(k).AvgWf) - min(WFstruct(k).AvgWf)
    end
    [M, I] = max(Sig)
    bestChan = WFstruct(I).Chan;
    bestNoise = NoiseStruct(I).OneStDev;
    Sig2Noise= M / (2*bestNoise);
    
    struct(n).OneSDnoise = NoiseStruct;
    struct(n).bestSig2Noise = Sig2Noise;
    struct(n).bestChan = bestChan;
end