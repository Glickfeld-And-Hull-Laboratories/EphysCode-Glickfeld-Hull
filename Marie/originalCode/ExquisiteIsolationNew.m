function [struct] = ExquisiteIsolationNew(struct, TimeGridA, TimeGridB, TimeLimit, AllBinaryStruct, filename)
%[struct] = ExquisiteIsolationNew(struct, TimeGridA, TimeGridB, TimeLimit, BinaryStruct)
%tic
%[AllBinaryStruct] = ReadInAllBinary(TimeLimit); % If AllBinary is passed in, commment out here and add to passback results
%toctime = toc
for n = 1:length(struct)
    
    unit = struct(n).unitID
    reportViolations = ISIviolationsNew(TimeGridA, TimeGridB, struct, unit, TimeLimit);
    struct(n).ISIviol = reportViolations;
    struct(n).TimeLimit = TimeLimit;
    struct(n).FileName = filename;
    %if ~strcmp(reportViolations, 'more than 5%')
        [SigNoise2, AvgWvF, StDev] = WFavgSigNoiseNewUseStruct(TimeGridA, TimeGridB, struct, AllBinaryStruct, .003, TimeLimit, unit);
        struct(n).SigNoise = SigNoise2;
        struct(n).AvgWvF = AvgWvF;
        struct(n).StDev = StDev;
    %end
%toctime = toc
    
%channels = [struct.channel].';
%UniqueChannels = unique(channels);
%    for c = 1:length(UniqueChannels)
%    BinaryChannels(c).chan = UniqueGoodChannels(c);
%    matlabCH = UniqueGoodChannels(c)+1;
%    BinaryChannels(c).Binary = AllBinary(matlabCH,:);
%    end
    
%toctime = toc
end
        