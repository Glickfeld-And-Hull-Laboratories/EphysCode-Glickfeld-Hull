for n = 1:length(GoodUnitStructSorted)
if GoodUnitStructSorted(n).FR <2.5
CSstruct(count).unitID = GoodUnitStructSorted(n).unitID;
CSstruct(count).channel = GoodUnitStructSorted(n).channel;
CSstruct(count).FR = GoodUnitStructSorted(n).FR;
[CSstruct(count).Njat, CSstruct(count).edgesJat] = OneUnitHistStructTimeLimLine(JuiceAfterToneAdj, GoodUnitStructSorted(n).unitID, AllUnitStruct, -2, 3, .05, [0 inf], 4, 'k', 'tester', 0, 0);
[CSstruct(count).Nta, CSstruct(count).edgesTa] = OneUnitHistStructTimeLimLine(ToneAloneAdj, GoodUnitStructSorted(n).unitID, AllUnitStruct, -2, 3, .05, [0 inf], 4, 'k', 'tester', 0, 0);
[CSstruct(count).Nja, CSstruct(count).edgesJa] = OneUnitHistStructTimeLimLine(JuiceAloneAdj, GoodUnitStructSorted(n).unitID, AllUnitStruct, -2, 3, .05, [0 inf], 4, 'k', 'tester', 0, 0);
[CSstruct(count).Nnje, CSstruct(count).edgesNje] = OneUnitHistStructTimeLimLine(NoJuiceEpochsAdj, GoodUnitStructSorted(n).unitID, AllUnitStruct, -2, 3, .05, [0 inf], 4, 'k', 'tester', 0, 0);
[CSstruct(count).Nfje, CSstruct(count).edgesFje] = OneUnitHistStructTimeLimLine(FirstJuiceEpochsAdj, GoodUnitStructSorted(n).unitID, AllUnitStruct, -2, 3, .05, [0 inf], 4, 'k', 'tester', 0, 0);
count = count + 1;
end
end

Njat = struct2mat(CSstruct, 'Njat');
NjatMean = mean(Njat);
Nta = struct2mat(CSstruct, 'Nta');
NtaMean = mean(Nta);
Nja = struct2mat(CSstruct, 'Nja');
NjaMean = mean(Nja);
Nnje = struct2mat(CSstruct, 'Nnje');
NnjeMean = mean(Nnje);
Nfje = struct2mat(CSstruct, 'Nfje');
NfjeMean = mean(Nfje);

figure
hold on
plot(CSstruct(1).edgesJat(1:end-1), NjatMean.', 'k');
plot(CSstruct(1).edgesJat(1:end-1)-.68, NtaMean.', 'g');
plot(CSstruct(1).edgesJat(1:end-1), NjaMean.', 'b');
plot(CSstruct(1).edgesJat(1:end-1), NnjeMean.', 'r');
plot(CSstruct(1).edgesJat(1:end-1), NfjeMean.', 'c');

