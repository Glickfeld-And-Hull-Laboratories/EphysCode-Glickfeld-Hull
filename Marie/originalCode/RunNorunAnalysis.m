%Create CSUnitStruct for an experiement based on a list of unit IDS that
%are CS and a corresponding list of timeLimits (n rows, two columns- column 1 
%is starting time Limit and column 2 is ending Time Limit) during which 
%each CS is well-isolated.

function [outputStruct]= RunNorunAnalysis(ifRunAdj, inputStruct, burstLim, TimeLim, RecordingFile, CSlist);
for n = 1:length(CSlist)
    [FRate, FRrun, FRstop, timestamps] = FRstructRunNorunTimeLim(ifRunAdj, inputStruct, burstLim, TimeLim(n,:), CSlist(n));
    outputStruct(n).unitID = CSlist(n);
    outputStruct(n).timestamps = timestamps;
    outputStruct(n).FRate = FRate;
    outputStruct(n).FRrun = FRrun;
    outputStruct(n).FRstop = FRstop;
    outputStruct(n).TimeLim = TimeLim(n,:);
    outputStruct(n).ifRunAdj = ifRunAdj;
    outputStruct(n).RecordingFile = RecordingFile;
    outputStruct(n).paired = inputStruct(n).paired;
    outputStruct(n).CellType = inputStruct(n).CellType;
    
    p = find([inputStruct.unitID] == CSlist(n)); %% n changes to index in struct pointing to specified unit
    outputStruct(n).channel = [inputStruct(p).channel];  %% Make vector, TimeStamps2, that has timestamps from unit.
    outputStruct(n).depth = [inputStruct(p).depth];
    
    
    charUnit = num2str(CSlist(n));
    charUniteps = [charUnit '.eps'];
    saveas(gca, charUniteps, 'epsc');
    saveas(gca, charUnit);
    %close
end



