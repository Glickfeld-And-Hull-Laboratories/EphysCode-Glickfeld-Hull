function [ struct] = ExquisiteIsolation(struct, TimeGridA, TimeGridB, TimeLimit, AllBinary)
tic
%AllBinary = ReadInAllBinary(TimeLimit); % If AllBinary is passed in, commment out here and add to passback results
toc
for n = 1:1%length(struct)
    n = n
    unit = struct(n).unitID
    reportViolations = ISIviolationsNew(TimeGridA, TimeGridB, struct, unit, TimeLimit);
    struct(n).ISIviol = reportViolations;
    struct(n).TimeLimit = TimeLimit;
    struct(n).FileName = 'DH12_21_12_01g1';
    if ~strcmp(reportViolations, 'more than 5%')
        TimeGridA = TimeGridA
        TimeLimit = TimeLimit
        unit = unit
        [SigNoise2, AvgWvF, StDev] = WFavgSigNoiseNew(TimeGridA, TimeGridB, struct, AllBinary, .003, TimeLimit, unit);
        struct(n).SigNoise = SigNoise2;
        struct(n).AvgWvF = AvgWvF;
        struct(n).StDev = StDev;
    end
    toc
end
        