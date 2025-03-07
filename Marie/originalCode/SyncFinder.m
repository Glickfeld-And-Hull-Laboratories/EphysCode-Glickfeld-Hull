function CoincidentSpikes = SyncFinder(unit1, unit2, struct, CoIncWin)

TSone = [struct(unit1).timestamps]; 
TStwo = [struct(unit2).timestamps]; 
k = 1;
CoincidentSpikes = [];
for i = 1:length(TSone)
    SearchWindow = [TSone(i) - CoIncWin TSone(i) + CoIncWin];
    if find(TStwo > SearchWindow(1) & TStwo < SearchWindow(2))
     CoincidentSpikes(k,1)= TSone(i);
     k = k+1;
    end
end
end
        