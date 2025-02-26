function PlotGroupMean(CSstruct)

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

end