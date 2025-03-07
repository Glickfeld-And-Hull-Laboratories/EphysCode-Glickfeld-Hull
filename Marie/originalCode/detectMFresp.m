function [MFunits] = determineMFid(struct, TimeLim1, TimeLim2, LaserStimAdj)
SD = 4;
msbins = .0001;
STDEVTIME = .1;
firstCutoff = .005;
secondCutoff = .01;
reqBinH = 2;

MFunits = [];
MFcounter = 1;

for n = 57:57%1:length(struct)

[N, edges, SDline, BinCounts] = OneUnitHistStructTimeLimSD(LaserStimAdj, struct(n).unitID, struct, -STDEVTIME, .02, msbins, TimeLim1, 4, 'k', .5, 1);
ZERO = find(edges == 0);

[stateTL1, MFtl_1] = detectResponses(ZERO, N, SDline, BinCounts, msbins, firstCutoff, secondCutoff, reqBinH);

[N2, ~, ~, BinCounts2] = OneUnitHistStructTimeLimSD(LaserStimAdj, struct(n).unitID, struct, -STDEVTIME, .02, msbins, TimeLim2, 4, 'k', .5, 0);

[stateTL2, MFtl_2] = detectResponses(ZERO, N2, SDline, BinCounts2, msbins, firstCutoff, secondCutoff, reqBinH);

if stateTL2 == 'response' & stateTL1 == 'response'
    
     MFunits(MFcounter).unit = [struct(n).unitID];
     MFunits(MFcounter).TL1_lat1 = MFtl_1.Lat1;
     MFunits(MFcounter).TL1_lat2 = MFtl_1.Lat2;
     MFunits(MFcounter).TL2_lat1 = MFtl_2.Lat1;
     MFunits(MFcounter).TL2_lat2 = MFtl_2.Lat2;
     MFcounter = MFcounter + 1;
end
end
end

    
    
    

        
   
    

