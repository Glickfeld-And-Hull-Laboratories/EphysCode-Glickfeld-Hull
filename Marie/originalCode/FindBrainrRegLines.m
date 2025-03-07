for n = 1:length(SumSt_mlis)
chan = SumSt_mlis(n).channel;
SumSt_mlis(n).BrReg = RecordingList_mli(SumSt_mlis(n).RecorNum).BrainReg([RecordingList_mli(SumSt_mlis(n).RecorNum).BrainReg.chan] == chan).loc;
end