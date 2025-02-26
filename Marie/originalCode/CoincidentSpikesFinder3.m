function DoubleCoincidentSpikes = CoincidentSpikesFinder3(unit1, unit2, unit3, struct, CoIncWin)

unitINone = find([struct.unitID] == unit1);
TSone = [struct(unitINone).timestamps]; 

unitINtwo = find([struct.unitID] == unit2);
TStwo = [struct(unitINtwo).timestamps]; 

unitINthree = find([struct.unitID] == unit3);
TSthree = [struct(unitINthree).timestamps]; 

k = 1;
for i = 1:length(TSone)
    SearchWindow = [TSone(i) - CoIncWin TSone(i) + CoIncWin];
    if find(TStwo > SearchWindow(1) & TStwo < SearchWindow(2))
     CoincidentSpikes(k,1)= TSone(i);
     k = k+1;
    end
end

c = 1;
for j = 1:length(CoincidentSpikes)
    SearchWindow = [CoincidentSpikes(j) - CoIncWin CoincidentSpikes(j) + CoIncWin];
    if find(TSthree > SearchWindow(1) & TSthree < SearchWindow(2))
     DoubleCoincidentSpikes(c,1)= CoincidentSpikes(j);
     c = c+1;
    end
end
end
        