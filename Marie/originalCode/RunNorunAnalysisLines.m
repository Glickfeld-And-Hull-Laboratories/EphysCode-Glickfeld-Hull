%Create CSUnitStruct for an experiement based on a list of unit IDS that
%are CSs.

function = RunNorunAnalysis(ifRunAdj, AllUnitStruct, burstLim, TimeLim, RecordingFile, CSlist);
for n = 1:length(CSlist)
    [FRate, FRrun, FRstop, timestamps] = FRstructRunNorunTimeLim(ifRunAdj, AllUnitStruct, burstLim, TimeLim, CSlist(n));
    CSGoodUnitStruct(n).unitID = CSlist(n);
    CSGoodUnitStruct(n).timestamps = timestamps;
    CSGoodUnitStruct(n).FRate = FRate;
    CSGoodUnitStruct(n).FRrun = FRrun;
    CSGoodUnitStruct(n).FRstop = FRstop;
    CSGoodUnitStruct(n).TimeLim = TimeLim;
    CSGoodUnitStruct(n).ifRunAdj = ifrunAdj;
    CSGoodUnitStruct(n).RecordingFile = RecordingFile;
    CSGoodUnitStruct(n).channel = 
    
    charUnit = num2str(CSlist(n));
    charUniteps = [charUnit '.eps'];
    saveas(gca, charUniteps, 'epsc');
    saveas(gca, charUnit);
    close
end



