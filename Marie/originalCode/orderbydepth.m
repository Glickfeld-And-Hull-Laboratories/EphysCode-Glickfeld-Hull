function UnitListByChannel = orderbydepth(struct, unitlistUnsorted);

UnitChannelConcat = [unitlistUnsorted zeros(length(unitlistUnsorted), 1)];
for n = 1:length(unitlistUnsorted)
    UnitChannelConcat(n, 2) = FindChan(unitlistUnsorted(n), struct);
end
UnitListByChannel = sortrows(UnitChannelConcat, 2, 'descend');
end