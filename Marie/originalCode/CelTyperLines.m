for n = 1:length(SumSt)
if strcmp(SumSt(n).handID, 'CS_pause') | strcmp(SumSt(n).handID, 'CS_noPair')
SumSt(n).CellType = 'CS';
elseif strcmp(SumSt(n).handID, 'SS_pause') | strcmp(SumSt(n).handID, 'SS_noPair')
SumSt(n).CellType = 'SS';
else
SumSt(n).CellType = SumSt(n).handID;
end
end