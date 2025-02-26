function c = Cell2CellDistINDEX(struct, index1, index2, chanMap)
%get coords for index1
F = fields(struct);
if true(sum(strcmp(F, 'BiggestWFstruct')))
chan1 = struct(index1).BiggestWFstruct.chan;
mapI = chan1 + 1;
x1 = chanMap(mapI).xcoord;
y1 = chanMap(mapI).ycoord;

%get coords for index2
chan2 = struct(index2).BiggestWFstruct.chan;
mapI = chan2 + 1;
x2 = chanMap(mapI).xcoord;
y2 = chanMap(mapI).ycoord;

a = abs(x1 - x2);
b = abs(y1 - y2);

c = sqrt(a^2 + b^2);
else
    chan1 = struct(index1).channel;
mapI = chan1 + 1;
x1 = chanMap(mapI).xcoord;
y1 = chanMap(mapI).ycoord;

%get coords for index2
chan2 = struct(index2).channel;
mapI = chan2 + 1;
x2 = chanMap(mapI).xcoord;
y2 = chanMap(mapI).ycoord;

a = abs(x1 - x2);
b = abs(y1 - y2);

c = sqrt(a^2 + b^2);
end
end
