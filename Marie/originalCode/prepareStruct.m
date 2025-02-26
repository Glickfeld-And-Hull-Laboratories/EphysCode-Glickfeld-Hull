function struct = prepareStruct(struct, laser, descentDepth, angle, filename);
%filename is a string indicating file

struct = getTrueDepth(struct, descentDepth, angle);

for n = 1:length(struct)
    struct(n).fileName = filename;
    struct(n).Laser = laser;
 
     [meanLine, EXClatency, INHlatency, respType] = GeneralHistForStructTimeLim(laser, n, struct, -.5, .05, [0 inf], .001, 'k');
    struct(n).meanLine = meanLine;
    struct(n).EXClatency = EXClatency;
    struct(n).INHlatency = INHlatency;
    struct(n).respType = respType;
    TimeLim(1) = struct(n).timestamps(1);
    TimeLim(2) = struct(n).timestamps(end);
    struct(n).TimeLim = TimeLim;
    struct(n).CellType = 'all';
    %struct(n).JuiceTimesAdj = juicetimesAdj;
    
end