DrugLinesStruct(1).Name
TimeGridAsane = TimeGridA(TimeGridA <DrugLinesStruct(1).time);
for n = 1:length(TimeGridAsane)
SaneSpikeMask{n} = [TimeGridAsane(n) TimeGridB(n)];
end
SaneSpikeMask = SaneSpikeMask.';

fid=fopen('ForJson','w');
fprintf(fid, '%s',  '"units": ');
fprintf(fid, '%s', jsonencode([MFhandID]));
fprintf(fid, '%s', [',' newline '      "ss": ']);
fprintf(fid, '%s', jsonencode([SS_CS.SS]));
fprintf(fid, '%s', [',' newline '      "cs": ']);
fprintf(fid, '%s', jsonencode([SS_CS.CS]));
fprintf(fid, '%s', [',' newline '      "DE": ']);
fprintf(fid, '%s', jsonencode(DEhandID));
fprintf(fid, '%s', [',' newline '      "global_sane_period": ']);
for n = 1:length(TimeGridA)
SaneSpikeMask{n} = [TimeGridA(n) TimeGridB(n)];
end
SaneSpikeMask = SaneSpikeMask.';
fprintf(fid, '%s', jsonencode(SaneSpikeMask));
fprintf(fid, '%s', [',' newline '    },']);

