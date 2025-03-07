AllBinaryFiltTimeLim = ReadInAllBinaryChunks([TimeLim]);
[GoodUnitsIsol] = ExquisiteIsolationNew(GoodUnitStruct, NaN, TimeGridB, [0 1000], AllBinaryFilt1_1000, 'a6Ai32_1627_210927_HiPass150_loccar1_2_2.0');


k = 1;
for n = 1:length(GoodUnitsIsol)
    if ((GoodUnitsIsol(n).SigNoise > 5) && (GoodUnitsIsol(n).ISIviol < .01))
        Above5lessThan1(k) = GoodUnitsIsol(n);
        k = k+1;
    end
end



T = struct2table(GoodUnitStruct); % convert the struct array to a table

sortedByChan = sortrows(T, 'channel'); % sort the table by 'DOB'

sortedS = table2struct(sortedByChan); % change it back to struct array if necessary

save('AllBinaryFilt1_1000.mat','AllBinaryFilt1_1000'

for n = 1:length(sortedS)
if sortedS(n).Pair == -1
autoCorrStructNewLimits(GoodUnitsIsol, -.03, .03, .001, sortedS(n).unitID, [0 1000], 'k');
end
if sortedS(n).Pair == -2
autoCorrStructNewLimits(GoodUnitsIsol, -.3, .3, .001, sortedS(n).unitID, [0 1000], 'k');
end
if sortedS(n).Pair > 0
xCorrStructNewLimits(sortedS, -.03, .03, .001, sortedS(n).unitID, sortedS(n).Pair, 0, 1000, 'k');
end
end