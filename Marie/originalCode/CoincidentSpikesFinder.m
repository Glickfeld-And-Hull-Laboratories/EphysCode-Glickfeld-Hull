function CoincidentSpikes = CoincidentSpikesFinder(unit1, unit2, struct, CoIncWin)

unitINone = find([struct.unitID] == unit1);
TSone = [struct(unitINone).timestamps]; 

unitINtwo = find([struct.unitID] == unit2);
TStwo = [struct(unitINtwo).timestamps]; 
k = 1;
for i = 1:length(TSone)
    SearchWindow = [TSone(i) - CoIncWin TSone(i) + CoIncWin];
    %SearchWindow = [TSone(i) - CoIncWin  TSone(i)];
    if find(TStwo > SearchWindow(1) & TStwo < SearchWindow(2))
     CoincidentSpikes(k,1)= TSone(i);
     k = k+1;
    end
end
end
        