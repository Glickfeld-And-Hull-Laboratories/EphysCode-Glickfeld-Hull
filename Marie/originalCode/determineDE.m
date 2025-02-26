function [DEunits] = determineDE(struct, TimeLim1, TimeLim2, LaserStimAdj)
SD = 4;
msbins = .001;
STDEVTIME = .1;
firstCutoff = .008;
%secondCutoff = .01;
reqBinH = 2;

DEunits = [];
DEcounter = 1;

for n = 1:length(struct)

[N, edges, SDline, ~] = OneUnitHistStructTimeLimSD(LaserStimAdj, struct(n).unitID, struct, -STDEVTIME, .02, msbins, TimeLim1, SD, 'k', .5, 1);
ZERO = find(edges == 0);

[stateTL1, DEtl_1] = detectResponsesDE(ZERO, N, SDline, msbins, firstCutoff, reqBinH);

[N2, ~, ~, ~] = OneUnitHistStructTimeLimSD(LaserStimAdj, struct(n).unitID, struct, -STDEVTIME, .02, msbins, TimeLim2, SD, 'k', .5, 0);

[stateTL2, DEtl_2] = detectNoResponsesDE(ZERO, N2, SDline, msbins, firstCutoff, reqBinH);

if stateTL2 == '0' & stateTL1 == 'response'
    
     DEunits(DEcounter).unit = [struct(n).unitID];
     DEunits(DEcounter).chan = struct(n).channel;
     DEunits(DEcounter).TL1_lat1 = DEtl_1.Lat1;
     %DEunits(DEcounter).TL1_lat2 = DEtl_1.Lat2;
     DEunits(DEcounter).TL2_lat1 = DEtl_2.Lat1;
     %DEunits(DEcounter).TL2_lat2 = DEtl_2.Lat2;
     DEcounter = DEcounter + 1;
end
end
end

    
    
    

        
   
    

